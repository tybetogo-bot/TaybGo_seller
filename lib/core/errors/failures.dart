/// Failure classes for error handling in the application layer
library;

import 'package:equatable/equatable.dart';

/// Base failure class
abstract class Failure extends Equatable {
  const Failure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Failure from API/Server
class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

/// Failure from cache/local storage
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

/// Failure from network/connection
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection'});
}

/// Validation failure
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    this.errors,
  });

  final Map<String, List<String>>? errors;

  @override
  List<Object?> get props => [message, errors];
}

/// Authentication failure
class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}
