/// Customer orders repository interface and implementation
library;

import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/i18n/i18n.dart';
import '../datasources/customer_orders_remote_data_source.dart';
import '../models/food_checkout_model.dart';
import '../models/order_model.dart';

/// Result type for repository methods
typedef CustomerOrdersResult<T> = ({Failure? failure, T? data});

/// Customer orders repository interface
abstract class CustomerOrdersRepository {
  /// Create a food order
  Future<CustomerOrdersResult<OrderModel>> createFoodOrder(
    FoodCheckoutRequest request,
  );

  /// Get customer orders list with pagination
  Future<CustomerOrdersResult<List<OrderModel>>> getCustomerOrders({
    int page = 1,
  });

  /// Get customer order by ID
  Future<CustomerOrdersResult<OrderModel>> getCustomerOrderById(String id);

  /// Update an order
  Future<CustomerOrdersResult<OrderModel>> updateOrder(
    String id,
    OrderUpdateRequest request,
  );

  /// Partial update an order
  Future<CustomerOrdersResult<OrderModel>> patchOrder(
    String id,
    Map<String, dynamic> data,
  );

  /// Delete an order
  Future<CustomerOrdersResult<void>> deleteOrder(String id);

  /// Get order by ID (generic)
  Future<CustomerOrdersResult<OrderModel>> getOrderById(String id);
}

/// Implementation of customer orders repository
class CustomerOrdersRepositoryImpl implements CustomerOrdersRepository {
  CustomerOrdersRepositoryImpl({
    required CustomerOrdersDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final CustomerOrdersDataSource _remoteDataSource;

  void _log(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: 'CustomerOrdersRepository',
        error: error,
        stackTrace: stackTrace,
      );
      // ignore: avoid_print
      print('[CustomerOrdersRepository] $message');
      if (error != null) {
        // ignore: avoid_print
        print('[CustomerOrdersRepository] Error: $error');
      }
    }
  }

  String _extractErrorMessage(DioException e) {
    final response = e.response;
    if (response != null) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        // Try common error field names
        final errorMsg =
            data['detail'] ??
            data['message'] ??
            data['error'] ??
            data['non_field_errors']?.toString() ??
            data.toString();
        return errorMsg.toString();
      }
      return data?.toString() ?? e.message ?? 'Unknown error';
    }
    return e.message ?? 'Network error occurred';
  }

  bool _isRoleConflict({int? statusCode, String? message}) {
    final normalizedMessage = message?.toLowerCase() ?? '';

    if (statusCode == 409) return true;

    return normalizedMessage.contains('another role') ||
        normalizedMessage.contains('another app') ||
        normalizedMessage.contains('account type') ||
        (normalizedMessage.contains('already') &&
            normalizedMessage.contains('registered'));
  }

  @override
  Future<CustomerOrdersResult<OrderModel>> createFoodOrder(
    FoodCheckoutRequest request,
  ) async {
    _log('Creating food order...');
    _log('Request data: ${request.toJson()}');

    try {
      final order = await _remoteDataSource.createFoodOrder(request);
      _log('Food order created successfully with ID: ${order.id}');
      return (failure: null, data: order);
    } on DioException catch (e, stackTrace) {
      _log('DioException in createFoodOrder', error: e, stackTrace: stackTrace);
      _log('Status code: ${e.response?.statusCode}');
      _log('Response data: ${e.response?.data}');
      _log('Error type: ${e.type}');

      final errorMessage = _extractErrorMessage(e);
      _log('Extracted error message: $errorMessage');

      final apiError = e.error;
      if (_isRoleConflict(
        statusCode: e.response?.statusCode,
        message: errorMessage,
      )) {
        return (
          failure: ValidationFailure(
            message: 'errors.auth.phoneAlreadyRegistered'.tr,
          ),
          data: null,
        );
      }

      if (apiError is ApiException) {
        _log('ApiException: ${apiError.message}');
        return (
          failure: ValidationFailure(message: apiError.message),
          data: null,
        );
      }

      // Return detailed error message from API response
      return (failure: ServerFailure(message: errorMessage), data: null);
    } catch (e, stackTrace) {
      _log(
        'Unexpected error in createFoodOrder',
        error: e,
        stackTrace: stackTrace,
      );
      return (
        failure: ServerFailure(message: 'An unexpected error occurred: $e'),
        data: null,
      );
    }
  }

  @override
  Future<CustomerOrdersResult<List<OrderModel>>> getCustomerOrders({
    int page = 1,
  }) async {
    try {
      final orders = await _remoteDataSource.getCustomerOrders(page: page);
      return (failure: null, data: orders);
    } on DioException catch (e) {
      final apiError = e.error;
      if (apiError is ApiException) {
        return (failure: ServerFailure(message: apiError.message), data: null);
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
  Future<CustomerOrdersResult<OrderModel>> getCustomerOrderById(
    String id,
  ) async {
    try {
      final order = await _remoteDataSource.getCustomerOrderById(id);
      return (failure: null, data: order);
    } on DioException catch (e) {
      final apiError = e.error;
      if (apiError is ApiException) {
        return (failure: ServerFailure(message: apiError.message), data: null);
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
  Future<CustomerOrdersResult<OrderModel>> updateOrder(
    String id,
    OrderUpdateRequest request,
  ) async {
    try {
      final order = await _remoteDataSource.updateOrder(id, request);
      return (failure: null, data: order);
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
  Future<CustomerOrdersResult<OrderModel>> patchOrder(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final order = await _remoteDataSource.patchOrder(id, data);
      return (failure: null, data: order);
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
  Future<CustomerOrdersResult<void>> deleteOrder(String id) async {
    try {
      await _remoteDataSource.deleteOrder(id);
      return (failure: null, data: null);
    } on DioException catch (e) {
      final apiError = e.error;
      if (apiError is ApiException) {
        return (failure: ServerFailure(message: apiError.message), data: null);
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
  Future<CustomerOrdersResult<OrderModel>> getOrderById(String id) async {
    try {
      final order = await _remoteDataSource.getOrderById(id);
      return (failure: null, data: order);
    } on DioException catch (e) {
      final apiError = e.error;
      if (apiError is ApiException) {
        return (failure: ServerFailure(message: apiError.message), data: null);
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
