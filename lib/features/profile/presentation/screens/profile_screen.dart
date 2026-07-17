import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/i18n/i18n.dart';
import '../../../../core/network/user_api.dart';
import '../../../../core/responsive/responsive.dart';
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
  bool _isUpdatingDeliveryEnabled = false;
  String? _updatingDeliveryRestaurantId;
  bool? _pendingDeliveryEnabled;

  @override
  Widget build(BuildContext context) {
    ref.watch(translationsLoadedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
    final effectiveRestaurant =
        selectedRestaurant ??
        (restaurants.isNotEmpty ? restaurants.first : null);
    final visibleDeliveryEnabled =
        _updatingDeliveryRestaurantId == effectiveRestaurant?.id
        ? (_pendingDeliveryEnabled ?? effectiveRestaurant?.deliveryEnabled)
        : effectiveRestaurant?.deliveryEnabled;

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
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: Breakpoints.maxContentWidth,
                ),
                child: ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                // Restaurant/User info
                _ProfileCard(
                  name:
                      effectiveRestaurant?.name ??
                      userProfileState.profile?.name ??
                      'profile.yourRestaurant'.tr,
                  email:
                      userProfileState.profile?.email ??
                      userProfileState.profile?.phone ??
                      '',
                  logoUrl: effectiveRestaurant?.logoUrl,
                  deliveryEnabled: visibleDeliveryEnabled ?? false,
                  isDark: isDark,
                  canSwitchRestaurant: hasMultipleRestaurants,
                  onRestaurantTap: hasMultipleRestaurants
                      ? () => _showRestaurantPicker(
                          context,
                          ref,
                          restaurants,
                          effectiveRestaurant,
                        )
                      : null,
                  isUpdatingDelivery: _isUpdatingDeliveryEnabled,
                  onDeliveryChanged: effectiveRestaurant == null
                      ? null
                      : (value) =>
                            _updateDeliveryEnabled(effectiveRestaurant, value),
                  onEditProfileTap: () => context.push(Routes.editProfile),
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
                          ? '€${selectedRestaurant!.todayStats!.totalRevenue.toStringAsFixed(0)}'
                          : '€0',
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

                _SectionMenuTile(
                  key: TourKeys.settingsOptionsKey,
                  title: 'profile.settingsSectionTitle'.tr,
                  subtitle: 'profile.settingsSectionSubtitle'.tr,
                  isDark: isDark,
                  onTap: () => _showSettingsSectionSheet(context),
                ),
                SizedBox(height: 10.h),
                _SectionMenuTile(
                  key: TourKeys.themeSettingKey,
                  title: 'profile.preferencesSectionTitle'.tr,
                  subtitle: 'profile.preferencesSectionSubtitle'.tr,
                  isDark: isDark,
                  onTap: () => _showPreferencesSectionSheet(context),
                ),
                SizedBox(height: 10.h),
                _SectionMenuTile(
                  key: TourKeys.knowledgeBaseRowKey,
                  title: 'profile.helpSupportSectionTitle'.tr,
                  subtitle: 'profile.helpSupportSectionSubtitle'.tr,
                  isDark: isDark,
                  onTap: () => _showHelpSectionSheet(context),
                ),
                if (ordersState.completedOrders.length >= 3) ...[
                  SizedBox(height: 16.h),
                  const TourSectionWidget(),
                  SizedBox(height: 12.h),
                ],
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
                SizedBox(height: 8.h),
                Text(
                  AppConfig.compactReleaseLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: isDark
                        ? DarkColors.textTertiary
                        : LightColors.textTertiary,
                  ),
                ),
                SizedBox(height: 80.h),
              ],
            ),
              ),
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

  void _showSettingsSectionSheet(BuildContext context) {
    final parentContext = context;
    _showSectionSheet(
      context: context,
      title: 'profile.settingsSectionTitle'.tr,
      subtitle: 'profile.settingsSectionSubtitle'.tr,
      builder: (sheetContext, isDark) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SettingRow(
            label: 'earnings.title'.tr,
            isDark: isDark,
            onTap: () => _navigateFromSheet(
              sheetContext,
              parentContext,
              Routes.earnings,
            ),
          ),
          _SettingRow(
            label: 'coupons.title'.tr,
            isDark: isDark,
            onTap: () =>
                _navigateFromSheet(sheetContext, parentContext, Routes.coupons),
          ),
          _SettingRow(
            label: 'settings.notifications'.tr,
            isDark: isDark,
            onTap: () => _navigateFromSheet(
              sheetContext,
              parentContext,
              Routes.notifications,
            ),
          ),
        ],
      ),
    );
  }

  void _showPreferencesSectionSheet(BuildContext context) {
    final parentContext = context;
    _showSectionSheet(
      context: context,
      title: 'profile.preferencesSectionTitle'.tr,
      subtitle: 'profile.preferencesSectionSubtitle'.tr,
      builder: (sheetContext, isDark) => Consumer(
        builder: (context, ref, child) {
          final themeMode = ref.watch(themeProvider);
          final accentColor = ref.watch(accentColorProvider);
          final locale = ref.watch(localeProvider);
          final isDarkMode = themeMode == AppThemeMode.dark;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SettingRow(
                label: 'settings.darkMode'.tr,
                isDark: isDark,
                trailing: Switch.adaptive(
                  value: isDarkMode,
                  onChanged: (value) {
                    ref
                        .read(themeProvider.notifier)
                        .setTheme(
                          value ? AppThemeMode.dark : AppThemeMode.light,
                        );
                  },
                ),
                onTap: () {
                  ref
                      .read(themeProvider.notifier)
                      .setTheme(
                        isDarkMode ? AppThemeMode.light : AppThemeMode.dark,
                      );
                },
              ),
              _SettingRow(
                key: TourKeys.languageSettingKey,
                label: 'settings.language'.tr,
                value: locale.languageCode.toUpperCase(),
                isDark: isDark,
                onTap: () => _navigateFromSheet(
                  sheetContext,
                  parentContext,
                  Routes.language,
                ),
              ),
              _SettingRow(
                key: TourKeys.accentColorSettingKey,
                label: 'settings.accentColor'.tr,
                value: 'settings.accentColor_${accentColor.name}'.tr,
                isDark: isDark,
                onTap: () =>
                    _showAccentColorPicker(sheetContext, ref, accentColor),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showHelpSectionSheet(BuildContext context) {
    final parentContext = context;
    _showSectionSheet(
      context: context,
      title: 'profile.helpSupportSectionTitle'.tr,
      subtitle: 'profile.helpSupportSectionSubtitle'.tr,
      builder: (sheetContext, isDark) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SettingRow(
            label: 'knowledgeBase.title'.tr,
            isDark: isDark,
            onTap: () => _navigateFromSheet(
              sheetContext,
              parentContext,
              Routes.knowledgeBase,
            ),
          ),
          _SettingRow(
            label: 'support.title'.tr,
            isDark: isDark,
            onTap: () =>
                _navigateFromSheet(sheetContext, parentContext, Routes.support),
          ),
          _SettingRow(
            label: 'settings.help'.tr,
            isDark: isDark,
            onTap: () =>
                _navigateFromSheet(sheetContext, parentContext, Routes.help),
          ),
          _SettingRow(
            label: 'settings.about'.tr,
            isDark: isDark,
            onTap: () =>
                _navigateFromSheet(sheetContext, parentContext, Routes.about),
          ),
          _SettingRow(
            label: 'deleteAccount.title'.tr,
            isDark: isDark,
            isDestructive: true,
            onTap: () => _navigateFromSheet(
              sheetContext,
              parentContext,
              Routes.deleteAccount,
            ),
          ),
        ],
      ),
    );
  }

  void _showSectionSheet({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Widget Function(BuildContext sheetContext, bool isDark) builder,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? DarkColors.surface
          : LightColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16.w,
                12.h,
                16.w,
                24.h + MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: isDark ? DarkColors.border : LightColors.border,
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? DarkColors.textPrimary
                          : LightColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isDark
                          ? DarkColors.textSecondary
                          : LightColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  builder(sheetContext, isDark),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateFromSheet(
    BuildContext sheetContext,
    BuildContext parentContext,
    String route,
  ) {
    Navigator.of(sheetContext).pop();
    parentContext.push(route);
  }

  void _showRestaurantPicker(
    BuildContext context,
    WidgetRef ref,
    List<RestaurantModel> restaurants,
    RestaurantModel? selectedRestaurant,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? DarkColors.surface
          : LightColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (bottomSheetContext) {
        final isDark =
            Theme.of(bottomSheetContext).brightness == Brightness.dark;
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: isDark ? DarkColors.border : LightColors.border,
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'restaurant.selectRestaurant'.tr,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? DarkColors.textPrimary
                        : LightColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'restaurant.chooseRestaurant'.tr,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isDark
                        ? DarkColors.textSecondary
                        : LightColors.textSecondary,
                  ),
                ),
                SizedBox(height: 16.h),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: restaurants.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 10.h),
                    itemBuilder: (context, index) {
                      final restaurant = restaurants[index];
                      return _RestaurantPickerTile(
                        restaurant: restaurant,
                        isDark: isDark,
                        isSelected: restaurant.id == selectedRestaurant?.id,
                        onTap: restaurant.status == RestaurantStatus.active
                            ? () async {
                                await ref
                                    .read(restaurantProvider.notifier)
                                    .selectRestaurant(restaurant);
                                if (bottomSheetContext.mounted) {
                                  Navigator.of(bottomSheetContext).pop();
                                }
                              }
                            : null,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateDeliveryEnabled(
    RestaurantModel restaurant,
    bool value,
  ) async {
    if (_isUpdatingDeliveryEnabled) return;

    setState(() {
      _isUpdatingDeliveryEnabled = true;
      _updatingDeliveryRestaurantId = restaurant.id;
      _pendingDeliveryEnabled = value;
    });

    final result = await ref
        .read(restaurantRepositoryProvider)
        .updateRestaurant(
          restaurant.id,
          _buildRestaurantUpdatePayload(
            restaurant: restaurant,
            deliveryEnabled: value,
          ),
        );

    if (!mounted) return;

    if (result.failure != null || result.data == null) {
      setState(() {
        _isUpdatingDeliveryEnabled = false;
        _updatingDeliveryRestaurantId = null;
        _pendingDeliveryEnabled = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.failure?.message ?? 'errors.serverError'.tr),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    ref.read(restaurantProvider.notifier).syncUpdatedRestaurant(result.data!);

    setState(() {
      _isUpdatingDeliveryEnabled = false;
      _updatingDeliveryRestaurantId = null;
      _pendingDeliveryEnabled = null;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('settings.settingsSaved'.tr)));
  }

  Map<String, dynamic> _buildRestaurantUpdatePayload({
    required RestaurantModel restaurant,
    required bool deliveryEnabled,
  }) {
    return {
      'name': restaurant.name,
      if ((restaurant.phone ?? '').trim().isNotEmpty)
        'phone': restaurant.phone!.trim(),
      if ((restaurant.logoUrl ?? '').trim().isNotEmpty)
        'logo': restaurant.logoUrl,
      'delivery_enabled': deliveryEnabled,
      'work_hours': {
        for (final entry in restaurant.workHours.entries)
          entry.key: entry.value
              .map((period) => {'open': period.open, 'close': period.close})
              .toList(),
      },
      if (restaurant.addressData?.id != null)
        'address_id': restaurant.addressData!.id,
    };
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

          if (!hasDocument) {
            return InkWell(
              onTap: onViewProfile,
              borderRadius: BorderRadius.circular(10.r),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16.w,
                    color: AppColors.warning,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'profile.registrationDocumentMissing'.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark
                            ? DarkColors.textSecondary
                            : LightColors.textSecondary,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.chevron_right,
                    size: 16.w,
                    color: isDark
                        ? DarkColors.textTertiary
                        : LightColors.textTertiary,
                  ),
                ],
              ),
            );
          }

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
                  Icons.verified_outlined,
                  size: 20.w,
                  color: AppColors.success,
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
                      'profile.registrationDocumentAddedLocked'.tr,
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
                icon: const Icon(Icons.visibility_outlined),
                label: Text('common.open'.tr),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.name,
    required this.email,
    this.logoUrl,
    required this.deliveryEnabled,
    required this.isDark,
    this.canSwitchRestaurant = false,
    this.onRestaurantTap,
    this.isUpdatingDelivery,
    this.onDeliveryChanged,
    this.onEditProfileTap,
  });

  final String name;
  final String email;
  final String? logoUrl;
  final bool deliveryEnabled;
  final bool isDark;
  final bool canSwitchRestaurant;
  final VoidCallback? onRestaurantTap;
  final bool? isUpdatingDelivery;
  final ValueChanged<bool>? onDeliveryChanged;
  final VoidCallback? onEditProfileTap;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final borderColor = isDark
        ? DarkColors.border.withValues(alpha: 0.7)
        : LightColors.border.withValues(alpha: 0.75);
    final cardColor = isDark
        ? DarkColors.surface
        : LightColors.surface.withValues(alpha: 0.96);

    return InkWell(
      onTap: onRestaurantTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: borderColor, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: logoUrl != null
                        ? Colors.transparent
                        : primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14.r),
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
                            size: 20.w,
                            color: primaryColor,
                          ),
                        )
                      : Icon(
                          Icons.storefront_rounded,
                          size: 20.w,
                          color: primaryColor,
                        ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? DarkColors.textPrimary
                                    : LightColors.textPrimary,
                                height: 1.1,
                              ),
                            ),
                          ),
                          if (canSwitchRestaurant) ...[
                            SizedBox(width: 10.w),
                            Container(
                              width: 30.w,
                              height: 30.w,
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: primaryColor.withValues(alpha: 0.12),
                                ),
                              ),
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 18.w,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          height: 1.15,
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
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: _HeaderActionButton(
                    label: deliveryEnabled
                        ? 'profile.deliveryEnabled'.tr
                        : 'profile.deliveryDisabled'.tr,
                    isDark: isDark,
                    isActive: deliveryEnabled,
                    isDanger: !deliveryEnabled,
                    isLoading: isUpdatingDelivery ?? false,
                    onTap: onDeliveryChanged == null
                        ? null
                        : () => onDeliveryChanged!(!deliveryEnabled),
                  ),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: _HeaderActionButton(
                    label: 'profile.editProfile'.tr,
                    isDark: isDark,
                    onTap: onEditProfileTap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({
    required this.label,
    required this.isDark,
    this.isActive = false,
    this.isDanger = false,
    this.isLoading = false,
    this.onTap,
  });

  final String label;
  final bool isDark;
  final bool isActive;
  final bool isDanger;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final accentColor = isDanger ? AppColors.error : primaryColor;
    final backgroundColor = isActive
        ? accentColor.withValues(alpha: 0.06)
        : isDanger
        ? AppColors.error.withValues(alpha: isDark ? 0.12 : 0.08)
        : (isDark ? DarkColors.backgroundTertiary : LightColors.surface);
    final borderColor = isActive
        ? accentColor.withValues(alpha: 0.14)
        : isDanger
        ? AppColors.error.withValues(alpha: 0.24)
        : (isDark
              ? DarkColors.border.withValues(alpha: 0.55)
              : LightColors.border.withValues(alpha: 0.75));
    final textColor = isDanger
        ? AppColors.error
        : (isDark ? DarkColors.textPrimary : LightColors.textPrimary);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: borderColor, width: 0.7),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    height: 1.1,
                  ),
                ),
              ),
              if (isLoading) ...[
                SizedBox(width: 6.w),
                SizedBox(
                  width: 12.w,
                  height: 12.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.8,
                    color: accentColor,
                  ),
                ),
              ] else if (isActive) ...[
                SizedBox(width: 6.w),
                Icon(Icons.check_rounded, size: 14.w, color: accentColor),
              ],
            ],
          ),
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
    final borderColor = isAction
        ? primaryColor.withValues(alpha: 0.18)
        : (isDark
              ? DarkColors.border.withValues(alpha: 0.7)
              : LightColors.border.withValues(alpha: 0.8));
    final backgroundColor = isAction
        ? primaryColor.withValues(alpha: 0.05)
        : (isDark ? DarkColors.surface : LightColors.surface);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: borderColor, width: 0.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isAction) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? DarkColors.textSecondary
                              : LightColors.textSecondary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_outward_rounded,
                      size: 14.w,
                      color: primaryColor,
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
              ] else ...[
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? DarkColors.textSecondary
                        : LightColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8.h),
              ],
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isAction ? 15.sp : 18.sp,
                  fontWeight: FontWeight.w700,
                  color: isAction
                      ? primaryColor
                      : (isDark
                            ? DarkColors.textPrimary
                            : LightColors.textPrimary),
                  height: 1.05,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RestaurantPickerTile extends StatelessWidget {
  const _RestaurantPickerTile({
    required this.restaurant,
    required this.isDark,
    required this.isSelected,
    this.onTap,
  });

  final RestaurantModel restaurant;
  final bool isDark;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isEnabled = restaurant.status == RestaurantStatus.active;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.08)
              : (isDark ? DarkColors.background : LightColors.background),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : (isDark ? DarkColors.border : LightColors.border),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: isEnabled
                    ? primaryColor.withValues(alpha: 0.12)
                    : AppColors.warningLight,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.storefront_outlined,
                size: 20.w,
                color: isEnabled ? primaryColor : AppColors.warning,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? DarkColors.textPrimary
                          : LightColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  _RestaurantStatusPill(
                    status: restaurant.status,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            if (isSelected)
              Icon(Icons.check_circle, size: 20.w, color: primaryColor)
            else if (isEnabled)
              Icon(
                Icons.chevron_right,
                size: 18.w,
                color: isDark
                    ? DarkColors.textTertiary
                    : LightColors.textTertiary,
              )
            else
              Icon(Icons.lock_outline, size: 16.w, color: AppColors.warning),
          ],
        ),
      ),
    );
  }
}

