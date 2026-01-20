/// Error interceptor for handling API errors
library;

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../errors/exceptions.dart';

/// Interceptor that converts Dio errors to custom exceptions
class ErrorInterceptor extends Interceptor {
  final _logger = Logger();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e('API Error: ${err.message}', error: err);

    // Convert DioException to custom ApiException
    final exception = _handleError(err);
    
    // Pass the custom exception
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        response: err.response,
        type: err.type,
      ),
    );
  }

  ApiException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Connection timeout. Please check your internet connection.',
          statusCode: 408,
        );

      case DioExceptionType.badResponse:
        return _handleStatusCode(error.response);

      case DioExceptionType.cancel:
        return ApiException(
          message: 'Request cancelled',
          statusCode: 0,
        );

      case DioExceptionType.connectionError:
        return ApiException(
          message: 'No internet connection. Please check your network.',
          statusCode: 0,
        );

      case DioExceptionType.badCertificate:
        return ApiException(
          message: 'Security certificate error',
          statusCode: 0,
        );

      case DioExceptionType.unknown:
        return ApiException(
          message: error.message ?? 'An unexpected error occurred',
          statusCode: 0,
        );
    }
  }

  ApiException _handleStatusCode(Response? response) {
    final statusCode = response?.statusCode ?? 0;
    final data = response?.data;

    // Try to extract error message from response
    String message = 'An error occurred';
    
    if (data is Map<String, dynamic>) {
      // API uses 'detail' for error messages
      if (data['detail'] != null) {
        message = data['detail'].toString();
      } else if (data['message'] != null) {
        message = data['message'].toString();
      } else if (data['error'] != null) {
        message = data['error'].toString();
      } else if (data['msg'] != null) {
        message = data['msg'].toString();
      } else if (statusCode == 400) {
        // Django REST Framework returns field errors as {"field": ["error"]}
        final fieldErrors = <String>[];
        data.forEach((key, value) {
          if (value is List && value.isNotEmpty) {
            fieldErrors.add('$key: ${value.first}');
          } else if (value is String) {
            fieldErrors.add('$key: $value');
          }
        });
        if (fieldErrors.isNotEmpty) {
          message = fieldErrors.join(', ');
        }
      } else {
        message = _getDefaultMessageForCode(statusCode);
      }
    }

    switch (statusCode) {
      case 400:
        return BadRequestException(message: message);
      case 401:
        return UnauthorizedException(message: message);
      case 403:
        return ForbiddenException(message: message);
      case 404:
        return NotFoundException(message: message);
      case 422:
        return ValidationException(
          message: message,
          errors: _extractValidationErrors(data),
        );
      case 429:
        return ApiException(message: 'Too many requests. Please wait and try again.', statusCode: 429);
      case 500:
      case 502:
      case 503:
        return ServerException(message: message.isEmpty ? 'Server error. Please try again later.' : message);
      default:
        return ApiException(message: message, statusCode: statusCode);
    }
  }

  Map<String, List<String>>? _extractValidationErrors(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    
    final errors = data['errors'];
    if (errors is! Map<String, dynamic>) return null;

    return errors.map((key, value) {
      if (value is List) {
        return MapEntry(key, value.map((e) => e.toString()).toList());
      }
      return MapEntry(key, [value.toString()]);
    });
  }

  String _getDefaultMessageForCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Authentication failed. Please try again.';
      case 403:
        return 'Access denied.';
      case 404:
        return 'The requested resource was not found.';
      case 422:
        return 'Validation error. Please check your input.';
      case 429:
        return 'Too many requests. Please wait and try again.';
      case 500:
      case 502:
      case 503:
        return 'Server error. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
