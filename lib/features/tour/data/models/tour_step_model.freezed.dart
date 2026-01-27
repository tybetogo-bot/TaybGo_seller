// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tour_step_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TourStepModel {

 String get id; String get titleKey; String get descriptionKey; String get targetScreen; GlobalKey? get targetWidgetKey; HighlightArea get highlightArea; TooltipPosition get tooltipPosition; List<TourAction> get actions; bool get canSkip; Duration get estimatedDuration;
/// Create a copy of TourStepModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TourStepModelCopyWith<TourStepModel> get copyWith => _$TourStepModelCopyWithImpl<TourStepModel>(this as TourStepModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TourStepModel&&(identical(other.id, id) || other.id == id)&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey)&&(identical(other.descriptionKey, descriptionKey) || other.descriptionKey == descriptionKey)&&(identical(other.targetScreen, targetScreen) || other.targetScreen == targetScreen)&&(identical(other.targetWidgetKey, targetWidgetKey) || other.targetWidgetKey == targetWidgetKey)&&(identical(other.highlightArea, highlightArea) || other.highlightArea == highlightArea)&&(identical(other.tooltipPosition, tooltipPosition) || other.tooltipPosition == tooltipPosition)&&const DeepCollectionEquality().equals(other.actions, actions)&&(identical(other.canSkip, canSkip) || other.canSkip == canSkip)&&(identical(other.estimatedDuration, estimatedDuration) || other.estimatedDuration == estimatedDuration));
}


@override
int get hashCode => Object.hash(runtimeType,id,titleKey,descriptionKey,targetScreen,targetWidgetKey,highlightArea,tooltipPosition,const DeepCollectionEquality().hash(actions),canSkip,estimatedDuration);

@override
String toString() {
  return 'TourStepModel(id: $id, titleKey: $titleKey, descriptionKey: $descriptionKey, targetScreen: $targetScreen, targetWidgetKey: $targetWidgetKey, highlightArea: $highlightArea, tooltipPosition: $tooltipPosition, actions: $actions, canSkip: $canSkip, estimatedDuration: $estimatedDuration)';
}


}

/// @nodoc
abstract mixin class $TourStepModelCopyWith<$Res>  {
  factory $TourStepModelCopyWith(TourStepModel value, $Res Function(TourStepModel) _then) = _$TourStepModelCopyWithImpl;
@useResult
$Res call({
 String id, String titleKey, String descriptionKey, String targetScreen, GlobalKey? targetWidgetKey, HighlightArea highlightArea, TooltipPosition tooltipPosition, List<TourAction> actions, bool canSkip, Duration estimatedDuration
});




}
/// @nodoc
class _$TourStepModelCopyWithImpl<$Res>
    implements $TourStepModelCopyWith<$Res> {
  _$TourStepModelCopyWithImpl(this._self, this._then);

  final TourStepModel _self;
  final $Res Function(TourStepModel) _then;

/// Create a copy of TourStepModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? titleKey = null,Object? descriptionKey = null,Object? targetScreen = null,Object? targetWidgetKey = freezed,Object? highlightArea = null,Object? tooltipPosition = null,Object? actions = null,Object? canSkip = null,Object? estimatedDuration = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,titleKey: null == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as String,descriptionKey: null == descriptionKey ? _self.descriptionKey : descriptionKey // ignore: cast_nullable_to_non_nullable
as String,targetScreen: null == targetScreen ? _self.targetScreen : targetScreen // ignore: cast_nullable_to_non_nullable
as String,targetWidgetKey: freezed == targetWidgetKey ? _self.targetWidgetKey : targetWidgetKey // ignore: cast_nullable_to_non_nullable
as GlobalKey?,highlightArea: null == highlightArea ? _self.highlightArea : highlightArea // ignore: cast_nullable_to_non_nullable
as HighlightArea,tooltipPosition: null == tooltipPosition ? _self.tooltipPosition : tooltipPosition // ignore: cast_nullable_to_non_nullable
as TooltipPosition,actions: null == actions ? _self.actions : actions // ignore: cast_nullable_to_non_nullable
as List<TourAction>,canSkip: null == canSkip ? _self.canSkip : canSkip // ignore: cast_nullable_to_non_nullable
as bool,estimatedDuration: null == estimatedDuration ? _self.estimatedDuration : estimatedDuration // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}

}


/// Adds pattern-matching-related methods to [TourStepModel].
extension TourStepModelPatterns on TourStepModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TourStepModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TourStepModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TourStepModel value)  $default,){
final _that = this;
switch (_that) {
case _TourStepModel():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TourStepModel value)?  $default,){
final _that = this;
switch (_that) {
case _TourStepModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String titleKey,  String descriptionKey,  String targetScreen,  GlobalKey? targetWidgetKey,  HighlightArea highlightArea,  TooltipPosition tooltipPosition,  List<TourAction> actions,  bool canSkip,  Duration estimatedDuration)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TourStepModel() when $default != null:
return $default(_that.id,_that.titleKey,_that.descriptionKey,_that.targetScreen,_that.targetWidgetKey,_that.highlightArea,_that.tooltipPosition,_that.actions,_that.canSkip,_that.estimatedDuration);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String titleKey,  String descriptionKey,  String targetScreen,  GlobalKey? targetWidgetKey,  HighlightArea highlightArea,  TooltipPosition tooltipPosition,  List<TourAction> actions,  bool canSkip,  Duration estimatedDuration)  $default,) {final _that = this;
switch (_that) {
case _TourStepModel():
return $default(_that.id,_that.titleKey,_that.descriptionKey,_that.targetScreen,_that.targetWidgetKey,_that.highlightArea,_that.tooltipPosition,_that.actions,_that.canSkip,_that.estimatedDuration);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String titleKey,  String descriptionKey,  String targetScreen,  GlobalKey? targetWidgetKey,  HighlightArea highlightArea,  TooltipPosition tooltipPosition,  List<TourAction> actions,  bool canSkip,  Duration estimatedDuration)?  $default,) {final _that = this;
switch (_that) {
case _TourStepModel() when $default != null:
return $default(_that.id,_that.titleKey,_that.descriptionKey,_that.targetScreen,_that.targetWidgetKey,_that.highlightArea,_that.tooltipPosition,_that.actions,_that.canSkip,_that.estimatedDuration);case _:
  return null;

}
}

}

