// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AddressModel {

 String get street; String get building; String? get apartment; String? get floor; String? get city; String? get postalCode; String get country; String? get placeId; double? get latitude; double? get longitude; String? get additionalInfo;
/// Create a copy of AddressModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddressModelCopyWith<AddressModel> get copyWith => _$AddressModelCopyWithImpl<AddressModel>(this as AddressModel, _$identity);

  /// Serializes this AddressModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddressModel&&(identical(other.street, street) || other.street == street)&&(identical(other.building, building) || other.building == building)&&(identical(other.apartment, apartment) || other.apartment == apartment)&&(identical(other.floor, floor) || other.floor == floor)&&(identical(other.city, city) || other.city == city)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.country, country) || other.country == country)&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.additionalInfo, additionalInfo) || other.additionalInfo == additionalInfo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,street,building,apartment,floor,city,postalCode,country,placeId,latitude,longitude,additionalInfo);

@override
String toString() {
  return 'AddressModel(street: $street, building: $building, apartment: $apartment, floor: $floor, city: $city, postalCode: $postalCode, country: $country, placeId: $placeId, latitude: $latitude, longitude: $longitude, additionalInfo: $additionalInfo)';
}


}

/// @nodoc
abstract mixin class $AddressModelCopyWith<$Res>  {
  factory $AddressModelCopyWith(AddressModel value, $Res Function(AddressModel) _then) = _$AddressModelCopyWithImpl;
@useResult
$Res call({
 String street, String building, String? apartment, String? floor, String? city, String? postalCode, String country, String? placeId, double? latitude, double? longitude, String? additionalInfo
});




}
/// @nodoc
class _$AddressModelCopyWithImpl<$Res>
    implements $AddressModelCopyWith<$Res> {
  _$AddressModelCopyWithImpl(this._self, this._then);

  final AddressModel _self;
  final $Res Function(AddressModel) _then;

/// Create a copy of AddressModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? street = null,Object? building = null,Object? apartment = freezed,Object? floor = freezed,Object? city = freezed,Object? postalCode = freezed,Object? country = null,Object? placeId = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? additionalInfo = freezed,}) {
  return _then(_self.copyWith(
street: null == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String,building: null == building ? _self.building : building // ignore: cast_nullable_to_non_nullable
as String,apartment: freezed == apartment ? _self.apartment : apartment // ignore: cast_nullable_to_non_nullable
as String?,floor: freezed == floor ? _self.floor : floor // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,postalCode: freezed == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String?,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,placeId: freezed == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,additionalInfo: freezed == additionalInfo ? _self.additionalInfo : additionalInfo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AddressModel].
extension AddressModelPatterns on AddressModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AddressModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AddressModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AddressModel value)  $default,){
final _that = this;
switch (_that) {
case _AddressModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AddressModel value)?  $default,){
final _that = this;
switch (_that) {
case _AddressModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String street,  String building,  String? apartment,  String? floor,  String? city,  String? postalCode,  String country,  String? placeId,  double? latitude,  double? longitude,  String? additionalInfo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AddressModel() when $default != null:
return $default(_that.street,_that.building,_that.apartment,_that.floor,_that.city,_that.postalCode,_that.country,_that.placeId,_that.latitude,_that.longitude,_that.additionalInfo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String street,  String building,  String? apartment,  String? floor,  String? city,  String? postalCode,  String country,  String? placeId,  double? latitude,  double? longitude,  String? additionalInfo)  $default,) {final _that = this;
switch (_that) {
case _AddressModel():
return $default(_that.street,_that.building,_that.apartment,_that.floor,_that.city,_that.postalCode,_that.country,_that.placeId,_that.latitude,_that.longitude,_that.additionalInfo);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String street,  String building,  String? apartment,  String? floor,  String? city,  String? postalCode,  String country,  String? placeId,  double? latitude,  double? longitude,  String? additionalInfo)?  $default,) {final _that = this;
switch (_that) {
case _AddressModel() when $default != null:
return $default(_that.street,_that.building,_that.apartment,_that.floor,_that.city,_that.postalCode,_that.country,_that.placeId,_that.latitude,_that.longitude,_that.additionalInfo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AddressModel extends AddressModel {
  const _AddressModel({required this.street, required this.building, this.apartment, this.floor, this.city, this.postalCode, this.country = 'Austria', this.placeId, this.latitude, this.longitude, this.additionalInfo}): super._();
  factory _AddressModel.fromJson(Map<String, dynamic> json) => _$AddressModelFromJson(json);

@override final  String street;
@override final  String building;
@override final  String? apartment;
@override final  String? floor;
@override final  String? city;
@override final  String? postalCode;
@override@JsonKey() final  String country;
@override final  String? placeId;
@override final  double? latitude;
@override final  double? longitude;
@override final  String? additionalInfo;

/// Create a copy of AddressModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddressModelCopyWith<_AddressModel> get copyWith => __$AddressModelCopyWithImpl<_AddressModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AddressModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddressModel&&(identical(other.street, street) || other.street == street)&&(identical(other.building, building) || other.building == building)&&(identical(other.apartment, apartment) || other.apartment == apartment)&&(identical(other.floor, floor) || other.floor == floor)&&(identical(other.city, city) || other.city == city)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.country, country) || other.country == country)&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.additionalInfo, additionalInfo) || other.additionalInfo == additionalInfo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,street,building,apartment,floor,city,postalCode,country,placeId,latitude,longitude,additionalInfo);

@override
String toString() {
  return 'AddressModel(street: $street, building: $building, apartment: $apartment, floor: $floor, city: $city, postalCode: $postalCode, country: $country, placeId: $placeId, latitude: $latitude, longitude: $longitude, additionalInfo: $additionalInfo)';
}


}

/// @nodoc
abstract mixin class _$AddressModelCopyWith<$Res> implements $AddressModelCopyWith<$Res> {
  factory _$AddressModelCopyWith(_AddressModel value, $Res Function(_AddressModel) _then) = __$AddressModelCopyWithImpl;
@override @useResult
$Res call({
 String street, String building, String? apartment, String? floor, String? city, String? postalCode, String country, String? placeId, double? latitude, double? longitude, String? additionalInfo
});




}
/// @nodoc
class __$AddressModelCopyWithImpl<$Res>
    implements _$AddressModelCopyWith<$Res> {
  __$AddressModelCopyWithImpl(this._self, this._then);

  final _AddressModel _self;
  final $Res Function(_AddressModel) _then;

/// Create a copy of AddressModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? street = null,Object? building = null,Object? apartment = freezed,Object? floor = freezed,Object? city = freezed,Object? postalCode = freezed,Object? country = null,Object? placeId = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? additionalInfo = freezed,}) {
  return _then(_AddressModel(
street: null == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String,building: null == building ? _self.building : building // ignore: cast_nullable_to_non_nullable
as String,apartment: freezed == apartment ? _self.apartment : apartment // ignore: cast_nullable_to_non_nullable
as String?,floor: freezed == floor ? _self.floor : floor // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,postalCode: freezed == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String?,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,placeId: freezed == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,additionalInfo: freezed == additionalInfo ? _self.additionalInfo : additionalInfo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CustomizationSelection {

 String get id; String get name; CustomizationType get type; double get priceModifier;
/// Create a copy of CustomizationSelection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomizationSelectionCopyWith<CustomizationSelection> get copyWith => _$CustomizationSelectionCopyWithImpl<CustomizationSelection>(this as CustomizationSelection, _$identity);

  /// Serializes this CustomizationSelection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomizationSelection&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.priceModifier, priceModifier) || other.priceModifier == priceModifier));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,priceModifier);

@override
String toString() {
  return 'CustomizationSelection(id: $id, name: $name, type: $type, priceModifier: $priceModifier)';
}


}

/// @nodoc
abstract mixin class $CustomizationSelectionCopyWith<$Res>  {
  factory $CustomizationSelectionCopyWith(CustomizationSelection value, $Res Function(CustomizationSelection) _then) = _$CustomizationSelectionCopyWithImpl;
@useResult
$Res call({
 String id, String name, CustomizationType type, double priceModifier
});




}
/// @nodoc
class _$CustomizationSelectionCopyWithImpl<$Res>
    implements $CustomizationSelectionCopyWith<$Res> {
  _$CustomizationSelectionCopyWithImpl(this._self, this._then);

  final CustomizationSelection _self;
  final $Res Function(CustomizationSelection) _then;

/// Create a copy of CustomizationSelection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? priceModifier = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CustomizationType,priceModifier: null == priceModifier ? _self.priceModifier : priceModifier // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [CustomizationSelection].
extension CustomizationSelectionPatterns on CustomizationSelection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomizationSelection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomizationSelection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomizationSelection value)  $default,){
final _that = this;
switch (_that) {
case _CustomizationSelection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomizationSelection value)?  $default,){
final _that = this;
switch (_that) {
case _CustomizationSelection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  CustomizationType type,  double priceModifier)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomizationSelection() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.priceModifier);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  CustomizationType type,  double priceModifier)  $default,) {final _that = this;
switch (_that) {
case _CustomizationSelection():
return $default(_that.id,_that.name,_that.type,_that.priceModifier);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  CustomizationType type,  double priceModifier)?  $default,) {final _that = this;
switch (_that) {
case _CustomizationSelection() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.priceModifier);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CustomizationSelection extends CustomizationSelection {
  const _CustomizationSelection({required this.id, required this.name, required this.type, this.priceModifier = 0.0}): super._();
  factory _CustomizationSelection.fromJson(Map<String, dynamic> json) => _$CustomizationSelectionFromJson(json);

@override final  String id;
@override final  String name;
@override final  CustomizationType type;
@override@JsonKey() final  double priceModifier;

/// Create a copy of CustomizationSelection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomizationSelectionCopyWith<_CustomizationSelection> get copyWith => __$CustomizationSelectionCopyWithImpl<_CustomizationSelection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CustomizationSelectionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomizationSelection&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.priceModifier, priceModifier) || other.priceModifier == priceModifier));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,priceModifier);

@override
String toString() {
  return 'CustomizationSelection(id: $id, name: $name, type: $type, priceModifier: $priceModifier)';
}


}

/// @nodoc
abstract mixin class _$CustomizationSelectionCopyWith<$Res> implements $CustomizationSelectionCopyWith<$Res> {
  factory _$CustomizationSelectionCopyWith(_CustomizationSelection value, $Res Function(_CustomizationSelection) _then) = __$CustomizationSelectionCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, CustomizationType type, double priceModifier
});




}
/// @nodoc
class __$CustomizationSelectionCopyWithImpl<$Res>
    implements _$CustomizationSelectionCopyWith<$Res> {
  __$CustomizationSelectionCopyWithImpl(this._self, this._then);

  final _CustomizationSelection _self;
  final $Res Function(_CustomizationSelection) _then;

/// Create a copy of CustomizationSelection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? priceModifier = null,}) {
  return _then(_CustomizationSelection(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CustomizationType,priceModifier: null == priceModifier ? _self.priceModifier : priceModifier // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
mixin _$OrderItemModel {

 String get id; String get menuItemId; String get name; int get quantity; double get unitPrice; String? get notes; List<CustomizationSelection> get customizations;
/// Create a copy of OrderItemModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderItemModelCopyWith<OrderItemModel> get copyWith => _$OrderItemModelCopyWithImpl<OrderItemModel>(this as OrderItemModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderItemModel&&(identical(other.id, id) || other.id == id)&&(identical(other.menuItemId, menuItemId) || other.menuItemId == menuItemId)&&(identical(other.name, name) || other.name == name)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other.customizations, customizations));
}


@override
int get hashCode => Object.hash(runtimeType,id,menuItemId,name,quantity,unitPrice,notes,const DeepCollectionEquality().hash(customizations));

@override
String toString() {
  return 'OrderItemModel(id: $id, menuItemId: $menuItemId, name: $name, quantity: $quantity, unitPrice: $unitPrice, notes: $notes, customizations: $customizations)';
}


}

/// @nodoc
abstract mixin class $OrderItemModelCopyWith<$Res>  {
  factory $OrderItemModelCopyWith(OrderItemModel value, $Res Function(OrderItemModel) _then) = _$OrderItemModelCopyWithImpl;
@useResult
$Res call({
 String id, String menuItemId, String name, int quantity, double unitPrice, String? notes, List<CustomizationSelection> customizations
});




}
/// @nodoc
class _$OrderItemModelCopyWithImpl<$Res>
    implements $OrderItemModelCopyWith<$Res> {
  _$OrderItemModelCopyWithImpl(this._self, this._then);

  final OrderItemModel _self;
  final $Res Function(OrderItemModel) _then;

/// Create a copy of OrderItemModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? menuItemId = null,Object? name = null,Object? quantity = null,Object? unitPrice = null,Object? notes = freezed,Object? customizations = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,menuItemId: null == menuItemId ? _self.menuItemId : menuItemId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,customizations: null == customizations ? _self.customizations : customizations // ignore: cast_nullable_to_non_nullable
as List<CustomizationSelection>,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderItemModel].
extension OrderItemModelPatterns on OrderItemModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderItemModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderItemModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderItemModel value)  $default,){
final _that = this;
switch (_that) {
case _OrderItemModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderItemModel value)?  $default,){
final _that = this;
switch (_that) {
case _OrderItemModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String menuItemId,  String name,  int quantity,  double unitPrice,  String? notes,  List<CustomizationSelection> customizations)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderItemModel() when $default != null:
return $default(_that.id,_that.menuItemId,_that.name,_that.quantity,_that.unitPrice,_that.notes,_that.customizations);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String menuItemId,  String name,  int quantity,  double unitPrice,  String? notes,  List<CustomizationSelection> customizations)  $default,) {final _that = this;
switch (_that) {
case _OrderItemModel():
return $default(_that.id,_that.menuItemId,_that.name,_that.quantity,_that.unitPrice,_that.notes,_that.customizations);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String menuItemId,  String name,  int quantity,  double unitPrice,  String? notes,  List<CustomizationSelection> customizations)?  $default,) {final _that = this;
switch (_that) {
case _OrderItemModel() when $default != null:
return $default(_that.id,_that.menuItemId,_that.name,_that.quantity,_that.unitPrice,_that.notes,_that.customizations);case _:
  return null;

}
}

}

/// @nodoc


class _OrderItemModel extends OrderItemModel {
  const _OrderItemModel({required this.id, required this.menuItemId, required this.name, required this.quantity, required this.unitPrice, this.notes, final  List<CustomizationSelection> customizations = const []}): _customizations = customizations,super._();
  

@override final  String id;
@override final  String menuItemId;
@override final  String name;
@override final  int quantity;
@override final  double unitPrice;
@override final  String? notes;
 final  List<CustomizationSelection> _customizations;
@override@JsonKey() List<CustomizationSelection> get customizations {
  if (_customizations is EqualUnmodifiableListView) return _customizations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_customizations);
}


/// Create a copy of OrderItemModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderItemModelCopyWith<_OrderItemModel> get copyWith => __$OrderItemModelCopyWithImpl<_OrderItemModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderItemModel&&(identical(other.id, id) || other.id == id)&&(identical(other.menuItemId, menuItemId) || other.menuItemId == menuItemId)&&(identical(other.name, name) || other.name == name)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other._customizations, _customizations));
}


