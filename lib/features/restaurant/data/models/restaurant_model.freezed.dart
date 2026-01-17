// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'restaurant_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RestaurantAddressModel {

 String? get id; String? get label; double? get lat; double? get lng; String? get fullAddress; String? get streetName; String? get houseNumber; String? get city; String? get postalCode; String? get country; DateTime? get createdAt;
/// Create a copy of RestaurantAddressModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RestaurantAddressModelCopyWith<RestaurantAddressModel> get copyWith => _$RestaurantAddressModelCopyWithImpl<RestaurantAddressModel>(this as RestaurantAddressModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RestaurantAddressModel&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.fullAddress, fullAddress) || other.fullAddress == fullAddress)&&(identical(other.streetName, streetName) || other.streetName == streetName)&&(identical(other.houseNumber, houseNumber) || other.houseNumber == houseNumber)&&(identical(other.city, city) || other.city == city)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.country, country) || other.country == country)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,label,lat,lng,fullAddress,streetName,houseNumber,city,postalCode,country,createdAt);

@override
String toString() {
  return 'RestaurantAddressModel(id: $id, label: $label, lat: $lat, lng: $lng, fullAddress: $fullAddress, streetName: $streetName, houseNumber: $houseNumber, city: $city, postalCode: $postalCode, country: $country, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $RestaurantAddressModelCopyWith<$Res>  {
  factory $RestaurantAddressModelCopyWith(RestaurantAddressModel value, $Res Function(RestaurantAddressModel) _then) = _$RestaurantAddressModelCopyWithImpl;
@useResult
$Res call({
 String? id, String? label, double? lat, double? lng, String? fullAddress, String? streetName, String? houseNumber, String? city, String? postalCode, String? country, DateTime? createdAt
});




}
/// @nodoc
class _$RestaurantAddressModelCopyWithImpl<$Res>
    implements $RestaurantAddressModelCopyWith<$Res> {
  _$RestaurantAddressModelCopyWithImpl(this._self, this._then);

  final RestaurantAddressModel _self;
  final $Res Function(RestaurantAddressModel) _then;

/// Create a copy of RestaurantAddressModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? label = freezed,Object? lat = freezed,Object? lng = freezed,Object? fullAddress = freezed,Object? streetName = freezed,Object? houseNumber = freezed,Object? city = freezed,Object? postalCode = freezed,Object? country = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,lat: freezed == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double?,lng: freezed == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double?,fullAddress: freezed == fullAddress ? _self.fullAddress : fullAddress // ignore: cast_nullable_to_non_nullable
as String?,streetName: freezed == streetName ? _self.streetName : streetName // ignore: cast_nullable_to_non_nullable
as String?,houseNumber: freezed == houseNumber ? _self.houseNumber : houseNumber // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,postalCode: freezed == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RestaurantAddressModel].
extension RestaurantAddressModelPatterns on RestaurantAddressModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RestaurantAddressModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RestaurantAddressModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RestaurantAddressModel value)  $default,){
final _that = this;
switch (_that) {
case _RestaurantAddressModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RestaurantAddressModel value)?  $default,){
final _that = this;
switch (_that) {
case _RestaurantAddressModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? label,  double? lat,  double? lng,  String? fullAddress,  String? streetName,  String? houseNumber,  String? city,  String? postalCode,  String? country,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RestaurantAddressModel() when $default != null:
return $default(_that.id,_that.label,_that.lat,_that.lng,_that.fullAddress,_that.streetName,_that.houseNumber,_that.city,_that.postalCode,_that.country,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? label,  double? lat,  double? lng,  String? fullAddress,  String? streetName,  String? houseNumber,  String? city,  String? postalCode,  String? country,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _RestaurantAddressModel():
return $default(_that.id,_that.label,_that.lat,_that.lng,_that.fullAddress,_that.streetName,_that.houseNumber,_that.city,_that.postalCode,_that.country,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? label,  double? lat,  double? lng,  String? fullAddress,  String? streetName,  String? houseNumber,  String? city,  String? postalCode,  String? country,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _RestaurantAddressModel() when $default != null:
return $default(_that.id,_that.label,_that.lat,_that.lng,_that.fullAddress,_that.streetName,_that.houseNumber,_that.city,_that.postalCode,_that.country,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _RestaurantAddressModel implements RestaurantAddressModel {
  const _RestaurantAddressModel({this.id, this.label, this.lat, this.lng, this.fullAddress, this.streetName, this.houseNumber, this.city, this.postalCode, this.country, this.createdAt});
  

@override final  String? id;
@override final  String? label;
@override final  double? lat;
@override final  double? lng;
@override final  String? fullAddress;
@override final  String? streetName;
@override final  String? houseNumber;
@override final  String? city;
@override final  String? postalCode;
@override final  String? country;
@override final  DateTime? createdAt;

/// Create a copy of RestaurantAddressModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RestaurantAddressModelCopyWith<_RestaurantAddressModel> get copyWith => __$RestaurantAddressModelCopyWithImpl<_RestaurantAddressModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RestaurantAddressModel&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.fullAddress, fullAddress) || other.fullAddress == fullAddress)&&(identical(other.streetName, streetName) || other.streetName == streetName)&&(identical(other.houseNumber, houseNumber) || other.houseNumber == houseNumber)&&(identical(other.city, city) || other.city == city)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.country, country) || other.country == country)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,label,lat,lng,fullAddress,streetName,houseNumber,city,postalCode,country,createdAt);

@override
String toString() {
  return 'RestaurantAddressModel(id: $id, label: $label, lat: $lat, lng: $lng, fullAddress: $fullAddress, streetName: $streetName, houseNumber: $houseNumber, city: $city, postalCode: $postalCode, country: $country, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$RestaurantAddressModelCopyWith<$Res> implements $RestaurantAddressModelCopyWith<$Res> {
  factory _$RestaurantAddressModelCopyWith(_RestaurantAddressModel value, $Res Function(_RestaurantAddressModel) _then) = __$RestaurantAddressModelCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? label, double? lat, double? lng, String? fullAddress, String? streetName, String? houseNumber, String? city, String? postalCode, String? country, DateTime? createdAt
});




}
/// @nodoc
class __$RestaurantAddressModelCopyWithImpl<$Res>
    implements _$RestaurantAddressModelCopyWith<$Res> {
  __$RestaurantAddressModelCopyWithImpl(this._self, this._then);

  final _RestaurantAddressModel _self;
  final $Res Function(_RestaurantAddressModel) _then;

/// Create a copy of RestaurantAddressModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? label = freezed,Object? lat = freezed,Object? lng = freezed,Object? fullAddress = freezed,Object? streetName = freezed,Object? houseNumber = freezed,Object? city = freezed,Object? postalCode = freezed,Object? country = freezed,Object? createdAt = freezed,}) {
  return _then(_RestaurantAddressModel(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,lat: freezed == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double?,lng: freezed == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double?,fullAddress: freezed == fullAddress ? _self.fullAddress : fullAddress // ignore: cast_nullable_to_non_nullable
as String?,streetName: freezed == streetName ? _self.streetName : streetName // ignore: cast_nullable_to_non_nullable
as String?,houseNumber: freezed == houseNumber ? _self.houseNumber : houseNumber // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,postalCode: freezed == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$RestaurantStats {

 int get pendingOrders; int get totalOrders; double get totalRevenue;
/// Create a copy of RestaurantStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RestaurantStatsCopyWith<RestaurantStats> get copyWith => _$RestaurantStatsCopyWithImpl<RestaurantStats>(this as RestaurantStats, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RestaurantStats&&(identical(other.pendingOrders, pendingOrders) || other.pendingOrders == pendingOrders)&&(identical(other.totalOrders, totalOrders) || other.totalOrders == totalOrders)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue));
}


@override
int get hashCode => Object.hash(runtimeType,pendingOrders,totalOrders,totalRevenue);

@override
String toString() {
  return 'RestaurantStats(pendingOrders: $pendingOrders, totalOrders: $totalOrders, totalRevenue: $totalRevenue)';
}


}

/// @nodoc
abstract mixin class $RestaurantStatsCopyWith<$Res>  {
  factory $RestaurantStatsCopyWith(RestaurantStats value, $Res Function(RestaurantStats) _then) = _$RestaurantStatsCopyWithImpl;
@useResult
$Res call({
 int pendingOrders, int totalOrders, double totalRevenue
});




}
/// @nodoc
class _$RestaurantStatsCopyWithImpl<$Res>
    implements $RestaurantStatsCopyWith<$Res> {
  _$RestaurantStatsCopyWithImpl(this._self, this._then);

  final RestaurantStats _self;
  final $Res Function(RestaurantStats) _then;

/// Create a copy of RestaurantStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pendingOrders = null,Object? totalOrders = null,Object? totalRevenue = null,}) {
  return _then(_self.copyWith(
pendingOrders: null == pendingOrders ? _self.pendingOrders : pendingOrders // ignore: cast_nullable_to_non_nullable
as int,totalOrders: null == totalOrders ? _self.totalOrders : totalOrders // ignore: cast_nullable_to_non_nullable
as int,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [RestaurantStats].
extension RestaurantStatsPatterns on RestaurantStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RestaurantStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RestaurantStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RestaurantStats value)  $default,){
final _that = this;
switch (_that) {
case _RestaurantStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RestaurantStats value)?  $default,){
final _that = this;
switch (_that) {
case _RestaurantStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int pendingOrders,  int totalOrders,  double totalRevenue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RestaurantStats() when $default != null:
return $default(_that.pendingOrders,_that.totalOrders,_that.totalRevenue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int pendingOrders,  int totalOrders,  double totalRevenue)  $default,) {final _that = this;
switch (_that) {
case _RestaurantStats():
return $default(_that.pendingOrders,_that.totalOrders,_that.totalRevenue);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int pendingOrders,  int totalOrders,  double totalRevenue)?  $default,) {final _that = this;
switch (_that) {
case _RestaurantStats() when $default != null:
return $default(_that.pendingOrders,_that.totalOrders,_that.totalRevenue);case _:
  return null;

}
}

}

/// @nodoc


class _RestaurantStats implements RestaurantStats {
  const _RestaurantStats({this.pendingOrders = 0, this.totalOrders = 0, this.totalRevenue = 0.0});
  

@override@JsonKey() final  int pendingOrders;
@override@JsonKey() final  int totalOrders;
@override@JsonKey() final  double totalRevenue;

/// Create a copy of RestaurantStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RestaurantStatsCopyWith<_RestaurantStats> get copyWith => __$RestaurantStatsCopyWithImpl<_RestaurantStats>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RestaurantStats&&(identical(other.pendingOrders, pendingOrders) || other.pendingOrders == pendingOrders)&&(identical(other.totalOrders, totalOrders) || other.totalOrders == totalOrders)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue));
}


@override
int get hashCode => Object.hash(runtimeType,pendingOrders,totalOrders,totalRevenue);

@override
String toString() {
  return 'RestaurantStats(pendingOrders: $pendingOrders, totalOrders: $totalOrders, totalRevenue: $totalRevenue)';
}


}

/// @nodoc
abstract mixin class _$RestaurantStatsCopyWith<$Res> implements $RestaurantStatsCopyWith<$Res> {
  factory _$RestaurantStatsCopyWith(_RestaurantStats value, $Res Function(_RestaurantStats) _then) = __$RestaurantStatsCopyWithImpl;
@override @useResult
$Res call({
 int pendingOrders, int totalOrders, double totalRevenue
});




}
/// @nodoc
class __$RestaurantStatsCopyWithImpl<$Res>
    implements _$RestaurantStatsCopyWith<$Res> {
  __$RestaurantStatsCopyWithImpl(this._self, this._then);

  final _RestaurantStats _self;
  final $Res Function(_RestaurantStats) _then;

/// Create a copy of RestaurantStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pendingOrders = null,Object? totalOrders = null,Object? totalRevenue = null,}) {
  return _then(_RestaurantStats(
pendingOrders: null == pendingOrders ? _self.pendingOrders : pendingOrders // ignore: cast_nullable_to_non_nullable
as int,totalOrders: null == totalOrders ? _self.totalOrders : totalOrders // ignore: cast_nullable_to_non_nullable
as int,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
mixin _$RestaurantModel {

 String get id; String get name; String? get description; String? get phone; String? get email; String? get address; String? get city; String? get country; String? get imageUrl; String? get logoUrl; RestaurantStatus get status; bool get isOpen; String? get openingHours; String? get closingHours; double get deliveryFee; double get minimumOrder; int get estimatedDeliveryTime; List<String> get cuisineTypes; double get rating; int get totalReviews; DateTime? get createdAt; DateTime? get updatedAt;// Today's stats (returned from API)
 RestaurantStats? get todayStats;// Direct location coordinates
 double? get lat; double? get lng;// Full address object from API
 RestaurantAddressModel? get addressData;
/// Create a copy of RestaurantModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RestaurantModelCopyWith<RestaurantModel> get copyWith => _$RestaurantModelCopyWithImpl<RestaurantModel>(this as RestaurantModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RestaurantModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.address, address) || other.address == address)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.isOpen, isOpen) || other.isOpen == isOpen)&&(identical(other.openingHours, openingHours) || other.openingHours == openingHours)&&(identical(other.closingHours, closingHours) || other.closingHours == closingHours)&&(identical(other.deliveryFee, deliveryFee) || other.deliveryFee == deliveryFee)&&(identical(other.minimumOrder, minimumOrder) || other.minimumOrder == minimumOrder)&&(identical(other.estimatedDeliveryTime, estimatedDeliveryTime) || other.estimatedDeliveryTime == estimatedDeliveryTime)&&const DeepCollectionEquality().equals(other.cuisineTypes, cuisineTypes)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.totalReviews, totalReviews) || other.totalReviews == totalReviews)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.todayStats, todayStats) || other.todayStats == todayStats)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.addressData, addressData) || other.addressData == addressData));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,name,description,phone,email,address,city,country,imageUrl,logoUrl,status,isOpen,openingHours,closingHours,deliveryFee,minimumOrder,estimatedDeliveryTime,const DeepCollectionEquality().hash(cuisineTypes),rating,totalReviews,createdAt,updatedAt,todayStats,lat,lng,addressData]);

@override
String toString() {
  return 'RestaurantModel(id: $id, name: $name, description: $description, phone: $phone, email: $email, address: $address, city: $city, country: $country, imageUrl: $imageUrl, logoUrl: $logoUrl, status: $status, isOpen: $isOpen, openingHours: $openingHours, closingHours: $closingHours, deliveryFee: $deliveryFee, minimumOrder: $minimumOrder, estimatedDeliveryTime: $estimatedDeliveryTime, cuisineTypes: $cuisineTypes, rating: $rating, totalReviews: $totalReviews, createdAt: $createdAt, updatedAt: $updatedAt, todayStats: $todayStats, lat: $lat, lng: $lng, addressData: $addressData)';
}


}

/// @nodoc
abstract mixin class $RestaurantModelCopyWith<$Res>  {
  factory $RestaurantModelCopyWith(RestaurantModel value, $Res Function(RestaurantModel) _then) = _$RestaurantModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, String? phone, String? email, String? address, String? city, String? country, String? imageUrl, String? logoUrl, RestaurantStatus status, bool isOpen, String? openingHours, String? closingHours, double deliveryFee, double minimumOrder, int estimatedDeliveryTime, List<String> cuisineTypes, double rating, int totalReviews, DateTime? createdAt, DateTime? updatedAt, RestaurantStats? todayStats, double? lat, double? lng, RestaurantAddressModel? addressData
});


$RestaurantStatsCopyWith<$Res>? get todayStats;$RestaurantAddressModelCopyWith<$Res>? get addressData;

}
/// @nodoc
class _$RestaurantModelCopyWithImpl<$Res>
    implements $RestaurantModelCopyWith<$Res> {
  _$RestaurantModelCopyWithImpl(this._self, this._then);

  final RestaurantModel _self;
  final $Res Function(RestaurantModel) _then;

/// Create a copy of RestaurantModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? phone = freezed,Object? email = freezed,Object? address = freezed,Object? city = freezed,Object? country = freezed,Object? imageUrl = freezed,Object? logoUrl = freezed,Object? status = null,Object? isOpen = null,Object? openingHours = freezed,Object? closingHours = freezed,Object? deliveryFee = null,Object? minimumOrder = null,Object? estimatedDeliveryTime = null,Object? cuisineTypes = null,Object? rating = null,Object? totalReviews = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? todayStats = freezed,Object? lat = freezed,Object? lng = freezed,Object? addressData = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RestaurantStatus,isOpen: null == isOpen ? _self.isOpen : isOpen // ignore: cast_nullable_to_non_nullable
as bool,openingHours: freezed == openingHours ? _self.openingHours : openingHours // ignore: cast_nullable_to_non_nullable
as String?,closingHours: freezed == closingHours ? _self.closingHours : closingHours // ignore: cast_nullable_to_non_nullable
as String?,deliveryFee: null == deliveryFee ? _self.deliveryFee : deliveryFee // ignore: cast_nullable_to_non_nullable
as double,minimumOrder: null == minimumOrder ? _self.minimumOrder : minimumOrder // ignore: cast_nullable_to_non_nullable
as double,estimatedDeliveryTime: null == estimatedDeliveryTime ? _self.estimatedDeliveryTime : estimatedDeliveryTime // ignore: cast_nullable_to_non_nullable
as int,cuisineTypes: null == cuisineTypes ? _self.cuisineTypes : cuisineTypes // ignore: cast_nullable_to_non_nullable
as List<String>,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,totalReviews: null == totalReviews ? _self.totalReviews : totalReviews // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,todayStats: freezed == todayStats ? _self.todayStats : todayStats // ignore: cast_nullable_to_non_nullable
as RestaurantStats?,lat: freezed == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double?,lng: freezed == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double?,addressData: freezed == addressData ? _self.addressData : addressData // ignore: cast_nullable_to_non_nullable
as RestaurantAddressModel?,
  ));
}
/// Create a copy of RestaurantModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RestaurantStatsCopyWith<$Res>? get todayStats {
    if (_self.todayStats == null) {
    return null;
  }

  return $RestaurantStatsCopyWith<$Res>(_self.todayStats!, (value) {
    return _then(_self.copyWith(todayStats: value));
  });
}/// Create a copy of RestaurantModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RestaurantAddressModelCopyWith<$Res>? get addressData {
    if (_self.addressData == null) {
    return null;
  }

  return $RestaurantAddressModelCopyWith<$Res>(_self.addressData!, (value) {
    return _then(_self.copyWith(addressData: value));
  });
}
}


/// Adds pattern-matching-related methods to [RestaurantModel].
extension RestaurantModelPatterns on RestaurantModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RestaurantModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RestaurantModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RestaurantModel value)  $default,){
final _that = this;
switch (_that) {
case _RestaurantModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RestaurantModel value)?  $default,){
final _that = this;
switch (_that) {
case _RestaurantModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  String? phone,  String? email,  String? address,  String? city,  String? country,  String? imageUrl,  String? logoUrl,  RestaurantStatus status,  bool isOpen,  String? openingHours,  String? closingHours,  double deliveryFee,  double minimumOrder,  int estimatedDeliveryTime,  List<String> cuisineTypes,  double rating,  int totalReviews,  DateTime? createdAt,  DateTime? updatedAt,  RestaurantStats? todayStats,  double? lat,  double? lng,  RestaurantAddressModel? addressData)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RestaurantModel() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.phone,_that.email,_that.address,_that.city,_that.country,_that.imageUrl,_that.logoUrl,_that.status,_that.isOpen,_that.openingHours,_that.closingHours,_that.deliveryFee,_that.minimumOrder,_that.estimatedDeliveryTime,_that.cuisineTypes,_that.rating,_that.totalReviews,_that.createdAt,_that.updatedAt,_that.todayStats,_that.lat,_that.lng,_that.addressData);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  String? phone,  String? email,  String? address,  String? city,  String? country,  String? imageUrl,  String? logoUrl,  RestaurantStatus status,  bool isOpen,  String? openingHours,  String? closingHours,  double deliveryFee,  double minimumOrder,  int estimatedDeliveryTime,  List<String> cuisineTypes,  double rating,  int totalReviews,  DateTime? createdAt,  DateTime? updatedAt,  RestaurantStats? todayStats,  double? lat,  double? lng,  RestaurantAddressModel? addressData)  $default,) {final _that = this;
switch (_that) {
case _RestaurantModel():
return $default(_that.id,_that.name,_that.description,_that.phone,_that.email,_that.address,_that.city,_that.country,_that.imageUrl,_that.logoUrl,_that.status,_that.isOpen,_that.openingHours,_that.closingHours,_that.deliveryFee,_that.minimumOrder,_that.estimatedDeliveryTime,_that.cuisineTypes,_that.rating,_that.totalReviews,_that.createdAt,_that.updatedAt,_that.todayStats,_that.lat,_that.lng,_that.addressData);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description,  String? phone,  String? email,  String? address,  String? city,  String? country,  String? imageUrl,  String? logoUrl,  RestaurantStatus status,  bool isOpen,  String? openingHours,  String? closingHours,  double deliveryFee,  double minimumOrder,  int estimatedDeliveryTime,  List<String> cuisineTypes,  double rating,  int totalReviews,  DateTime? createdAt,  DateTime? updatedAt,  RestaurantStats? todayStats,  double? lat,  double? lng,  RestaurantAddressModel? addressData)?  $default,) {final _that = this;
switch (_that) {
case _RestaurantModel() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.phone,_that.email,_that.address,_that.city,_that.country,_that.imageUrl,_that.logoUrl,_that.status,_that.isOpen,_that.openingHours,_that.closingHours,_that.deliveryFee,_that.minimumOrder,_that.estimatedDeliveryTime,_that.cuisineTypes,_that.rating,_that.totalReviews,_that.createdAt,_that.updatedAt,_that.todayStats,_that.lat,_that.lng,_that.addressData);case _:
  return null;

}
}

}