class _RestaurantStatusPill extends StatelessWidget {
  const _RestaurantStatusPill({required this.status, required this.isDark});

  final RestaurantStatus status;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    late final Color textColor;
    late final Color backgroundColor;
    late final String label;

    switch (status) {
      case RestaurantStatus.active:
        textColor = AppColors.success;
        backgroundColor = AppColors.success.withValues(alpha: 0.12);
        label = 'restaurantStatus.active'.tr;
        break;
      case RestaurantStatus.pending:
        textColor = AppColors.warningDark;
        backgroundColor = AppColors.warningLight;
        label = 'orders.status.pending'.tr;
        break;
      case RestaurantStatus.inactive:
        textColor = isDark
            ? DarkColors.textSecondary
            : LightColors.textSecondary;
        backgroundColor = isDark
            ? DarkColors.backgroundTertiary
            : LightColors.backgroundSecondary;
        label = 'restaurantStatus.inactive'.tr;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

class _SectionMenuTile extends StatelessWidget {
  const _SectionMenuTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isDark,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final bool isDark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isDark ? DarkColors.surface : LightColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isDark
                ? DarkColors.border.withValues(alpha: 0.7)
                : LightColors.border.withValues(alpha: 0.8),
            width: 0.6,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
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
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      height: 1.3,
                      color: isDark
                          ? DarkColors.textSecondary
                          : LightColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
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

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    super.key,
    required this.label,
    required this.isDark,
    this.value,
    this.trailing,
    this.isDestructive = false,
    this.onTap,
  });

  final String label;
  final bool isDark;
  final String? value;
  final Widget? trailing;
  final bool isDestructive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final primaryTextColor = isDestructive
        ? AppColors.error
        : (isDark ? DarkColors.textPrimary : LightColors.textPrimary);
    final secondaryTextColor = isDestructive
        ? AppColors.error.withValues(alpha: 0.75)
        : (isDark ? DarkColors.textSecondary : LightColors.textSecondary);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: primaryTextColor,
                ),
              ),
            ),
            if (value != null)
              Text(
                value!,
                style: TextStyle(fontSize: 13.sp, color: secondaryTextColor),
              ),
            if (trailing != null) trailing!,
            if (trailing == null && onTap != null)
              Icon(Icons.chevron_right, size: 18.w, color: secondaryTextColor),
          ],
        ),
      ),
    );
  }
}
