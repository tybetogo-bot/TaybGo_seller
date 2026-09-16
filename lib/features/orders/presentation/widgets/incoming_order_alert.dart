import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/i18n/i18n.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../../../core/theme/theme.dart';
import '../../../notifications/application/notifications_notifier.dart';
import '../../../restaurant/application/restaurant_state.dart';
import '../../../tour/application/tour_notifier.dart';
import '../../../menu/application/menu_notifier.dart';
import '../../../menu/data/models/menu_item_model.dart';
import '../../application/orders_notifier.dart';
import '../../data/models/food_checkout_model.dart';
import '../../data/models/order_model.dart';
import 'driver_dispatch_selector.dart';
import 'incoming_order_item_editor.dart';
import 'incoming_order_timer.dart';

const _knownOrderNotificationTypes = {
  'new_order',
  'new-order',
  'order_created',
  'order-created',
  'order_updated',
  'order-updated',
  'order_status_updated',
  'order-status-updated',
  'order_accepted',
  'order-accepted',
  'order_rejected',
  'order-rejected',
  'order_delivered',
  'order-delivered',
  'order_cancelled',
  'order-cancelled',
};

/// Places a high-attention incoming-order experience above the authenticated
/// shell. The order remains server-owned: this widget only displays the
/// backend timer when it is present and sends the existing seller actions.
class IncomingOrderAlertHost extends ConsumerStatefulWidget {
  const IncomingOrderAlertHost({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<IncomingOrderAlertHost> createState() =>
      _IncomingOrderAlertHostState();
}

class _IncomingOrderAlertHostState
    extends ConsumerState<IncomingOrderAlertHost> {
  final Set<String> _dismissedOrderIds = <String>{};
  final List<String> _incomingOrderIds = <String>[];
  Set<String> _knownPendingOrderIds = <String>{};
  bool _hasSeededPendingSnapshot = false;
  late final void Function(Map<String, dynamic> data) _notificationTapHandler;

  @override
  void initState() {
    super.initState();

    _notificationTapHandler = (data) {
      // Notification callbacks are synchronous by contract; the order fetch
      // and overlay handoff can safely continue asynchronously.
      unawaited(_handleNotificationTap(data));
    };
    PushNotificationService.instance.onNotificationTap =
        _notificationTapHandler;

    // Listen outside build so the overlay appears once when a new pending
    // order arrives, rather than re-opening old pending orders on navigation.
    ref.listenManual<OrdersState>(
      ordersProvider,
      (_, next) => _reconcilePendingOrders(next),
      fireImmediately: true,
    );
  }

  void _reconcilePendingOrders(OrdersState ordersState) {
    // The first completed snapshot is the baseline. This prevents an order
    // that was already pending before the shell opened from behaving like a
    // newly received order.
    if (!mounted || ordersState.isLoading || ordersState.error != null) return;

    final pendingOrders = ordersState.orders
        .where((order) => order.status == OrderStatusEnum.pending)
        .toList();
    final pendingIds = pendingOrders.map((order) => order.id).toSet();

    if (!_hasSeededPendingSnapshot) {
      _knownPendingOrderIds = pendingIds;
      _hasSeededPendingSnapshot = true;
      return;
    }

    final newlyPendingIds = pendingIds.difference(_knownPendingOrderIds);
    _knownPendingOrderIds = pendingIds;

    final nextIncomingIds = _incomingOrderIds
        .where(pendingIds.contains)
        .toList();
    for (final order in pendingOrders) {
      if (newlyPendingIds.contains(order.id) &&
          !_dismissedOrderIds.contains(order.id) &&
          !nextIncomingIds.contains(order.id)) {
        nextIncomingIds.add(order.id);
      }
    }

    if (nextIncomingIds.length == _incomingOrderIds.length &&
        nextIncomingIds.every((id) => _incomingOrderIds.contains(id))) {
      return;
    }
    setState(() {
      _incomingOrderIds
        ..clear()
        ..addAll(nextIncomingIds);
    });
  }

  void _dismissOrder(String orderId) {
    if (!mounted) return;
    setState(() {
      _dismissedOrderIds.add(orderId);
      _incomingOrderIds.remove(orderId);
    });
  }

  void _enqueueOrder(String orderId, {bool fromNotification = false}) {
    if (!mounted || _incomingOrderIds.contains(orderId)) return;
    if (fromNotification) _dismissedOrderIds.remove(orderId);
    setState(() => _incomingOrderIds.add(orderId));
  }

  Future<void> _handleNotificationTap(Map<String, dynamic> data) async {
    final rawOrderId = data['order_id'] ?? data['orderId'];
    final orderId = rawOrderId?.toString().trim();
    final notificationType = data['type']?.toString().trim().toLowerCase();

    if (notificationType == 'support_message_from_staff' ||
        notificationType == 'support_ticket_updated') {
      await _handleSupportNotificationTap(data);
      return;
    }

    if (notificationType != null &&
        !_knownOrderNotificationTypes.contains(notificationType)) {
      if (mounted) context.go(Routes.notifications);
      return;
    }

    if (orderId == null || orderId.isEmpty) {
      if (notificationType == 'new_order' || notificationType == 'new-order') {
        // The preferred payload includes order_id. If it is absent, refresh
        // so a newly-created pending order can still enter the queue.
        await ref.read(ordersProvider.notifier).refreshOrders();
        return;
      }
      if (mounted) context.go(Routes.notifications);
      return;
    }

    final cachedOrder = ref.read(ordersProvider.notifier).getOrder(orderId);
    final fetchedOrder = await ref
        .read(ordersProvider.notifier)
        .fetchOrderById(orderId);
    final order = fetchedOrder ?? cachedOrder;

    if (!mounted) return;
    if (order?.status == OrderStatusEnum.pending) {
      _dismissedOrderIds.remove(order!.id);
      _knownPendingOrderIds.add(order.id);
      _enqueueOrder(order.id, fromNotification: true);
      return;
    }

    // A notification for an order that is already past the seller decision
    // step should continue to the normal details route.
    context.go(Routes.orderDetailsPath(order?.id ?? orderId));
  }

  Future<void> _handleSupportNotificationTap(Map<String, dynamic> data) async {
    final ticketId = _asInt(data['ticket_id'] ?? data['ticketId']);
    final messageId = _asInt(data['message_id'] ?? data['messageId']);

    if (ticketId == null) {
      if (mounted) context.go(Routes.notifications);
      return;
    }

    if (!mounted) return;
    context.go(
      Routes.supportTicketDetailNotificationPath(
        ticketId.toString(),
        messageId: messageId,
      ),
    );

    // Reconcile in the background. Navigation must not be blocked by a
    // missing notification record or a temporary notifications API failure.
    unawaited(
      ref.read(notificationsProvider.notifier).markPushTargetAsRead(data),
    );
  }

  Future<bool> _acceptOrder(OrderModel order, int? delayMinutes) async {
    final success = await ref
        .read(ordersProvider.notifier)
        .acceptOrder(order.id, driverDispatchDelayMinutes: delayMinutes);
    if (success) _dismissOrder(order.id);
    return success;
  }

  Future<bool> _rejectOrder(OrderModel order) async {
    final success = await ref
        .read(ordersProvider.notifier)
        .rejectOrder(order.id);
    if (success) _dismissOrder(order.id);
    return success;
  }

  Future<bool> _editOrderItems(OrderModel order, List<CartItem> items) async {
    return ref
        .read(ordersProvider.notifier)
        .editPendingOrderItems(order.id, items);
  }

  Future<List<MenuItemModel>> _loadMenuItems(OrderModel order) async {
    // An account can own more than one restaurant. The incoming order is the
    // source of truth for the catalog scope; the currently selected
    // restaurant is only a compatibility fallback for older payloads.
    final restaurantId =
        order.restaurant?.id.toString() ??
        ref.read(selectedRestaurantIdProvider);
    if (restaurantId == null) {
      throw StateError('No restaurant selected');
    }

    // Fetch a fresh, complete catalog only when the editor opens. Returning
    // unavailable items is intentional: the editor must map an existing
    // order line before it can show it as unavailable and let the seller
    // remove or replace it.
    final result = await ref
        .read(menuRepositoryProvider)
        .getMenuItems(restaurantId);
    if (result.failure != null) {
      throw StateError(result.failure!.message);
    }
    return (result.data ?? const <MenuItemModel>[]).toList(growable: false);
  }

  @override
  void dispose() {
    if (PushNotificationService.instance.onNotificationTap ==
        _notificationTapHandler) {
      PushNotificationService.instance.onNotificationTap = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(ordersProvider);
    final tourState = ref.watch(tourProvider);
    final visibleOrders = <OrderModel>[];
    for (final orderId in _incomingOrderIds) {
      for (final order in ordersState.orders) {
        if (order.id == orderId && order.status == OrderStatusEnum.pending) {
          visibleOrders.add(order);
          break;
        }
      }
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (visibleOrders.isNotEmpty && !tourState.isActive)
          Positioned.fill(
            child: IncomingOrderAlert(
              key: const ValueKey('incoming-orders-alert'),
              orders: visibleOrders,
              onAccept: _acceptOrder,
              onReject: _rejectOrder,
              onEditItems: _editOrderItems,
              onDismiss: (order) => _dismissOrder(order.id),
              // Load the catalog only when the seller opens the editor. This
              // keeps the home screen's incoming-order path lightweight.
              menuItems: const [],
              loadMenuItems: _loadMenuItems,
              canAccept: (order) =>
                  order.allowedActions.isEmpty ||
                  order.allowsAction('ACCEPTED'),
              canScheduleDriver: ref
                  .read(ordersProvider.notifier)
                  .isDriverDispatchAvailableForOrder,
              errorMessage: () => ref.read(ordersProvider).error,
            ),
          ),
      ],
    );
  }
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

/// Full-screen incoming order presentation.
///
/// Before acceptance, the timer area intentionally says that dispatch timing
/// starts after acceptance. When the backend supplies dispatch timing fields,
/// the same area automatically becomes a live countdown using the server
/// timestamp as its clock anchor.
class IncomingOrderAlert extends StatefulWidget {
  const IncomingOrderAlert({
    required this.orders,
    required this.onAccept,
    required this.onReject,
    required this.onDismiss,
    this.onEditItems,
    this.menuItems = const [],
    this.loadMenuItems,
    this.errorMessage,
    this.canAccept,
    this.canScheduleDriver,
    this.onRefresh,
    this.previewOnly = false,
    super.key,
  });

  final List<OrderModel> orders;
  final Future<bool> Function(OrderModel order, int? delayMinutes) onAccept;
  final Future<bool> Function(OrderModel order) onReject;
  final void Function(OrderModel order) onDismiss;
  final Future<bool> Function(OrderModel order, List<CartItem> items)?
  onEditItems;
  final List<MenuItemModel> menuItems;
  final Future<List<MenuItemModel>> Function(OrderModel order)? loadMenuItems;
  final String? Function()? errorMessage;
  final bool Function(OrderModel order)? canAccept;
  final bool Function(OrderModel order)? canScheduleDriver;
  final Future<void> Function()? onRefresh;
  final bool previewOnly;

  @override
  State<IncomingOrderAlert> createState() => _IncomingOrderAlertState();
}

class _IncomingOrderAlertState extends State<IncomingOrderAlert>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryController;
  late final PageController _pageController;
  int _pageIndex = 0;
  bool _isProcessing = false;
  bool _isDismissing = false;
  String? _actionError;
  String? _actionNotice;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 460),
    )..forward();
    _pageController = PageController();
  }

  @override
  void didUpdateWidget(covariant IncomingOrderAlert oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldActiveId = oldWidget.orders.isEmpty
        ? null
        : oldWidget.orders[_pageIndex.clamp(0, oldWidget.orders.length - 1)].id;
    final nextIndex = oldActiveId == null
        ? 0
        : widget.orders.indexWhere((order) => order.id == oldActiveId);
    final safeNextIndex = widget.orders.isEmpty
        ? 0
        : (nextIndex == -1
              ? _pageIndex.clamp(0, widget.orders.length - 1)
              : nextIndex);
    final nextActiveId = widget.orders.isEmpty
        ? null
        : widget.orders[safeNextIndex].id;
    final activeOrderChanged =
        oldActiveId != null &&
        nextActiveId != null &&
        oldActiveId != nextActiveId;

    if (safeNextIndex != _pageIndex || activeOrderChanged) {
      _pageIndex = safeNextIndex;
      _actionError = null;
      _actionNotice = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_pageController.hasClients) return;
        _pageController.jumpToPage(safeNextIndex);
      });
    }
    if (oldActiveId != null &&
        !widget.orders.any((order) => order.id == oldActiveId)) {
      _isDismissing = false;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  Future<void> _handleAccept(OrderModel order) async {
    if (_isProcessing) return;

    int? delayMinutes;
    if (widget.canScheduleDriver?.call(order) ?? false) {
      delayMinutes = await showDriverDispatchDelaySelector(
        context,
        order: order,
      );
      if (!mounted || delayMinutes == null) return;
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _isProcessing = true;
      _actionError = null;
      _actionNotice = null;
    });

    final success = await widget.onAccept(order, delayMinutes);
    if (!mounted) return;
    if (!success) {
      setState(() {
        _isProcessing = false;
        _actionError =
            widget.errorMessage?.call() ?? 'orders.statusUpdateFailed'.tr;
      });
      return;
    }

    // The host removes the overlay after the server confirms the action.
    setState(() => _isProcessing = false);
  }

  Future<void> _handleReject(OrderModel order) async {
    if (_isProcessing) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
      ),
    );
    if (confirmed != true || !mounted) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _isProcessing = true;
      _actionError = null;
      _actionNotice = null;
    });

    final success = await widget.onReject(order);
    if (!mounted) return;
    if (!success) {
      setState(() {
        _isProcessing = false;
        _actionError =
            widget.errorMessage?.call() ?? 'orders.orderRejectFailed'.tr;
      });
      return;
    }

    setState(() => _isProcessing = false);
  }

  Future<void> _handleEditItems(OrderModel order) async {
    if (_isProcessing || widget.onEditItems == null) return;

    setState(() {
      _isProcessing = true;
      _actionError = null;
      _actionNotice = null;
    });

    try {
      var menuItems = widget.menuItems;
      if (menuItems.isEmpty && widget.loadMenuItems != null) {
        menuItems = await widget.loadMenuItems!(order);
      }
      if (!mounted) return;

      final editedItems = await showIncomingOrderItemEditor(
        context,
        order: order,
        menuItems: menuItems,
      );
      if (!mounted) return;

      if (editedItems == null) {
        setState(() => _isProcessing = false);
        return;
      }

      final success = await widget.onEditItems!(order, editedItems);
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        if (success) {
          _actionNotice = 'orders.incoming.itemsUpdated'.tr;
        } else {
          _actionError =
              widget.errorMessage?.call() ??
              'orders.incoming.editItemsFailed'.tr;
        }
      });
      if (success) HapticFeedback.mediumImpact();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _actionError =
            widget.errorMessage?.call() ?? 'orders.incoming.editItemsFailed'.tr;
      });
    }
  }

  void _reviewLater() {
    if (_isProcessing || _isDismissing || widget.orders.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() => _isDismissing = true);
    // The host removes the full-screen layer immediately. The dismissing
    // guard releases pointer events during the one-frame handoff.
    widget.onDismiss(_currentOrder);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColors = isDark
        ? const [Color(0xFF10271A), Color(0xFF0C1711)]
        : const [Color(0xFFEFF9F2), Color(0xFFFAFCFB)];
    final textPrimary = isDark ? Colors.white : const Color(0xFF152019);
    final textSecondary = isDark
        ? Colors.white.withValues(alpha: 0.66)
        : const Color(0xFF68746D);

    return IgnorePointer(
      ignoring: _isDismissing,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (_, _) {
          if (!_isProcessing) _reviewLater();
        },
        child: Material(
          color: Colors.transparent,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: backgroundColors,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -150.h,
                  right: -120.w,
                  child: _SoftGlow(
                    size: 310.w,
                    color: AppColors.primary.withValues(
                      alpha: isDark ? 0.1 : 0.13,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -200.h,
                  left: -150.w,
                  child: _SoftGlow(
                    size: 300.w,
                    color: AppColors.info.withValues(
                      alpha: isDark ? 0.04 : 0.06,
                    ),
                  ),
                ),
                SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return PageView.builder(
                        controller: _pageController,
                        physics: const BouncingScrollPhysics(),
                        itemCount: widget.orders.length,
                        onPageChanged: (index) {
                          if (!mounted) return;
                          HapticFeedback.selectionClick();
                          setState(() {
                            _pageIndex = index;
                            _actionError = null;
                            _actionNotice = null;
                          });
                        },
                        itemBuilder: (context, index) {
                          final order = widget.orders[index];
                          return Align(
                            key: ValueKey('incoming-order-page-${order.id}'),
                            alignment: Alignment.topCenter,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 560.w),
                              child: SizedBox(
                                width: double.infinity,
                                height: constraints.maxHeight,
                                child: FadeTransition(
                                  opacity: CurvedAnimation(
                                    parent: _entryController,
                                    curve: Curves.easeOutCubic,
                                  ),
                                  child: SlideTransition(
                                    position:
                                        Tween<Offset>(
                                          begin: const Offset(0, 0.035),
                                          end: Offset.zero,
                                        ).animate(
                                          CurvedAnimation(
                                            parent: _entryController,
                                            curve: Curves.easeOutCubic,
                                          ),
                                        ),
                                    child: _buildOrderPage(
                                      order,
                                      textPrimary,
                                      textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  OrderModel get _currentOrder =>
      widget.orders[_pageIndex.clamp(0, widget.orders.length - 1)];

  Widget _buildOrderPage(
    OrderModel order,
    Color textPrimary,
    Color textSecondary,
  ) {
    final actionBottomPadding = _canEditItems(order) ? 190.h : 126.h;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(0, 10.h, 0, actionBottomPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTopBar(textSecondary),
                SizedBox(height: 10.h),
                _buildHero(),
                SizedBox(height: 8.h),
                Text(
                  'orders.incoming.title'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 23.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'orders.incoming.subtitle'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textSecondary, fontSize: 12.sp),
                ),
                SizedBox(height: 14.h),
                _buildOrderCard(order, textPrimary, textSecondary),
                SizedBox(height: 12.h),
                IncomingOrderTimer(
                  order: order,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  onRefresh: widget.onRefresh,
                ),
                if (_actionError != null) ...[
                  SizedBox(height: 8.h),
                  _buildErrorMessage(_actionError!),
                ],
                if (_actionNotice != null) ...[
                  SizedBox(height: 8.h),
                  _buildNoticeMessage(_actionNotice!),
                ],
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF0D1A12)
                    : const Color(0xFFF8FBF9),
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.08)
                        : const Color(0xFFE2ECE6),
                  ),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
                child: _buildActions(order),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(Color textSecondary) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: isDark ? 0.14 : 0.1),
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: isDark ? 0.28 : 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7.w,
                height: 7.w,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 7.w),
              Text(
                widget.previewOnly
                    ? 'orders.incoming.previewBadge'.tr
                    : 'orders.incoming.badge'.tr,
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.88)
                      : const Color(0xFF356044),
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.25,
                ),
              ),
            ],
          ),
        ),
        if (widget.orders.length > 1) ...[
          SizedBox(width: 8.w),
          Tooltip(
            message: 'orders.incoming.swipeHint'.tr,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0xFFE8F2EC),
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Text(
                '${_pageIndex + 1}/${widget.orders.length}',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
        const Spacer(),
        TextButton(
          onPressed: _isProcessing ? null : _reviewLater,
          style: TextButton.styleFrom(
            foregroundColor: textSecondary,
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          ),
          child: Text(
            'orders.incoming.reviewLater'.tr,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildHero() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final heroScale = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.08, 0.82, curve: Curves.easeOutBack),
    );
    return ScaleTransition(
      scale: Tween<double>(begin: 0.86, end: 1).animate(heroScale),
      child: Container(
        width: 68.w,
        height: 68.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: isDark ? 0.11 : 0.08),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.18),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: isDark ? 0.14 : 0.1),
              blurRadius: 22,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Container(
          width: 50.w,
          height: 50.w,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.receipt_long_rounded,
            color: Colors.white,
            size: 25.w,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(
    OrderModel order,
    Color textPrimary,
    Color textSecondary,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isPaid = order.isPaid;
    final typeLabel = _isPickupOrder(order)
        ? 'orders.incoming.pickup'.tr
        : 'orders.incoming.delivery'.tr;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.055) : Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : const Color(0xFFD8E7DE),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.16)
                : const Color(0xFF315342).withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '#${order.id}',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 8.w),
              _SmallPill(label: typeLabel, color: AppColors.primary),
              const Spacer(),
              _SmallPill(
                label: isPaid ? 'orders.paid'.tr : 'orders.unpaid'.tr,
                color: isPaid ? AppColors.success : AppColors.warning,
                icon: isPaid ? Icons.check_rounded : Icons.schedule_rounded,
              ),
            ],
          ),
          SizedBox(height: 11.h),
          Divider(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : const Color(0xFFE2ECE6),
            height: 1,
          ),
          SizedBox(height: 12.h),
          _InfoRow(
            icon: Icons.person_outline_rounded,
            label: 'orders.customerName'.tr,
            value: order.customerName,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
          if (!_isPickupOrder(order)) ...[
            SizedBox(height: 10.h),
            _InfoRow(
              icon: Icons.location_on_outlined,
              label: 'orders.deliveryAddress'.tr,
              value: _addressLabel(order),
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
          ],
          SizedBox(height: 12.h),
          _buildItemSummary(order, textPrimary, textSecondary),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.only(top: 12.h),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : const Color(0xFFE2ECE6),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'orders.incoming.sellerTotal'.tr,
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  order.sellerTotalAmount == null
                      ? '—'
                      : '€${order.sellerTotalAmount!.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemSummary(
    OrderModel order,
    Color textPrimary,
    Color textSecondary,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final items = order.items;
    final itemCount = items.fold<int>(
      0,
      (total, item) => total + item.quantity,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.045)
            : theme.colorScheme.primary.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(13.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                color: AppColors.primary[100],
                size: 18.w,
              ),
              SizedBox(width: 8.w),
              Text(
                'orders.orderItems'.tr,
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '$itemCount ${'orders.itemsLabel'.tr}',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            _itemSummary(order),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textSecondary,
              fontSize: 11.sp,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _itemSummary(OrderModel order) {
    if (order.items.isEmpty) return 'orders.noItems'.tr;

    final visibleItems = order.items.take(3).map((item) {
      return '${item.quantity}× ${item.name}';
    }).toList();
    final summary = visibleItems.join('  ·  ');
    final remaining = order.items.length - visibleItems.length;
    if (remaining > 0) {
      return '$summary  ·  ${'orders.incoming.moreItems'.trParams({'count': '$remaining'})}';
    }
    return summary;
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18.w),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white, fontSize: 11.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeMessage(String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            color: AppColors.primary,
            size: 18.w,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : const Color(0xFF356044),
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(OrderModel order) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rejectColor = isDark
        ? const Color(0xFFFF8A8A)
        : const Color(0xFFD54A4A);
    final canAccept = widget.canAccept?.call(order) ?? true;
    final canReject =
        order.allowedActions.isEmpty || order.allowsAction('REJECTED');
    final canEditItems = _canEditItems(order);
    return Column(
      children: [
        if (canEditItems)
          SizedBox(
            width: double.infinity,
            height: 46.h,
            child: OutlinedButton.icon(
              onPressed: _isProcessing ? null : () => _handleEditItems(order),
              icon: _isProcessing
                  ? SizedBox(
                      width: 17.w,
                      height: 17.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.1,
                        color: AppColors.primary.withValues(alpha: 0.8),
                      ),
                    )
                  : Icon(Icons.edit_note_rounded, size: 19.w),
              label: Text(
                'orders.incoming.editItems'.tr,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                backgroundColor: AppColors.primary.withValues(alpha: 0.07),
                disabledForegroundColor: AppColors.primary.withValues(
                  alpha: 0.4,
                ),
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.5),
                ),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13.r),
                ),
              ),
            ),
          ),
        if (canEditItems && (canAccept || canReject)) SizedBox(height: 10.h),
        if (canAccept)
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : () => _handleAccept(order),
              icon: _isProcessing
                  ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(Icons.check_rounded, size: 20.w),
              label: Text(
                'orders.acceptOrder'.tr,
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primary.withValues(
                  alpha: 0.5,
                ),
                disabledForegroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13.r),
                ),
              ),
            ),
          ),
        if (canAccept && canReject) SizedBox(height: 10.h),
        if (canReject) ...[
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: OutlinedButton.icon(
              onPressed: _isProcessing ? null : () => _handleReject(order),
              icon: Icon(Icons.close_rounded, size: 20.w),
              label: Text(
                'orders.rejectOrder'.tr,
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: rejectColor,
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.025)
                    : rejectColor.withValues(alpha: 0.05),
                disabledForegroundColor: rejectColor.withValues(alpha: 0.4),
                side: BorderSide(color: rejectColor.withValues(alpha: 0.55)),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13.r),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  bool _canEditItems(OrderModel order) {
    return !widget.previewOnly &&
        order.status == OrderStatusEnum.pending &&
        !order.isPaid &&
        order.allowsAction('EDIT') &&
        widget.onEditItems != null;
  }

  bool _isPickupOrder(OrderModel order) {
    final type =
        (order.fulfillmentType ??
                order.requestedDeliveryType ??
                order.orderType)
            .toUpperCase();
    return type.contains('PICKUP') ||
        type.contains('TAKEAWAY') ||
        type.contains('COLLECT');
  }

  String _addressLabel(OrderModel order) {
    final newAddress = order.dropoffAddress?.displayAddress;
    if (newAddress != null && newAddress != 'N/A') return newAddress;
    final legacyAddress = order.fullAddress;
    if (legacyAddress.trim().isNotEmpty) return legacyAddress;
    return '—';
  }
}

