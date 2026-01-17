// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'coupon_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CouponModel {

 String get id; String get title; String? get description; String get code; double get percentDiscount; double get minimumOrderPrice; int? get maxTotalUsage; int? get maxUsagePerUser; int get currentUsageCount; DateTime get startDate; DateTime get endDate; bool get isActive; String? get restaurantId; String? get titleAr; String? get titleDe; String? get titleFr; String? get descriptionAr; String? get descriptionDe; String? get descriptionFr; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of CouponModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CouponModelCopyWith<CouponModel> get copyWith => _$CouponModelCopyWithImpl<CouponModel>(this as CouponModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CouponModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.code, code) || other.code == code)&&(identical(other.percentDiscount, percentDiscount) || other.percentDiscount == percentDiscount)&&(identical(other.minimumOrderPrice, minimumOrderPrice) || other.minimumOrderPrice == minimumOrderPrice)&&(identical(other.maxTotalUsage, maxTotalUsage) || other.maxTotalUsage == maxTotalUsage)&&(identical(other.maxUsagePerUser, maxUsagePerUser) || other.maxUsagePerUser == maxUsagePerUser)&&(identical(other.currentUsageCount, currentUsageCount) || other.currentUsageCount == currentUsageCount)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.restaurantId, restaurantId) || other.restaurantId == restaurantId)&&(identical(other.titleAr, titleAr) || other.titleAr == titleAr)&&(identical(other.titleDe, titleDe) || other.titleDe == titleDe)&&(identical(other.titleFr, titleFr) || other.titleFr == titleFr)&&(identical(other.descriptionAr, descriptionAr) || other.descriptionAr == descriptionAr)&&(identical(other.descriptionDe, descriptionDe) || other.descriptionDe == descriptionDe)&&(identical(other.descriptionFr, descriptionFr) || other.descriptionFr == descriptionFr)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,title,description,code,percentDiscount,minimumOrderPrice,maxTotalUsage,maxUsagePerUser,currentUsageCount,startDate,endDate,isActive,restaurantId,titleAr,titleDe,titleFr,descriptionAr,descriptionDe,descriptionFr,createdAt,updatedAt]);

