import 'dart:async';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';
import '../../data/models/order_model.dart';

/// Google Places API key
const String _placesApiKey = 'AIzaSyC2AE-hUVzVqtd-LP3QcVED_XQP9c7OCHc';

/// Google Places API service
/// Note: On Flutter Web, direct API calls will fail due to CORS.
/// This works on mobile (Android/iOS). For web, use a proxy or backend service.
class _PlacesApiService {
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  /// Check if running on web platform
  static bool get _isWeb => kIsWeb;

  /// Search for place predictions (autocomplete)
  static Future<List<_PlacePrediction>> getAutocomplete(String query) async {
    // On web, CORS will block direct calls - return empty and let user enter manually
    if (_isWeb) {
      if (kDebugMode) {
        print('[PlacesAPI] Running on web - Places API requires CORS proxy. Enter address manually.');
      }
      return [];
    }

    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json',
        queryParameters: {
          'input': query,
          'key': _placesApiKey,
          'types': 'address',
          'language': 'en',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        // Check for API errors
        final status = data['status'] as String?;
        if (status != 'OK' && status != 'ZERO_RESULTS') {
          if (kDebugMode) {
            print('[PlacesAPI] API error status: $status');
            print('[PlacesAPI] Error message: ${data['error_message']}');
          }
          return [];
        }

        final predictions = data['predictions'] as List<dynamic>? ?? [];

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
        print('[PlacesAPI] Autocomplete error: $e');
      }
      return [];
    }
  }

  /// Get place details including lat/lng
  static Future<_PlaceDetails?> getPlaceDetails(String placeId) async {
    if (_isWeb) {
      if (kDebugMode) {
        print('[PlacesAPI] Running on web - Place details requires CORS proxy.');
      }
      return null;
    }

    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/details/json',
        queryParameters: {
          'place_id': placeId,
          'key': _placesApiKey,
          'fields': 'geometry,address_components,formatted_address',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        // Check for API errors
        final status = data['status'] as String?;
        if (status != 'OK') {
          if (kDebugMode) {
            print('[PlacesAPI] API error status: $status');
            print('[PlacesAPI] Error message: ${data['error_message']}');
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
        print('[PlacesAPI] Place details error: $e');
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
    if (widget.initialAddress != null) {
      _populateFields(widget.initialAddress!);
      _showManualEntry = true;
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

    // Use Google Places API for autocomplete
    final predictions = await _PlacesApiService.getAutocomplete(query);

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
    final address = AddressModel(
      street: _streetController.text,
      building: _buildingController.text,
      apartment: _apartmentController.text.isNotEmpty ? _apartmentController.text : null,
      floor: _floorController.text.isNotEmpty ? _floorController.text : null,
      city: _cityController.text.isNotEmpty ? _cityController.text : null,
      postalCode: _postalCodeController.text.isNotEmpty ? _postalCodeController.text : null,
      country: _country ?? '',
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
              borderSide: const BorderSide(color: AppColors.primary),
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
                    color: AppColors.primary,
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
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
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
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.primary, size: 20.w),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Location: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.primary,
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
              borderSide: const BorderSide(color: AppColors.primary),
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
