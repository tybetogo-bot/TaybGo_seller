// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'address_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CustomerAddressModel {

/// Unique identifier (read-only from API)
 int? get id;/// Label for the address (e.g., "home", "work", "office")
 String get label;/// Latitude as decimal string
 String get lat;/// Longitude as decimal string
 String get lng;/// Full formatted address string
@JsonKey(name: 'full_address') String get fullAddress;/// Street name
@JsonKey(name: 'street_name') String? get streetName;/// House/building number
@JsonKey(name: 'house_number') String? get houseNumber;/// City name
 String? get city;/// Postal/ZIP code
@JsonKey(name: 'postal_code') String? get postalCode;/// Country name
 String? get country;/// Creation timestamp (read-only from API)
@JsonKey(name: 'created_at') DateTime? get createdAt;
/// Create a copy of CustomerAddressModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerAddressModelCopyWith<CustomerAddressModel> get copyWith => _$CustomerAddressModelCopyWithImpl<CustomerAddressModel>(this as CustomerAddressModel, _$identity);

  /// Serializes this CustomerAddressModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomerAddressModel&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.fullAddress, fullAddress) || other.fullAddress == fullAddress)&&(identical(other.streetName, streetName) || other.streetName == streetName)&&(identical(other.houseNumber, houseNumber) || other.houseNumber == houseNumber)&&(identical(other.city, city) || other.city == city)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.country, country) || other.country == country)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,lat,lng,fullAddress,streetName,houseNumber,city,postalCode,country,createdAt);

