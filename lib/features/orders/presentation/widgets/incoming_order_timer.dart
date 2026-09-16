import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';
import '../../data/models/order_model.dart';

/// Displays the seller's response state or the backend-owned driver dispatch
/// countdown for an incoming order.
///
/// The countdown is only a presentation of server-provided timing. It never
/// changes the order state locally or attempts to request a driver itself.
class IncomingOrderTimer extends StatefulWidget {
  const IncomingOrderTimer({
    required this.order,
    required this.textPrimary,
    required this.textSecondary,
    this.onRefresh,
    super.key,
  });

  final OrderModel order;
  final Color textPrimary;
  final Color textSecondary;
  final Future<void> Function()? onRefresh;

  @override
  State<IncomingOrderTimer> createState() => _IncomingOrderTimerState();
}

class _IncomingOrderTimerState extends State<IncomingOrderTimer>
    with WidgetsBindingObserver {
  Timer? _clockTimer;
  DateTime _localServerSampleAt = DateTime.now().toUtc();
  bool _hasRefreshedAtZero = false;
  bool _hasRefreshedPreparationAtZero = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _localServerSampleAt =
        widget.order.timingReceivedAt ?? DateTime.now().toUtc();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      var needsRefresh = false;
      if (_isCountdownState &&
          _remainingDispatchSeconds(widget.order) <= 0 &&
          !_hasRefreshedAtZero) {
        _hasRefreshedAtZero = true;
        needsRefresh = true;
      }
      if (widget.order.showPreparationEstimate &&
          _remainingPreparationSeconds(widget.order) <= 0 &&
          !_hasRefreshedPreparationAtZero) {
        _hasRefreshedPreparationAtZero = true;
        needsRefresh = true;
      }
      final refresh = widget.onRefresh;
      if (needsRefresh && refresh != null) unawaited(refresh());
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant IncomingOrderTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.order.id != widget.order.id ||
        oldWidget.order.driverDispatchStatus !=
            widget.order.driverDispatchStatus ||
        oldWidget.order.driverDispatchDueAt !=
            widget.order.driverDispatchDueAt) {
      _hasRefreshedAtZero = false;
    }
    if (oldWidget.order.id != widget.order.id ||
        oldWidget.order.preparationReadyAt != widget.order.preparationReadyAt) {
      _hasRefreshedPreparationAtZero = false;
    }
    if (oldWidget.order != widget.order) {
      _localServerSampleAt =
          widget.order.timingReceivedAt ?? DateTime.now().toUtc();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !mounted) return;
    _hasRefreshedAtZero = false;
    setState(() {});
    final refresh = widget.onRefresh;
    if (refresh != null) unawaited(refresh());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    if (order.isCompleted || order.status == OrderStatusEnum.onTheWay) {
      return const SizedBox.shrink();
    }
    final dispatch = _buildDispatchState(order);
    if (!order.showPreparationEstimate) return dispatch;
    final remaining = _remainingPreparationSeconds(order);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStateBanner(
          icon: Icons.restaurant_rounded,
          color: remaining > 0 ? AppColors.info : AppColors.warning,
          title: remaining > 0
              ? '${'orders.preparation.readyIn'.tr} ${_formatDuration(remaining)}'
              : 'orders.preparation.estimateElapsed'.tr,
          subtitle: 'orders.preparation.estimateExplanation'.tr,
          trailingIcon: Icons.schedule_rounded,
        ),
        SizedBox(height: 8.h),
        dispatch,
      ],
    );
  }

  Widget _buildDispatchState(OrderModel order) {
    final dispatchStatus = order.driverDispatchStatus?.toUpperCase();
    final hasCountdown = _isCountdownState;

    if (dispatchStatus == 'SEARCHING') {
      return _buildMatchingState();
    }
    if (dispatchStatus == 'ASSIGNED') {
      return _buildAssignedState();
    }

    if (hasCountdown) {
      return _buildCountdown(order);
    }

    return _buildWaitingState(order);
  }

  bool get _isCountdownState {
    if (widget.order.isCompleted ||
        widget.order.status == OrderStatusEnum.onTheWay) {
      return false;
    }
    final status = widget.order.driverDispatchStatus?.toUpperCase();
    if (status == 'SEARCHING' || status == 'ASSIGNED') return false;
    return widget.order.hasDriverDispatchTimer ||
        status == 'SCHEDULED' ||
        status == 'DUE';
  }

  Widget _buildCountdown(OrderModel order) {
    final remainingSeconds = _remainingDispatchSeconds(order);
    final totalSeconds = math.max(
      1,
      (order.driverDispatchDelayMinutes ??
              math.max(
                0,
                (order.preparationTimeMinutes ?? 0) -
                    (order.driverDispatchLeadMinutes ?? 5),
              )) *
          60,
    );
    final progress = (remainingSeconds / totalSeconds).clamp(0.0, 1.0);
    final due = remainingSeconds <= 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(11.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.34)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 50.w,
            height: 50.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ExcludeSemantics(
                  // The parent order card owns the details action. Without
                  // excluding this progress semantics node, Flutter Web can
                  // expose the entire card as a non-tappable progress bar.
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 4.5,
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                Icon(
                  due ? Icons.bolt_rounded : Icons.timer_outlined,
                  color: AppColors.primary[100],
                  size: 20.w,
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  due
                      ? 'orders.incoming.driverReady'.tr
                      : 'orders.incoming.driverRequestIn'.tr,
                  style: TextStyle(
                    color: widget.textSecondary,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  ),
                  child: Text(
                    due ? '00:00' : _formatDuration(remainingSeconds),
                    key: ValueKey(remainingSeconds),
                    style: TextStyle(
                      color: widget.textPrimary,
                      fontSize: 21.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.cloud_done_outlined,
            color: AppColors.primary[100],
            size: 20.w,
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingState(OrderModel order) {
    final isPending = order.status == OrderStatusEnum.pending;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(11.w),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.timer_outlined,
              color: AppColors.warning,
              size: 24.w,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'orders.incoming.responseStatus'.tr,
                  style: TextStyle(
                    color: widget.textSecondary,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'orders.statusDesc.pending'.tr,
                  style: TextStyle(
                    color: widget.textPrimary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  isPending
                      ? 'orders.incoming.timerStartsAfterAccept'.tr
                      : 'orders.driverDispatchNotScheduled'.tr,
                  style: TextStyle(color: widget.textSecondary, fontSize: 9.sp),
                ),
              ],
            ),
          ),
          Text(
            _formatReceivedAge(_elapsedSinceReceived(order)),
            textAlign: TextAlign.end,
            style: TextStyle(
              color: AppColors.warning,
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchingState() {
    return _buildStateBanner(
      icon: Icons.person_search_rounded,
      color: AppColors.info,
      title: 'orders.driverMatching'.tr,
      subtitle: 'orders.statusDesc.searchingForDriver'.tr,
    );
  }

  Widget _buildAssignedState() {
    return _buildStateBanner(
      icon: Icons.local_shipping_rounded,
      color: AppColors.success,
      title: 'orders.driverAssigned'.tr,
      subtitle: 'orders.driverAssigned'.tr,
    );
  }

  Widget _buildStateBanner({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    IconData trailingIcon = Icons.check_circle_outline_rounded,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(11.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24.w),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: widget.textPrimary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: widget.textSecondary,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),
          Icon(trailingIcon, color: color, size: 20.w),
        ],
      ),
    );
  }

  int _elapsedSinceReceived(OrderModel order) {
    final seconds = DateTime.now()
        .toUtc()
        .difference(order.createdAt.toUtc())
        .inSeconds;
    return math.max(0, seconds);
  }

  int _remainingDispatchSeconds(OrderModel order) {
    final dueAt = order.driverDispatchDueAt;
    if (dueAt != null) {
      final now = DateTime.now().toUtc();
      final serverTime = order.driverDispatchServerTime?.toUtc();
      final serverNow = serverTime == null
          ? now
          : serverTime.add(now.difference(_localServerSampleAt));
      return math.max(0, dueAt.toUtc().difference(serverNow).inSeconds);
    }

    final remaining = order.driverDispatchRemainingSeconds;
    if (remaining == null) return 0;
    final elapsed = DateTime.now().toUtc().difference(_localServerSampleAt);
    return math.max(0, remaining - elapsed.inSeconds);
  }

  int _remainingPreparationSeconds(OrderModel order) {
    final now = DateTime.now().toUtc();
    final serverTime =
        order.preparationServerTime ?? order.driverDispatchServerTime;
    final serverNow = serverTime == null
        ? now
        : serverTime.toUtc().add(now.difference(_localServerSampleAt));
    final readyAt = order.preparationReadyAt;
    if (readyAt != null) {
      return math.max(0, readyAt.toUtc().difference(serverNow).inSeconds);
    }
    return math.max(
      0,
      (order.preparationRemainingSeconds ?? 0) -
          now.difference(_localServerSampleAt).inSeconds,
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainder = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainder.toString().padLeft(2, '0')}';
  }

  String _formatReceivedAge(int seconds) {
    if (seconds < 60) {
      return 'orders.incoming.receivedSecondsAgo'.trParams({
        'count': '$seconds',
      });
    }
    if (seconds < 3600) {
      return 'orders.incoming.receivedMinutesAgo'.trParams({
        'count': '${seconds ~/ 60}',
      });
    }
    if (seconds < 86400) {
      return 'orders.incoming.receivedHoursAgo'.trParams({
        'count': '${seconds ~/ 3600}',
      });
    }
    return 'orders.incoming.receivedDaysAgo'.trParams({
      'count': '${seconds ~/ 86400}',
    });
  }
}
