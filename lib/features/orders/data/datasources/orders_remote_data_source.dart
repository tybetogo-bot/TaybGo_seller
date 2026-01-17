/// Remote data source for orders
library;

import '../../../../core/network/orders_api.dart';
import '../models/order_model.dart';

/// Abstract interface for orders data source
abstract class OrdersDataSource {
  /// Get orders list with optional filters
  /// Note: API auto-scopes to seller's restaurants
  Future<List<OrderModel>> getOrders({
    int page = 1,
    String? status,
  });

  /// Get single order by ID
  Future<OrderModel> getOrderById(String id);

  /// Update order status (e.g., CANCELLED)
  Future<OrderModel> updateOrderStatus(String id, String status);

  /// Process refund for an order
  Future<RefundResponse> refundOrder({
    required String orderId,
    required double amount,
    required String reason,
    String? idempotencyKey,
  });

  /// Log manual order from scanned form
  Future<void> logManualOrder({
    required Map<String, dynamic> data,
  });
}

/// Remote data source implementation using OrdersApi
class OrdersRemoteDataSource implements OrdersDataSource {
  OrdersRemoteDataSource(this._api);

  final OrdersApi _api;

  @override
  Future<List<OrderModel>> getOrders({
    int page = 1,
    String? status,
  }) async {
    final response = await _api.getOrders(
      page: page,
      status: status,
    );
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
  Future<void> logManualOrder({
    required Map<String, dynamic> data,
  }) async {
    return await _api.logManualOrder(data: data);
  }
}