@override
String toString() {
  return 'CouponModel(id: $id, title: $title, description: $description, code: $code, percentDiscount: $percentDiscount, minimumOrderPrice: $minimumOrderPrice, maxTotalUsage: $maxTotalUsage, maxUsagePerUser: $maxUsagePerUser, currentUsageCount: $currentUsageCount, startDate: $startDate, endDate: $endDate, isActive: $isActive, restaurantId: $restaurantId, titleAr: $titleAr, titleDe: $titleDe, titleFr: $titleFr, descriptionAr: $descriptionAr, descriptionDe: $descriptionDe, descriptionFr: $descriptionFr, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CouponModelCopyWith<$Res>  {
  factory $CouponModelCopyWith(CouponModel value, $Res Function(CouponModel) _then) = _$CouponModelCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? description, String code, double percentDiscount, double minimumOrderPrice, int? maxTotalUsage, int? maxUsagePerUser, int currentUsageCount, DateTime startDate, DateTime endDate, bool isActive, String? restaurantId, String? titleAr, String? titleDe, String? titleFr, String? descriptionAr, String? descriptionDe, String? descriptionFr, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$CouponModelCopyWithImpl<$Res>
    implements $CouponModelCopyWith<$Res> {
  _$CouponModelCopyWithImpl(this._self, this._then);

  final CouponModel _self;
  final $Res Function(CouponModel) _then;

/// Create a copy of CouponModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? code = null,Object? percentDiscount = null,Object? minimumOrderPrice = null,Object? maxTotalUsage = freezed,Object? maxUsagePerUser = freezed,Object? currentUsageCount = null,Object? startDate = null,Object? endDate = null,Object? isActive = null,Object? restaurantId = freezed,Object? titleAr = freezed,Object? titleDe = freezed,Object? titleFr = freezed,Object? descriptionAr = freezed,Object? descriptionDe = freezed,Object? descriptionFr = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,percentDiscount: null == percentDiscount ? _self.percentDiscount : percentDiscount // ignore: cast_nullable_to_non_nullable
as double,minimumOrderPrice: null == minimumOrderPrice ? _self.minimumOrderPrice : minimumOrderPrice // ignore: cast_nullable_to_non_nullable
as double,maxTotalUsage: freezed == maxTotalUsage ? _self.maxTotalUsage : maxTotalUsage // ignore: cast_nullable_to_non_nullable
as int?,maxUsagePerUser: freezed == maxUsagePerUser ? _self.maxUsagePerUser : maxUsagePerUser // ignore: cast_nullable_to_non_nullable
as int?,currentUsageCount: null == currentUsageCount ? _self.currentUsageCount : currentUsageCount // ignore: cast_nullable_to_non_nullable
as int,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,restaurantId: freezed == restaurantId ? _self.restaurantId : restaurantId // ignore: cast_nullable_to_non_nullable
as String?,titleAr: freezed == titleAr ? _self.titleAr : titleAr // ignore: cast_nullable_to_non_nullable
as String?,titleDe: freezed == titleDe ? _self.titleDe : titleDe // ignore: cast_nullable_to_non_nullable
as String?,titleFr: freezed == titleFr ? _self.titleFr : titleFr // ignore: cast_nullable_to_non_nullable
as String?,descriptionAr: freezed == descriptionAr ? _self.descriptionAr : descriptionAr // ignore: cast_nullable_to_non_nullable
as String?,descriptionDe: freezed == descriptionDe ? _self.descriptionDe : descriptionDe // ignore: cast_nullable_to_non_nullable
as String?,descriptionFr: freezed == descriptionFr ? _self.descriptionFr : descriptionFr // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [CouponModel].
extension CouponModelPatterns on CouponModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CouponModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CouponModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CouponModel value)  $default,){
final _that = this;
switch (_that) {
case _CouponModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CouponModel value)?  $default,){
final _that = this;
switch (_that) {
case _CouponModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  String code,  double percentDiscount,  double minimumOrderPrice,  int? maxTotalUsage,  int? maxUsagePerUser,  int currentUsageCount,  DateTime startDate,  DateTime endDate,  bool isActive,  String? restaurantId,  String? titleAr,  String? titleDe,  String? titleFr,  String? descriptionAr,  String? descriptionDe,  String? descriptionFr,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CouponModel() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.code,_that.percentDiscount,_that.minimumOrderPrice,_that.maxTotalUsage,_that.maxUsagePerUser,_that.currentUsageCount,_that.startDate,_that.endDate,_that.isActive,_that.restaurantId,_that.titleAr,_that.titleDe,_that.titleFr,_that.descriptionAr,_that.descriptionDe,_that.descriptionFr,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  String code,  double percentDiscount,  double minimumOrderPrice,  int? maxTotalUsage,  int? maxUsagePerUser,  int currentUsageCount,  DateTime startDate,  DateTime endDate,  bool isActive,  String? restaurantId,  String? titleAr,  String? titleDe,  String? titleFr,  String? descriptionAr,  String? descriptionDe,  String? descriptionFr,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _CouponModel():
return $default(_that.id,_that.title,_that.description,_that.code,_that.percentDiscount,_that.minimumOrderPrice,_that.maxTotalUsage,_that.maxUsagePerUser,_that.currentUsageCount,_that.startDate,_that.endDate,_that.isActive,_that.restaurantId,_that.titleAr,_that.titleDe,_that.titleFr,_that.descriptionAr,_that.descriptionDe,_that.descriptionFr,_that.createdAt,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? description,  String code,  double percentDiscount,  double minimumOrderPrice,  int? maxTotalUsage,  int? maxUsagePerUser,  int currentUsageCount,  DateTime startDate,  DateTime endDate,  bool isActive,  String? restaurantId,  String? titleAr,  String? titleDe,  String? titleFr,  String? descriptionAr,  String? descriptionDe,  String? descriptionFr,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _CouponModel() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.code,_that.percentDiscount,_that.minimumOrderPrice,_that.maxTotalUsage,_that.maxUsagePerUser,_that.currentUsageCount,_that.startDate,_that.endDate,_that.isActive,_that.restaurantId,_that.titleAr,_that.titleDe,_that.titleFr,_that.descriptionAr,_that.descriptionDe,_that.descriptionFr,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _CouponModel implements CouponModel {
  const _CouponModel({required this.id, required this.title, this.description, required this.code, required this.percentDiscount, this.minimumOrderPrice = 0.0, this.maxTotalUsage, this.maxUsagePerUser, this.currentUsageCount = 0, required this.startDate, required this.endDate, this.isActive = true, this.restaurantId, this.titleAr, this.titleDe, this.titleFr, this.descriptionAr, this.descriptionDe, this.descriptionFr, this.createdAt, this.updatedAt});
  

@override final  String id;
@override final  String title;
@override final  String? description;
@override final  String code;
@override final  double percentDiscount;
@override@JsonKey() final  double minimumOrderPrice;
@override final  int? maxTotalUsage;
@override final  int? maxUsagePerUser;
@override@JsonKey() final  int currentUsageCount;
@override final  DateTime startDate;
@override final  DateTime endDate;
@override@JsonKey() final  bool isActive;
@override final  String? restaurantId;
@override final  String? titleAr;
@override final  String? titleDe;
@override final  String? titleFr;
@override final  String? descriptionAr;
@override final  String? descriptionDe;
@override final  String? descriptionFr;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of CouponModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CouponModelCopyWith<_CouponModel> get copyWith => __$CouponModelCopyWithImpl<_CouponModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CouponModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.code, code) || other.code == code)&&(identical(other.percentDiscount, percentDiscount) || other.percentDiscount == percentDiscount)&&(identical(other.minimumOrderPrice, minimumOrderPrice) || other.minimumOrderPrice == minimumOrderPrice)&&(identical(other.maxTotalUsage, maxTotalUsage) || other.maxTotalUsage == maxTotalUsage)&&(identical(other.maxUsagePerUser, maxUsagePerUser) || other.maxUsagePerUser == maxUsagePerUser)&&(identical(other.currentUsageCount, currentUsageCount) || other.currentUsageCount == currentUsageCount)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.restaurantId, restaurantId) || other.restaurantId == restaurantId)&&(identical(other.titleAr, titleAr) || other.titleAr == titleAr)&&(identical(other.titleDe, titleDe) || other.titleDe == titleDe)&&(identical(other.titleFr, titleFr) || other.titleFr == titleFr)&&(identical(other.descriptionAr, descriptionAr) || other.descriptionAr == descriptionAr)&&(identical(other.descriptionDe, descriptionDe) || other.descriptionDe == descriptionDe)&&(identical(other.descriptionFr, descriptionFr) || other.descriptionFr == descriptionFr)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,title,description,code,percentDiscount,minimumOrderPrice,maxTotalUsage,maxUsagePerUser,currentUsageCount,startDate,endDate,isActive,restaurantId,titleAr,titleDe,titleFr,descriptionAr,descriptionDe,descriptionFr,createdAt,updatedAt]);

