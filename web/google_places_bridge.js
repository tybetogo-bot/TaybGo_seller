(function () {
  let loaderPromise;
  let loadedKey;

  function loadGoogleMaps(apiKey) {
    if (window.google && window.google.maps && window.google.maps.importLibrary) {
      return Promise.resolve(window.google.maps);
    }
    if (loaderPromise) {
      if (loadedKey !== apiKey) {
        return Promise.reject(new Error('Google Maps was initialized with a different API key.'));
      }
      return loaderPromise;
    }

    loadedKey = apiKey;
    loaderPromise = new Promise(function (resolve, reject) {
      const callbackName = '__taybgoGoogleMapsReady';
      window[callbackName] = function () {
        delete window[callbackName];
        resolve(window.google.maps);
      };

      const script = document.createElement('script');
      script.async = true;
      script.defer = true;
      script.src = 'https://maps.googleapis.com/maps/api/js?key=' +
        encodeURIComponent(apiKey) +
        '&v=weekly&loading=async&libraries=places&callback=' + callbackName;
      script.onerror = function () {
        delete window[callbackName];
        loaderPromise = undefined;
        reject(new Error('Unable to load the Google Maps JavaScript API.'));
      };
      document.head.appendChild(script);
    });
    return loaderPromise;
  }

  function componentValue(component) {
    return component.longText || component.long_name || '';
  }

  function addressFields(components) {
    const fields = {};
    (components || []).forEach(function (component) {
      const types = component.types || [];
      if (types.includes('street_number')) fields.streetNumber = componentValue(component);
      if (types.includes('route')) fields.streetName = componentValue(component);
      if (types.includes('locality')) fields.city = componentValue(component);
      if (!fields.city && types.includes('postal_town')) fields.city = componentValue(component);
      if (!fields.city && types.includes('administrative_area_level_2')) fields.city = componentValue(component);
      if (types.includes('postal_code')) fields.postalCode = componentValue(component);
      if (types.includes('country')) {
        fields.country = componentValue(component);
        fields.countryCode = (component.shortText || component.short_name || '').toLowerCase();
      }
    });
    return fields;
  }

  window.taybgoPlacesAutocomplete = async function (apiKey, query, countryCode) {
    const maps = await loadGoogleMaps(apiKey);
    const places = await maps.importLibrary('places');
    const request = { input: query, language: 'en' };
    if (countryCode) request.includedRegionCodes = [countryCode.toLowerCase()];

    try {
      const response = await places.AutocompleteSuggestion.fetchAutocompleteSuggestions(request);
      return (response.suggestions || []).map(function (suggestion) {
        const prediction = suggestion.placePrediction;
        return {
          placeId: prediction.placeId,
          description: prediction.text ? prediction.text.text : '',
          mainText: prediction.mainText ? prediction.mainText.text : '',
          secondaryText: prediction.secondaryText ? prediction.secondaryText.text : ''
        };
      });
    } catch (newApiError) {
      // Existing Google Maps projects may have the Places JavaScript service
      // enabled without access to the newer AutocompleteSuggestions RPC.
      // Keep the supported legacy JS service as a compatibility fallback.
      const legacyRequest = { input: query };
      if (countryCode) {
        legacyRequest.componentRestrictions = { country: countryCode.toLowerCase() };
      }
      const predictions = await new Promise(function (resolve, reject) {
        const service = new places.AutocompleteService();
        service.getPlacePredictions(legacyRequest, function (results, status) {
          if (status === places.PlacesServiceStatus.OK ||
              status === places.PlacesServiceStatus.ZERO_RESULTS) {
            resolve(results || []);
          } else {
            reject(new Error('Google Places autocomplete failed: ' + status));
          }
        });
      });
      return predictions.map(function (prediction) {
        const structured = prediction.structured_formatting || {};
        return {
          placeId: prediction.place_id || '',
          description: prediction.description || '',
          mainText: structured.main_text || prediction.description || '',
          secondaryText: structured.secondary_text || ''
        };
      });
    }
  };

  window.taybgoPlaceDetails = async function (apiKey, placeId) {
    const maps = await loadGoogleMaps(apiKey);
    const places = await maps.importLibrary('places');
    try {
      const place = new places.Place({ id: placeId });
      await place.fetchFields({
        fields: ['location', 'formattedAddress', 'addressComponents']
      });
      const fields = addressFields(place.addressComponents);
      return Object.assign(fields, {
        latitude: place.location ? place.location.lat() : null,
        longitude: place.location ? place.location.lng() : null,
        formattedAddress: place.formattedAddress || null
      });
    } catch (newApiError) {
      const result = await new Promise(function (resolve, reject) {
        const container = document.createElement('div');
        const service = new places.PlacesService(container);
        service.getDetails({
          placeId: placeId,
          fields: ['geometry', 'formatted_address', 'address_components']
        }, function (place, status) {
          if (status === places.PlacesServiceStatus.OK && place) {
            resolve(place);
          } else {
            reject(new Error('Google Place details failed: ' + status));
          }
        });
      });
      const fields = addressFields(result.address_components);
      return Object.assign(fields, {
        latitude: result.geometry && result.geometry.location
          ? result.geometry.location.lat()
          : null,
        longitude: result.geometry && result.geometry.location
          ? result.geometry.location.lng()
          : null,
        formattedAddress: result.formatted_address || null
      });
    }
  };

  window.taybgoGeocodeAddress = async function (apiKey, address) {
    const maps = await loadGoogleMaps(apiKey);
    const geocoder = new maps.Geocoder();
    const response = await geocoder.geocode({ address: address });
    if (!response.results || response.results.length === 0) return null;
    const location = response.results[0].geometry.location;
    return { latitude: location.lat(), longitude: location.lng() };
  };

  window.taybgoReverseGeocodeCountry = async function (apiKey, latitude, longitude) {
    const maps = await loadGoogleMaps(apiKey);
    const geocoder = new maps.Geocoder();
    const response = await geocoder.geocode({ location: { lat: latitude, lng: longitude } });
    for (const result of response.results || []) {
      const fields = addressFields(result.address_components);
      if (fields.countryCode) return fields.countryCode;
    }
    return null;
  };
})();
