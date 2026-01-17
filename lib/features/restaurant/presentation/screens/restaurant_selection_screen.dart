import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../application/restaurant_state.dart';
import '../../data/models/restaurant_model.dart';

/// Restaurant selection screen for sellers with multiple restaurants
class RestaurantSelectionScreen extends ConsumerWidget {
  const RestaurantSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(translationsLoadedProvider);
    final theme = Theme.of(context);
    final restaurantState = ref.watch(restaurantProvider);

    // Listen for state changes
    ref.listen<RestaurantState>(restaurantProvider, (previous, next) {
      if (next is RestaurantLoaded && next.selectedRestaurant != null) {
        // Navigate to home when restaurant is selected
        context.go(Routes.home);
      } else if (next is RestaurantError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return AppScaffold(
      appBar: AppBar(
        title: Text('restaurant.selectRestaurant'.tr),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: _buildBody(context, ref, restaurantState, theme),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    RestaurantState state,
    ThemeData theme,
  ) {
    if (state is RestaurantLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is RestaurantError) {
      return Center(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64.w,
                color: AppColors.error,
              ),
              SizedBox(height: 16.h),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              SizedBox(height: 24.h),
              AppButton(
                label: 'common.retry'.tr,
                onPressed: () {
                  ref.read(restaurantProvider.notifier).fetchRestaurants();
                },
              ),
            ],
          ),
        ),
      );
    }

    if (state is RestaurantLoaded) {
      if (state.restaurants.isEmpty) {
        return Center(
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.store_mall_directory_outlined,
                  size: 64.w,
                  color: theme.disabledColor,
                ),
                SizedBox(height: 16.h),
                Text(
                  'restaurant.noRestaurants'.tr,
                  style: theme.textTheme.titleLarge,
                ),
                SizedBox(height: 8.h),
                Text(
                  'restaurant.contactSupport'.tr,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.disabledColor,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return ListView(
        padding: AppSpacing.screenPadding,
        children: [
          SizedBox(height: 16.h),
          Text(
            'restaurant.selectYourRestaurant'.tr,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'restaurant.chooseRestaurant'.tr,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.disabledColor,
            ),
          ),
          SizedBox(height: 24.h),
          ...state.restaurants.map(
            (restaurant) => _RestaurantCard(
              restaurant: restaurant,
              onTap: () {
                ref
                    .read(restaurantProvider.notifier)
                    .selectRestaurant(restaurant);
              },
            ),
          ),
        ],
      );
    }

    // Initial or unknown state
    return const Center(child: CircularProgressIndicator());
  }
}

/// Restaurant card widget
class _RestaurantCard extends StatelessWidget {
  const _RestaurantCard({
    required this.restaurant,
    required this.onTap,
  });

  final RestaurantModel restaurant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: restaurant.status == RestaurantStatus.active
            ? BorderSide.none
            : BorderSide(
                color: AppColors.warning,
                width: 1,
              ),
      ),
      child: InkWell(
        onTap: restaurant.status == RestaurantStatus.active ? onTap : null,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and status
              Row(
                children: [
                  // Restaurant icon
                  Container(
                    width: 56.w,
                    height: 56.w,
                    decoration: BoxDecoration(
                      color: restaurant.status == RestaurantStatus.active
                          ? AppColors.primary[50]
                          : AppColors.warningLight,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.restaurant,
                      size: 28.w,
                      color: restaurant.status == RestaurantStatus.active
                          ? AppColors.primary
                          : AppColors.warning,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        _StatusBadge(status: restaurant.status),
                      ],
                    ),
                  ),
                  if (restaurant.status == RestaurantStatus.active)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 20.w,
                      color: theme.disabledColor,
                    ),
                ],
              ),

              // Description
              if (restaurant.description != null) ...[
                SizedBox(height: 12.h),
                Text(
                  restaurant.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.disabledColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Address
              if (restaurant.address != null) ...[
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16.w,
                      color: theme.disabledColor,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        restaurant.fullAddress,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.disabledColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              // Today's stats (if available)
              if (restaurant.todayStats != null) ...[
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: isDark
                        ? DarkColors.backgroundTertiary
                        : AppColors.primary[50],
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatItem(
                          icon: Icons.pending_actions,
                          label: 'orders.status.pending'.tr,
                          value: restaurant.todayStats!.pendingOrders.toString(),
                          color: AppColors.warning,
                        ),
                      ),
                      Expanded(
                        child: _StatItem(
                          icon: Icons.shopping_bag_outlined,
                          label: 'navigation.orders'.tr,
                          value: restaurant.todayStats!.totalOrders.toString(),
                          color: AppColors.primary,
                        ),
                      ),
                      Expanded(
                        child: _StatItem(
                          icon: Icons.euro,
                          label: 'statistics.revenue'.tr,
                          value: restaurant.todayStats!.totalRevenue
                              .toStringAsFixed(0),
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Inactive warning
              if (restaurant.status != RestaurantStatus.active) ...[
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: AppColors.warning,
                    ),
                  ),
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
                          restaurant.status == RestaurantStatus.pending
                              ? 'restaurantStatus.pendingApproval'.tr
                              : 'restaurantStatus.inactive'.tr,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.warningDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Status badge widget
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final RestaurantStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case RestaurantStatus.active:
        backgroundColor = AppColors.successLight;
        textColor = AppColors.success;
        label = 'Active';
        break;
      case RestaurantStatus.pending:
        backgroundColor = AppColors.warningLight;
        textColor = AppColors.warning;
        label = 'Pending';
        break;
      case RestaurantStatus.inactive:
        backgroundColor = AppColors.errorLight;
        textColor = AppColors.error;
        label = 'Inactive';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.w,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Stat item widget for today's stats
class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(
          icon,
          size: 20.w,
          color: color,
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.disabledColor,
          ),
        ),
      ],
    );
  }
}
