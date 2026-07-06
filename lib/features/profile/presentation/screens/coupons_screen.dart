import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/theme.dart';
import '../../../coupons/application/coupons_notifier.dart';
import '../../../coupons/data/models/coupon_model.dart';

/// Coupons management screen with filters and CRUD functionality
class CouponsScreen extends ConsumerWidget {
  const CouponsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(translationsLoadedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final couponsState = ref.watch(couponsProvider);
    final filteredCoupons = couponsState.filteredCoupons;

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : LightColors.background,
      appBar: AppBar(
        title: Text('coupons.title'.tr),
        backgroundColor: isDark
            ? DarkColors.background
            : LightColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/coupons/add'),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: Breakpoints.maxContentWidth,
          ),
          child: Column(
        children: [
          // Filter chips
          _FilterSection(
            currentFilter: couponsState.filter,
            activeCount: couponsState.activeCount,
            expiredCount: couponsState.expiredCount,
            totalCount: couponsState.coupons.length,
            onFilterChanged: (filter) {
              ref.read(couponsProvider.notifier).setFilter(filter);
            },
          ),

          // Coupons list
          Expanded(
            child: couponsState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredCoupons.isEmpty
                ? _EmptyState(filter: couponsState.filter, isDark: isDark)
                : RefreshIndicator(
                    onRefresh: () =>
                        ref.read(couponsProvider.notifier).refresh(),
                    child: ListView.builder(
                      padding: EdgeInsets.all(16.w),
                      itemCount: filteredCoupons.length,
                      itemBuilder: (context, index) {
                        final coupon = filteredCoupons[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: _CouponCard(
                            coupon: coupon,
                            isDark: isDark,
                            onTap: () =>
                                context.push('/coupons/edit/${coupon.id}'),
                            onToggle: () {
                              ref
                                  .read(couponsProvider.notifier)
                                  .toggleCouponStatus(coupon.id);
                            },
                            onDelete: () =>
                                _showDeleteDialog(context, ref, coupon),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/coupons/add'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'coupons.addCoupon'.tr,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    CouponModel coupon,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${'common.delete'.tr} ${'coupons.title'.tr}?'),
        content: Text('couponsFilter.deleteConfirmText'.tr.replaceAll('{code}', coupon.code)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(couponsProvider.notifier).deleteCoupon(coupon.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('coupons.couponDeleted'.tr)),
              );
            },
            child: Text(
              'common.delete'.tr,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.currentFilter,
    required this.activeCount,
    required this.expiredCount,
    required this.totalCount,
    required this.onFilterChanged,
  });

  final CouponFilter currentFilter;
  final int activeCount;
  final int expiredCount;
  final int totalCount;
  final ValueChanged<CouponFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          _FilterChip(
            label: 'couponsFilter.all'.trParams({'count': totalCount.toString()}),
            isSelected: currentFilter == CouponFilter.all,
            onTap: () => onFilterChanged(CouponFilter.all),
            isDark: isDark,
          ),
          SizedBox(width: 8.w),
          _FilterChip(
            label: 'couponsFilter.active'.trParams({'count': activeCount.toString()}),
            isSelected: currentFilter == CouponFilter.active,
            onTap: () => onFilterChanged(CouponFilter.active),
            isDark: isDark,
            color: AppColors.success,
          ),
          SizedBox(width: 8.w),
          _FilterChip(
            label: 'couponsFilter.expired'.trParams({'count': expiredCount.toString()}),
            isSelected: currentFilter == CouponFilter.expired,
            onTap: () => onFilterChanged(CouponFilter.expired),
            isDark: isDark,
            color: AppColors.error,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
    this.color,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.1)
              : (isDark ? DarkColors.surface : LightColors.surface),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? activeColor
                : (isDark ? DarkColors.border : LightColors.border),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? activeColor
                : (isDark
                      ? DarkColors.textSecondary
                      : LightColors.textSecondary),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filter, required this.isDark});

  final CouponFilter filter;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    String message;
    IconData icon;

    switch (filter) {
      case CouponFilter.active:
        message = 'couponsFilter.noActiveCoupons'.tr;
        icon = Icons.check_circle_outline;
        break;
      case CouponFilter.expired:
        message = 'couponsFilter.noExpiredCoupons'.tr;
        icon = Icons.timer_off_outlined;
        break;
      case CouponFilter.all:
        message = 'couponsFilter.noCouponsYet'.tr;
        icon = Icons.local_offer_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64.w,
            color: isDark ? DarkColors.textTertiary : LightColors.textTertiary,
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 16.sp,
              color: isDark
                  ? DarkColors.textSecondary
                  : LightColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'couponsFilter.tapToCreate'.tr,
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark
                  ? DarkColors.textTertiary
                  : LightColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CouponCard extends StatelessWidget {
  const _CouponCard({
    required this.coupon,
    required this.isDark,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  final CouponModel coupon;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final isValid = coupon.isValid;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? DarkColors.surface : LightColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isValid
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                : (isDark ? DarkColors.border : LightColors.border),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Code badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: isValid
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                        : (isDark
                              ? DarkColors.backgroundTertiary
                              : LightColors.backgroundTertiary),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    coupon.code,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: isValid
                          ? Theme.of(context).colorScheme.primary
                          : (isDark
                                ? DarkColors.textSecondary
                                : LightColors.textSecondary),
                    ),
                  ),
                ),
                // Discount
                Text(
                  coupon.discountText,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: isValid
                        ? AppColors.success
                        : (isDark
                              ? DarkColors.textSecondary
                              : LightColors.textSecondary),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Title
            Text(
              coupon.title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? DarkColors.textPrimary
                    : LightColors.textPrimary,
              ),
            ),

            // Description
            if (coupon.description != null &&
                coupon.description!.isNotEmpty) ...[
              SizedBox(height: 4.h),
              Text(
                coupon.description!,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDark
                      ? DarkColors.textSecondary
                      : LightColors.textSecondary,
                ),
              ),
            ],
            SizedBox(height: 12.h),

            // Stats row
            Row(
              children: [
                _StatBadge(
                  icon: Icons.calendar_today,
                  label: coupon.isExpired
                      ? 'Expired'
                      : 'Until ${dateFormat.format(coupon.endDate)}',
                  color: coupon.isExpired ? AppColors.error : null,
                  isDark: isDark,
                ),
                SizedBox(width: 12.w),
                if (coupon.minimumOrderPrice > 0)
                  _StatBadge(
                    icon: Icons.euro,
                    label: 'Min ${coupon.minimumOrderPrice.toStringAsFixed(0)}',
                    isDark: isDark,
                  ),
                const Spacer(),
                // Usage count
                if (coupon.maxTotalUsage != null)
                  Text(
                    '${coupon.currentUsageCount}/${coupon.maxTotalUsage}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark
                          ? DarkColors.textTertiary
                          : LightColors.textTertiary,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12.h),

            // Actions row
            Row(
              children: [
                // Status badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: (isValid ? AppColors.success : AppColors.error)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    coupon.statusText,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: isValid ? AppColors.success : AppColors.error,
                    ),
                  ),
                ),
                const Spacer(),
                // Toggle button
                IconButton(
                  onPressed: onToggle,
                  icon: Icon(
                    coupon.isActive
                        ? Icons.pause_circle_outline
                        : Icons.play_circle_outline,
                    color: coupon.isActive
                        ? AppColors.warning
                        : AppColors.success,
                  ),
                  tooltip: coupon.isActive ? 'Deactivate' : 'Activate',
                ),
                // Delete button
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline, color: AppColors.error),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.icon,
    required this.label,
    required this.isDark,
    this.color,
  });

  final IconData icon;
  final String label;
  final bool isDark;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final textColor =
        color ?? (isDark ? DarkColors.textTertiary : LightColors.textTertiary);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.w, color: textColor),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: textColor),
        ),
      ],
    );
  }
}
