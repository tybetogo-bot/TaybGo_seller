/// Google Places API service for address search
library;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;

import '../models/order_model.dart';

/// Google Places API key
const String _placesApiKey = 'AIzaSyBIruHrqkvAAWUQRAWtKOWT77qw-5KbAJE';

/// CORS proxy for web platform (only for development/testing)
const String _corsProxy = 'https://corsproxy.io/?';

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

  /// Search for place predictions (autocomplete)
  static Future<List<PlacePrediction>> searchAddress(String query) async {
    if (query.trim().length < 3) {
      if (kDebugMode) {
        print('[PlacesAPI] Query too short: ${query.trim().length} chars');
      }
      return [];
    }

    try {
      // Build the full URL with parameters
      final baseUrl =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      final params = {
        'input': query,
        'key': _placesApiKey,
        'types': 'address',
        'language': 'en',
        // Bias towards Netherlands, Austria, and Germany
        'components': 'country:nl|country:at|country:de',
      };

      final uri = Uri.parse(baseUrl).replace(queryParameters: params);
      final requestUrl = _isWeb
          ? '$_corsProxy${uri.toString()}'
          : uri.toString();

      if (kDebugMode) {
        print('[PlacesAPI] Searching for: $query');
        print(
          '[PlacesAPI] Request URL: ${_isWeb ? "Using CORS proxy" : baseUrl}',
        );
      }

      final response = await _dio.get(requestUrl);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final status = data['status'] as String?;

        if (kDebugMode) {
          print('[PlacesAPI] Response status: $status');
        }

        if (status != 'OK' && status != 'ZERO_RESULTS') {
          if (kDebugMode) {
            print('[PlacesAPI] API error: $status - ${data['error_message']}');
          }
          return [];
        }

        final predictions = data['predictions'] as List<dynamic>? ?? [];
        if (kDebugMode) {
          print('[PlacesAPI] Found ${predictions.length} predictions');
        }

        return predictions.map((p) {
          final structured =
              p['structured_formatting'] as Map<String, dynamic>? ?? {};
          return PlacePrediction(
            placeId: p['place_id'] as String? ?? '',
            description: p['description'] as String? ?? '',
            mainText:
                structured['main_text'] as String? ??
                p['description'] as String? ??
                '',
            secondaryText: structured['secondary_text'] as String? ?? '',
          );
        }).toList();
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

  /// Get place details by place ID
  static Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    try {
      final baseUrl = 'https://maps.googleapis.com/maps/api/place/details/json';
      final params = {
        'place_id': placeId,
        'key': _placesApiKey,
        'fields': 'geometry,address_components,formatted_address',
      };

      final uri = Uri.parse(baseUrl).replace(queryParameters: params);
      final requestUrl = _isWeb
          ? '$_corsProxy${uri.toString()}'
          : uri.toString();

      if (kDebugMode) {
        print('[PlacesAPI] Getting details for placeId: $placeId');
      }

      final response = await _dio.get(requestUrl);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final status = data['status'] as String?;

        if (status != 'OK') {
          if (kDebugMode) {
            print('[PlacesAPI] Details error: $status');
          }
          return null;
        }

        final result = data['result'] as Map<String, dynamic>?;
        if (result != null) {
          return _parseResult(result);
        }
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
  static Future<AddressModel?> searchAndGetAddress(String addressQuery) async {
    if (kDebugMode) {
      print('[PlacesAPI] ===== searchAndGetAddress START =====');
      print('[PlacesAPI] Query: $addressQuery');
      print(
        '[PlacesAPI] Platform: ${_isWeb ? "Web (using CORS proxy)" : "Native"}',
      );
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
      final predictions = await searchAddress(addressQuery);

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

  /// Parse place result to PlaceDetails
  static PlaceDetails _parseResult(Map<String, dynamic> result) {
    final geometry = result['geometry'] as Map<String, dynamic>?;
    final location = geometry?['location'] as Map<String, dynamic>?;
    final components = result['address_components'] as List<dynamic>? ?? [];

    String? streetNumber;
    String? streetName;
    String? city;
    String? postalCode;
    String? country;

    for (final component in components) {
      final types =
          (component['types'] as List<dynamic>?)?.cast<String>() ?? [];
      final longName = component['long_name'] as String?;

      if (types.contains('street_number')) {
        streetNumber = longName;
      } else if (types.contains('route')) {
        streetName = longName;
      } else if (types.contains('locality')) {
        city = longName;
      } else if (types.contains('postal_code')) {
        postalCode = longName;
      } else if (types.contains('country')) {
        country = longName;
      }
    }

    return PlaceDetails(
      latitude: (location?['lat'] as num?)?.toDouble(),
      longitude: (location?['lng'] as num?)?.toDouble(),
      formattedAddress: result['formatted_address'] as String?,
      streetName: streetName,
      streetNumber: streetNumber,
      city: city,
      postalCode: postalCode,
      country: country,
    );
  }
}
