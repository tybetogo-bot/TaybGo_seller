// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tour_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TourState {

 bool get isActive; int get currentStepIndex; int get totalSteps; TourType get tourType; bool get hasCompletedBefore; DateTime? get lastCompletedAt; DateTime? get lastShownAt; int get skipCount; bool get isDismissedFromHome;
/// Create a copy of TourState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TourStateCopyWith<TourState> get copyWith => _$TourStateCopyWithImpl<TourState>(this as TourState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TourState&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.currentStepIndex, currentStepIndex) || other.currentStepIndex == currentStepIndex)&&(identical(other.totalSteps, totalSteps) || other.totalSteps == totalSteps)&&(identical(other.tourType, tourType) || other.tourType == tourType)&&(identical(other.hasCompletedBefore, hasCompletedBefore) || other.hasCompletedBefore == hasCompletedBefore)&&(identical(other.lastCompletedAt, lastCompletedAt) || other.lastCompletedAt == lastCompletedAt)&&(identical(other.lastShownAt, lastShownAt) || other.lastShownAt == lastShownAt)&&(identical(other.skipCount, skipCount) || other.skipCount == skipCount)&&(identical(other.isDismissedFromHome, isDismissedFromHome) || other.isDismissedFromHome == isDismissedFromHome));
}


@override
int get hashCode => Object.hash(runtimeType,isActive,currentStepIndex,totalSteps,tourType,hasCompletedBefore,lastCompletedAt,lastShownAt,skipCount,isDismissedFromHome);

@override
String toString() {
  return 'TourState(isActive: $isActive, currentStepIndex: $currentStepIndex, totalSteps: $totalSteps, tourType: $tourType, hasCompletedBefore: $hasCompletedBefore, lastCompletedAt: $lastCompletedAt, lastShownAt: $lastShownAt, skipCount: $skipCount, isDismissedFromHome: $isDismissedFromHome)';
}


}

/// @nodoc
abstract mixin class $TourStateCopyWith<$Res>  {
  factory $TourStateCopyWith(TourState value, $Res Function(TourState) _then) = _$TourStateCopyWithImpl;
@useResult
$Res call({
 bool isActive, int currentStepIndex, int totalSteps, TourType tourType, bool hasCompletedBefore, DateTime? lastCompletedAt, DateTime? lastShownAt, int skipCount, bool isDismissedFromHome
});




}
/// @nodoc
class _$TourStateCopyWithImpl<$Res>
    implements $TourStateCopyWith<$Res> {
  _$TourStateCopyWithImpl(this._self, this._then);

  final TourState _self;
  final $Res Function(TourState) _then;

/// Create a copy of TourState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isActive = null,Object? currentStepIndex = null,Object? totalSteps = null,Object? tourType = null,Object? hasCompletedBefore = null,Object? lastCompletedAt = freezed,Object? lastShownAt = freezed,Object? skipCount = null,Object? isDismissedFromHome = null,}) {
  return _then(_self.copyWith(
isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,currentStepIndex: null == currentStepIndex ? _self.currentStepIndex : currentStepIndex // ignore: cast_nullable_to_non_nullable
as int,totalSteps: null == totalSteps ? _self.totalSteps : totalSteps // ignore: cast_nullable_to_non_nullable
as int,tourType: null == tourType ? _self.tourType : tourType // ignore: cast_nullable_to_non_nullable
as TourType,hasCompletedBefore: null == hasCompletedBefore ? _self.hasCompletedBefore : hasCompletedBefore // ignore: cast_nullable_to_non_nullable
as bool,lastCompletedAt: freezed == lastCompletedAt ? _self.lastCompletedAt : lastCompletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastShownAt: freezed == lastShownAt ? _self.lastShownAt : lastShownAt // ignore: cast_nullable_to_non_nullable
as DateTime?,skipCount: null == skipCount ? _self.skipCount : skipCount // ignore: cast_nullable_to_non_nullable
as int,isDismissedFromHome: null == isDismissedFromHome ? _self.isDismissedFromHome : isDismissedFromHome // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TourState].
extension TourStatePatterns on TourState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TourState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TourState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TourState value)  $default,){
final _that = this;
switch (_that) {
case _TourState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TourState value)?  $default,){
final _that = this;
switch (_that) {
case _TourState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isActive,  int currentStepIndex,  int totalSteps,  TourType tourType,  bool hasCompletedBefore,  DateTime? lastCompletedAt,  DateTime? lastShownAt,  int skipCount,  bool isDismissedFromHome)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TourState() when $default != null:
return $default(_that.isActive,_that.currentStepIndex,_that.totalSteps,_that.tourType,_that.hasCompletedBefore,_that.lastCompletedAt,_that.lastShownAt,_that.skipCount,_that.isDismissedFromHome);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isActive,  int currentStepIndex,  int totalSteps,  TourType tourType,  bool hasCompletedBefore,  DateTime? lastCompletedAt,  DateTime? lastShownAt,  int skipCount,  bool isDismissedFromHome)  $default,) {final _that = this;
switch (_that) {
case _TourState():
return $default(_that.isActive,_that.currentStepIndex,_that.totalSteps,_that.tourType,_that.hasCompletedBefore,_that.lastCompletedAt,_that.lastShownAt,_that.skipCount,_that.isDismissedFromHome);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isActive,  int currentStepIndex,  int totalSteps,  TourType tourType,  bool hasCompletedBefore,  DateTime? lastCompletedAt,  DateTime? lastShownAt,  int skipCount,  bool isDismissedFromHome)?  $default,) {final _that = this;
switch (_that) {
case _TourState() when $default != null:
return $default(_that.isActive,_that.currentStepIndex,_that.totalSteps,_that.tourType,_that.hasCompletedBefore,_that.lastCompletedAt,_that.lastShownAt,_that.skipCount,_that.isDismissedFromHome);case _:
  return null;

}
}

}

