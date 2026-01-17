import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';
import '../../../notifications/application/notifications_notifier.dart';
import '../../../orders/application/orders_notifier.dart';
import '../../../orders/presentation/widgets/animated_order_card.dart';
import '../../../restaurant/application/restaurant_state.dart';

/// Home screen - Manager Dashboard
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(translationsLoadedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ordersState = ref.watch(ordersProvider);
    final pendingOrders = ordersState.pendingOrders;
    
    // Use restaurant stats from API if available, fallback to calculated values
    final selectedRestaurant = ref.watch(selectedRestaurantProvider);
    final todayStats = selectedRestaurant?.todayStats;
    
    final todayTotal = todayStats?.totalRevenue ?? ordersState.orders
        .where((o) => o.createdAt.day == DateTime.now().day)
        .fold<double>(0, (sum, o) => sum + o.total);
    final totalOrdersToday = todayStats?.totalOrders ?? ordersState.orders
        .where((o) => o.createdAt.day == DateTime.now().day)
        .length;

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : LightColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Refresh both orders and restaurant stats
            await ref.read(ordersProvider.notifier).refreshOrders();
            if (selectedRestaurant != null) {
              await ref.read(restaurantProvider.notifier).fetchRestaurantById(selectedRestaurant.id);
            }
          },
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 12.w, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedRestaurant?.name ?? 'profile.yourRestaurant'.tr,
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? DarkColors.textPrimary
                                    : LightColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      _NotificationIconButton(isDark: isDark),
                    ],
                  ),
                ),
              ),

              // Stats Row
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                  child: Row(
                    children: [
                      _StatBox(
                        value: pendingOrders.length.toString(),
                        label: 'orders.status.pending'.tr,
                        color: AppColors.warning,
                        isDark: isDark,
                        onTap: () => context.go(Routes.orders),
                      ),
                      SizedBox(width: 12.w),
                      _StatBox(
                        value: '\$${todayTotal.toStringAsFixed(0)}',
                        label: 'profile.today'.tr,
                        color: AppColors.success,
                        isDark: isDark,
                      ),
                      SizedBox(width: 12.w),
                      _StatBox(
                        value: totalOrdersToday.toString(),
                        label: 'navigation.orders'.tr,
                        color: AppColors.primary,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ),

              // Quick Actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                  child: _PrimaryAction(
                    icon: Icons.add,
                    label: 'orders.createOrder'.tr,
                    onTap: () => context.push(Routes.createOrder),
                  ),
                ),
              ),

              // Pending Orders Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'orders.pending'.tr,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? DarkColors.textPrimary
                              : LightColors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go(Routes.orders),
                        child: Text(
                          'common.seeAll'.tr,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Orders List
              if (pendingOrders.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(40.w),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 48.w,
                          color: AppColors.success,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'orders.noPendingOrders'.tr,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: isDark
                                ? DarkColors.textSecondary
                                : LightColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final order = pendingOrders[index];
                        return AnimatedOrderCard(
                          key: ValueKey(order.id),
                          order: order,
                          onTap: () => context.push(
                            Routes.orderDetailsPath(order.id),
                          ),
                        );
                      },
                      childCount: pendingOrders.length.clamp(0, 5),
                    ),
                  ),
                ),

              SliverToBoxAdapter(child: SizedBox(height: 100.h)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
    this.onTap,
  });

  final String value;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
          decoration: BoxDecoration(
            color: isDark
                ? DarkColors.surface
                : LightColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18.w, color: Colors.white),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationIconButton extends ConsumerWidget {
  const _NotificationIconButton({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final hasUnread = unreadCount > 0;

    return IconButton(
      onPressed: () => context.push(Routes.notifications),
      icon: Badge(
        smallSize: 8.w,
        isLabelVisible: hasUnread,
        child: Icon(
          Icons.notifications_none,
          color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
        ),
      ),
    );
  }
}

