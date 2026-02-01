import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:teybatseller/features/tour/application/tour_state.dart';
import 'package:teybatseller/features/tour/data/tour_steps_data.dart';
import 'package:teybatseller/features/tour/utils/tour_persistence.dart';

void _tourLog(String message) {
  if (kDebugMode) {
    debugPrint('🎯 [TourNotifier] $message');
  }
}

class TourNotifier extends Notifier<TourState> {
  GoRouter? _router;

  void setRouter(GoRouter router) {
    _tourLog('setRouter() called, router=${router.hashCode}');
    _router = router;
  }

  @override
  TourState build() {
    _tourLog('build() called — initializing state');
    _loadSavedState();
    return const TourState();
  }

  Future<void> _loadSavedState() async {
    final hasCompleted = await TourPersistence.hasTourBeenCompleted();
    final lastShown = await TourPersistence.getLastTourShownDate();
    final skipCount = await TourPersistence.getTourSkipCount();

    _tourLog('_loadSavedState() → hasCompleted=$hasCompleted, '
        'lastShown=$lastShown, skipCount=$skipCount');

    state = state.copyWith(
      hasCompletedBefore: hasCompleted,
      lastShownAt: lastShown,
      skipCount: skipCount,
    );
  }

  void startTour(TourType tourType) {
    final steps = TourSteps.getStepsForTourType(tourType);
    _tourLog('startTour($tourType) → ${steps.length} steps, '
        'router=${_router != null ? "SET" : "NULL"}');
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
    _tourLog('nextStep() called → isActive=${state.isActive}, '
        'currentStep=${state.currentStepIndex}, '
        'isLastStep=${state.isOnLastStep}');

    if (!state.isActive) {
      _tourLog('nextStep() ABORTED: tour not active!');
      return;
    }
    if (state.isOnLastStep) {
      _tourLog('nextStep() → on last step, calling completeTour()');
      completeTour();
      return;
    }

    final newIndex = state.currentStepIndex + 1;
    final steps = TourSteps.getStepsForTourType(state.tourType);
    final nextStepData = steps[newIndex];
    _tourLog('nextStep() → advancing to step $newIndex: '
        '"${nextStepData.id}" (target=${nextStepData.targetScreen})');

    state = state.copyWith(
      currentStepIndex: newIndex,
    );

    // Navigate to the next step's target screen
    _navigateToCurrentStep();
  }

  void previousStep() {
    _tourLog('previousStep() called → currentStep=${state.currentStepIndex}');

    if (!state.isActive) {
      _tourLog('previousStep() ABORTED: tour not active!');
      return;
    }
    if (state.isOnFirstStep) {
      _tourLog('previousStep() ABORTED: already on first step');
      return;
    }

    final newIndex = state.currentStepIndex - 1;
    _tourLog('previousStep() → going back to step $newIndex');

    state = state.copyWith(
      currentStepIndex: newIndex,
    );

    // Navigate back to the previous step's target screen
    _navigateToCurrentStep();
  }

  void _navigateToCurrentStep() {
    if (_router == null) {
      _tourLog('_navigateToCurrentStep() ABORTED: _router is NULL!');
      return;
    }

    final steps = TourSteps.getStepsForTourType(state.tourType);
    if (state.currentStepIndex >= steps.length) {
      _tourLog('_navigateToCurrentStep() ABORTED: '
          'stepIndex ${state.currentStepIndex} >= steps.length ${steps.length}');
      return;
    }

    final currentStep = steps[state.currentStepIndex];
    final targetScreen = currentStep.targetScreen;

    // Only navigate if we're not already on the target screen
    final currentLocation =
        _router!.routerDelegate.currentConfiguration.uri.path;
    if (currentLocation != targetScreen) {
      _tourLog('_navigateToCurrentStep() → NAVIGATING from '
          '"$currentLocation" to "$targetScreen"');
      _router!.go(targetScreen);
    } else {
      _tourLog('_navigateToCurrentStep() → already on "$targetScreen", '
          'no navigation needed');
    }
  }

  Future<void> skipStep() async {
    _tourLog('skipStep() called');
    await TourPersistence.incrementSkipCount();
    nextStep();
  }

  Future<void> completeTour() async {
    _tourLog('completeTour() called');
    await TourPersistence.markTourAsCompleted();

    state = state.copyWith(
      isActive: false,
      hasCompletedBefore: true,
      lastCompletedAt: DateTime.now(),
      currentStepIndex: 0,
    );
    _tourLog('completeTour() → tour marked as completed, isActive=false');
  }

  void exitTour() {
    _tourLog('exitTour() called');
    state = state.copyWith(
      isActive: false,
      currentStepIndex: 0,
    );
    _tourLog('exitTour() → tour deactivated');
  }

  Future<void> resetTour() async {
    _tourLog('resetTour() called');
    await TourPersistence.resetTourData();
    state = const TourState();
    _tourLog('resetTour() → state reset to defaults');
  }
}

final tourProvider = NotifierProvider<TourNotifier, TourState>(() {
  return TourNotifier();
});