@override
String toString() {
  return 'CouponModel(id: $id, title: $title, description: $description, code: $code, percentDiscount: $percentDiscount, minimumOrderPrice: $minimumOrderPrice, maxTotalUsage: $maxTotalUsage, maxUsagePerUser: $maxUsagePerUser, currentUsageCount: $currentUsageCount, startDate: $startDate, endDate: $endDate, isActive: $isActive, restaurantId: $restaurantId, titleAr: $titleAr, titleDe: $titleDe, titleFr: $titleFr, descriptionAr: $descriptionAr, descriptionDe: $descriptionDe, descriptionFr: $descriptionFr, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CouponModelCopyWith<$Res> implements $CouponModelCopyWith<$Res> {
  factory _$CouponModelCopyWith(_CouponModel value, $Res Function(_CouponModel) _then) = __$CouponModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? description, String code, double percentDiscount, double minimumOrderPrice, int? maxTotalUsage, int? maxUsagePerUser, int currentUsageCount, DateTime startDate, DateTime endDate, bool isActive, String? restaurantId, String? titleAr, String? titleDe, String? titleFr, String? descriptionAr, String? descriptionDe, String? descriptionFr, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$CouponModelCopyWithImpl<$Res>
    implements _$CouponModelCopyWith<$Res> {
  __$CouponModelCopyWithImpl(this._self, this._then);

  final _CouponModel _self;
  final $Res Function(_CouponModel) _then;

/// Create a copy of CouponModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? code = null,Object? percentDiscount = null,Object? minimumOrderPrice = null,Object? maxTotalUsage = freezed,Object? maxUsagePerUser = freezed,Object? currentUsageCount = null,Object? startDate = null,Object? endDate = null,Object? isActive = null,Object? restaurantId = freezed,Object? titleAr = freezed,Object? titleDe = freezed,Object? titleFr = freezed,Object? descriptionAr = freezed,Object? descriptionDe = freezed,Object? descriptionFr = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_CouponModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,percentDiscount: null == percentDiscount ? _self.percentDiscount : percentDiscount // ignore: cast_nullable_to_non_nullable
as double,minimumOrderPrice: null == minimumOrderPrice ? _self.minimumOrderPrice : minimumOrderPrice // ignore: cast_nullable_to_non_nullable
as double,maxTotalUsage: freezed == maxTotalUsage ? _self.maxTotalUsage : maxTotalUsage // ignore: cast_nullable_to_non_nullable
as int?,maxUsagePerUser: freezed == maxUsagePerUser ? _self.maxUsagePerUser : maxUsagePerUser // ignore: cast_nullable_to_non_nullable
as int?,currentUsageCount: null == currentUsageCount ? _self.currentUsageCount : currentUsageCount // ignore: cast_nullable_to_non_nullable
as int,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,restaurantId: freezed == restaurantId ? _self.restaurantId : restaurantId // ignore: cast_nullable_to_non_nullable
as String?,titleAr: freezed == titleAr ? _self.titleAr : titleAr // ignore: cast_nullable_to_non_nullable
as String?,titleDe: freezed == titleDe ? _self.titleDe : titleDe // ignore: cast_nullable_to_non_nullable
as String?,titleFr: freezed == titleFr ? _self.titleFr : titleFr // ignore: cast_nullable_to_non_nullable
as String?,descriptionAr: freezed == descriptionAr ? _self.descriptionAr : descriptionAr // ignore: cast_nullable_to_non_nullable
as String?,descriptionDe: freezed == descriptionDe ? _self.descriptionDe : descriptionDe // ignore: cast_nullable_to_non_nullable
as String?,descriptionFr: freezed == descriptionFr ? _self.descriptionFr : descriptionFr // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$CouponUsage {

 String get id; String get couponId; String get userId; String get orderId; double get discountAmount; DateTime get usedAt;
/// Create a copy of CouponUsage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CouponUsageCopyWith<CouponUsage> get copyWith => _$CouponUsageCopyWithImpl<CouponUsage>(this as CouponUsage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CouponUsage&&(identical(other.id, id) || other.id == id)&&(identical(other.couponId, couponId) || other.couponId == couponId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount)&&(identical(other.usedAt, usedAt) || other.usedAt == usedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,couponId,userId,orderId,discountAmount,usedAt);

@override
String toString() {
  return 'CouponUsage(id: $id, couponId: $couponId, userId: $userId, orderId: $orderId, discountAmount: $discountAmount, usedAt: $usedAt)';
}


}

/// @nodoc
abstract mixin class $CouponUsageCopyWith<$Res>  {
  factory $CouponUsageCopyWith(CouponUsage value, $Res Function(CouponUsage) _then) = _$CouponUsageCopyWithImpl;
@useResult
$Res call({
 String id, String couponId, String userId, String orderId, double discountAmount, DateTime usedAt
});




}
/// @nodoc
class _$CouponUsageCopyWithImpl<$Res>
    implements $CouponUsageCopyWith<$Res> {
  _$CouponUsageCopyWithImpl(this._self, this._then);

  final CouponUsage _self;
  final $Res Function(CouponUsage) _then;

/// Create a copy of CouponUsage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? couponId = null,Object? userId = null,Object? orderId = null,Object? discountAmount = null,Object? usedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,couponId: null == couponId ? _self.couponId : couponId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,discountAmount: null == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as double,usedAt: null == usedAt ? _self.usedAt : usedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CouponUsage].
extension CouponUsagePatterns on CouponUsage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CouponUsage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CouponUsage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CouponUsage value)  $default,){
final _that = this;
switch (_that) {
case _CouponUsage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CouponUsage value)?  $default,){
final _that = this;
switch (_that) {
case _CouponUsage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String couponId,  String userId,  String orderId,  double discountAmount,  DateTime usedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CouponUsage() when $default != null:
return $default(_that.id,_that.couponId,_that.userId,_that.orderId,_that.discountAmount,_that.usedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String couponId,  String userId,  String orderId,  double discountAmount,  DateTime usedAt)  $default,) {final _that = this;
switch (_that) {
case _CouponUsage():
return $default(_that.id,_that.couponId,_that.userId,_that.orderId,_that.discountAmount,_that.usedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String couponId,  String userId,  String orderId,  double discountAmount,  DateTime usedAt)?  $default,) {final _that = this;
switch (_that) {
case _CouponUsage() when $default != null:
return $default(_that.id,_that.couponId,_that.userId,_that.orderId,_that.discountAmount,_that.usedAt);case _:
  return null;

}
}

}

/// @nodoc


class _CouponUsage implements CouponUsage {
  const _CouponUsage({required this.id, required this.couponId, required this.userId, required this.orderId, required this.discountAmount, required this.usedAt});
  

@override final  String id;
@override final  String couponId;
@override final  String userId;
@override final  String orderId;
@override final  double discountAmount;
@override final  DateTime usedAt;

/// Create a copy of CouponUsage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CouponUsageCopyWith<_CouponUsage> get copyWith => __$CouponUsageCopyWithImpl<_CouponUsage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CouponUsage&&(identical(other.id, id) || other.id == id)&&(identical(other.couponId, couponId) || other.couponId == couponId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount)&&(identical(other.usedAt, usedAt) || other.usedAt == usedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,couponId,userId,orderId,discountAmount,usedAt);

@override
String toString() {
  return 'CouponUsage(id: $id, couponId: $couponId, userId: $userId, orderId: $orderId, discountAmount: $discountAmount, usedAt: $usedAt)';
}


}

/// @nodoc
abstract mixin class _$CouponUsageCopyWith<$Res> implements $CouponUsageCopyWith<$Res> {
  factory _$CouponUsageCopyWith(_CouponUsage value, $Res Function(_CouponUsage) _then) = __$CouponUsageCopyWithImpl;
@override @useResult
$Res call({
 String id, String couponId, String userId, String orderId, double discountAmount, DateTime usedAt
});




}
/// @nodoc
class __$CouponUsageCopyWithImpl<$Res>
    implements _$CouponUsageCopyWith<$Res> {
  __$CouponUsageCopyWithImpl(this._self, this._then);

  final _CouponUsage _self;
  final $Res Function(_CouponUsage) _then;

/// Create a copy of CouponUsage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? couponId = null,Object? userId = null,Object? orderId = null,Object? discountAmount = null,Object? usedAt = null,}) {
  return _then(_CouponUsage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,couponId: null == couponId ? _self.couponId : couponId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,discountAmount: null == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as double,usedAt: null == usedAt ? _self.usedAt : usedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
