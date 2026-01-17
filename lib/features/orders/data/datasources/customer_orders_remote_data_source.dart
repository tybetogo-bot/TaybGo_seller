/// Remote data source for customer orders
library;

import '../../../../core/network/customer_orders_api.dart';
import '../models/food_checkout_model.dart';
import '../models/order_model.dart';

/// Abstract interface for customer orders data source
abstract class CustomerOrdersDataSource {
  /// Create a food order
  Future<OrderModel> createFoodOrder(FoodCheckoutRequest request);

  /// Get customer orders list with pagination
  Future<List<OrderModel>> getCustomerOrders({int page = 1});

  /// Get customer order by ID
  Future<OrderModel> getCustomerOrderById(String id);

  /// Update an order
  Future<OrderModel> updateOrder(String id, OrderUpdateRequest request);

  /// Partial update an order
  Future<OrderModel> patchOrder(String id, Map<String, dynamic> data);

  /// Delete an order
  Future<void> deleteOrder(String id);

  /// Get order by ID (generic)
  Future<OrderModel> getOrderById(String id);
}

/// Remote data source implementation using CustomerOrdersApi
class CustomerOrdersRemoteDataSource implements CustomerOrdersDataSource {
  CustomerOrdersRemoteDataSource(this._api);

  final CustomerOrdersApi _api;

  @override
  Future<OrderModel> createFoodOrder(FoodCheckoutRequest request) async {
    return await _api.createFoodOrder(request);
  }

  @override
  Future<List<OrderModel>> getCustomerOrders({int page = 1}) async {
    final response = await _api.getCustomerOrders(page: page);
    return response.results;
  }

  @override
  Future<OrderModel> getCustomerOrderById(String id) async {
    return await _api.getCustomerOrderById(id);
  }

  @override
  Future<OrderModel> updateOrder(String id, OrderUpdateRequest request) async {
    return await _api.updateOrder(id, request);
  }

  @override
  Future<OrderModel> patchOrder(String id, Map<String, dynamic> data) async {
    return await _api.patchOrder(id, data);
  }

  @override
  Future<void> deleteOrder(String id) async {
    await _api.deleteOrder(id);
  }

  @override
  Future<OrderModel> getOrderById(String id) async {
    return await _api.getOrderById(id);
  }
}
