import 'dart:async';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';
import '../../data/models/order_model.dart';

/// Supported countries for address search
class _SupportedCountry {
  final String code;
  final String name;

  const _SupportedCountry({
    required this.code,
    required this.name,
  });

  /// Generate flag emoji from ISO country code
  String get flag {
    final codePoints = code.toUpperCase().codeUnits.map((c) => 0x1F1E6 + c - 0x41);
    return String.fromCharCodes(codePoints);
  }
}

const List<_SupportedCountry> _supportedCountries = [
  _SupportedCountry(code: 'af', name: 'Afghanistan'),
  _SupportedCountry(code: 'al', name: 'Albania'),
  _SupportedCountry(code: 'dz', name: 'Algeria'),
  _SupportedCountry(code: 'ad', name: 'Andorra'),
  _SupportedCountry(code: 'ao', name: 'Angola'),
  _SupportedCountry(code: 'ag', name: 'Antigua and Barbuda'),
  _SupportedCountry(code: 'ar', name: 'Argentina'),
  _SupportedCountry(code: 'am', name: 'Armenia'),
  _SupportedCountry(code: 'au', name: 'Australia'),
  _SupportedCountry(code: 'at', name: 'Austria'),
  _SupportedCountry(code: 'az', name: 'Azerbaijan'),
  _SupportedCountry(code: 'bs', name: 'Bahamas'),
  _SupportedCountry(code: 'bh', name: 'Bahrain'),
  _SupportedCountry(code: 'bd', name: 'Bangladesh'),
  _SupportedCountry(code: 'bb', name: 'Barbados'),
  _SupportedCountry(code: 'by', name: 'Belarus'),
  _SupportedCountry(code: 'be', name: 'Belgium'),
  _SupportedCountry(code: 'bz', name: 'Belize'),
  _SupportedCountry(code: 'bj', name: 'Benin'),
  _SupportedCountry(code: 'bt', name: 'Bhutan'),
  _SupportedCountry(code: 'bo', name: 'Bolivia'),
  _SupportedCountry(code: 'ba', name: 'Bosnia and Herzegovina'),
  _SupportedCountry(code: 'bw', name: 'Botswana'),
  _SupportedCountry(code: 'br', name: 'Brazil'),
  _SupportedCountry(code: 'bn', name: 'Brunei'),
  _SupportedCountry(code: 'bg', name: 'Bulgaria'),
  _SupportedCountry(code: 'bf', name: 'Burkina Faso'),
  _SupportedCountry(code: 'bi', name: 'Burundi'),
  _SupportedCountry(code: 'kh', name: 'Cambodia'),
  _SupportedCountry(code: 'cm', name: 'Cameroon'),
  _SupportedCountry(code: 'ca', name: 'Canada'),
  _SupportedCountry(code: 'cv', name: 'Cape Verde'),
  _SupportedCountry(code: 'cf', name: 'Central African Republic'),
  _SupportedCountry(code: 'td', name: 'Chad'),
  _SupportedCountry(code: 'cl', name: 'Chile'),
  _SupportedCountry(code: 'cn', name: 'China'),
  _SupportedCountry(code: 'co', name: 'Colombia'),
  _SupportedCountry(code: 'km', name: 'Comoros'),
  _SupportedCountry(code: 'cg', name: 'Congo'),
  _SupportedCountry(code: 'cd', name: 'Congo (DRC)'),
  _SupportedCountry(code: 'cr', name: 'Costa Rica'),
  _SupportedCountry(code: 'ci', name: "Cote d'Ivoire"),
  _SupportedCountry(code: 'hr', name: 'Croatia'),
  _SupportedCountry(code: 'cu', name: 'Cuba'),
  _SupportedCountry(code: 'cy', name: 'Cyprus'),
  _SupportedCountry(code: 'cz', name: 'Czech Republic'),
  _SupportedCountry(code: 'dk', name: 'Denmark'),
  _SupportedCountry(code: 'dj', name: 'Djibouti'),
  _SupportedCountry(code: 'dm', name: 'Dominica'),
  _SupportedCountry(code: 'do', name: 'Dominican Republic'),
  _SupportedCountry(code: 'ec', name: 'Ecuador'),
  _SupportedCountry(code: 'eg', name: 'Egypt'),
  _SupportedCountry(code: 'sv', name: 'El Salvador'),
  _SupportedCountry(code: 'gq', name: 'Equatorial Guinea'),
  _SupportedCountry(code: 'er', name: 'Eritrea'),
  _SupportedCountry(code: 'ee', name: 'Estonia'),
  _SupportedCountry(code: 'sz', name: 'Eswatini'),
  _SupportedCountry(code: 'et', name: 'Ethiopia'),
  _SupportedCountry(code: 'fj', name: 'Fiji'),
  _SupportedCountry(code: 'fi', name: 'Finland'),
  _SupportedCountry(code: 'fr', name: 'France'),
  _SupportedCountry(code: 'ga', name: 'Gabon'),
  _SupportedCountry(code: 'gm', name: 'Gambia'),
  _SupportedCountry(code: 'ge', name: 'Georgia'),
  _SupportedCountry(code: 'de', name: 'Germany'),
  _SupportedCountry(code: 'gh', name: 'Ghana'),
  _SupportedCountry(code: 'gr', name: 'Greece'),
  _SupportedCountry(code: 'gd', name: 'Grenada'),
  _SupportedCountry(code: 'gt', name: 'Guatemala'),
  _SupportedCountry(code: 'gn', name: 'Guinea'),
  _SupportedCountry(code: 'gw', name: 'Guinea-Bissau'),
  _SupportedCountry(code: 'gy', name: 'Guyana'),
  _SupportedCountry(code: 'ht', name: 'Haiti'),
  _SupportedCountry(code: 'hn', name: 'Honduras'),
  _SupportedCountry(code: 'hu', name: 'Hungary'),
  _SupportedCountry(code: 'is', name: 'Iceland'),
  _SupportedCountry(code: 'in', name: 'India'),
  _SupportedCountry(code: 'id', name: 'Indonesia'),
  _SupportedCountry(code: 'ir', name: 'Iran'),
  _SupportedCountry(code: 'iq', name: 'Iraq'),
  _SupportedCountry(code: 'ie', name: 'Ireland'),
  _SupportedCountry(code: 'il', name: 'Israel'),
  _SupportedCountry(code: 'it', name: 'Italy'),
  _SupportedCountry(code: 'jm', name: 'Jamaica'),
  _SupportedCountry(code: 'jp', name: 'Japan'),
  _SupportedCountry(code: 'jo', name: 'Jordan'),
  _SupportedCountry(code: 'kz', name: 'Kazakhstan'),
  _SupportedCountry(code: 'ke', name: 'Kenya'),
  _SupportedCountry(code: 'ki', name: 'Kiribati'),
  _SupportedCountry(code: 'kw', name: 'Kuwait'),
  _SupportedCountry(code: 'kg', name: 'Kyrgyzstan'),
  _SupportedCountry(code: 'la', name: 'Laos'),
  _SupportedCountry(code: 'lv', name: 'Latvia'),
  _SupportedCountry(code: 'lb', name: 'Lebanon'),
  _SupportedCountry(code: 'ls', name: 'Lesotho'),
  _SupportedCountry(code: 'lr', name: 'Liberia'),
  _SupportedCountry(code: 'ly', name: 'Libya'),
  _SupportedCountry(code: 'li', name: 'Liechtenstein'),
  _SupportedCountry(code: 'lt', name: 'Lithuania'),
  _SupportedCountry(code: 'lu', name: 'Luxembourg'),
  _SupportedCountry(code: 'mg', name: 'Madagascar'),
  _SupportedCountry(code: 'mw', name: 'Malawi'),
  _SupportedCountry(code: 'my', name: 'Malaysia'),
  _SupportedCountry(code: 'mv', name: 'Maldives'),
  _SupportedCountry(code: 'ml', name: 'Mali'),
  _SupportedCountry(code: 'mt', name: 'Malta'),
  _SupportedCountry(code: 'mh', name: 'Marshall Islands'),
  _SupportedCountry(code: 'mr', name: 'Mauritania'),
  _SupportedCountry(code: 'mu', name: 'Mauritius'),
  _SupportedCountry(code: 'mx', name: 'Mexico'),
  _SupportedCountry(code: 'fm', name: 'Micronesia'),
  _SupportedCountry(code: 'md', name: 'Moldova'),
  _SupportedCountry(code: 'mc', name: 'Monaco'),
  _SupportedCountry(code: 'mn', name: 'Mongolia'),
  _SupportedCountry(code: 'me', name: 'Montenegro'),
  _SupportedCountry(code: 'ma', name: 'Morocco'),
  _SupportedCountry(code: 'mz', name: 'Mozambique'),
  _SupportedCountry(code: 'mm', name: 'Myanmar'),
  _SupportedCountry(code: 'na', name: 'Namibia'),
  _SupportedCountry(code: 'nr', name: 'Nauru'),
  _SupportedCountry(code: 'np', name: 'Nepal'),
  _SupportedCountry(code: 'nl', name: 'Netherlands'),
  _SupportedCountry(code: 'nz', name: 'New Zealand'),
  _SupportedCountry(code: 'ni', name: 'Nicaragua'),
  _SupportedCountry(code: 'ne', name: 'Niger'),
  _SupportedCountry(code: 'ng', name: 'Nigeria'),
  _SupportedCountry(code: 'kp', name: 'North Korea'),
  _SupportedCountry(code: 'mk', name: 'North Macedonia'),
  _SupportedCountry(code: 'no', name: 'Norway'),
  _SupportedCountry(code: 'om', name: 'Oman'),
  _SupportedCountry(code: 'pk', name: 'Pakistan'),
  _SupportedCountry(code: 'pw', name: 'Palau'),
  _SupportedCountry(code: 'ps', name: 'Palestine'),
  _SupportedCountry(code: 'pa', name: 'Panama'),
  _SupportedCountry(code: 'pg', name: 'Papua New Guinea'),
  _SupportedCountry(code: 'py', name: 'Paraguay'),
  _SupportedCountry(code: 'pe', name: 'Peru'),
  _SupportedCountry(code: 'ph', name: 'Philippines'),
  _SupportedCountry(code: 'pl', name: 'Poland'),
  _SupportedCountry(code: 'pt', name: 'Portugal'),
  _SupportedCountry(code: 'qa', name: 'Qatar'),
  _SupportedCountry(code: 'ro', name: 'Romania'),
  _SupportedCountry(code: 'ru', name: 'Russia'),
  _SupportedCountry(code: 'rw', name: 'Rwanda'),
  _SupportedCountry(code: 'kn', name: 'Saint Kitts and Nevis'),
  _SupportedCountry(code: 'lc', name: 'Saint Lucia'),
  _SupportedCountry(code: 'vc', name: 'Saint Vincent and the Grenadines'),
  _SupportedCountry(code: 'ws', name: 'Samoa'),
  _SupportedCountry(code: 'sm', name: 'San Marino'),
  _SupportedCountry(code: 'st', name: 'Sao Tome and Principe'),
  _SupportedCountry(code: 'sa', name: 'Saudi Arabia'),
  _SupportedCountry(code: 'sn', name: 'Senegal'),
  _SupportedCountry(code: 'rs', name: 'Serbia'),
  _SupportedCountry(code: 'sc', name: 'Seychelles'),
  _SupportedCountry(code: 'sl', name: 'Sierra Leone'),
  _SupportedCountry(code: 'sg', name: 'Singapore'),
  _SupportedCountry(code: 'sk', name: 'Slovakia'),
  _SupportedCountry(code: 'si', name: 'Slovenia'),
  _SupportedCountry(code: 'sb', name: 'Solomon Islands'),
  _SupportedCountry(code: 'so', name: 'Somalia'),
  _SupportedCountry(code: 'za', name: 'South Africa'),
  _SupportedCountry(code: 'kr', name: 'South Korea'),
  _SupportedCountry(code: 'ss', name: 'South Sudan'),
  _SupportedCountry(code: 'es', name: 'Spain'),
  _SupportedCountry(code: 'lk', name: 'Sri Lanka'),
  _SupportedCountry(code: 'sd', name: 'Sudan'),
  _SupportedCountry(code: 'sr', name: 'Suriname'),
  _SupportedCountry(code: 'se', name: 'Sweden'),
  _SupportedCountry(code: 'ch', name: 'Switzerland'),
  _SupportedCountry(code: 'sy', name: 'Syria'),
  _SupportedCountry(code: 'tw', name: 'Taiwan'),
  _SupportedCountry(code: 'tj', name: 'Tajikistan'),
  _SupportedCountry(code: 'tz', name: 'Tanzania'),
  _SupportedCountry(code: 'th', name: 'Thailand'),
  _SupportedCountry(code: 'tl', name: 'Timor-Leste'),
  _SupportedCountry(code: 'tg', name: 'Togo'),
  _SupportedCountry(code: 'to', name: 'Tonga'),
  _SupportedCountry(code: 'tt', name: 'Trinidad and Tobago'),
  _SupportedCountry(code: 'tn', name: 'Tunisia'),
  _SupportedCountry(code: 'tr', name: 'Turkey'),
  _SupportedCountry(code: 'tm', name: 'Turkmenistan'),
  _SupportedCountry(code: 'tv', name: 'Tuvalu'),
  _SupportedCountry(code: 'ug', name: 'Uganda'),
  _SupportedCountry(code: 'ua', name: 'Ukraine'),
  _SupportedCountry(code: 'ae', name: 'United Arab Emirates'),
  _SupportedCountry(code: 'gb', name: 'United Kingdom'),
  _SupportedCountry(code: 'us', name: 'United States'),
  _SupportedCountry(code: 'uy', name: 'Uruguay'),
  _SupportedCountry(code: 'uz', name: 'Uzbekistan'),
  _SupportedCountry(code: 'vu', name: 'Vanuatu'),
  _SupportedCountry(code: 've', name: 'Venezuela'),
  _SupportedCountry(code: 'vn', name: 'Vietnam'),
  _SupportedCountry(code: 'ye', name: 'Yemen'),
  _SupportedCountry(code: 'zm', name: 'Zambia'),
  _SupportedCountry(code: 'zw', name: 'Zimbabwe'),
];

