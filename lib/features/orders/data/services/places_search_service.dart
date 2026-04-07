/// Google Places API service for address search
library;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;

import '../models/order_model.dart';

/// Google Places API key
const String _placesApiKey = 'AIzaSyBIruHrqkvAAWUQRAWtKOWT77qw-5KbAJE';

/// Place prediction from autocomplete
class PlacePrediction {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  const PlacePrediction({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });
}

/// Place details from Google Places API
class PlaceDetails {
  final double? latitude;
  final double? longitude;
  final String? formattedAddress;
  final String? streetName;
  final String? streetNumber;
  final String? city;
  final String? postalCode;
  final String? country;

  const PlaceDetails({
    this.latitude,
    this.longitude,
    this.formattedAddress,
    this.streetName,
    this.streetNumber,
    this.city,
    this.postalCode,
    this.country,
  });

  /// Convert to AddressModel
  AddressModel toAddressModel({String? placeId}) {
    return AddressModel(
      street: streetName ?? '',
      building: streetNumber ?? '',
      city: city,
      postalCode: postalCode,
      country: country ?? 'Austria',
      placeId: placeId,
      latitude: latitude,
      longitude: longitude,
    );
  }
}

/// Google Places API service for searching addresses
class PlacesSearchService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  /// Check if running on web platform
  static bool get _isWeb => kIsWeb;

  /// Search for place predictions (autocomplete).
  ///
  /// Uses Places API (New) v1 — the legacy `maps.googleapis.com` endpoints
  /// don't send CORS headers and are blocked by browsers. The new API must
  /// be enabled in your GCP console ("Places API (New)"), the same API key
  /// works.
  static Future<List<PlacePrediction>> searchAddress(String query, {String? countryCode}) async {
    if (query.trim().length < 3) {
      if (kDebugMode) {
        print('[PlacesAPI] Query too short: ${query.trim().length} chars');
      }
      return [];
    }

    try {
      const url = 'https://places.googleapis.com/v1/places:autocomplete';

      final body = <String, dynamic>{
        'input': query,
        'languageCode': 'en',
        if (countryCode != null)
          'includedRegionCodes': [countryCode.toLowerCase()],
      };

      if (kDebugMode) {
        print('[PlacesAPI] Searching for: $query (new API)');
      }

      final response = await _dio.post(
        url,
        data: body,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': _placesApiKey,
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final suggestions = data['suggestions'] as List<dynamic>? ?? [];

        if (kDebugMode) {
          print('[PlacesAPI] Found ${suggestions.length} suggestions');
        }

        return suggestions
            .map((s) {
              final prediction =
                  (s as Map<String, dynamic>)['placePrediction']
                      as Map<String, dynamic>?;
              if (prediction == null) return null;

              final placeResource = prediction['place'] as String? ?? '';
              final placeId = prediction['placeId'] as String? ??
                  (placeResource.startsWith('places/')
                      ? placeResource.substring(7)
                      : placeResource);

              final text = prediction['text'] as Map<String, dynamic>?;
              final structured =
                  prediction['structuredFormat'] as Map<String, dynamic>?;
              final mainTextObj =
                  structured?['mainText'] as Map<String, dynamic>?;
              final secondaryTextObj =
                  structured?['secondaryText'] as Map<String, dynamic>?;

              final description = text?['text'] as String? ?? '';
              return PlacePrediction(
                placeId: placeId,
                description: description,
                mainText: mainTextObj?['text'] as String? ?? description,
                secondaryText: secondaryTextObj?['text'] as String? ?? '',
              );
            })
            .whereType<PlacePrediction>()
            .toList();
      }

      if (kDebugMode) {
        print('[PlacesAPI] Non-200 status code: ${response.statusCode}');
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('[PlacesAPI] Search error: $e');
      }
      return [];
    }
  }

  /// Get place details by place ID (Places API New v1).
  static Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    try {
      final url = 'https://places.googleapis.com/v1/places/$placeId';

      if (kDebugMode) {
        print('[PlacesAPI] Getting details for placeId: $placeId (new API)');
      }

      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'X-Goog-Api-Key': _placesApiKey,
            'X-Goog-FieldMask':
                'id,location,addressComponents,formattedAddress',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return _parseNewApiResult(data);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('[PlacesAPI] Details error: $e');
      }
      return null;
    }
  }

  /// Search and get full details for the best matching address
  /// This combines autocomplete + details in one call
  static Future<AddressModel?> searchAndGetAddress(String addressQuery, {String? countryCode}) async {
    if (kDebugMode) {
      print('[PlacesAPI] ===== searchAndGetAddress START =====');
      print('[PlacesAPI] Query: $addressQuery');
      print('[PlacesAPI] Platform: ${_isWeb ? "Web direct" : "Native"}');
    }

    if (addressQuery.trim().length < 3) {
      if (kDebugMode) {
        print(
          '[PlacesAPI] Query too short: ${addressQuery.trim().length} chars',
        );
      }
      return null;
    }

    try {
      // First, search for matching addresses
      final predictions = await searchAddress(addressQuery, countryCode: countryCode);

      if (kDebugMode) {
        print('[PlacesAPI] Got ${predictions.length} predictions');
        for (final p in predictions) {
          print('[PlacesAPI]   - ${p.description} (${p.placeId})');
        }
      }

      if (predictions.isEmpty) {
        if (kDebugMode) {
          print('[PlacesAPI] No predictions found for: $addressQuery');
          print('[PlacesAPI] ===== searchAndGetAddress END (no results) =====');
        }
        return null;
      }

      // Get details for the first (best) match
      final bestMatch = predictions.first;
      if (kDebugMode) {
        print(
          '[PlacesAPI] Getting details for best match: ${bestMatch.description}',
        );
      }
      final details = await getPlaceDetails(bestMatch.placeId);

      if (details != null) {
        if (kDebugMode) {
          print('[PlacesAPI] SUCCESS - Got coordinates!');
          print('[PlacesAPI]   Latitude: ${details.latitude}');
          print('[PlacesAPI]   Longitude: ${details.longitude}');
          print(
            '[PlacesAPI]   Street: ${details.streetName} ${details.streetNumber}',
          );
          print('[PlacesAPI]   City: ${details.city}');
          print('[PlacesAPI]   PostalCode: ${details.postalCode}');
          print('[PlacesAPI]   Country: ${details.country}');
          print('[PlacesAPI] ===== searchAndGetAddress END (success) =====');
        }
        return details.toAddressModel(placeId: bestMatch.placeId);
      }

      if (kDebugMode) {
        print('[PlacesAPI] getPlaceDetails returned null');
        print('[PlacesAPI] ===== searchAndGetAddress END (no details) =====');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('[PlacesAPI] ERROR: $e');
        print('[PlacesAPI] ===== searchAndGetAddress END (error) =====');
      }
      return null;
    }
  }

  /// Reverse geocode coordinates to a country ISO code.
  ///
  /// Uses Places API (New) searchNearby with country-only field mask.
  static Future<String?> reverseGeocodeCountry(double lat, double lng) async {
    try {
      const url = 'https://places.googleapis.com/v1/places:searchNearby';
      final body = <String, dynamic>{
        'locationRestriction': {
          'circle': {
            'center': {'latitude': lat, 'longitude': lng},
            'radius': 50.0,
          },
        },
        'maxResultCount': 1,
      };

      final response = await _dio.post(
        url,
        data: body,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': _placesApiKey,
            'X-Goog-FieldMask': 'places.addressComponents',
          },
        ),
      );

      if (response.statusCode != 200) return null;

      final data = response.data as Map<String, dynamic>;
      final places = data['places'] as List<dynamic>? ?? [];
      if (places.isEmpty) return null;

      final components =
          (places[0] as Map<String, dynamic>)['addressComponents']
              as List<dynamic>? ??
              [];
      for (final component in components) {
        final types =
            ((component as Map<String, dynamic>)['types'] as List<dynamic>?)
                    ?.cast<String>() ??
                [];
        if (types.contains('country')) {
          return (component['shortText'] as String?)?.toLowerCase();
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('[PlacesAPI] Reverse geocode error: $e');
      }
      return null;
    }
  }

  /// Forward geocode an address string to coordinates using
  /// Places API (New) searchText.
  static Future<({double lat, double lng})?> geocodeAddress(
    String address,
  ) async {
    try {
      const url = 'https://places.googleapis.com/v1/places:searchText';
      final body = <String, dynamic>{'textQuery': address};

      final response = await _dio.post(
        url,
        data: body,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': _placesApiKey,
            'X-Goog-FieldMask': 'places.location',
          },
        ),
      );

      if (response.statusCode != 200) return null;

      final data = response.data as Map<String, dynamic>;
      final places = data['places'] as List<dynamic>? ?? [];
      if (places.isEmpty) return null;

      final location =
          (places[0] as Map<String, dynamic>)['location']
              as Map<String, dynamic>?;
      if (location == null) return null;

      return (
        lat: (location['latitude'] as num).toDouble(),
        lng: (location['longitude'] as num).toDouble(),
      );
    } catch (e) {
      if (kDebugMode) {
        print('[PlacesAPI] Geocode error: $e');
      }
      return null;
    }
  }

  /// Parse a Places API (New) place resource to [PlaceDetails].
  static PlaceDetails _parseNewApiResult(Map<String, dynamic> place) {
    final location = place['location'] as Map<String, dynamic>?;
    final components =
        place['addressComponents'] as List<dynamic>? ?? [];

    String? streetNumber;
    String? streetName;
    String? city;
    String? postalCode;
    String? country;

    for (final component in components) {
      final map = component as Map<String, dynamic>;
      final types = (map['types'] as List<dynamic>?)?.cast<String>() ?? [];
      final longText = map['longText'] as String?;

      if (types.contains('street_number')) {
        streetNumber = longText;
      } else if (types.contains('route')) {
        streetName = longText;
      } else if (types.contains('locality')) {
        city = longText;
      } else if (types.contains('postal_code')) {
        postalCode = longText;
      } else if (types.contains('country')) {
        country = longText;
      }
    }

    return PlaceDetails(
      latitude: (location?['latitude'] as num?)?.toDouble(),
      longitude: (location?['longitude'] as num?)?.toDouble(),
      formattedAddress: place['formattedAddress'] as String?,
      streetName: streetName,
      streetNumber: streetNumber,
      city: city,
      postalCode: postalCode,
      country: country,
    );
  }
}
