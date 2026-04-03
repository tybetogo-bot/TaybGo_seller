import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/network/user_api.dart';
import '../../../../core/theme/theme.dart';
import '../../../restaurant/application/restaurant_state.dart';
import '../../../restaurant/data/models/restaurant_model.dart';
import '../../application/user_profile_notifier.dart';

/// Seller profile screen - view-only seller data, address, and docs
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthdateController = TextEditingController();
  final _ageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _birthdateController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(translationsLoadedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final userProfileState = ref.watch(userProfileProvider);
    final selectedRestaurant = ref.watch(selectedRestaurantProvider);
    final sellerProfileAsync = ref.watch(sellerProfileProvider);
    final sellerProfile = sellerProfileAsync.maybeWhen(
      data: (profile) => profile,
      orElse: () => null,
    );
    final userProfile = userProfileState.profile;
    final effectiveBirthdate =
        sellerProfile?.birthdate ?? userProfile?.birthdate;
    final effectiveAge = sellerProfile?.age ?? userProfile?.age;
    final sellerPhone = sellerProfile?.phone ?? '';

    _syncControllerText(
      _nameController,
      sellerProfile?.name ?? userProfile?.name ?? '',
    );
    _syncControllerText(
      _phoneController,
      sellerPhone.isNotEmpty ? sellerPhone : (userProfile?.phone ?? ''),
    );
    _syncControllerText(_emailController, userProfile?.email ?? '');
    _syncControllerText(
      _birthdateController,
      effectiveBirthdate != null
          ? DateFormat('MMM d, yyyy').format(effectiveBirthdate)
          : '',
    );
    _syncControllerText(_ageController, effectiveAge?.toString() ?? '');

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : LightColors.background,
      appBar: AppBar(
        title: const Text('Seller Profile'),
        backgroundColor: isDark
            ? DarkColors.background
            : LightColors.background,
        elevation: 0,
      ),
      body: userProfileState.isLoading && userProfile == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.visibility_outlined,
                        color: primaryColor,
                        size: 18.sp,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          'View-only mode. Profile edits are disabled from this page.',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isDark
                                ? DarkColors.textSecondary
                                : LightColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                // Personal info section
                _SectionHeader(
                  icon: Icons.person_outline,
                  title: 'Seller Details',
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
                SizedBox(height: 12.h),
                _buildTextField('email'.tr, _emailController, isDark),
                SizedBox(height: 12.h),
                _buildTextField('Birthdate', _birthdateController, isDark),
                SizedBox(height: 12.h),
                _buildTextField('Age', _ageController, isDark),

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

                SizedBox(height: 28.h),
                _SectionHeader(
                  icon: Icons.description_outlined,
                  title: 'Registration Document',
                  isDark: isDark,
                ),
                SizedBox(height: 12.h),
                _RegistrationDocumentStatusCard(
                  isDark: isDark,
                  sellerProfileAsync: sellerProfileAsync,
                  onRetry: () => ref.invalidate(sellerProfileProvider),
                  onOpenDocument: _openDocument,
                ),
              ],
            ),
    );
  }

  void _syncControllerText(TextEditingController controller, String value) {
    if (controller.text != value) {
      controller.text = value;
    }
  }

  Future<void> _openDocument(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid document URL.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open document.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
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

class _RegistrationDocumentStatusCard extends StatelessWidget {
  const _RegistrationDocumentStatusCard({
    required this.isDark,
    required this.sellerProfileAsync,
    required this.onRetry,
    required this.onOpenDocument,
  });

  final bool isDark;
  final AsyncValue<BasicProfile?> sellerProfileAsync;
  final VoidCallback onRetry;
  final Future<void> Function(BuildContext context, String url) onOpenDocument;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : LightColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? DarkColors.border : LightColors.border,
        ),
      ),
      child: sellerProfileAsync.when(
        loading: () => Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'Loading registration document...',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: isDark
                      ? DarkColors.textSecondary
                      : LightColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        error: (error, stackTrace) => Row(
          children: [
            Icon(Icons.error_outline, size: 18.w, color: AppColors.error),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'Could not load registration document.',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: isDark
                      ? DarkColors.textSecondary
                      : LightColors.textSecondary,
                ),
              ),
            ),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
        data: (profile) {
          final documentUrl = profile?.restaurantRegistrationLicenseDocument;
          final hasDocument = documentUrl != null && documentUrl.isNotEmpty;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: hasDocument
                      ? AppColors.success.withValues(alpha: 0.12)
                      : Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  hasDocument
                      ? Icons.verified_outlined
                      : Icons.description_outlined,
                  size: 20.w,
                  color: hasDocument
                      ? AppColors.success
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Registration Document',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? DarkColors.textPrimary
                            : LightColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      hasDocument
                          ? 'Added and locked. This page is view-only.'
                          : 'No document found on this seller profile.',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark
                            ? DarkColors.textSecondary
                            : LightColors.textSecondary,
                      ),
                    ),
                    if (hasDocument) ...[
                      SizedBox(height: 10.h),
                      TextButton.icon(
                        onPressed: () => onOpenDocument(context, documentUrl),
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Open Document'),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.lock_outline,
                size: 18.w,
                color: isDark
                    ? DarkColors.textTertiary
                    : LightColors.textTertiary,
              ),
            ],
          );
        },
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
