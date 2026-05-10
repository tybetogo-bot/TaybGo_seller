import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';
import '../../../notifications/application/notifications_notifier.dart';
import '../../../profile/application/user_profile_notifier.dart';
import '../../../tour/application/tour_notifier.dart';
import '../../../tour/utils/tour_keys.dart';
import '../../application/orders_notifier.dart';
import '../../data/models/order_model.dart';
import '../widgets/animated_order_card.dart';

enum OrdersScreenTab {
  current,
  done,
  expired;

  static OrdersScreenTab fromQueryParam(String? value) {
    switch (value?.toLowerCase()) {
      case 'done':
        return OrdersScreenTab.done;
      case 'expired':
        return OrdersScreenTab.expired;
      case 'current':
      default:
        return OrdersScreenTab.current;
    }
  }
}

enum CurrentOrdersFilter { newOnly, activeOnly, all }

/// Orders screen
class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key, this.initialTab = OrdersScreenTab.current});

  final OrdersScreenTab initialTab;

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  final _searchController = TextEditingController();
  bool _isRefreshing = false;
  CurrentOrdersFilter _currentOrdersFilter = CurrentOrdersFilter.all;
  Timer? _searchDebounce;
  OrdersPollingNotifier? _ordersPollingNotifier;
  NotificationsPollingNotifier? _notificationsPollingNotifier;
  UserProfilePollingNotifier? _profilePollingNotifier;

  @override
  void initState() {
    super.initState();
    debugPrint('[OrdersScreen] initState() called');
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab.index,
    );
    WidgetsBinding.instance.addObserver(this);

    // Start polling when screen is initialized (skip during tour)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tourActive = ref.read(tourProvider).isActive;
      if (!tourActive) {
        debugPrint('[OrdersScreen] starting all polling services');

        _ordersPollingNotifier = ref.read(ordersPollingProvider.notifier);
        _ordersPollingNotifier!.start();

        _notificationsPollingNotifier = ref.read(
          notificationsPollingProvider.notifier,
        );
        _notificationsPollingNotifier!.start();

        _profilePollingNotifier = ref.read(userProfilePollingProvider.notifier);
        _profilePollingNotifier!.start();
      } else {
        debugPrint('[OrdersScreen] skipping polling because tour is active');
      }
    });
  }

  @override
  void didUpdateWidget(covariant OrdersScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialTab != widget.initialTab &&
        _tabController.index != widget.initialTab.index) {
      _tabController.animateTo(widget.initialTab.index);
    }
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);

    try {
      await ref.read(ordersProvider.notifier).refreshOrders();
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  void dispose() {
    debugPrint('[OrdersScreen] dispose() called');
    _ordersPollingNotifier?.stop();
    _notificationsPollingNotifier?.stop();
    _profilePollingNotifier?.stop();
    WidgetsBinding.instance.removeObserver(this);
    _searchDebounce?.cancel();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(ordersPollingProvider.notifier).start();
      ref.read(notificationsPollingProvider.notifier).start();
      ref.read(userProfilePollingProvider.notifier).start();
    } else if (state == AppLifecycleState.paused) {
      ref.read(ordersPollingProvider.notifier).stop();
      ref.read(notificationsPollingProvider.notifier).stop();
      ref.read(userProfilePollingProvider.notifier).stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(translationsLoadedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final ordersState = ref.watch(ordersProvider);

    debugPrint(
      '[OrdersScreen] build() -> '
      'isLoading=${ordersState.isLoading}, '
      'orders=${ordersState.orders.length}, '
      'current=${ordersState.currentOrders.length}, '
      'pending=${ordersState.pendingOrders.length}, '
      'active=${ordersState.activeOrders.length}, '
      'expired=${ordersState.expiredOrders.length}, '
      'error=${ordersState.error}',
    );

    final filteredCurrentOrders = switch (_currentOrdersFilter) {
      CurrentOrdersFilter.newOnly => ordersState.pendingOrders,
      CurrentOrdersFilter.activeOnly => ordersState.activeOrders,
      CurrentOrdersFilter.all => ordersState.currentOrders,
    };
    final currentEmptyMessage = switch (_currentOrdersFilter) {
      CurrentOrdersFilter.newOnly => 'orders.noPendingOrders'.tr,
      CurrentOrdersFilter.activeOnly => 'orders.noActiveOrders'.tr,
      CurrentOrdersFilter.all => 'orders.noCurrentOrders'.tr,
    };

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : LightColors.background,
      appBar: AppBar(
        title: Text('orders.title'.tr),
        centerTitle: true,
        backgroundColor: isDark
            ? DarkColors.background
            : LightColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: _isRefreshing
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: isDark
                          ? DarkColors.textPrimary
                          : LightColors.textSecondary,
                    ),
                  )
                : const Icon(Icons.refresh_rounded),
            onPressed: _isRefreshing ? null : _handleRefresh,
          ),
          IconButton(
            key: TourKeys.createOrderButtonKey,
            icon: const Icon(Icons.add),
            onPressed: () => context.push(Routes.createOrder),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: isDark
              ? DarkColors.textSecondary
              : LightColors.textSecondary,
          indicatorColor: primaryColor,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: Colors.transparent,
          tabs: [
            Tab(
              key: TourKeys.activeOrdersTabKey,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('orders.current'.tr),
                  if (ordersState.currentOrders.isNotEmpty) ...[
                    SizedBox(width: 4.w),
                    _TabBadge(count: ordersState.currentOrders.length),
                  ],
                ],
              ),
            ),
            Tab(
              key: TourKeys.pendingOrdersTabKey,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('orders.done'.tr),
                  if (ordersState.completedOrders.isNotEmpty) ...[
                    SizedBox(width: 4.w),
                    _TabBadge(count: ordersState.completedOrders.length),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('orders.expired'.tr),
                  if (ordersState.expiredOrders.isNotEmpty) ...[
                    SizedBox(width: 4.w),
                    _TabBadge(count: ordersState.expiredOrders.length),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: ordersState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      _searchDebounce?.cancel();
                      _searchDebounce = Timer(
                        const Duration(milliseconds: 300),
                        () {
                          ref
                              .read(ordersProvider.notifier)
                              .setSearchQuery(value);
                        },
                      );
                    },
                    decoration: InputDecoration(
                      hintText: 'orders.searchHint'.tr,
                      hintStyle: TextStyle(
                        color: isDark
                            ? DarkColors.textTertiary
                            : LightColors.textTertiary,
                        fontSize: 14.sp,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: isDark
                            ? DarkColors.textSecondary
                            : LightColors.textSecondary,
                        size: 20.w,
                      ),
                      suffixIcon: ordersState.searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear_rounded,
                                color: isDark
                                    ? DarkColors.textSecondary
                                    : LightColors.textSecondary,
                                size: 20.w,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                ref.read(ordersProvider.notifier).clearSearch();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: isDark
                          ? DarkColors.surface
                          : LightColors.surface,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: primaryColor, width: 1.5),
                      ),
                    ),
                    style: TextStyle(
                      color: isDark
                          ? DarkColors.textPrimary
                          : LightColors.textPrimary,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _CurrentOrdersTab(
                        orders: filteredCurrentOrders,
                        selectedFilter: _currentOrdersFilter,
                        onFilterSelected: (filter) {
                          setState(() => _currentOrdersFilter = filter);
                        },
                        isDark: isDark,
                        emptyMessage: ordersState.searchQuery.isNotEmpty
                            ? 'orders.noSearchResults'.tr
                            : currentEmptyMessage,
                      ),
                      _OrdersList(
                        key: TourKeys.activeOrdersListKey,
                        orders: ordersState.completedOrders,
                        isDark: isDark,
                        emptyMessage: ordersState.searchQuery.isNotEmpty
                            ? 'orders.noSearchResults'.tr
                            : 'orders.noCompletedOrders'.tr,
                      ),
                      _OrdersList(
                        orders: ordersState.expiredOrders,
                        isDark: isDark,
                        emptyMessage: ordersState.searchQuery.isNotEmpty
                            ? 'orders.noSearchResults'.tr
                            : 'orders.noExpiredOrders'.tr,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _CurrentOrdersTab extends StatelessWidget {
  const _CurrentOrdersTab({
    required this.orders,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.isDark,
    required this.emptyMessage,
  });

  final List<OrderModel> orders;
  final CurrentOrdersFilter selectedFilter;
  final ValueChanged<CurrentOrdersFilter> onFilterSelected;
  final bool isDark;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                _FilterChip(
                  label: 'orders.new'.tr,
                  isSelected: selectedFilter == CurrentOrdersFilter.newOnly,
                  isDark: isDark,
                  primaryColor: primaryColor,
                  onSelected: () =>
                      onFilterSelected(CurrentOrdersFilter.newOnly),
                ),
                _FilterChip(
                  label: 'orders.active'.tr,
                  isSelected: selectedFilter == CurrentOrdersFilter.activeOnly,
                  isDark: isDark,
                  primaryColor: primaryColor,
                  onSelected: () =>
                      onFilterSelected(CurrentOrdersFilter.activeOnly),
                ),
                _FilterChip(
                  label: 'orders.all'.tr,
                  isSelected: selectedFilter == CurrentOrdersFilter.all,
                  isDark: isDark,
                  primaryColor: primaryColor,
                  onSelected: () => onFilterSelected(CurrentOrdersFilter.all),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: _OrdersList(
            key: TourKeys.pendingOrdersListKey,
            orders: orders,
            isDark: isDark,
            emptyMessage: emptyMessage,
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.primaryColor,
    required this.onSelected,
  });

  final String label;
  final bool isSelected;
  final bool isDark;
  final Color primaryColor;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      labelStyle: TextStyle(
        color: isSelected
            ? Colors.white
            : (isDark ? DarkColors.textSecondary : LightColors.textSecondary),
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
      ),
      selectedColor: primaryColor,
      backgroundColor: isDark ? DarkColors.surface : LightColors.surface,
      side: BorderSide(
        color: isSelected
            ? primaryColor
            : (isDark ? DarkColors.border : LightColors.border),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999.r)),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
    );
  }
}

class _TabBadge extends StatelessWidget {
  const _TabBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _OrdersList extends StatelessWidget {
  const _OrdersList({
    super.key,
    required this.orders,
    required this.isDark,
    required this.emptyMessage,
  });

  final List<OrderModel> orders;
  final bool isDark;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64.w,
              color: isDark
                  ? DarkColors.textTertiary
                  : LightColors.textTertiary,
            ),
            SizedBox(height: 16.h),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark
                    ? DarkColors.textSecondary
                    : LightColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return RepaintBoundary(
          child: AnimatedOrderCard(
            key: index == 0 ? TourKeys.firstOrderCardKey : ValueKey(order.id),
            order: order,
            onTap: () => context.push(Routes.orderDetailsPath(order.id)),
          ),
        );
      },
    );
  }
}
