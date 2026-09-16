/// Web implementation backed by the supported Google Maps JavaScript API.
library;

import 'dart:js_interop';

@JS('taybgoPlacesAutocomplete')
external JSPromise<JSAny?> _autocomplete(
  JSString apiKey,
  JSString query,
  JSString? countryCode,
);

@JS('taybgoPlaceDetails')
external JSPromise<JSAny?> _placeDetails(JSString apiKey, JSString placeId);

@JS('taybgoGeocodeAddress')
external JSPromise<JSAny?> _geocodeAddress(JSString apiKey, JSString address);

@JS('taybgoReverseGeocodeCountry')
external JSPromise<JSAny?> _reverseGeocodeCountry(
  JSString apiKey,
  JSNumber latitude,
  JSNumber longitude,
);

Future<List<Map<String, dynamic>>> webPlacesAutocomplete(
  String apiKey,
  String query, {
  String? countryCode,
}) async {
  final result = await _autocomplete(
    apiKey.toJS,
    query.toJS,
    countryCode?.toJS,
  ).toDart;
  final values = result?.dartify() as List<Object?>? ?? const [];
  return values
      .map((value) => Map<String, dynamic>.from(value! as Map))
      .toList();
}

Future<Map<String, dynamic>?> webPlaceDetails(
  String apiKey,
  String placeId,
) async {
  final result = await _placeDetails(apiKey.toJS, placeId.toJS).toDart;
  final value = result?.dartify();
  return value == null ? null : Map<String, dynamic>.from(value as Map);
}

Future<Map<String, dynamic>?> webGeocodeAddress(
  String apiKey,
  String address,
) async {
  final result = await _geocodeAddress(apiKey.toJS, address.toJS).toDart;
  final value = result?.dartify();
  return value == null ? null : Map<String, dynamic>.from(value as Map);
}

Future<String?> webReverseGeocodeCountry(
  String apiKey,
  double latitude,
  double longitude,
) async {
  final result = await _reverseGeocodeCountry(
    apiKey.toJS,
    latitude.toJS,
    longitude.toJS,
  ).toDart;
  return result?.dartify() as String?;
}
