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
  @JsonValue('RESTAURANT_DELIVERED')
  restaurantDelivered,
  @JsonValue('EXPIRED')
  expired,
  @JsonValue('REJECTED')
  rejected,
  @JsonValue('CANCELLED')
  cancelled,
}

OrderStatusEnum? orderStatusFromApi(String? statusStr) {
  if (statusStr == null) return null;
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
    case 'RESTAURANT_DELIVERED':
      return OrderStatusEnum.restaurantDelivered;
    case 'COMPLETED':
      return OrderStatusEnum.delivered;
    case 'EXPIRED':
      return OrderStatusEnum.expired;
    case 'REJECTED':
      return OrderStatusEnum.rejected;
    case 'CANCELLED':
      return OrderStatusEnum.cancelled;
    default:
      return null;
  }
}

class OrderAllowedStatusOption {
  const OrderAllowedStatusOption({required this.value, this.label});

  final String value;
  final String? label;

  OrderStatusEnum? get status => orderStatusFromApi(value);

  factory OrderAllowedStatusOption.fromJson(Map<String, dynamic> json) {
    return OrderAllowedStatusOption(
      value: json['value']?.toString() ?? '',
      label: json['label'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is OrderAllowedStatusOption &&
            other.value == value &&
            other.label == label);
  }

  @override
  int get hashCode => Object.hash(value, label);
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
      case OrderStatusEnum.restaurantDelivered:
        return 'Restaurant Delivered';
      case OrderStatusEnum.expired:
        return 'Expired';
      case OrderStatusEnum.rejected:
        return 'Rejected';
      case OrderStatusEnum.cancelled:
        return 'Cancelled';
    }
  }

  /// Check if order can transition to a new status
  /// Flow: PENDING → SEARCHING_FOR_DRIVER → DRIVER_NOTIFICATION_SENT → ACCEPTED/REJECTED → ON_THE_WAY → DELIVERED
  /// If restaurant delivery is disabled: PENDING → RESTAURANT_DELIVERED
  bool canTransitionTo(OrderStatusEnum newStatus) {
    switch (this) {
      case OrderStatusEnum.pending:
        return newStatus == OrderStatusEnum.searchingForDriver ||
            newStatus == OrderStatusEnum.restaurantDelivered ||
            newStatus == OrderStatusEnum.cancelled;
      case OrderStatusEnum.searchingForDriver:
        return newStatus == OrderStatusEnum.driverNotificationSent ||
            newStatus == OrderStatusEnum.cancelled;
      case OrderStatusEnum.driverNotificationSent:
        return newStatus == OrderStatusEnum.accepted ||
            newStatus == OrderStatusEnum.rejected ||
            newStatus == OrderStatusEnum.cancelled;
      case OrderStatusEnum.accepted:
        return newStatus == OrderStatusEnum.onTheWay ||
            newStatus == OrderStatusEnum.cancelled;
      case OrderStatusEnum.onTheWay:
        return newStatus == OrderStatusEnum.delivered;
      case OrderStatusEnum.delivered:
      case OrderStatusEnum.restaurantDelivered:
      case OrderStatusEnum.expired:
      case OrderStatusEnum.rejected:
      case OrderStatusEnum.cancelled:
        return false;
    }
  }

  /// Get the next status in the flow
  /// Flow: PENDING → SEARCHING_FOR_DRIVER → DRIVER_NOTIFICATION_SENT → ACCEPTED → ON_THE_WAY → DELIVERED
  OrderStatusEnum? get nextStatus {
    switch (this) {
      case OrderStatusEnum.pending:
        return OrderStatusEnum.searchingForDriver;
      case OrderStatusEnum.searchingForDriver:
        return OrderStatusEnum.driverNotificationSent;
      case OrderStatusEnum.driverNotificationSent:
        return OrderStatusEnum.accepted;
      case OrderStatusEnum.accepted:
        return OrderStatusEnum.onTheWay;
      case OrderStatusEnum.onTheWay:
        return OrderStatusEnum.delivered;
      case OrderStatusEnum.delivered:
      case OrderStatusEnum.restaurantDelivered:
      case OrderStatusEnum.expired:
      case OrderStatusEnum.rejected:
      case OrderStatusEnum.cancelled:
        return null;
    }
  }

  /// Get the previous status in the flow (for undo functionality)
  /// Flow: DELIVERED → ON_THE_WAY → ACCEPTED → DRIVER_NOTIFICATION_SENT → SEARCHING_FOR_DRIVER → PENDING
  /// Direct restaurant-delivered orders revert to PENDING.
  OrderStatusEnum? get previousStatus {
    switch (this) {
      case OrderStatusEnum.delivered:
        return OrderStatusEnum.onTheWay;
      case OrderStatusEnum.restaurantDelivered:
        return OrderStatusEnum.pending;
      case OrderStatusEnum.onTheWay:
        return OrderStatusEnum.accepted;
      case OrderStatusEnum.accepted:
        return OrderStatusEnum.driverNotificationSent;
      case OrderStatusEnum.driverNotificationSent:
        return OrderStatusEnum.searchingForDriver;
      case OrderStatusEnum.searchingForDriver:
        return OrderStatusEnum.pending;
      case OrderStatusEnum.pending:
      case OrderStatusEnum.expired:
      case OrderStatusEnum.rejected:
      case OrderStatusEnum.cancelled:
        return null;
    }
  }

  OrderStatusEnum? nextStatusForRestaurant({required bool deliveryEnabled}) {
    if (this == OrderStatusEnum.pending) {
      return deliveryEnabled
          ? OrderStatusEnum.searchingForDriver
          : OrderStatusEnum.restaurantDelivered;
    }
    return nextStatus;
  }

  bool get isTerminal {
    switch (this) {
      case OrderStatusEnum.delivered:
      case OrderStatusEnum.restaurantDelivered:
      case OrderStatusEnum.expired:
      case OrderStatusEnum.rejected:
      case OrderStatusEnum.cancelled:
        return true;
      case OrderStatusEnum.pending:
      case OrderStatusEnum.searchingForDriver:
      case OrderStatusEnum.driverNotificationSent:
      case OrderStatusEnum.accepted:
      case OrderStatusEnum.onTheWay:
        return false;
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

/// Order type enum
enum OrderType {
  @JsonValue('FOOD')
  food,
  @JsonValue('PARCEL')
  parcel,
}

/// Helper function to parse double from various types
double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

/// Restaurant model for order (embedded in order response)
class OrderRestaurantModel {
  final int id;
  final String name;
  final String? logo;
  final OrderAddressModel? addressObject;
  final double? lat;
  final double? lng;
  final String? phone;
  final String? status;
  final DateTime? createdAt;

  const OrderRestaurantModel({
    required this.id,
    required this.name,
    this.logo,
    this.addressObject,
    this.lat,
    this.lng,
    this.phone,
    this.status,
    this.createdAt,
  });

  /// Get address as display string
  String? get address => addressObject?.displayAddress;

  factory OrderRestaurantModel.fromJson(Map<String, dynamic> json) {
    // Parse address - can be a nested object or a string
    OrderAddressModel? parsedAddress;
    if (json['address'] is Map<String, dynamic>) {
      parsedAddress = OrderAddressModel.fromJson(
        json['address'] as Map<String, dynamic>,
      );
    }

    return OrderRestaurantModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      logo: json['logo'] as String?,
      addressObject: parsedAddress,
      lat: parsedAddress?.lat ?? _parseDouble(json['lat']),
      lng: parsedAddress?.lng ?? _parseDouble(json['lng']),
      phone: json['phone'] as String?,
      status: json['status'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}

/// Coupon model for order (embedded in order response)
class OrderCouponModel {
  final int id;
  final int restaurantId;
  final String title;
  final String? description;
  final String code;
  final int percentage;
  final String? minPrice;
  final int? maxTotalUsers;
  final int? maxPerCustomer;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final DateTime? createdAt;

  const OrderCouponModel({
    required this.id,
    required this.restaurantId,
    required this.title,
    this.description,
    required this.code,
    required this.percentage,
    this.minPrice,
    this.maxTotalUsers,
    this.maxPerCustomer,
    this.startDate,
    this.endDate,
    this.isActive = true,
    this.createdAt,
  });

  factory OrderCouponModel.fromJson(Map<String, dynamic> json) {
    return OrderCouponModel(
      id: json['id'] as int,
      restaurantId: json['restaurant'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      code: json['code'] as String? ?? '',
      percentage: json['percentage'] as int? ?? 0,
      minPrice: json['min_price'] as String?,
      maxTotalUsers: json['max_total_users'] as int?,
      maxPerCustomer: json['max_per_customer'] as int?,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}

/// Driver model for order (embedded in order response)
class OrderDriverModel {
  final int id;
  final String email;
  final String name;
  final String? phone;
  final int? age;
  final bool isVerified;
  final DateTime? createdAt;
  final List<String> roles;

  const OrderDriverModel({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.age,
    this.isVerified = false,
    this.createdAt,
    this.roles = const [],
  });

  factory OrderDriverModel.fromJson(Map<String, dynamic> json) {
    return OrderDriverModel(
      id: json['id'] as int,
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String?,
      age: json['age'] as int?,
      isVerified: json['is_verified'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      roles:
          (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
    );
  }
}

/// Order address model for pickup/dropoff (new API structure)
class OrderAddressModel {
  final int? id;
  final String? label;
  final double? lat;
  final double? lng;
  final String? fullAddress;
  final String? streetName;
  final String? houseNumber;
  final String? city;
  final String? postalCode;
  final String? country;
  final DateTime? createdAt;

  const OrderAddressModel({
    this.id,
    this.label,
    this.lat,
    this.lng,
    this.fullAddress,
    this.streetName,
    this.houseNumber,
    this.city,
    this.postalCode,
    this.country,
    this.createdAt,
  });

  factory OrderAddressModel.fromJson(Map<String, dynamic> json) {
    return OrderAddressModel(
      id: json['id'] as int?,
      label: json['label'] as String?,
      lat: _parseDouble(json['lat']),
      lng: _parseDouble(json['lng']),
      fullAddress: json['full_address'] as String?,
      streetName: json['street_name'] as String?,
      houseNumber: json['house_number'] as String?,
      city: json['city'] as String?,
      postalCode: json['postal_code'] as String?,
      country: json['country'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Get display address
  String get displayAddress {
    if (fullAddress != null && fullAddress!.isNotEmpty) {
      return fullAddress!;
    }
    final parts = <String>[
      if (streetName != null) streetName!,
      if (houseNumber != null) houseNumber!,
      if (city != null) city!,
      if (postalCode != null) postalCode!,
      if (country != null) country!,
    ];
    if (parts.isNotEmpty) return parts.join(', ');
    return 'N/A';
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (fullAddress != null) 'full_address': fullAddress,
      if (streetName != null) 'street_name': streetName,
      if (houseNumber != null) 'house_number': houseNumber,
      if (city != null) 'city': city,
      if (postalCode != null) 'postal_code': postalCode,
      if (country != null) 'country': country,
    };
  }
}

/// Address model for delivery location (legacy - keeping for backward compatibility)
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

  /// Create from new API OrderAddressModel
  factory AddressModel.fromOrderAddress(OrderAddressModel orderAddress) {
    return AddressModel(
      street: orderAddress.fullAddress ?? orderAddress.streetName ?? 'N/A',
      building: orderAddress.houseNumber ?? '',
      city: orderAddress.city,
      postalCode: orderAddress.postalCode,
      country: orderAddress.country ?? 'Austria',
      latitude: orderAddress.lat,
      longitude: orderAddress.lng,
    );
  }

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

    /// Raw customizations text from API (e.g., "no sauce")
    String? customizationsText,
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
    final priceValue =
        json['price'] ??
        json['unit_price'] ??
        json['unitPrice'] ??
        json['item_price'] ??
        0;

    // Handle customizations - can be a string (from API) or a list of objects
    final customizationsRaw = json['customizations'];
    String? customizationsText;
    List<CustomizationSelection> customizationsList = [];

    if (customizationsRaw is String && customizationsRaw.isNotEmpty) {
      // API returns customizations as a string (e.g., "no sauce")
      customizationsText = customizationsRaw;
    } else if (customizationsRaw is List) {
      // Structured customizations list
      customizationsList = customizationsRaw
          .map(
            (c) => CustomizationSelection.fromJson(c as Map<String, dynamic>),
          )
          .toList();
    }

    return OrderItemModel(
      id: json['id']?.toString() ?? '',
      menuItemId:
          (json['item'] ?? json['menuItemId'] ?? json['menu_item_id'])
              ?.toString() ??
          '',
      name: json['item_name'] ?? json['name'] ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (priceValue is num)
          ? priceValue.toDouble()
          : (double.tryParse(priceValue.toString()) ?? 0.0),
      notes:
          json['delivery_instructions'] as String? ?? json['notes'] as String?,
      customizations: customizationsList,
      customizationsText: customizationsText,
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
    @Default(0.0) double discountAmount,
    @Default(0.0) double tips,
    @Default(0.0) double total,
    @Default(false) bool isPaid,
    @Default(OrderStatusEnum.pending) OrderStatusEnum status,
    @Default(false) bool hasAllowedStatusOptions,
    @Default([]) List<OrderAllowedStatusOption> allowedStatusOptions,
    String? notes,
    String? rejectionReason,
    required DateTime createdAt,
    DateTime? acceptedAt,
    DateTime? readyAt,
    DateTime? outForDeliveryAt,
    DateTime? deliveredAt,
    String? restaurantId,
    String? assignedDriverId,
    // New fields from API
    @Default('FOOD') String orderType,
    OrderRestaurantModel? restaurant,
    OrderCouponModel? coupon,
    OrderAddressModel? pickupAddress,
    OrderAddressModel? dropoffAddress,
    String? requestedVehicleType,
    String? requestedDeliveryType,
    OrderDriverModel? driver,
    @Default(false) bool isManual,
  }) = _OrderModel;

  /// Custom fromJson to handle API response format
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Parse items list
    List<OrderItemModel> parseItems(dynamic itemsJson) {
      if (itemsJson == null || itemsJson is! List) return [];
      return itemsJson
          .map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    List<OrderAllowedStatusOption> parseAllowedStatusOptions(dynamic options) {
      if (options is! List) return const [];
      return options
          .whereType<Map<String, dynamic>>()
          .map(OrderAllowedStatusOption.fromJson)
          .toList();
    }

    // Parse new API address format
    OrderAddressModel? parseOrderAddress(dynamic addressJson) {
      if (addressJson is Map<String, dynamic>) {
        return OrderAddressModel.fromJson(addressJson);
      }
      return null;
    }

    // Build legacy address from API response for backward compatibility
    AddressModel parseAddress(dynamic addressJson) {
      if (addressJson is Map<String, dynamic>) {
        // Check if it's new API format with full_address
        if (addressJson['full_address'] != null) {
          return AddressModel(
            street: addressJson['full_address'] as String? ?? 'N/A',
            building: addressJson['house_number'] as String? ?? '',
            city: addressJson['city'] as String?,
            postalCode: addressJson['postal_code'] as String?,
            country: addressJson['country'] as String? ?? 'Austria',
            latitude: _parseDouble(addressJson['lat']),
            longitude: _parseDouble(addressJson['lng']),
          );
        }
        // Legacy format
        return AddressModel(
          street: addressJson['street'] ?? addressJson['address'] ?? '',
          building: addressJson['building'] ?? '',
          apartment: addressJson['apartment'] as String?,
          floor: addressJson['floor'] as String?,
          city: addressJson['city'] as String?,
          postalCode:
              addressJson['postal_code'] ??
              addressJson['postalCode'] as String?,
          latitude: _parseDouble(addressJson['lat'] ?? addressJson['latitude']),
          longitude: _parseDouble(
            addressJson['lng'] ?? addressJson['longitude'],
          ),
        );
      }
      // If address is just an ID, return empty address
      return const AddressModel(street: 'N/A', building: 'N/A');
    }

    // Parse customer name - from dropoff_address label or nested customer object
    String parseCustomerName(Map<String, dynamic> json) {
      // Try dropoff_address label first (new API format: "Customer: abdulelah")
      if (json['dropoff_address'] is Map<String, dynamic>) {
        final dropoff = json['dropoff_address'] as Map<String, dynamic>;
        final label = dropoff['label'] as String?;
        if (label != null && label.startsWith('Customer: ')) {
          return label.replaceFirst('Customer: ', '');
        }
      }
      if (json['customer_name'] != null) return json['customer_name'] as String;
      if (json['customerName'] != null) return json['customerName'] as String;
      // Handle nested customer object
      if (json['customer'] is Map<String, dynamic>) {
        final customer = json['customer'] as Map<String, dynamic>;
        return customer['name'] ??
            customer['full_name'] ??
            customer['first_name'] ??
            'Customer';
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
        return customer['phone_number']?.toString() ??
            customer['phone']?.toString() ??
            '';
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

    // Parse restaurant - can be nested object or just ID
    OrderRestaurantModel? parseRestaurant(dynamic restaurantJson) {
      if (restaurantJson is Map<String, dynamic>) {
        return OrderRestaurantModel.fromJson(restaurantJson);
      }
      return null;
    }

    // Parse coupon
    OrderCouponModel? parseCoupon(dynamic couponJson) {
      if (couponJson is Map<String, dynamic>) {
        return OrderCouponModel.fromJson(couponJson);
      }
      return null;
    }

    // Parse driver
    OrderDriverModel? parseDriver(dynamic driverJson) {
      if (driverJson is Map<String, dynamic>) {
        return OrderDriverModel.fromJson(driverJson);
      }
      return null;
    }

    // Get restaurant ID from nested object or direct field
    String? getRestaurantId(Map<String, dynamic> json) {
      if (json['restaurant'] is Map<String, dynamic>) {
        return (json['restaurant'] as Map<String, dynamic>)['id']?.toString();
      }
      return (json['restaurant'] ??
              json['restaurant_id'] ??
              json['restaurantId'])
          ?.toString();
    }

    // Get driver ID from nested object or direct field
    String? getDriverId(Map<String, dynamic> json) {
      if (json['driver'] is Map<String, dynamic>) {
        return (json['driver'] as Map<String, dynamic>)['id']?.toString();
      }
      return json['assigned_driver_id']?.toString() ??
          json['assignedDriverId']?.toString();
    }

    return OrderModel(
      id: json['id']?.toString() ?? '',
      customerName: parseCustomerName(json),
      phoneNumber: parsePhoneNumber(json),
      countryCode: parseCountryCode(json),
      address: parseAddress(
        json['dropoff_address'] ?? json['delivery_address'] ?? json['address'],
      ),
      items: parseItems(json['items'] ?? json['order_items']),
      subtotal:
          double.tryParse(
            json['subtotal_amount']?.toString() ??
                json['subtotal']?.toString() ??
                '0',
          ) ??
          0.0,
      deliveryFee:
          double.tryParse(
            json['delivery_fee']?.toString() ??
                json['deliveryFee']?.toString() ??
                '0',
          ) ??
          0.0,
      discountAmount:
          double.tryParse(
            json['discount_amount']?.toString() ??
                json['discountAmount']?.toString() ??
                '0',
          ) ??
          0.0,
      tips:
          double.tryParse(
            json['tip']?.toString() ?? json['tips']?.toString() ?? '0',
          ) ??
          0.0,
      total:
          double.tryParse(
            json['total_amount']?.toString() ??
                json['total']?.toString() ??
                '0',
          ) ??
          0.0,
      isPaid: json['is_paid'] ?? json['isPaid'] ?? json['paid'] ?? false,
      status:
          orderStatusFromApi(json['status'] as String?) ??
          OrderStatusEnum.pending,
      hasAllowedStatusOptions:
          json.containsKey('allowed_status_options') ||
          json.containsKey('allowedStatusOptions'),
      allowedStatusOptions: parseAllowedStatusOptions(
        json['allowed_status_options'] ?? json['allowedStatusOptions'],
      ),
      notes: (json['notes'] ?? json['delivery_instructions']) as String?,
      rejectionReason:
          json['rejection_reason'] ?? json['rejectionReason'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : (json['createdAt'] != null
                ? DateTime.parse(json['createdAt'] as String)
                : DateTime.now()),
      acceptedAt: json['accepted_at'] != null
          ? DateTime.parse(json['accepted_at'] as String)
          : null,
      readyAt: json['ready_at'] != null
          ? DateTime.parse(json['ready_at'] as String)
          : null,
      outForDeliveryAt: json['out_for_delivery_at'] != null
          ? DateTime.parse(json['out_for_delivery_at'] as String)
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'] as String)
          : null,
      restaurantId: getRestaurantId(json),
      assignedDriverId: getDriverId(json),
      // New fields
      orderType: json['order_type'] as String? ?? 'FOOD',
      restaurant: parseRestaurant(json['restaurant']),
      coupon: parseCoupon(json['coupon']),
      pickupAddress: parseOrderAddress(json['pickup_address']),
      dropoffAddress: parseOrderAddress(json['dropoff_address']),
      requestedVehicleType: json['requested_vehicle_type'] as String?,
      requestedDeliveryType: json['requested_delivery_type'] as String?,
      driver: parseDriver(json['driver']),
      isManual: json['is_manual'] as bool? ?? false,
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
      status != OrderStatusEnum.restaurantDelivered &&
      status != OrderStatusEnum.expired &&
      status != OrderStatusEnum.rejected &&
      status != OrderStatusEnum.cancelled;

  /// Check if order is in "new/pending" state
  bool get isNew =>
      status == OrderStatusEnum.pending ||
      status == OrderStatusEnum.searchingForDriver;

  /// Check if order is completed
  bool get isCompleted =>
      status == OrderStatusEnum.delivered ||
      status == OrderStatusEnum.restaurantDelivered ||
      status == OrderStatusEnum.expired ||
      status == OrderStatusEnum.rejected ||
      status == OrderStatusEnum.cancelled;

  OrderStatusEnum? get preferredAllowedNextStatus {
    for (final option in allowedStatusOptions) {
      final status = option.status;
      if (status == null) continue;
      if (status == OrderStatusEnum.cancelled ||
          status == OrderStatusEnum.rejected ||
          status == OrderStatusEnum.expired) {
        continue;
      }
      return status;
    }
    return null;
  }

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