/// @nodoc


class _TourState extends TourState {
  const _TourState({this.isActive = false, this.currentStepIndex = 0, this.totalSteps = 0, this.tourType = TourType.fullApp, this.hasCompletedBefore = false, this.lastCompletedAt, this.lastShownAt, this.skipCount = 0, this.isDismissedFromHome = false}): super._();
  

@override@JsonKey() final  bool isActive;
@override@JsonKey() final  int currentStepIndex;
@override@JsonKey() final  int totalSteps;
@override@JsonKey() final  TourType tourType;
@override@JsonKey() final  bool hasCompletedBefore;
@override final  DateTime? lastCompletedAt;
@override final  DateTime? lastShownAt;
@override@JsonKey() final  int skipCount;
@override@JsonKey() final  bool isDismissedFromHome;

/// Create a copy of TourState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TourStateCopyWith<_TourState> get copyWith => __$TourStateCopyWithImpl<_TourState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TourState&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.currentStepIndex, currentStepIndex) || other.currentStepIndex == currentStepIndex)&&(identical(other.totalSteps, totalSteps) || other.totalSteps == totalSteps)&&(identical(other.tourType, tourType) || other.tourType == tourType)&&(identical(other.hasCompletedBefore, hasCompletedBefore) || other.hasCompletedBefore == hasCompletedBefore)&&(identical(other.lastCompletedAt, lastCompletedAt) || other.lastCompletedAt == lastCompletedAt)&&(identical(other.lastShownAt, lastShownAt) || other.lastShownAt == lastShownAt)&&(identical(other.skipCount, skipCount) || other.skipCount == skipCount)&&(identical(other.isDismissedFromHome, isDismissedFromHome) || other.isDismissedFromHome == isDismissedFromHome));
}


@override
int get hashCode => Object.hash(runtimeType,isActive,currentStepIndex,totalSteps,tourType,hasCompletedBefore,lastCompletedAt,lastShownAt,skipCount,isDismissedFromHome);

@override
String toString() {
  return 'TourState(isActive: $isActive, currentStepIndex: $currentStepIndex, totalSteps: $totalSteps, tourType: $tourType, hasCompletedBefore: $hasCompletedBefore, lastCompletedAt: $lastCompletedAt, lastShownAt: $lastShownAt, skipCount: $skipCount, isDismissedFromHome: $isDismissedFromHome)';
}


}

/// @nodoc
abstract mixin class _$TourStateCopyWith<$Res> implements $TourStateCopyWith<$Res> {
  factory _$TourStateCopyWith(_TourState value, $Res Function(_TourState) _then) = __$TourStateCopyWithImpl;
@override @useResult
$Res call({
 bool isActive, int currentStepIndex, int totalSteps, TourType tourType, bool hasCompletedBefore, DateTime? lastCompletedAt, DateTime? lastShownAt, int skipCount, bool isDismissedFromHome
});




}
/// @nodoc
class __$TourStateCopyWithImpl<$Res>
    implements _$TourStateCopyWith<$Res> {
  __$TourStateCopyWithImpl(this._self, this._then);

  final _TourState _self;
  final $Res Function(_TourState) _then;

/// Create a copy of TourState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isActive = null,Object? currentStepIndex = null,Object? totalSteps = null,Object? tourType = null,Object? hasCompletedBefore = null,Object? lastCompletedAt = freezed,Object? lastShownAt = freezed,Object? skipCount = null,Object? isDismissedFromHome = null,}) {
  return _then(_TourState(
isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,currentStepIndex: null == currentStepIndex ? _self.currentStepIndex : currentStepIndex // ignore: cast_nullable_to_non_nullable
as int,totalSteps: null == totalSteps ? _self.totalSteps : totalSteps // ignore: cast_nullable_to_non_nullable
as int,tourType: null == tourType ? _self.tourType : tourType // ignore: cast_nullable_to_non_nullable
as TourType,hasCompletedBefore: null == hasCompletedBefore ? _self.hasCompletedBefore : hasCompletedBefore // ignore: cast_nullable_to_non_nullable
as bool,lastCompletedAt: freezed == lastCompletedAt ? _self.lastCompletedAt : lastCompletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastShownAt: freezed == lastShownAt ? _self.lastShownAt : lastShownAt // ignore: cast_nullable_to_non_nullable
as DateTime?,skipCount: null == skipCount ? _self.skipCount : skipCount // ignore: cast_nullable_to_non_nullable
as int,isDismissedFromHome: null == isDismissedFromHome ? _self.isDismissedFromHome : isDismissedFromHome // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
