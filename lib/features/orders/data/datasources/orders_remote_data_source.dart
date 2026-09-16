/// Remote data source for orders
library;

import '../../../../core/network/orders_api.dart';
import '../models/food_checkout_model.dart';
import '../models/order_model.dart';

/// Abstract interface for orders data source
abstract class OrdersDataSource {
  /// Get orders list with optional filters
  /// Note: API auto-scopes to seller's restaurants
  Future<List<OrderModel>> getOrders({int page = 1, String? status});

  /// Get single order by ID
  Future<OrderModel> getOrderById(String id);

  /// Update order status (e.g., CANCELLED)
  Future<OrderModel> updateOrderStatus(String id, String status);

  /// Reject a pending order through the dedicated seller action.
  Future<OrderModel> rejectOrder(String id);

  /// Apply an item-only edit to a pending, pre-payment order.
  Future<OrderModel> editOrderItems(
    String id, {
    required List<CartItem> items,
    required String idempotencyKey,
  });

  /// Accept a seller order, optionally delaying driver dispatch.
  Future<OrderModel> acceptOrder(String id, {int? driverDispatchDelayMinutes});

  /// Request, schedule, or reschedule driver dispatch.
  Future<OrderModel> driverDispatch(
    String id, {
    required DriverDispatchAction action,
    int? driverDispatchDelayMinutes,
  });

  /// Process refund for an order
  Future<RefundResponse> refundOrder({
    required String orderId,
    required double amount,
    required String reason,
    String? idempotencyKey,
  });

  /// Log manual order from scanned form
  Future<void> logManualOrder({required Map<String, dynamic> data});
}

/// Remote data source implementation using OrdersApi
class OrdersRemoteDataSource implements OrdersDataSource {
  OrdersRemoteDataSource(this._api);

  final OrdersApi _api;

  @override
  Future<List<OrderModel>> getOrders({int page = 1, String? status}) async {
    final response = await _api.getOrders(page: page, status: status);
    return response.results;
  }

  @override
  Future<OrderModel> getOrderById(String id) async {
    return await _api.getOrderById(id);
  }

  @override
  Future<OrderModel> updateOrderStatus(String id, String status) async {
    return await _api.updateOrderStatus(id, status);
  }

  @override
  Future<OrderModel> rejectOrder(String id) async {
    return await _api.rejectOrder(id);
  }

  @override
  Future<OrderModel> editOrderItems(
    String id, {
    required List<CartItem> items,
    required String idempotencyKey,
  }) async {
    return await _api.editOrderItems(
      id,
      items: items,
      idempotencyKey: idempotencyKey,
    );
  }

  @override
  Future<OrderModel> acceptOrder(
    String id, {
    int? driverDispatchDelayMinutes,
  }) async {
    return await _api.acceptOrder(
      id,
      driverDispatchDelayMinutes: driverDispatchDelayMinutes,
    );
  }

  @override
  Future<OrderModel> driverDispatch(
    String id, {
    required DriverDispatchAction action,
    int? driverDispatchDelayMinutes,
  }) async {
    return await _api.driverDispatch(
      id,
      action: action,
      driverDispatchDelayMinutes: driverDispatchDelayMinutes,
    );
  }

  @override
  Future<RefundResponse> refundOrder({
    required String orderId,
    required double amount,
    required String reason,
    String? idempotencyKey,
  }) async {
    return await _api.refundOrder(
      orderId: orderId,
      amount: amount,
      reason: reason,
      idempotencyKey: idempotencyKey,
    );
  }

  @override
  Future<void> logManualOrder({required Map<String, dynamic> data}) async {
    return await _api.logManualOrder(data: data);
  }
}