/// @nodoc


class _RestaurantModel implements RestaurantModel {
  const _RestaurantModel({required this.id, required this.name, this.description, this.phone, this.email, this.address, this.city, this.country, this.imageUrl, this.logoUrl, this.status = RestaurantStatus.pending, this.isOpen = false, this.openingHours, this.closingHours, this.deliveryFee = 0.0, this.minimumOrder = 0.0, this.estimatedDeliveryTime = 30, final  List<String> cuisineTypes = const [], this.rating = 0.0, this.totalReviews = 0, this.createdAt, this.updatedAt, this.todayStats, this.lat, this.lng, this.addressData}): _cuisineTypes = cuisineTypes;
  

@override final  String id;
@override final  String name;
@override final  String? description;
@override final  String? phone;
@override final  String? email;
@override final  String? address;
@override final  String? city;
@override final  String? country;
@override final  String? imageUrl;
@override final  String? logoUrl;
@override@JsonKey() final  RestaurantStatus status;
@override@JsonKey() final  bool isOpen;
@override final  String? openingHours;
@override final  String? closingHours;
@override@JsonKey() final  double deliveryFee;
@override@JsonKey() final  double minimumOrder;
@override@JsonKey() final  int estimatedDeliveryTime;
 final  List<String> _cuisineTypes;
@override@JsonKey() List<String> get cuisineTypes {
  if (_cuisineTypes is EqualUnmodifiableListView) return _cuisineTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cuisineTypes);
}

