import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tour_step_model.freezed.dart';

enum TourAction {
  tap,
  swipe,
  navigate,
  observe,
  interact,
}

enum HighlightArea {
  fullScreen,
  rectangle,
  circle,
  custom,
}

enum TooltipPosition {
  top,
  bottom,
  left,
  right,
  auto,
}

@freezed
sealed class TourStepModel with _$TourStepModel {
  const factory TourStepModel({
    required String id,
    required String titleKey,
    required String descriptionKey,
    required String targetScreen,
    GlobalKey? targetWidgetKey,
    @Default(HighlightArea.rectangle) HighlightArea highlightArea,
    @Default(TooltipPosition.auto) TooltipPosition tooltipPosition,
    @Default([TourAction.observe]) List<TourAction> actions,
    @Default(true) bool canSkip,
    @Default(Duration(seconds: 5)) Duration estimatedDuration,
  }) = _TourStepModel;

  const TourStepModel._();

  String get actionHintKey {
    if (actions.isEmpty) return 'tour.actionHint.observe';

    switch (actions.first) {
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
}
