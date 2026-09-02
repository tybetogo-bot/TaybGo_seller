import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/i18n/i18n.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../menu/application/menu_notifier.dart';
import '../../../restaurant/application/restaurant_state.dart';
import '../../../tour/utils/tour_keys.dart';
import '../../application/orders_notifier.dart';
import '../../data/models/order_model.dart';
import '../widgets/order_api_debug_inspector.dart';

// TODO: Re-enable when print button is enabled
// import '../../data/services/pdf_receipt_service.dart';

/// Order details screen
class OrderDetailsScreen extends ConsumerStatefulWidget {
  const OrderDetailsScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends ConsumerState<OrderDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isProcessing = false;
  bool _isLoadingDebugData = false;
  OrderModel? _loadedOrder;
  bool _isLoadingOrder = true;
  bool _hasStartedOrderLoad = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadOrder();
    });
  }

  @override
  void didUpdateWidget(covariant OrderDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orderId == widget.orderId) return;

    _loadedOrder = null;
    _isLoadingOrder = true;
    _hasStartedOrderLoad = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadOrder();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleStatusAction(OrderModel order) async {
    if (_isProcessing) return;

    // Get the target status for confirmation
    final targetStatus = _getTargetStatus(order);
    if (targetStatus == null) return;

    // Show confirmation dialog
    final confirmed = await _showStatusConfirmationDialog(
      order.status,
      targetStatus,
    );
    if (confirmed != true) return;

    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();

    final success = await ref
        .read(ordersProvider.notifier)
        .moveToNextStatus(order.id);

    if (mounted) {
      if (success) {
        _showSuccessSnackBar(
          'orders.statusUpdatedTo'.tr.replaceAll(
            '{status}',
            _getStatusDisplayName(targetStatus),
          ),
        );
      } else {
        final error = ref.read(ordersProvider).error;
        _showErrorSnackBar(error ?? 'orders.statusUpdateFailed'.tr);
      }
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleReorder(OrderModel order) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();

    final createdOrder = await ref
        .read(ordersProvider.notifier)
        .reorderExpiredOrder(order.id);

    if (mounted) {
      if (createdOrder != null) {
        _showSuccessSnackBar('orders.orderCreated'.tr);
      } else {
        final error = ref.read(ordersProvider).error;
        _showErrorSnackBar(error ?? 'errors.unexpected'.tr);
      }

      setState(() => _isProcessing = false);
    }
  }

  OrderStatusEnum? _getTargetStatus(OrderModel order) {
    return ref.read(ordersProvider.notifier).getNextStatusForOrder(order);
  }

  String _getActionLabel(OrderStatusEnum targetStatus) {
    switch (targetStatus) {
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
        return _getStatusDisplayName(targetStatus);
    }
  }

  String _getStatusDisplayName(OrderStatusEnum status) {
    switch (status) {
      case OrderStatusEnum.pending:
        return 'orders.status.pending'.tr;
      case OrderStatusEnum.searchingForDriver:
        return 'orders.status.searchingForDriver'.tr;
      case OrderStatusEnum.accepted:
        return 'orders.status.accepted'.tr;
      case OrderStatusEnum.driverNotificationSent:
        return 'orders.status.driverNotificationSent'.tr;
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

  Future<bool?> _showStatusConfirmationDialog(
    OrderStatusEnum currentStatus,
    OrderStatusEnum targetStatus,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final primaryColor = Theme.of(dialogContext).colorScheme.primary;
        return AlertDialog(
          title: Text('orders.updateStatus'.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('orders.confirmStatusUpdate'.tr),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'orders.from'.tr,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            _getStatusDisplayName(currentStatus),
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Icon(Icons.arrow_forward, color: primaryColor),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'orders.to'.tr,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: primaryColor,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            _getStatusDisplayName(targetStatus),
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text('common.cancel'.tr),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text('orders.update'.tr),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20.w),
            SizedBox(width: 8.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20.w),
            SizedBox(width: 8.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _loadOrder() async {
    if (_hasStartedOrderLoad) return;

    _hasStartedOrderLoad = true;
    final requestedOrderId = widget.orderId;
    final cachedOrder = ref.read(orderByIdProvider(requestedOrderId));

    if (cachedOrder != null) {
      if (!mounted || widget.orderId != requestedOrderId) return;
      setState(() {
        _loadedOrder = cachedOrder;
        _isLoadingOrder = false;
      });
      return;
    }

    if (mounted) {
      setState(() => _isLoadingOrder = true);
    }

    OrderModel? fetchedOrder;
    try {
      fetchedOrder = await ref
          .read(ordersProvider.notifier)
          .fetchOrderById(requestedOrderId);
    } catch (_) {
      // The notifier normally converts failures to a null result. Keep the
      // screen in a settled state even if a future implementation throws.
    }

    if (!mounted || widget.orderId != requestedOrderId) return;

    setState(() {
      _loadedOrder = fetchedOrder;
      _isLoadingOrder = false;
    });
  }

  void _retryLoadOrder() {
    if (_isLoadingOrder) return;

    setState(() {
      _loadedOrder = null;
      _isLoadingOrder = true;
      _hasStartedOrderLoad = false;
    });
    _loadOrder();
  }

  Widget _buildOrderUnavailable({required bool isDark}) {
    return AppScaffold(
      appBar: AppAppBar(title: 'orders.orderDetails'.tr),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoadingOrder) ...[
                SizedBox(
                  width: 32.w,
                  height: 32.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'common.loading'.tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: isDark
                        ? DarkColors.textSecondary
                        : LightColors.textSecondary,
                  ),
                ),
              ] else ...[
                Icon(Icons.error_outline, size: 48.w, color: AppColors.error),
                SizedBox(height: 16.h),
                Text(
                  'orderNotFound'.tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: isDark
                        ? DarkColors.textSecondary
                        : LightColors.textSecondary,
                  ),
                ),
                SizedBox(height: 12.h),
                TextButton.icon(
                  onPressed: _retryLoadOrder,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text('common.retry'.tr),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(translationsLoadedProvider);
    ref.watch(selectedRestaurantProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cachedOrder = ref.watch(orderByIdProvider(widget.orderId));
    final order = cachedOrder ?? _loadedOrder;

    if (order == null) {
      return _buildOrderUnavailable(isDark: isDark);
    }

    return AppScaffold(
      appBar: AppAppBar(
        title: '${'orders.orderDetails'.tr} #${order.id}',
        actions: showOrderApiDebugTools
            ? [
                IconButton(
                  tooltip: 'Show API debug data',
                  onPressed: _isLoadingDebugData
                      ? null
                      : () async {
                          setState(() => _isLoadingDebugData = true);
                          try {
                            await showOrderApiDebugInspector(
                              context: context,
                              ref: ref,
                              order: order,
                            );
                          } catch (e) {
                            if (mounted) {
                              _showErrorSnackBar('Debug fetch failed: $e');
                            }
                          } finally {
                            if (mounted) {
                              setState(() => _isLoadingDebugData = false);
                            }
                          }
                        },
                  icon: _isLoadingDebugData
                      ? SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.primary,
                          ),
                        )
                      : const Icon(Icons.data_object_rounded),
                ),
              ]
            : null,
        // TODO: Re-enable print button when PDF generation is fully tested
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.print_outlined),
        //     onPressed: () {
        //       PdfReceiptService.showReceiptOptions(
        //         context,
        //         order,
        //         restaurantName: order.restaurant?.name,
        //         restaurantAddress: order.restaurant?.address,
        //         restaurantPhone: order.restaurant?.phone,
        //       );
        //     },
        //   ),
        // ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: Breakpoints.maxContentWidth,
          ),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: AppSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status timeline
                  KeyedSubtree(
                    key: TourKeys.orderStatusTimelineKey,
                    child: _OrderStatusTimeline(order: order, isDark: isDark),
                  ),
                  SizedBox(height: 24.h),

                  // Order info (type, manual indicator)
                  _OrderInfoCard(order: order, isDark: isDark),
                  SizedBox(height: 20.h),

                  // Pickup & Dropoff Addresses
                  _SectionTitle(title: 'orders.addresses'.tr, isDark: isDark),
                  SizedBox(height: 12.h),
                  _AddressesCard(order: order, isDark: isDark),
                  SizedBox(height: 20.h),

                  // Driver info (if assigned)
                  if (order.driver != null) ...[
                    _SectionTitle(
                      title: 'orders.driverInfo'.tr,
                      isDark: isDark,
                    ),
                    SizedBox(height: 12.h),
                    _DriverCard(driver: order.driver!, isDark: isDark),
                    SizedBox(height: 20.h),
                  ],

                  // Delivery options (vehicle type)
                  if (order.requestedVehicleType != null ||
                      order.requestedDeliveryType != null) ...[
                    _SectionTitle(
                      title: 'orders.deliveryOptions'.tr,
                      isDark: isDark,
                    ),
                    SizedBox(height: 12.h),
                    _DeliveryOptionsCard(order: order, isDark: isDark),
                    SizedBox(height: 20.h),
                  ],

                  // Order items
                  KeyedSubtree(
                    key: TourKeys.orderItemsSectionKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionTitle(
                          title: 'orders.orderItems'.tr,
                          isDark: isDark,
                        ),
                        SizedBox(height: 12.h),
                        _OrderItemsCard(order: order, isDark: isDark),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Coupon info (if applied)
                  if (order.coupon != null) ...[
                    _SectionTitle(
                      title: 'orders.couponApplied'.tr,
                      isDark: isDark,
                    ),
                    SizedBox(height: 12.h),
                    _CouponCard(coupon: order.coupon!, isDark: isDark),
                    SizedBox(height: 20.h),
                  ],

                  // Payment summary
                  KeyedSubtree(
                    key: TourKeys.orderPaymentSummaryKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionTitle(
                          title: 'orders.payment'.tr,
                          isDark: isDark,
                        ),
                        SizedBox(height: 12.h),
                        _PaymentSummaryCard(order: order, isDark: isDark),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Action buttons based on status
                  _buildActionButtons(order, isDark),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(OrderModel order, bool isDark) {
    final status = order.status;
    final canEditOrder = order.isManual && !order.isCompleted;
    final actionButtons = <Widget>[];

    if (canEditOrder) {
      actionButtons.add(
        AppButton(
          label: 'orders.editOrder'.tr,
          icon: Icons.edit_outlined,
          variant: AppButtonVariant.secondary,
          isLoading: _isProcessing,
          onPressed: () => context.push(Routes.editOrderPath(order.id)),
          isFullWidth: true,
        ),
      );
    }

    if (status == OrderStatusEnum.expired) {
      actionButtons.add(
        AppButton(
          label: 'orders.reorder'.tr,
          icon: Icons.refresh_rounded,
          isLoading: _isProcessing,
          onPressed: () => _handleReorder(order),
          isFullWidth: true,
        ),
      );
      return _ActionButtonStack(children: actionButtons);
    }

    // Flow: Pending → Searching → Driver Notified → Accepted/Rejected → On the Way → Delivered
    // Delivered, rejected, or cancelled orders don't need action buttons
    if (status == OrderStatusEnum.delivered ||
        status == OrderStatusEnum.restaurantDelivered ||
        status == OrderStatusEnum.rejected ||
        status == OrderStatusEnum.cancelled) {
      return _ActionButtonStack(children: actionButtons);
    }

    // Get the next status label for the button
    final targetStatus = _getTargetStatus(order);
    if (targetStatus == null) {
      return _ActionButtonStack(children: actionButtons);
    }

    // Show button with action label
    actionButtons.add(
      AppButton(
        label: _getActionLabel(targetStatus),
        icon: _getStatusIcon(targetStatus),
        isLoading: _isProcessing,
        onPressed: () => _handleStatusAction(order),
        isFullWidth: true,
      ),
    );

    return _ActionButtonStack(children: actionButtons);
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
}

class _ActionButtonStack extends StatelessWidget {
  const _ActionButtonStack({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(height: 10.h),
          children[i],
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.isDark});

  final String title;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
      ),
    );
  }
}

/// Animated status timeline showing order progress
class _OrderStatusTimeline extends StatelessWidget {
  const _OrderStatusTimeline({required this.order, required this.isDark});

  final OrderModel order;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    // Calculate progress (0.0 to 1.0) based on current status
    final progress = _getProgress(order.status);
    final isRestaurantDelivered =
        order.status == OrderStatusEnum.restaurantDelivered;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : LightColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? DarkColors.border : LightColors.border,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          // Order ID row
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isDark
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                  : Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.tag,
                  size: 16.w,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 6.w),
                Text(
                  '${'orders.orderId'.tr}: ',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isDark
                        ? DarkColors.textSecondary
                        : LightColors.textSecondary,
                  ),
                ),
                Text(
                  '#${order.id}',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          // Current status header
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  _getStatusIcon(order.status),
                  color: _getStatusColor(order.status),
                  size: 24.w,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStatusLabel(order.status),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(order.status),
                      ),
                    ),
                    Text(
                      _getStatusDescription(order.status),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark
                            ? DarkColors.textSecondary
                            : LightColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (order.isPaid)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 14.w,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'orders.paid'.tr,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 20.h),

          // Simple progress timeline with 4 milestones
          if (order.status != OrderStatusEnum.rejected &&
              order.status != OrderStatusEnum.cancelled &&
              order.status != OrderStatusEnum.expired) ...[
            // Progress bar
            _SimpleProgressBar(progress: progress, isDark: isDark),
            SizedBox(height: 8.h),
            // Milestone labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: isRestaurantDelivered
                  ? [
                      _MilestoneLabel(
                        label: 'orders.statusShort.pending'.tr,
                        isActive: true,
                        isDark: isDark,
                      ),
                      _MilestoneLabel(
                        label: 'orders.status.restaurantDelivered'.tr,
                        isActive: true,
                        isDark: isDark,
                      ),
                    ]
                  : [
                      _MilestoneLabel(
                        label: 'orders.statusShort.pending'.tr,
                        isActive: progress >= 0,
                        isDark: isDark,
                      ),
                      _MilestoneLabel(
                        label: 'orders.statusShort.accepted'.tr,
                        isActive: progress >= 0.5,
                        isDark: isDark,
                      ),
                      _MilestoneLabel(
                        label: 'orders.statusShort.onTheWay'.tr,
                        isActive: progress >= 0.75,
                        isDark: isDark,
                      ),
                      _MilestoneLabel(
                        label: 'orders.statusShort.done'.tr,
                        isActive: progress >= 1.0,
                        isDark: isDark,
                      ),
                    ],
            ),
          ] else ...[
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color:
                    (order.status == OrderStatusEnum.rejected
                            ? AppColors.error
                            : AppColors.warning)
                        .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    order.status == OrderStatusEnum.rejected
                        ? Icons.cancel
                        : order.status == OrderStatusEnum.expired
                        ? Icons.timer_off
                        : Icons.block,
                    color: order.status == OrderStatusEnum.rejected
                        ? AppColors.error
                        : AppColors.warning,
                    size: 20.w,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    order.status == OrderStatusEnum.rejected
                        ? 'orders.orderRejected'.tr
                        : order.status == OrderStatusEnum.expired
                        ? 'coupons.expired'.tr
                        : 'orders.orderCancelled'.tr,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: order.status == OrderStatusEnum.rejected
                          ? AppColors.error
                          : AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Calculate progress value (0.0 to 1.0) for the progress bar
  /// Maps 7 statuses to 4 milestones: New (0), Prep (0.5), Delivery (0.75), Done (1.0)
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

  String _getStatusLabel(OrderStatusEnum status) {
    switch (status) {
      case OrderStatusEnum.pending:
        return 'orders.status.pending'.tr;
      case OrderStatusEnum.searchingForDriver:
        return 'orders.status.searchingForDriver'.tr;
      case OrderStatusEnum.accepted:
        return 'orders.status.accepted'.tr;
      case OrderStatusEnum.driverNotificationSent:
        return 'orders.status.driverNotificationSent'.tr;
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

  String _getStatusDescription(OrderStatusEnum status) {
    switch (status) {
      case OrderStatusEnum.pending:
        return 'orders.statusDesc.pending'.tr;
      case OrderStatusEnum.searchingForDriver:
        return 'orders.statusDesc.searchingForDriver'.tr;
      case OrderStatusEnum.accepted:
        return 'orders.statusDesc.accepted'.tr;
      case OrderStatusEnum.driverNotificationSent:
        return 'orders.statusDesc.driverNotificationSent'.tr;
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
}

class _SimpleProgressBar extends StatelessWidget {
  const _SimpleProgressBar({required this.progress, required this.isDark});

  final double progress;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return LayoutBuilder(
      builder: (context, constraints) {
        final progressWidth = constraints.maxWidth * progress.clamp(0.0, 1.0);

        return SizedBox(
          height: 24.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background track
              Container(
                height: 4.h,
                decoration: BoxDecoration(
                  color: isDark ? DarkColors.border : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              // Progress fill
              Align(
                alignment: isRtl ? Alignment.centerRight : Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  height: 4.h,
                  width: progressWidth,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: isRtl
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      end: isRtl ? Alignment.centerLeft : Alignment.centerRight,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              // Milestone dots
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _MilestoneDot(isActive: progress >= 0, isDark: isDark),
                  _MilestoneDot(isActive: progress >= 0.5, isDark: isDark),
                  _MilestoneDot(isActive: progress >= 0.75, isDark: isDark),
                  _MilestoneDot(isActive: progress >= 1.0, isDark: isDark),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MilestoneDot extends StatelessWidget {
  const _MilestoneDot({required this.isActive, required this.isDark});

  final bool isActive;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 16.w : 12.w,
      height: isActive ? 16.w : 12.w,
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).colorScheme.primary
            : (isDark ? DarkColors.surface : Colors.white),
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : (isDark ? DarkColors.border : Colors.grey[400]!),
          width: 2,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: isActive
          ? Icon(Icons.check, size: 10.w, color: Colors.white)
          : null,
    );
  }
}

class _MilestoneLabel extends StatelessWidget {
  const _MilestoneLabel({
    required this.label,
    required this.isActive,
    required this.isDark,
  });

  final String label;
  final bool isActive;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11.sp,
        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
        color: isActive
            ? Theme.of(context).colorScheme.primary
            : (isDark ? DarkColors.textTertiary : LightColors.textTertiary),
      ),
    );
  }
}

class _OrderItemsCard extends ConsumerWidget {
  const _OrderItemsCard({required this.order, required this.isDark});

  final OrderModel order;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = order.items;
    final menuState = ref.watch(menuProvider);

    // Helper to get price from menu if order item price is 0
    double getItemPrice(OrderItemModel item) {
      if (item.unitPrice > 0) return item.totalPrice;
      // Try to find price from menu
      final menuItem = menuState.items
          .where((m) => m.id == item.menuItemId || m.name == item.name)
          .firstOrNull;
      if (menuItem != null) {
        return menuItem.price * item.quantity;
      }
      return 0;
    }

    if (items.isEmpty) {
      return AppCard(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(
              'orders.noItems'.tr,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark
                    ? DarkColors.textSecondary
                    : LightColors.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    return AppCard(
      child: Column(
        children: items.asMap().entries.map((entry) {
          final item = entry.value;
          final isLast = entry.key == items.length - 1;
          final itemPrice = getItemPrice(item);

          return Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: Text(
                        '${item.quantity}x',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name.isNotEmpty
                              ? item.name
                              : 'orders.unknownItem'.tr,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: isDark
                                ? DarkColors.textPrimary
                                : LightColors.textPrimary,
                          ),
                        ),
                        // Show customizations text (e.g., "no sauce")
                        if (item.customizationsText != null &&
                            item.customizationsText!.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 4.h),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit_note,
                                  size: 14.w,
                                  color: AppColors.warning,
                                ),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    item.customizationsText!,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: isDark
                                          ? DarkColors.textSecondary
                                          : LightColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // Show notes if present
                        if (item.notes != null && item.notes!.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 4.h),
                            child: Text(
                              item.notes!,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontStyle: FontStyle.italic,
                                color: isDark
                                    ? DarkColors.textTertiary
                                    : LightColors.textTertiary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Only show price if available
                  if (itemPrice > 0)
                    Text(
                      '€${itemPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? DarkColors.textPrimary
                            : LightColors.textPrimary,
                      ),
                    ),
                ],
              ),
              if (!isLast) ...[
                SizedBox(height: 12.h),
                Divider(color: isDark ? DarkColors.border : LightColors.border),
                SizedBox(height: 12.h),
              ],
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _PaymentSummaryCard extends ConsumerWidget {
  const _PaymentSummaryCard({required this.order, required this.isDark});

  final OrderModel order;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuState = ref.watch(menuProvider);

    // Calculate subtotal from menu prices if order subtotal is 0
    double calculateSubtotalFromMenu() {
      double total = 0;
      for (final item in order.items) {
        if (item.unitPrice > 0) {
          total += item.totalPrice;
        } else {
          // Try to find price from menu
          final menuItem = menuState.items
              .where((m) => m.id == item.menuItemId || m.name == item.name)
              .firstOrNull;
          if (menuItem != null) {
            total += menuItem.price * item.quantity;
          }
        }
      }
      return total;
    }

    // Get subtotal - try API value first, then calculated, then from menu
    double subtotal = order.subtotal;
    if (subtotal <= 0) {
      subtotal = order.calculatedSubtotal;
    }
    if (subtotal <= 0) {
      subtotal = calculateSubtotalFromMenu();
    }

    final deliveryFee = order.deliveryFee;
    final discountAmount = order.discountAmount;
    final tip = order.tips;
    final total = order.total > 0
        ? order.total
        : (subtotal + deliveryFee - discountAmount + tip);

    // Check if we have any meaningful payment data
    final hasPaymentData = total > 0 || subtotal > 0 || order.isPaid;

    if (!hasPaymentData) {
      return AppCard(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(
              'orders.paymentInfoNotAvailable'.tr,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark
                    ? DarkColors.textSecondary
                    : LightColors.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    return AppCard(
      child: Column(
        children: [
          // Only show subtotal if available
          if (subtotal > 0) ...[
            _SummaryRow(
              label: 'orders.subtotal'.tr,
              value: '€${subtotal.toStringAsFixed(2)}',
              isDark: isDark,
            ),
            SizedBox(height: 8.h),
          ],
          // Only show delivery fee if available
          if (deliveryFee > 0) ...[
            _SummaryRow(
              label: 'orders.deliveryFee'.tr,
              value: '€${deliveryFee.toStringAsFixed(2)}',
              isDark: isDark,
            ),
            SizedBox(height: 8.h),
          ],
          // Only show discount if available
          if (discountAmount > 0) ...[
            _SummaryRow(
              label: 'orders.discount'.tr,
              value: '-€${discountAmount.toStringAsFixed(2)}',
              isDark: isDark,
              isDiscount: true,
            ),
            SizedBox(height: 8.h),
          ],
          // Only show tip if available
          if (tip > 0) ...[
            _SummaryRow(
              label: 'orders.tip'.tr,
              value: '€${tip.toStringAsFixed(2)}',
              isDark: isDark,
            ),
            SizedBox(height: 8.h),
          ],
          // Show total if available
          if (total > 0) ...[
            if (subtotal > 0 ||
                deliveryFee > 0 ||
                discountAmount > 0 ||
                tip > 0) ...[
              Divider(color: isDark ? DarkColors.border : LightColors.border),
              SizedBox(height: 12.h),
            ],
            _SummaryRow(
              label: 'orders.total'.tr,
              value: '€${total.toStringAsFixed(2)}',
              isDark: isDark,
              isTotal: true,
            ),
          ],
          if (order.isPaid) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 16.w,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'orders.paidOnline'.tr,
                    style: TextStyle(
                      fontSize: 13.sp,
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
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.isDark,
    this.isTotal = false,
    this.isDiscount = false,
  });

  final String label;
  final String value;
  final bool isDark;
  final bool isTotal;
  final bool isDiscount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16.sp : 14.sp,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w400,
            color: isDiscount
                ? AppColors.success
                : (isDark ? DarkColors.textPrimary : LightColors.textPrimary),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18.sp : 14.sp,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal
                ? Theme.of(context).colorScheme.primary
                : (isDiscount
                      ? AppColors.success
                      : (isDark
                            ? DarkColors.textPrimary
                            : LightColors.textPrimary)),
          ),
        ),
      ],
    );
  }
}

/// Order info card showing type and manual indicator
class _OrderInfoCard extends StatelessWidget {
  const _OrderInfoCard({required this.order, required this.isDark});

  final OrderModel order;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          // Order type
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    order.orderType == 'FOOD'
                        ? Icons.restaurant
                        : Icons.local_shipping,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20.w,
                  ),
                ),
                SizedBox(width: 12.w),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'orders.orderType'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: isDark
                              ? DarkColors.textSecondary
                              : LightColors.textSecondary,
                        ),
                      ),
                      Text(
                        order.orderType == 'FOOD'
                            ? 'orders.foodOrder'.tr
                            : 'orders.parcelOrder'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? DarkColors.textPrimary
                              : LightColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Badges column
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Payment status indicator (always visible)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: order.isPaid
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: order.isPaid
                        ? AppColors.success.withValues(alpha: 0.3)
                        : AppColors.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      order.isPaid ? Icons.check_circle : Icons.pending,
                      color: order.isPaid
                          ? AppColors.success
                          : AppColors.warning,
                      size: 16.w,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      order.isPaid ? 'orders.paid'.tr : 'orders.unpaid'.tr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: order.isPaid
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
              // Manual order indicator
              if (order.isManual) ...[
                SizedBox(height: 6.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit_note,
                        color: AppColors.warning,
                        size: 16.w,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'orders.manualOrder'.tr,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Addresses card showing pickup and dropoff locations
class _AddressesCard extends StatelessWidget {
  const _AddressesCard({required this.order, required this.isDark});

  final OrderModel order;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    // Get coordinates from dropoffAddress or legacy address
    final dropoffLat = order.dropoffAddress?.lat ?? order.address.latitude;
    final dropoffLng = order.dropoffAddress?.lng ?? order.address.longitude;

    return AppCard(
      child: Column(
        children: [
          // Pickup address
          _AddressRow(
            icon: Icons.store,
            iconColor: AppColors.info,
            label: 'orders.pickupFrom'.tr,
            address:
                order.pickupAddress?.displayAddress ??
                order.restaurant?.address ??
                'orders.addressNotAvailable'.tr,
            sublabel: order.pickupAddress?.label ?? order.restaurant?.name,
            isDark: isDark,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Row(
              children: [
                SizedBox(width: 12.w),
                Container(
                  width: 2.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: isDark ? DarkColors.border : LightColors.border,
                    borderRadius: BorderRadius.circular(1.r),
                  ),
                ),
                SizedBox(width: 12.w),
                Icon(
                  Icons.arrow_downward,
                  size: 16.w,
                  color: isDark
                      ? DarkColors.textTertiary
                      : LightColors.textTertiary,
                ),
              ],
            ),
          ),
          // Dropoff address
          _AddressRow(
            icon: Icons.location_on,
            iconColor: AppColors.error,
            label: 'orders.deliverTo'.tr,
            address:
                order.dropoffAddress?.displayAddress ?? order.address.street,
            sublabel: order.customerName != 'Customer'
                ? order.customerName
                : null,
            isDark: isDark,
            latitude: dropoffLat,
            longitude: dropoffLng,
          ),
        ],
      ),
    );
  }
}

class _AddressRow extends StatelessWidget {
  const _AddressRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.address,
    required this.isDark,
    this.sublabel,
    this.latitude,
    this.longitude,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String address;
  final String? sublabel;
  final bool isDark;
  final double? latitude;
  final double? longitude;

  bool get hasCoordinates => latitude != null && longitude != null;

  String get googleMapsUrl =>
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

  Future<void> _openInMaps() async {
    if (!hasCoordinates) return;
    final uri = Uri.parse(googleMapsUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _copyMapsLink(BuildContext context) {
    if (!hasCoordinates) return;
    Clipboard.setData(ClipboardData(text: googleMapsUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('orders.linkCopied'.tr),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(icon, color: iconColor, size: 16.w),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isDark
                          ? DarkColors.textTertiary
                          : LightColors.textTertiary,
                    ),
                  ),
                  if (sublabel != null) ...[
                    Text(
                      sublabel!,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? DarkColors.textPrimary
                            : LightColors.textPrimary,
                      ),
                    ),
                  ],
                  Text(
                    address,
                    style: TextStyle(
                      fontSize: 13.sp,
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
        // Maps buttons
        if (hasCoordinates) ...[
          SizedBox(height: 8.h),
          Row(
            children: [
              SizedBox(width: 40.w), // Align with address text
              _MapActionButton(
                icon: Icons.map_outlined,
                label: 'orders.openInMaps'.tr,
                onTap: _openInMaps,
              ),
              SizedBox(width: 8.w),
              _MapActionButton(
                icon: Icons.copy,
                label: 'orders.copyMapsLink'.tr,
                onTap: () => _copyMapsLink(context),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _MapActionButton extends StatelessWidget {
  const _MapActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12.w,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Driver card showing assigned driver info
class _DriverCard extends StatelessWidget {
  const _DriverCard({required this.driver, required this.isDark});

  final OrderDriverModel driver;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.delivery_dining,
              color: Theme.of(context).colorScheme.primary,
              size: 24.w,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver.name,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? DarkColors.textPrimary
                        : LightColors.textPrimary,
                  ),
                ),
                if (driver.phone != null)
                  Text(
                    driver.phone!,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isDark
                          ? DarkColors.textSecondary
                          : LightColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          if (driver.isVerified)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified, color: AppColors.success, size: 14.w),
                  SizedBox(width: 4.w),
                  Text(
                    'orders.verified'.tr,
                    style: TextStyle(fontSize: 11.sp, color: AppColors.success),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Delivery options card showing vehicle and delivery type
class _DeliveryOptionsCard extends StatelessWidget {
  const _DeliveryOptionsCard({required this.order, required this.isDark});

  final OrderModel order;
  final bool isDark;

  IconData _getVehicleIcon(String? type) {
    switch (type?.toUpperCase()) {
      case 'BIKE':
        return Icons.pedal_bike;
      case 'MOTORCYCLE':
        return Icons.two_wheeler;
      case 'CAR':
        return Icons.directions_car;
      case 'VAN':
        return Icons.local_shipping;
      default:
        return Icons.local_shipping;
    }
  }

  String _getVehicleLabel(String? type) {
    switch (type?.toUpperCase()) {
      case 'BIKE':
        return 'orders.vehicleType.bike'.tr;
      case 'MOTORCYCLE':
        return 'orders.vehicleType.motorcycle'.tr;
      case 'CAR':
        return 'orders.vehicleType.car'.tr;
      case 'VAN':
        return 'orders.vehicleType.van'.tr;
      default:
        return type ?? 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          if (order.requestedVehicleType != null) ...[
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      _getVehicleIcon(order.requestedVehicleType),
                      color: Colors.purple,
                      size: 20.w,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'orders.requestedVehicleType'.tr,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: isDark
                              ? DarkColors.textSecondary
                              : LightColors.textSecondary,
                        ),
                      ),
                      Text(
                        _getVehicleLabel(order.requestedVehicleType),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? DarkColors.textPrimary
                              : LightColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Coupon card showing applied coupon
class _CouponCard extends StatelessWidget {
  const _CouponCard({required this.coupon, required this.isDark});

  final OrderCouponModel coupon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.local_offer,
              color: AppColors.success,
              size: 20.w,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coupon.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? DarkColors.textPrimary
                        : LightColors.textPrimary,
                  ),
                ),
                Text(
                  coupon.code,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark
                        ? DarkColors.textSecondary
                        : LightColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              '-${coupon.percentage}%',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