/// Google Places API key
const String _placesApiKey = 'AIzaSyC2AE-hUVzVqtd-LP3QcVED_XQP9c7OCHc';

/// CORS proxy for web platform
const String _corsProxy = 'https://corsproxy.io/?';

/// Google Places API service
class _PlacesApiService {
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  /// Check if running on web platform
  static bool get _isWeb => kIsWeb;

  /// Search for place predictions (autocomplete)
  static Future<List<_PlacePrediction>> getAutocomplete(String query, {String? countryCode}) async {
    try {
      final baseUrl = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      final params = {
        'input': query,
        'key': _placesApiKey,
        'types': 'geocode|establishment',
        'language': 'en',
        if (countryCode != null) 'components': 'country:$countryCode',
      };

      final uri = Uri.parse(baseUrl).replace(queryParameters: params);
      final requestUrl = _isWeb ? '$_corsProxy${Uri.encodeComponent(uri.toString())}' : uri.toString();

      if (kDebugMode) {
        print('[PlacesAPI-Widget] Searching for: $query');
        print('[PlacesAPI-Widget] Platform: ${_isWeb ? "Web (CORS proxy)" : "Native"}');
      }

      final response = await _dio.get(requestUrl);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        // Check for API errors
        final status = data['status'] as String?;
        if (kDebugMode) {
          print('[PlacesAPI-Widget] Response status: $status');
        }

        if (status != 'OK' && status != 'ZERO_RESULTS') {
          if (kDebugMode) {
            print('[PlacesAPI-Widget] API error status: $status');
            print('[PlacesAPI-Widget] Error message: ${data['error_message']}');
          }
          return [];
        }

        final predictions = data['predictions'] as List<dynamic>? ?? [];
        if (kDebugMode) {
          print('[PlacesAPI-Widget] Found ${predictions.length} predictions');
        }

        return predictions.map((p) {
          final structured = p['structured_formatting'] as Map<String, dynamic>? ?? {};
          return _PlacePrediction(
            placeId: p['place_id'] as String? ?? '',
            description: p['description'] as String? ?? '',
            mainText: structured['main_text'] as String? ?? p['description'] as String? ?? '',
            secondaryText: structured['secondary_text'] as String? ?? '',
          );
        }).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('[PlacesAPI-Widget] Autocomplete error: $e');
      }
      return [];
    }
  }

  /// Reverse geocode coordinates to get country code (for web)
  static Future<String?> reverseGeocodeCountry(double lat, double lng) async {
    try {
      final baseUrl = 'https://maps.googleapis.com/maps/api/geocode/json';
      final params = {
        'latlng': '$lat,$lng',
        'key': _placesApiKey,
        'result_type': 'country',
      };

      final uri = Uri.parse(baseUrl).replace(queryParameters: params);
      final requestUrl = _isWeb ? '$_corsProxy${Uri.encodeComponent(uri.toString())}' : uri.toString();

      final response = await _dio.get(requestUrl);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>? ?? [];
        if (results.isNotEmpty) {
          final components = results[0]['address_components'] as List<dynamic>? ?? [];
          for (final component in components) {
            final types = (component['types'] as List<dynamic>?)?.cast<String>() ?? [];
            if (types.contains('country')) {
              return (component['short_name'] as String?)?.toLowerCase();
            }
          }
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('[PlacesAPI-Widget] Reverse geocode error: $e');
      }
      return null;
    }
  }

  /// Forward geocode an address string to coordinates (for web)
  static Future<({double lat, double lng})?> geocodeAddress(String address) async {
    try {
      final baseUrl = 'https://maps.googleapis.com/maps/api/geocode/json';
      final params = {
        'address': address,
        'key': _placesApiKey,
      };

      final uri = Uri.parse(baseUrl).replace(queryParameters: params);
      final requestUrl = _isWeb ? '$_corsProxy${Uri.encodeComponent(uri.toString())}' : uri.toString();

      final response = await _dio.get(requestUrl);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>? ?? [];
        if (results.isNotEmpty) {
          final geometry = results[0]['geometry'] as Map<String, dynamic>?;
          final location = geometry?['location'] as Map<String, dynamic>?;
          if (location != null) {
            return (
              lat: (location['lat'] as num).toDouble(),
              lng: (location['lng'] as num).toDouble(),
            );
          }
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('[PlacesAPI-Widget] Geocode error: $e');
      }
      return null;
    }
  }

  /// Get place details including lat/lng
  static Future<_PlaceDetails?> getPlaceDetails(String placeId) async {
    try {
      final baseUrl = 'https://maps.googleapis.com/maps/api/place/details/json';
      final params = {
        'place_id': placeId,
        'key': _placesApiKey,
        'fields': 'geometry,address_components,formatted_address',
      };

      final uri = Uri.parse(baseUrl).replace(queryParameters: params);
      final requestUrl = _isWeb ? '$_corsProxy${Uri.encodeComponent(uri.toString())}' : uri.toString();

      if (kDebugMode) {
        print('[PlacesAPI-Widget] Getting details for placeId: $placeId');
      }

      final response = await _dio.get(requestUrl);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        // Check for API errors
        final status = data['status'] as String?;
        if (status != 'OK') {
          if (kDebugMode) {
            print('[PlacesAPI-Widget] Details error: $status');
          }
          return null;
        }

        final result = data['result'] as Map<String, dynamic>?;

        if (result != null) {
          final geometry = result['geometry'] as Map<String, dynamic>?;
          final location = geometry?['location'] as Map<String, dynamic>?;
          final components = result['address_components'] as List<dynamic>? ?? [];

          String? streetNumber;
          String? streetName;
          String? city;
          String? postalCode;
          String? country;

          for (final component in components) {
            final types = (component['types'] as List<dynamic>?)?.cast<String>() ?? [];
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

          if (kDebugMode) {
            print('[PlacesAPI-Widget] Got details - lat: ${location?['lat']}, lng: ${location?['lng']}');
          }

          return _PlaceDetails(
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
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('[PlacesAPI-Widget] Place details error: $e');
      }
      return null;
    }
  }
}

/// Place details from Google Places API
class _PlaceDetails {
  final double? latitude;
  final double? longitude;
  final String? formattedAddress;
  final String? streetName;
  final String? streetNumber;
  final String? city;
  final String? postalCode;
  final String? country;

  const _PlaceDetails({
    this.latitude,
    this.longitude,
    this.formattedAddress,
    this.streetName,
    this.streetNumber,
    this.city,
    this.postalCode,
    this.country,
  });
}

/// Address search widget using Google Places API
/// Note: Requires Google Places API key to be configured
class AddressSearchWidget extends StatefulWidget {
  const AddressSearchWidget({
    super.key,
    required this.onAddressSelected,
    this.initialAddress,
  });

  final ValueChanged<AddressModel> onAddressSelected;
  final AddressModel? initialAddress;

  @override
  State<AddressSearchWidget> createState() => _AddressSearchWidgetState();
}

class _AddressSearchWidgetState extends State<AddressSearchWidget> {
  final _searchController = TextEditingController();
  final _streetController = TextEditingController();
  final _buildingController = TextEditingController();
  final _apartmentController = TextEditingController();
  final _floorController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();

  List<_PlacePrediction> _predictions = [];
  bool _isSearching = false;
  bool _showManualEntry = false;
  Timer? _debounce;

  // Flag to prevent didUpdateWidget from re-triggering search
  // when the parent updates initialAddress from our own selection
  bool _selfUpdated = false;

  // Country selector state
  String _selectedCountryCode = 'at';
  bool _detectingLocation = false;

  // Store coordinates and country from Places API
  double? _latitude;
  double? _longitude;
  String? _country;

  void _log(String message, {Object? error}) {
    if (kDebugMode) {
      developer.log(message, name: 'AddressSearchWidget', error: error);
      // ignore: avoid_print
      print('[AddressSearchWidget] $message');
    }
  }

  @override
  void initState() {
    super.initState();
    // Set initial country name from default country code
    final defaultCountry = _supportedCountries.firstWhere(
      (c) => c.code == _selectedCountryCode,
    );
    _country = defaultCountry.name;

    if (widget.initialAddress != null) {
      _populateFields(widget.initialAddress!);
      _showManualEntry = true;
    }
    _detectUserCountry();
  }

  Future<void> _detectUserCountry() async {
    setState(() => _detectingLocation = true);
    try {
      if (!kIsWeb) {
        // On native, check/request permission first
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          _log('Location permission denied');
          return;
        }
      }
      // On web, just call getCurrentPosition directly —
      // the browser will show its own permission prompt.

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );

      String? isoCode;

      if (kIsWeb) {
        // On web, use Google Geocoding API for reverse geocoding
        isoCode = await _PlacesApiService.reverseGeocodeCountry(
          position.latitude,
          position.longitude,
        );
      } else {
        // On native, use platform geocoding
        final placemarks = await geocoding.placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          isoCode = placemarks.first.isoCountryCode?.toLowerCase();
        }
      }

      _log('Detected country: $isoCode');
      if (isoCode != null && mounted) {
        final matchedCountry = _supportedCountries.where((c) => c.code == isoCode);
        if (matchedCountry.isNotEmpty) {
          setState(() {
            _selectedCountryCode = isoCode!;
            _country = matchedCountry.first.name;
          });
        }
      }
    } catch (e) {
      _log('Country detection error: $e');
    } finally {
      if (mounted) setState(() => _detectingLocation = false);
    }
  }

  @override
  void didUpdateWidget(covariant AddressSearchWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the update came from our own selection, skip re-triggering search
    if (_selfUpdated) {
      _selfUpdated = false;
      return;
    }
    // If initialAddress changed and has data, trigger search (e.g. from scan)
    if (widget.initialAddress != null &&
        widget.initialAddress != oldWidget.initialAddress) {
      final newAddress = widget.initialAddress!;
      _log('Initial address updated - triggering search');
      _log('Street: ${newAddress.street}, Building: ${newAddress.building}');

      // Build search query from address
      final searchParts = <String>[];
      if (newAddress.street.isNotEmpty) searchParts.add(newAddress.street);
      if (newAddress.building.isNotEmpty) searchParts.add(newAddress.building);
      if (newAddress.postalCode != null && newAddress.postalCode!.isNotEmpty) {
        searchParts.add(newAddress.postalCode!);
      }
      if (newAddress.city != null && newAddress.city!.isNotEmpty) {
        searchParts.add(newAddress.city!);
      }

      final searchQuery = searchParts.join(' ').trim();

      if (searchQuery.length >= 3) {
        // Set search text and trigger search
        _searchController.text = searchQuery;
        _log('Searching for: $searchQuery');
        _searchPlaces(searchQuery);
      } else {
        // Just populate fields without search
        _populateFields(newAddress);
        _showManualEntry = true;
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _streetController.dispose();
    _buildingController.dispose();
    _apartmentController.dispose();
    _floorController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  void _populateFields(AddressModel address) {
    _streetController.text = address.street;
    _buildingController.text = address.building;
    _apartmentController.text = address.apartment ?? '';
    _floorController.text = address.floor ?? '';
    _cityController.text = address.city ?? '';
    _postalCodeController.text = address.postalCode ?? '';
    _latitude = address.latitude;
    _longitude = address.longitude;
    _country = address.country;
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.length < 3) {
      setState(() {
        _predictions = [];
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchPlaces(query);
    });
  }

  Future<void> _searchPlaces(String query) async {
    setState(() {
      _isSearching = true;
    });

    _log('Searching places for: $query');

    // Use Google Places API for autocomplete, filtered by selected country
    final predictions = await _PlacesApiService.getAutocomplete(
      query,
      countryCode: _selectedCountryCode,
    );

    _log('Got ${predictions.length} predictions');

    if (mounted) {
      setState(() {
        _predictions = predictions;
        _isSearching = false;
      });
    }
  }

  Future<void> _selectPlace(_PlacePrediction prediction) async {
    _log('Selecting place: ${prediction.description} (placeId: ${prediction.placeId})');

    setState(() {
      _isSearching = true;
      _predictions = [];
      _searchController.text = prediction.mainText;
    });

    // Get place details including lat/lng from Google Places API
    final details = await _PlacesApiService.getPlaceDetails(prediction.placeId);

    if (details != null) {
      _log('Got place details - lat: ${details.latitude}, lng: ${details.longitude}');
      _log('Street: ${details.streetName} ${details.streetNumber}, City: ${details.city}');

      setState(() {
        _showManualEntry = true;
        _isSearching = false;
        _latitude = details.latitude;
        _longitude = details.longitude;
        _country = details.country;
        _streetController.text = details.streetName ?? prediction.mainText;
        _buildingController.text = details.streetNumber ?? '';
        _cityController.text = details.city ?? '';
        _postalCodeController.text = details.postalCode ?? '';
      });
    } else {
      _log('Failed to get place details, using prediction data');
      setState(() {
        _showManualEntry = true;
        _isSearching = false;
        _streetController.text = prediction.mainText;
        _cityController.text = prediction.secondaryText.split(',').first.trim();
      });
    }

    _notifyAddressChanged();
  }

  void _notifyAddressChanged() {
    _log('Notifying address change - lat: $_latitude, lng: $_longitude');
    // Mark that this update originated from within the widget,
    // so didUpdateWidget won't re-trigger a search.
    _selfUpdated = true;
    // Use the selected country from dropdown as fallback
    final countryName = _country ??
        _supportedCountries
            .firstWhere((c) => c.code == _selectedCountryCode)
            .name;
    final address = AddressModel(
      street: _streetController.text,
      building: _buildingController.text,
      apartment: _apartmentController.text.isNotEmpty ? _apartmentController.text : null,
      floor: _floorController.text.isNotEmpty ? _floorController.text : null,
      city: _cityController.text.isNotEmpty ? _cityController.text : null,
      postalCode: _postalCodeController.text.isNotEmpty ? _postalCodeController.text : null,
      country: countryName,
      latitude: _latitude,
      longitude: _longitude,
    );
    widget.onAddressSelected(address);
  }

  /// Geocode the current address to get coordinates (for manual entry)
  Future<void> _geocodeCurrentAddress() async {
    if (_streetController.text.isEmpty) return;

    final addressParts = <String>[
      _streetController.text,
      if (_buildingController.text.isNotEmpty) _buildingController.text,
      if (_cityController.text.isNotEmpty) _cityController.text,
      if (_postalCodeController.text.isNotEmpty) _postalCodeController.text,
      if (_country != null && _country!.isNotEmpty) _country!,
    ];
    final addressString = addressParts.join(', ');

    _log('Geocoding address: $addressString');

    try {
      if (kIsWeb) {
        // On web, use Google Geocoding API
        final result = await _PlacesApiService.geocodeAddress(addressString);
        if (result != null) {
          _log('Geocoded to: ${result.lat}, ${result.lng}');
          setState(() {
            _latitude = result.lat;
            _longitude = result.lng;
          });
          _notifyAddressChanged();
        }
      } else {
        // On native, use platform geocoding
        final locations = await geocoding.locationFromAddress(addressString);
        if (locations.isNotEmpty) {
          final location = locations.first;
          _log('Geocoded to: ${location.latitude}, ${location.longitude}');
          setState(() {
            _latitude = location.latitude;
            _longitude = location.longitude;
          });
          _notifyAddressChanged();
        }
      }
    } catch (e) {
      _log('Geocoding error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Country selector
        InputDecorator(
          decoration: InputDecoration(
            labelText: 'Country',
            isDense: true,
            filled: true,
            fillColor: isDark ? DarkColors.inputBackground : LightColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: isDark ? DarkColors.border : LightColors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: isDark ? DarkColors.border : LightColors.border,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCountryCode,
              isExpanded: true,
              icon: _detectingLocation
                  ? SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.arrow_drop_down),
              items: _supportedCountries.map((country) {
                return DropdownMenuItem<String>(
                  value: country.code,
                  child: Text(
                    '${country.flag}  ${country.name}',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  final selectedCountry = _supportedCountries.firstWhere(
                    (c) => c.code == value,
                  );
                  setState(() {
                    _selectedCountryCode = value;
                    _country = selectedCountry.name;
                    _predictions = [];
                  });
                  _notifyAddressChanged();
                  // Re-search if there's text in the search field
                  if (_searchController.text.length >= 3) {
                    _searchPlaces(_searchController.text);
                  }
                }
              },
            ),
          ),
        ),

        SizedBox(height: 12.h),

        // Search field
        TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'address.searchForAddress'.tr,
            prefixIcon: Icon(Icons.search, size: 20.w),
            suffixIcon: _isSearching
                ? Padding(
                    padding: EdgeInsets.all(12.w),
                    child: SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, size: 20.w),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _predictions = [];
                          });
                        },
                      )
                    : null,
            filled: true,
            fillColor: isDark ? DarkColors.inputBackground : LightColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: isDark ? DarkColors.border : LightColors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: isDark ? DarkColors.border : LightColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ),

        // Predictions list
        if (_predictions.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Container(
            constraints: BoxConstraints(maxHeight: 200.h),
            decoration: BoxDecoration(
              color: isDark ? DarkColors.surface : LightColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isDark ? DarkColors.border : LightColors.border,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _predictions.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: isDark ? DarkColors.border : LightColors.border,
              ),
              itemBuilder: (context, index) {
                final prediction = _predictions[index];
                return ListTile(
                  dense: true,
                  leading: Icon(
                    Icons.location_on_outlined,
                    size: 20.w,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    prediction.mainText,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    prediction.secondaryText,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
                    ),
                  ),
                  onTap: () => _selectPlace(prediction),
                );
              },
            ),
          ),
        ],

        // Manual entry toggle
        if (!_showManualEntry && _predictions.isEmpty) ...[
          SizedBox(height: 12.h),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _showManualEntry = true;
              });
            },
            icon: Icon(Icons.edit, size: 16.w),
            label: Text('address.enterManually'.tr),
          ),
        ],

        // Manual entry fields
        if (_showManualEntry) ...[
          SizedBox(height: 16.h),

          // Street
          _AddressField(
            controller: _streetController,
            label: 'address.street'.tr,
            hint: 'address.streetName'.tr,
            isRequired: true,
            onChanged: (_) => _notifyAddressChanged(),
            isDark: isDark,
          ),

          SizedBox(height: 12.h),

          // Building number (required for European addresses)
          _AddressField(
            controller: _buildingController,
            label: 'address.building'.tr,
            hint: 'address.buildingHouseNumber'.tr,
            isRequired: true,
            onChanged: (_) => _notifyAddressChanged(),
            isDark: isDark,
          ),

          SizedBox(height: 12.h),

          // Apartment and Floor (optional)
          Row(
            children: [
              Expanded(
                child: _AddressField(
                  controller: _apartmentController,
                  label: 'address.apartment'.tr,
                  hint: 'address.aptUnit'.tr,
                  onChanged: (_) => _notifyAddressChanged(),
                  isDark: isDark,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _AddressField(
                  controller: _floorController,
                  label: 'address.floor'.tr,
                  hint: 'address.floor'.tr,
                  onChanged: (_) => _notifyAddressChanged(),
                  isDark: isDark,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // City and Postal Code
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _AddressField(
                  controller: _cityController,
                  label: 'address.city'.tr,
                  hint: 'address.city'.tr,
                  onChanged: (_) => _notifyAddressChanged(),
                  isDark: isDark,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _AddressField(
                  controller: _postalCodeController,
                  label: 'address.postalCode'.tr,
                  hint: 'address.postalCode'.tr,
                  onChanged: (_) => _notifyAddressChanged(),
                  isDark: isDark,
                ),
              ),
            ],
          ),

          // Get coordinates button (useful for manual entry, especially on web)
          if (_latitude == null && _streetController.text.isNotEmpty) ...[
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _geocodeCurrentAddress,
                icon: Icon(Icons.my_location, size: 18.w),
                label: const Text('Get Location Coordinates'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  side: BorderSide(color: Theme.of(context).colorScheme.primary),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),
          ],

          // Show coordinates if available
          if (_latitude != null && _longitude != null) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary, size: 20.w),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Location: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class _AddressField extends StatelessWidget {
  const _AddressField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.isDark,
    this.isRequired = false,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isDark;
  final bool isRequired;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.error,
                ),
              ),
          ],
        ),
        SizedBox(height: 4.h),
        TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            filled: true,
            fillColor: isDark ? DarkColors.inputBackground : LightColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(
                color: isDark ? DarkColors.border : LightColors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(
                color: isDark ? DarkColors.border : LightColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          ),
        ),
      ],
    );
  }
}

/// Place prediction model for search results
class _PlacePrediction {
  const _PlacePrediction({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });

  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;
}