@override
int get hashCode => Object.hash(runtimeType,id,menuItemId,name,quantity,unitPrice,notes,const DeepCollectionEquality().hash(_customizations));

@override
String toString() {
  return 'OrderItemModel(id: $id, menuItemId: $menuItemId, name: $name, quantity: $quantity, unitPrice: $unitPrice, notes: $notes, customizations: $customizations)';
}


}

/// @nodoc
abstract mixin class _$OrderItemModelCopyWith<$Res> implements $OrderItemModelCopyWith<$Res> {
  factory _$OrderItemModelCopyWith(_OrderItemModel value, $Res Function(_OrderItemModel) _then) = __$OrderItemModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String menuItemId, String name, int quantity, double unitPrice, String? notes, List<CustomizationSelection> customizations
});




}
/// @nodoc
class __$OrderItemModelCopyWithImpl<$Res>
    implements _$OrderItemModelCopyWith<$Res> {
  __$OrderItemModelCopyWithImpl(this._self, this._then);

  final _OrderItemModel _self;
  final $Res Function(_OrderItemModel) _then;

/// Create a copy of OrderItemModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? menuItemId = null,Object? name = null,Object? quantity = null,Object? unitPrice = null,Object? notes = freezed,Object? customizations = null,}) {
  return _then(_OrderItemModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,menuItemId: null == menuItemId ? _self.menuItemId : menuItemId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,customizations: null == customizations ? _self._customizations : customizations // ignore: cast_nullable_to_non_nullable
as List<CustomizationSelection>,
  ));
}


}

