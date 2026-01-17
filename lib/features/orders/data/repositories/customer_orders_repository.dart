/// Customer orders repository interface and implementation
library;

import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../datasources/customer_orders_remote_data_source.dart';
import '../models/food_checkout_model.dart';
import '../models/order_model.dart';

/// Result type for repository methods
typedef CustomerOrdersResult<T> = ({Failure? failure, T? data});

/// Customer orders repository interface
abstract class CustomerOrdersRepository {
  /// Create a food order
  Future<CustomerOrdersResult<OrderModel>> createFoodOrder(FoodCheckoutRequest request);

  /// Get customer orders list with pagination
  Future<CustomerOrdersResult<List<OrderModel>>> getCustomerOrders({int page = 1});

  /// Get customer order by ID
  Future<CustomerOrdersResult<OrderModel>> getCustomerOrderById(String id);

  /// Update an order
  Future<CustomerOrdersResult<OrderModel>> updateOrder(String id, OrderUpdateRequest request);

  /// Partial update an order
  Future<CustomerOrdersResult<OrderModel>> patchOrder(String id, Map<String, dynamic> data);

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

  @override
  Future<CustomerOrdersResult<OrderModel>> createFoodOrder(FoodCheckoutRequest request) async {
    try {
      final order = await _remoteDataSource.createFoodOrder(request);
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
        failure: ServerFailure(message: 'An unexpected error occurred: $e'),
        data: null,
      );
    }
  }

  @override
  Future<CustomerOrdersResult<List<OrderModel>>> getCustomerOrders({int page = 1}) async {
    try {
      final orders = await _remoteDataSource.getCustomerOrders(page: page);
      return (failure: null, data: orders);
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
  Future<CustomerOrdersResult<OrderModel>> getCustomerOrderById(String id) async {
    try {
      final order = await _remoteDataSource.getCustomerOrderById(id);
      return (failure: null, data: order);
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
  Future<CustomerOrdersResult<OrderModel>> updateOrder(String id, OrderUpdateRequest request) async {
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
  Future<CustomerOrdersResult<OrderModel>> patchOrder(String id, Map<String, dynamic> data) async {
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
  Future<CustomerOrdersResult<OrderModel>> getOrderById(String id) async {
    try {
      final order = await _remoteDataSource.getOrderById(id);
      return (failure: null, data: order);
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
