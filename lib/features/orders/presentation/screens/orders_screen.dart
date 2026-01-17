import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';
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
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(translationsLoadedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            icon: const Icon(Icons.add),
            onPressed: () => context.push(Routes.createOrder),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark
              ? DarkColors.textSecondary
              : LightColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: Colors.transparent,
          tabs: [
            Tab(
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
          : TabBarView(
              controller: _tabController,
              children: [
                _OrdersList(
                  orders: ordersState.pendingOrders,
                  isDark: isDark,
                  emptyMessage: 'orders.noPendingOrders'.tr,
                ),
                _OrdersList(
                  orders: ordersState.activeOrders,
                  isDark: isDark,
                  emptyMessage: 'orders.noActiveOrders'.tr,
                ),
                _OrdersList(
                  orders: ordersState.completedOrders,
                  isDark: isDark,
                  emptyMessage: 'orders.noCompletedOrders'.tr,
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
        color: AppColors.primary,
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

    return AnimatedList(
      key: ValueKey(orders.length),
      initialItemCount: orders.length,
      padding: EdgeInsets.all(16.w),
      itemBuilder: (context, index, animation) {
        if (index >= orders.length) return const SizedBox.shrink();
        
        final order = orders[index];
        return SlideTransition(
          position: animation.drive(
            Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic)),
          ),
          child: FadeTransition(
            opacity: animation,
            child: AnimatedOrderCard(
              key: ValueKey(order.id),
              order: order,
              onTap: () => context.push(Routes.orderDetailsPath(order.id)),
            ),
          ),
        );
      },
    );
  }
}
