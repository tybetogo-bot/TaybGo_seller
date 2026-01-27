import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teybatseller/features/tour/application/tour_state.dart';
import 'package:teybatseller/features/tour/data/tour_steps_data.dart';
import 'package:teybatseller/features/tour/utils/tour_persistence.dart';

class TourNotifier extends Notifier<TourState> {
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
  }

  void previousStep() {
    if (!state.isActive) return;
    if (state.isOnFirstStep) return;

    state = state.copyWith(
      currentStepIndex: state.currentStepIndex - 1,
    );
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