/// @nodoc


class _TourStepModel extends TourStepModel {
  const _TourStepModel({required this.id, required this.titleKey, required this.descriptionKey, required this.targetScreen, this.targetWidgetKey, this.highlightArea = HighlightArea.rectangle, this.tooltipPosition = TooltipPosition.auto, final  List<TourAction> actions = const [TourAction.observe], this.canSkip = true, this.estimatedDuration = const Duration(seconds: 5)}): _actions = actions,super._();
  

@override final  String id;
@override final  String titleKey;
@override final  String descriptionKey;
@override final  String targetScreen;
@override final  GlobalKey? targetWidgetKey;
@override@JsonKey() final  HighlightArea highlightArea;
@override@JsonKey() final  TooltipPosition tooltipPosition;
 final  List<TourAction> _actions;
@override@JsonKey() List<TourAction> get actions {
  if (_actions is EqualUnmodifiableListView) return _actions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_actions);
}

@override@JsonKey() final  bool canSkip;
@override@JsonKey() final  Duration estimatedDuration;

/// Create a copy of TourStepModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TourStepModelCopyWith<_TourStepModel> get copyWith => __$TourStepModelCopyWithImpl<_TourStepModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TourStepModel&&(identical(other.id, id) || other.id == id)&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey)&&(identical(other.descriptionKey, descriptionKey) || other.descriptionKey == descriptionKey)&&(identical(other.targetScreen, targetScreen) || other.targetScreen == targetScreen)&&(identical(other.targetWidgetKey, targetWidgetKey) || other.targetWidgetKey == targetWidgetKey)&&(identical(other.highlightArea, highlightArea) || other.highlightArea == highlightArea)&&(identical(other.tooltipPosition, tooltipPosition) || other.tooltipPosition == tooltipPosition)&&const DeepCollectionEquality().equals(other._actions, _actions)&&(identical(other.canSkip, canSkip) || other.canSkip == canSkip)&&(identical(other.estimatedDuration, estimatedDuration) || other.estimatedDuration == estimatedDuration));
}


@override
int get hashCode => Object.hash(runtimeType,id,titleKey,descriptionKey,targetScreen,targetWidgetKey,highlightArea,tooltipPosition,const DeepCollectionEquality().hash(_actions),canSkip,estimatedDuration);

@override
String toString() {
  return 'TourStepModel(id: $id, titleKey: $titleKey, descriptionKey: $descriptionKey, targetScreen: $targetScreen, targetWidgetKey: $targetWidgetKey, highlightArea: $highlightArea, tooltipPosition: $tooltipPosition, actions: $actions, canSkip: $canSkip, estimatedDuration: $estimatedDuration)';
}


}

/// @nodoc
abstract mixin class _$TourStepModelCopyWith<$Res> implements $TourStepModelCopyWith<$Res> {
  factory _$TourStepModelCopyWith(_TourStepModel value, $Res Function(_TourStepModel) _then) = __$TourStepModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String titleKey, String descriptionKey, String targetScreen, GlobalKey? targetWidgetKey, HighlightArea highlightArea, TooltipPosition tooltipPosition, List<TourAction> actions, bool canSkip, Duration estimatedDuration
});




}
/// @nodoc
class __$TourStepModelCopyWithImpl<$Res>
    implements _$TourStepModelCopyWith<$Res> {
  __$TourStepModelCopyWithImpl(this._self, this._then);

  final _TourStepModel _self;
  final $Res Function(_TourStepModel) _then;

/// Create a copy of TourStepModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? titleKey = null,Object? descriptionKey = null,Object? targetScreen = null,Object? targetWidgetKey = freezed,Object? highlightArea = null,Object? tooltipPosition = null,Object? actions = null,Object? canSkip = null,Object? estimatedDuration = null,}) {
  return _then(_TourStepModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,titleKey: null == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as String,descriptionKey: null == descriptionKey ? _self.descriptionKey : descriptionKey // ignore: cast_nullable_to_non_nullable
as String,targetScreen: null == targetScreen ? _self.targetScreen : targetScreen // ignore: cast_nullable_to_non_nullable
as String,targetWidgetKey: freezed == targetWidgetKey ? _self.targetWidgetKey : targetWidgetKey // ignore: cast_nullable_to_non_nullable
as GlobalKey?,highlightArea: null == highlightArea ? _self.highlightArea : highlightArea // ignore: cast_nullable_to_non_nullable
as HighlightArea,tooltipPosition: null == tooltipPosition ? _self.tooltipPosition : tooltipPosition // ignore: cast_nullable_to_non_nullable
as TooltipPosition,actions: null == actions ? _self._actions : actions // ignore: cast_nullable_to_non_nullable
as List<TourAction>,canSkip: null == canSkip ? _self.canSkip : canSkip // ignore: cast_nullable_to_non_nullable
as bool,estimatedDuration: null == estimatedDuration ? _self.estimatedDuration : estimatedDuration // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}


}

// dart format on