@override@JsonKey() final  double rating;
@override@JsonKey() final  int totalReviews;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
// Today's stats (returned from API)
@override final  RestaurantStats? todayStats;
// Direct location coordinates
@override final  double? lat;
@override final  double? lng;
// Full address object from API
@override final  RestaurantAddressModel? addressData;

/// Create a copy of RestaurantModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RestaurantModelCopyWith<_RestaurantModel> get copyWith => __$RestaurantModelCopyWithImpl<_RestaurantModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RestaurantModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.address, address) || other.address == address)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.isOpen, isOpen) || other.isOpen == isOpen)&&(identical(other.openingHours, openingHours) || other.openingHours == openingHours)&&(identical(other.closingHours, closingHours) || other.closingHours == closingHours)&&(identical(other.deliveryFee, deliveryFee) || other.deliveryFee == deliveryFee)&&(identical(other.minimumOrder, minimumOrder) || other.minimumOrder == minimumOrder)&&(identical(other.estimatedDeliveryTime, estimatedDeliveryTime) || other.estimatedDeliveryTime == estimatedDeliveryTime)&&const DeepCollectionEquality().equals(other._cuisineTypes, _cuisineTypes)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.totalReviews, totalReviews) || other.totalReviews == totalReviews)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.todayStats, todayStats) || other.todayStats == todayStats)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.addressData, addressData) || other.addressData == addressData));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,name,description,phone,email,address,city,country,imageUrl,logoUrl,status,isOpen,openingHours,closingHours,deliveryFee,minimumOrder,estimatedDeliveryTime,const DeepCollectionEquality().hash(_cuisineTypes),rating,totalReviews,createdAt,updatedAt,todayStats,lat,lng,addressData]);

