/// Auth interceptor for adding authentication token to requests
library;

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/constants.dart';

/// Interceptor that adds the auth token to all requests
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._prefs, {this.onUnauthorized});

  final SharedPreferences _prefs;
  final Future<void> Function()? onUnauthorized;

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
      // Clear auth data immediately to ensure user is logged out
      _prefs.remove(StorageKeys.authToken);
      _prefs.remove(StorageKeys.refreshToken);
      _prefs.remove('user_phone');
      _prefs.remove(StorageKeys.userId);
      _prefs.remove(StorageKeys.userRole);
      _prefs.remove(StorageKeys.restaurantId);

      // Notify the app to handle logout (navigate to login screen)
      onUnauthorized?.call();
    }

    super.onError(err, handler);
  }
}
