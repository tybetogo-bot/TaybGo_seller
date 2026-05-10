import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/i18n/i18n.dart';
import '../../../../core/network/user_api.dart';
import '../../../../core/theme/theme.dart';
import '../../../auth/application/auth_state.dart';
import '../../../orders/application/orders_notifier.dart';
import '../../../restaurant/application/restaurant_state.dart';
import '../../../restaurant/data/models/restaurant_model.dart';
import '../../../tour/presentation/widgets/tour_section_widget.dart';
import '../../../tour/utils/tour_keys.dart';
import '../../application/user_profile_notifier.dart';

/// Profile screen - minimal design
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _didSyncRestaurantsForSwitcher = false;

  @override
  Widget build(BuildContext context) {
    ref.watch(translationsLoadedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeProvider);
    final accentColor = ref.watch(accentColorProvider);
    final sellerProfileAsync = ref.watch(sellerProfileProvider);

    // Get user profile and restaurant data
    final userProfileState = ref.watch(userProfileProvider);
    final restaurantState = ref.watch(restaurantProvider);
    final selectedRestaurant = ref.watch(selectedRestaurantProvider);
    final ordersState = ref.watch(ordersProvider);
    final List<RestaurantModel> restaurants =
        restaurantState is RestaurantLoaded
        ? restaurantState.restaurants
        : const <RestaurantModel>[];
    final hasMultipleRestaurants = restaurants.length > 1;
    final currentRestaurantName =
        selectedRestaurant?.name ??
        (restaurants.isNotEmpty
            ? restaurants.first.name
            : 'profile.yourRestaurant'.tr);

    if (!_didSyncRestaurantsForSwitcher &&
        restaurantState is RestaurantLoaded) {
      _didSyncRestaurantsForSwitcher = true;
      if (restaurantState.selectedRestaurant != null &&
          restaurantState.restaurants.length <= 1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ref.read(restaurantProvider.notifier).fetchRestaurants();
          }
        });
      }
    }

    ref.listen<RestaurantState>(restaurantProvider, (previous, next) {
      if (_didSyncRestaurantsForSwitcher) return;
      if (next is! RestaurantLoaded) return;

      _didSyncRestaurantsForSwitcher = true;
      if (next.selectedRestaurant != null && next.restaurants.length <= 1) {
        ref.read(restaurantProvider.notifier).fetchRestaurants();
      }
    });

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : LightColors.background,
      appBar: AppBar(
        title: Text('settings.title'.tr),
        centerTitle: true,
        backgroundColor: isDark
            ? DarkColors.background
            : LightColors.background,
        elevation: 0,
      ),
      body: userProfileState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                // Restaurant/User info
                _ProfileCard(
                  name:
                      selectedRestaurant?.name ??
                      userProfileState.profile?.name ??
                      'profile.yourRestaurant'.tr,
                  email:
                      userProfileState.profile?.email ??
                      userProfileState.profile?.phone ??
                      '',
                  logoUrl: selectedRestaurant?.logoUrl,
                  isDark: isDark,
                ),
                SizedBox(height: 12.h),
                _RegistrationDocumentCard(
                  isDark: isDark,
                  sellerProfileAsync: sellerProfileAsync,
                  onViewProfile: () => context.push(Routes.editProfile),
                  onRetry: () => ref.invalidate(sellerProfileProvider),
                ),
                SizedBox(height: 20.h),

                // Quick stats row
                Row(
                  key: TourKeys.quickStatsKey,
                  children: [
                    _QuickStat(
                      label: 'profile.today'.tr,
                      value: selectedRestaurant?.todayStats != null
                          ? '\$${selectedRestaurant!.todayStats!.totalRevenue.toStringAsFixed(0)}'
                          : '\$0',
                      isDark: isDark,
                    ),
                    SizedBox(width: 10.w),
                    _QuickStat(
                      label: 'navigation.orders'.tr,
                      value:
                          selectedRestaurant?.todayStats?.totalOrders
                              .toString() ??
                          '0',
                      isDark: isDark,
                    ),
                    SizedBox(width: 10.w),
                    _QuickStat(
                      label: 'settings.statistics'.tr,
                      value: 'profile.viewStats'.tr,
                      isDark: isDark,
                      isAction: true,
                      onTap: () => context.push(Routes.statistics),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                if (hasMultipleRestaurants) ...[
                  _RestaurantSwitcherCard(
                    isDark: isDark,
                    currentRestaurantName: currentRestaurantName,
                    onTap: () => context.push(Routes.restaurantSelection),
                  ),
                  SizedBox(height: 12.h),
                ],

                // Settings list
                _SettingRow(
                  icon: Icons.badge_outlined,
                  label: 'profile.sellerProfile'.tr,
                  value: 'profile.viewOnly'.tr,
                  isDark: isDark,
                  onTap: () => context.push(Routes.editProfile),
                ),
                _SettingRow(
                  icon: Icons.storefront_outlined,
                  label: 'settings.restaurantSettings'.tr,
                  isDark: isDark,
                  onTap: () => context.push(Routes.restaurantSettings),
                ),
                _SettingRow(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'earnings.title'.tr,
                  isDark: isDark,
                  onTap: () => context.push(Routes.earnings),
                ),
                _SettingRow(
                  key: TourKeys.settingsOptionsKey,
                  icon: Icons.local_offer_outlined,
                  label: 'coupons.title'.tr,
                  isDark: isDark,
                  onTap: () => context.push(Routes.coupons),
                ),
                _SettingRow(
                  key: TourKeys.themeSettingKey,
                  icon: isDark
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                  label: 'settings.darkMode'.tr,
                  isDark: isDark,
                  trailing: Switch.adaptive(
                    value: themeMode == AppThemeMode.dark,
                    onChanged: (value) {
                      ref
                          .read(themeProvider.notifier)
                          .setTheme(
                            value ? AppThemeMode.dark : AppThemeMode.light,
                          );
                    },
                  ),
                ),
                _AccentColorRow(
                  key: TourKeys.accentColorSettingKey,
                  accentColor: accentColor,
                  isDark: isDark,
                  onTap: () =>
                      _showAccentColorPicker(context, ref, accentColor),
                ),
                _SettingRow(
                  key: TourKeys.languageSettingKey,
                  icon: Icons.language_outlined,
                  label: 'settings.language'.tr,
                  value: ref.watch(localeProvider).languageCode.toUpperCase(),
                  isDark: isDark,
                  onTap: () => context.push(Routes.language),
                ),
                _SettingRow(
                  icon: Icons.notifications_outlined,
                  label: 'settings.notifications'.tr,
                  isDark: isDark,
                  onTap: () => context.push(Routes.notifications),
                ),

                SizedBox(height: 16.h),
                Divider(color: isDark ? DarkColors.border : LightColors.border),
                SizedBox(height: 8.h),

                KeyedSubtree(
                  key: TourKeys.knowledgeBaseRowKey,
                  child: _SettingRow(
                    icon: Icons.menu_book_outlined,
                    label: 'knowledgeBase.title'.tr,
                    isDark: isDark,
                    onTap: () => context.push(Routes.knowledgeBase),
                  ),
                ),
                if (ordersState.completedOrders.length >= 3) ...[
                  SizedBox(height: 12.h),
                  const TourSectionWidget(),
                  SizedBox(height: 12.h),
                ],
                _SettingRow(
                  icon: Icons.support_agent_outlined,
                  label: 'support.title'.tr,
                  isDark: isDark,
                  onTap: () => context.push(Routes.support),
                ),
                _SettingRow(
                  icon: Icons.help_outline,
                  label: 'settings.help'.tr,
                  isDark: isDark,
                  onTap: () => context.push(Routes.help),
                ),
                _SettingRow(
                  icon: Icons.info_outline,
                  label: 'settings.about'.tr,
                  isDark: isDark,
                  onTap: () => context.push(Routes.about),
                ),

                SizedBox(height: 16.h),
                Divider(color: isDark ? DarkColors.border : LightColors.border),
                SizedBox(height: 8.h),

                _SettingRow(
                  icon: Icons.delete_forever_outlined,
                  label: 'deleteAccount.title'.tr,
                  isDark: isDark,
                  onTap: () => context.push(Routes.deleteAccount),
                ),

                SizedBox(height: 24.h),

                // Logout
                GestureDetector(
                  onTap: () => _showLogoutConfirmation(context, ref),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, size: 18.w, color: AppColors.error),
                        SizedBox(width: 8.w),
                        Text(
                          'auth.logout'.tr,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('auth.logout'.tr),
          content: Text('auth.logoutConfirm'.tr),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'common.cancel'.tr,
                style: TextStyle(
                  color: Theme.of(dialogContext).brightness == Brightness.dark
                      ? DarkColors.textSecondary
                      : LightColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                // Pop the dialog first using dialog context
                Navigator.of(dialogContext).pop();

                // Perform logout
                await ref.read(authProvider.notifier).logout();

                // Navigate using the original context (screen context, not dialog context)
                if (context.mounted) {
                  context.go(Routes.login);
                }
              },
              child: Text(
                'auth.logout'.tr,
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAccentColorPicker(
    BuildContext context,
    WidgetRef ref,
    AccentColor current,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'settings.accentColor'.tr,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 20.h),
            Wrap(
              spacing: 16.w,
              runSpacing: 16.h,
              children: AppColors.presetAccentColors.map((accent) {
                final isSelected = accent.name == current.name;
                return GestureDetector(
                  onTap: () {
                    ref
                        .read(accentColorProvider.notifier)
                        .setAccentColor(accent);
                    Navigator.pop(context);
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 48.w,
                        height: 48.w,
                        decoration: BoxDecoration(
                          color: accent.color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                  width: 3,
                                )
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: accent.color.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 24,
                              )
                            : null,
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'settings.accentColor_${accent.name}'.tr,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}

class _RegistrationDocumentCard extends StatelessWidget {
  const _RegistrationDocumentCard({
    required this.isDark,
    required this.sellerProfileAsync,
    required this.onViewProfile,
    required this.onRetry,
  });

  final bool isDark;
  final AsyncValue<BasicProfile?> sellerProfileAsync;
  final VoidCallback onViewProfile;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : LightColors.surface,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isDark ? DarkColors.border : LightColors.border,
          width: 0.5,
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
            Text(
              'common.loading'.tr,
              style: TextStyle(
                fontSize: 13.sp,
                color: isDark
                    ? DarkColors.textSecondary
                    : LightColors.textSecondary,
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
                'profile.registrationDocumentUnavailable'.tr,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: isDark
                      ? DarkColors.textSecondary
                      : LightColors.textSecondary,
                ),
              ),
            ),
            TextButton(onPressed: onRetry, child: Text('common.retry'.tr)),
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
                      'onboarding.documentTitle'.tr,
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
                          ? 'profile.registrationDocumentAddedLocked'.tr
                          : 'profile.registrationDocumentMissing'.tr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark
                            ? DarkColors.textSecondary
                            : LightColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: onViewProfile,
                icon: Icon(
                  hasDocument ? Icons.visibility_outlined : Icons.open_in_new,
                ),
                label: Text('common.open'.tr),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AccentColorRow extends StatelessWidget {
  const _AccentColorRow({
    super.key,
    required this.accentColor,
    required this.isDark,
    required this.onTap,
  });

  final AccentColor accentColor;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: accentColor.color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'settings.accentColor'.tr,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDark
                      ? DarkColors.textPrimary
                      : LightColors.textPrimary,
                ),
              ),
            ),
            Text(
              'settings.accentColor_${accentColor.name}'.tr,
              style: TextStyle(
                fontSize: 13.sp,
                color: isDark
                    ? DarkColors.textTertiary
                    : LightColors.textTertiary,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.chevron_right,
              size: 18.w,
              color: isDark
                  ? DarkColors.textTertiary
                  : LightColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.name,
    required this.email,
    this.logoUrl,
    required this.isDark,
  });

  final String name;
  final String email;
  final String? logoUrl;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : LightColors.surface,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isDark ? DarkColors.border : LightColors.border,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: logoUrl != null
                  ? Colors.transparent
                  : primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            clipBehavior: Clip.antiAlias,
            child: logoUrl != null
                ? CachedNetworkImage(
                    imageUrl: logoUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: primaryColor.withValues(alpha: 0.1),
                      child: Center(
                        child: SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.storefront_rounded,
                      size: 24.w,
                      color: primaryColor,
                    ),
                  )
                : Icon(
                    Icons.storefront_rounded,
                    size: 24.w,
                    color: primaryColor,
                  ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? DarkColors.textPrimary
                        : LightColors.textPrimary,
                  ),
                ),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark
                        ? DarkColors.textSecondary
                        : LightColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RestaurantSwitcherCard extends StatelessWidget {
  const _RestaurantSwitcherCard({
    required this.isDark,
    required this.currentRestaurantName,
    required this.onTap,
  });

  final bool isDark;
  final String currentRestaurantName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isDark ? DarkColors.surface : LightColors.surface,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isDark ? DarkColors.border : LightColors.border,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.storefront_outlined,
                size: 22.w,
                color: primaryColor,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'restaurant.selectRestaurant'.tr,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? DarkColors.textSecondary
                          : LightColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    currentRestaurantName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? DarkColors.textPrimary
                          : LightColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'restaurant.chooseRestaurant'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark
                          ? DarkColors.textTertiary
                          : LightColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20.w,
              color: isDark
                  ? DarkColors.textTertiary
                  : LightColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  const _QuickStat({
    required this.label,
    required this.value,
    required this.isDark,
    this.isAction = false,
    this.onTap,
  });

  final String label;
  final String value;
  final bool isDark;
  final bool isAction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isAction
                ? primaryColor.withValues(alpha: 0.1)
                : (isDark
                      ? DarkColors.surface
                      : LightColors.backgroundSecondary),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: isAction
                      ? primaryColor
                      : (isDark
                            ? DarkColors.textPrimary
                            : LightColors.textPrimary),
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: isDark
                      ? DarkColors.textSecondary
                      : LightColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    super.key,
    required this.icon,
    required this.label,
    required this.isDark,
    this.value,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isDark;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20.w,
              color: isDark
                  ? DarkColors.textSecondary
                  : LightColors.textSecondary,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDark
                      ? DarkColors.textPrimary
                      : LightColors.textPrimary,
                ),
              ),
            ),
            if (value != null)
              Text(
                value!,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: isDark
                      ? DarkColors.textTertiary
                      : LightColors.textTertiary,
                ),
              ),
            if (trailing != null) trailing!,
            if (trailing == null && onTap != null)
              Icon(
                Icons.chevron_right,
                size: 18.w,
                color: isDark
                    ? DarkColors.textTertiary
                    : LightColors.textTertiary,
              ),
          ],
        ),
      ),
    );
  }
}
