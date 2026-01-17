/// Orders API service for seller order management
library;

import 'package:dio/dio.dart';

import '../../features/orders/data/models/order_model.dart';
import 'restaurant_api.dart';

/// Orders API service
class OrdersApi {
  final Dio _dio;

  OrdersApi(this._dio);

  /// List seller's restaurant orders
  /// GET /api/seller/orders/
  Future<PaginatedResponse<OrderModel>> getOrders({
    int page = 1,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
    };
    if (status != null) queryParams['status'] = status;

    final response = await _dio.get(
      '/api/seller/orders/',
      queryParameters: queryParams,
    );

    return PaginatedResponse.fromJson(
      response.data as Map<String, dynamic>,
      OrderModel.fromJson,
    );
  }

  /// Get order details
  /// GET /api/seller/orders/{id}/
  Future<OrderModel> getOrderById(String id) async {
    final response = await _dio.get('/api/seller/orders/$id/');
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Update order status (e.g., CANCELLED)
  /// POST /api/seller/orders/{id}/status/
  Future<OrderModel> updateOrderStatus(String id, String status) async {
    final response = await _dio.post(
      '/api/seller/orders/$id/status/',
      data: {'status': status},
    );
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Process refund
  /// POST /api/seller/orders/{order_id}/refund/
  Future<RefundResponse> refundOrder({
    required String orderId,
    required double amount,
    required String reason,
    String? idempotencyKey,
  }) async {
    final response = await _dio.post(
      '/api/seller/orders/$orderId/refund/',
      data: {
        'amount': amount,
        'reason': reason,
        if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      },
    );
    return RefundResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Log manual order from scanned form
  /// POST /api/seller/orders/manual/
  Future<void> logManualOrder({
    required Map<String, dynamic> data,
  }) async {
    await _dio.post(
      '/api/seller/orders/manual/',
      data: data,
    );
  }

  /// Export orders to Excel
  /// GET /api/seller/orders/export/excel/
  /// Note: API uses 'from_' with underscore for the from date parameter
  Future<Response> exportToExcel({
    String? status,
    String? search,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final queryParams = <String, dynamic>{};
    if (status != null) queryParams['status'] = status;
    if (search != null) queryParams['search'] = search;
    if (fromDate != null) queryParams['from_'] = fromDate.toIso8601String();
    if (toDate != null) queryParams['to'] = toDate.toIso8601String();

    return await _dio.get(
      '/api/seller/orders/export/excel/',
      queryParameters: queryParams,
      options: Options(
        responseType: ResponseType.bytes,
      ),
    );
  }

  /// Export orders to PDF
  /// GET /api/seller/orders/export/pdf/
  /// Note: API uses 'from_' with underscore for the from date parameter
  Future<Response> exportToPdf({
    String? status,
    String? search,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final queryParams = <String, dynamic>{};
    if (status != null) queryParams['status'] = status;
    if (search != null) queryParams['search'] = search;
    if (fromDate != null) queryParams['from_'] = fromDate.toIso8601String();
    if (toDate != null) queryParams['to'] = toDate.toIso8601String();

    return await _dio.get(
      '/api/seller/orders/export/pdf/',
      queryParameters: queryParams,
      options: Options(
        responseType: ResponseType.bytes,
      ),
    );
  }
}

/// Refund response model
class RefundResponse {
  final String orderId;
  final double refundAmount;
  final String status;
  final String? transactionId;
  final String reason;

  RefundResponse({
    required this.orderId,
    required this.refundAmount,
    required this.status,
    this.transactionId,
    required this.reason,
  });

  factory RefundResponse.fromJson(Map<String, dynamic> json) {
    return RefundResponse(
      orderId: json['order_id'] as String,
      refundAmount: (json['refund_amount'] as num).toDouble(),
      status: json['status'] as String,
      transactionId: json['transaction_id'] as String?,
      reason: json['reason'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'refund_amount': refundAmount,
      'status': status,
      if (transactionId != null) 'transaction_id': transactionId,
      'reason': reason,
    };
  }
}
