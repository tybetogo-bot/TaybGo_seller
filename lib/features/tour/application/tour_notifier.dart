import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:teybatseller/features/tour/application/tour_state.dart';
import 'package:teybatseller/features/tour/data/tour_steps_data.dart';
import 'package:teybatseller/features/tour/utils/tour_persistence.dart';

class TourNotifier extends Notifier<TourState> {
  GoRouter? _router;

  void setRouter(GoRouter router) {
    _router = router;
  }

  @override
  TourState build() {
    _loadSavedState();
    return const TourState();
  }

  Future<void> _loadSavedState() async {
    final hasCompleted = await TourPersistence.hasTourBeenCompleted();
    final lastShown = await TourPersistence.getLastTourShownDate();
    final skipCount = await TourPersistence.getTourSkipCount();

    state = state.copyWith(
      hasCompletedBefore: hasCompleted,
      lastShownAt: lastShown,
      skipCount: skipCount,
    );
  }

  void startTour(TourType tourType) {
    final steps = TourSteps.getStepsForTourType(tourType);
    state = state.copyWith(
      isActive: true,
      currentStepIndex: 0,
      totalSteps: steps.length,
      tourType: tourType,
    );

    // Navigate to the first step's target screen
    _navigateToCurrentStep();
  }

  void nextStep() {
    if (!state.isActive) return;
    if (state.isOnLastStep) {
      completeTour();
      return;
    }

    state = state.copyWith(
      currentStepIndex: state.currentStepIndex + 1,
    );

    // Navigate to the next step's target screen
    _navigateToCurrentStep();
  }

  void previousStep() {
    if (!state.isActive) return;
    if (state.isOnFirstStep) return;

    state = state.copyWith(
      currentStepIndex: state.currentStepIndex - 1,
    );

    // Navigate back to the previous step's target screen
    _navigateToCurrentStep();
  }

  void _navigateToCurrentStep() {
    if (_router == null) return;

    final steps = TourSteps.getStepsForTourType(state.tourType);
    if (state.currentStepIndex >= steps.length) return;

    final currentStep = steps[state.currentStepIndex];
    final targetScreen = currentStep.targetScreen;

    // Only navigate if we're not already on the target screen
    final currentLocation = _router!.routerDelegate.currentConfiguration.uri.path;
    if (currentLocation != targetScreen) {
      _router!.go(targetScreen);
    }
  }

  Future<void> skipStep() async {
    await TourPersistence.incrementSkipCount();
    nextStep();
  }

  Future<void> completeTour() async {
    await TourPersistence.markTourAsCompleted();

    state = state.copyWith(
      isActive: false,
      hasCompletedBefore: true,
      lastCompletedAt: DateTime.now(),
      currentStepIndex: 0,
    );
  }

  void exitTour() {
    state = state.copyWith(
      isActive: false,
      currentStepIndex: 0,
    );
  }

  Future<void> resetTour() async {
    await TourPersistence.resetTourData();
    state = const TourState();
  }
}

final tourProvider = NotifierProvider<TourNotifier, TourState>(() {
  return TourNotifier();
});
