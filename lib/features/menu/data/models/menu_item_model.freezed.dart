// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'menu_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CustomizationOption {

 String get id; String get name; CustomizationType get type; double get priceModifier; bool get isAvailable;
/// Create a copy of CustomizationOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomizationOptionCopyWith<CustomizationOption> get copyWith => _$CustomizationOptionCopyWithImpl<CustomizationOption>(this as CustomizationOption, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomizationOption&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.priceModifier, priceModifier) || other.priceModifier == priceModifier)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,type,priceModifier,isAvailable);

@override
String toString() {
  return 'CustomizationOption(id: $id, name: $name, type: $type, priceModifier: $priceModifier, isAvailable: $isAvailable)';
}


}

/// @nodoc
abstract mixin class $CustomizationOptionCopyWith<$Res>  {
  factory $CustomizationOptionCopyWith(CustomizationOption value, $Res Function(CustomizationOption) _then) = _$CustomizationOptionCopyWithImpl;
@useResult
$Res call({
 String id, String name, CustomizationType type, double priceModifier, bool isAvailable
});




}
/// @nodoc
class _$CustomizationOptionCopyWithImpl<$Res>
    implements $CustomizationOptionCopyWith<$Res> {
  _$CustomizationOptionCopyWithImpl(this._self, this._then);

  final CustomizationOption _self;
  final $Res Function(CustomizationOption) _then;

/// Create a copy of CustomizationOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? priceModifier = null,Object? isAvailable = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CustomizationType,priceModifier: null == priceModifier ? _self.priceModifier : priceModifier // ignore: cast_nullable_to_non_nullable
as double,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CustomizationOption].
extension CustomizationOptionPatterns on CustomizationOption {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomizationOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomizationOption() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomizationOption value)  $default,){
final _that = this;
switch (_that) {
case _CustomizationOption():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomizationOption value)?  $default,){
final _that = this;
switch (_that) {
case _CustomizationOption() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  CustomizationType type,  double priceModifier,  bool isAvailable)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomizationOption() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.priceModifier,_that.isAvailable);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  CustomizationType type,  double priceModifier,  bool isAvailable)  $default,) {final _that = this;
switch (_that) {
case _CustomizationOption():
return $default(_that.id,_that.name,_that.type,_that.priceModifier,_that.isAvailable);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  CustomizationType type,  double priceModifier,  bool isAvailable)?  $default,) {final _that = this;
switch (_that) {
case _CustomizationOption() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.priceModifier,_that.isAvailable);case _:
  return null;

}
}

}

/// @nodoc


class _CustomizationOption implements CustomizationOption {
  const _CustomizationOption({required this.id, required this.name, required this.type, this.priceModifier = 0.0, this.isAvailable = true});
  

@override final  String id;
@override final  String name;
@override final  CustomizationType type;
@override@JsonKey() final  double priceModifier;
@override@JsonKey() final  bool isAvailable;

/// Create a copy of CustomizationOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomizationOptionCopyWith<_CustomizationOption> get copyWith => __$CustomizationOptionCopyWithImpl<_CustomizationOption>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomizationOption&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.priceModifier, priceModifier) || other.priceModifier == priceModifier)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,type,priceModifier,isAvailable);

@override
String toString() {
  return 'CustomizationOption(id: $id, name: $name, type: $type, priceModifier: $priceModifier, isAvailable: $isAvailable)';
}


}

