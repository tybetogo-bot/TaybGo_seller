import 'package:freezed_annotation/freezed_annotation.dart';

part 'restaurant_model.freezed.dart';

/// Restaurant status enum
enum RestaurantStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('ACTIVE')
  active,
  @JsonValue('INACTIVE')
  inactive,
}

/// Restaurant address model with full location data
@freezed
sealed class RestaurantAddressModel with _$RestaurantAddressModel {
  const factory RestaurantAddressModel({
    String? id,
    String? label,
    double? lat,
    double? lng,
    String? fullAddress,
    String? streetName,
    String? houseNumber,
    String? city,
    String? postalCode,
    String? country,
    DateTime? createdAt,
  }) = _RestaurantAddressModel;

  factory RestaurantAddressModel.fromJson(Map<String, dynamic> json) {
    return RestaurantAddressModel(
      id: json['id']?.toString(),
      label: json['label'] as String?,
      lat: _parseDouble(json['lat']),
      lng: _parseDouble(json['lng']),
      fullAddress: (json['full_address'] ?? json['fullAddress']) as String?,
      streetName: (json['street_name'] ?? json['streetName']) as String?,
      houseNumber: (json['house_number'] ?? json['houseNumber']) as String?,
      city: json['city'] as String?,
      postalCode: (json['postal_code'] ?? json['postalCode']) as String?,
      country: json['country'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

/// Today's statistics for a restaurant
@freezed
sealed class RestaurantStats with _$RestaurantStats {
  const factory RestaurantStats({
    @Default(0) int pendingOrders,
    @Default(0) int totalOrders,
    @Default(0.0) double totalRevenue,
  }) = _RestaurantStats;

  factory RestaurantStats.fromJson(Map<String, dynamic> json) {
    return RestaurantStats(
      pendingOrders: (json['pending_orders'] as num?)?.toInt() ?? 0,
      totalOrders: (json['total_orders'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Single opening interval for a restaurant working day.
class WorkHourPeriod {
  const WorkHourPeriod({required this.open, required this.close});

  final String open;
  final String close;

  factory WorkHourPeriod.fromJson(Map<String, dynamic> json) {
    return WorkHourPeriod(
      open: json['open'] as String? ?? '',
      close: json['close'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'open': open, 'close': close};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkHourPeriod &&
          runtimeType == other.runtimeType &&
          open == other.open &&
          close == other.close;

  @override
  int get hashCode => Object.hash(open, close);
}

/// Restaurant model
@freezed
sealed class RestaurantModel with _$RestaurantModel {
  const factory RestaurantModel({
    required String id,
    required String name,
    String? description,
    String? phone,
    String? email,
    String? address,
    String? city,
    String? country,
    String? imageUrl,
    String? logoUrl,
    @Default(RestaurantStatus.pending) RestaurantStatus status,
    @Default(false) bool isOpen,
    String? openingHours,
    String? closingHours,
    @Default({}) Map<String, List<WorkHourPeriod>> workHours,
    bool? deliveryEnabled,
    @Default(0.0) double deliveryFee,
    @Default(0.0) double minimumOrder,
    @Default(30) int estimatedDeliveryTime,
    @Default([]) List<String> cuisineTypes,
    @Default(0.0) double rating,
    @Default(0) int totalReviews,
    DateTime? createdAt,
    DateTime? updatedAt,
    // Today's stats (returned from API)
    RestaurantStats? todayStats,
    // Direct location coordinates
    double? lat,
    double? lng,
    // Full address object from API
    RestaurantAddressModel? addressData,
  }) = _RestaurantModel;

  /// Custom fromJson to handle API response mapping
  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    // Parse status
    RestaurantStatus parseStatus(String? statusStr) {
      if (statusStr == null) return RestaurantStatus.pending;
      switch (statusStr.toUpperCase()) {
        case 'ACTIVE':
          return RestaurantStatus.active;
        case 'INACTIVE':
          return RestaurantStatus.inactive;
        case 'PENDING':
        default:
          return RestaurantStatus.pending;
      }
    }

    // Parse today stats
    RestaurantStats? parseTodayStats(Map<String, dynamic> json) {
      if (json['todayStats'] != null) {
        return RestaurantStats.fromJson(
          json['todayStats'] as Map<String, dynamic>,
        );
      }
      if (json['total_orders_today'] != null) {
        return RestaurantStats(
          pendingOrders: (json['pending_orders_count'] as num?)?.toInt() ?? 0,
          totalOrders: (json['total_orders_today'] as num?)?.toInt() ?? 0,
          totalRevenue:
              (json['total_revenue_today'] as num?)?.toDouble() ?? 0.0,
        );
      }
      return null;
    }

    return RestaurantModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] is String ? json['address'] as String : null,
      city: json['city'] as String?,
      country: json['country'] as String?,
      imageUrl: (json['image_url'] ?? json['imageUrl']) as String?,
      logoUrl: (json['logo'] ?? json['logo_url'] ?? json['logoUrl']) as String?,
      status: parseStatus(json['status'] as String?),
      isOpen: (json['is_open'] ?? json['isOpen'] ?? false) as bool,
      openingHours: (json['opening_hours'] ?? json['openingHours']) as String?,
      closingHours: (json['closing_hours'] ?? json['closingHours']) as String?,
      workHours: _parseWorkHours(json['work_hours'] ?? json['workHours']),
      deliveryEnabled: _parseOptionalBool(
        json['delivery_enabled'] ?? json['deliveryEnabled'],
      ),
      deliveryFee: (json['delivery_fee'] ?? json['deliveryFee'] ?? 0.0) is num
          ? (json['delivery_fee'] ?? json['deliveryFee'] ?? 0.0).toDouble()
          : 0.0,
      minimumOrder:
          (json['minimum_order'] ?? json['minimumOrder'] ?? 0.0) is num
          ? (json['minimum_order'] ?? json['minimumOrder'] ?? 0.0).toDouble()
          : 0.0,
      estimatedDeliveryTime:
          (json['estimated_delivery_time'] ??
                  json['estimatedDeliveryTime'] ??
                  30)
              is num
          ? (json['estimated_delivery_time'] ??
                    json['estimatedDeliveryTime'] ??
                    30)
                .toInt()
          : 30,
      cuisineTypes: (json['cuisine_types'] ?? json['cuisineTypes']) is List
          ? List<String>.from(
              json['cuisine_types'] ?? json['cuisineTypes'] ?? [],
            )
          : [],
      rating: (json['rating'] ?? 0.0) is num
          ? (json['rating'] ?? 0.0).toDouble()
          : 0.0,
      totalReviews: (json['total_reviews'] ?? json['totalReviews'] ?? 0) is num
          ? (json['total_reviews'] ?? json['totalReviews'] ?? 0).toInt()
          : 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : (json['createdAt'] != null
                ? DateTime.tryParse(json['createdAt'] as String)
                : null),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : (json['updatedAt'] != null
                ? DateTime.tryParse(json['updatedAt'] as String)
                : null),
      todayStats: parseTodayStats(json),
      lat: _parseCoordinate(json['lat']),
      lng: _parseCoordinate(json['lng']),
      addressData: json['address'] is Map<String, dynamic>
          ? RestaurantAddressModel.fromJson(
              json['address'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  static double? _parseCoordinate(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static bool? _parseOptionalBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      switch (value.trim().toLowerCase()) {
        case 'true':
        case '1':
        case 'yes':
          return true;
        case 'false':
        case '0':
        case 'no':
          return false;
      }
    }
    return null;
  }

  static Map<String, List<WorkHourPeriod>> _parseWorkHours(dynamic value) {
    if (value is! Map) return const {};

    final parsed = <String, List<WorkHourPeriod>>{};
    for (final entry in value.entries) {
      final day = entry.key.toString().toLowerCase();
      final periods = entry.value;
      if (periods is! List) {
        parsed[day] = const [];
        continue;
      }

      parsed[day] = periods
          .whereType<Map>()
          .map(
            (period) =>
                WorkHourPeriod.fromJson(Map<String, dynamic>.from(period)),
          )
          .toList();
    }
    return parsed;
  }
}

/// Extension for RestaurantModel utilities
extension RestaurantModelExtension on RestaurantModel {
  /// Check if restaurant is active
  bool get isActive => status == RestaurantStatus.active;

  /// Get full address string (prefers addressData if available)
  String get fullAddress {
    // If we have addressData with fullAddress, use it
    if (addressData?.fullAddress != null &&
        addressData!.fullAddress!.isNotEmpty) {
      return addressData!.fullAddress!;
    }

    // If we have addressData, build from components
    if (addressData != null) {
      final parts = <String>[
        if (addressData!.streetName != null) addressData!.streetName!,
        if (addressData!.houseNumber != null) addressData!.houseNumber!,
        if (addressData!.city != null) addressData!.city!,
        if (addressData!.postalCode != null) addressData!.postalCode!,
        if (addressData!.country != null) addressData!.country!,
      ];
      if (parts.isNotEmpty) return parts.join(', ');
    }

    // Fallback to simple address fields
    final parts = <String>[
      if (address != null) address!,
      if (city != null) city!,
      if (country != null) country!,
    ];
    return parts.join(', ');
  }

  /// Check if restaurant has location coordinates
  bool get hasCoordinates => lat != null && lng != null;

  /// Get coordinates as tuple (for map usage)
  (double, double)? get coordinates => hasCoordinates ? (lat!, lng!) : null;

  /// Format rating with stars
  String get formattedRating =>
      '⭐ ${rating.toStringAsFixed(1)} ($totalReviews)';
}
