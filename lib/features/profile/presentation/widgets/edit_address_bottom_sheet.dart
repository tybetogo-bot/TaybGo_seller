import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';
import '../../../restaurant/data/models/restaurant_model.dart';

/// Bottom sheet for editing address with better UX
class EditAddressBottomSheet extends StatefulWidget {
  const EditAddressBottomSheet({
    super.key,
    required this.address,
    required this.onSave,
  });

  final RestaurantAddressModel address;
  final Future<void> Function(Map<String, String>) onSave;

  @override
  State<EditAddressBottomSheet> createState() => _EditAddressBottomSheetState();
}

class _EditAddressBottomSheetState extends State<EditAddressBottomSheet> {
  late final TextEditingController _fullAddressController;
  late final TextEditingController _streetNameController;
  late final TextEditingController _houseNumberController;
  late final TextEditingController _cityController;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _countryController;
  late final TextEditingController _latController;
  late final TextEditingController _lngController;

  bool _isSaving = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fullAddressController = TextEditingController(text: widget.address.fullAddress ?? '');
    _streetNameController = TextEditingController(text: widget.address.streetName ?? '');
    _houseNumberController = TextEditingController(text: widget.address.houseNumber ?? '');
    _cityController = TextEditingController(text: widget.address.city ?? '');
    _postalCodeController = TextEditingController(text: widget.address.postalCode ?? '');
    _countryController = TextEditingController(text: widget.address.country ?? '');
    _latController = TextEditingController(text: widget.address.lat?.toString() ?? '');
    _lngController = TextEditingController(text: widget.address.lng?.toString() ?? '');
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

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
                        'Edit Address',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Update your restaurant location',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
                ),
              ],
            ),
          ),

          Divider(height: 1, color: isDark ? DarkColors.border : LightColors.border),

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
                    title: 'Full Address',
                    color: primaryColor,
                    child: _buildTextField(
                      controller: _fullAddressController,
                      label: 'Complete address',
                      hint: 'Enter the full address',
                      maxLines: 3,
                      isDark: isDark,
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Street Details
                  _buildSection(
                    icon: Icons.signpost,
                    title: 'Street Details',
                    color: Colors.blue,
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _streetNameController,
                          label: 'Street Name',
                          hint: 'e.g., Main Street',
                          isDark: isDark,
                        ),
                        SizedBox(height: 12.h),
                        _buildTextField(
                          controller: _houseNumberController,
                          label: 'Building/House Number',
                          hint: 'e.g., 123A',
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // City & Postal Code
                  _buildSection(
                    icon: Icons.location_city,
                    title: 'City & Postal Code',
                    color: Colors.orange,
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _postalCodeController,
                            label: 'Postal Code',
                            hint: 'e.g., 12345',
                            isDark: isDark,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            controller: _cityController,
                            label: 'City',
                            hint: 'e.g., Riyadh',
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
                    title: 'Country',
                    color: Colors.green,
                    child: _buildTextField(
                      controller: _countryController,
                      label: 'Country',
                      hint: 'e.g., Saudi Arabia',
                      isDark: isDark,
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Coordinates
                  _buildSection(
                    icon: Icons.my_location,
                    title: 'Coordinates',
                    color: Colors.purple,
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _latController,
                            label: 'Latitude',
                            hint: 'e.g., 24.7136',
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            isDark: isDark,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final lat = double.tryParse(value);
                                if (lat == null || lat < -90 || lat > 90) {
                                  return 'Invalid latitude';
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
                            label: 'Longitude',
                            hint: 'e.g., 46.6753',
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            isDark: isDark,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final lng = double.tryParse(value);
                                if (lng == null || lng < -180 || lng > 180) {
                                  return 'Invalid longitude';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
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
                    onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
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
                        color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
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
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
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
            Icon(
              icon,
              size: 18.sp,
              color: color,
            ),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
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
          borderSide: const BorderSide(
            color: AppColors.error,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 14.h,
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
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
        builder: (context, scrollController) => EditAddressBottomSheet(
          address: address,
          onSave: onSave,
        ),
      ),
    ),
  );
}
