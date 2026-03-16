/// API Client configuration
/// Sets up Dio with interceptors and error handling
library;

import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../config/env_config.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

/// Creates and configures the Dio instance for API calls
class ApiClient {
  ApiClient._();

  static Dio? _dio;
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
    _dio?.close();
    _dio = null;
    _onUnauthorized = null;
  }
}
