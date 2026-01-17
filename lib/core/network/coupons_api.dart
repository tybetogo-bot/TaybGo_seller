/// Coupons API service for seller coupon management
library;

import 'package:dio/dio.dart';

import '../../features/coupons/data/models/coupon_model.dart';
import 'restaurant_api.dart';

/// Coupons API service
class CouponsApi {
  final Dio _dio;

  CouponsApi(this._dio);

  /// List seller's coupons
  /// GET /api/seller/coupons/
  Future<PaginatedResponse<CouponModel>> getCoupons({
    required String restaurantId,
    int page = 1,
    bool? active,
    String? code,
  }) async {
    final queryParams = <String, dynamic>{
      'restaurant_id': restaurantId,
      'page': page,
    };
    if (active != null) queryParams['active'] = active;
    if (code != null) queryParams['code'] = code;

    final response = await _dio.get(
      '/api/seller/coupons/',
      queryParameters: queryParams,
    );
    return PaginatedResponse.fromJson(
      response.data as Map<String, dynamic>,
      CouponModel.fromJson,
    );
  }

  /// Get coupon details
  /// GET /api/seller/coupons/{id}/
  Future<CouponModel> getCouponById(String id) async {
    final response = await _dio.get('/api/seller/coupons/$id/');
    return CouponModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Create coupon
  /// POST /api/seller/coupons/
  Future<CouponModel> createCoupon({
    required String restaurantId,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dio.post(
      '/api/seller/coupons/',
      data: data,
      queryParameters: {'restaurant_id': restaurantId},
    );
    return CouponModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Partial update coupon
  /// PATCH /api/seller/coupons/{id}/
  Future<CouponModel> patchCoupon(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.patch(
      '/api/seller/coupons/$id/',
      data: data,
    );
    return CouponModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Delete coupon
  /// DELETE /api/seller/coupons/{id}/
  Future<void> deleteCoupon(String id) async {
    await _dio.delete('/api/seller/coupons/$id/');
  }
}
