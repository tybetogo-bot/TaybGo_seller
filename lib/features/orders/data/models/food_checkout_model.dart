/// Food order creation models for manual order entry
library;

import 'dart:convert';

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

  Map<String, dynamic> toPreviewJson({bool isDefault = false}) {
    return {
      'label': label,
      'is_default': isDefault,
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
  factory OrderAddressData.fromAddressModel(
    AddressModel address, {
    String label = 'Delivery',
  }) {
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

  /// Create from the order API's address shape.
  factory OrderAddressData.fromOrderAddress(
    OrderAddressModel address, {
    String? fallbackLabel,
  }) {
    return OrderAddressData(
      label: address.label ?? fallbackLabel ?? 'Delivery',
      lat: (address.lat ?? 0.0).toStringAsFixed(6),
      lng: (address.lng ?? 0.0).toStringAsFixed(6),
      fullAddress: address.displayAddress,
      streetName: address.streetName,
      houseNumber: address.houseNumber,
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
  motorcycle('MOTOR'),
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

  static VehicleType? fromApiValue(String? value) {
    switch (value?.trim().toUpperCase()) {
      case 'BIKE':
        return VehicleType.bike;
      case 'MOTOR':
      case 'MOTORCYCLE':
        return VehicleType.motorcycle;
      case 'CAR':
        return VehicleType.car;
      case 'VAN':
        return VehicleType.van;
      default:
        return null;
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

/// Live pricing preview request for seller food orders.
class FoodPricePreviewRequest {
  final int restaurantId;
  final OrderAddressData? pickupAddressData;
  final OrderAddressData? dropoffAddressData;
  final String tip;
  final String? couponCode;
  final List<CartItem> items;
  final VehicleType? requestedVehicleType;
  final VehicleType? requestedDeliveryType;

  const FoodPricePreviewRequest({
    required this.restaurantId,
    this.pickupAddressData,
    this.dropoffAddressData,
    this.tip = '0.00',
    this.couponCode,
    required this.items,
    this.requestedVehicleType,
    this.requestedDeliveryType,
  });

  Map<String, dynamic> toJson() {
    return {
      'restaurant_id': restaurantId,
      if (pickupAddressData != null)
        'pickup_address': pickupAddressData!.toPreviewJson(),
      if (dropoffAddressData != null)
        'dropoff_address': dropoffAddressData!.toPreviewJson(),
      'tip': tip,
      if (couponCode != null && couponCode!.isNotEmpty)
        'coupon_code': couponCode,
      'items': items.map((item) => item.toJson()).toList(),
      if (requestedVehicleType != null)
        'requested_vehicle_type': requestedVehicleType!.value,
      if (requestedDeliveryType != null)
        'requested_delivery_type': requestedDeliveryType!.value,
    };
  }

  String get fingerprint => jsonEncode(toJson());
}

/// Live pricing quote returned by the preview endpoint.
class FoodPriceQuote {
  final String calculatedDistance;
  final int? calculatedTime;
  final String subtotalAmount;
  final String discountAmount;
  final String deliveryFee;
  final String totalAmount;

  const FoodPriceQuote({
    required this.calculatedDistance,
    required this.calculatedTime,
    required this.subtotalAmount,
    required this.discountAmount,
    required this.deliveryFee,
    required this.totalAmount,
  });

  factory FoodPriceQuote.fromJson(Map<String, dynamic> json) {
    return FoodPriceQuote(
      calculatedDistance: json['calculated_distance']?.toString() ?? '0',
      calculatedTime: (json['calculated_time'] as num?)?.toInt(),
      subtotalAmount: json['subtotal_amount']?.toString() ?? '0.00',
      discountAmount: json['discount_amount']?.toString() ?? '0.00',
      deliveryFee: json['delivery_fee']?.toString() ?? '0.00',
      totalAmount: json['total_amount']?.toString() ?? '0.00',
    );
  }

  double get subtotalValue => _parseAmount(subtotalAmount);
  double get discountValue => _parseAmount(discountAmount);
  double get deliveryFeeValue => _parseAmount(deliveryFee);
  double get totalValue => _parseAmount(totalAmount);
  double? get distanceKm => double.tryParse(calculatedDistance);
  int? get estimatedMinutes =>
      calculatedTime == null ? null : ((calculatedTime! + 59) ~/ 60);
  bool get hasDiscount => discountValue.abs() > 0.0001;

  static double _parseAmount(String value) => double.tryParse(value) ?? 0.0;
}

/// Food order request model - matches API POST /api/orders/
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
  // Legacy checkout fields kept for compatibility with older flows.
  // The manual create-order endpoint only uses the drop-off address.
  final int? pickupAddressId;
  final int? dropoffAddressId;
  // Embedded address data (optional, used if the address must be created first)
  final OrderAddressData? pickupAddressData;
  final OrderAddressData? dropoffAddressData;
  final List<CartItem>? items;
  final int? couponId;
  final String? couponCode;
  final String? notes;
  final int? paymentMethodId;
  final bool isPaid;
  final String? customerName;
  final String? customerPhoneNumber;

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
    this.isPaid = false,
    this.pickupAddressId,
    this.dropoffAddressId,
    this.pickupAddressData,
    this.dropoffAddressData,
    this.items,
    this.couponId,
    this.couponCode,
    this.notes,
    this.paymentMethodId,
    this.customerName,
    this.customerPhoneNumber,
  });

  Map<String, dynamic> toJson({int? dropoffId}) {
    return {
      'order_type': orderType.value,
      'status': status,
      'restaurant': restaurantId,
      if (customerName != null && customerName!.isNotEmpty)
        'customer_name': customerName,
      if (customerPhoneNumber != null && customerPhoneNumber!.isNotEmpty)
        'customer_phone_number': customerPhoneNumber,
      if (notes != null && notes!.isNotEmpty) 'delivery_instructions': notes,
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
      'is_paid': isPaid,
      if (dropoffId != null) 'dropoff_address': dropoffId,
      if (dropoffId == null && dropoffAddressId != null)
        'dropoff_address': dropoffAddressId,
      if (dropoffId == null &&
          dropoffAddressId == null &&
          dropoffAddressData != null)
        'dropoff_address_data': dropoffAddressData!.toJson(),
      if (items != null && items!.isNotEmpty)
        'items': items!.map((item) => item.toJson()).toList(),
      if (couponId != null) 'coupon': couponId,
    };
  }

  /// Build JSON with pre-created address IDs instead of nested address data.
  Map<String, dynamic> toJsonWithAddressIds({int? dropoffId}) {
    return toJson(dropoffId: dropoffId);
  }
}

String? _buildCustomerPhoneNumber(OrderModel order) {
  final phone = order.phoneNumber.trim();
  final countryCode = order.countryCode.trim();

  if (phone.isEmpty) return null;
  if (phone.startsWith('+')) return phone;
  if (countryCode.isNotEmpty && phone.startsWith(countryCode)) return phone;

  return '$countryCode$phone';
}

String? _buildCartItemCustomizations(OrderItemModel item) {
  final parts = <String>[];

  final customizationsText = item.customizationsText?.trim();
  if (customizationsText != null && customizationsText.isNotEmpty) {
    parts.add(customizationsText);
  }

  final notes = item.notes?.trim();
  if (notes != null && notes.isNotEmpty && !parts.contains(notes)) {
    parts.add(notes);
  }

  if (item.customizations.isNotEmpty) {
    final structuredCustomizations = item.customizations
        .map(
          (customization) => switch (customization.type) {
            CustomizationType.addition => '+ ${customization.name}',
            CustomizationType.removal => '- ${customization.name}',
          },
        )
        .join(', ');

    if (structuredCustomizations.isNotEmpty &&
        !parts.contains(structuredCustomizations)) {
      parts.add(structuredCustomizations);
    }
  }

  if (parts.isEmpty) return null;
  return parts.join('\n');
}

OrderAddressData _buildDropoffAddressData(OrderModel order) {
  final label =
      order.dropoffAddress?.label ?? 'Customer: ${order.customerName}';

  if (order.dropoffAddress != null) {
    return OrderAddressData.fromOrderAddress(
      order.dropoffAddress!,
      fallbackLabel: label,
    );
  }

  return OrderAddressData.fromAddressModel(order.address, label: label);
}

extension OrderReorderRequestExtension on OrderModel {
  FoodCheckoutRequest toReorderRequest() {
    final parsedRestaurantId = int.tryParse(
      restaurantId ?? restaurant?.id.toString() ?? '',
    );

    if (parsedRestaurantId == null || parsedRestaurantId <= 0) {
      throw const FormatException('Missing restaurant for reorder.');
    }

    final cartItems = items.map((item) {
      final parsedItemId = int.tryParse(item.menuItemId);
      if (parsedItemId == null || parsedItemId <= 0) {
        throw FormatException(
          'Order item "${item.name}" is missing a valid menu item id.',
        );
      }

      return CartItem(
        itemId: parsedItemId,
        quantity: item.quantity,
        customizations: _buildCartItemCustomizations(item),
      );
    }).toList();

    if (cartItems.isEmpty) {
      throw const FormatException('This order has no items to reorder.');
    }

    final effectiveSubtotal = subtotal > 0 ? subtotal : calculatedSubtotal;
    final effectiveTotal = total > 0
        ? total
        : effectiveSubtotal + deliveryFee + tips - discountAmount;
    final requestedVehicle = VehicleType.fromApiValue(requestedVehicleType);
    final requestedDelivery =
        VehicleType.fromApiValue(requestedDeliveryType) ?? requestedVehicle;

    return FoodCheckoutRequest(
      restaurantId: parsedRestaurantId,
      customerName: customerName.trim().isEmpty ? null : customerName.trim(),
      customerPhoneNumber: _buildCustomerPhoneNumber(this),
      subtotalAmount: effectiveSubtotal.toStringAsFixed(2),
      discountAmount: discountAmount > 0
          ? discountAmount.toStringAsFixed(2)
          : null,
      deliveryFee: deliveryFee.toStringAsFixed(2),
      tip: tips > 0 ? tips.toStringAsFixed(2) : null,
      totalAmount: effectiveTotal.toStringAsFixed(2),
      requestedVehicleType: requestedVehicle,
      requestedDeliveryType: requestedDelivery,
      isManual: true,
      isPaid: isPaid,
      dropoffAddressData: _buildDropoffAddressData(this),
      items: cartItems,
      couponId: coupon?.id,
      notes: notes,
    );
  }
}

/// Order update request model for editing orders
class OrderUpdateRequest {
  final String? orderType;
  final String? customerName;
  final String? customerPhoneNumber;
  final OrderAddressData? dropoffAddressData;
  final List<CartItem>? items;
  final String? notes;
  final String? status;
  final int? restaurantId;
  final int? couponId;
  final bool includeCoupon;
  final String? subtotalAmount;
  final String? discountAmount;
  final String? deliveryFee;
  final String? tip;
  final String? totalAmount;
  final VehicleType? requestedVehicleType;
  final VehicleType? requestedDeliveryType;
  final bool? isManual;
  final bool? isPaid;

  const OrderUpdateRequest({
    this.orderType,
    this.customerName,
    this.customerPhoneNumber,
    this.dropoffAddressData,
    this.items,
    this.notes,
    this.status,
    this.restaurantId,
    this.couponId,
    this.includeCoupon = false,
    this.subtotalAmount,
    this.discountAmount,
    this.deliveryFee,
    this.tip,
    this.totalAmount,
    this.requestedVehicleType,
    this.requestedDeliveryType,
    this.isManual,
    this.isPaid,
  });

  Map<String, dynamic> toJson() {
    return {
      if (orderType != null) 'order_type': orderType,
      if (customerName != null && customerName!.isNotEmpty)
        'customer_name': customerName,
      if (customerPhoneNumber != null && customerPhoneNumber!.isNotEmpty)
        'customer_phone_number': customerPhoneNumber,
      if (dropoffAddressData != null)
        'dropoff_address_data': dropoffAddressData!.toJson(),
      if (items != null) 'items': items!.map((item) => item.toJson()).toList(),
      if (notes != null) 'delivery_instructions': notes,
      if (status != null) 'status': status,
      if (restaurantId != null) 'restaurant': restaurantId,
      if (includeCoupon) 'coupon': couponId,
      if (subtotalAmount != null) 'subtotal_amount': subtotalAmount,
      if (discountAmount != null) 'discount_amount': discountAmount,
      if (deliveryFee != null) 'delivery_fee': deliveryFee,
      if (tip != null) 'tip': tip,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (requestedVehicleType != null)
        'requested_vehicle_type': requestedVehicleType!.value,
      if (requestedDeliveryType != null)
        'requested_delivery_type': requestedDeliveryType!.value,
      if (isManual != null) 'is_manual': isManual,
      if (isPaid != null) 'is_paid': isPaid,
    };
  }
}
