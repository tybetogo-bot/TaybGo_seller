/// Earnings data models
library;

/// Summary totals for earnings
class EarningsSummary {
  final int totalOrders;
  final double totalEarnings;
  final double grossSubtotal;
  final double totalDiscounts;

  const EarningsSummary({
    required this.totalOrders,
    required this.totalEarnings,
    required this.grossSubtotal,
    required this.totalDiscounts,
  });

  factory EarningsSummary.fromJson(Map<String, dynamic> json) {
    return EarningsSummary(
      totalOrders: json['total_orders'] as int? ?? 0,
      totalEarnings: _parseDouble(json['total_earnings']),
      grossSubtotal: _parseDouble(json['gross_subtotal']),
      totalDiscounts: _parseDouble(json['total_discounts']),
    );
  }
}

/// Single earning entry (one delivered/completed order)
class EarningItem {
  final int orderId;
  final int restaurantId;
  final String restaurantName;
  final String paymentType;
  final bool isPaid;
  final String status;
  final DateTime? earnedAt;
  final double subtotalAmount;
  final double discountAmount;
  final double earningAmount;
  final bool couponApplied;

  const EarningItem({
    required this.orderId,
    required this.restaurantId,
    required this.restaurantName,
    required this.paymentType,
    required this.isPaid,
    required this.status,
    this.earnedAt,
    required this.subtotalAmount,
    required this.discountAmount,
    required this.earningAmount,
    required this.couponApplied,
  });

  factory EarningItem.fromJson(Map<String, dynamic> json) {
    return EarningItem(
      orderId: json['order_id'] as int? ?? 0,
      restaurantId: json['restaurant_id'] as int? ?? 0,
      restaurantName: json['restaurant_name'] as String? ?? '',
      paymentType: json['payment_type'] as String? ?? 'CASH',
      isPaid: json['is_paid'] as bool? ?? false,
      status: json['status'] as String? ?? 'PENDING',
      earnedAt: json['earned_at'] != null
          ? DateTime.tryParse(json['earned_at'] as String)
          : null,
      subtotalAmount: _parseDouble(json['subtotal_amount']),
      discountAmount: _parseDouble(json['discount_amount']),
      earningAmount: _parseDouble(json['earning_amount']),
      couponApplied: json['coupon_applied'] as bool? ?? false,
    );
  }
}

/// Paginated earnings response with summary
class EarningsResponse {
  final int count;
  final String? next;
  final String? previous;
  final EarningsSummary summary;
  final List<EarningItem> results;

  const EarningsResponse({
    required this.count,
    this.next,
    this.previous,
    required this.summary,
    required this.results,
  });

  factory EarningsResponse.fromJson(Map<String, dynamic> json) {
    return EarningsResponse(
      count: json['count'] as int? ?? 0,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      summary: EarningsSummary.fromJson(
        json['summary'] as Map<String, dynamic>? ?? {},
      ),
      results: (json['results'] as List<dynamic>?)
              ?.map(
                (e) => EarningItem.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  bool get hasMore => next != null;
}

/// Helper to safely parse a numeric string or number into double
double _parseDouble(dynamic value) {
  if (value == null || value == '') return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
