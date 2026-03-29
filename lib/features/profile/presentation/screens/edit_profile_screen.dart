import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';
import '../../../restaurant/application/restaurant_state.dart';
import '../../../restaurant/data/models/restaurant_model.dart';
import '../../application/user_profile_notifier.dart';

/// Edit profile screen - update user info (name, phone) and restaurant address
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isInitialized = false;

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
    final primaryColor = Theme.of(context).colorScheme.primary;
    final userProfileState = ref.watch(userProfileProvider);
    final selectedRestaurant = ref.watch(selectedRestaurantProvider);

    // Initialize controllers with user data
    if (!_isInitialized && userProfileState.profile != null) {
      final profile = userProfileState.profile!;
      _nameController.text = profile.name ?? '';
      _phoneController.text = profile.phone;
      _isInitialized = true;
    }

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : LightColors.background,
      appBar: AppBar(
        title: Text('profile.title'.tr),
        backgroundColor: isDark
            ? DarkColors.background
            : LightColors.background,
        elevation: 0,
      ),
      body: userProfileState.isLoading && !_isInitialized
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                // Personal info section
                _SectionHeader(
                  icon: Icons.person_outline,
                  title: 'onboarding.profileStep'.tr,
                  isDark: isDark,
                ),
                SizedBox(height: 12.h),
                _buildTextField('common.name'.tr, _nameController, isDark),
                SizedBox(height: 12.h),
                _buildTextField(
                  'auth.phoneNumber'.tr,
                  _phoneController,
                  isDark,
                  keyboardType: TextInputType.phone,
                ),

                SizedBox(height: 28.h),

                // Address section
                if (selectedRestaurant != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 18.sp,
                        color: isDark
                            ? DarkColors.textSecondary
                            : LightColors.textSecondary,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'orders.address'.tr,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? DarkColors.textSecondary
                                : LightColors.textSecondary,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.lock_outline,
                        size: 16.sp,
                        color: isDark
                            ? DarkColors.textTertiary
                            : LightColors.textTertiary,
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // Address card
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: isDark ? DarkColors.surface : LightColors.surface,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (selectedRestaurant.addressData != null ||
                            selectedRestaurant.fullAddress.isNotEmpty) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Icon(
                                  Icons.location_on,
                                  color: primaryColor,
                                  size: 20.sp,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (selectedRestaurant
                                                .addressData
                                                ?.streetName !=
                                            null ||
                                        selectedRestaurant
                                                .addressData
                                                ?.houseNumber !=
                                            null)
                                      Text(
                                        [
                                              selectedRestaurant
                                                  .addressData
                                                  ?.streetName,
                                              selectedRestaurant
                                                  .addressData
                                                  ?.houseNumber,
                                            ]
                                            .where(
                                              (s) => s != null && s.isNotEmpty,
                                            )
                                            .join(' '),
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? DarkColors.textPrimary
                                              : LightColors.textPrimary,
                                        ),
                                      ),
                                    if (selectedRestaurant.addressData?.city !=
                                            null ||
                                        selectedRestaurant
                                                .addressData
                                                ?.postalCode !=
                                            null)
                                      Text(
                                        [
                                              selectedRestaurant
                                                  .addressData
                                                  ?.postalCode,
                                              selectedRestaurant
                                                  .addressData
                                                  ?.city,
                                            ]
                                            .where(
                                              (s) => s != null && s.isNotEmpty,
                                            )
                                            .join(' '),
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: isDark
                                              ? DarkColors.textSecondary
                                              : LightColors.textSecondary,
                                        ),
                                      ),
                                    if (selectedRestaurant
                                            .addressData
                                            ?.country !=
                                        null)
                                      Text(
                                        selectedRestaurant
                                            .addressData!
                                            .country!,
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: isDark
                                              ? DarkColors.textSecondary
                                              : LightColors.textSecondary,
                                        ),
                                      ),
                                    // Fallback to simple address
                                    if (selectedRestaurant.addressData ==
                                            null &&
                                        selectedRestaurant
                                            .fullAddress
                                            .isNotEmpty)
                                      Text(
                                        selectedRestaurant.fullAddress,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: isDark
                                              ? DarkColors.textPrimary
                                              : LightColors.textPrimary,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.lock_outline,
                                size: 18.sp,
                                color: isDark
                                    ? DarkColors.textTertiary
                                    : LightColors.textTertiary,
                              ),
                            ],
                          ),
                          // Show coordinates if available
                          if (selectedRestaurant.lat != null &&
                              selectedRestaurant.lng != null) ...[
                            SizedBox(height: 8.h),
                            Text(
                              '${selectedRestaurant.lat!.toStringAsFixed(6)}, ${selectedRestaurant.lng!.toStringAsFixed(6)}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: isDark
                                    ? DarkColors.textSecondary.withValues(
                                        alpha: 0.7,
                                      )
                                    : LightColors.textSecondary.withValues(
                                        alpha: 0.7,
                                      ),
                              ),
                            ),
                          ],
                        ] else
                          // No address
                          Column(
                            children: [
                              Icon(
                                Icons.location_off_outlined,
                                size: 40.sp,
                                color: isDark
                                    ? DarkColors.textTertiary
                                    : LightColors.textTertiary,
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'No address available',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? DarkColors.textSecondary
                                      : LightColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Restaurant not loaded yet - show loading for address section
                  _SectionHeader(
                    icon: Icons.location_on_outlined,
                    title: 'orders.address'.tr,
                    isDark: isDark,
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: isDark ? DarkColors.surface : LightColors.surface,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    bool isDark, {
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: false,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: isDark ? DarkColors.surface : LightColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.isDark,
  });

  final IconData icon;
  final String title;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18.sp,
          color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isDark
                ? DarkColors.textSecondary
                : LightColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
