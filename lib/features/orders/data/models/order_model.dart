import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_model.freezed.dart';
part 'order_model.g.dart';

/// Order status enum representing the lifecycle of an order
enum OrderStatusEnum {
  @JsonValue('PENDING')
  pending,
  @JsonValue('SEARCHING_FOR_DRIVER')
  searchingForDriver,
  @JsonValue('DRIVER_NOTIFICATION_SENT')
  driverNotificationSent,
  @JsonValue('ACCEPTED')
  accepted,
  @JsonValue('ON_THE_WAY')
  onTheWay,
  @JsonValue('DELIVERED')
  delivered,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('REJECTED')
  rejected,
  @JsonValue('CANCELLED')
  cancelled,
}

/// Extension to get display name for order status
extension OrderStatusExtension on OrderStatusEnum {
  String get displayName {
    switch (this) {
      case OrderStatusEnum.pending:
        return 'Pending';
      case OrderStatusEnum.searchingForDriver:
        return 'Searching for Driver';
      case OrderStatusEnum.driverNotificationSent:
        return 'Driver Notified';
      case OrderStatusEnum.accepted:
        return 'Accepted';
      case OrderStatusEnum.onTheWay:
        return 'On the Way';
      case OrderStatusEnum.delivered:
        return 'Delivered';
      case OrderStatusEnum.completed:
        return 'Completed';
      case OrderStatusEnum.rejected:
        return 'Rejected';
      case OrderStatusEnum.cancelled:
        return 'Cancelled';
    }
  }

  /// Check if order can transition to a new status
  bool canTransitionTo(OrderStatusEnum newStatus) {
    switch (this) {
      case OrderStatusEnum.pending:
        return newStatus == OrderStatusEnum.searchingForDriver ||
            newStatus == OrderStatusEnum.accepted ||
            newStatus == OrderStatusEnum.rejected;
      case OrderStatusEnum.searchingForDriver:
        return newStatus == OrderStatusEnum.driverNotificationSent ||
            newStatus == OrderStatusEnum.cancelled;
      case OrderStatusEnum.driverNotificationSent:
        return newStatus == OrderStatusEnum.accepted ||
            newStatus == OrderStatusEnum.cancelled;
      case OrderStatusEnum.accepted:
        return newStatus == OrderStatusEnum.onTheWay ||
            newStatus == OrderStatusEnum.cancelled;
      case OrderStatusEnum.onTheWay:
        return newStatus == OrderStatusEnum.delivered;
      case OrderStatusEnum.delivered:
        return newStatus == OrderStatusEnum.completed;
      case OrderStatusEnum.completed:
      case OrderStatusEnum.rejected:
      case OrderStatusEnum.cancelled:
        return false;
    }
  }

  /// Get the next status in the flow
  OrderStatusEnum? get nextStatus {
    switch (this) {
      case OrderStatusEnum.pending:
        return OrderStatusEnum.accepted;
      case OrderStatusEnum.searchingForDriver:
        return OrderStatusEnum.driverNotificationSent;
      case OrderStatusEnum.driverNotificationSent:
        return OrderStatusEnum.accepted;
      case OrderStatusEnum.accepted:
        return OrderStatusEnum.onTheWay;
      case OrderStatusEnum.onTheWay:
        return OrderStatusEnum.delivered;
      case OrderStatusEnum.delivered:
        return OrderStatusEnum.completed;
      case OrderStatusEnum.completed:
      case OrderStatusEnum.rejected:
      case OrderStatusEnum.cancelled:
        return null;
    }
  }
}

/// Customization type for menu items
enum CustomizationType {
  @JsonValue('addition')
  addition,
  @JsonValue('removal')
  removal,
}

/// Address model for delivery location
@freezed
sealed class AddressModel with _$AddressModel {
  const AddressModel._();

  const factory AddressModel({
    required String street,
    required String building,
    String? apartment,
    String? floor,
    String? city,
    String? postalCode,
    @Default('Austria') String country,
    String? placeId,
    double? latitude,
    double? longitude,
    String? additionalInfo,
  }) = _AddressModel;

  factory AddressModel.fromJson(Map<String, dynamic> json) =>
      _$AddressModelFromJson(json);

  /// Convert to JSON for API requests
  @override
  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'building': building,
      if (apartment != null) 'apartment': apartment,
      if (floor != null) 'floor': floor,
      if (city != null) 'city': city,
      if (postalCode != null) 'postal_code': postalCode,
      'country': country,
      if (placeId != null) 'place_id': placeId,
      if (latitude != null) 'lat': latitude,
      if (longitude != null) 'lng': longitude,
      if (additionalInfo != null) 'additional_info': additionalInfo,
    };
  }
}

/// Customization selection for an order item
@freezed
sealed class CustomizationSelection with _$CustomizationSelection {
  const CustomizationSelection._();

  const factory CustomizationSelection({
    required String id,
    required String name,
    required CustomizationType type,
    @Default(0.0) double priceModifier,
  }) = _CustomizationSelection;

  factory CustomizationSelection.fromJson(Map<String, dynamic> json) =>
      _$CustomizationSelectionFromJson(json);