@override
String toString() {
  return 'RestaurantModel(id: $id, name: $name, description: $description, phone: $phone, email: $email, address: $address, city: $city, country: $country, imageUrl: $imageUrl, logoUrl: $logoUrl, status: $status, isOpen: $isOpen, openingHours: $openingHours, closingHours: $closingHours, deliveryFee: $deliveryFee, minimumOrder: $minimumOrder, estimatedDeliveryTime: $estimatedDeliveryTime, cuisineTypes: $cuisineTypes, rating: $rating, totalReviews: $totalReviews, createdAt: $createdAt, updatedAt: $updatedAt, todayStats: $todayStats, lat: $lat, lng: $lng, addressData: $addressData)';
}


}

/// @nodoc
abstract mixin class _$RestaurantModelCopyWith<$Res> implements $RestaurantModelCopyWith<$Res> {
  factory _$RestaurantModelCopyWith(_RestaurantModel value, $Res Function(_RestaurantModel) _then) = __$RestaurantModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, String? phone, String? email, String? address, String? city, String? country, String? imageUrl, String? logoUrl, RestaurantStatus status, bool isOpen, String? openingHours, String? closingHours, double deliveryFee, double minimumOrder, int estimatedDeliveryTime, List<String> cuisineTypes, double rating, int totalReviews, DateTime? createdAt, DateTime? updatedAt, RestaurantStats? todayStats, double? lat, double? lng, RestaurantAddressModel? addressData
});


