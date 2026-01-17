/// Food checkout request models for creating food orders
library;

/// Cart item for food checkout
class CartItem {
  final int itemId;
  final int quantity;
  final Map<String, dynamic>? customizations;
  final String? notes;

  const CartItem({
    required this.itemId,
    required this.quantity,
    this.customizations,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'item': itemId,
      'quantity': quantity,
      if (customizations != null && customizations!.isNotEmpty)
        'customizations': customizations,
      if (notes != null) 'notes': notes,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      itemId: json['item'] as int,
      quantity: json['quantity'] as int,
      customizations: json['customizations'] as Map<String, dynamic>?,
      notes: json['notes'] as String?,
    );
  }
}

/// Food checkout request model
class FoodCheckoutRequest {
  final int restaurantId;
  final int addressId;
  final List<CartItem> items;
  final int? paymentMethodId;
  final String? couponCode;
  final String? notes;
  final double? tip;

  const FoodCheckoutRequest({
    required this.restaurantId,
    required this.addressId,
    required this.items,
    this.paymentMethodId,
    this.couponCode,
    this.notes,
    this.tip,
  });

  Map<String, dynamic> toJson() {
    return {
      'restaurant': restaurantId,
      'dropoff_address': addressId,
      'items': items.map((item) => item.toJson()).toList(),
      if (paymentMethodId != null) 'payment_method': paymentMethodId,
      if (couponCode != null && couponCode!.isNotEmpty) 'coupon_code': couponCode,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      if (tip != null && tip! > 0) 'tip': tip,
    };
  }
}

/// Order update request model for editing orders
class OrderUpdateRequest {
  final int? addressId;
  final List<CartItem>? items;
  final String? notes;
  final String? status;

  const OrderUpdateRequest({
    this.addressId,
    this.items,
    this.notes,
    this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      if (addressId != null) 'dropoff_address': addressId,
      if (items != null) 'items': items!.map((item) => item.toJson()).toList(),
      if (notes != null) 'notes': notes,
      if (status != null) 'status': status,
    };
  }
}
