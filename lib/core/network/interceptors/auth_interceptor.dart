/// Auth interceptor for adding authentication token to requests
library;

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/constants.dart';

/// Interceptor that adds the auth token to all requests
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._prefs);

  final SharedPreferences _prefs;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Get the auth token from storage
    final token = _prefs.getString(StorageKeys.authToken);

    // Add token to headers if available
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle 401 Unauthorized - token expired or invalid
    if (err.response?.statusCode == 401) {
      // TODO: Implement token refresh logic here
      // For now, just pass the error along
      // In a complete implementation, you would:
      // 1. Try to refresh the token using refresh token
      // 2. Retry the original request with new token
      // 3. If refresh fails, logout the user
    }

    super.onError(err, handler);
  }
}