@override $RestaurantStatsCopyWith<$Res>? get todayStats;@override $RestaurantAddressModelCopyWith<$Res>? get addressData;

}
/// @nodoc
class __$RestaurantModelCopyWithImpl<$Res>
    implements _$RestaurantModelCopyWith<$Res> {
  __$RestaurantModelCopyWithImpl(this._self, this._then);

  final _RestaurantModel _self;
  final $Res Function(_RestaurantModel) _then;

/// Create a copy of RestaurantModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? phone = freezed,Object? email = freezed,Object? address = freezed,Object? city = freezed,Object? country = freezed,Object? imageUrl = freezed,Object? logoUrl = freezed,Object? status = null,Object? isOpen = null,Object? openingHours = freezed,Object? closingHours = freezed,Object? deliveryFee = null,Object? minimumOrder = null,Object? estimatedDeliveryTime = null,Object? cuisineTypes = null,Object? rating = null,Object? totalReviews = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? todayStats = freezed,Object? lat = freezed,Object? lng = freezed,Object? addressData = freezed,}) {
  return _then(_RestaurantModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RestaurantStatus,isOpen: null == isOpen ? _self.isOpen : isOpen // ignore: cast_nullable_to_non_nullable
as bool,openingHours: freezed == openingHours ? _self.openingHours : openingHours // ignore: cast_nullable_to_non_nullable
as String?,closingHours: freezed == closingHours ? _self.closingHours : closingHours // ignore: cast_nullable_to_non_nullable
as String?,deliveryFee: null == deliveryFee ? _self.deliveryFee : deliveryFee // ignore: cast_nullable_to_non_nullable
as double,minimumOrder: null == minimumOrder ? _self.minimumOrder : minimumOrder // ignore: cast_nullable_to_non_nullable
as double,estimatedDeliveryTime: null == estimatedDeliveryTime ? _self.estimatedDeliveryTime : estimatedDeliveryTime // ignore: cast_nullable_to_non_nullable
as int,cuisineTypes: null == cuisineTypes ? _self._cuisineTypes : cuisineTypes // ignore: cast_nullable_to_non_nullable
as List<String>,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,totalReviews: null == totalReviews ? _self.totalReviews : totalReviews // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,todayStats: freezed == todayStats ? _self.todayStats : todayStats // ignore: cast_nullable_to_non_nullable
as RestaurantStats?,lat: freezed == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double?,lng: freezed == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double?,addressData: freezed == addressData ? _self.addressData : addressData // ignore: cast_nullable_to_non_nullable
as RestaurantAddressModel?,
  ));
}

/// Create a copy of RestaurantModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RestaurantStatsCopyWith<$Res>? get todayStats {
    if (_self.todayStats == null) {
    return null;
  }

  return $RestaurantStatsCopyWith<$Res>(_self.todayStats!, (value) {
    return _then(_self.copyWith(todayStats: value));
  });
}/// Create a copy of RestaurantModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RestaurantAddressModelCopyWith<$Res>? get addressData {
    if (_self.addressData == null) {
    return null;
  }

  return $RestaurantAddressModelCopyWith<$Res>(_self.addressData!, (value) {
    return _then(_self.copyWith(addressData: value));
  });
}
}

// dart format on