@override
String toString() {
  return 'CustomerAddressModel(id: $id, label: $label, lat: $lat, lng: $lng, fullAddress: $fullAddress, streetName: $streetName, houseNumber: $houseNumber, city: $city, postalCode: $postalCode, country: $country, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $CustomerAddressModelCopyWith<$Res>  {
  factory $CustomerAddressModelCopyWith(CustomerAddressModel value, $Res Function(CustomerAddressModel) _then) = _$CustomerAddressModelCopyWithImpl;
@useResult
$Res call({
 int? id, String label, String lat, String lng,@JsonKey(name: 'full_address') String fullAddress,@JsonKey(name: 'street_name') String? streetName,@JsonKey(name: 'house_number') String? houseNumber, String? city,@JsonKey(name: 'postal_code') String? postalCode, String? country,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class _$CustomerAddressModelCopyWithImpl<$Res>
    implements $CustomerAddressModelCopyWith<$Res> {
  _$CustomerAddressModelCopyWithImpl(this._self, this._then);

  final CustomerAddressModel _self;
  final $Res Function(CustomerAddressModel) _then;

/// Create a copy of CustomerAddressModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? label = null,Object? lat = null,Object? lng = null,Object? fullAddress = null,Object? streetName = freezed,Object? houseNumber = freezed,Object? city = freezed,Object? postalCode = freezed,Object? country = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as String,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as String,fullAddress: null == fullAddress ? _self.fullAddress : fullAddress // ignore: cast_nullable_to_non_nullable
as String,streetName: freezed == streetName ? _self.streetName : streetName // ignore: cast_nullable_to_non_nullable
as String?,houseNumber: freezed == houseNumber ? _self.houseNumber : houseNumber // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,postalCode: freezed == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [CustomerAddressModel].
extension CustomerAddressModelPatterns on CustomerAddressModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomerAddressModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomerAddressModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomerAddressModel value)  $default,){
final _that = this;
switch (_that) {
case _CustomerAddressModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomerAddressModel value)?  $default,){
final _that = this;
switch (_that) {
case _CustomerAddressModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  String label,  String lat,  String lng, @JsonKey(name: 'full_address')  String fullAddress, @JsonKey(name: 'street_name')  String? streetName, @JsonKey(name: 'house_number')  String? houseNumber,  String? city, @JsonKey(name: 'postal_code')  String? postalCode,  String? country, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomerAddressModel() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  String label,  String lat,  String lng, @JsonKey(name: 'full_address')  String fullAddress, @JsonKey(name: 'street_name')  String? streetName, @JsonKey(name: 'house_number')  String? houseNumber,  String? city, @JsonKey(name: 'postal_code')  String? postalCode,  String? country, @JsonKey(name: 'created_at')  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _CustomerAddressModel():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  String label,  String lat,  String lng, @JsonKey(name: 'full_address')  String fullAddress, @JsonKey(name: 'street_name')  String? streetName, @JsonKey(name: 'house_number')  String? houseNumber,  String? city, @JsonKey(name: 'postal_code')  String? postalCode,  String? country, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _CustomerAddressModel() when $default != null:
return $default(_that.id,_that.label,_that.lat,_that.lng,_that.fullAddress,_that.streetName,_that.houseNumber,_that.city,_that.postalCode,_that.country,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CustomerAddressModel extends CustomerAddressModel {
  const _CustomerAddressModel({this.id, required this.label, required this.lat, required this.lng, @JsonKey(name: 'full_address') required this.fullAddress, @JsonKey(name: 'street_name') this.streetName, @JsonKey(name: 'house_number') this.houseNumber, this.city, @JsonKey(name: 'postal_code') this.postalCode, this.country, @JsonKey(name: 'created_at') this.createdAt}): super._();
  factory _CustomerAddressModel.fromJson(Map<String, dynamic> json) => _$CustomerAddressModelFromJson(json);

/// Unique identifier (read-only from API)
@override final  int? id;
/// Label for the address (e.g., "home", "work", "office")
@override final  String label;
/// Latitude as decimal string
@override final  String lat;
/// Longitude as decimal string
@override final  String lng;
/// Full formatted address string
@override@JsonKey(name: 'full_address') final  String fullAddress;
/// Street name
@override@JsonKey(name: 'street_name') final  String? streetName;
/// House/building number
@override@JsonKey(name: 'house_number') final  String? houseNumber;
/// City name
@override final  String? city;
/// Postal/ZIP code
@override@JsonKey(name: 'postal_code') final  String? postalCode;
/// Country name
@override final  String? country;
/// Creation timestamp (read-only from API)
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;

/// Create a copy of CustomerAddressModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomerAddressModelCopyWith<_CustomerAddressModel> get copyWith => __$CustomerAddressModelCopyWithImpl<_CustomerAddressModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CustomerAddressModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomerAddressModel&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.fullAddress, fullAddress) || other.fullAddress == fullAddress)&&(identical(other.streetName, streetName) || other.streetName == streetName)&&(identical(other.houseNumber, houseNumber) || other.houseNumber == houseNumber)&&(identical(other.city, city) || other.city == city)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.country, country) || other.country == country)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,lat,lng,fullAddress,streetName,houseNumber,city,postalCode,country,createdAt);

@override
String toString() {
  return 'CustomerAddressModel(id: $id, label: $label, lat: $lat, lng: $lng, fullAddress: $fullAddress, streetName: $streetName, houseNumber: $houseNumber, city: $city, postalCode: $postalCode, country: $country, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$CustomerAddressModelCopyWith<$Res> implements $CustomerAddressModelCopyWith<$Res> {
  factory _$CustomerAddressModelCopyWith(_CustomerAddressModel value, $Res Function(_CustomerAddressModel) _then) = __$CustomerAddressModelCopyWithImpl;
@override @useResult
$Res call({
 int? id, String label, String lat, String lng,@JsonKey(name: 'full_address') String fullAddress,@JsonKey(name: 'street_name') String? streetName,@JsonKey(name: 'house_number') String? houseNumber, String? city,@JsonKey(name: 'postal_code') String? postalCode, String? country,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class __$CustomerAddressModelCopyWithImpl<$Res>
    implements _$CustomerAddressModelCopyWith<$Res> {
  __$CustomerAddressModelCopyWithImpl(this._self, this._then);

  final _CustomerAddressModel _self;
  final $Res Function(_CustomerAddressModel) _then;

/// Create a copy of CustomerAddressModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? label = null,Object? lat = null,Object? lng = null,Object? fullAddress = null,Object? streetName = freezed,Object? houseNumber = freezed,Object? city = freezed,Object? postalCode = freezed,Object? country = freezed,Object? createdAt = freezed,}) {
  return _then(_CustomerAddressModel(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as String,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as String,fullAddress: null == fullAddress ? _self.fullAddress : fullAddress // ignore: cast_nullable_to_non_nullable
as String,streetName: freezed == streetName ? _self.streetName : streetName // ignore: cast_nullable_to_non_nullable
as String?,houseNumber: freezed == houseNumber ? _self.houseNumber : houseNumber // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,postalCode: freezed == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
