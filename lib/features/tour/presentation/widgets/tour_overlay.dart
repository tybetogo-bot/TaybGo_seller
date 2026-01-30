import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:teybatseller/core/theme/theme.dart';
import 'package:teybatseller/features/menu/application/menu_notifier.dart';
import 'package:teybatseller/features/orders/application/orders_notifier.dart';
import 'package:teybatseller/features/restaurant/application/restaurant_state.dart';
import 'package:teybatseller/features/tour/application/mock_providers.dart';
import 'package:teybatseller/features/tour/application/tour_notifier.dart';
import 'package:teybatseller/features/tour/data/tour_steps_data.dart';

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

    // If tour is not active, show normal app
    if (!tourState.isActive) {
      return child;
    }

    // Get current tour step
    final steps = TourSteps.getStepsForTourType(tourState.tourType);
    if (tourState.currentStepIndex >= steps.length) {
      return child;
    }

    final currentStep = steps[tourState.currentStepIndex];

    // Use mock data during tour for better demonstration
    return ProviderScope(
      overrides: [
        ordersProvider.overrideWith(() => MockOrdersNotifier()),
        menuProvider.overrideWith(() => MockMenuNotifier()),
        restaurantProvider.overrideWith(() => MockRestaurantNotifier()),
      ],
      child: Stack(
        children: [
          // App content with mock data
          child,

          // Professional tour UI
          _TourSpotlight(step: currentStep),
        ],
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
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(_TourSpotlight oldWidget) {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tourState = ref.watch(tourProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Stack(
      children: [
        // Subtle overlay (only 30% opacity for better visibility)
        Positioned.fill(
          child: IgnorePointer(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),

        // Highlight target element with pulse animation
        if (widget.step.targetWidgetKey != null)
          _HighlightedElement(
            targetKey: widget.step.targetWidgetKey!,
            animation: _controller,
          ),

        // Clear, readable tooltip
        Positioned(
          bottom: 100.h,
          left: 20.w,
          right: 20.w,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
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
        ),
      ],
    );
  }
}

/// Highlighted element with pulse effect
class _HighlightedElement extends StatelessWidget {
  const _HighlightedElement({
    required this.targetKey,
    required this.animation,
  });

  final GlobalKey targetKey;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final RenderBox? renderBox =
        targetKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null || !renderBox.hasSize) {
      return const SizedBox.shrink();
    }

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    return Positioned(
      left: position.dx - 8,
      top: position.dy - 8,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Container(
              width: size.width + 16,
              height: size.height + 16,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.4 * animation.value),
                    blurRadius: 20,
                    spreadRadius: 5,
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

/// Professional tooltip card with clear content
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
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: LinearProgressIndicator(
                    value: (currentIndex + 1) / totalSteps,
                    minHeight: 6.h,
                    backgroundColor:
                        primaryColor.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation(primaryColor),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                '${currentIndex + 1}/$totalSteps',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // Title
          Text(
            step.titleKey.toString().replaceAll('tour.', '').replaceAll('.title', '').toUpperCase(),
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
              letterSpacing: 0.5,
            ),
          ),

          SizedBox(height: 12.h),

          // Description
          Text(
            step.descriptionKey.toString().replaceAll('tour.', '').replaceAll('.description', ''),
            style: TextStyle(
              fontSize: 15.sp,
              height: 1.6,
              color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
            ),
          ),

          SizedBox(height: 24.h),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Skip button
              TextButton(
                onPressed: () => ref.read(tourProvider.notifier).exitTour(),
                child: Text(
                  'SKIP TOUR',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? DarkColors.textSecondary
                        : LightColors.textSecondary,
                  ),
                ),
              ),

              // Navigation buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isFirstStep) ...[
                    IconButton(
                      onPressed: () =>
                          ref.read(tourProvider.notifier).previousStep(),
                      icon: const Icon(Icons.arrow_back),
                      style: IconButton.styleFrom(
                        backgroundColor: isDark
                            ? DarkColors.backgroundSecondary
                            : LightColors.backgroundSecondary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                  ],
                  ElevatedButton(
                    onPressed: () {
                      if (isLastStep) {
                        ref.read(tourProvider.notifier).completeTour();
                      } else {
                        ref.read(tourProvider.notifier).nextStep();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 14.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isLastStep ? 'FINISH' : 'NEXT',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          isLastStep ? Icons.check : Icons.arrow_forward,
                          size: 18.w,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
