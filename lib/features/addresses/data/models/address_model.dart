import 'package:freezed_annotation/freezed_annotation.dart';

part 'address_model.freezed.dart';
part 'address_model.g.dart';

/// Customer address model matching API schema
@freezed
sealed class CustomerAddressModel with _$CustomerAddressModel {
  const CustomerAddressModel._();

  const factory CustomerAddressModel({
    /// Unique identifier (read-only from API)
    int? id,

    /// Label for the address (e.g., "home", "work", "office")
    required String label,

    /// Latitude as decimal string
    required String lat,

    /// Longitude as decimal string
    required String lng,

    /// Full formatted address string
    @JsonKey(name: 'full_address') required String fullAddress,

    /// Street name
    @JsonKey(name: 'street_name') String? streetName,

    /// House/building number
    @JsonKey(name: 'house_number') String? houseNumber,

    /// City name
    String? city,

    /// Postal/ZIP code
    @JsonKey(name: 'postal_code') String? postalCode,

    /// Country name
    String? country,

    /// Creation timestamp (read-only from API)
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _CustomerAddressModel;

  factory CustomerAddressModel.fromJson(Map<String, dynamic> json) =>
      _$CustomerAddressModelFromJson(json);

  /// Convert to JSON for API create/update requests
  Map<String, dynamic> toCreateJson() {
    return {
      'label': label,
      'lat': lat,
      'lng': lng,
      'full_address': fullAddress,
      if (streetName != null) 'street_name': streetName,
      if (houseNumber != null) 'house_number': houseNumber,
      if (city != null) 'city': city,
      if (postalCode != null) 'postal_code': postalCode,
      if (country != null) 'country': country,
    };
  }
}

/// Request model for creating/updating addresses
class AddressCreateRequest {
  final String label;
  final String lat;
  final String lng;
  final String fullAddress;
  final String? streetName;
  final String? houseNumber;
  final String? city;
  final String? postalCode;
  final String? country;

  const AddressCreateRequest({
    required this.label,
    required this.lat,
    required this.lng,
    required this.fullAddress,
    this.streetName,
    this.houseNumber,
    this.city,
    this.postalCode,
    this.country,
  });

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'lat': lat,
      'lng': lng,
      'full_address': fullAddress,
      if (streetName != null) 'street_name': streetName,
      if (houseNumber != null) 'house_number': houseNumber,
      if (city != null) 'city': city,
      if (postalCode != null) 'postal_code': postalCode,
      if (country != null) 'country': country,
    };
  }

  /// Create from CustomerAddressModel (for editing existing addresses)
  factory AddressCreateRequest.fromModel(CustomerAddressModel model) {
    return AddressCreateRequest(
      label: model.label,
      lat: model.lat,
      lng: model.lng,
      fullAddress: model.fullAddress,
      streetName: model.streetName,
      houseNumber: model.houseNumber,
      city: model.city,
      postalCode: model.postalCode,
      country: model.country,
    );
  }
}
