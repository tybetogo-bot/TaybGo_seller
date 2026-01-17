import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../menu/application/menu_notifier.dart';
import '../../application/orders_notifier.dart';
import '../../data/models/order_model.dart';
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleStatusAction(OrderModel order) async {
    if (_isProcessing) return;

    // Get the target status for confirmation
    final targetStatus = _getTargetStatus(order.status);
    if (targetStatus == null) return;

    // Show confirmation dialog
    final confirmed = await _showStatusConfirmationDialog(order.status, targetStatus);
    if (confirmed != true) return;

    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();

    // Flow: Pending → Searching → Driver Notified → Accepted → On the Way → Delivered → Completed
    // Use moveToNextStatus to advance to the next status in sequence
    final success = await ref.read(ordersProvider.notifier).moveToNextStatus(order.id);

    if (mounted) {
      if (success) {
        _showSuccessSnackBar('orders.statusUpdatedTo'.tr.replaceAll('{status}', _getStatusDisplayName(targetStatus)));
      } else {
        final error = ref.read(ordersProvider).error;
        _showErrorSnackBar(error ?? 'orders.statusUpdateFailed'.tr);
      }
      setState(() => _isProcessing = false);
    }
  }

  OrderStatusEnum? _getTargetStatus(OrderStatusEnum currentStatus) {
    // Flow: Pending → Searching → Driver Notified → Accepted → On the Way → Delivered → Completed
    // Each status moves to the next one in sequence
    switch (currentStatus) {
      case OrderStatusEnum.pending:
        return OrderStatusEnum.searchingForDriver;
      case OrderStatusEnum.searchingForDriver:
        return OrderStatusEnum.driverNotificationSent;
      case OrderStatusEnum.driverNotificationSent:
        return OrderStatusEnum.accepted;
      case OrderStatusEnum.accepted:
        return OrderStatusEnum.onTheWay;
      case OrderStatusEnum.onTheWay:
        return OrderStatusEnum.delivered;
      case OrderStatusEnum.delivered:
        return OrderStatusEnum.completed;
      default:
        return null;
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
      case OrderStatusEnum.completed:
        return 'orders.status.completed'.tr;
      case OrderStatusEnum.rejected:
        return 'orders.status.rejected'.tr;
      case OrderStatusEnum.cancelled:
        return 'orders.status.cancelled'.tr;
    }
  }

  Future<bool?> _showStatusConfirmationDialog(OrderStatusEnum currentStatus, OrderStatusEnum targetStatus) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
                  child: Icon(Icons.arrow_forward, color: AppColors.primary),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'orders.to'.tr,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          _getStatusDisplayName(targetStatus),
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
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
            onPressed: () => Navigator.pop(context, false),
            child: Text('common.cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text('orders.update'.tr),
          ),
        ],
      ),
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

  @override
  Widget build(BuildContext context) {
    ref.watch(translationsLoadedProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final order = ref.watch(orderByIdProvider(widget.orderId));

    if (order == null) {
      return AppScaffold(
        appBar: AppAppBar(
          title: 'orders.orderDetails'.tr,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48.w,
                color: AppColors.error,
              ),
              SizedBox(height: 16.h),
              Text(
                'orderNotFound'.tr,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return AppScaffold(
      appBar: AppAppBar(
        title: '${'orders.orderDetails'.tr} #${order.id}',
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
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status timeline
              _OrderStatusTimeline(order: order, isDark: isDark),
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
                _SectionTitle(title: 'orders.driverInfo'.tr, isDark: isDark),
                SizedBox(height: 12.h),
                _DriverCard(driver: order.driver!, isDark: isDark),
                SizedBox(height: 20.h),
              ],

              // Delivery options (vehicle type)
              if (order.requestedVehicleType != null || order.requestedDeliveryType != null) ...[
                _SectionTitle(title: 'orders.deliveryOptions'.tr, isDark: isDark),
                SizedBox(height: 12.h),
                _DeliveryOptionsCard(order: order, isDark: isDark),
                SizedBox(height: 20.h),
              ],

              // Order items
              _SectionTitle(title: 'orders.orderItems'.tr, isDark: isDark),
              SizedBox(height: 12.h),
              _OrderItemsCard(order: order, isDark: isDark),
              SizedBox(height: 20.h),

              // Coupon info (if applied)
              if (order.coupon != null) ...[
                _SectionTitle(title: 'orders.couponApplied'.tr, isDark: isDark),
                SizedBox(height: 12.h),
                _CouponCard(coupon: order.coupon!, isDark: isDark),
                SizedBox(height: 20.h),
              ],

              // Payment summary
              _SectionTitle(title: 'orders.payment'.tr, isDark: isDark),
              SizedBox(height: 12.h),
              _PaymentSummaryCard(order: order, isDark: isDark),
              SizedBox(height: 24.h),

              // Action buttons based on status
              _buildActionButtons(order, isDark),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(OrderModel order, bool isDark) {
    final status = order.status;

    // Flow: Pending → Searching → Driver Notified → Accepted/Rejected → On the Way → Delivered → Completed
    // Completed or cancelled orders don't need action buttons
    if (status == OrderStatusEnum.completed ||
        status == OrderStatusEnum.rejected ||
        status == OrderStatusEnum.cancelled) {
      return const SizedBox.shrink();
    }

    // Get the next status label for the button
    final targetStatus = _getTargetStatus(status);
    if (targetStatus == null) return const SizedBox.shrink();

    // Show Update Status button for all active statuses
    return AppButton(
      label: '${'orders.updateStatus'.tr}: ${_getStatusDisplayName(targetStatus)}',
      icon: _getStatusIcon(targetStatus),
      isLoading: _isProcessing,
      onPressed: () => _handleStatusAction(order),
      isFullWidth: true,
    );
  }

  IconData _getStatusIcon(OrderStatusEnum status) {
    switch (status) {
      case OrderStatusEnum.pending:
        return Icons.hourglass_empty;
      case OrderStatusEnum.searchingForDriver:
        return Icons.search;
      case OrderStatusEnum.driverNotificationSent:
        return Icons.notifications_active;
      case OrderStatusEnum.accepted:
        return Icons.check_circle_outline;
      case OrderStatusEnum.onTheWay:
        return Icons.delivery_dining;
      case OrderStatusEnum.delivered:
        return Icons.done_all;
      case OrderStatusEnum.completed:
        return Icons.verified;
      case OrderStatusEnum.rejected:
      case OrderStatusEnum.cancelled:
        return Icons.cancel;
    }
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
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.tag,
                  size: 16.w,
                  color: AppColors.primary,
                ),
                SizedBox(width: 6.w),
                Text(
                  '${'orders.orderId'.tr}: ',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
                  ),
                ),
                Text(
                  '#${order.id}',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
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
                      Icon(Icons.check_circle, color: AppColors.success, size: 14.w),
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
              order.status != OrderStatusEnum.cancelled) ...[
            // Progress bar
            _SimpleProgressBar(progress: progress, isDark: isDark),
            SizedBox(height: 8.h),
            // 4 milestone labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.cancel, color: AppColors.error, size: 20.w),
                  SizedBox(width: 8.w),
                  Text(
                    order.status == OrderStatusEnum.rejected
                        ? 'orders.orderRejected'.tr
                        : 'orders.orderCancelled'.tr,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.error,
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
        return AppColors.warning;
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
        return Icons.pending_actions;
      case OrderStatusEnum.searchingForDriver:
        return Icons.search;
      case OrderStatusEnum.accepted:
        return Icons.thumb_up_alt;
      case OrderStatusEnum.driverNotificationSent:
        return Icons.person_pin;
      case OrderStatusEnum.onTheWay:
        return Icons.delivery_dining;
      case OrderStatusEnum.delivered:
      case OrderStatusEnum.completed:
        return Icons.check_circle;
      case OrderStatusEnum.rejected:
      case OrderStatusEnum.cancelled:
        return Icons.cancel;
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
      case OrderStatusEnum.completed:
        return 'orders.status.completed'.tr;
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
      case OrderStatusEnum.completed:
        return 'orders.statusDesc.completed'.tr;
      case OrderStatusEnum.rejected:
        return 'orders.statusDesc.rejected'.tr;
      case OrderStatusEnum.cancelled:
        return 'orders.statusDesc.cancelled'.tr;
    }
  }
}

class _SimpleProgressBar extends StatelessWidget {
  const _SimpleProgressBar({
    required this.progress,
    required this.isDark,
  });

  final double progress;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress bar with milestone dots
        SizedBox(
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
                alignment: Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  height: 4.h,
                  width: MediaQuery.of(context).size.width * 0.85 * progress,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
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
        ),
      ],
    );
  }
}

class _MilestoneDot extends StatelessWidget {
  const _MilestoneDot({
    required this.isActive,
    required this.isDark,
  });

  final bool isActive;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 16.w : 12.w,
      height: isActive ? 16.w : 12.w,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : (isDark ? DarkColors.surface : Colors.white),
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? AppColors.primary : (isDark ? DarkColors.border : Colors.grey[400]!),
          width: 2,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
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
            ? AppColors.primary
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
                color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
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
                      color: AppColors.primary[50],
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: Text(
                        '${item.quantity}x',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
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
                          item.name.isNotEmpty ? item.name : 'orders.unknownItem'.tr,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: isDark
                                ? DarkColors.textPrimary
                                : LightColors.textPrimary,
                          ),
                        ),
                        // Show customizations text (e.g., "no sauce")
                        if (item.customizationsText != null && item.customizationsText!.isNotEmpty)
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
                      '\$${itemPrice.toStringAsFixed(2)}',
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
    final total = order.total > 0 ? order.total : (subtotal + deliveryFee - discountAmount + tip);

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
                color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
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
              value: '\$${subtotal.toStringAsFixed(2)}',
              isDark: isDark,
            ),
            SizedBox(height: 8.h),
          ],
          // Only show delivery fee if available
          if (deliveryFee > 0) ...[
            _SummaryRow(
              label: 'orders.deliveryFee'.tr,
              value: '\$${deliveryFee.toStringAsFixed(2)}',
              isDark: isDark,
            ),
            SizedBox(height: 8.h),
          ],
          // Only show discount if available
          if (discountAmount > 0) ...[
            _SummaryRow(
              label: 'orders.discount'.tr,
              value: '-\$${discountAmount.toStringAsFixed(2)}',
              isDark: isDark,
              isDiscount: true,
            ),
            SizedBox(height: 8.h),
          ],
          // Only show tip if available
          if (tip > 0) ...[
            _SummaryRow(
              label: 'orders.tip'.tr,
              value: '\$${tip.toStringAsFixed(2)}',
              isDark: isDark,
            ),
            SizedBox(height: 8.h),
          ],
          // Show total if available
          if (total > 0) ...[
            if (subtotal > 0 || deliveryFee > 0 || discountAmount > 0 || tip > 0) ...[
              Divider(color: isDark ? DarkColors.border : LightColors.border),
              SizedBox(height: 12.h),
            ],
            _SummaryRow(
              label: 'orders.total'.tr,
              value: '\$${total.toStringAsFixed(2)}',
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
                  Icon(Icons.check_circle, color: AppColors.success, size: 16.w),
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
                ? AppColors.primary
                : (isDiscount
                    ? AppColors.success
                    : (isDark ? DarkColors.textPrimary : LightColors.textPrimary)),
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
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    order.orderType == 'FOOD' ? Icons.restaurant : Icons.local_shipping,
                    color: AppColors.primary,
                    size: 20.w,
                  ),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'orders.orderType'.tr,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
                      ),
                    ),
                    Text(
                      order.orderType == 'FOOD' ? 'orders.foodOrder'.tr : 'orders.parcelOrder'.tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Manual order indicator
          if (order.isManual)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_note, color: AppColors.warning, size: 16.w),
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
    return AppCard(
      child: Column(
        children: [
          // Pickup address
          _AddressRow(
            icon: Icons.store,
            iconColor: AppColors.info,
            label: 'orders.pickupFrom'.tr,
            address: order.pickupAddress?.displayAddress ??
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
                  color: isDark ? DarkColors.textTertiary : LightColors.textTertiary,
                ),
              ],
            ),
          ),
          // Dropoff address
          _AddressRow(
            icon: Icons.location_on,
            iconColor: AppColors.error,
            label: 'orders.deliverTo'.tr,
            address: order.dropoffAddress?.displayAddress ??
                     order.address.street,
            sublabel: order.customerName != 'Customer' ? order.customerName : null,
            isDark: isDark,
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
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String address;
  final String? sublabel;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
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
                  color: isDark ? DarkColors.textTertiary : LightColors.textTertiary,
                ),
              ),
              if (sublabel != null) ...[
                Text(
                  sublabel!,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
                  ),
                ),
              ],
              Text(
                address,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
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
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.delivery_dining,
              color: AppColors.primary,
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
                    color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
                  ),
                ),
                if (driver.phone != null)
                  Text(
                    driver.phone!,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
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
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.success,
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
                          color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
                        ),
                      ),
                      Text(
                        _getVehicleLabel(order.requestedVehicleType),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
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
                    color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
                  ),
                ),
                Text(
                  coupon.code,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
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
