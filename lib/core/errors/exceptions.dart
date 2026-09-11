/// Custom exceptions for the application
library;

/// Base API exception
class ApiException implements Exception {
  const ApiException({required this.message, this.statusCode, this.code});

  final String message;
  final int? statusCode;
  final String? code;

  @override
  String toString() => message;
}

/// Exception for 400 Bad Request
class BadRequestException extends ApiException {
  const BadRequestException({required super.message, super.code})
    : super(statusCode: 400);
}

/// Exception for 401 Unauthorized
class UnauthorizedException extends ApiException {
  const UnauthorizedException({required super.message, super.code})
    : super(statusCode: 401);
}

/// Exception for 403 Forbidden
class ForbiddenException extends ApiException {
  const ForbiddenException({required super.message, super.code})
    : super(statusCode: 403);
}

/// Exception for 404 Not Found
class NotFoundException extends ApiException {
  const NotFoundException({required super.message, super.code})
    : super(statusCode: 404);
}

/// Exception for 422 Validation Error
class ValidationException extends ApiException {
  const ValidationException({required super.message, super.code, this.errors})
    : super(statusCode: 422);

  final Map<String, List<String>>? errors;

  String? getFieldError(String field) {
    final fieldErrors = errors?[field];
    return fieldErrors?.isNotEmpty == true ? fieldErrors!.first : null;
  }

  @override
  String toString() {
    if (errors == null || errors!.isEmpty) return message;

    final buffer = StringBuffer(message);
    buffer.writeln();

    errors!.forEach((field, messages) {
      buffer.writeln('  $field: ${messages.join(", ")}');
    });

    return buffer.toString();
  }
}

/// Exception for 500 Server Error
class ServerException extends ApiException {
  const ServerException({required super.message, super.code})
    : super(statusCode: 500);
}

/// Exception for network/connection errors
class NetworkException implements Exception {
  const NetworkException({this.message = 'No internet connection'});

  final String message;

  @override
  String toString() => message;
}

/// Exception for cache errors
class CacheException implements Exception {
  const CacheException({this.message = 'Cache error occurred'});

  final String message;

  @override
  String toString() => message;
}
