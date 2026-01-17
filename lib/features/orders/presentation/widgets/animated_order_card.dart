import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';
import '../../application/orders_notifier.dart';
import '../../data/models/order_model.dart';

/// Minimal order card with clean design
class AnimatedOrderCard extends ConsumerStatefulWidget {
  const AnimatedOrderCard({
    super.key,
    required this.order,
    required this.onTap,
    this.compact = false,
  });

  final OrderModel order;
  final VoidCallback onTap;
  final bool compact;

  @override
  ConsumerState<AnimatedOrderCard> createState() => _AnimatedOrderCardState();
}

class _AnimatedOrderCardState extends ConsumerState<AnimatedOrderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleMoveToNextStatus() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    HapticFeedback.mediumImpact();
    await _controller.forward();

    final success = await ref
        .read(ordersProvider.notifier)
        .moveToNextStatus(widget.order.id);

    if (success && mounted) {
      final nextStatus = widget.order.status.nextStatus;
      if (nextStatus != null) {
        _showSuccessSnackBar('orders.statusUpdatedTo'.tr.replaceAll('{status}', _getStatusLabel(nextStatus)));
      }
    }

    if (mounted) {
      await _controller.reverse();
      setState(() => _isProcessing = false);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getStatusLabel(OrderStatusEnum status) {
    switch (status) {
      case OrderStatusEnum.pending:
        return 'orders.status.pending'.tr;
      case OrderStatusEnum.searchingForDriver:
        return 'orders.status.searchingForDriver'.tr;
      case OrderStatusEnum.driverNotificationSent:
        return 'orders.status.driverNotificationSent'.tr;
      case OrderStatusEnum.accepted:
        return 'orders.status.accepted'.tr;
      case OrderStatusEnum.onTheWay:
        return 'orders.status.onTheWay'.tr;
      case OrderStatusEnum.delivered:
        return 'orders.status.delivered'.tr;
      case OrderStatusEnum.completed:
        return 'orders.status.completed'.tr;
      case OrderStatusEnum.rejected:
        return 'orders.status.rejected'.tr;
      case OrderStatusEnum.cancelled:
        return 'orders.status.cancelled'.tr;
    }
  }

  String _getShortStatus(OrderStatusEnum status) {
    switch (status) {
      case OrderStatusEnum.pending:
        return 'orders.statusShort.pending'.tr;
      case OrderStatusEnum.searchingForDriver:
        return 'orders.statusShort.searching'.tr;
      case OrderStatusEnum.driverNotificationSent:
        return 'orders.statusShort.notified'.tr;
      case OrderStatusEnum.accepted:
        return 'orders.statusShort.accepted'.tr;
      case OrderStatusEnum.onTheWay:
        return 'orders.statusShort.onTheWay'.tr;
      case OrderStatusEnum.delivered:
        return 'orders.statusShort.delivered'.tr;
      case OrderStatusEnum.completed:
        return 'orders.statusShort.done'.tr;
      case OrderStatusEnum.rejected:
      case OrderStatusEnum.cancelled:
        return status == OrderStatusEnum.rejected ? 'Rejected' : 'Cancelled';
    }
  }

  String _getTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) {
      return 'time.justNow'.tr;
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h';
    } else {
      return '${diff.inDays}d';
    }
  }

  int _getItemsCount(OrderModel order) {
    return order.items.fold(0, (sum, item) => sum + item.quantity);
  }

  double _getProgress(OrderStatusEnum status) {
    switch (status) {
      case OrderStatusEnum.pending:
        return 0.0;
      case OrderStatusEnum.searchingForDriver:
        return 0.15;
      case OrderStatusEnum.driverNotificationSent:
        return 0.35;
      case OrderStatusEnum.accepted:
        return 0.5;
      case OrderStatusEnum.onTheWay:
        return 0.75;
      case OrderStatusEnum.delivered:
        return 0.9;
      case OrderStatusEnum.completed:
        return 1.0;
      case OrderStatusEnum.rejected:
      case OrderStatusEnum.cancelled:
        return 0.0;
    }
  }

  Color _getStatusColor(OrderStatusEnum status) {
    switch (status) {
      case OrderStatusEnum.pending:
        return AppColors.warning;
      case OrderStatusEnum.searchingForDriver:
        return Colors.orange;
      case OrderStatusEnum.driverNotificationSent:
        return Colors.orange;
      case OrderStatusEnum.accepted:
        return AppColors.info;
      case OrderStatusEnum.onTheWay:
        return Colors.purple;
      case OrderStatusEnum.delivered:
        return AppColors.success;
      case OrderStatusEnum.completed:
        return AppColors.success;
      case OrderStatusEnum.rejected:
      case OrderStatusEnum.cancelled:
        return AppColors.error;
    }
  }

  IconData _getStatusIcon(OrderStatusEnum status) {
    switch (status) {
      case OrderStatusEnum.pending:
        return Icons.schedule;
      case OrderStatusEnum.searchingForDriver:
        return Icons.search;
      case OrderStatusEnum.driverNotificationSent:
        return Icons.notifications_active_outlined;
      case OrderStatusEnum.accepted:
        return Icons.restaurant;
      case OrderStatusEnum.onTheWay:
        return Icons.delivery_dining;
      case OrderStatusEnum.delivered:
        return Icons.check_circle_outline;
      case OrderStatusEnum.completed:
        return Icons.verified;
      case OrderStatusEnum.rejected:
      case OrderStatusEnum.cancelled:
        return Icons.cancel_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final order = widget.order;
    final status = order.status;
    final statusColor = _getStatusColor(status);
    final isTerminal = status == OrderStatusEnum.completed ||
        status == OrderStatusEnum.rejected ||
        status == OrderStatusEnum.cancelled;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: EdgeInsets.only(bottom: 12.h),
          decoration: BoxDecoration(
            color: isDark ? DarkColors.surface : LightColors.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: status == OrderStatusEnum.pending
                  ? statusColor.withValues(alpha: 0.4)
                  : (isDark ? DarkColors.border : LightColors.border),
              width: status == OrderStatusEnum.pending ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : Colors.grey).withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    // Top row: Order ID, Status badge, Time
                    Row(
                      children: [
                        // Order ID
                        Text(
                          '#${order.id}',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        // Status badge
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getStatusIcon(status),
                                size: 12.w,
                                color: statusColor,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                _getShortStatus(status),
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Time ago
                        Text(
                          _getTimeAgo(order.createdAt),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isDark ? DarkColors.textTertiary : LightColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),

                    // Middle row: Customer name and items count
                    Row(
                      children: [
                        // Customer avatar placeholder
                        Container(
                          width: 36.w,
                          height: 36.w,
                          decoration: BoxDecoration(
                            color: isDark
                                ? DarkColors.backgroundSecondary
                                : LightColors.backgroundSecondary,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            Icons.person_outline,
                            size: 20.w,
                            color: isDark ? DarkColors.textTertiary : LightColors.textTertiary,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        // Customer info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.customerName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                '${_getItemsCount(order)} ${'orders.itemsLabel'.tr}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: isDark ? DarkColors.textTertiary : LightColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Total price
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${order.total.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
                              ),
                            ),
                            if (order.isPaid)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 12.w,
                                    color: AppColors.success,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    'orders.paid'.tr,
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),

                    // Action button for non-terminal statuses
                    if (!isTerminal && status.nextStatus != null) ...[
                      SizedBox(height: 14.h),
                      _MinimalActionButton(
                        onTap: _handleMoveToNextStatus,
                        isLoading: _isProcessing,
                        statusColor: statusColor,
                      ),
                    ],
                  ],
                ),
              ),

              // Bottom progress bar
              if (!isTerminal)
                _MiniProgressBar(
                  progress: _getProgress(status),
                  color: statusColor,
                  isDark: isDark,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Minimal action button
class _MinimalActionButton extends StatelessWidget {
  const _MinimalActionButton({
    required this.onTap,
    required this.isLoading,
    required this.statusColor,
  });

  final VoidCallback onTap;
  final bool isLoading;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 18.w,
                  height: 18.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'orders.updateStatus'.tr,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16.w,
                    color: Colors.white,
                  ),
                ],
              ),
      ),
    );
  }
}

/// Mini progress bar at the bottom of the card
class _MiniProgressBar extends StatelessWidget {
  const _MiniProgressBar({
    required this.progress,
    required this.color,
    required this.isDark,
  });

  final double progress;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3.h,
      decoration: BoxDecoration(
        color: isDark ? DarkColors.border : Colors.grey[200],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16.r),
          bottomRight: Radius.circular(16.r),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                width: constraints.maxWidth * progress,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16.r),
                    bottomRight: progress >= 1.0 ? Radius.circular(16.r) : Radius.zero,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
