import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:teybatseller/core/i18n/i18n.dart';
import 'package:teybatseller/core/theme/theme.dart';
import 'package:teybatseller/features/menu/application/menu_notifier.dart';
import 'package:teybatseller/features/orders/application/orders_notifier.dart';
import 'package:teybatseller/features/profile/application/user_profile_notifier.dart';
import 'package:teybatseller/features/restaurant/application/restaurant_state.dart';
import 'package:teybatseller/features/tour/application/mock_providers.dart';
import 'package:teybatseller/features/tour/application/tour_notifier.dart';
import 'package:teybatseller/features/tour/data/tour_steps_data.dart';

void _tourLog(String message) {
  if (kDebugMode) {
    debugPrint('🎯 [Tour] $message');
  }
}

/// Professional tour overlay with clear highlighting and readable tooltips
class TourOverlay extends ConsumerWidget {
  const TourOverlay({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tourState = ref.watch(tourProvider);

    _tourLog('TourOverlay.build() → isActive=${tourState.isActive}, '
        'step=${tourState.currentStepIndex}/${tourState.totalSteps}, '
        'type=${tourState.tourType}');

    // If tour is not active, show normal app
    if (!tourState.isActive) {
      _tourLog('TourOverlay: tour not active, returning plain child');
      return child;
    }

    // Get current tour step
    final steps = TourSteps.getStepsForTourType(tourState.tourType);
    if (tourState.currentStepIndex >= steps.length) {
      _tourLog('TourOverlay: stepIndex ${tourState.currentStepIndex} >= '
          'steps.length ${steps.length}, returning plain child');
      return child;
    }

    final currentStep = steps[tourState.currentStepIndex];
    _tourLog('TourOverlay: rendering step "${currentStep.id}" '
        '(targetScreen=${currentStep.targetScreen}, '
        'targetKey=${currentStep.targetWidgetKey?.toString()})');

    // Read the app's actual theme data from providers so we can
    // provide it to the tour spotlight (which sits outside MaterialApp).
    final accentColor = ref.watch(accentColorProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == AppThemeMode.dark;
    final themeData = isDark
        ? AppTheme.darkWithAccent(accentColor)
        : AppTheme.lightWithAccent(accentColor);

    // Use mock data during tour for better demonstration
    return ProviderScope(
      overrides: [
        ordersProvider.overrideWith(() => MockOrdersNotifier()),
        menuProvider.overrideWith(() => MockMenuNotifier()),
        restaurantProvider.overrideWith(() => MockRestaurantNotifier()),
        userProfileProvider.overrideWith(() => MockUserProfileNotifier()),
        // Family providers must be explicitly overridden so they read
        // from the mock ordersProvider within this scope.
        orderByIdProvider.overrideWith((ref, id) {
          final ordersState = ref.watch(ordersProvider);
          try {
            return ordersState.orders.firstWhere((o) => o.id == id);
          } catch (_) {
            return null;
          }
        }),
      ],
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            // App content with mock data
            child,

            // Wrap spotlight in Theme so it picks up
            // the app's accent color, surfaces, text styles, etc.
            Theme(
              data: themeData,
              child: _TourSpotlight(step: currentStep),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tour spotlight with clear highlighting and readable tooltip
class _TourSpotlight extends ConsumerStatefulWidget {
  const _TourSpotlight({required this.step});

  final dynamic step;

  @override
  ConsumerState<_TourSpotlight> createState() => _TourSpotlightState();
}

class _TourSpotlightState extends ConsumerState<_TourSpotlight>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  int _highlightRetryCount = 0;
  static const _maxHighlightRetries = 3;

  @override
  void initState() {
    super.initState();
    _tourLog('_TourSpotlight.initState() → step="${widget.step.id}"');
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(_TourSpotlight oldWidget) {
    super.didUpdateWidget(oldWidget);
    _tourLog('_TourSpotlight.didUpdateWidget() → '
        'old="${oldWidget.step.id}" new="${widget.step.id}"');
    if (oldWidget.step.id != widget.step.id) {
      _tourLog('_TourSpotlight: step changed, resetting animation');
      _highlightRetryCount = 0; // Reset retry counter for new step
      _controller.reset();
      _controller.forward();
      // Schedule a rebuild after the next frame so newly-navigated
      // screens have time to render and their GlobalKeys become available.
      // Also scroll the target into view if it's off-screen.
      _scheduleHighlightRetry();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _scrollToTargetIfNeeded();
      });
    }
  }

  /// Rebuild after the next frame so highlight can find targets
  /// that weren't rendered yet during the initial build.
  /// Capped at [_maxHighlightRetries] to avoid infinite loops when the
  /// target widget is permanently unavailable (e.g. on a non-visible tab).
  void _scheduleHighlightRetry() {
    if (_highlightRetryCount >= _maxHighlightRetries) {
      _tourLog('_TourSpotlight: max retries ($_maxHighlightRetries) reached '
          'for step "${widget.step.id}" — giving up on highlight');
      return;
    }
    _highlightRetryCount++;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _tourLog('_TourSpotlight: post-frame retry #$_highlightRetryCount '
            'for highlight');
        _scrollToTargetIfNeeded();
        setState(() {});
      }
    });
  }

  /// Scroll the target widget into view if it's inside a Scrollable.
  void _scrollToTargetIfNeeded() {
    final targetKey = widget.step.targetWidgetKey;
    if (targetKey == null) return;
    final ctx = targetKey.currentContext;
    if (ctx == null) return;

    _tourLog('_TourSpotlight: scrolling to target "${widget.step.id}"');
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      alignment: 0.3, // show target ~30% from the top
    ).then((_) {
      // Rebuild after scroll completes so highlight lands on the new position
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tourLog('_TourSpotlight.dispose()');
    _controller.dispose();
    super.dispose();
  }

  /// Calculate the target widget rect if available
  Rect? _getTargetRect() {
    if (widget.step.targetWidgetKey == null) return null;
    final RenderBox? renderBox =
        widget.step.targetWidgetKey!.currentContext?.findRenderObject()
            as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return null;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    return Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
  }

  /// Determine whether tooltip should go above or below the target
  bool _shouldTooltipGoAbove(Rect? targetRect, double screenHeight) {
    if (targetRect == null) return false; // center/bottom for fullscreen
    // If target center is in bottom 55% of screen, put tooltip above
    return targetRect.center.dy > screenHeight * 0.45;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tourState = ref.watch(tourProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final screenHeight = MediaQuery.of(context).size.height;

    final targetRect = _getTargetRect();
    final tooltipAbove = _shouldTooltipGoAbove(targetRect, screenHeight);

    _tourLog('_TourSpotlight.build() → step="${widget.step.id}", '
        'targetRect=${targetRect != null ? "found" : "null"}, '
        'tooltipAbove=$tooltipAbove');

    return Stack(
      children: [
        // Dark overlay with cutout for target widget
        Positioned.fill(
          child: IgnorePointer(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: targetRect != null
                  ? _CutoutOverlay(targetRect: targetRect)
                  : Container(color: Colors.black.withValues(alpha: 0.45)),
            ),
          ),
        ),

        // Highlight border around target
        if (widget.step.targetWidgetKey != null)
          _HighlightedElement(
            targetKey: widget.step.targetWidgetKey!,
            animation: _controller,
            onTargetMissing: _scheduleHighlightRetry,
            primaryColor: primaryColor,
          ),

        // Dynamically positioned tooltip card
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Positioned(
              left: 16.w,
              right: 16.w,
              top: tooltipAbove ? null : _getTooltipTopPosition(targetRect, screenHeight),
              bottom: tooltipAbove ? _getTooltipBottomPosition(targetRect, screenHeight) : null,
              child: Transform.translate(
                offset: Offset(0, tooltipAbove ? _slideAnimation.value : -_slideAnimation.value),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: _TooltipCard(
                    step: widget.step,
                    currentIndex: tourState.currentStepIndex,
                    totalSteps: tourState.totalSteps,
                    isFirstStep: tourState.isOnFirstStep,
                    isLastStep: tourState.isOnLastStep,
                    isDark: isDark,
                    primaryColor: primaryColor,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Calculate top position for tooltip when placed below target
  double? _getTooltipTopPosition(Rect? targetRect, double screenHeight) {
    if (targetRect == null) {
      // Full-screen step — center vertically
      return screenHeight * 0.3;
    }
    // Place below the target with some spacing
    final below = targetRect.bottom + 20.h;
    // Ensure it doesn't go off screen
    return below.clamp(80.h, screenHeight * 0.55);
  }

  /// Calculate bottom position for tooltip when placed above target
  double? _getTooltipBottomPosition(Rect? targetRect, double screenHeight) {
    if (targetRect == null) return 100.h;
    // Place above the target with some spacing
    final spaceBelow = screenHeight - targetRect.top + 20.h;
    return spaceBelow.clamp(80.h, screenHeight * 0.55);
  }
}

/// Overlay with a rectangular cutout revealing the target widget
class _CutoutOverlay extends StatelessWidget {
  const _CutoutOverlay({required this.targetRect});

  final Rect targetRect;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CutoutPainter(
        targetRect: targetRect.inflate(10),
        overlayColor: Colors.black.withValues(alpha: 0.50),
        borderRadius: 14.r,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _CutoutPainter extends CustomPainter {
  _CutoutPainter({
    required this.targetRect,
    required this.overlayColor,
    required this.borderRadius,
  });

  final Rect targetRect;
  final Color overlayColor;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = overlayColor;
    // Draw overlay with hole
    final outer = Path()..addRect(Offset.zero & size);
    final inner = Path()
      ..addRRect(
        RRect.fromRectAndRadius(targetRect, Radius.circular(borderRadius)),
      );
    final combined = Path.combine(PathOperation.difference, outer, inner);
    canvas.drawPath(combined, paint);
  }

  @override
  bool shouldRepaint(_CutoutPainter oldDelegate) =>
      targetRect != oldDelegate.targetRect;
}

/// Highlighted element with pulse effect
class _HighlightedElement extends StatelessWidget {
  const _HighlightedElement({
    required this.targetKey,
    required this.animation,
    required this.primaryColor,
    this.onTargetMissing,
  });

  final GlobalKey targetKey;
  final Animation<double> animation;
  final Color primaryColor;
  final VoidCallback? onTargetMissing;

  @override
  Widget build(BuildContext context) {
    final RenderBox? renderBox =
        targetKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null || !renderBox.hasSize) {
      _tourLog('_HighlightedElement: targetKey "${targetKey.toString()}" → '
          'renderBox=${renderBox == null ? "NULL" : "no size"}, '
          'context=${targetKey.currentContext == null ? "NULL" : "exists"}');
      // Target not rendered yet — schedule another retry
      onTargetMissing?.call();
      return const SizedBox.shrink();
    }

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    _tourLog('_HighlightedElement: found target at '
        'pos=(${position.dx.toInt()},${position.dy.toInt()}) '
        'size=(${size.width.toInt()}x${size.height.toInt()})');

    return Positioned(
      left: position.dx - 10,
      top: position.dy - 10,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Container(
              width: size.width + 20,
              height: size.height + 20,
              decoration: BoxDecoration(
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.9),
                  width: 2.5,
                ),
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor
                        .withValues(alpha: 0.35 * animation.value),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Professional tooltip card with translated content
class _TooltipCard extends ConsumerWidget {
  const _TooltipCard({
    required this.step,
    required this.currentIndex,
    required this.totalSteps,
    required this.isFirstStep,
    required this.isLastStep,
    required this.isDark,
    required this.primaryColor,
  });

  final dynamic step;
  final int currentIndex;
  final int totalSteps;
  final bool isFirstStep;
  final bool isLastStep;
  final bool isDark;
  final Color primaryColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardBg = isDark ? DarkColors.surface : Colors.white;
    final textPrimary =
        isDark ? DarkColors.textPrimary : LightColors.textPrimary;
    final textSecondary =
        isDark ? DarkColors.textSecondary : LightColors.textSecondary;

    // Translate title and description using .tr
    final title = step.titleKey.toString().tr;
    final description = step.descriptionKey.toString().tr;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar + step counter
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: LinearProgressIndicator(
                    value: (currentIndex + 1) / totalSteps,
                    minHeight: 4.h,
                    backgroundColor: primaryColor.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation(primaryColor),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '${'tour.step'.tr} ${currentIndex + 1} ${'tour.of'.tr} $totalSteps',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: textPrimary,
              height: 1.3,
            ),
          ),

          SizedBox(height: 8.h),

          // Description
          Text(
            description,
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.5,
              color: textSecondary,
            ),
          ),

          SizedBox(height: 20.h),

          // Action buttons
          Row(
            children: [
              // Skip button
              TextButton(
                onPressed: () {
                  _tourLog('SKIP TOUR tapped');
                  ref.read(tourProvider.notifier).exitTour();
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                ),
                child: Text(
                  'tour.skip'.tr,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? DarkColors.textTertiary
                        : LightColors.textTertiary,
                  ),
                ),
              ),

              const Spacer(),

              // Back button
              if (!isFirstStep) ...[
                _NavButton(
                  icon: Icons.arrow_back_rounded,
                  onPressed: () {
                    _tourLog('BACK button tapped');
                    ref.read(tourProvider.notifier).previousStep();
                  },
                  isDark: isDark,
                ),
                SizedBox(width: 10.w),
              ],

              // Next / Finish button
              _PrimaryButton(
                label: isLastStep ? 'tour.finish'.tr : 'tour.next'.tr,
                icon: isLastStep ? Icons.check_rounded : Icons.arrow_forward_rounded,
                primaryColor: primaryColor,
                onPressed: () {
                  if (isLastStep) {
                    _tourLog('FINISH button tapped (last step)');
                    ref.read(tourProvider.notifier).completeTour();
                  } else {
                    _tourLog('NEXT button tapped → advancing from '
                        'step $currentIndex to ${currentIndex + 1}');
                    ref.read(tourProvider.notifier).nextStep();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Circular back button
class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.onPressed,
    required this.isDark,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? DarkColors.backgroundTertiary : LightColors.backgroundTertiary,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: 42.w,
          height: 42.w,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 20.w,
            color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Primary action button (Next / Finish)
class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.primaryColor,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color primaryColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: primaryColor,
      borderRadius: BorderRadius.circular(12.r),
      elevation: 0,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(width: 6.w),
              Icon(icon, size: 18.w, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