/// @nodoc
mixin _$OrderModel {

 String get id; String get customerName; String get phoneNumber; String get countryCode; AddressModel get address; List<OrderItemModel> get items; double get subtotal; double get deliveryFee; double get discountAmount; double get tips; double get total; bool get isPaid; OrderStatusEnum get status; String? get notes; String? get rejectionReason; DateTime get createdAt; DateTime? get acceptedAt; DateTime? get readyAt; DateTime? get outForDeliveryAt; DateTime? get deliveredAt; String? get restaurantId; String? get assignedDriverId;// New fields from API
 String get orderType; OrderRestaurantModel? get restaurant; OrderCouponModel? get coupon; OrderAddressModel? get pickupAddress; OrderAddressModel? get dropoffAddress; String? get requestedVehicleType; String? get requestedDeliveryType; OrderDriverModel? get driver; bool get isManual;
/// Create a copy of OrderModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderModelCopyWith<OrderModel> get copyWith => _$OrderModelCopyWithImpl<OrderModel>(this as OrderModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderModel&&(identical(other.id, id) || other.id == id)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.address, address) || other.address == address)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.deliveryFee, deliveryFee) || other.deliveryFee == deliveryFee)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount)&&(identical(other.tips, tips) || other.tips == tips)&&(identical(other.total, total) || other.total == total)&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid)&&(identical(other.status, status) || other.status == status)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.acceptedAt, acceptedAt) || other.acceptedAt == acceptedAt)&&(identical(other.readyAt, readyAt) || other.readyAt == readyAt)&&(identical(other.outForDeliveryAt, outForDeliveryAt) || other.outForDeliveryAt == outForDeliveryAt)&&(identical(other.deliveredAt, deliveredAt) || other.deliveredAt == deliveredAt)&&(identical(other.restaurantId, restaurantId) || other.restaurantId == restaurantId)&&(identical(other.assignedDriverId, assignedDriverId) || other.assignedDriverId == assignedDriverId)&&(identical(other.orderType, orderType) || other.orderType == orderType)&&(identical(other.restaurant, restaurant) || other.restaurant == restaurant)&&(identical(other.coupon, coupon) || other.coupon == coupon)&&(identical(other.pickupAddress, pickupAddress) || other.pickupAddress == pickupAddress)&&(identical(other.dropoffAddress, dropoffAddress) || other.dropoffAddress == dropoffAddress)&&(identical(other.requestedVehicleType, requestedVehicleType) || other.requestedVehicleType == requestedVehicleType)&&(identical(other.requestedDeliveryType, requestedDeliveryType) || other.requestedDeliveryType == requestedDeliveryType)&&(identical(other.driver, driver) || other.driver == driver)&&(identical(other.isManual, isManual) || other.isManual == isManual));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,customerName,phoneNumber,countryCode,address,const DeepCollectionEquality().hash(items),subtotal,deliveryFee,discountAmount,tips,total,isPaid,status,notes,rejectionReason,createdAt,acceptedAt,readyAt,outForDeliveryAt,deliveredAt,restaurantId,assignedDriverId,orderType,restaurant,coupon,pickupAddress,dropoffAddress,requestedVehicleType,requestedDeliveryType,driver,isManual]);

@override
String toString() {
  return 'OrderModel(id: $id, customerName: $customerName, phoneNumber: $phoneNumber, countryCode: $countryCode, address: $address, items: $items, subtotal: $subtotal, deliveryFee: $deliveryFee, discountAmount: $discountAmount, tips: $tips, total: $total, isPaid: $isPaid, status: $status, notes: $notes, rejectionReason: $rejectionReason, createdAt: $createdAt, acceptedAt: $acceptedAt, readyAt: $readyAt, outForDeliveryAt: $outForDeliveryAt, deliveredAt: $deliveredAt, restaurantId: $restaurantId, assignedDriverId: $assignedDriverId, orderType: $orderType, restaurant: $restaurant, coupon: $coupon, pickupAddress: $pickupAddress, dropoffAddress: $dropoffAddress, requestedVehicleType: $requestedVehicleType, requestedDeliveryType: $requestedDeliveryType, driver: $driver, isManual: $isManual)';
}


}

