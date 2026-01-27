import 'package:freezed_annotation/freezed_annotation.dart';

part 'tour_state.freezed.dart';

enum TourType {
  fullApp,
  ordersQuick,
  menuQuick,
}

@freezed
sealed class TourState with _$TourState {
  const factory TourState({
    @Default(false) bool isActive,
    @Default(0) int currentStepIndex,
    @Default(0) int totalSteps,
    @Default(TourType.fullApp) TourType tourType,
    @Default(false) bool hasCompletedBefore,
    DateTime? lastCompletedAt,
    DateTime? lastShownAt,
    @Default(0) int skipCount,
  }) = _TourState;

  const TourState._();

  bool get isOnFirstStep => currentStepIndex == 0;
  bool get isOnLastStep => currentStepIndex == totalSteps - 1;
  double get progress => totalSteps > 0 ? currentStepIndex / totalSteps : 0.0;
  int get remainingSteps => totalSteps - currentStepIndex;
}
