/// API Client configuration
/// Sets up Dio with interceptors and error handling
library;

import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../config/env_config.dart';
import '../services/session_lifecycle.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

/// Creates and configures the Dio instance for API calls
class ApiClient {
  ApiClient._();

  static Dio? _dio;
  static void Function()? _sessionListener;
  static Future<void> Function()? _onUnauthorized;

  /// Get the configured Dio instance
  static Dio getInstance(
    SharedPreferences prefs, {
    Future<void> Function()? onUnauthorized,
  }) {
    // Store the callback for future use
    if (onUnauthorized != null) {
      _onUnauthorized = onUnauthorized;
    }

    if (_dio != null) return _dio!;

    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.apiTimeout,
        receiveTimeout: AppConfig.apiTimeout,
        sendTimeout: AppConfig.apiTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // BaseOptions are copied when each request is created, before asynchronous
    // interceptor dispatch. A queued request must retain its original login.
    void updateGeneration() {
      _dio?.options.extra['loginGeneration'] =
          SessionLifecycle.instance.generation;
    }

    _sessionListener = updateGeneration;
    updateGeneration();
    SessionLifecycle.instance.addListener(updateGeneration);

    // Add interceptors
    _dio!.interceptors.addAll([
      AuthInterceptor(prefs, onUnauthorized: _onUnauthorized),
      RetryInterceptor(dio: _dio!, maxRetries: 2),
      ErrorInterceptor(),
      if (EnvConfig.enableNetworkLogging)
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
    ]);

    return _dio!;
  }

  /// Clear the Dio instance (useful for testing or re-initialization)
  static void reset() {
    if (_sessionListener != null) {
      SessionLifecycle.instance.removeListener(_sessionListener!);
      _sessionListener = null;
    }
    _dio?.close();
    _dio = null;
    _onUnauthorized = null;
  }
}