/// @nodoc
abstract mixin class $OrderModelCopyWith<$Res>  {
  factory $OrderModelCopyWith(OrderModel value, $Res Function(OrderModel) _then) = _$OrderModelCopyWithImpl;
@useResult
$Res call({
 String id, String customerName, String phoneNumber, String countryCode, AddressModel address, List<OrderItemModel> items, double subtotal, double deliveryFee, double discountAmount, double tips, double total, bool isPaid, OrderStatusEnum status, String? notes, String? rejectionReason, DateTime createdAt, DateTime? acceptedAt, DateTime? readyAt, DateTime? outForDeliveryAt, DateTime? deliveredAt, String? restaurantId, String? assignedDriverId, String orderType, OrderRestaurantModel? restaurant, OrderCouponModel? coupon, OrderAddressModel? pickupAddress, OrderAddressModel? dropoffAddress, String? requestedVehicleType, String? requestedDeliveryType, OrderDriverModel? driver, bool isManual
});


$AddressModelCopyWith<$Res> get address;

}
/// @nodoc
class _$OrderModelCopyWithImpl<$Res>
    implements $OrderModelCopyWith<$Res> {
  _$OrderModelCopyWithImpl(this._self, this._then);

  final OrderModel _self;
  final $Res Function(OrderModel) _then;

/// Create a copy of OrderModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? customerName = null,Object? phoneNumber = null,Object? countryCode = null,Object? address = null,Object? items = null,Object? subtotal = null,Object? deliveryFee = null,Object? discountAmount = null,Object? tips = null,Object? total = null,Object? isPaid = null,Object? status = null,Object? notes = freezed,Object? rejectionReason = freezed,Object? createdAt = null,Object? acceptedAt = freezed,Object? readyAt = freezed,Object? outForDeliveryAt = freezed,Object? deliveredAt = freezed,Object? restaurantId = freezed,Object? assignedDriverId = freezed,Object? orderType = null,Object? restaurant = freezed,Object? coupon = freezed,Object? pickupAddress = freezed,Object? dropoffAddress = freezed,Object? requestedVehicleType = freezed,Object? requestedDeliveryType = freezed,Object? driver = freezed,Object? isManual = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,countryCode: null == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as AddressModel,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItemModel>,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,deliveryFee: null == deliveryFee ? _self.deliveryFee : deliveryFee // ignore: cast_nullable_to_non_nullable
as double,discountAmount: null == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as double,tips: null == tips ? _self.tips : tips // ignore: cast_nullable_to_non_nullable
as double,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,isPaid: null == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatusEnum,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,acceptedAt: freezed == acceptedAt ? _self.acceptedAt : acceptedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,readyAt: freezed == readyAt ? _self.readyAt : readyAt // ignore: cast_nullable_to_non_nullable
as DateTime?,outForDeliveryAt: freezed == outForDeliveryAt ? _self.outForDeliveryAt : outForDeliveryAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deliveredAt: freezed == deliveredAt ? _self.deliveredAt : deliveredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,restaurantId: freezed == restaurantId ? _self.restaurantId : restaurantId // ignore: cast_nullable_to_non_nullable
as String?,assignedDriverId: freezed == assignedDriverId ? _self.assignedDriverId : assignedDriverId // ignore: cast_nullable_to_non_nullable
as String?,orderType: null == orderType ? _self.orderType : orderType // ignore: cast_nullable_to_non_nullable
as String,restaurant: freezed == restaurant ? _self.restaurant : restaurant // ignore: cast_nullable_to_non_nullable
as OrderRestaurantModel?,coupon: freezed == coupon ? _self.coupon : coupon // ignore: cast_nullable_to_non_nullable
as OrderCouponModel?,pickupAddress: freezed == pickupAddress ? _self.pickupAddress : pickupAddress // ignore: cast_nullable_to_non_nullable
as OrderAddressModel?,dropoffAddress: freezed == dropoffAddress ? _self.dropoffAddress : dropoffAddress // ignore: cast_nullable_to_non_nullable
as OrderAddressModel?,requestedVehicleType: freezed == requestedVehicleType ? _self.requestedVehicleType : requestedVehicleType // ignore: cast_nullable_to_non_nullable
as String?,requestedDeliveryType: freezed == requestedDeliveryType ? _self.requestedDeliveryType : requestedDeliveryType // ignore: cast_nullable_to_non_nullable
as String?,driver: freezed == driver ? _self.driver : driver // ignore: cast_nullable_to_non_nullable
as OrderDriverModel?,isManual: null == isManual ? _self.isManual : isManual // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of OrderModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AddressModelCopyWith<$Res> get address {
  
  return $AddressModelCopyWith<$Res>(_self.address, (value) {
    return _then(_self.copyWith(address: value));
  });
}
}


