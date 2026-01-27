import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:teybatseller/core/i18n/i18n.dart';
import 'package:teybatseller/core/theme/app_shadows.dart';
import 'package:teybatseller/core/theme/app_spacing.dart';
import 'package:teybatseller/features/tour/application/tour_notifier.dart';
import 'package:teybatseller/features/tour/data/models/tour_step_model.dart';
import 'package:teybatseller/features/tour/utils/tour_keys.dart';

/// Tooltip showing tour step instructions
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
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void didUpdateWidget(TourTooltip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step.id != widget.step.id) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Offset _calculateTooltipPosition(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    Rect? targetRect;

    if (widget.step.targetWidgetKey != null) {
      targetRect = TourKeys.getWidgetBounds(widget.step.targetWidgetKey!);
    }

    // Default position (center)
    double x = 20.w;
    double y = screenSize.height * 0.4;

    if (targetRect != null) {
      final tooltipHeight = 200.h; // Approximate tooltip height

      // Try to position based on preference and available space
      switch (widget.step.tooltipPosition) {
        case TooltipPosition.top:
          y = targetRect.top - tooltipHeight - 16.h;
          if (y < MediaQuery.of(context).padding.top + 60.h) {
            // Not enough space at top, try bottom
            y = targetRect.bottom + 16.h;
          }
        case TooltipPosition.bottom:
          y = targetRect.bottom + 16.h;
          if (y + tooltipHeight > screenSize.height - 100.h) {
            // Not enough space at bottom, try top
            y = targetRect.top - tooltipHeight - 16.h;
          }
        case TooltipPosition.left:
        case TooltipPosition.right:
        case TooltipPosition.auto:
          // Auto-position: prefer bottom, then top
          if (targetRect.bottom + tooltipHeight + 16.h <
              screenSize.height - 100.h) {
            y = targetRect.bottom + 16.h;
          } else {
            y = targetRect.top - tooltipHeight - 16.h;
          }
      }

      // Keep y within safe bounds
      final topPadding = MediaQuery.of(context).padding.top + 60.h;
      final bottomPadding = 100.h;
      y = y.clamp(topPadding, screenSize.height - bottomPadding - tooltipHeight);
    }

    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    final tourState = ref.watch(tourProvider);
    final position = _calculateTooltipPosition(context);

    return Positioned(
      top: position.dy,
      left: position.dx,
      right: 20.w,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            constraints: BoxConstraints(maxWidth: 300.w),
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: AppShadows.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Step counter
                Text(
                  '${'tour.step'.tr} ${tourState.currentStepIndex + 1} ${'tour.of'.tr} ${tourState.totalSteps}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                SizedBox(height: AppSpacing.sm),

                // Title
                Text(
                  widget.step.titleKey.tr,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: AppSpacing.sm),

                // Description
                Text(
                  widget.step.descriptionKey.tr,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: AppSpacing.md),

                // Action hint
                _ActionHint(action: widget.step.actions.first),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget showing action hint (tap, swipe, etc.)
class _ActionHint extends StatelessWidget {
  const _ActionHint({required this.action});

  final TourAction action;

  IconData get _icon {
    switch (action) {
      case TourAction.tap:
        return Icons.touch_app;
      case TourAction.swipe:
        return Icons.swipe;
      case TourAction.navigate:
        return Icons.arrow_forward;
      case TourAction.observe:
        return Icons.visibility;
      case TourAction.interact:
        return Icons.touch_app;
    }
  }

  String get _hintKey {
    switch (action) {
      case TourAction.tap:
        return 'tour.actionHint.tap';
      case TourAction.swipe:
        return 'tour.actionHint.swipe';
      case TourAction.navigate:
        return 'tour.actionHint.navigate';
      case TourAction.observe:
        return 'tour.actionHint.observe';
      case TourAction.interact:
        return 'tour.actionHint.interact';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          _icon,
          size: 16.sp,
          color: Theme.of(context)
              .textTheme
              .bodySmall
              ?.color
              ?.withAlpha(153),
        ),
        SizedBox(width: AppSpacing.xs),
        Text(
          _hintKey.tr,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
