/// Coupons repository interface and implementation
library;

import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../datasources/coupons_remote_data_source.dart';
import '../models/coupon_model.dart';

/// Result type for repository methods
typedef CouponsResult<T> = ({Failure? failure, T? data});

/// Coupons repository interface
abstract class CouponsRepository {
  /// Get coupons list with optional filters
  Future<CouponsResult<List<CouponModel>>> getCoupons({
    required String restaurantId,
    int page = 1,
    bool? active,
    String? code,
  });

  /// Get single coupon by ID
  Future<CouponsResult<CouponModel>> getCouponById(String id);

  /// Create a new coupon
  Future<CouponsResult<CouponModel>> createCoupon({
    required String restaurantId,
    required Map<String, dynamic> data,
  });

  /// Partial update coupon
  Future<CouponsResult<CouponModel>> patchCoupon(
    String id,
    Map<String, dynamic> data,
  );

  /// Delete a coupon
  Future<CouponsResult<void>> deleteCoupon(String id);
}

/// Implementation of coupons repository
class CouponsRepositoryImpl implements CouponsRepository {
  CouponsRepositoryImpl({
    required CouponsDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final CouponsDataSource _remoteDataSource;

  @override
  Future<CouponsResult<List<CouponModel>>> getCoupons({
    required String restaurantId,
    int page = 1,
    bool? active,
    String? code,
  }) async {
    try {
      final coupons = await _remoteDataSource.getCoupons(
        restaurantId: restaurantId,
        page: page,
        active: active,
        code: code,
      );
      return (failure: null, data: coupons);
    } on DioException catch (e) {
      final apiError = e.error;
      if (apiError is ApiException) {
        return (
          failure: ServerFailure(message: apiError.message),
          data: null,
        );
      }
      return (
        failure: const NetworkFailure(message: 'Network error occurred'),
        data: null,
      );
    } on NetworkException catch (e) {
      return (failure: NetworkFailure(message: e.message), data: null);
    } catch (e) {
      return (
        failure: const ServerFailure(message: 'An unexpected error occurred'),
        data: null,
      );
    }
  }

  @override
  Future<CouponsResult<CouponModel>> getCouponById(String id) async {
    try {
      final coupon = await _remoteDataSource.getCouponById(id);
      return (failure: null, data: coupon);
    } on DioException catch (e) {
      final apiError = e.error;
      if (apiError is ApiException) {
        return (
          failure: ServerFailure(message: apiError.message),
          data: null,
        );
      }
      return (
        failure: const NetworkFailure(message: 'Network error occurred'),
        data: null,
      );
    } catch (e) {
      return (
        failure: const ServerFailure(message: 'An unexpected error occurred'),
        data: null,
      );
    }
  }

  @override
  Future<CouponsResult<CouponModel>> createCoupon({
    required String restaurantId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final coupon = await _remoteDataSource.createCoupon(
        restaurantId: restaurantId,
        data: data,
      );
      return (failure: null, data: coupon);
    } on DioException catch (e) {
      final apiError = e.error;
      if (apiError is ApiException) {
        return (
          failure: ValidationFailure(message: apiError.message),
          data: null,
        );
      }
      return (
        failure: const NetworkFailure(message: 'Network error occurred'),
        data: null,
      );
    } catch (e) {
      return (
        failure: const ServerFailure(message: 'An unexpected error occurred'),
        data: null,
      );
    }
  }

  @override
  Future<CouponsResult<CouponModel>> patchCoupon(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final coupon = await _remoteDataSource.patchCoupon(id, data);
      return (failure: null, data: coupon);
    } on DioException catch (e) {
      final apiError = e.error;
      if (apiError is ApiException) {
        return (
          failure: ValidationFailure(message: apiError.message),
          data: null,
        );
      }
      return (
        failure: const NetworkFailure(message: 'Network error occurred'),
        data: null,
      );
    } catch (e) {
      return (
        failure: const ServerFailure(message: 'An unexpected error occurred'),
        data: null,
      );
    }
  }

  @override
  Future<CouponsResult<void>> deleteCoupon(String id) async {
    try {
      await _remoteDataSource.deleteCoupon(id);
      return (failure: null, data: null);
    } on DioException catch (e) {
      final apiError = e.error;
      if (apiError is ApiException) {
        return (
          failure: ServerFailure(message: apiError.message),
          data: null,
        );
      }
      return (
        failure: const NetworkFailure(message: 'Network error occurred'),
        data: null,
      );
    } catch (e) {
      return (
        failure: const ServerFailure(message: 'An unexpected error occurred'),
        data: null,
      );
    }
  }
}
