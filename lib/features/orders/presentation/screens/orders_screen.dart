import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';
import '../../../tour/utils/tour_keys.dart';
import '../../application/orders_notifier.dart';
import '../../data/models/order_model.dart';
import '../widgets/animated_order_card.dart';

/// Orders screen
class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  final _searchController = TextEditingController();
  bool _isRefreshing = false;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addObserver(this);

    // Start polling when screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ordersPollingProvider.notifier).start();
    });
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
    // Stop polling when screen is disposed
    ref.read(ordersPollingProvider.notifier).stop();
    WidgetsBinding.instance.removeObserver(this);
    _searchDebounce?.cancel();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pause polling when app is in background, resume when in foreground
    final pollingNotifier = ref.read(ordersPollingProvider.notifier);
    if (state == AppLifecycleState.resumed) {
      pollingNotifier.start();
    } else if (state == AppLifecycleState.paused) {
      pollingNotifier.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(translationsLoadedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final ordersState = ref.watch(ordersProvider);

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
                      color: isDark ? DarkColors.textPrimary : LightColors.textSecondary,
                    ),
                  )
                : const Icon(Icons.refresh_rounded),
            onPressed: _isRefreshing ? null : _handleRefresh,
          ),
          IconButton(
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
              key: TourKeys.pendingOrdersTabKey,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('orders.new'.tr),
                  if (ordersState.pendingOrders.isNotEmpty) ...[
                    SizedBox(width: 4.w),
                    _TabBadge(count: ordersState.pendingOrders.length),
                  ],
                ],
              ),
            ),
            Tab(
              key: TourKeys.activeOrdersTabKey,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('orders.active'.tr),
                  if (ordersState.activeOrders.isNotEmpty) ...[
                    SizedBox(width: 4.w),
                    _TabBadge(count: ordersState.activeOrders.length),
                  ],
                ],
              ),
            ),
            Tab(text: 'orders.done'.tr),
          ],
        ),
      ),
      body: ordersState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search bar
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      // Debounce search to avoid filtering on every keystroke
                      _searchDebounce?.cancel();
                      _searchDebounce = Timer(const Duration(milliseconds: 300), () {
                        ref.read(ordersProvider.notifier).setSearchQuery(value);
                      });
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
                        borderSide: BorderSide(
                          color: primaryColor,
                          width: 1.5,
                        ),
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
                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _OrdersList(
                        key: TourKeys.pendingOrdersListKey,
                        orders: ordersState.pendingOrders,
                        isDark: isDark,
                        emptyMessage: ordersState.searchQuery.isNotEmpty
                            ? 'orders.noSearchResults'.tr
                            : 'orders.noPendingOrders'.tr,
                      ),
                      _OrdersList(
                        key: TourKeys.activeOrdersListKey,
                        orders: ordersState.activeOrders,
                        isDark: isDark,
                        emptyMessage: ordersState.searchQuery.isNotEmpty
                            ? 'orders.noSearchResults'.tr
                            : 'orders.noActiveOrders'.tr,
                      ),
                      _OrdersList(
                        orders: ordersState.completedOrders,
                        isDark: isDark,
                        emptyMessage: ordersState.searchQuery.isNotEmpty
                            ? 'orders.noSearchResults'.tr
                            : 'orders.noCompletedOrders'.tr,
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
    Key? key,
    required this.orders,
    required this.isDark,
    required this.emptyMessage,
  }) : super(key: key);

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
              color: isDark ? DarkColors.textTertiary : LightColors.textTertiary,
            ),
            SizedBox(height: 16.h),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: orders.length,
      // Use itemExtent for better performance if cards have fixed height
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
