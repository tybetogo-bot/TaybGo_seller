/// Customer Orders API service for customer order management
library;

import 'package:dio/dio.dart';

import '../../features/orders/data/models/food_checkout_model.dart';
import '../../features/orders/data/models/order_model.dart';
import 'restaurant_api.dart';

/// Customer Orders API service
class CustomerOrdersApi {
  final Dio _dio;

  CustomerOrdersApi(this._dio);

  /// Create a food order
  /// POST /api/customer/checkout/food/
  Future<OrderModel> createFoodOrder(FoodCheckoutRequest request) async {
    final response = await _dio.post(
      '/api/customer/checkout/food/',
      data: request.toJson(),
    );
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// List customer's orders
  /// GET /api/customer/orders/
  Future<PaginatedResponse<OrderModel>> getCustomerOrders({
    int page = 1,
  }) async {
    final response = await _dio.get(
      '/api/customer/orders/',
      queryParameters: {'page': page},
    );

    return PaginatedResponse.fromJson(
      response.data as Map<String, dynamic>,
      OrderModel.fromJson,
    );
  }

  /// Get customer order by ID
  /// GET /api/customer/orders/{id}/
  Future<OrderModel> getCustomerOrderById(String id) async {
    final response = await _dio.get('/api/customer/orders/$id/');
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Update an order (full update)
  /// PUT /api/orders/{id}/
  Future<OrderModel> updateOrder(String id, OrderUpdateRequest request) async {
    final response = await _dio.put(
      '/api/orders/$id/',
      data: request.toJson(),
    );
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Partial update an order
  /// PATCH /api/orders/{id}/
  Future<OrderModel> patchOrder(String id, Map<String, dynamic> data) async {
    final response = await _dio.patch(
      '/api/orders/$id/',
      data: data,
    );
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Delete an order
  /// DELETE /api/orders/{id}/
  Future<void> deleteOrder(String id) async {
    await _dio.delete('/api/orders/$id/');
  }

  /// Get order by ID (generic)
  /// GET /api/orders/{id}/
  Future<OrderModel> getOrderById(String id) async {
    final response = await _dio.get('/api/orders/$id/');
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// List user's orders (generic)
  /// GET /api/orders/
  Future<PaginatedResponse<OrderModel>> getOrders({
    int page = 1,
  }) async {
    final response = await _dio.get(
      '/api/orders/',
      queryParameters: {'page': page},
    );

    return PaginatedResponse.fromJson(
      response.data as Map<String, dynamic>,
      OrderModel.fromJson,
    );
  }
}
