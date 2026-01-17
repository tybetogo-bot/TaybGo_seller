/// Food checkout request models for creating food orders
library;

import '../../../addresses/data/models/address_model.dart';
import '../../../restaurant/data/models/restaurant_model.dart';
import 'order_model.dart';

/// Address data for order creation (embedded address, not ID reference)
class OrderAddressData {
  final String label;
  final String lat;
  final String lng;
  final String fullAddress;
  final String? streetName;
  final String? houseNumber;
  final String? city;
  final String? postalCode;
  final String? country;

  const OrderAddressData({
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

  factory OrderAddressData.fromJson(Map<String, dynamic> json) {
    return OrderAddressData(
      label: json['label'] as String? ?? '',
      lat: json['lat']?.toString() ?? '0',
      lng: json['lng']?.toString() ?? '0',
      fullAddress: json['full_address'] as String? ?? '',
      streetName: json['street_name'] as String?,
      houseNumber: json['house_number'] as String?,
      city: json['city'] as String?,
      postalCode: json['postal_code'] as String?,
      country: json['country'] as String?,
    );
  }

  /// Create from RestaurantModel (for pickup address)
  factory OrderAddressData.fromRestaurant(RestaurantModel restaurant) {
    final addressData = restaurant.addressData;
    final lat = restaurant.lat ?? addressData?.lat ?? 0.0;
    final lng = restaurant.lng ?? addressData?.lng ?? 0.0;
    return OrderAddressData(
      label: 'Restaurant',
      lat: lat.toStringAsFixed(6),
      lng: lng.toStringAsFixed(6),
      fullAddress: restaurant.fullAddress,
      streetName: addressData?.streetName,
      houseNumber: addressData?.houseNumber,
      city: addressData?.city ?? restaurant.city,
      postalCode: addressData?.postalCode,
      country: addressData?.country ?? restaurant.country,
    );
  }

  /// Create from CustomerAddressModel (for dropoff address from saved addresses)
  factory OrderAddressData.fromCustomerAddress(CustomerAddressModel address) {
    return OrderAddressData(
      label: address.label,
      lat: address.lat,
      lng: address.lng,
      fullAddress: address.fullAddress,
      streetName: address.streetName,
      houseNumber: address.houseNumber,
      city: address.city,
      postalCode: address.postalCode,
      country: address.country,
    );
  }

  /// Create from AddressModel (from places search widget)
  factory OrderAddressData.fromAddressModel(AddressModel address, {String label = 'Delivery'}) {
    // Build full address from components
    final parts = <String>[
      address.street,
      address.building,
      if (address.city != null) address.city!,
      if (address.postalCode != null) address.postalCode!,
      address.country,
    ];
    final fullAddress = parts.where((p) => p.isNotEmpty).join(', ');

    return OrderAddressData(
      label: label,
      lat: (address.latitude ?? 0.0).toStringAsFixed(6),
      lng: (address.longitude ?? 0.0).toStringAsFixed(6),
      fullAddress: fullAddress,
      streetName: address.street,
      houseNumber: address.building,
      city: address.city,
      postalCode: address.postalCode,
      country: address.country,
    );
  }
}

/// Order type enum
enum OrderType {
  food('FOOD'),
  taxi('TAXI'),
  shipping('SHIPPING');

  final String value;
  const OrderType(this.value);
}

/// Vehicle/delivery type enum
enum VehicleType {
  bike('BIKE'),
  motorcycle('MOTORCYCLE'),
  car('CAR'),
  van('VAN');

  final String value;
  const VehicleType(this.value);

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case VehicleType.bike:
        return 'Bike';
      case VehicleType.motorcycle:
        return 'Motorcycle';
      case VehicleType.car:
        return 'Car';
      case VehicleType.van:
        return 'Van';
    }
  }
}

/// Cart item for food checkout
class CartItem {
  final int itemId;
  final int quantity;
  final String? customizations;

  const CartItem({
    required this.itemId,
    required this.quantity,
    this.customizations,
  });

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'quantity': quantity,
      if (customizations != null && customizations!.isNotEmpty)
        'customizations': customizations,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      itemId: (json['item_id'] ?? json['item']) as int,
      quantity: json['quantity'] as int,
      customizations: json['customizations'] as String?,
    );
  }
}

