import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:teybatseller/core/i18n/i18n.dart';
import 'package:teybatseller/core/theme/theme.dart';
import 'package:teybatseller/features/tour/application/tour_notifier.dart';
import 'package:teybatseller/features/tour/data/models/tour_step_model.dart';

/// Tour tooltip with step information - redesigned with better card style
class TourTooltip extends ConsumerStatefulWidget {
  const TourTooltip({
    required this.step,
    super.key,
  });

  final TourStepModel step;

  @override
  ConsumerState<TourTooltip> createState() => _TourTooltipState();
}

class _TourTooltipState extends ConsumerState<TourTooltip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(TourTooltip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step.id != widget.step.id) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tourState = ref.watch(tourProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    // Calculate position
    final screenSize = MediaQuery.of(context).size;
    final tooltipPosition = _calculatePosition(screenSize);

    return Positioned(
      top: tooltipPosition.dy,
      left: tooltipPosition.dx,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            width: min(screenSize.width - 40.w, 340.w),
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: isDark ? DarkColors.surface : Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Step counter badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '${'tour.step'.tr} ${tourState.currentStepIndex + 1} ${'tour.of'.tr} ${tourState.totalSteps}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // Title
                Text(
                  widget.step.titleKey.tr,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
                    height: 1.3,
                  ),
                ),

                SizedBox(height: 12.h),

                // Description
                Text(
                  widget.step.descriptionKey.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    height: 1.5,
                    color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
                  ),
                ),

                SizedBox(height: 16.h),

                // Action hint with icon
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getActionIcon(widget.step.actions.first),
                        size: 16.w,
                        color: primaryColor,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        _getActionHintText(widget.step.actions.first),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Offset _calculatePosition(Size screenSize) {
    // Position tooltip at the center-top of screen for now
    // In a full implementation, this would calculate based on the target widget position
    final double top = 100.h;
    final double left = 20.w;

    return Offset(left, top);
  }

  IconData _getActionIcon(TourAction action) {
    switch (action) {
      case TourAction.tap:
        return Icons.touch_app;
      case TourAction.swipe:
        return Icons.swipe;
      case TourAction.navigate:
        return Icons.navigation;
      case TourAction.observe:
        return Icons.visibility;
      case TourAction.interact:
        return Icons.touch_app;
    }
  }

  String _getActionHintText(TourAction action) {
    switch (action) {
      case TourAction.tap:
        return 'tour.actionHint.tap'.tr;
      case TourAction.swipe:
        return 'tour.actionHint.swipe'.tr;
      case TourAction.navigate:
        return 'tour.actionHint.navigate'.tr;
      case TourAction.observe:
        return 'tour.actionHint.observe'.tr;
      case TourAction.interact:
        return 'tour.actionHint.interact'.tr;
    }
  }

  T min<T extends num>(T a, T b) => a < b ? a : b;
}
