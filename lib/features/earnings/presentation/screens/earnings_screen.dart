/// Earnings screen for viewing seller earnings
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/theme.dart';
import '../../application/earnings_notifier.dart';
import '../../data/models/earning_model.dart';

/// Earnings screen
class EarningsScreen extends ConsumerStatefulWidget {
  const EarningsScreen({super.key});

  @override
  ConsumerState<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends ConsumerState<EarningsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(earningsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final earningsState = ref.watch(earningsProvider);

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : LightColors.background,
      appBar: AppBar(
        title: Text('earnings.title'.tr),
        backgroundColor: isDark
            ? DarkColors.background
            : LightColors.background,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: Breakpoints.maxWideContentWidth,
          ),
          child: RefreshIndicator(
            onRefresh: () => ref.read(earningsProvider.notifier).refreshEarnings(),
            child: Column(
              children: [
                // Date filter chips
                _DateFilterBar(isDark: isDark),
                // Summary cards
                if (!earningsState.isLoading || earningsState.earnings.isNotEmpty)
                  _SummarySection(summary: earningsState.summary, isDark: isDark),
                // Earnings list
                Expanded(child: _buildBody(earningsState, isDark)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(EarningsState earningsState, bool isDark) {
    if (earningsState.isLoading && earningsState.earnings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (earningsState.error != null && earningsState.earnings.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48.w, color: AppColors.error),
              SizedBox(height: 16.h),
              Text(
                earningsState.error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDark
                      ? DarkColors.textSecondary
                      : LightColors.textSecondary,
                ),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () =>
                    ref.read(earningsProvider.notifier).refreshEarnings(),
                child: Text('common.retry'.tr),
              ),
            ],
          ),
        ),
      );
    }

    if (earningsState.earnings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 64.w,
              color: isDark
                  ? DarkColors.textTertiary
                  : LightColors.textTertiary,
            ),
            SizedBox(height: 16.h),
            Text(
              'earnings.empty'.tr,
              style: TextStyle(
                fontSize: 16.sp,
                color: isDark
                    ? DarkColors.textSecondary
                    : LightColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      itemCount:
          earningsState.earnings.length + (earningsState.hasMorePages ? 1 : 0),
      separatorBuilder: (_, _) => SizedBox(height: 8.h),
      itemBuilder: (context, index) {
        if (index >= earningsState.earnings.length) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        return _EarningItemCard(
          item: earningsState.earnings[index],
          isDark: isDark,
        );
      },
    );
  }
}

/// Date filter bar
class _DateFilterBar extends ConsumerWidget {
  const _DateFilterBar({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(
      earningsProvider.select((s) => s.dateFilter),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          _FilterChip(
            label: 'earnings.filter.today'.tr,
            isSelected: currentFilter == EarningsDateFilter.today,
            onTap: () => ref
                .read(earningsProvider.notifier)
                .setDateFilter(EarningsDateFilter.today),
            isDark: isDark,
          ),
          SizedBox(width: 8.w),
          _FilterChip(
            label: 'earnings.filter.thisWeek'.tr,
            isSelected: currentFilter == EarningsDateFilter.thisWeek,
            onTap: () => ref
                .read(earningsProvider.notifier)
                .setDateFilter(EarningsDateFilter.thisWeek),
            isDark: isDark,
          ),
          SizedBox(width: 8.w),
          _FilterChip(
            label: 'earnings.filter.thisMonth'.tr,
            isSelected: currentFilter == EarningsDateFilter.thisMonth,
            onTap: () => ref
                .read(earningsProvider.notifier)
                .setDateFilter(EarningsDateFilter.thisMonth),
            isDark: isDark,
          ),
          SizedBox(width: 8.w),
          _FilterChip(
            label: 'earnings.filter.custom'.tr,
            isSelected: currentFilter == EarningsDateFilter.custom,
            onTap: () => _showDateRangePicker(context, ref),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Future<void> _showDateRangePicker(BuildContext context, WidgetRef ref) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final onSurface = isDark ? DarkColors.textPrimary : LightColors.textPrimary;
    final inRangeText = isDark
        ? DarkColors.textPrimary
        : LightColors.textPrimary;
    final disabledText = isDark
        ? DarkColors.textDisabled
        : LightColors.textDisabled;
    final rangeFill = primary.withValues(alpha: isDark ? 0.24 : 0.14);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      keyboardType: TextInputType.text,
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: primary,
              onPrimary: AppColors.white,
              secondaryContainer: rangeFill,
              onSecondaryContainer: inRangeText,
              surface: isDark ? DarkColors.surface : LightColors.surface,
              onSurface: onSurface,
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: isDark
                  ? DarkColors.surface
                  : LightColors.surface,
              rangePickerBackgroundColor: isDark
                  ? DarkColors.surface
                  : LightColors.surface,
              rangePickerHeaderBackgroundColor: isDark
                  ? DarkColors.surface
                  : LightColors.surface,
              rangePickerHeaderForegroundColor: onSurface,
              headerBackgroundColor: isDark
                  ? DarkColors.surface
                  : LightColors.surface,
              headerForegroundColor: onSurface,
              rangeSelectionBackgroundColor: rangeFill,
              rangeSelectionOverlayColor: WidgetStateProperty.all(
                primary.withValues(alpha: 0.08),
              ),
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return disabledText;
                }
                if (states.contains(WidgetState.selected)) {
                  return AppColors.white;
                }
                return onSurface;
              }),
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return primary;
                }
                return Colors.transparent;
              }),
              todayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.white;
                }
                return primary;
              }),
              todayBorder: BorderSide(color: primary),
              weekdayStyle: TextStyle(
                color: onSurface,
                fontWeight: FontWeight.w700,
              ),
              yearForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return disabledText;
                }
                if (states.contains(WidgetState.selected)) {
                  return AppColors.white;
                }
                return onSurface;
              }),
              yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return primary;
                }
                return Colors.transparent;
              }),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      ref
          .read(earningsProvider.notifier)
          .setCustomDateRange(picked.start, picked.end);
    }
  }
}

