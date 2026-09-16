/// Customer Orders API service for customer order management
library;

import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../features/addresses/data/models/address_model.dart';
import '../../features/orders/data/models/food_checkout_model.dart';
import '../../features/orders/data/models/order_model.dart';
import 'restaurant_api.dart';

/// Customer Orders API service
class CustomerOrdersApi {
  static const String _sellerFoodPreviewPath = '/api/seller/preview/food/';
  static const String _customerFoodPreviewPath = '/api/customer/preview/food/';

  final Dio _dio;

  CustomerOrdersApi(this._dio);

  void _log(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: 'CustomerOrdersApi',
        error: error,
        stackTrace: stackTrace,
      );
      // ignore: avoid_print
      print('[CustomerOrdersApi] $message');
      if (error != null) {
        // ignore: avoid_print
        print('[CustomerOrdersApi] Error: $error');
      }
    }
  }

  /// Create an address via POST /api/addresses/
  Future<CustomerAddressModel> _createAddress(
    OrderAddressData addressData,
  ) async {
    final data = addressData.toJson();
    _log('Creating address with data: $data');
    final response = await _dio.post('/api/addresses/', data: data);
    _log('Created address response: ${response.data}');
    return CustomerAddressModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<FoodPriceQuote> _postFoodPreview(
    String path,
    FoodPricePreviewRequest request,
  ) async {
    final data = request.toJson();
    _log('Previewing food order via $path with data: $data');
    final response = await _dio.post(path, data: data);
    return FoodPriceQuote.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  /// Preview live food pricing without creating an order.
  Future<FoodPriceQuote> previewFoodOrder(
    FoodPricePreviewRequest request,
  ) async {
    try {
      return await _postFoodPreview(_sellerFoodPreviewPath, request);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 404 || statusCode == 405) {
        _log(
          'Seller food preview unavailable, retrying customer preview path.',
          error: e,
          stackTrace: e.stackTrace,
        );
        return await _postFoodPreview(_customerFoodPreviewPath, request);
      }
      rethrow;
    }
  }

  /// Create a food order
  /// Creates the drop-off address if needed, then creates the order
  /// POST /api/orders/
  Future<OrderModel> createFoodOrder(FoodCheckoutRequest request) async {
    try {
      int? dropoffId = request.dropoffAddressId;

      if (dropoffId == null && request.dropoffAddressData != null) {
        _log('Creating dropoff address...');
        final dropoffAddress = await _createAddress(
          request.dropoffAddressData!,
        );
        dropoffId = dropoffAddress.id;
        _log('Created dropoff address with ID: $dropoffId');
      }

      // Build the request in the shape expected by POST /api/orders/
      final requestJson = request.toJson(dropoffId: dropoffId);
      _log('Creating food order with data: $requestJson');

      final response = await _dio.post('/api/orders/', data: requestJson);

      _log('Create food order response status: ${response.statusCode}');
      _log('Create food order response data: ${response.data}');

      final order = OrderModel.fromJson(response.data as Map<String, dynamic>);
      _log('Successfully parsed order with ID: ${order.id}');

      return order;
    } on DioException catch (e) {
      _log(
        'DioException creating food order: ${e.message}',
        error: e,
        stackTrace: e.stackTrace,
      );
      _log('Response status code: ${e.response?.statusCode}');
      _log('Response data: ${e.response?.data}');
      rethrow;
    } catch (e, stackTrace) {
      _log(
        'Unexpected error creating food order',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
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
    final response = await _dio.put('/api/orders/$id/', data: request.toJson());
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Partial update an order
  /// PATCH /api/orders/{id}/
  Future<OrderModel> patchOrder(String id, Map<String, dynamic> data) async {
    final response = await _dio.patch('/api/orders/$id/', data: data);
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
  Future<PaginatedResponse<OrderModel>> getOrders({int page = 1}) async {
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
