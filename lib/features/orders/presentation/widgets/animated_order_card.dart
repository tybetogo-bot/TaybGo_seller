import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';
import '../../../restaurant/application/restaurant_state.dart';
import '../../application/orders_notifier.dart';
import '../../data/models/order_model.dart';
import 'order_api_debug_inspector.dart';
import 'driver_dispatch_selector.dart';
import 'incoming_order_timer.dart';

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
  bool _isLoadingDebugData = false;
  double _dragExtent = 0.0;
  bool _isDragging = false;
  bool _hasPassedThreshold = false;

  // Swipe thresholds
  static const double _swipeThreshold = 0.25; // 25% of card width
  static const double _maxSwipeRatio = 0.4; // Max 40% swipe
  static const double _processingSwipeRatio =
      0.35; // Locked position during processing

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));
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
    final canAdvanceOrder = _canSwipeToAdvance();
    // Only allow left-swipe (negative) when the order has a next actionable state.
    final minDrag = canAdvanceOrder ? -maxDrag : 0.0;
    final clampedExtent = newExtent.clamp(minDrag, maxDrag);

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

    // Swipe left threshold reached - update status when another action is available.
    if (swipeRatio < -_swipeThreshold && _canSwipeToAdvance()) {
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
    _slideAnimation = Tween<double>(begin: startExtent, end: targetExtent)
        .animate(
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
    final nextStatus = _getNextStatus();
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
      } else {
        _showErrorSnackBar(
          ref.read(ordersProvider).error ?? 'orders.statusUpdateFailed'.tr,
        );
      }

      setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleMoveToNextStatus() async {
    if (_isProcessing) return;

    final previousStatus = widget.order.status;
    final nextStatus = _getNextStatus();
    if (nextStatus == null) return;

    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();
    await _scaleController.forward();

    final success = await ref
        .read(ordersProvider.notifier)
        .moveToNextStatus(widget.order.id);

    if (mounted) {
      if (success) {
        _showUndoSnackBar(previousStatus, nextStatus);
      } else {
        _showErrorSnackBar(
          ref.read(ordersProvider).error ?? 'orders.statusUpdateFailed'.tr,
        );
      }
    }

    if (mounted) {
      await _scaleController.reverse();
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _handlePrimaryAction() async {
    if (_isProcessing) return;

    final action = _getPrimaryAction();
    if (action == null) return;

    switch (action.normalizedValue) {
      case 'ACCEPTED':
        await _handleAcceptAction();
      case 'REQUEST_DRIVER_NOW':
        await _handleDriverDispatchAction(DriverDispatchAction.requestNow);
      case 'SCHEDULE_DRIVER':
        await _handleDriverDispatchAction(DriverDispatchAction.schedule);
      case 'RESCHEDULE_DRIVER':
        await _handleDriverDispatchAction(DriverDispatchAction.reschedule);
      case 'REJECTED':
        await _handleReject();
      case 'CANCELLED':
        await _handleCancel();
      default:
        if (action.status != null) await _handleMoveToNextStatus();
    }
  }

  Future<void> _handleAcceptAction() async {
    int? delayMinutes;
    final notifier = ref.read(ordersProvider.notifier);
    if (notifier.isDriverDispatchAvailableForOrder(widget.order)) {
      delayMinutes = await showDriverDispatchDelaySelector(
        context,
        order: widget.order,
      );
      if (!mounted || delayMinutes == null) return;
    }

    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();
    await _scaleController.forward();

    final success = await notifier.acceptOrder(
      widget.order.id,
      driverDispatchDelayMinutes: delayMinutes,
    );
    if (!mounted) return;

    if (success) {
      _showSimpleSnackBar(
        delayMinutes != null && delayMinutes > 0
            ? 'orders.driverRequestScheduled'.tr
            : 'orders.orderAcceptedSuccess'.tr,
        AppColors.success,
      );
    } else {
      _showErrorSnackBar(
        ref.read(ordersProvider).error ?? 'orders.statusUpdateFailed'.tr,
      );
    }
    await _scaleController.reverse();
    if (mounted) setState(() => _isProcessing = false);
  }

  Future<void> _handleDriverDispatchAction(DriverDispatchAction action) async {
    int? delayMinutes;
    if (action != DriverDispatchAction.requestNow) {
      delayMinutes = await showDriverDispatchDelaySelector(
        context,
        order: widget.order,
      );
      if (!mounted || delayMinutes == null) return;
      // Choosing "Immediately" is semantically a request-now operation and
      // avoids sending a zero-delay RESCHEDULE to the backend.
      if (delayMinutes == 0) action = DriverDispatchAction.requestNow;
    }

    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();
    final notifier = ref.read(ordersProvider.notifier);
    final success = switch (action) {
      DriverDispatchAction.requestNow => await notifier.requestDriverNow(
        widget.order.id,
      ),
      DriverDispatchAction.schedule => await notifier.scheduleDriver(
        widget.order.id,
        delayMinutes!,
      ),
      DriverDispatchAction.reschedule => await notifier.rescheduleDriver(
        widget.order.id,
        delayMinutes!,
      ),
    };

    if (!mounted) return;
    if (success) {
      _showSimpleSnackBar(
        action == DriverDispatchAction.requestNow
            ? 'orders.driverRequestStarted'.tr
            : 'orders.driverRequestScheduled'.tr,
        AppColors.success,
      );
    } else {
      _showErrorSnackBar(
        ref.read(ordersProvider).error ?? 'orders.statusUpdateFailed'.tr,
      );
    }
    if (mounted) setState(() => _isProcessing = false);
  }

  Future<void> _handlePrimaryActionForReschedule() {
    return _handleDriverDispatchAction(DriverDispatchAction.reschedule);
  }

  Future<void> _handleCancel() async {
    setState(() => _isProcessing = true);
    final success = await ref
        .read(ordersProvider.notifier)
        .cancelOrder(widget.order.id);
    if (!mounted) return;
    if (success) {
      _showSimpleSnackBar('orders.orderCancelled'.tr, AppColors.success);
    } else {
      _showErrorSnackBar(
        ref.read(ordersProvider).error ?? 'orders.statusUpdateFailed'.tr,
      );
    }
    setState(() => _isProcessing = false);
  }

  void _showSimpleSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
      ),
    );
  }

  Future<void> _handleReorder() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();

    final createdOrder = await ref
        .read(ordersProvider.notifier)
        .reorderExpiredOrder(widget.order.id);

    if (!mounted) return;

    if (createdOrder != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('orders.orderCreated'.tr),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      final error = ref.read(ordersProvider).error ?? 'errors.unexpected'.tr;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
    }

    setState(() => _isProcessing = false);
  }

  Future<void> _handleReject() async {
    if (_isProcessing) return;

    final confirmed = await _showRejectConfirmationDialog();
    if (confirmed != true || !mounted) return;

    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();

    final success = await ref
        .read(ordersProvider.notifier)
        .rejectOrder(widget.order.id);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('orders.orderRejectedSuccess'.tr),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      _showErrorSnackBar(
        ref.read(ordersProvider).error ?? 'orders.orderRejectFailed'.tr,
      );
    }

    setState(() => _isProcessing = false);
  }

  Future<bool?> _showRejectConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('orders.rejectOrder'.tr),
          content: Text('orders.rejectConfirmMessage'.tr),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text('orders.cancel'.tr),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: Text('orders.rejectOrder'.tr),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleShowDebugInspector() async {
    if (_isLoadingDebugData) return;

    setState(() => _isLoadingDebugData = true);

    try {
      await showOrderApiDebugInspector(
        context: context,
        ref: ref,
        order: widget.order,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Debug fetch failed: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingDebugData = false);
      }
    }
  }

  void _showUndoSnackBar(
    OrderStatusEnum previousStatus,
    OrderStatusEnum newStatus,
  ) {
    final orderId = widget.order.id;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      _CountdownSnackBar(
        orderId: orderId,
        previousStatus: previousStatus,
        newStatus: newStatus,
        getStatusLabel: _getStatusLabel,
        onUndo: (orderId, previousStatus) async {
          HapticFeedback.lightImpact();
          final success = await ref
              .read(ordersProvider.notifier)
              .updateToStatus(orderId, previousStatus);

          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.undo_rounded, color: Colors.white, size: 20.w),
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
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  OrderStatusEnum? _getNextStatus() {
    return ref
        .read(ordersProvider.notifier)
        .getNextStatusForOrder(widget.order);
  }

  OrderAllowedAction? _getPrimaryAction() {
    return ref
        .read(ordersProvider.notifier)
        .getPrimaryAllowedAction(widget.order);
  }

  bool _canSwipeToAdvance() {
    // Explicit allowed_actions may represent ACCEPTED, scheduling, or a
    // destructive command. Keep those choices behind their dedicated button
    // and selector instead of silently executing a status swipe.
    return widget.order.status != OrderStatusEnum.pending &&
        widget.order.allowedActions.isEmpty &&
        _getNextStatus() != null;
  }

  String _getActionLabel(OrderAllowedAction action) {
    switch (action.normalizedValue) {
      case 'ACCEPTED':
        return 'orders.acceptOrder'.tr;
      case 'REQUEST_DRIVER_NOW':
        return 'orders.requestDriverNow'.tr;
      case 'SCHEDULE_DRIVER':
        return 'orders.scheduleDriver'.tr;
      case 'RESCHEDULE_DRIVER':
        return 'orders.changeDriverRequestTime'.tr;
      case 'REJECTED':
        return 'orders.rejectOrder'.tr;
      case 'CANCELLED':
        return 'orders.cancelOrder'.tr;
      default:
        return action.status == null
            ? (action.label ?? action.value)
            : _getPrimaryActionLabel(action.status!);
    }
  }

  IconData _getActionIcon(OrderAllowedAction action) {
    switch (action.normalizedValue) {
      case 'REQUEST_DRIVER_NOW':
      case 'SCHEDULE_DRIVER':
      case 'RESCHEDULE_DRIVER':
        return Icons.delivery_dining_rounded;
      case 'REJECTED':
        return Icons.close_rounded;
      case 'CANCELLED':
        return Icons.block_rounded;
      default:
        return action.status == null
            ? Icons.touch_app_rounded
            : _getStatusIcon(action.status!);
    }
  }

  String _getPrimaryActionLabel(OrderStatusEnum nextStatus) {
    switch (nextStatus) {
      case OrderStatusEnum.accepted:
        return 'orders.acceptOrder'.tr;
      case OrderStatusEnum.searchingForDriver:
        return 'orders.requestDriver'.tr;
      case OrderStatusEnum.onTheWay:
        return 'orders.markOnTheWay'.tr;
      case OrderStatusEnum.delivered:
        return 'orders.markDelivered'.tr;
      case OrderStatusEnum.restaurantDelivered:
        return 'orders.markRestaurantDelivered'.tr;
      default:
        return _getStatusLabel(nextStatus);
    }
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
      case OrderStatusEnum.restaurantDelivered:
        return 'orders.status.restaurantDelivered'.tr;
      case OrderStatusEnum.expired:
        return 'coupons.expired'.tr;
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
      return 'orders.incoming.receivedMinutesAgo'.trParams({
        'count': '${diff.inMinutes}',
      });
    } else if (diff.inHours < 24) {
      return 'orders.incoming.receivedHoursAgo'.trParams({
        'count': '${diff.inHours}',
      });
    } else {
      return 'orders.incoming.receivedDaysAgo'.trParams({
        'count': '${diff.inDays}',
      });
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
      case OrderStatusEnum.restaurantDelivered:
        return 1.0;
      case OrderStatusEnum.expired:
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
      case OrderStatusEnum.restaurantDelivered:
        return const Color(0xFF4CAF50); // Green - Delivered (final success)
      case OrderStatusEnum.expired:
        return AppColors.warning; // Amber - Order expired before completion
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
      case OrderStatusEnum.restaurantDelivered:
        return Icons.check_circle_rounded; // Delivered (final success)
      case OrderStatusEnum.expired:
        return Icons.timer_off_rounded; // Expired before completion
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
      case OrderStatusEnum.restaurantDelivered:
        return 'orders.statusDesc.restaurantDelivered'.tr;
      case OrderStatusEnum.expired:
        return 'coupons.expired'.tr;
      case OrderStatusEnum.rejected:
        return 'orders.statusDesc.rejected'.tr;
      case OrderStatusEnum.cancelled:
        return 'orders.statusDesc.cancelled'.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(selectedRestaurantProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final order = widget.order;
    final status = order.status;
    final statusColor = _getStatusColor(status);
    final isTerminal = status.isTerminal;
    final nextStatus = _getNextStatus();
    final primaryAction = _getPrimaryAction();
    final notifier = ref.read(ordersProvider.notifier);
    final canReject = notifier.canRejectOrder(order);
    final canCancel = notifier.canCancelOrder(order);
    final canReschedule = order.allowsAction('RESCHEDULE_DRIVER');

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final swipeProgress = (_dragExtent / maxWidth).clamp(-1.0, 1.0);

        return AnimatedBuilder(
          animation: _scaleController,
          builder: (context, child) {
            return Transform.scale(scale: _scaleAnimation.value, child: child);
          },
          child: Semantics(
            // The timer contains a progress indicator. Keep the whole order
            // card exposed as a details button on Flutter Web instead of
            // allowing the timer's progress semantics to replace it.
            container: true,
            button: true,
            onTap: widget.onTap,
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
                        getActionLabel: _getPrimaryActionLabel,
                        getStatusIcon: _getStatusIcon,
                      ),
                    ),

                    // Main card (slides on swipe)
                    Transform.translate(
                      offset: Offset(_dragExtent, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? DarkColors.surface
                              : LightColors.surface,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: isTerminal
                                ? (isDark
                                      ? DarkColors.border
                                      : LightColors.border)
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
                                      if (showOrderApiDebugTools) ...[
                                        _CardDebugButton(
                                          isDark: isDark,
                                          isLoading: _isLoadingDebugData,
                                          onTap: _handleShowDebugInspector,
                                        ),
                                        SizedBox(width: 8.w),
                                      ],
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
                                      horizontal: 12.w,
                                      vertical: 10.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10.r),
                                      border: Border.all(
                                        color: statusColor.withValues(
                                          alpha: 0.3,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(8.w),
                                          decoration: BoxDecoration(
                                            color: statusColor.withValues(
                                              alpha: 0.15,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8.r,
                                            ),
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
                                                      : LightColors
                                                            .textSecondary,
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
                                          borderRadius: BorderRadius.circular(
                                            10.r,
                                          ),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            order.sellerTotalAmount == null
                                                ? '—'
                                                : '€${order.sellerTotalAmount!.toStringAsFixed(2)}',
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

                                  if (order.driverDispatchStatus != null &&
                                      status != OrderStatusEnum.pending) ...[
                                    SizedBox(height: 12.h),
                                    IncomingOrderTimer(
                                      order: order,
                                      textPrimary: isDark
                                          ? DarkColors.textPrimary
                                          : LightColors.textPrimary,
                                      textSecondary: isDark
                                          ? DarkColors.textSecondary
                                          : LightColors.textSecondary,
                                      onRefresh: () async {
                                        await ref
                                            .read(ordersProvider.notifier)
                                            .fetchOrderById(order.id);
                                      },
                                    ),
                                  ],

                                  // Action button for explicit order actions
                                  if (primaryAction != null) ...[
                                    SizedBox(height: 14.h),
                                    _StatusActionButton(
                                      onTap: _handlePrimaryAction,
                                      isLoading: _isProcessing,
                                      nextStatusLabel: _getActionLabel(
                                        primaryAction,
                                      ),
                                      nextStatusIcon: _getActionIcon(
                                        primaryAction,
                                      ),
                                    ),
                                  ] else if (status ==
                                      OrderStatusEnum.expired) ...[
                                    SizedBox(height: 14.h),
                                    _StatusActionButton(
                                      onTap: _handleReorder,
                                      isLoading: _isProcessing,
                                      nextStatusLabel: 'orders.reorder'.tr,
                                      nextStatusIcon: Icons.refresh_rounded,
                                    ),
                                  ],
                                  if (canReschedule &&
                                      primaryAction?.normalizedValue ==
                                          'REQUEST_DRIVER_NOW') ...[
                                    SizedBox(height: 8.h),
                                    _SecondaryActionButton(
                                      onTap: _handlePrimaryActionForReschedule,
                                      label:
                                          'orders.changeDriverRequestTime'.tr,
                                      icon: Icons.schedule_rounded,
                                      isLoading: _isProcessing,
                                    ),
                                  ],
                                  if (canReject) ...[
                                    SizedBox(height: 8.h),
                                    _RejectOrderButton(
                                      onTap: _handleReject,
                                      isLoading: _isProcessing,
                                    ),
                                  ],
                                  if (canCancel && !canReject) ...[
                                    SizedBox(height: 8.h),
                                    _SecondaryActionButton(
                                      onTap: _handleCancel,
                                      label: 'orders.cancelOrder'.tr,
                                      icon: Icons.block_rounded,
                                      isLoading: _isProcessing,
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
          ),
        );
      },
    );
  }
}

class _CardDebugButton extends StatelessWidget {
  const _CardDebugButton({
    required this.isDark,
    required this.isLoading,
    required this.onTap,
  });

  final bool isDark;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: 28.w,
        height: 28.w,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 14.w,
                  height: 14.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
              : Icon(
                  Icons.data_object_rounded,
                  size: 16.w,
                  color: isDark
                      ? DarkColors.textPrimary
                      : Theme.of(context).colorScheme.primary,
                ),
        ),
      ),
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
    required this.getActionLabel,
    required this.getStatusIcon,
  });

  final double swipeProgress;
  final bool isDark;
  final OrderStatusEnum? nextStatus;
  final bool isProcessing;
  final String Function(OrderStatusEnum) getActionLabel;
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
      backgroundColor = hasReachedThreshold
          ? AppColors.success
          : AppColors.success.withValues(alpha: 0.7);
      icon = getStatusIcon(nextStatus!);
      label = getActionLabel(nextStatus!);
    } else {
      // Swiping right - view details
      backgroundColor = hasReachedThreshold
          ? AppColors.info
          : AppColors.info.withValues(alpha: 0.7);
      icon = Icons.visibility_rounded;
      label = 'orders.viewDetails'.tr;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [backgroundColor.withValues(alpha: 0.9), backgroundColor],
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
                child: Icon(icon, size: 150.w, color: Colors.white),
              ),
            ),

            // Content - Text only
            if (absProgress > 0.1 && !isProcessing)
              Align(
                alignment: isSwipingRight
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: absProgress > 0.15 ? 1.0 : 0.0,
                    child: Text(
                      label,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.visible,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        height: 1.3,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black.withValues(alpha: 0.4),
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Loading indicator
            if (isProcessing)
              Center(
                child: Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: SizedBox(
                    width: 28.w,
                    height: 28.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
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
                  Icon(nextStatusIcon, size: 18.w, color: Colors.white),
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

class _RejectOrderButton extends StatelessWidget {
  const _RejectOrderButton({required this.onTap, required this.isLoading});

  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 11.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.45)),
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 18.w,
                  height: 18.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.error,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.close_rounded, size: 18.w, color: AppColors.error),
                  SizedBox(width: 8.w),
                  Text(
                    'orders.rejectOrder'.tr,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({
    required this.onTap,
    required this.label,
    required this.icon,
    required this.isLoading,
  });

  final VoidCallback onTap;
  final String label;
  final IconData icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return OutlinedButton.icon(
      onPressed: isLoading ? null : onTap,
      icon: isLoading
          ? SizedBox(
              width: 16.w,
              height: 16.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: primaryColor,
              ),
            )
          : Icon(icon, size: 17.w),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
        side: BorderSide(color: primaryColor.withValues(alpha: 0.35)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
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
                    bottomRight: progress >= 1.0
                        ? Radius.circular(16.r)
                        : Radius.zero,
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

/// Countdown snackbar with undo functionality
class _CountdownSnackBar extends SnackBar {
  _CountdownSnackBar({
    required String orderId,
    required OrderStatusEnum previousStatus,
    required OrderStatusEnum newStatus,
    required String Function(OrderStatusEnum) getStatusLabel,
    required Future<void> Function(String, OrderStatusEnum) onUndo,
  }) : super(
         content: _CountdownSnackBarContent(
           orderId: orderId,
           previousStatus: previousStatus,
           newStatus: newStatus,
           getStatusLabel: getStatusLabel,
           onUndo: onUndo,
         ),
         backgroundColor: AppColors.success,
         behavior: SnackBarBehavior.floating,
         duration: const Duration(seconds: 3),
         margin: EdgeInsets.all(16.w),
         shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(12.r),
         ),
       );
}

/// Content widget for countdown snackbar
class _CountdownSnackBarContent extends StatefulWidget {
  const _CountdownSnackBarContent({
    required this.orderId,
    required this.previousStatus,
    required this.newStatus,
    required this.getStatusLabel,
    required this.onUndo,
  });

  final String orderId;
  final OrderStatusEnum previousStatus;
  final OrderStatusEnum newStatus;
  final String Function(OrderStatusEnum) getStatusLabel;
  final Future<void> Function(String, OrderStatusEnum) onUndo;

  @override
  State<_CountdownSnackBarContent> createState() =>
      _CountdownSnackBarContentState();
}

class _CountdownSnackBarContentState extends State<_CountdownSnackBarContent> {
  late int _countdown;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _countdown = 3;
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _countdown--;
          if (_countdown <= 0) {
            _timer?.cancel();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.check_circle_rounded, color: Colors.white, size: 20.w),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            'orders.statusUpdatedTo'.tr.replaceAll(
              '{status}',
              widget.getStatusLabel(widget.newStatus),
            ),
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
          ),
        ),
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            widget.onUndo(widget.orderId, widget.previousStatus);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'common.undo'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 6.w),
                Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$_countdown',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
