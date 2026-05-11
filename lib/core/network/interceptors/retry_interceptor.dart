/// Retry interceptor for handling timeout and connection errors
library;

import 'dart:async';

import 'package:dio/dio.dart';

/// Interceptor that retries failed requests on timeout/connection errors
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.maxRetries = 2,
    this.retryDelays = const [Duration(seconds: 1), Duration(seconds: 2)],
  });

  final Dio dio;
  final int maxRetries;
  final List<Duration> retryDelays;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Multipart/stream bodies are consumed by Dio once a request starts, so
    // replaying the same RequestOptions would fail before reaching the server.
    if (_hasOneShotBody(err.requestOptions.data)) {
      return handler.next(err);
    }

    // Only retry on timeout or connection errors
    if (_shouldRetry(err)) {
      final retryCount = err.requestOptions.extra['retryCount'] ?? 0;

      if (retryCount < maxRetries) {
        // Wait before retrying
        final delay = retryCount < retryDelays.length
            ? retryDelays[retryCount]
            : retryDelays.last;

        await Future.delayed(delay);

        // Update retry count
        err.requestOptions.extra['retryCount'] = retryCount + 1;

        try {
          // Retry the request
          final response = await dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } on DioException catch (e) {
          // If retry also fails, continue to next error handler
          return handler.next(e);
        }
      }
    }

    // Don't retry, pass to next handler
    return handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    // Retry on timeout errors
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return true;
    }

    // Also retry on socket/DNS errors (unknown type with SocketException)
    if (err.type == DioExceptionType.unknown &&
        err.error.toString().contains('SocketException')) {
      return true;
    }

    return false;
  }

  bool _hasOneShotBody(dynamic data) {
    return data is FormData || data is Stream;
  }
}
