import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';
import '../../../orders/data/services/places_search_service.dart';
import '../../../restaurant/data/models/restaurant_model.dart';

/// Bottom sheet for editing address with better UX
class EditAddressBottomSheet extends ConsumerStatefulWidget {
  const EditAddressBottomSheet({
    super.key,
    required this.address,
    required this.onSave,
  });

  final RestaurantAddressModel address;
  final Future<void> Function(Map<String, String>) onSave;

  @override
  ConsumerState<EditAddressBottomSheet> createState() =>
      _EditAddressBottomSheetState();
}

class _EditAddressBottomSheetState
    extends ConsumerState<EditAddressBottomSheet> {
  late final TextEditingController _fullAddressController;
  late final TextEditingController _streetNameController;
  late final TextEditingController _houseNumberController;
  late final TextEditingController _cityController;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _countryController;
  late final TextEditingController _latController;
  late final TextEditingController _lngController;

  bool _isSaving = false;
  bool _isRefreshingCoordinates = false;
  late final String _initialAddressQuery;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fullAddressController = TextEditingController(
      text: widget.address.fullAddress ?? '',
    );
    _streetNameController = TextEditingController(
      text: widget.address.streetName ?? '',
    );
    _houseNumberController = TextEditingController(
      text: widget.address.houseNumber ?? '',
    );
    _cityController = TextEditingController(text: widget.address.city ?? '');
    _postalCodeController = TextEditingController(
      text: widget.address.postalCode ?? '',
    );
    _countryController = TextEditingController(
      text: widget.address.country ?? '',
    );
    _latController = TextEditingController(
      text: widget.address.lat?.toString() ?? '',
    );
    _lngController = TextEditingController(
      text: widget.address.lng?.toString() ?? '',
    );
    _initialAddressQuery = _buildAddressQuery();
  }

  @override
  void dispose() {
    _fullAddressController.dispose();
    _streetNameController.dispose();
    _houseNumberController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(translationsLoadedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final addressQuery = _buildAddressQuery();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? DarkColors.background : LightColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: isDark ? DarkColors.border : LightColors.border,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.edit_location_alt,
                    color: primaryColor,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${'common.edit'.tr} ${'orders.address'.tr}',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? DarkColors.textPrimary
                              : LightColors.textPrimary,
                        ),
                      ),
                      Text(
                        'address.enterManually'.tr,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: isDark
                              ? DarkColors.textSecondary
                              : LightColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  color: isDark
                      ? DarkColors.textSecondary
                      : LightColors.textSecondary,
                ),
              ],
            ),
          ),

          Divider(
            height: 1,
            color: isDark ? DarkColors.border : LightColors.border,
          ),

          // Form content
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(20.w),
                children: [
                  // Full Address
                  _buildSection(
                    icon: Icons.place,
                    title: 'orders.address'.tr,
                    color: primaryColor,
                    child: _buildTextField(
                      controller: _fullAddressController,
                      label: 'orders.address'.tr,
                      hint: 'address.searchForAddress'.tr,
                      maxLines: 3,
                      isDark: isDark,
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Street Details
                  _buildSection(
                    icon: Icons.signpost,
                    title: 'address.street'.tr,
                    color: Colors.blue,
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _streetNameController,
                          label: 'address.streetName'.tr,
                          hint: 'address.streetName'.tr,
                          isDark: isDark,
                        ),
                        SizedBox(height: 12.h),
                        _buildTextField(
                          controller: _houseNumberController,
                          label: 'address.buildingHouseNumber'.tr,
                          hint: 'address.buildingHouseNumber'.tr,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // City & Postal Code
                  _buildSection(
                    icon: Icons.location_city,
                    title: '${'address.city'.tr} & ${'address.postalCode'.tr}',
                    color: Colors.orange,
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _postalCodeController,
                            label: 'address.postalCode'.tr,
                            hint: 'address.postalCode'.tr,
                            isDark: isDark,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            controller: _cityController,
                            label: 'address.city'.tr,
                            hint: 'address.city'.tr,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Country
                  _buildSection(
                    icon: Icons.public,
                    title: 'address.country'.tr,
                    color: Colors.green,
                    child: _buildTextField(
                      controller: _countryController,
                      label: 'address.country'.tr,
                      hint: 'address.country'.tr,
                      isDark: isDark,
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Coordinates
                  _buildSection(
                    icon: Icons.my_location,
                    title: 'address.coordinates'.tr,
                    color: Colors.purple,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _latController,
                                label: 'address.latitude'.tr,
                                hint: 'address.latitude'.tr,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                isDark: isDark,
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    final lat = double.tryParse(value);
                                    if (lat == null || lat < -90 || lat > 90) {
                                      return 'address.invalidLatitude'.tr;
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: _buildTextField(
                                controller: _lngController,
                                label: 'address.longitude'.tr,
                                hint: 'address.longitude'.tr,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                isDark: isDark,
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    final lng = double.tryParse(value);
                                    if (lng == null ||
                                        lng < -180 ||
                                        lng > 180) {
                                      return 'address.invalidLongitude'.tr;
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        if (addressQuery.isNotEmpty) ...[
                          SizedBox(height: 12.h),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: (_isSaving || _isRefreshingCoordinates)
                                  ? null
                                  : _refreshCoordinates,
                              icon: _isRefreshingCoordinates
                                  ? SizedBox(
                                      width: 18.w,
                                      height: 18.w,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(Icons.my_location, size: 18.w),
                              label: Text('address.getLocationCoordinates'.tr),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: primaryColor,
                                side: BorderSide(color: primaryColor),
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),

          // Action buttons
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: isDark ? DarkColors.surface : LightColors.surface,
              border: Border(
                top: BorderSide(
                  color: isDark ? DarkColors.border : LightColors.border,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving
                        ? null
                        : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      side: BorderSide(
                        color: isDark ? DarkColors.border : LightColors.border,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'common.cancel'.tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? DarkColors.textSecondary
                            : LightColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'common.save'.tr,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Color color,
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18.sp, color: color),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? DarkColors.textPrimary
                    : LightColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        child,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: isDark ? DarkColors.surface : LightColors.surface,
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
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
    );
  }

  String _buildAddressQuery() {
    final parts = <String>[
      _streetNameController.text.trim(),
      _houseNumberController.text.trim(),
      _cityController.text.trim(),
      _postalCodeController.text.trim(),
      _countryController.text.trim(),
    ];

    final fullAddress = _fullAddressController.text.trim();
    if (parts.any((part) => part.isNotEmpty)) {
      if (fullAddress.isNotEmpty) {
        parts.insert(0, fullAddress);
      }
      return parts.where((part) => part.isNotEmpty).join(', ');
    }

    return fullAddress;
  }

  Future<({double lat, double lng})?> _fetchCoordinates(String query) async {
    final result = await PlacesSearchService.searchAndGetAddress(query);
    if (result == null || result.latitude == null || result.longitude == null) {
      return null;
    }

    return (lat: result.latitude!, lng: result.longitude!);
  }

  Future<bool> _refreshCoordinates({bool showError = true}) async {
    final query = _buildAddressQuery();
    if (query.isEmpty) {
      return false;
    }

    setState(() => _isRefreshingCoordinates = true);

    try {
      final coordinates = await _fetchCoordinates(query);
      if (!mounted || coordinates == null) {
        if (showError && mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('common.error'.tr)));
        }
        return false;
      }

      _latController.text = coordinates.lat.toStringAsFixed(6);
      _lngController.text = coordinates.lng.toStringAsFixed(6);
      return true;
    } finally {
      if (mounted) {
        setState(() => _isRefreshingCoordinates = false);
      }
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final currentQuery = _buildAddressQuery();
      if (currentQuery.isNotEmpty &&
          (currentQuery != _initialAddressQuery ||
              _latController.text.trim().isEmpty ||
              _lngController.text.trim().isEmpty)) {
        final coordinates = await _fetchCoordinates(currentQuery);
        if (coordinates != null) {
          _latController.text = coordinates.lat.toStringAsFixed(6);
          _lngController.text = coordinates.lng.toStringAsFixed(6);
        }
      }

      final data = <String, String>{};

      if (_fullAddressController.text.trim().isNotEmpty) {
        data['full_address'] = _fullAddressController.text.trim();
      }
      if (_streetNameController.text.trim().isNotEmpty) {
        data['street_name'] = _streetNameController.text.trim();
      }
      if (_houseNumberController.text.trim().isNotEmpty) {
        data['house_number'] = _houseNumberController.text.trim();
      }
      if (_cityController.text.trim().isNotEmpty) {
        data['city'] = _cityController.text.trim();
      }
      if (_postalCodeController.text.trim().isNotEmpty) {
        data['postal_code'] = _postalCodeController.text.trim();
      }
      if (_countryController.text.trim().isNotEmpty) {
        data['country'] = _countryController.text.trim();
      }
      if (_latController.text.trim().isNotEmpty) {
        data['lat'] = _latController.text.trim();
      }
      if (_lngController.text.trim().isNotEmpty) {
        data['lng'] = _lngController.text.trim();
      }

      await widget.onSave(data);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

/// Helper function to show the edit address bottom sheet
Future<void> showEditAddressBottomSheet({
  required BuildContext context,
  required RestaurantAddressModel address,
  required Future<void> Function(Map<String, String>) onSave,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) =>
            EditAddressBottomSheet(address: address, onSave: onSave),
      ),
    ),
  );
}
