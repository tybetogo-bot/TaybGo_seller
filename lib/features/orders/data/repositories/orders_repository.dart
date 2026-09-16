/// Orders repository interface and implementation
library;

import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/i18n/i18n.dart';
import '../../../../core/network/orders_api.dart';
import '../datasources/orders_remote_data_source.dart';
import '../models/food_checkout_model.dart';
import '../models/order_model.dart';

/// Result type for repository methods
typedef OrdersResult<T> = ({Failure? failure, T? data});

/// Orders repository interface
abstract class OrdersRepository {
  /// Get orders list with optional filters
  /// Note: API auto-scopes to seller's restaurants
  Future<OrdersResult<List<OrderModel>>> getOrders({
    int page = 1,
    String? status,
  });

  /// Get single order by ID
  Future<OrdersResult<OrderModel>> getOrderById(String id);

  /// Update order status (e.g., CANCELLED)
  Future<OrdersResult<OrderModel>> updateOrderStatus(String id, String status);

  /// Reject a pending order through the dedicated seller action.
  Future<OrdersResult<OrderModel>> rejectOrder(String id);

  /// Apply an item-only edit to a pending, pre-payment order.
  Future<OrdersResult<OrderModel>> editOrderItems(
    String id, {
    required List<CartItem> items,
    required String idempotencyKey,
  });

  /// Accept a seller order, optionally delaying driver dispatch.
  Future<OrdersResult<OrderModel>> acceptOrder(
    String id, {
    int? driverDispatchDelayMinutes,
  });

  /// Request, schedule, or reschedule driver dispatch.
  Future<OrdersResult<OrderModel>> driverDispatch(
    String id, {
    required DriverDispatchAction action,
    int? driverDispatchDelayMinutes,
  });

  /// Process refund for an order
  Future<OrdersResult<RefundResponse>> refundOrder({
    required String orderId,
    required double amount,
    required String reason,
    String? idempotencyKey,
  });

  /// Log manual order from scanned form
  Future<OrdersResult<void>> logManualOrder({
    required Map<String, dynamic> data,
  });
}

/// Implementation of orders repository
class OrdersRepositoryImpl implements OrdersRepository {
  OrdersRepositoryImpl({required OrdersDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final OrdersDataSource _remoteDataSource;

  @override
  Future<OrdersResult<List<OrderModel>>> getOrders({
    int page = 1,
    String? status,
  }) async {
    try {
      final orders = await _remoteDataSource.getOrders(
        page: page,
        status: status,
      );
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
    } catch (e, stackTrace) {
      // Log the actual error for debugging
      assert(() {
        // ignore: avoid_print
        print('[OrdersRepository] getOrders parse error: $e');
        // ignore: avoid_print
        print('[OrdersRepository] Stack: $stackTrace');
        return true;
      }());
      return (
        failure: ServerFailure(message: 'An unexpected error occurred: $e'),
        data: null,
      );
    }
  }

  @override
  Future<OrdersResult<OrderModel>> getOrderById(String id) async {
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

  @override
  Future<OrdersResult<OrderModel>> updateOrderStatus(
    String id,
    String status,
  ) async {
    try {
      final order = await _remoteDataSource.updateOrderStatus(id, status);
      return (failure: null, data: order);
    } on DioException catch (e) {
      final apiError = e.error;
      if (apiError is ApiException) {
        return (failure: _actionFailure(e), data: null);
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
  Future<OrdersResult<OrderModel>> rejectOrder(String id) async {
    try {
      final order = await _remoteDataSource.rejectOrder(id);
      return (failure: null, data: order);
    } on DioException catch (e) {
      final apiError = e.error;
      if (apiError is ApiException) {
        return (failure: _actionFailure(e), data: null);
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
  Future<OrdersResult<OrderModel>> editOrderItems(
    String id, {
    required List<CartItem> items,
    required String idempotencyKey,
  }) async {
    try {
      final order = await _remoteDataSource.editOrderItems(
        id,
        items: items,
        idempotencyKey: idempotencyKey,
      );
      return (failure: null, data: order);
    } on DioException catch (e) {
      return (failure: _actionFailure(e), data: null);
    } catch (e) {
      return (
        failure: ServerFailure(message: 'An unexpected error occurred: $e'),
        data: null,
      );
    }
  }

  @override
  Future<OrdersResult<OrderModel>> acceptOrder(
    String id, {
    int? driverDispatchDelayMinutes,
  }) async {
    try {
      final order = await _remoteDataSource.acceptOrder(
        id,
        driverDispatchDelayMinutes: driverDispatchDelayMinutes,
      );
      return (failure: null, data: order);
    } on DioException catch (e) {
      return (failure: _actionFailure(e), data: null);
    } catch (e) {
      return (
        failure: ServerFailure(message: 'An unexpected error occurred: $e'),
        data: null,
      );
    }
  }

  @override
  Future<OrdersResult<OrderModel>> driverDispatch(
    String id, {
    required DriverDispatchAction action,
    int? driverDispatchDelayMinutes,
  }) async {
    try {
      final order = await _remoteDataSource.driverDispatch(
        id,
        action: action,
        driverDispatchDelayMinutes: driverDispatchDelayMinutes,
      );
      return (failure: null, data: order);
    } on DioException catch (e) {
      return (failure: _actionFailure(e), data: null);
    } catch (e) {
      return (
        failure: ServerFailure(message: 'An unexpected error occurred: $e'),
        data: null,
      );
    }
  }

  Failure _actionFailure(DioException error) {
    final apiError = error.error;
    if (apiError is ApiException) {
      final statusCode = apiError.statusCode ?? error.response?.statusCode;
      return ValidationFailure(
        message: apiError.message,
        statusCode: statusCode,
        code: apiError.code,
      );
    }
    return const NetworkFailure(message: 'Network error occurred');
  }

  @override
  Future<OrdersResult<RefundResponse>> refundOrder({
    required String orderId,
    required double amount,
    required String reason,
    String? idempotencyKey,
  }) async {
    try {
      final response = await _remoteDataSource.refundOrder(
        orderId: orderId,
        amount: amount,
        reason: reason,
        idempotencyKey: idempotencyKey,
      );
      return (failure: null, data: response);
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
  Future<OrdersResult<void>> logManualOrder({
    required Map<String, dynamic> data,
  }) async {
    try {
      await _remoteDataSource.logManualOrder(data: data);
      return (failure: null, data: null);
    } on DioException catch (e) {
      final apiError = e.error;
      if (apiError is ApiException &&
          (apiError.statusCode ?? e.response?.statusCode) == 409) {
        return (
          failure: ValidationFailure(
            message: 'errors.auth.phoneAlreadyRegistered'.tr,
          ),
          data: null,
        );
      }
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
