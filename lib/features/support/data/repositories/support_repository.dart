/// Support repository interface and implementation
library;

import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/support_api.dart';
import '../models/support_ticket_model.dart';

/// Result type for repository methods
typedef SupportResult<T> = ({Failure? failure, T? data});

/// Support repository interface
abstract class SupportRepository {
  Future<SupportResult<List<SupportTicket>>> getTickets({int page = 1});
  Future<SupportResult<SupportTicket>> getTicketById(int id);
  Future<SupportResult<SupportTicket>> createTicket({
    required String subject,
    required String category,
    required String priority,
    int? orderId,
    int? restaurantId,
    int? driverId,
  });
  Future<SupportResult<TicketMessage>> sendMessage(
    int ticketId, {
    required String body,
  });
}

/// Implementation of support repository
class SupportRepositoryImpl implements SupportRepository {
  SupportRepositoryImpl({required SupportApi api}) : _api = api;

  final SupportApi _api;

  @override
  Future<SupportResult<List<SupportTicket>>> getTickets({int page = 1}) async {
    try {
      final response = await _api.getTickets(page: page);
      return (failure: null, data: response.results);
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
  Future<SupportResult<SupportTicket>> getTicketById(int id) async {
    try {
      final ticket = await _api.getTicketById(id);
      return (failure: null, data: ticket);
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
  Future<SupportResult<SupportTicket>> createTicket({
    required String subject,
    required String category,
    required String priority,
    int? orderId,
    int? restaurantId,
    int? driverId,
  }) async {
    try {
      final ticket = await _api.createTicket(
        subject: subject,
        category: category,
        priority: priority,
        orderId: orderId,
        restaurantId: restaurantId,
        driverId: driverId,
      );
      return (failure: null, data: ticket);
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
  Future<SupportResult<TicketMessage>> sendMessage(
    int ticketId, {
    required String body,
  }) async {
    try {
      final message = await _api.sendMessage(ticketId, body: body);
      return (failure: null, data: message);
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
}
