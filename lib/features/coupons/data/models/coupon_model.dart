import 'package:freezed_annotation/freezed_annotation.dart';

part 'coupon_model.freezed.dart';

/// Coupon model for discounts and promotions
@freezed
sealed class CouponModel with _$CouponModel {
  const factory CouponModel({
    required String id,
    required String title,
    String? description,
    required String code,
    required double percentDiscount,
    @Default(0.0) double minimumOrderPrice,
    int? maxTotalUsage,
    int? maxUsagePerUser,
    @Default(0) int currentUsageCount,
    required DateTime startDate,
    required DateTime endDate,
    @Default(true) bool isActive,
    String? restaurantId,
    String? titleAr,
    String? titleDe,
    String? titleFr,
    String? descriptionAr,
    String? descriptionDe,
    String? descriptionFr,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _CouponModel;

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      code: json['code'] as String? ?? '',
      percentDiscount:
          double.tryParse(
            (json['percentage'] ?? json['percent_discount'] ?? json['percentDiscount'] ?? '0')
                .toString(),
          ) ??
          0.0,
      minimumOrderPrice:
          double.tryParse(
            (json['min_price'] ?? json['minimum_order_price'] ?? json['minimumOrderPrice'] ?? '0')
                .toString(),
          ) ??
          0.0,
      maxTotalUsage: int.tryParse(
        (json['max_total_users'] ?? json['max_total_usage'] ?? json['maxTotalUsage'] ?? '').toString(),
      ),
      maxUsagePerUser: int.tryParse(
        (json['max_per_customer'] ?? json['max_usage_per_user'] ?? json['maxUsagePerUser'] ?? '').toString(),
      ),
      currentUsageCount:
          (json['current_usage_count'] ?? json['currentUsageCount'] ?? 0)
              as int,
      startDate:
          DateTime.tryParse(
            (json['start_date'] ?? json['startDate'] ?? '').toString(),
          ) ??
          DateTime.now(),
      endDate:
          DateTime.tryParse(
            (json['end_date'] ?? json['endDate'] ?? '').toString(),
          ) ??
          DateTime.now(),
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      restaurantId: (json['restaurant_id'] ?? json['restaurantId'])?.toString(),
      titleAr: json['title_ar'] as String?,
      titleDe: json['title_de'] as String?,
      titleFr: json['title_fr'] as String?,
      descriptionAr: json['description_ar'] as String?,
      descriptionDe: json['description_de'] as String?,
      descriptionFr: json['description_fr'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }
}

/// Extension for CouponModel with utility methods
extension CouponModelExtension on CouponModel {
  /// Check if coupon is currently valid
  bool get isValid {
    final now = DateTime.now();
    return isActive &&
        now.isAfter(startDate) &&
        now.isBefore(endDate) &&
        !hasReachedMaxUsage;
  }

  /// Check if coupon has reached max usage
  bool get hasReachedMaxUsage =>
      maxTotalUsage != null && currentUsageCount >= maxTotalUsage!;

  /// Check if coupon is expired
  bool get isExpired => DateTime.now().isAfter(endDate);

  /// Check if coupon is not yet active
  bool get isNotYetActive => DateTime.now().isBefore(startDate);

  /// Get remaining uses (if max is set)
  int? get remainingUses =>
      maxTotalUsage != null ? maxTotalUsage! - currentUsageCount : null;

  /// Get days until expiration
  int get daysUntilExpiration {
    final now = DateTime.now();
    return endDate.difference(now).inDays;
  }

  /// Calculate discount amount for a given order total
  double calculateDiscount(double orderTotal) {
    if (orderTotal < minimumOrderPrice) return 0.0;
    return orderTotal * (percentDiscount / 100);
  }

  /// Get localized title
  String getLocalizedTitle(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return titleAr ?? title;
      case 'de':
        return titleDe ?? title;
      case 'fr':
        return titleFr ?? title;
      default:
        return title;
    }
  }

  /// Get localized description
  String? getLocalizedDescription(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return descriptionAr ?? description;
      case 'de':
        return descriptionDe ?? description;
      case 'fr':
        return descriptionFr ?? description;
      default:
        return description;
    }
  }

  /// Get formatted discount string
  String get discountText => '${percentDiscount.toStringAsFixed(0)}% off';

  /// Get validity status text
  String get statusText {
    if (isExpired) return 'Expired';
    if (isNotYetActive) return 'Not yet active';
    if (hasReachedMaxUsage) return 'Max usage reached';
    if (!isActive) return 'Inactive';
    return 'Active';
  }
}

/// Coupon usage tracking model
@freezed
sealed class CouponUsage with _$CouponUsage {
  const factory CouponUsage({
    required String id,
    required String couponId,
    required String userId,
    required String orderId,
    required double discountAmount,
    required DateTime usedAt,
  }) = _CouponUsage;

  factory CouponUsage.fromJson(Map<String, dynamic> json) {
    return CouponUsage(
      id: json['id']?.toString() ?? '',
      couponId: (json['coupon_id'] ?? json['couponId'])?.toString() ?? '',
      userId: (json['user_id'] ?? json['userId'])?.toString() ?? '',
      orderId: (json['order_id'] ?? json['orderId'])?.toString() ?? '',
      discountAmount:
          double.tryParse(
            (json['discount_amount'] ?? json['discountAmount'] ?? '0')
                .toString(),
          ) ??
          0.0,
      usedAt:
          DateTime.tryParse(
            (json['used_at'] ?? json['usedAt'] ?? '').toString(),
          ) ??
          DateTime.now(),
    );
  }
}