/// Adds pattern-matching-related methods to [OrderModel].
extension OrderModelPatterns on OrderModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderModel value)  $default,){
final _that = this;
switch (_that) {
case _OrderModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderModel value)?  $default,){
final _that = this;
switch (_that) {
case _OrderModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String customerName,  String phoneNumber,  String countryCode,  AddressModel address,  List<OrderItemModel> items,  double subtotal,  double deliveryFee,  double discountAmount,  double tips,  double total,  bool isPaid,  OrderStatusEnum status,  String? notes,  String? rejectionReason,  DateTime createdAt,  DateTime? acceptedAt,  DateTime? readyAt,  DateTime? outForDeliveryAt,  DateTime? deliveredAt,  String? restaurantId,  String? assignedDriverId,  String orderType,  OrderRestaurantModel? restaurant,  OrderCouponModel? coupon,  OrderAddressModel? pickupAddress,  OrderAddressModel? dropoffAddress,  String? requestedVehicleType,  String? requestedDeliveryType,  OrderDriverModel? driver,  bool isManual)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderModel() when $default != null:
return $default(_that.id,_that.customerName,_that.phoneNumber,_that.countryCode,_that.address,_that.items,_that.subtotal,_that.deliveryFee,_that.discountAmount,_that.tips,_that.total,_that.isPaid,_that.status,_that.notes,_that.rejectionReason,_that.createdAt,_that.acceptedAt,_that.readyAt,_that.outForDeliveryAt,_that.deliveredAt,_that.restaurantId,_that.assignedDriverId,_that.orderType,_that.restaurant,_that.coupon,_that.pickupAddress,_that.dropoffAddress,_that.requestedVehicleType,_that.requestedDeliveryType,_that.driver,_that.isManual);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String customerName,  String phoneNumber,  String countryCode,  AddressModel address,  List<OrderItemModel> items,  double subtotal,  double deliveryFee,  double discountAmount,  double tips,  double total,  bool isPaid,  OrderStatusEnum status,  String? notes,  String? rejectionReason,  DateTime createdAt,  DateTime? acceptedAt,  DateTime? readyAt,  DateTime? outForDeliveryAt,  DateTime? deliveredAt,  String? restaurantId,  String? assignedDriverId,  String orderType,  OrderRestaurantModel? restaurant,  OrderCouponModel? coupon,  OrderAddressModel? pickupAddress,  OrderAddressModel? dropoffAddress,  String? requestedVehicleType,  String? requestedDeliveryType,  OrderDriverModel? driver,  bool isManual)  $default,) {final _that = this;
switch (_that) {
case _OrderModel():
return $default(_that.id,_that.customerName,_that.phoneNumber,_that.countryCode,_that.address,_that.items,_that.subtotal,_that.deliveryFee,_that.discountAmount,_that.tips,_that.total,_that.isPaid,_that.status,_that.notes,_that.rejectionReason,_that.createdAt,_that.acceptedAt,_that.readyAt,_that.outForDeliveryAt,_that.deliveredAt,_that.restaurantId,_that.assignedDriverId,_that.orderType,_that.restaurant,_that.coupon,_that.pickupAddress,_that.dropoffAddress,_that.requestedVehicleType,_that.requestedDeliveryType,_that.driver,_that.isManual);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String customerName,  String phoneNumber,  String countryCode,  AddressModel address,  List<OrderItemModel> items,  double subtotal,  double deliveryFee,  double discountAmount,  double tips,  double total,  bool isPaid,  OrderStatusEnum status,  String? notes,  String? rejectionReason,  DateTime createdAt,  DateTime? acceptedAt,  DateTime? readyAt,  DateTime? outForDeliveryAt,  DateTime? deliveredAt,  String? restaurantId,  String? assignedDriverId,  String orderType,  OrderRestaurantModel? restaurant,  OrderCouponModel? coupon,  OrderAddressModel? pickupAddress,  OrderAddressModel? dropoffAddress,  String? requestedVehicleType,  String? requestedDeliveryType,  OrderDriverModel? driver,  bool isManual)?  $default,) {final _that = this;
switch (_that) {
case _OrderModel() when $default != null:
return $default(_that.id,_that.customerName,_that.phoneNumber,_that.countryCode,_that.address,_that.items,_that.subtotal,_that.deliveryFee,_that.discountAmount,_that.tips,_that.total,_that.isPaid,_that.status,_that.notes,_that.rejectionReason,_that.createdAt,_that.acceptedAt,_that.readyAt,_that.outForDeliveryAt,_that.deliveredAt,_that.restaurantId,_that.assignedDriverId,_that.orderType,_that.restaurant,_that.coupon,_that.pickupAddress,_that.dropoffAddress,_that.requestedVehicleType,_that.requestedDeliveryType,_that.driver,_that.isManual);case _:
  return null;

}
}

}

