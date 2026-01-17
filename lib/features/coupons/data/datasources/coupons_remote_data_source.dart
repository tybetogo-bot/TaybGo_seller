/// Remote data source for coupons
library;

import '../../../../core/network/coupons_api.dart';
import '../models/coupon_model.dart';

/// Abstract interface for coupons data source
abstract class CouponsDataSource {
  /// Get coupons list with optional filters
  Future<List<CouponModel>> getCoupons({
    required String restaurantId,
    int page = 1,
    bool? active,
    String? code,
  });

  /// Get single coupon by ID
  Future<CouponModel> getCouponById(String id);

  /// Create a new coupon
  Future<CouponModel> createCoupon({
    required String restaurantId,
    required Map<String, dynamic> data,
  });

  /// Partial update coupon
  Future<CouponModel> patchCoupon(String id, Map<String, dynamic> data);

  /// Delete a coupon
  Future<void> deleteCoupon(String id);
}

/// Remote data source implementation using CouponsApi
class CouponsRemoteDataSource implements CouponsDataSource {
  CouponsRemoteDataSource(this._api);

  final CouponsApi _api;

  @override
  Future<List<CouponModel>> getCoupons({
    required String restaurantId,
    int page = 1,
    bool? active,
    String? code,
  }) async {
    final response = await _api.getCoupons(
      restaurantId: restaurantId,
      page: page,
      active: active,
      code: code,
    );
    return response.results;
  }

  @override
  Future<CouponModel> getCouponById(String id) async {
    return await _api.getCouponById(id);
  }

  @override
  Future<CouponModel> createCoupon({
    required String restaurantId,
    required Map<String, dynamic> data,
  }) async {
    return await _api.createCoupon(
      restaurantId: restaurantId,
      data: data,
    );
  }

  @override
  Future<CouponModel> patchCoupon(String id, Map<String, dynamic> data) async {
    return await _api.patchCoupon(id, data);
  }

  @override
  Future<void> deleteCoupon(String id) async {
    return await _api.deleteCoupon(id);
  }
}
