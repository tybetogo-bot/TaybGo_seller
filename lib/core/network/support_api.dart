/// Support tickets API service
library;

import 'package:dio/dio.dart';

import '../../features/support/data/models/support_ticket_model.dart';
import 'restaurant_api.dart';

/// Support API service
class SupportApi {
  final Dio _dio;

  SupportApi(this._dio);

  /// List support tickets
  /// GET /api/seller/support/tickets/
  Future<PaginatedResponse<SupportTicket>> getTickets({
    int page = 1,
  }) async {
    final response = await _dio.get(
      '/api/seller/support/tickets/',
      queryParameters: {'page': page},
    );
    return PaginatedResponse.fromJson(
      response.data as Map<String, dynamic>,
      SupportTicket.fromJson,
    );
  }

  /// Create a support ticket
  /// POST /api/seller/support/tickets/
  Future<SupportTicket> createTicket({
    required String subject,
    required String category,
    required String priority,
    int? orderId,
    int? restaurantId,
    int? driverId,
  }) async {
    final response = await _dio.post(
      '/api/seller/support/tickets/',
      data: {
        'subject': subject,
        'category': category,
        'priority': priority,
        if (orderId != null) 'order_id': orderId,
        if (restaurantId != null) 'restaurant_id': restaurantId,
        if (driverId != null) 'driver_id': driverId,
      },
    );
    return SupportTicket.fromJson(response.data as Map<String, dynamic>);
  }

  /// Get ticket detail with messages
  /// GET /api/seller/support/tickets/{id}/
  Future<SupportTicket> getTicketById(int id) async {
    final response = await _dio.get('/api/seller/support/tickets/$id/');
    return SupportTicket.fromJson(response.data as Map<String, dynamic>);
  }

  /// Send a message to a ticket
  /// POST /api/seller/support/tickets/{id}/messages/
  Future<TicketMessage> sendMessage(
    int ticketId, {
    required String body,
    List<Map<String, String>>? attachments,
  }) async {
    final response = await _dio.post(
      '/api/seller/support/tickets/$ticketId/messages/',
      data: {
        'body': body,
        if (attachments != null) 'attachments': attachments,
      },
    );
    return TicketMessage.fromJson(response.data as Map<String, dynamic>);
  }
}