/// @nodoc


class _OrderModel implements OrderModel {
  const _OrderModel({required this.id, required this.customerName, required this.phoneNumber, required this.countryCode, required this.address, required final  List<OrderItemModel> items, this.subtotal = 0.0, this.deliveryFee = 0.0, this.discountAmount = 0.0, this.tips = 0.0, this.total = 0.0, this.isPaid = false, this.status = OrderStatusEnum.pending, this.notes, this.rejectionReason, required this.createdAt, this.acceptedAt, this.readyAt, this.outForDeliveryAt, this.deliveredAt, this.restaurantId, this.assignedDriverId, this.orderType = 'FOOD', this.restaurant, this.coupon, this.pickupAddress, this.dropoffAddress, this.requestedVehicleType, this.requestedDeliveryType, this.driver, this.isManual = false}): _items = items;
  

@override final  String id;
@override final  String customerName;
@override final  String phoneNumber;
@override final  String countryCode;
@override final  AddressModel address;
 final  List<OrderItemModel> _items;
@override List<OrderItemModel> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  double subtotal;
@override@JsonKey() final  double deliveryFee;
@override@JsonKey() final  double discountAmount;
@override@JsonKey() final  double tips;
@override@JsonKey() final  double total;
@override@JsonKey() final  bool isPaid;
@override@JsonKey() final  OrderStatusEnum status;
@override final  String? notes;
@override final  String? rejectionReason;
@override final  DateTime createdAt;
@override final  DateTime? acceptedAt;
@override final  DateTime? readyAt;
@override final  DateTime? outForDeliveryAt;
@override final  DateTime? deliveredAt;
@override final  String? restaurantId;
@override final  String? assignedDriverId;
// New fields from API
@override@JsonKey() final  String orderType;
@override final  OrderRestaurantModel? restaurant;
@override final  OrderCouponModel? coupon;
@override final  OrderAddressModel? pickupAddress;
@override final  OrderAddressModel? dropoffAddress;
@override final  String? requestedVehicleType;
@override final  String? requestedDeliveryType;
@override final  OrderDriverModel? driver;
@override@JsonKey() final  bool isManual;

/// Create a copy of OrderModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderModelCopyWith<_OrderModel> get copyWith => __$OrderModelCopyWithImpl<_OrderModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderModel&&(identical(other.id, id) || other.id == id)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.address, address) || other.address == address)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.deliveryFee, deliveryFee) || other.deliveryFee == deliveryFee)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount)&&(identical(other.tips, tips) || other.tips == tips)&&(identical(other.total, total) || other.total == total)&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid)&&(identical(other.status, status) || other.status == status)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.acceptedAt, acceptedAt) || other.acceptedAt == acceptedAt)&&(identical(other.readyAt, readyAt) || other.readyAt == readyAt)&&(identical(other.outForDeliveryAt, outForDeliveryAt) || other.outForDeliveryAt == outForDeliveryAt)&&(identical(other.deliveredAt, deliveredAt) || other.deliveredAt == deliveredAt)&&(identical(other.restaurantId, restaurantId) || other.restaurantId == restaurantId)&&(identical(other.assignedDriverId, assignedDriverId) || other.assignedDriverId == assignedDriverId)&&(identical(other.orderType, orderType) || other.orderType == orderType)&&(identical(other.restaurant, restaurant) || other.restaurant == restaurant)&&(identical(other.coupon, coupon) || other.coupon == coupon)&&(identical(other.pickupAddress, pickupAddress) || other.pickupAddress == pickupAddress)&&(identical(other.dropoffAddress, dropoffAddress) || other.dropoffAddress == dropoffAddress)&&(identical(other.requestedVehicleType, requestedVehicleType) || other.requestedVehicleType == requestedVehicleType)&&(identical(other.requestedDeliveryType, requestedDeliveryType) || other.requestedDeliveryType == requestedDeliveryType)&&(identical(other.driver, driver) || other.driver == driver)&&(identical(other.isManual, isManual) || other.isManual == isManual));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,customerName,phoneNumber,countryCode,address,const DeepCollectionEquality().hash(_items),subtotal,deliveryFee,discountAmount,tips,total,isPaid,status,notes,rejectionReason,createdAt,acceptedAt,readyAt,outForDeliveryAt,deliveredAt,restaurantId,assignedDriverId,orderType,restaurant,coupon,pickupAddress,dropoffAddress,requestedVehicleType,requestedDeliveryType,driver,isManual]);

@override
String toString() {
  return 'OrderModel(id: $id, customerName: $customerName, phoneNumber: $phoneNumber, countryCode: $countryCode, address: $address, items: $items, subtotal: $subtotal, deliveryFee: $deliveryFee, discountAmount: $discountAmount, tips: $tips, total: $total, isPaid: $isPaid, status: $status, notes: $notes, rejectionReason: $rejectionReason, createdAt: $createdAt, acceptedAt: $acceptedAt, readyAt: $readyAt, outForDeliveryAt: $outForDeliveryAt, deliveredAt: $deliveredAt, restaurantId: $restaurantId, assignedDriverId: $assignedDriverId, orderType: $orderType, restaurant: $restaurant, coupon: $coupon, pickupAddress: $pickupAddress, dropoffAddress: $dropoffAddress, requestedVehicleType: $requestedVehicleType, requestedDeliveryType: $requestedDeliveryType, driver: $driver, isManual: $isManual)';
}


}

