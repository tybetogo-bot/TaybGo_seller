// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AddressModel _$AddressModelFromJson(Map<String, dynamic> json) =>
    _AddressModel(
      street: json['street'] as String,
      building: json['building'] as String,
      apartment: json['apartment'] as String?,
      floor: json['floor'] as String?,
      city: json['city'] as String?,
      postalCode: json['postalCode'] as String?,
      country: json['country'] as String? ?? 'Austria',
      placeId: json['placeId'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      additionalInfo: json['additionalInfo'] as String?,
    );

Map<String, dynamic> _$AddressModelToJson(_AddressModel instance) =>
    <String, dynamic>{
      'street': instance.street,
      'building': instance.building,
      'apartment': instance.apartment,
      'floor': instance.floor,
      'city': instance.city,
      'postalCode': instance.postalCode,
      'country': instance.country,
      'placeId': instance.placeId,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'additionalInfo': instance.additionalInfo,
    };

_CustomizationSelection _$CustomizationSelectionFromJson(
  Map<String, dynamic> json,
) => _CustomizationSelection(
  id: json['id'] as String,
  name: json['name'] as String,
  type: $enumDecode(_$CustomizationTypeEnumMap, json['type']),
  priceModifier: (json['priceModifier'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$CustomizationSelectionToJson(
  _CustomizationSelection instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': _$CustomizationTypeEnumMap[instance.type]!,
  'priceModifier': instance.priceModifier,
};

const _$CustomizationTypeEnumMap = {
  CustomizationType.addition: 'addition',
  CustomizationType.removal: 'removal',
};
