import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';
import '../../../auth/application/auth_state.dart';
import '../../../restaurant/application/restaurant_state.dart';
import '../../application/user_profile_notifier.dart';

/// Profile screen - minimal design
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(translationsLoadedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeProvider);

    // Get user profile and restaurant data
    final userProfileState = ref.watch(userProfileProvider);
    final selectedRestaurant = ref.watch(selectedRestaurantProvider);

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
            name: selectedRestaurant?.name ?? userProfileState.profile?.name ?? 'profile.yourRestaurant'.tr,
            email: userProfileState.profile?.email ?? userProfileState.profile?.phone ?? '',
            isDark: isDark,
            onEdit: () => context.push(Routes.restaurantSettings),
          ),
          SizedBox(height: 20.h),

          // Quick stats row
          Row(
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
                value: selectedRestaurant?.todayStats?.totalOrders.toString() ?? '0',
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

          // Settings list
          _SettingRow(
            icon: Icons.local_offer_outlined,
            label: 'coupons.title'.tr,
            isDark: isDark,
            onTap: () => context.push(Routes.coupons),
          ),
          _SettingRow(
            icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            label: 'settings.darkMode'.tr,
            isDark: isDark,
            trailing: Switch.adaptive(
              value: themeMode == AppThemeMode.dark,
              onChanged: (value) {
                ref
                    .read(themeProvider.notifier)
                    .setTheme(value ? AppThemeMode.dark : AppThemeMode.light);
              },
            ),
          ),
          _SettingRow(
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

          SizedBox(height: 24.h),

          // Logout
          GestureDetector(
            onTap: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go(Routes.login);
              }
            },
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
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.name,
    required this.email,
    required this.isDark,
    required this.onEdit,
  });

  final String name;
  final String email;
  final bool isDark;
  final VoidCallback onEdit;

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
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.storefront_rounded,
              size: 24.w,
              color: AppColors.primary,
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
          GestureDetector(
            onTap: onEdit,
            child: Icon(
              Icons.edit_outlined,
              size: 18.w,
              color: AppColors.primary,
            ),
          ),
        ],
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
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isAction
                ? AppColors.primary.withValues(alpha: 0.1)
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
                      ? AppColors.primary
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