/// @nodoc
abstract mixin class _$OrderModelCopyWith<$Res> implements $OrderModelCopyWith<$Res> {
  factory _$OrderModelCopyWith(_OrderModel value, $Res Function(_OrderModel) _then) = __$OrderModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String customerName, String phoneNumber, String countryCode, AddressModel address, List<OrderItemModel> items, double subtotal, double deliveryFee, double discountAmount, double tips, double total, bool isPaid, OrderStatusEnum status, String? notes, String? rejectionReason, DateTime createdAt, DateTime? acceptedAt, DateTime? readyAt, DateTime? outForDeliveryAt, DateTime? deliveredAt, String? restaurantId, String? assignedDriverId, String orderType, OrderRestaurantModel? restaurant, OrderCouponModel? coupon, OrderAddressModel? pickupAddress, OrderAddressModel? dropoffAddress, String? requestedVehicleType, String? requestedDeliveryType, OrderDriverModel? driver, bool isManual
});


@override $AddressModelCopyWith<$Res> get address;

}
/// @nodoc
class __$OrderModelCopyWithImpl<$Res>
    implements _$OrderModelCopyWith<$Res> {
  __$OrderModelCopyWithImpl(this._self, this._then);

  final _OrderModel _self;
  final $Res Function(_OrderModel) _then;

/// Create a copy of OrderModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? customerName = null,Object? phoneNumber = null,Object? countryCode = null,Object? address = null,Object? items = null,Object? subtotal = null,Object? deliveryFee = null,Object? discountAmount = null,Object? tips = null,Object? total = null,Object? isPaid = null,Object? status = null,Object? notes = freezed,Object? rejectionReason = freezed,Object? createdAt = null,Object? acceptedAt = freezed,Object? readyAt = freezed,Object? outForDeliveryAt = freezed,Object? deliveredAt = freezed,Object? restaurantId = freezed,Object? assignedDriverId = freezed,Object? orderType = null,Object? restaurant = freezed,Object? coupon = freezed,Object? pickupAddress = freezed,Object? dropoffAddress = freezed,Object? requestedVehicleType = freezed,Object? requestedDeliveryType = freezed,Object? driver = freezed,Object? isManual = null,}) {
  return _then(_OrderModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,countryCode: null == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as AddressModel,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItemModel>,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,deliveryFee: null == deliveryFee ? _self.deliveryFee : deliveryFee // ignore: cast_nullable_to_non_nullable
as double,discountAmount: null == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as double,tips: null == tips ? _self.tips : tips // ignore: cast_nullable_to_non_nullable
as double,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,isPaid: null == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatusEnum,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,acceptedAt: freezed == acceptedAt ? _self.acceptedAt : acceptedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,readyAt: freezed == readyAt ? _self.readyAt : readyAt // ignore: cast_nullable_to_non_nullable
as DateTime?,outForDeliveryAt: freezed == outForDeliveryAt ? _self.outForDeliveryAt : outForDeliveryAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deliveredAt: freezed == deliveredAt ? _self.deliveredAt : deliveredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,restaurantId: freezed == restaurantId ? _self.restaurantId : restaurantId // ignore: cast_nullable_to_non_nullable
as String?,assignedDriverId: freezed == assignedDriverId ? _self.assignedDriverId : assignedDriverId // ignore: cast_nullable_to_non_nullable
as String?,orderType: null == orderType ? _self.orderType : orderType // ignore: cast_nullable_to_non_nullable
as String,restaurant: freezed == restaurant ? _self.restaurant : restaurant // ignore: cast_nullable_to_non_nullable
as OrderRestaurantModel?,coupon: freezed == coupon ? _self.coupon : coupon // ignore: cast_nullable_to_non_nullable
as OrderCouponModel?,pickupAddress: freezed == pickupAddress ? _self.pickupAddress : pickupAddress // ignore: cast_nullable_to_non_nullable
as OrderAddressModel?,dropoffAddress: freezed == dropoffAddress ? _self.dropoffAddress : dropoffAddress // ignore: cast_nullable_to_non_nullable
as OrderAddressModel?,requestedVehicleType: freezed == requestedVehicleType ? _self.requestedVehicleType : requestedVehicleType // ignore: cast_nullable_to_non_nullable
as String?,requestedDeliveryType: freezed == requestedDeliveryType ? _self.requestedDeliveryType : requestedDeliveryType // ignore: cast_nullable_to_non_nullable
as String?,driver: freezed == driver ? _self.driver : driver // ignore: cast_nullable_to_non_nullable
as OrderDriverModel?,isManual: null == isManual ? _self.isManual : isManual // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of OrderModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AddressModelCopyWith<$Res> get address {
  
  return $AddressModelCopyWith<$Res>(_self.address, (value) {
    return _then(_self.copyWith(address: value));
  });
}
}

// dart format on
