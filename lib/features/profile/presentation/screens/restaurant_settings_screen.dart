import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/theme/theme.dart';
import '../../../menu/presentation/widgets/image_picker_widget.dart';
import '../../../restaurant/application/restaurant_state.dart';
import '../../../restaurant/data/models/restaurant_model.dart';
import '../widgets/address_display_widget.dart';
import '../widgets/edit_address_bottom_sheet.dart';

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

  // Track initial values to detect changes
  String _initialName = '';
  String _initialPhone = '';
  String? _initialLogoUrl;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Check if there are unsaved changes
  bool _hasUnsavedChanges() {
    final currentName = _nameController.text.trim();
    final currentPhone = _phoneController.text.trim();
    final currentLogo = _logoUrl;

    final hasChanges = currentName != _initialName ||
        currentPhone != _initialPhone ||
        currentLogo != _initialLogoUrl;

    print('========== UNSAVED CHANGES CHECK ==========');
    print('Name changed: ${currentName != _initialName} (current: "$currentName", initial: "$_initialName")');
    print('Phone changed: ${currentPhone != _initialPhone} (current: "$currentPhone", initial: "$_initialPhone")');
    print('Logo changed: ${currentLogo != _initialLogoUrl} (current: "$currentLogo", initial: "$_initialLogoUrl")');
    print('Has unsaved changes: $hasChanges');
    print('==========================================');

    return hasChanges;
  }

  /// Show confirmation dialog when user tries to leave with unsaved changes
  Future<bool> _showUnsavedChangesDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('unsavedChanges.title'.tr),
        content: Text('unsavedChanges.message'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('unsavedChanges.keepEditing'.tr),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'unsavedChanges.discard'.tr,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
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

      // Store initial values
      _initialName = selectedRestaurant.name;
      _initialPhone = selectedRestaurant.phone ?? '';
      _initialLogoUrl = selectedRestaurant.logoUrl;

      _isInitialized = true;

      // Debug: Print restaurant data
      print('============ RESTAURANT SETTINGS DEBUG ============');
      print('Restaurant ID: ${selectedRestaurant.id}');
      print('Restaurant Name: ${selectedRestaurant.name}');
      print('Address (simple string): ${selectedRestaurant.address}');
      print('City: ${selectedRestaurant.city}');
      print('Country: ${selectedRestaurant.country}');
      print('Lat: ${selectedRestaurant.lat}');
      print('Lng: ${selectedRestaurant.lng}');
      print('Address Data (object): ${selectedRestaurant.addressData}');
      if (selectedRestaurant.addressData != null) {
        print('  - ID: ${selectedRestaurant.addressData!.id}');
        print('  - Label: ${selectedRestaurant.addressData!.label}');
        print('  - Full Address: ${selectedRestaurant.addressData!.fullAddress}');
        print('  - Street Name: ${selectedRestaurant.addressData!.streetName}');
        print('  - House Number: ${selectedRestaurant.addressData!.houseNumber}');
        print('  - City: ${selectedRestaurant.addressData!.city}');
        print('  - Postal Code: ${selectedRestaurant.addressData!.postalCode}');
        print('  - Country: ${selectedRestaurant.addressData!.country}');
        print('  - Lat: ${selectedRestaurant.addressData!.lat}');
        print('  - Lng: ${selectedRestaurant.addressData!.lng}');
      }
      print('Full Address (from extension): ${selectedRestaurant.fullAddress}');
      print('===================================================');
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // Check if there are unsaved changes
        if (_hasUnsavedChanges()) {
          final shouldPop = await _showUnsavedChangesDialog();
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        } else {
          // No unsaved changes, allow navigation
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
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

          // Address section
          Text(
            'orders.address'.tr,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
            ),
          ),
          SizedBox(height: 12.h),
          AddressDisplayWidget(
            addressData: selectedRestaurant.addressData,
            lat: selectedRestaurant.lat,
            lng: selectedRestaurant.lng,
            fullAddress: selectedRestaurant.fullAddress,
            isDark: isDark,
            onEdit: selectedRestaurant.addressData?.id != null
                ? () => _showEditAddressBottomSheet(selectedRestaurant.addressData!)
                : null,
          ),
        ],
      ),
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
      // Update was successful - reset initial values to current values
      _initialName = _nameController.text.trim();
      _initialPhone = _phoneController.text.trim();
      _initialLogoUrl = _logoUrl;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('settings.settingsSaved'.tr)),
        );
      }
    }
  }

  Future<void> _showEditAddressBottomSheet(RestaurantAddressModel address) async {
    await showEditAddressBottomSheet(
      context: context,
      address: address,
      onSave: (data) => _updateAddress(
        addressId: address.id!,
        data: data,
      ),
    );
  }

  Future<void> _updateAddress({
    required String addressId,
    required Map<String, String> data,
  }) async {
    try {
      final addressesApi = ref.read(addressesApiProvider);

      print('Updating address $addressId with data: $data');

      // Update address via API
      final updatedAddress = await addressesApi.patchAddress(
        int.parse(addressId),
        data,
      );

      print('Address updated successfully: ${updatedAddress.toJson()}');

      // Refresh restaurant data to get updated address
      final selectedRestaurant = ref.read(selectedRestaurantProvider);
      if (selectedRestaurant != null) {
        await ref.read(restaurantProvider.notifier).fetchRestaurantById(selectedRestaurant.id);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Address updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error updating address: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update address: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
