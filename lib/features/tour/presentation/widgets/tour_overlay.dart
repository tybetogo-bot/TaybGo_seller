import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teybatseller/features/menu/application/menu_notifier.dart';
import 'package:teybatseller/features/orders/application/orders_notifier.dart';
import 'package:teybatseller/features/restaurant/application/restaurant_state.dart';
import 'package:teybatseller/features/tour/application/mock_providers.dart';
import 'package:teybatseller/features/tour/application/tour_notifier.dart';
import 'package:teybatseller/features/tour/data/tour_steps_data.dart';
import 'package:teybatseller/features/tour/presentation/widgets/tour_controls.dart';
import 'package:teybatseller/features/tour/presentation/widgets/tour_highlight.dart';
import 'package:teybatseller/features/tour/presentation/widgets/tour_progress_indicator.dart';
import 'package:teybatseller/features/tour/presentation/widgets/tour_tooltip.dart';

/// Main tour overlay widget that wraps the entire app
/// When tour is active, it creates a nested ProviderScope with mock data
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

    // Create nested ProviderScope with mock data providers
    return ProviderScope(
      overrides: [
        // Override orders provider with mock version
        ordersProvider.overrideWith(() => MockOrdersNotifier()),

        // Override menu provider with mock version
        menuProvider.overrideWith(() => MockMenuNotifier()),

        // Override restaurant provider with mock version
        restaurantProvider.overrideWith(() => MockRestaurantNotifier()),
      ],
      child: Stack(
        children: [
          // Original app content (with mock data)
          child,

          // Tour UI overlay
          _TourOverlayUI(currentStep: currentStep),
        ],
      ),
    );
  }
}

/// Internal widget for tour overlay UI
class _TourOverlayUI extends StatelessWidget {
  const _TourOverlayUI({
    required this.currentStep,
  });

  final dynamic currentStep;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Highlight and dimmed background
        TourHighlight(step: currentStep),

        // Tooltip with step instructions
        TourTooltip(step: currentStep),

        // Progress indicator at top
        const TourProgressIndicator(),

        // Navigation controls at bottom
        const TourControls(),
      ],
    );
  }
}
