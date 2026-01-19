import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';
import '../../application/orders_notifier.dart';
import '../../data/models/order_model.dart';

/// Swipeable order card with clean design
/// - Swipe right: Update to next status
/// - Swipe left: Open order details
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
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;

  bool _isProcessing = false;
  double _dragExtent = 0.0;
  bool _isDragging = false;
  bool _hasPassedThreshold = false;

  // Swipe thresholds
  static const double _swipeThreshold = 0.25; // 25% of card width
  static const double _maxSwipeRatio = 0.4; // Max 40% swipe
  static const double _processingSwipeRatio = 0.35; // Locked position during processing

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    _isDragging = true;
    _dragExtent = 0.0;
    _hasPassedThreshold = false;
    HapticFeedback.selectionClick();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details, double maxWidth) {
    if (!_isDragging || _isProcessing) return;

    final previousExtent = _dragExtent;
    final newExtent = _dragExtent + (details.primaryDelta ?? 0);
    final maxDrag = maxWidth * _maxSwipeRatio;
    final clampedExtent = newExtent.clamp(-maxDrag, maxDrag);

    // Check if we're crossing the threshold
    final previousRatio = (previousExtent / maxWidth).abs();
    final newRatio = (clampedExtent / maxWidth).abs();
    final wasAboveThreshold = previousRatio >= _swipeThreshold;
    final isAboveThreshold = newRatio >= _swipeThreshold;

    // Haptic feedback when crossing threshold
    if (!wasAboveThreshold && isAboveThreshold && !_hasPassedThreshold) {
      HapticFeedback.mediumImpact();
      _hasPassedThreshold = true;
    } else if (wasAboveThreshold && !isAboveThreshold && _hasPassedThreshold) {
      HapticFeedback.lightImpact();
      _hasPassedThreshold = false;
    }

    setState(() {
      _dragExtent = clampedExtent;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details, double maxWidth) async {
    if (!_isDragging || _isProcessing) return;
    _isDragging = false;

    final swipeRatio = _dragExtent / maxWidth;
    final status = widget.order.status;
    final isTerminal = status == OrderStatusEnum.completed ||
        status == OrderStatusEnum.rejected ||
        status == OrderStatusEnum.cancelled;
    final nextStatus = status.nextStatus;

    // Swipe left threshold reached - update status
    if (swipeRatio < -_swipeThreshold && !isTerminal && nextStatus != null) {
      await _handleSwipeToUpdateStatus();
    }
    // Swipe right threshold reached - open details
    else if (swipeRatio > _swipeThreshold) {
      _resetSwipe();
      HapticFeedback.lightImpact();
      widget.onTap();
    }
    // Reset if threshold not reached
    else {
      _resetSwipe();
    }
  }

  void _resetSwipe() {
    setState(() {
      _dragExtent = 0.0;
    });
  }

  Future<void> _animateToPosition(double targetExtent) async {
    final startExtent = _dragExtent;
    _slideAnimation = Tween<double>(begin: startExtent, end: targetExtent).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    void listener() {
      setState(() {
        _dragExtent = _slideAnimation.value;
      });
    }

    _slideController.addListener(listener);
    _slideController.reset();
    await _slideController.forward();
    _slideController.removeListener(listener);
  }

  Future<void> _handleSwipeToUpdateStatus() async {
    if (_isProcessing) return;

    final previousStatus = widget.order.status;
    final nextStatus = previousStatus.nextStatus;
    if (nextStatus == null) return;

    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();

    // Get card width and animate to locked position
    final cardWidth = context.size?.width ?? 300;
    final targetExtent = -cardWidth * _processingSwipeRatio;

    // Smoothly animate to processing position
    await _animateToPosition(targetExtent);

    final success = await ref
        .read(ordersProvider.notifier)
        .moveToNextStatus(widget.order.id);

    if (mounted) {
      // Smoothly animate back to center
      await _animateToPosition(0.0);

      if (success) {
        _showUndoSnackBar(previousStatus, nextStatus);
      }

      setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleMoveToNextStatus() async {
    if (_isProcessing) return;

    final previousStatus = widget.order.status;
    final nextStatus = previousStatus.nextStatus;
    if (nextStatus == null) return;

    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();
    await _scaleController.forward();

    final success = await ref
        .read(ordersProvider.notifier)
        .moveToNextStatus(widget.order.id);

    if (success && mounted) {
      _showUndoSnackBar(previousStatus, nextStatus);
    }

    if (mounted) {
      await _scaleController.reverse();
      setState(() => _isProcessing = false);
    }
  }

  void _showUndoSnackBar(
      OrderStatusEnum previousStatus, OrderStatusEnum newStatus) {
    final orderId = widget.order.id;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 20.w,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'orders.statusUpdatedTo'
                    .tr
                    .replaceAll('{status}', _getStatusLabel(newStatus)),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        margin: EdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        action: SnackBarAction(
          label: 'common.undo'.tr,
          textColor: Colors.white,
          onPressed: () async {
            // Undo: revert to previous status
            HapticFeedback.lightImpact();
            final success = await ref
                .read(ordersProvider.notifier)
                .updateToStatus(orderId, previousStatus);

            if (success && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        Icons.undo_rounded,
                        color: Colors.white,
                        size: 20.w,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'orders.statusReverted'.tr,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.info,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                  margin: EdgeInsets.all(16.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              );
            }
          },
        ),
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
        return const Color(0xFFFF9800); // Orange - New order waiting
      case OrderStatusEnum.searchingForDriver:
        return const Color(0xFF2196F3); // Blue - Searching
      case OrderStatusEnum.driverNotificationSent:
        return const Color(0xFF9C27B0); // Purple - Driver notified
      case OrderStatusEnum.accepted:
        return const Color(0xFF00BCD4); // Cyan - Accepted/Preparing
      case OrderStatusEnum.onTheWay:
        return const Color(0xFF3F51B5); // Indigo - On the way
      case OrderStatusEnum.delivered:
        return const Color(0xFF8BC34A); // Light Green - Delivered
      case OrderStatusEnum.completed:
        return const Color(0xFF4CAF50); // Green - Completed
      case OrderStatusEnum.rejected:
        return const Color(0xFFF44336); // Red - Rejected
      case OrderStatusEnum.cancelled:
        return const Color(0xFF9E9E9E); // Grey - Cancelled
    }
  }

  IconData _getStatusIcon(OrderStatusEnum status) {
    switch (status) {
      case OrderStatusEnum.pending:
        return Icons.fiber_new_rounded; // New order indicator
      case OrderStatusEnum.searchingForDriver:
        return Icons.person_search_rounded; // Searching for driver
      case OrderStatusEnum.driverNotificationSent:
        return Icons.notifications_active_rounded; // Driver notified
      case OrderStatusEnum.accepted:
        return Icons.restaurant_menu_rounded; // Preparing food
      case OrderStatusEnum.onTheWay:
        return Icons.delivery_dining_rounded; // On delivery
      case OrderStatusEnum.delivered:
        return Icons.where_to_vote_rounded; // Arrived
      case OrderStatusEnum.completed:
        return Icons.check_circle_rounded; // Completed
      case OrderStatusEnum.rejected:
        return Icons.cancel_rounded; // Rejected
      case OrderStatusEnum.cancelled:
        return Icons.block_rounded; // Cancelled
    }
  }

  String _getStatusDescription(OrderStatusEnum status) {
    switch (status) {
      case OrderStatusEnum.pending:
        return 'orders.statusDesc.pending'.tr;
      case OrderStatusEnum.searchingForDriver:
        return 'orders.statusDesc.searchingForDriver'.tr;
      case OrderStatusEnum.driverNotificationSent:
        return 'orders.statusDesc.driverNotificationSent'.tr;
      case OrderStatusEnum.accepted:
        return 'orders.statusDesc.accepted'.tr;
      case OrderStatusEnum.onTheWay:
        return 'orders.statusDesc.onTheWay'.tr;
      case OrderStatusEnum.delivered:
        return 'orders.statusDesc.delivered'.tr;
      case OrderStatusEnum.completed:
        return 'orders.statusDesc.completed'.tr;
      case OrderStatusEnum.rejected:
        return 'orders.statusDesc.rejected'.tr;
      case OrderStatusEnum.cancelled:
        return 'orders.statusDesc.cancelled'.tr;
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
    final nextStatus = status.nextStatus;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final swipeProgress = (_dragExtent / maxWidth).clamp(-1.0, 1.0);

        return AnimatedBuilder(
          animation: _scaleController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: GestureDetector(
            onTap: widget.onTap,
            onHorizontalDragStart: _onHorizontalDragStart,
            onHorizontalDragUpdate: (details) =>
                _onHorizontalDragUpdate(details, maxWidth),
            onHorizontalDragEnd: (details) =>
                _onHorizontalDragEnd(details, maxWidth),
            child: Container(
              margin: EdgeInsets.only(bottom: 12.h),
              child: Stack(
                children: [
                  // Background layers (revealed when swiping)
                  Positioned.fill(
                    child: _SwipeBackground(
                      swipeProgress: swipeProgress,
                      isDark: isDark,
                      nextStatus: nextStatus,
                      isProcessing: _isProcessing,
                      getStatusLabel: _getStatusLabel,
                      getStatusIcon: _getStatusIcon,
                    ),
                  ),

                  // Main card (slides on swipe)
                  Transform.translate(
                    offset: Offset(_dragExtent, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? DarkColors.surface : LightColors.surface,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: isTerminal
                              ? (isDark ? DarkColors.border : LightColors.border)
                              : statusColor.withValues(alpha: 0.5),
                          width: isTerminal ? 1 : 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Column(
                              children: [
                                // Top row: Order ID and Time
                                Row(
                                  children: [
                                    // Order ID
                                    Text(
                                      '#${order.id}',
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? DarkColors.textPrimary
                                            : LightColors.textPrimary,
                                      ),
                                    ),
                                    const Spacer(),
                                    // Time ago
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
                                SizedBox(height: 12.h),

                                // Current Status - Prominent display
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12.w, vertical: 10.h),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10.r),
                                    border: Border.all(
                                      color: statusColor.withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8.w),
                                        decoration: BoxDecoration(
                                          color:
                                              statusColor.withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(8.r),
                                        ),
                                        child: Icon(
                                          _getStatusIcon(status),
                                          size: 18.w,
                                          color: statusColor,
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _getStatusLabel(status),
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w600,
                                                color: statusColor,
                                              ),
                                            ),
                                            SizedBox(height: 2.h),
                                            Text(
                                              _getStatusDescription(status),
                                              style: TextStyle(
                                                fontSize: 11.sp,
                                                color: isDark
                                                    ? DarkColors.textSecondary
                                                    : LightColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 12.h),

                                // Customer info row
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
                                        color: isDark
                                            ? DarkColors.textTertiary
                                            : LightColors.textTertiary,
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    // Customer info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            order.customerName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w500,
                                              color: isDark
                                                  ? DarkColors.textPrimary
                                                  : LightColors.textPrimary,
                                            ),
                                          ),
                                          SizedBox(height: 2.h),
                                          Text(
                                            '${_getItemsCount(order)} ${'orders.itemsLabel'.tr}',
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: isDark
                                                  ? DarkColors.textTertiary
                                                  : LightColors.textTertiary,
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
                                            color: isDark
                                                ? DarkColors.textPrimary
                                                : LightColors.textPrimary,
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
                                if (!isTerminal && nextStatus != null) ...[
                                  SizedBox(height: 14.h),
                                  _StatusActionButton(
                                    onTap: _handleMoveToNextStatus,
                                    isLoading: _isProcessing,
                                    nextStatusLabel: _getStatusLabel(nextStatus),
                                    nextStatusIcon: _getStatusIcon(nextStatus),
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Background revealed when swiping the card
class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.swipeProgress,
    required this.isDark,
    required this.nextStatus,
    required this.isProcessing,
    required this.getStatusLabel,
    required this.getStatusIcon,
  });

  final double swipeProgress;
  final bool isDark;
  final OrderStatusEnum? nextStatus;
  final bool isProcessing;
  final String Function(OrderStatusEnum) getStatusLabel;
  final IconData Function(OrderStatusEnum) getStatusIcon;

  @override
  Widget build(BuildContext context) {
    final absProgress = swipeProgress.abs();
    final isSwipingRight = swipeProgress > 0;
    final hasReachedThreshold = absProgress >= 0.25;

    // Swipe left: Update status (green)
    // Swipe right: View details (blue)
    final Color backgroundColor;
    final IconData icon;
    final String label;

    if (!isSwipingRight && nextStatus != null) {
      // Swiping left - update status
      backgroundColor =
          hasReachedThreshold ? AppColors.success : AppColors.success.withValues(alpha: 0.7);
      icon = getStatusIcon(nextStatus!);
      label = getStatusLabel(nextStatus!);
    } else {
      // Swiping right - view details
      backgroundColor =
          hasReachedThreshold ? AppColors.info : AppColors.info.withValues(alpha: 0.7);
      icon = Icons.visibility_rounded;
      label = 'orders.viewDetails'.tr;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            backgroundColor.withValues(alpha: 0.9),
            backgroundColor,
          ],
          begin: isSwipingRight ? Alignment.centerLeft : Alignment.centerRight,
          end: isSwipingRight ? Alignment.centerRight : Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          children: [
            // Decorative pattern
            Positioned(
              right: isSwipingRight ? null : -20.w,
              left: isSwipingRight ? -20.w : null,
              top: -20.h,
              child: Opacity(
                opacity: 0.1,
                child: Icon(
                  icon,
                  size: 150.w,
                  color: Colors.white,
                ),
              ),
            ),

            // Content
            Positioned(
              left: isSwipingRight ? 24.w : null,
              right: isSwipingRight ? null : 24.w,
              top: 0,
              bottom: 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: absProgress > 0.1 ? 1.0 : 0.0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isSwipingRight) ...[
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          isProcessing ? 'common.loading'.tr : label,
                          key: ValueKey(isProcessing),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                    ],
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.all(isProcessing ? 10.w : (hasReachedThreshold ? 14.w : 12.w)),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: isProcessing ? 0.3 : (hasReachedThreshold ? 0.25 : 0.15)),
                        borderRadius: BorderRadius.circular(isProcessing ? 20.r : (hasReachedThreshold ? 16.r : 12.r)),
                      ),
                      child: isProcessing
                          ? SizedBox(
                              width: 28.w,
                              height: 28.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              ),
                            )
                          : AnimatedRotation(
                              duration: const Duration(milliseconds: 200),
                              turns: hasReachedThreshold ? 0.0 : 0.0,
                              child: Transform.rotate(
                                angle: hasReachedThreshold ? 0 : (isSwipingRight ? -0.1 : 0.1),
                                child: Icon(
                                  hasReachedThreshold
                                      ? (isSwipingRight
                                          ? Icons.check_rounded
                                          : Icons.arrow_forward_rounded)
                                      : icon,
                                  color: Colors.white,
                                  size: hasReachedThreshold ? 28.w : 24.w,
                                ),
                              ),
                            ),
                    ),
                    if (isSwipingRight) ...[
                      SizedBox(width: 12.w),
                      Text(
                        label,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Arrow indicators on edges
            if (absProgress > 0.05)
              Positioned(
                right: isSwipingRight ? 16.w : null,
                left: isSwipingRight ? null : 16.w,
                top: 0,
                bottom: 0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: hasReachedThreshold ? 1.0 : 0.5,
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        3,
                        (index) => AnimatedContainer(
                          duration: Duration(milliseconds: 100 + (index * 50)),
                          margin: EdgeInsets.symmetric(horizontal: 2.w),
                          child: Icon(
                            isSwipingRight
                                ? Icons.chevron_right_rounded
                                : Icons.chevron_left_rounded,
                            color: Colors.white.withValues(
                              alpha: hasReachedThreshold
                                  ? 0.9 - (index * 0.2)
                                  : 0.5 - (index * 0.15),
                            ),
                            size: 20.w - (index * 2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Status action button showing next status
class _StatusActionButton extends StatelessWidget {
  const _StatusActionButton({
    required this.onTap,
    required this.isLoading,
    required this.nextStatusLabel,
    required this.nextStatusIcon,
  });

  final VoidCallback onTap;
  final bool isLoading;
  final String nextStatusLabel;
  final IconData nextStatusIcon;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: primaryColor,
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
                  Icon(
                    nextStatusIcon,
                    size: 18.w,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    nextStatusLabel,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16.w,
                    color: Colors.white.withValues(alpha: 0.8),
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
                    bottomRight:
                        progress >= 1.0 ? Radius.circular(16.r) : Radius.zero,
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
