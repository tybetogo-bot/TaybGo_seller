import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';
import '../../data/models/order_model.dart';

/// Order status timeline widget showing the progression of order status
class OrderStatusTimeline extends StatelessWidget {
  const OrderStatusTimeline({
    super.key,
    required this.currentStatus,
    this.acceptedAt,
    this.readyAt,
    this.outForDeliveryAt,
    this.deliveredAt,
  });

  final OrderStatusEnum currentStatus;
  final DateTime? acceptedAt;
  final DateTime? readyAt;
  final DateTime? outForDeliveryAt;
  final DateTime? deliveredAt;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Full order flow: Pending → Searching → Driver Notified → Accepted → On the Way → Delivered → Completed
    final steps = [
      _TimelineStep(
        status: OrderStatusEnum.pending,
        label: 'orders.status.pending'.tr,
        icon: Icons.hourglass_empty,
        isCompleted: _isCompleted(OrderStatusEnum.pending),
        isCurrent: currentStatus == OrderStatusEnum.pending,
        timestamp: null,
      ),
      _TimelineStep(
        status: OrderStatusEnum.searchingForDriver,
        label: 'orders.status.searchingForDriver'.tr,
        icon: Icons.search,
        isCompleted: _isCompleted(OrderStatusEnum.searchingForDriver),
        isCurrent: currentStatus == OrderStatusEnum.searchingForDriver,
        timestamp: null,
      ),
      _TimelineStep(
        status: OrderStatusEnum.driverNotificationSent,
        label: 'orders.status.driverNotificationSent'.tr,
        icon: Icons.notifications_active,
        isCompleted: _isCompleted(OrderStatusEnum.driverNotificationSent),
        isCurrent: currentStatus == OrderStatusEnum.driverNotificationSent,
        timestamp: null,
      ),
      _TimelineStep(
        status: OrderStatusEnum.accepted,
        label: 'orders.status.accepted'.tr,
        icon: Icons.check_circle_outline,
        isCompleted: _isCompleted(OrderStatusEnum.accepted),
        isCurrent: currentStatus == OrderStatusEnum.accepted,
        timestamp: acceptedAt,
      ),
      _TimelineStep(
        status: OrderStatusEnum.onTheWay,
        label: 'orders.status.onTheWay'.tr,
        icon: Icons.local_shipping_outlined,
        isCompleted: _isCompleted(OrderStatusEnum.onTheWay),
        isCurrent: currentStatus == OrderStatusEnum.onTheWay,
        timestamp: outForDeliveryAt,
      ),
      _TimelineStep(
        status: OrderStatusEnum.delivered,
        label: 'orders.status.delivered'.tr,
        icon: Icons.done_all,
        isCompleted: _isCompleted(OrderStatusEnum.delivered),
        isCurrent: currentStatus == OrderStatusEnum.delivered,
        timestamp: deliveredAt,
      ),
      _TimelineStep(
        status: OrderStatusEnum.completed,
        label: 'orders.status.completed'.tr,
        icon: Icons.verified,
        isCompleted: _isCompleted(OrderStatusEnum.completed),
        isCurrent: currentStatus == OrderStatusEnum.completed,
        timestamp: null,
      ),
    ];

    // Handle rejected/cancelled status
    if (currentStatus == OrderStatusEnum.rejected ||
        currentStatus == OrderStatusEnum.cancelled) {
      return _RejectedStatusCard(
        status: currentStatus,
        isDark: isDark,
      );
    }

    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline indicator
            Column(
              children: [
                _StatusDot(
                  isCompleted: step.isCompleted,
                  isCurrent: step.isCurrent,
                ),
                if (!isLast)
                  _TimelineLine(
                    isCompleted: step.isCompleted && !step.isCurrent,
                    isDark: isDark,
                  ),
              ],
            ),
            SizedBox(width: 12.w),

