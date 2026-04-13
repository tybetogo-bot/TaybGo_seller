/// Earnings API service for seller earnings management
library;

import 'package:dio/dio.dart';

import '../../features/earnings/data/models/earning_model.dart';
import '../config/constants.dart';

/// Earnings API service
class EarningsApi {
  final Dio _dio;

  EarningsApi(this._dio);

  /// List seller earnings with optional filters
  /// GET /api/seller/earnings/
  Future<EarningsResponse> getEarnings({
    int page = 1,
    int? pageSize,
    int? restaurantId,
    String? from,
    String? to,
    bool? isPaid,
    bool? couponApplied,
    String? paymentType,
    String? minEarning,
    String? maxEarning,
    String? ordering,
  }) async {
    final queryParams = <String, dynamic>{'page': page};
    if (pageSize != null) queryParams['page_size'] = pageSize;
    if (restaurantId != null) queryParams['restaurant_id'] = restaurantId;
    if (from != null) queryParams['from'] = from;
    if (to != null) queryParams['to'] = to;
    if (isPaid != null) queryParams['is_paid'] = isPaid;
    if (couponApplied != null) queryParams['coupon_applied'] = couponApplied;
    if (paymentType != null) queryParams['payment_type'] = paymentType;
    if (minEarning != null) queryParams['min_earning'] = minEarning;
    if (maxEarning != null) queryParams['max_earning'] = maxEarning;
    if (ordering != null) queryParams['ordering'] = ordering;

    final response = await _dio.get(
      ApiEndpoints.sellerEarnings,
      queryParameters: queryParams,
    );

    return EarningsResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
