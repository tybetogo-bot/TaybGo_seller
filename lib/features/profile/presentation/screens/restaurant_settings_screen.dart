import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';
import '../../../menu/presentation/widgets/image_picker_widget.dart';
import '../../../restaurant/application/restaurant_state.dart';
import '../../../restaurant/data/models/restaurant_model.dart';

/// Restaurant settings screen
class RestaurantSettingsScreen extends ConsumerStatefulWidget {
  const RestaurantSettingsScreen({super.key});

  @override
  ConsumerState<RestaurantSettingsScreen> createState() => _RestaurantSettingsScreenState();
}

class _RestaurantSettingsScreenState extends ConsumerState<RestaurantSettingsScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isInitialized = false;
  bool _isSaving = false;
  String? _logoUrl;
  bool _isUploadingLogo = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(translationsLoadedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedRestaurant = ref.watch(selectedRestaurantProvider);

    // Initialize controllers with restaurant data
    if (!_isInitialized && selectedRestaurant != null) {
      _nameController.text = selectedRestaurant.name;
      _phoneController.text = selectedRestaurant.phone ?? '';
      _logoUrl = selectedRestaurant.logoUrl;
      _isInitialized = true;
    }

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : LightColors.background,
      appBar: AppBar(
        title: Text('settings.restaurantSettings'.tr),
        backgroundColor: isDark ? DarkColors.background : LightColors.background,
        elevation: 0,
        actions: [
          if (_isSaving || _isUploadingLogo)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveSettings,
              child: Text('common.save'.tr, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            ),
        ],
      ),
      body: selectedRestaurant == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // Restaurant info
          Text(
            'settings.restaurantInfo'.tr,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
            ),
          ),
          SizedBox(height: 12.h),
          _buildTextField('settings.restaurantName'.tr, _nameController, isDark),
          SizedBox(height: 12.h),
          _buildTextField('auth.phoneNumber'.tr, _phoneController, isDark, keyboardType: TextInputType.phone),
          SizedBox(height: 24.h),

          // Restaurant logo
          Text(
            'settings.restaurantLogo'.tr,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
            ),
          ),
          SizedBox(height: 12.h),
          ImagePickerWidget(
            initialImageUrl: _logoUrl,
            onImageUploaded: (url) {
              setState(() => _logoUrl = url);
            },
            onImageRemoved: () {
              setState(() => _logoUrl = null);
            },
            onUploadStateChanged: (isUploading) {
              setState(() => _isUploadingLogo = isUploading);
            },
          ),
          SizedBox(height: 24.h),

          // Address section (read-only display)
          Text(
            'orders.address'.tr,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
            ),
          ),
          SizedBox(height: 12.h),
          // Display address in a read-only container
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isDark ? DarkColors.surface : LightColors.surface,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (selectedRestaurant.addressData != null || selectedRestaurant.fullAddress.isNotEmpty) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (selectedRestaurant.addressData?.streetName != null ||
                                selectedRestaurant.addressData?.houseNumber != null)
                              Text(
                                [
                                  selectedRestaurant.addressData?.streetName,
                                  selectedRestaurant.addressData?.houseNumber,
                                ].where((s) => s != null && s.isNotEmpty).join(' '),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
                                ),
                              ),
                            if (selectedRestaurant.addressData?.city != null ||
                                selectedRestaurant.addressData?.postalCode != null)
                              Text(
                                [
                                  selectedRestaurant.addressData?.postalCode,
                                  selectedRestaurant.addressData?.city,
                                ].where((s) => s != null && s.isNotEmpty).join(' '),
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
                                ),
                              ),
                            if (selectedRestaurant.addressData?.country != null)
                              Text(
                                selectedRestaurant.addressData!.country!,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
                                ),
                              ),
                            // Fallback to simple address if no addressData
                            if (selectedRestaurant.addressData == null && selectedRestaurant.fullAddress.isNotEmpty)
                              Text(
                                selectedRestaurant.fullAddress,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Show coordinates if available
                  if (selectedRestaurant.lat != null && selectedRestaurant.lng != null) ...[
                    SizedBox(height: 8.h),
                    Text(
                      '${selectedRestaurant.lat!.toStringAsFixed(6)}, ${selectedRestaurant.lng!.toStringAsFixed(6)}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark ? DarkColors.textSecondary.withValues(alpha: 0.7) : LightColors.textSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ] else
                  Text(
                    'No address configured',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, bool isDark, {TextInputType? keyboardType, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: isDark ? DarkColors.surface : LightColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Future<void> _saveSettings() async {
    final selectedRestaurant = ref.read(selectedRestaurantProvider);
    if (selectedRestaurant == null) return;

    setState(() => _isSaving = true);

    // Prepare update data
    // Note: Address is a foreign key reference - include the existing ID if present
    final addressId = selectedRestaurant.addressData?.id;
    final data = {
      'name': _nameController.text.trim(),
      if (_phoneController.text.trim().isNotEmpty)
        'phone': _phoneController.text.trim(),
      if (_logoUrl != null && _logoUrl!.isNotEmpty)
        'logo': _logoUrl,
      'is_open': true,
      // Keep existing address ID if we have one
      if (addressId != null) 'address': addressId,
    };

    // Call the API to update restaurant
    await ref.read(restaurantProvider.notifier).patchRestaurant(
          selectedRestaurant.id,
          data,
        );

    setState(() => _isSaving = false);

    // Check if update was successful
    final restaurantState = ref.read(restaurantProvider);
    if (restaurantState is RestaurantError) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(restaurantState.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('settings.settingsSaved'.tr)),
        );
      }
    }
  }
}