/// @nodoc
abstract mixin class _$CustomizationOptionCopyWith<$Res> implements $CustomizationOptionCopyWith<$Res> {
  factory _$CustomizationOptionCopyWith(_CustomizationOption value, $Res Function(_CustomizationOption) _then) = __$CustomizationOptionCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, CustomizationType type, double priceModifier, bool isAvailable
});




}
/// @nodoc
class __$CustomizationOptionCopyWithImpl<$Res>
    implements _$CustomizationOptionCopyWith<$Res> {
  __$CustomizationOptionCopyWithImpl(this._self, this._then);

  final _CustomizationOption _self;
  final $Res Function(_CustomizationOption) _then;

/// Create a copy of CustomizationOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? priceModifier = null,Object? isAvailable = null,}) {
  return _then(_CustomizationOption(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CustomizationType,priceModifier: null == priceModifier ? _self.priceModifier : priceModifier // ignore: cast_nullable_to_non_nullable
as double,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$CategoryModel {

 String get id; String get name; String? get nameAr; String? get nameDe; String? get nameFr; String? get imageUrl; int get sortOrder; bool get isActive;
/// Create a copy of CategoryModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryModelCopyWith<CategoryModel> get copyWith => _$CategoryModelCopyWithImpl<CategoryModel>(this as CategoryModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr)&&(identical(other.nameDe, nameDe) || other.nameDe == nameDe)&&(identical(other.nameFr, nameFr) || other.nameFr == nameFr)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,nameAr,nameDe,nameFr,imageUrl,sortOrder,isActive);

@override
String toString() {
  return 'CategoryModel(id: $id, name: $name, nameAr: $nameAr, nameDe: $nameDe, nameFr: $nameFr, imageUrl: $imageUrl, sortOrder: $sortOrder, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class $CategoryModelCopyWith<$Res>  {
  factory $CategoryModelCopyWith(CategoryModel value, $Res Function(CategoryModel) _then) = _$CategoryModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? nameAr, String? nameDe, String? nameFr, String? imageUrl, int sortOrder, bool isActive
});




}
/// @nodoc
class _$CategoryModelCopyWithImpl<$Res>
    implements $CategoryModelCopyWith<$Res> {
  _$CategoryModelCopyWithImpl(this._self, this._then);

  final CategoryModel _self;
  final $Res Function(CategoryModel) _then;

/// Create a copy of CategoryModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? nameAr = freezed,Object? nameDe = freezed,Object? nameFr = freezed,Object? imageUrl = freezed,Object? sortOrder = null,Object? isActive = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nameAr: freezed == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String?,nameDe: freezed == nameDe ? _self.nameDe : nameDe // ignore: cast_nullable_to_non_nullable
as String?,nameFr: freezed == nameFr ? _self.nameFr : nameFr // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CategoryModel].
extension CategoryModelPatterns on CategoryModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategoryModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategoryModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategoryModel value)  $default,){
final _that = this;
switch (_that) {
case _CategoryModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategoryModel value)?  $default,){
final _that = this;
switch (_that) {
case _CategoryModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? nameAr,  String? nameDe,  String? nameFr,  String? imageUrl,  int sortOrder,  bool isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategoryModel() when $default != null:
return $default(_that.id,_that.name,_that.nameAr,_that.nameDe,_that.nameFr,_that.imageUrl,_that.sortOrder,_that.isActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? nameAr,  String? nameDe,  String? nameFr,  String? imageUrl,  int sortOrder,  bool isActive)  $default,) {final _that = this;
switch (_that) {
case _CategoryModel():
return $default(_that.id,_that.name,_that.nameAr,_that.nameDe,_that.nameFr,_that.imageUrl,_that.sortOrder,_that.isActive);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? nameAr,  String? nameDe,  String? nameFr,  String? imageUrl,  int sortOrder,  bool isActive)?  $default,) {final _that = this;
switch (_that) {
case _CategoryModel() when $default != null:
return $default(_that.id,_that.name,_that.nameAr,_that.nameDe,_that.nameFr,_that.imageUrl,_that.sortOrder,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc


class _CategoryModel implements CategoryModel {
  const _CategoryModel({required this.id, required this.name, this.nameAr, this.nameDe, this.nameFr, this.imageUrl, this.sortOrder = 0, this.isActive = true});
  

@override final  String id;
@override final  String name;
@override final  String? nameAr;
@override final  String? nameDe;
@override final  String? nameFr;
@override final  String? imageUrl;
@override@JsonKey() final  int sortOrder;
@override@JsonKey() final  bool isActive;

/// Create a copy of CategoryModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryModelCopyWith<_CategoryModel> get copyWith => __$CategoryModelCopyWithImpl<_CategoryModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr)&&(identical(other.nameDe, nameDe) || other.nameDe == nameDe)&&(identical(other.nameFr, nameFr) || other.nameFr == nameFr)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,nameAr,nameDe,nameFr,imageUrl,sortOrder,isActive);

@override
String toString() {
  return 'CategoryModel(id: $id, name: $name, nameAr: $nameAr, nameDe: $nameDe, nameFr: $nameFr, imageUrl: $imageUrl, sortOrder: $sortOrder, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$CategoryModelCopyWith<$Res> implements $CategoryModelCopyWith<$Res> {
  factory _$CategoryModelCopyWith(_CategoryModel value, $Res Function(_CategoryModel) _then) = __$CategoryModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? nameAr, String? nameDe, String? nameFr, String? imageUrl, int sortOrder, bool isActive
});




}
/// @nodoc
class __$CategoryModelCopyWithImpl<$Res>
    implements _$CategoryModelCopyWith<$Res> {
  __$CategoryModelCopyWithImpl(this._self, this._then);

  final _CategoryModel _self;
  final $Res Function(_CategoryModel) _then;

/// Create a copy of CategoryModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? nameAr = freezed,Object? nameDe = freezed,Object? nameFr = freezed,Object? imageUrl = freezed,Object? sortOrder = null,Object? isActive = null,}) {
  return _then(_CategoryModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nameAr: freezed == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String?,nameDe: freezed == nameDe ? _self.nameDe : nameDe // ignore: cast_nullable_to_non_nullable
as String?,nameFr: freezed == nameFr ? _self.nameFr : nameFr // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$MenuItemModel {

 String get id; String get name; double get price; String? get imageUrl; String? get description; String get categoryId; List<String> get ingredients; List<CustomizationOption> get customizations; bool get isAvailable; int get preparationTime; String? get nameAr; String? get nameDe; String? get nameFr; String? get descriptionAr; String? get descriptionDe; String? get descriptionFr; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of MenuItemModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MenuItemModelCopyWith<MenuItemModel> get copyWith => _$MenuItemModelCopyWithImpl<MenuItemModel>(this as MenuItemModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MenuItemModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&const DeepCollectionEquality().equals(other.ingredients, ingredients)&&const DeepCollectionEquality().equals(other.customizations, customizations)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable)&&(identical(other.preparationTime, preparationTime) || other.preparationTime == preparationTime)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr)&&(identical(other.nameDe, nameDe) || other.nameDe == nameDe)&&(identical(other.nameFr, nameFr) || other.nameFr == nameFr)&&(identical(other.descriptionAr, descriptionAr) || other.descriptionAr == descriptionAr)&&(identical(other.descriptionDe, descriptionDe) || other.descriptionDe == descriptionDe)&&(identical(other.descriptionFr, descriptionFr) || other.descriptionFr == descriptionFr)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,price,imageUrl,description,categoryId,const DeepCollectionEquality().hash(ingredients),const DeepCollectionEquality().hash(customizations),isAvailable,preparationTime,nameAr,nameDe,nameFr,descriptionAr,descriptionDe,descriptionFr,createdAt,updatedAt);

@override
String toString() {
  return 'MenuItemModel(id: $id, name: $name, price: $price, imageUrl: $imageUrl, description: $description, categoryId: $categoryId, ingredients: $ingredients, customizations: $customizations, isAvailable: $isAvailable, preparationTime: $preparationTime, nameAr: $nameAr, nameDe: $nameDe, nameFr: $nameFr, descriptionAr: $descriptionAr, descriptionDe: $descriptionDe, descriptionFr: $descriptionFr, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $MenuItemModelCopyWith<$Res>  {
  factory $MenuItemModelCopyWith(MenuItemModel value, $Res Function(MenuItemModel) _then) = _$MenuItemModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, double price, String? imageUrl, String? description, String categoryId, List<String> ingredients, List<CustomizationOption> customizations, bool isAvailable, int preparationTime, String? nameAr, String? nameDe, String? nameFr, String? descriptionAr, String? descriptionDe, String? descriptionFr, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$MenuItemModelCopyWithImpl<$Res>
    implements $MenuItemModelCopyWith<$Res> {
  _$MenuItemModelCopyWithImpl(this._self, this._then);

  final MenuItemModel _self;
  final $Res Function(MenuItemModel) _then;

/// Create a copy of MenuItemModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? price = null,Object? imageUrl = freezed,Object? description = freezed,Object? categoryId = null,Object? ingredients = null,Object? customizations = null,Object? isAvailable = null,Object? preparationTime = null,Object? nameAr = freezed,Object? nameDe = freezed,Object? nameFr = freezed,Object? descriptionAr = freezed,Object? descriptionDe = freezed,Object? descriptionFr = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,ingredients: null == ingredients ? _self.ingredients : ingredients // ignore: cast_nullable_to_non_nullable
as List<String>,customizations: null == customizations ? _self.customizations : customizations // ignore: cast_nullable_to_non_nullable
as List<CustomizationOption>,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,preparationTime: null == preparationTime ? _self.preparationTime : preparationTime // ignore: cast_nullable_to_non_nullable
as int,nameAr: freezed == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String?,nameDe: freezed == nameDe ? _self.nameDe : nameDe // ignore: cast_nullable_to_non_nullable
as String?,nameFr: freezed == nameFr ? _self.nameFr : nameFr // ignore: cast_nullable_to_non_nullable
as String?,descriptionAr: freezed == descriptionAr ? _self.descriptionAr : descriptionAr // ignore: cast_nullable_to_non_nullable
as String?,descriptionDe: freezed == descriptionDe ? _self.descriptionDe : descriptionDe // ignore: cast_nullable_to_non_nullable
as String?,descriptionFr: freezed == descriptionFr ? _self.descriptionFr : descriptionFr // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [MenuItemModel].
extension MenuItemModelPatterns on MenuItemModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MenuItemModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MenuItemModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MenuItemModel value)  $default,){
final _that = this;
switch (_that) {
case _MenuItemModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MenuItemModel value)?  $default,){
final _that = this;
switch (_that) {
case _MenuItemModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  double price,  String? imageUrl,  String? description,  String categoryId,  List<String> ingredients,  List<CustomizationOption> customizations,  bool isAvailable,  int preparationTime,  String? nameAr,  String? nameDe,  String? nameFr,  String? descriptionAr,  String? descriptionDe,  String? descriptionFr,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MenuItemModel() when $default != null:
return $default(_that.id,_that.name,_that.price,_that.imageUrl,_that.description,_that.categoryId,_that.ingredients,_that.customizations,_that.isAvailable,_that.preparationTime,_that.nameAr,_that.nameDe,_that.nameFr,_that.descriptionAr,_that.descriptionDe,_that.descriptionFr,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  double price,  String? imageUrl,  String? description,  String categoryId,  List<String> ingredients,  List<CustomizationOption> customizations,  bool isAvailable,  int preparationTime,  String? nameAr,  String? nameDe,  String? nameFr,  String? descriptionAr,  String? descriptionDe,  String? descriptionFr,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _MenuItemModel():
return $default(_that.id,_that.name,_that.price,_that.imageUrl,_that.description,_that.categoryId,_that.ingredients,_that.customizations,_that.isAvailable,_that.preparationTime,_that.nameAr,_that.nameDe,_that.nameFr,_that.descriptionAr,_that.descriptionDe,_that.descriptionFr,_that.createdAt,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  double price,  String? imageUrl,  String? description,  String categoryId,  List<String> ingredients,  List<CustomizationOption> customizations,  bool isAvailable,  int preparationTime,  String? nameAr,  String? nameDe,  String? nameFr,  String? descriptionAr,  String? descriptionDe,  String? descriptionFr,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _MenuItemModel() when $default != null:
return $default(_that.id,_that.name,_that.price,_that.imageUrl,_that.description,_that.categoryId,_that.ingredients,_that.customizations,_that.isAvailable,_that.preparationTime,_that.nameAr,_that.nameDe,_that.nameFr,_that.descriptionAr,_that.descriptionDe,_that.descriptionFr,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _MenuItemModel implements MenuItemModel {
  const _MenuItemModel({required this.id, required this.name, required this.price, this.imageUrl, this.description, required this.categoryId, final  List<String> ingredients = const [], final  List<CustomizationOption> customizations = const [], this.isAvailable = true, this.preparationTime = 0, this.nameAr, this.nameDe, this.nameFr, this.descriptionAr, this.descriptionDe, this.descriptionFr, this.createdAt, this.updatedAt}): _ingredients = ingredients,_customizations = customizations;
  

@override final  String id;
@override final  String name;
@override final  double price;
@override final  String? imageUrl;
@override final  String? description;
@override final  String categoryId;
 final  List<String> _ingredients;
@override@JsonKey() List<String> get ingredients {
  if (_ingredients is EqualUnmodifiableListView) return _ingredients;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ingredients);
}

 final  List<CustomizationOption> _customizations;
@override@JsonKey() List<CustomizationOption> get customizations {
  if (_customizations is EqualUnmodifiableListView) return _customizations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_customizations);
}

@override@JsonKey() final  bool isAvailable;
@override@JsonKey() final  int preparationTime;
@override final  String? nameAr;
@override final  String? nameDe;
@override final  String? nameFr;
@override final  String? descriptionAr;
@override final  String? descriptionDe;
@override final  String? descriptionFr;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of MenuItemModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MenuItemModelCopyWith<_MenuItemModel> get copyWith => __$MenuItemModelCopyWithImpl<_MenuItemModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MenuItemModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&const DeepCollectionEquality().equals(other._ingredients, _ingredients)&&const DeepCollectionEquality().equals(other._customizations, _customizations)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable)&&(identical(other.preparationTime, preparationTime) || other.preparationTime == preparationTime)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr)&&(identical(other.nameDe, nameDe) || other.nameDe == nameDe)&&(identical(other.nameFr, nameFr) || other.nameFr == nameFr)&&(identical(other.descriptionAr, descriptionAr) || other.descriptionAr == descriptionAr)&&(identical(other.descriptionDe, descriptionDe) || other.descriptionDe == descriptionDe)&&(identical(other.descriptionFr, descriptionFr) || other.descriptionFr == descriptionFr)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,price,imageUrl,description,categoryId,const DeepCollectionEquality().hash(_ingredients),const DeepCollectionEquality().hash(_customizations),isAvailable,preparationTime,nameAr,nameDe,nameFr,descriptionAr,descriptionDe,descriptionFr,createdAt,updatedAt);

@override
String toString() {
  return 'MenuItemModel(id: $id, name: $name, price: $price, imageUrl: $imageUrl, description: $description, categoryId: $categoryId, ingredients: $ingredients, customizations: $customizations, isAvailable: $isAvailable, preparationTime: $preparationTime, nameAr: $nameAr, nameDe: $nameDe, nameFr: $nameFr, descriptionAr: $descriptionAr, descriptionDe: $descriptionDe, descriptionFr: $descriptionFr, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$MenuItemModelCopyWith<$Res> implements $MenuItemModelCopyWith<$Res> {
  factory _$MenuItemModelCopyWith(_MenuItemModel value, $Res Function(_MenuItemModel) _then) = __$MenuItemModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, double price, String? imageUrl, String? description, String categoryId, List<String> ingredients, List<CustomizationOption> customizations, bool isAvailable, int preparationTime, String? nameAr, String? nameDe, String? nameFr, String? descriptionAr, String? descriptionDe, String? descriptionFr, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$MenuItemModelCopyWithImpl<$Res>
    implements _$MenuItemModelCopyWith<$Res> {
  __$MenuItemModelCopyWithImpl(this._self, this._then);

  final _MenuItemModel _self;
  final $Res Function(_MenuItemModel) _then;

/// Create a copy of MenuItemModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? price = null,Object? imageUrl = freezed,Object? description = freezed,Object? categoryId = null,Object? ingredients = null,Object? customizations = null,Object? isAvailable = null,Object? preparationTime = null,Object? nameAr = freezed,Object? nameDe = freezed,Object? nameFr = freezed,Object? descriptionAr = freezed,Object? descriptionDe = freezed,Object? descriptionFr = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_MenuItemModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,ingredients: null == ingredients ? _self._ingredients : ingredients // ignore: cast_nullable_to_non_nullable
as List<String>,customizations: null == customizations ? _self._customizations : customizations // ignore: cast_nullable_to_non_nullable
as List<CustomizationOption>,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,preparationTime: null == preparationTime ? _self.preparationTime : preparationTime // ignore: cast_nullable_to_non_nullable
as int,nameAr: freezed == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String?,nameDe: freezed == nameDe ? _self.nameDe : nameDe // ignore: cast_nullable_to_non_nullable
as String?,nameFr: freezed == nameFr ? _self.nameFr : nameFr // ignore: cast_nullable_to_non_nullable
as String?,descriptionAr: freezed == descriptionAr ? _self.descriptionAr : descriptionAr // ignore: cast_nullable_to_non_nullable
as String?,descriptionDe: freezed == descriptionDe ? _self.descriptionDe : descriptionDe // ignore: cast_nullable_to_non_nullable
as String?,descriptionFr: freezed == descriptionFr ? _self.descriptionFr : descriptionFr // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