/// Individual filter chip
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? primary
              : (isDark ? DarkColors.surface : LightColors.surface),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? primary
                : (isDark ? DarkColors.border : LightColors.border),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? Colors.white
                : (isDark
                      ? DarkColors.textSecondary
                      : LightColors.textSecondary),
          ),
        ),
      ),
    );
  }
}

/// Summary section with stat cards
class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.summary, required this.isDark});

  final EarningsSummary summary;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
      child: Column(
        children: [
          // Total earnings highlight card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary, primary.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'earnings.totalEarnings'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '€${summary.totalEarnings.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          // Stat row
          Row(
            children: [
              Expanded(
                child: _MiniStatCard(
                  label: 'earnings.orders'.tr,
                  value: '${summary.totalOrders}',
                  icon: Icons.receipt_long_outlined,
                  isDark: isDark,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _MiniStatCard(
                  label: 'earnings.subtotal'.tr,
                  value: '€${summary.grossSubtotal.toStringAsFixed(2)}',
                  icon: Icons.euro,
                  isDark: isDark,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _MiniStatCard(
                  label: 'earnings.discounts'.tr,
                  value: '€${summary.totalDiscounts.toStringAsFixed(2)}',
                  icon: Icons.discount_outlined,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Mini stat card for the summary row
class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.isDark,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : LightColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? DarkColors.border : LightColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18.w,
            color: isDark ? DarkColors.textTertiary : LightColors.textTertiary,
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: isDark
                  ? DarkColors.textTertiary
                  : LightColors.textTertiary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Earning item card
class _EarningItemCard extends StatelessWidget {
  const _EarningItemCard({required this.item, required this.isDark});

  final EarningItem item;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy - hh:mm a');
    final formattedDate = item.earnedAt != null
        ? dateFormat.format(item.earnedAt!)
        : '-';

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : LightColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? DarkColors.border : LightColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: restaurant name + earning amount
          Row(
            children: [
              Expanded(
                child: Text(
                  item.restaurantName,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? DarkColors.textPrimary
                        : LightColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '€${item.earningAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // Order info row
          Row(
            children: [
              _InfoTag(
                icon: Icons.tag,
                text: '#${item.orderId}',
                isDark: isDark,
              ),
              SizedBox(width: 8.w),
              _InfoTag(
                icon: Icons.payment,
                text: item.paymentType,
                isDark: isDark,
              ),
              SizedBox(width: 8.w),
              _StatusBadge(isPaid: item.isPaid),
              if (item.couponApplied) ...[
                SizedBox(width: 8.w),
                Icon(Icons.local_offer, size: 14.w, color: AppColors.warning),
              ],
            ],
          ),
          SizedBox(height: 8.h),
          // Bottom row: date + subtotal/discount
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 14.w,
                color: isDark
                    ? DarkColors.textTertiary
                    : LightColors.textTertiary,
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark
                        ? DarkColors.textTertiary
                        : LightColors.textTertiary,
                  ),
                ),
              ),
              if (item.discountAmount > 0)
                Text(
                  '-€${item.discountAmount.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 12.sp, color: AppColors.error),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Small info tag widget
class _InfoTag extends StatelessWidget {
  const _InfoTag({
    required this.icon,
    required this.text,
    required this.isDark,
  });

  final IconData icon;
  final String text;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 13.w,
          color: isDark ? DarkColors.textTertiary : LightColors.textTertiary,
        ),
        SizedBox(width: 3.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 12.sp,
            color: isDark
                ? DarkColors.textSecondary
                : LightColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Paid/unpaid status badge
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isPaid});

  final bool isPaid;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isPaid ? AppColors.successLight : AppColors.warningLight,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        isPaid ? 'earnings.paid'.tr : 'earnings.unpaid'.tr,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: isPaid ? AppColors.successDark : AppColors.warningDark,
        ),
      ),
    );
  }
}