/// Opens the production-shaped incoming-order UI without sending an action to
/// the backend. This is intentionally exposed for the Home preview button so
/// the design can be reviewed safely with real or sample order data.
Future<void> showIncomingOrderPreview(
  BuildContext context, {
  OrderModel? order,
  List<OrderModel>? orders,
}) async {
  final previewOrders = orders == null || orders.isEmpty
      ? order == null
            ? _buildPreviewOrders()
            : [order]
      : orders;

  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'orders.incoming.previewBadge'.tr,
    barrierColor: Colors.transparent,
    transitionDuration: Duration.zero,
    pageBuilder: (dialogContext, _, _) {
      void closePreview() {
        Navigator.of(dialogContext, rootNavigator: true).pop();
      }

      return IncomingOrderAlert(
        orders: previewOrders,
        previewOnly: true,
        canScheduleDriver: (_) => true,
        onAccept: (_, _) async {
          closePreview();
          return true;
        },
        onReject: (_) async {
          closePreview();
          return true;
        },
        onDismiss: (_) => closePreview(),
      );
    },
  );
}

List<OrderModel> _buildPreviewOrders() {
  final firstOrder = OrderModel(
    id: 'PREVIEW',
    customerName: 'Maya Haddad',
    phoneNumber: '501234567',
    countryCode: '+43',
    address: const AddressModel(
      street: 'Mariahilfer Straße',
      building: '22',
      city: 'Vienna',
      postalCode: '1070',
      country: 'Austria',
    ),
    items: const [
      OrderItemModel(
        id: 'preview-item-1',
        menuItemId: 'preview-menu-1',
        name: 'Classic Burger',
        quantity: 2,
        unitPrice: 12.5,
      ),
      OrderItemModel(
        id: 'preview-item-2',
        menuItemId: 'preview-menu-2',
        name: 'Crispy Fries',
        quantity: 1,
        unitPrice: 4.5,
      ),
    ],
    subtotal: 29.5,
    sellerTotalAmount: 29.5,
    isPaid: true,
    status: OrderStatusEnum.pending,
    orderType: 'FOOD',
    fulfillmentType: 'DELIVERY',
    requestedDeliveryType: 'DELIVERY',
    restaurant: const OrderRestaurantModel(
      id: 1,
      name: 'TaybGo Kitchen',
      deliveryEnabled: true,
    ),
    notes: 'Please include extra napkins.',
    createdAt: DateTime.now().subtract(const Duration(seconds: 38)),
  );

  return [
    firstOrder,
    firstOrder.copyWith(
      id: 'PREVIEW-2',
      customerName: 'Lukas Steiner',
      phoneNumber: '512345678',
      isPaid: false,
      notes: 'Ring the bell once you arrive.',
      createdAt: DateTime.now().subtract(const Duration(seconds: 21)),
    ),
  ];
}

class _SoftGlow extends StatelessWidget {
  const _SoftGlow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: color, blurRadius: 80, spreadRadius: 20),
          ],
        ),
      ),
    );
  }
}

class _SmallPill extends StatelessWidget {
  const _SmallPill({required this.label, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.16 : 0.09),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.35 : 0.24),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12.w, color: color),
            SizedBox(width: 4.w),
          ],
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white : color,
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.textPrimary,
    required this.textSecondary,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, size: 17.w, color: AppColors.primary[100]),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
