/// Earnings repository interface and implementation
library;

import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../datasources/earnings_remote_data_source.dart';
import '../models/earning_model.dart';

/// Result type for repository methods
typedef EarningsResult<T> = ({Failure? failure, T? data});

/// Earnings repository interface
abstract class EarningsRepository {
  /// Get earnings with optional filters
  Future<EarningsResult<EarningsResponse>> getEarnings({
    int page = 1,
    int? pageSize,
    int? restaurantId,
    String? from,
    String? to,
    bool? isPaid,
    bool? couponApplied,
    String? paymentType,
    String? ordering,
  });
}

/// Implementation of earnings repository
class EarningsRepositoryImpl implements EarningsRepository {
  EarningsRepositoryImpl({
    required EarningsDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final EarningsDataSource _remoteDataSource;

  @override
  Future<EarningsResult<EarningsResponse>> getEarnings({
    int page = 1,
    int? pageSize,
    int? restaurantId,
    String? from,
    String? to,
    bool? isPaid,
    bool? couponApplied,
    String? paymentType,
    String? ordering,
  }) async {
    try {
      final response = await _remoteDataSource.getEarnings(
        page: page,
        pageSize: pageSize,
        restaurantId: restaurantId,
        from: from,
        to: to,
        isPaid: isPaid,
        couponApplied: couponApplied,
        paymentType: paymentType,
        ordering: ordering,
      );
      return (failure: null, data: response);
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
        failure: ServerFailure(message: 'An unexpected error occurred: $e'),
        data: null,
      );
    }
  }
}
