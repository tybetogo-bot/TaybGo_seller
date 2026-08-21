import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/i18n/i18n.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/theme.dart';
import '../../../../features/tour/application/tour_notifier.dart';
import '../../../../features/tour/presentation/widgets/tour_section_widget.dart';
import '../../../../features/tour/utils/tour_keys.dart';
import '../../../notifications/application/notifications_notifier.dart';
import '../../../orders/application/orders_notifier.dart';
import '../../../orders/data/models/order_model.dart';
import '../../../orders/presentation/widgets/animated_order_card.dart';
import '../../../restaurant/application/restaurant_state.dart';

/// Home screen - Manager Dashboard
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  OrderStatusEnum? _newOrdersStatusFilter;

  @override
  Widget build(BuildContext context) {
    ref.watch(translationsLoadedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ordersState = ref.watch(ordersProvider);
    final newOrders = ordersState.orders
        .where(
          (order) =>
              order.status == OrderStatusEnum.pending ||
              order.status == OrderStatusEnum.accepted ||
              order.status == OrderStatusEnum.searchingForDriver ||
              order.status == OrderStatusEnum.driverNotificationSent,
        )
        .toList();
    final expiredOrders = ordersState.expiredOrders;
    final availableNewOrderStatuses = newOrders
        .map((order) => order.status)
        .toSet()
        .toList();
    final selectedNewOrderStatus =
        availableNewOrderStatuses.contains(_newOrdersStatusFilter)
        ? _newOrdersStatusFilter
        : null;
    final visibleNewOrders = selectedNewOrderStatus == null
        ? newOrders
        : newOrders
              .where((order) => order.status == selectedNewOrderStatus)
              .toList();

    // Use restaurant stats from API if available, fallback to calculated values
    final selectedRestaurant = ref.watch(selectedRestaurantProvider);
    final todayStats = selectedRestaurant?.todayStats;

    // Cache DateTime.now() to avoid multiple allocations
    final double todayTotal;
    final int totalOrdersToday;
    if (todayStats != null) {
      todayTotal = todayStats.totalRevenue;
      totalOrdersToday = todayStats.totalOrders;
    } else {
      // Fallback calculation - only done when API stats unavailable
      final today = DateTime.now().day;
      var total = 0.0;
      var count = 0;
      for (final o in ordersState.orders) {
        if (o.createdAt.day == today) {
          total += o.total;
          count++;
        }
      }
      todayTotal = total;
      totalOrdersToday = count;
    }

    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : LightColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: Breakpoints.maxContentWidth,
            ),
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(ordersProvider.notifier).refreshOrders();
                if (selectedRestaurant != null) {
                  await ref
                      .read(restaurantProvider.notifier)
                      .fetchRestaurantById(selectedRestaurant.id);
                }
              },
              color: primaryColor,
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
                                  selectedRestaurant?.name ??
                                      'profile.yourRestaurant'.tr,
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
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _RefreshButton(isDark: isDark),
                              _NotificationIconButton(isDark: isDark),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Stats Row
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                      child: Row(
                        key: TourKeys.homeStatsCardKey,
                        children: [
                          _StatBox(
                            value: newOrders.length.toString(),
                            label: 'orders.new'.tr,
                            color: AppColors.warning,
                            isDark: isDark,
                            onTap: () => context.go(Routes.orders),
                          ),
                          SizedBox(width: 12.w),
                          _StatBox(
                            value: '€${todayTotal.toStringAsFixed(0)}',
                            label: 'profile.today'.tr,
                            color: AppColors.success,
                            isDark: isDark,
                          ),
                          SizedBox(width: 12.w),
                          _StatBox(
                            value: totalOrdersToday.toString(),
                            label: 'navigation.orders'.tr,
                            color: primaryColor,
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
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
                      child: Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: [
                          if (expiredOrders.isNotEmpty)
                            _CompactAction(
                              icon: Icons.timer_off_outlined,
                              label: 'orders.expiredAction'.trParams({
                                'count': expiredOrders.length.toString(),
                              }),
                              isDark: isDark,
                              accentColor: AppColors.warning,
                              onTap: () =>
                                  context.go(Routes.ordersPath(tab: 'expired')),
                            ),
                          _CompactAction(
                            icon: Icons.support_agent_outlined,
                            label: 'support.title'.tr,
                            isDark: isDark,
                            onTap: () => context.push(Routes.support),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Tour section - only show before the seller has any orders.
                  if (!ordersState.isLoading &&
                      ordersState.orders.isEmpty &&
                      !ref.watch(tourProvider).isDismissedFromHome)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
                        child: const TourSectionWidget(),
                      ),
                    ),

                  // New Orders Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 12.h),
                      child: Row(
                        key: TourKeys.homePendingOrdersKey,
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
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (availableNewOrderStatuses.length > 1) ...[
                                _NewOrdersStatusFilter(
                                  statuses: availableNewOrderStatuses,
                                  selectedStatus: selectedNewOrderStatus,
                                  isDark: isDark,
                                  onSelected: (status) {
                                    setState(
                                      () => _newOrdersStatusFilter = status,
                                    );
                                  },
                                ),
                                SizedBox(width: 10.w),
                              ],
                              GestureDetector(
                                onTap: () => context.go(Routes.orders),
                                child: Text(
                                  'common.seeAll'.tr,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Orders List
                  if (visibleNewOrders.isEmpty)
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
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final order = visibleNewOrders[index];
                          return RepaintBoundary(
                            child: AnimatedOrderCard(
                              key: ValueKey(order.id),
                              order: order,
                              onTap: () => context.push(
                                Routes.orderDetailsPath(order.id),
                              ),
                            ),
                          );
                        }, childCount: visibleNewOrders.length.clamp(0, 5)),
                      ),
                    ),

                  SliverToBoxAdapter(child: SizedBox(height: 100.h)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NewOrdersStatusFilter extends StatelessWidget {
  const _NewOrdersStatusFilter({
    required this.statuses,
    required this.selectedStatus,
    required this.isDark,
    required this.onSelected,
  });

  final List<OrderStatusEnum> statuses;
  final OrderStatusEnum? selectedStatus;
  final bool isDark;
  final ValueChanged<OrderStatusEnum?> onSelected;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final borderColor = isDark ? DarkColors.border : LightColors.border;
    final textColor = selectedStatus == null
        ? primaryColor
        : (isDark ? DarkColors.textPrimary : LightColors.textPrimary);

    return PopupMenuButton<String>(
      initialValue: selectedStatus?.name ?? 'all',
      onSelected: (value) {
        if (value == 'all') {
          onSelected(null);
          return;
        }
        onSelected(statuses.firstWhere((status) => status.name == value));
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(value: 'all', child: Text('orders.all'.tr)),
        for (final status in statuses)
          PopupMenuItem<String>(
            value: status.name,
            child: Text(_newOrderStatusLabel(status)),
          ),
      ],
      color: isDark ? DarkColors.surface : LightColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: selectedStatus == null
              ? primaryColor.withValues(alpha: 0.08)
              : (isDark ? DarkColors.surface : LightColors.surface),
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(
            color: selectedStatus == null
                ? primaryColor.withValues(alpha: 0.35)
                : borderColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tune_rounded, size: 14.w, color: textColor),
            SizedBox(width: 5.w),
            Text(
              selectedStatus == null
                  ? 'orders.all'.tr
                  : _newOrderStatusLabel(selectedStatus!),
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            SizedBox(width: 2.w),
            Icon(Icons.arrow_drop_down_rounded, size: 16.w, color: textColor),
          ],
        ),
      ),
    );
  }
}