/// Food checkout request model - matches API POST /api/customer/checkout/food/
class FoodCheckoutRequest {
  final OrderType orderType;
  final String status;
  final int restaurantId;
  final String subtotalAmount;
  final String? discountAmount;
  final String deliveryFee;
  final String? tip;
  final String totalAmount;
  final VehicleType? requestedVehicleType;
  final VehicleType? requestedDeliveryType;
  final int? driverId;
  final bool isManual;
  // Address IDs (required by API)
  final int? pickupAddressId;
  final int? dropoffAddressId;
  // Embedded address data (optional, for creating addresses inline if API supports it)
  final OrderAddressData? pickupAddressData;
  final OrderAddressData? dropoffAddressData;
  final List<CartItem>? items;
  final int? couponId;
  final String? couponCode;
  final String? notes;
  final int? paymentMethodId;

  const FoodCheckoutRequest({
    this.orderType = OrderType.food,
    this.status = 'PENDING',
    required this.restaurantId,
    required this.subtotalAmount,
    this.discountAmount,
    required this.deliveryFee,
    this.tip,
    required this.totalAmount,
    this.requestedVehicleType,
    this.requestedDeliveryType,
    this.driverId,
    this.isManual = false,
    this.pickupAddressId,
    this.dropoffAddressId,
    this.pickupAddressData,
    this.dropoffAddressData,
    this.items,
    this.couponId,
    this.couponCode,
    this.notes,
    this.paymentMethodId,
  });

  Map<String, dynamic> toJson() {
    return {
      'order_type': orderType.value,
      'status': status,
      'restaurant': restaurantId,
      'subtotal_amount': subtotalAmount,
      if (discountAmount != null) 'discount_amount': discountAmount,
      'delivery_fee': deliveryFee,
      if (tip != null) 'tip': tip,
      'total_amount': totalAmount,
      if (requestedVehicleType != null)
        'requested_vehicle_type': requestedVehicleType!.value,
      if (requestedDeliveryType != null)
        'requested_delivery_type': requestedDeliveryType!.value,
      if (driverId != null) 'driver': driverId,
      'is_manual': isManual,
      // Use address IDs if provided, otherwise use embedded data
      if (pickupAddressId != null) 'pickup_address': pickupAddressId,
      if (dropoffAddressId != null) 'dropoff_address': dropoffAddressId,
      if (pickupAddressData != null && pickupAddressId == null)
        'pickup_address_data': pickupAddressData!.toJson(),
      if (dropoffAddressData != null && dropoffAddressId == null)
        'dropoff_address_data': dropoffAddressData!.toJson(),
      if (items != null && items!.isNotEmpty)
        'items': items!.map((item) => item.toJson()).toList(),
      if (couponId != null) 'coupon': couponId,
      if (couponCode != null && couponCode!.isNotEmpty && couponId == null)
        'coupon_code': couponCode,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      if (paymentMethodId != null) 'payment_method': paymentMethodId,
    };
  }
}

/// Order update request model for editing orders
class OrderUpdateRequest {
  final OrderAddressData? dropoffAddressData;
  final List<CartItem>? items;
  final String? notes;
  final String? status;
  final String? subtotalAmount;
  final String? discountAmount;
  final String? deliveryFee;
  final String? tip;
  final String? totalAmount;

  const OrderUpdateRequest({
    this.dropoffAddressData,
    this.items,
    this.notes,
    this.status,
    this.subtotalAmount,
    this.discountAmount,
    this.deliveryFee,
    this.tip,
    this.totalAmount,
  });

  Map<String, dynamic> toJson() {
    return {
      if (dropoffAddressData != null)
        'dropoff_address_data': dropoffAddressData!.toJson(),
      if (items != null) 'items': items!.map((item) => item.toJson()).toList(),
      if (notes != null) 'notes': notes,
      if (status != null) 'status': status,
      if (subtotalAmount != null) 'subtotal_amount': subtotalAmount,
      if (discountAmount != null) 'discount_amount': discountAmount,
      if (deliveryFee != null) 'delivery_fee': deliveryFee,
      if (tip != null) 'tip': tip,
      if (totalAmount != null) 'total_amount': totalAmount,
    };
  }
}
