import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';
import '../../application/orders_notifier.dart';
import '../../data/models/order_model.dart';

/// Animated order card with status actions
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
  late Animation<double> _fadeAnimation;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Cancel an order
  Future<void> _handleCancel() async {
    if (_isProcessing) return;

    final confirmed = await _showCancelDialog();
    if (!confirmed) return;

    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();

    await _controller.forward();
    final success = await ref
        .read(ordersProvider.notifier)
        .cancelOrder(widget.order.id);

    if (success && mounted) {
      _showSuccessSnackBar('orders.status.cancelled'.tr);
    }

    if (mounted) {
      await _controller.reverse();
      setState(() => _isProcessing = false);
    }
  }

  /// Accept an order
  Future<void> _handleAccept() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    HapticFeedback.mediumImpact();
    await _controller.forward();

    final success = await ref
        .read(ordersProvider.notifier)
        .acceptOrder(widget.order.id);

    if (success && mounted) {
      _showSuccessSnackBar('orders.status.accepted'.tr);
    }

    if (mounted) {
      await _controller.reverse();
      setState(() => _isProcessing = false);
    }
  }

  Future<bool> _showCancelDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('orders.cancelOrder'.tr),
            content: Text('orders.confirmCancel'.tr),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('common.no'.tr),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'common.yes'.tr,
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _handleMarkOnTheWay() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    HapticFeedback.mediumImpact();
    await _controller.forward();

    final success = await ref
        .read(ordersProvider.notifier)
        .markOnTheWay(widget.order.id);

    if (success && mounted) {
      _showSuccessSnackBar('orders.status.onTheWay'.tr);
    }

    if (mounted) {
      await _controller.reverse();
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleMarkCompleted() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    HapticFeedback.mediumImpact();
    await _controller.forward();

    final success = await ref
        .read(ordersProvider.notifier)
        .markCompleted(widget.order.id);

    if (success && mounted) {
      _showSuccessSnackBar('orders.status.completed'.tr);
    }

    if (mounted) {
      await _controller.reverse();
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleMarkDelivered() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    HapticFeedback.mediumImpact();
    await _controller.forward();

    final success = await ref
        .read(ordersProvider.notifier)
        .markDelivered(widget.order.id);

    if (success && mounted) {
      _showSuccessSnackBar('orders.status.delivered'.tr);
    }

    if (mounted) {
      await _controller.reverse();
      setState(() => _isProcessing = false);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20.w),
            SizedBox(width: 8.w),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h';
    } else {
      return '${diff.inDays}d';
    }
  }

  String _getItemsSummary(OrderModel order) {
    if (order.items.isEmpty) return 'orders.noItems'.tr;
    
    final itemDescriptions = order.items.map((item) {
      return '${item.quantity}x ${item.name}';
    }).toList();
    
    return itemDescriptions.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final order = widget.order;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: EdgeInsets.only(bottom: 10.h),
          decoration: BoxDecoration(
            color: isDark ? DarkColors.surface : LightColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: _getStatusBorderColor(order.status, isDark),
              width: order.status == OrderStatusEnum.pending ? 1.5 : 0.5,
            ),
            boxShadow: order.status == OrderStatusEnum.pending
                ? [
                    BoxShadow(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              // Status indicator bar
              Container(
                height: 4.h,
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    topRight: Radius.circular(12.r),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(14.w),
                child: Column(
                  children: [
                    // Header row
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(order.status)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  '#${order.id}',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                    color: _getStatusColor(order.status),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  order.customerName,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? DarkColors.textPrimary
                                        : LightColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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
                            Text(
                              _getTimeAgo(order.createdAt),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: isDark
                                    ? DarkColors.textTertiary
                                    : LightColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),

                    // Items summary
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: isDark
                            ? DarkColors.background
                            : LightColors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        _getItemsSummary(order),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDark
                              ? DarkColors.textSecondary
                              : LightColors.textSecondary,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),

                    // Details row
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                '\$${order.total.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? DarkColors.textPrimary
                                      : LightColors.textPrimary,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              if (order.isPaid) ...[
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        size: 12.w,
                                        color: AppColors.success,
                                      ),
                                      SizedBox(width: 3.w),
                                      Text(
                                        'orders.paid'.tr,
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.success,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        _buildActionButtons(isDark),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    final status = widget.order.status;

    if (_isProcessing) {
      return SizedBox(
        width: 24.w,
        height: 24.w,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary,
        ),
      );
    }

    switch (status) {
      case OrderStatusEnum.pending:
      case OrderStatusEnum.searchingForDriver:
      case OrderStatusEnum.driverNotificationSent:
        // Show Accept and Cancel buttons
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ActionButton(
              label: 'orders.reject'.tr,
              onTap: _handleCancel,
              isDark: isDark,
            ),
            SizedBox(width: 6.w),
            _ActionButton(
              label: 'orders.accept'.tr,
              onTap: _handleAccept,
              isPrimary: true,
              icon: Icons.check,
            ),
          ],
        );

      case OrderStatusEnum.accepted:
        return _ActionButton(
          label: 'orders.markOnTheWay'.tr,
          onTap: _handleMarkOnTheWay,
          isPrimary: true,
          icon: Icons.delivery_dining,
        );

      case OrderStatusEnum.onTheWay:
        return _ActionButton(
          label: 'orders.markDelivered'.tr,
          onTap: _handleMarkDelivered,
          isPrimary: true,
          icon: Icons.check_circle_outline,
        );

      case OrderStatusEnum.delivered:
        return _ActionButton(
          label: 'orders.markCompleted'.tr,
          onTap: _handleMarkCompleted,
          isPrimary: true,
          icon: Icons.done_all,
        );

      case OrderStatusEnum.completed:
        return Row(
          children: [
            Icon(Icons.done_all, color: AppColors.success, size: 20.w),
            SizedBox(width: 4.w),
            Text(
              'orders.status.completed'.tr,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.success,
              ),
            ),
          ],
        );

      case OrderStatusEnum.rejected:
      case OrderStatusEnum.cancelled:
        return Row(
          children: [
            Icon(Icons.cancel, color: AppColors.error, size: 20.w),
            SizedBox(width: 4.w),
            Text(
              status == OrderStatusEnum.rejected
                  ? 'orders.status.rejected'.tr
                  : 'orders.status.cancelled'.tr,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ],
        );
    }
  }

  Color _getStatusColor(OrderStatusEnum status) {
    switch (status) {
      case OrderStatusEnum.pending:
      case OrderStatusEnum.searchingForDriver:
      case OrderStatusEnum.driverNotificationSent:
        return AppColors.warning;
      case OrderStatusEnum.accepted:
        return AppColors.info;
      case OrderStatusEnum.onTheWay:
        return Colors.purple;
      case OrderStatusEnum.delivered:
        return AppColors.success;
      case OrderStatusEnum.completed:
        return AppColors.success.withValues(alpha: 0.7);
      case OrderStatusEnum.rejected:
      case OrderStatusEnum.cancelled:
        return AppColors.error;
    }
  }

  Color _getStatusBorderColor(OrderStatusEnum status, bool isDark) {
    if (status == OrderStatusEnum.pending) {
      return AppColors.warning.withValues(alpha: 0.5);
    }
    return isDark ? DarkColors.border : LightColors.border;
  }

}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onTap,
    this.isPrimary = false,
    this.isDark = false,
    this.icon,
  });

  final String label;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool isDark;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: icon != null ? 8.w : 10.w,
          vertical: 6.h,
        ),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6.r),
          border: isPrimary
              ? null
              : Border.all(
                  color: isDark ? DarkColors.border : LightColors.border,
                ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 12.w,
                color: isPrimary ? Colors.white : (isDark ? DarkColors.textSecondary : LightColors.textSecondary),
              ),
              SizedBox(width: 3.w),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: isPrimary
                      ? Colors.white
                      : (isDark
                          ? DarkColors.textSecondary
                          : LightColors.textSecondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