            // Step content
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          step.icon,
                          size: 18.w,
                          color: step.isCompleted || step.isCurrent
                              ? AppColors.primary
                              : (isDark ? DarkColors.textTertiary : LightColors.textTertiary),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          step.label,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: step.isCurrent ? FontWeight.w600 : FontWeight.w500,
                            color: step.isCompleted || step.isCurrent
                                ? (isDark ? DarkColors.textPrimary : LightColors.textPrimary)
                                : (isDark ? DarkColors.textTertiary : LightColors.textTertiary),
                          ),
                        ),
                        if (step.isCurrent) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              'Current',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (step.timestamp != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        _formatTimestamp(step.timestamp!),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDark ? DarkColors.textTertiary : LightColors.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  bool _isCompleted(OrderStatusEnum status) {
    // Full flow: Pending → Searching → Driver Notified → Accepted → On the Way → Delivered → Completed
    final statusOrder = [
      OrderStatusEnum.pending,
      OrderStatusEnum.searchingForDriver,
      OrderStatusEnum.driverNotificationSent,
      OrderStatusEnum.accepted,
      OrderStatusEnum.onTheWay,
      OrderStatusEnum.delivered,
      OrderStatusEnum.completed,
    ];

    // Get timeline index for any status
    int getTimelineIndex(OrderStatusEnum s) {
      switch (s) {
        case OrderStatusEnum.pending:
          return 0;
        case OrderStatusEnum.searchingForDriver:
          return 1;
        case OrderStatusEnum.driverNotificationSent:
          return 2;
        case OrderStatusEnum.accepted:
          return 3;
        case OrderStatusEnum.onTheWay:
          return 4;
        case OrderStatusEnum.delivered:
          return 5;
        case OrderStatusEnum.completed:
          return 6;
        case OrderStatusEnum.rejected:
        case OrderStatusEnum.cancelled:
          return -1;
      }
    }

    final currentIndex = getTimelineIndex(currentStatus);
    final statusIndex = statusOrder.indexOf(status);

    return statusIndex <= currentIndex;
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) {
      return 'time.justNow'.tr;
    } else if (diff.inMinutes < 60) {
      return 'time.minutesAgo'.tr.replaceAll('{minutes}', diff.inMinutes.toString());
    } else if (diff.inHours < 24) {
      return 'time.hoursAgo'.tr.replaceAll('{hours}', diff.inHours.toString());
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}

class _TimelineStep {
  const _TimelineStep({
    required this.status,
    required this.label,
    required this.icon,
    required this.isCompleted,
    required this.isCurrent,
    this.timestamp,
  });

  final OrderStatusEnum status;
  final String label;
  final IconData icon;
  final bool isCompleted;
  final bool isCurrent;
  final DateTime? timestamp;
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({
    required this.isCompleted,
    required this.isCurrent,
  });

  final bool isCompleted;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 24.w,
      height: 24.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted || isCurrent
            ? AppColors.primary
            : (isDark ? DarkColors.backgroundSecondary : LightColors.backgroundSecondary),
        border: Border.all(
          color: isCompleted || isCurrent
              ? AppColors.primary
              : (isDark ? DarkColors.border : LightColors.border),
          width: 2,
        ),
      ),
      child: isCompleted && !isCurrent
          ? Icon(
              Icons.check,
              size: 14.w,
              color: Colors.white,
            )
          : isCurrent
              ? Container(
                  margin: EdgeInsets.all(4.w),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                )
              : null,
    );
  }
}

class _TimelineLine extends StatelessWidget {
  const _TimelineLine({
    required this.isCompleted,
    required this.isDark,
  });

  final bool isCompleted;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 2.w,
      height: 40.h,
      color: isCompleted
          ? AppColors.primary
          : (isDark ? DarkColors.border : LightColors.border),
    );
  }
}

class _RejectedStatusCard extends StatelessWidget {
  const _RejectedStatusCard({
    required this.status,
    required this.isDark,
  });

  final OrderStatusEnum status;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final isRejected = status == OrderStatusEnum.rejected;
    final color = isRejected ? AppColors.error : AppColors.warning;
    final icon = isRejected ? Icons.cancel : Icons.block;
    final label = isRejected ? 'orders.status.rejected'.tr : 'orders.status.cancelled'.tr;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'orders.orderLabel'.tr.replaceAll('{status}', label),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  isRejected
                      ? 'orders.orderRejectedByRestaurant'.tr
                      : 'orders.orderWasCancelled'.tr,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Order action buttons based on current status
class OrderActionButtons extends StatelessWidget {
  const OrderActionButtons({
    super.key,
    required this.currentStatus,
    required this.onUpdateStatus,
    this.isLoading = false,
  });

  final OrderStatusEnum currentStatus;
  final VoidCallback onUpdateStatus;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    // Flow: Pending → Searching → Driver Notified → Accepted → On the Way → Delivered → Completed
    // Terminal statuses - no action buttons
    if (currentStatus == OrderStatusEnum.completed ||
        currentStatus == OrderStatusEnum.rejected ||
        currentStatus == OrderStatusEnum.cancelled) {
      return const SizedBox.shrink();
    }

    // Active statuses - show Update Status button
    final nextStatus = currentStatus.nextStatus;
    if (nextStatus == null) return const SizedBox.shrink();

    return _ActionButton(
      label: 'orders.updateStatus'.tr,
      icon: Icons.arrow_forward,
      color: AppColors.primary,
      onPressed: isLoading ? null : onUpdateStatus,
      isLoading: isLoading,
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.isOutlined = false,
    this.isLoading = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  final bool isOutlined;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48.h,
      child: isOutlined
          ? OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: 18.w),
              label: Text(label),
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            )
          : ElevatedButton.icon(
              onPressed: onPressed,
              icon: isLoading
                  ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(icon, size: 18.w),
              label: Text(label),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
    );
  }
}
