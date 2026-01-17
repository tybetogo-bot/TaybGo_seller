// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CustomerAddressModel _$CustomerAddressModelFromJson(
  Map<String, dynamic> json,
) => _CustomerAddressModel(
  id: (json['id'] as num?)?.toInt(),
  label: json['label'] as String,
  lat: json['lat'] as String,
  lng: json['lng'] as String,
  fullAddress: json['full_address'] as String,
  streetName: json['street_name'] as String?,
  houseNumber: json['house_number'] as String?,
  city: json['city'] as String?,
  postalCode: json['postal_code'] as String?,
  country: json['country'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$CustomerAddressModelToJson(
  _CustomerAddressModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'label': instance.label,
  'lat': instance.lat,
  'lng': instance.lng,
  'full_address': instance.fullAddress,
  'street_name': instance.streetName,
  'house_number': instance.houseNumber,
  'city': instance.city,
  'postal_code': instance.postalCode,
  'country': instance.country,
  'created_at': instance.createdAt?.toIso8601String(),
};