  /// Convert to JSON for API requests
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type == CustomizationType.addition ? 'addition' : 'removal',
      'price_modifier': priceModifier,
    };
  }
}

/// Order item model representing a menu item in an order
@freezed
sealed class OrderItemModel with _$OrderItemModel {
  const OrderItemModel._();

  const factory OrderItemModel({
    required String id,
    required String menuItemId,
    required String name,
    required int quantity,
    required double unitPrice,
    String? notes,
    @Default([]) List<CustomizationSelection> customizations,
  }) = _OrderItemModel;

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'item': menuItemId,
      'item_name': name,
      'quantity': quantity,
      'price': unitPrice,
      if (notes != null) 'notes': notes,
      if (customizations.isNotEmpty)
        'customizations': customizations.map((c) => c.toJson()).toList(),
    };
  }

  /// Custom fromJson to handle API response format
  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    // Handle API response format: {id: 1, item: 1, item_name: Classic Burger, quantity: 1, price: 10.99, customizations: null}
    // Try multiple field names for price: price, unit_price, unitPrice, item_price
    final priceValue = json['price'] ?? json['unit_price'] ?? json['unitPrice'] ?? json['item_price'] ?? 0;

    return OrderItemModel(
      id: json['id']?.toString() ?? '',
      menuItemId: (json['item'] ?? json['menuItemId'] ?? json['menu_item_id'])?.toString() ?? '',
      name: json['item_name'] ?? json['name'] ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (priceValue is num) ? priceValue.toDouble() : (double.tryParse(priceValue.toString()) ?? 0.0),
      notes: json['notes'] as String?,
      customizations: json['customizations'] != null && json['customizations'] is List
          ? (json['customizations'] as List)
              .map((c) => CustomizationSelection.fromJson(c as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}

/// Extension for OrderItemModel calculations
extension OrderItemModelExtension on OrderItemModel {
  /// Calculate total price including customizations
  double get totalPrice {
    final customizationTotal = customizations.fold<double>(
      0.0,
      (sum, c) => sum + c.priceModifier,
    );
    return (unitPrice + customizationTotal) * quantity;
  }
}

/// Main order model
@freezed
sealed class OrderModel with _$OrderModel {
  const factory OrderModel({
    required String id,
    required String customerName,
    required String phoneNumber,
    required String countryCode,
    required AddressModel address,
    required List<OrderItemModel> items,
    @Default(0.0) double subtotal,
    @Default(0.0) double deliveryFee,
    @Default(0.0) double tips,
    @Default(0.0) double total,
    @Default(false) bool isPaid,
    @Default(OrderStatusEnum.pending) OrderStatusEnum status,
    String? notes,
    String? rejectionReason,
    required DateTime createdAt,
    DateTime? acceptedAt,
    DateTime? readyAt,
    DateTime? outForDeliveryAt,
    DateTime? deliveredAt,
    String? restaurantId,
    String? assignedDriverId,
  }) = _OrderModel;

  /// Custom fromJson to handle API response format
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Parse status from API (e.g., "SEARCHING_FOR_DRIVER")
    OrderStatusEnum parseStatus(String? statusStr) {
      if (statusStr == null) return OrderStatusEnum.pending;
      switch (statusStr.toUpperCase()) {
        case 'PENDING':
          return OrderStatusEnum.pending;
        case 'SEARCHING_FOR_DRIVER':
          return OrderStatusEnum.searchingForDriver;
        case 'DRIVER_NOTIFICATION_SENT':
          return OrderStatusEnum.driverNotificationSent;
        case 'ACCEPTED':
          return OrderStatusEnum.accepted;
        case 'ON_THE_WAY':
          return OrderStatusEnum.onTheWay;
        case 'DELIVERED':
          return OrderStatusEnum.delivered;
        case 'COMPLETED':
          return OrderStatusEnum.completed;
        case 'REJECTED':
          return OrderStatusEnum.rejected;
        case 'CANCELLED':
          return OrderStatusEnum.cancelled;
        default:
          return OrderStatusEnum.pending;
      }
    }

    // Parse items list
    List<OrderItemModel> parseItems(dynamic itemsJson) {
      if (itemsJson == null || itemsJson is! List) return [];
      return itemsJson
          .map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    // Build address from API response (may be an ID or object)
    AddressModel parseAddress(dynamic addressJson) {
      if (addressJson is Map<String, dynamic>) {
        return AddressModel(
          street: addressJson['street'] ?? addressJson['address'] ?? '',
          building: addressJson['building'] ?? '',
          apartment: addressJson['apartment'] as String?,
          floor: addressJson['floor'] as String?,
          city: addressJson['city'] as String?,
          postalCode: addressJson['postal_code'] ?? addressJson['postalCode'] as String?,
          latitude: (addressJson['lat'] ?? addressJson['latitude'])?.toDouble(),
          longitude: (addressJson['lng'] ?? addressJson['longitude'])?.toDouble(),
        );
      }
      // If address is just an ID, return empty address
      return const AddressModel(street: 'N/A', building: 'N/A');
    }

    // Parse customer name - could be direct field or nested in customer object
    String parseCustomerName(Map<String, dynamic> json) {
      if (json['customer_name'] != null) return json['customer_name'] as String;
      if (json['customerName'] != null) return json['customerName'] as String;
      // Handle nested customer object
      if (json['customer'] is Map<String, dynamic>) {
        final customer = json['customer'] as Map<String, dynamic>;
        return customer['name'] ?? customer['full_name'] ?? customer['first_name'] ?? 'Customer';
      }
      return 'Customer';
    }

    // Parse phone number - could be direct field or nested
    String parsePhoneNumber(Map<String, dynamic> json) {
      if (json['phone_number'] != null) return json['phone_number'].toString();
      if (json['phoneNumber'] != null) return json['phoneNumber'].toString();
      if (json['phone'] != null) return json['phone'].toString();
      // Handle nested customer object
      if (json['customer'] is Map<String, dynamic>) {
        final customer = json['customer'] as Map<String, dynamic>;
        return customer['phone_number']?.toString() ?? customer['phone']?.toString() ?? '';
      }
      return '';
    }

    // Parse country code
    String parseCountryCode(Map<String, dynamic> json) {
      if (json['country_code'] != null) return json['country_code'].toString();
      if (json['countryCode'] != null) return json['countryCode'].toString();
      // Handle nested customer object
      if (json['customer'] is Map<String, dynamic>) {
        final customer = json['customer'] as Map<String, dynamic>;
        return customer['country_code']?.toString() ?? '+43';
      }
      return '+43';
    }

    return OrderModel(
      id: json['id']?.toString() ?? '',
      customerName: parseCustomerName(json),
      phoneNumber: parsePhoneNumber(json),
      countryCode: parseCountryCode(json),
      address: parseAddress(json['dropoff_address'] ?? json['delivery_address'] ?? json['address']),
      items: parseItems(json['items'] ?? json['order_items']),
      subtotal: double.tryParse(json['subtotal_amount']?.toString() ?? json['subtotal']?.toString() ?? '0') ?? 0.0,
      deliveryFee: double.tryParse(json['delivery_fee']?.toString() ?? json['deliveryFee']?.toString() ?? '0') ?? 0.0,
      tips: double.tryParse(json['tip']?.toString() ?? json['tips']?.toString() ?? '0') ?? 0.0,
      total: double.tryParse(json['total_amount']?.toString() ?? json['total']?.toString() ?? '0') ?? 0.0,
      isPaid: json['is_paid'] ?? json['isPaid'] ?? json['paid'] ?? false,
      status: parseStatus(json['status'] as String?),
      notes: json['notes'] as String?,
      rejectionReason: json['rejection_reason'] ?? json['rejectionReason'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : (json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now()),
      acceptedAt: json['accepted_at'] != null ? DateTime.parse(json['accepted_at'] as String) : null,
      readyAt: json['ready_at'] != null ? DateTime.parse(json['ready_at'] as String) : null,
      outForDeliveryAt: json['out_for_delivery_at'] != null ? DateTime.parse(json['out_for_delivery_at'] as String) : null,
      deliveredAt: json['delivered_at'] != null ? DateTime.parse(json['delivered_at'] as String) : null,
      restaurantId: (json['restaurant'] ?? json['restaurant_id'] ?? json['restaurantId'])?.toString(),
      assignedDriverId: json['assigned_driver_id']?.toString() ?? json['assignedDriverId']?.toString(),
    );
  }
}

/// Extension for OrderModel calculations and utilities
extension OrderModelExtension on OrderModel {
  /// Calculate subtotal from items
  double get calculatedSubtotal {
    return items.fold<double>(0.0, (sum, item) {
      final customizationTotal = item.customizations.fold<double>(
        0.0,
        (cSum, c) => cSum + c.priceModifier,
      );
      return sum + ((item.unitPrice + customizationTotal) * item.quantity);
    });
  }

  /// Calculate total with delivery fee and tips
  double get calculatedTotal => calculatedSubtotal + deliveryFee + tips;

  /// Check if order is active (not completed or cancelled)
  bool get isActive =>
      status != OrderStatusEnum.delivered &&
      status != OrderStatusEnum.rejected &&
      status != OrderStatusEnum.cancelled;

  /// Check if order is in "new/pending" state
  bool get isNew =>
      status == OrderStatusEnum.pending ||
      status == OrderStatusEnum.searchingForDriver;

  /// Check if order is completed
  bool get isCompleted =>
      status == OrderStatusEnum.delivered ||
      status == OrderStatusEnum.rejected ||
      status == OrderStatusEnum.cancelled;

  /// Get formatted phone number
  String get formattedPhone => '$countryCode $phoneNumber';

  /// Get full address as string
  String get fullAddress {
    final parts = <String>[
      address.street,
      address.building,
      if (address.apartment != null) 'Apt ${address.apartment}',
      if (address.floor != null) 'Floor ${address.floor}',
      if (address.city != null) address.city!,
      if (address.postalCode != null) address.postalCode!,
      address.country,
    ];
    return parts.join(', ');
  }
}
