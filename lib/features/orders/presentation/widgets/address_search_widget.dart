import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';
import '../../data/models/order_model.dart';

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

    // TODO: Implement actual Google Places API call
    // For now, using mock data
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock predictions for demonstration
    final mockPredictions = [
      _PlacePrediction(
        placeId: 'place_1',
        description: '$query, Vienna, Austria',
        mainText: query,
        secondaryText: 'Vienna, Austria',
      ),
      _PlacePrediction(
        placeId: 'place_2',
        description: '$query, Graz, Austria',
        mainText: query,
        secondaryText: 'Graz, Austria',
      ),
      _PlacePrediction(
        placeId: 'place_3',
        description: '$query, Salzburg, Austria',
        mainText: query,
        secondaryText: 'Salzburg, Austria',
      ),
    ];

    if (mounted) {
      setState(() {
        _predictions = mockPredictions;
        _isSearching = false;
      });
    }
  }

  Future<void> _selectPlace(_PlacePrediction prediction) async {
    // TODO: Fetch place details from Google Places API
    // For now, using mock data
    setState(() {
      _showManualEntry = true;
      _predictions = [];
      _searchController.text = prediction.mainText;
      _streetController.text = prediction.mainText;
      _cityController.text = prediction.secondaryText.split(',').first.trim();
    });

    _notifyAddressChanged();
  }

  void _notifyAddressChanged() {
    final address = AddressModel(
      street: _streetController.text,
      building: _buildingController.text,
      apartment: _apartmentController.text.isNotEmpty ? _apartmentController.text : null,
      floor: _floorController.text.isNotEmpty ? _floorController.text : null,
      city: _cityController.text.isNotEmpty ? _cityController.text : null,
      postalCode: _postalCodeController.text.isNotEmpty ? _postalCodeController.text : null,
      country: 'Austria',
    );
    widget.onAddressSelected(address);
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
