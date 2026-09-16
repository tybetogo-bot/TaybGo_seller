/// Orders API service for seller order management
library;

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../features/orders/data/models/food_checkout_model.dart';
import '../../features/orders/data/models/order_model.dart';
import '../config/constants.dart';
import 'restaurant_api.dart';

/// Orders API service
class OrdersApi {
  final Dio _dio;

  OrdersApi(this._dio);

  Map<String, dynamic> _buildOrdersQueryParams({
    required int page,
    String? status,
  }) {
    final queryParams = <String, dynamic>{'page': page};
    if (status != null) queryParams['status'] = status;
    return queryParams;
  }

  /// List orders owned by the authenticated seller
  /// GET /api/seller/orders/
  Future<PaginatedResponse<OrderModel>> getOrders({
    int page = 1,
    String? status,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.sellerOrders,
      queryParameters: _buildOrdersQueryParams(page: page, status: status),
    );

    return PaginatedResponse.fromJson(
      response.data as Map<String, dynamic>,
      OrderModel.fromJson,
    );
  }

  /// Get seller order details
  /// GET /api/seller/orders/{id}/
  Future<OrderModel> getOrderById(String id) async {
    final response = await _dio.get(ApiEndpoints.sellerOrder(id));
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Debug helper to inspect the raw paginated orders payload.
  Future<Map<String, dynamic>> getRawOrders({
    int page = 1,
    String? status,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.sellerOrders,
      queryParameters: _buildOrdersQueryParams(page: page, status: status),
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// Debug helper to inspect the raw order details payload.
  Future<Map<String, dynamic>> getRawOrderById(String id) async {
    final response = await _dio.get(ApiEndpoints.sellerOrder(id));
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// Update order status
  /// POST /api/seller/orders/{id}/status/
  Future<OrderModel> updateOrderStatus(String id, String status) async {
    final response = await _dio.post(
      ApiEndpoints.sellerOrderStatus(id),
      data: {'status': status},
    );

    // Some status responses omit customer/order details, so re-fetch the full
    // order before updating local state to avoid replacing rich data with
    // placeholder fallbacks like "Customer".
    try {
      return await getOrderById(id);
    } on DioException {
      return OrderModel.fromJson(response.data as Map<String, dynamic>);
    }
  }

  /// Reject a pending seller order through the dedicated seller action.
  Future<OrderModel> rejectOrder(
    String id, {
    String reasonCode = 'OTHER',
  }) async {
    final response = await _dio.post(
      ApiEndpoints.sellerOrderReject(id),
      data: {'reason_code': reasonCode},
    );

    try {
      return await getOrderById(id);
    } on DioException {
      return OrderModel.fromJson(response.data as Map<String, dynamic>);
    }
  }

  /// Apply an item-only edit to a pending, pre-payment seller order.
  /// POST /api/seller/orders/{id}/edit/
  Future<OrderModel> editOrderItems(
    String id, {
    required List<CartItem> items,
    required String idempotencyKey,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.sellerOrderEdit(id),
      data: {
        'idempotency_key': idempotencyKey,
        'items': items.map((item) => item.toJson()).toList(),
      },
    );
    return _refreshOrderFromActionResponse(id, response);
  }

  /// Accept a seller order, optionally scheduling driver dispatch.
  /// POST /api/seller/orders/{id}/accept/
  Future<OrderModel> acceptOrder(
    String id, {
    int? driverDispatchDelayMinutes,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.sellerOrderAccept(id),
      data: {
        if (driverDispatchDelayMinutes != null)
          'driver_dispatch_delay_minutes': driverDispatchDelayMinutes,
      },
    );
    return _refreshOrderFromActionResponse(id, response);
  }

  /// Request or schedule driver dispatch for an accepted delivery order.
  /// POST /api/seller/orders/{id}/driver-dispatch/
  Future<OrderModel> driverDispatch(
    String id, {
    required DriverDispatchAction action,
    int? driverDispatchDelayMinutes,
  }) async {
    if ((action == DriverDispatchAction.schedule ||
            action == DriverDispatchAction.reschedule) &&
        driverDispatchDelayMinutes == null) {
      throw ArgumentError.value(
        driverDispatchDelayMinutes,
        'driverDispatchDelayMinutes',
        'A delay is required when scheduling driver dispatch.',
      );
    }

    final response = await _dio.post(
      ApiEndpoints.sellerOrderDriverDispatch(id),
      data: {
        'action': action.apiValue,
        if (action != DriverDispatchAction.requestNow &&
            driverDispatchDelayMinutes != null)
          'driver_dispatch_delay_minutes': driverDispatchDelayMinutes,
      },
      options: action == DriverDispatchAction.reschedule
          ? Options(extra: {'disableRetry': true})
          : null,
    );
    return _refreshOrderFromActionResponse(id, response);
  }

  Future<OrderModel> _refreshOrderFromActionResponse(
    String id,
    Response<dynamic> response,
  ) async {
    // Action responses may be compact, while the detail response is the
    // canonical shape used by cards and details. Prefer it after every action.
    try {
      return await getOrderById(id);
    } on DioException {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final order = data['order'];
        if (order is Map<String, dynamic>) {
          return OrderModel.fromJson(order);
        }

        // Keep compatibility with action endpoints that return the order
        // object directly rather than wrapping it in an `order` field.
        if (data.containsKey('id')) {
          return OrderModel.fromJson(data);
        }
      }
      rethrow;
    }
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
      ApiEndpoints.sellerOrderRefund(orderId),
      data: {
        'amount': amount,
        'reason': reason,
        if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      },
    );
    return RefundResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Log manual order from scanned form
  /// POST /api/orders/manual/
  Future<void> logManualOrder({required Map<String, dynamic> data}) async {
    await _dio.post('/api/orders/manual/', data: data);
  }

  /// Extract order draft from images using backend AI
  /// POST /api/orders/extract-draft/
  Future<Map<String, dynamic>> extractDraft({
    required int restaurantId,
    required List<XFile> images,
  }) async {
    final formData = FormData();
    formData.fields.add(MapEntry('restaurant_id', restaurantId.toString()));

    for (final file in images) {
      final bytes = await file.readAsBytes();
      final fileName = file.name.isNotEmpty ? file.name : 'order-image.jpg';
      formData.files.add(
        MapEntry('images', MultipartFile.fromBytes(bytes, filename: fileName)),
      );
    }

    final response = await _dio.post(
      ApiEndpoints.ordersExtractDraft,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    return response.data as Map<String, dynamic>;
  }

  /// Export orders to Excel
  /// GET /api/orders/export/excel/
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
      '/api/orders/export/excel/',
      queryParameters: queryParams,
      options: Options(responseType: ResponseType.bytes),
    );
  }

  /// Export orders to PDF
  /// GET /api/orders/export/pdf/
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
      '/api/orders/export/pdf/',
      queryParameters: queryParams,
      options: Options(responseType: ResponseType.bytes),
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
