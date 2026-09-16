import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/theme.dart';
import '../../../orders/application/orders_notifier.dart';
import '../../../restaurant/application/restaurant_state.dart';

/// Statistics screen
class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translationsAsync = ref.watch(translationsLoadedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Wait for translations to load
    return translationsAsync.when(
      loading: () => Scaffold(
        backgroundColor: isDark ? DarkColors.background : LightColors.background,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => _buildContent(context, ref, isDark),
      data: (_) => _buildContent(context, ref, isDark),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, bool isDark) {
    // Get real data from restaurant and orders
    final selectedRestaurant = ref.watch(selectedRestaurantProvider);
    final ordersState = ref.watch(ordersProvider);

    // Calculate statistics from real data
    final stats = selectedRestaurant?.todayStats;
    final totalOrders = stats?.totalOrders ?? 0;
    final revenue = stats?.totalRevenue ?? 0.0;
    final avgOrder = totalOrders > 0 ? revenue / totalOrders : 0.0;

    // Count unique customers from orders
    final uniqueCustomers = ordersState.orders
        .map((order) => order.phoneNumber)
        .toSet()
        .length;

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : LightColors.background,
      appBar: AppBar(
        title: Text('statistics.title'.tr),
        backgroundColor: isDark ? DarkColors.background : LightColors.background,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: Breakpoints.maxContentWidth,
          ),
          child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Today's stats header
            Text(
              'statistics.today'.tr,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),

            // Stats grid with real data
            Row(
              children: [
                Expanded(child: _StatCard(title: 'statistics.totalOrders'.tr, value: '$totalOrders', icon: Icons.receipt_long_outlined, color: Theme.of(context).colorScheme.primary, isDark: isDark)),
                SizedBox(width: 12.w),
                Expanded(child: _StatCard(title: 'statistics.revenue'.tr, value: '€${revenue.toStringAsFixed(0)}', icon: Icons.euro, color: AppColors.success, isDark: isDark)),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(child: _StatCard(title: 'statistics.avgOrder'.tr, value: '€${avgOrder.toStringAsFixed(2)}', icon: Icons.trending_up, color: AppColors.info, isDark: isDark)),
                SizedBox(width: 12.w),
                Expanded(child: _StatCard(title: 'statistics.customers'.tr, value: '$uniqueCustomers', icon: Icons.people_outline, color: AppColors.warning, isDark: isDark)),
              ],
            ),
          ],
        ),
      ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : LightColors.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24.w),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
