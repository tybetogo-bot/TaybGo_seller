/// Failure classes for error handling in the application layer
library;

import 'package:equatable/equatable.dart';

/// Base failure class
abstract class Failure extends Equatable {
  const Failure({required this.message, this.statusCode, this.code});

  final String message;
  final int? statusCode;
  final String? code;

  @override
  List<Object?> get props => [message, statusCode, code];
}

/// Failure from API/Server
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode, super.code});
}

/// Failure from cache/local storage
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.statusCode, super.code});
}

/// Failure from network/connection
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection',
    super.statusCode,
    super.code,
  });
}

/// Validation failure
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    this.errors,
    super.statusCode,
    super.code,
  });

  final Map<String, List<String>>? errors;

  @override
  List<Object?> get props => [message, errors, statusCode, code];
}

/// Authentication failure
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code, super.statusCode});

  @override
  List<Object?> get props => [message, code, statusCode];
}