String _newOrderStatusLabel(OrderStatusEnum status) {
  return switch (status) {
    OrderStatusEnum.pending => 'orders.status.pending'.tr,
    OrderStatusEnum.accepted => 'orders.status.accepted'.tr,
    OrderStatusEnum.searchingForDriver => 'orders.status.searchingForDriver'.tr,
    OrderStatusEnum.driverNotificationSent =>
      'orders.status.driverNotificationSent'.tr,
    _ => status.displayName,
  };
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
    final backgroundColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: backgroundColor,
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

class _CompactAction extends StatelessWidget {
  const _CompactAction({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
    this.accentColor,
  });

  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final actionColor = accentColor ?? Theme.of(context).colorScheme.primary;
    final maxWidth = MediaQuery.sizeOf(context).width - 40.w;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999.r),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Ink(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: actionColor.withValues(alpha: isDark ? 0.14 : 0.08),
              borderRadius: BorderRadius.circular(999.r),
              border: Border.all(color: actionColor.withValues(alpha: 0.22)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16.w, color: actionColor),
                SizedBox(width: 6.w),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? DarkColors.textPrimary
                          : LightColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RefreshButton extends ConsumerStatefulWidget {
  const _RefreshButton({required this.isDark});

  final bool isDark;

  @override
  ConsumerState<_RefreshButton> createState() => _RefreshButtonState();
}

class _RefreshButtonState extends ConsumerState<_RefreshButton> {
  bool _isRefreshing = false;

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);

    try {
      await ref.read(ordersProvider.notifier).refreshOrders();
      final selectedRestaurant = ref.read(selectedRestaurantProvider);
      if (selectedRestaurant != null) {
        await ref
            .read(restaurantProvider.notifier)
            .fetchRestaurantById(selectedRestaurant.id);
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _isRefreshing ? null : _handleRefresh,
      icon: _isRefreshing
          ? SizedBox(
              width: 20.w,
              height: 20.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: widget.isDark
                    ? DarkColors.textPrimary
                    : LightColors.textSecondary,
              ),
            )
          : Icon(
              Icons.refresh_rounded,
              color: widget.isDark
                  ? DarkColors.textPrimary
                  : LightColors.textPrimary,
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
