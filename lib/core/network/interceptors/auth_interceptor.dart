/// Auth interceptor for adding authentication token to requests
/// and refreshing expired tokens automatically.
library;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_config.dart';
import '../../config/constants.dart';

/// Interceptor that adds the auth token to all requests and handles
/// automatic token refresh on 401 responses.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor(this._prefs, {this.onUnauthorized});

  final SharedPreferences _prefs;
  final Future<void> Function()? onUnauthorized;

  /// Whether a token refresh is currently in progress.
  bool _isRefreshing = false;

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
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Only handle 401 Unauthorized
    if (err.response?.statusCode != 401) {
      return super.onError(err, handler);
    }

    // Don't try to refresh if the failing request was itself a refresh or auth request
    final requestPath = err.requestOptions.path;
    if (requestPath.contains('/auth/token/refresh') ||
        requestPath.contains('/auth/otp/') ||
        requestPath.endsWith('/auth/token/') ||
        requestPath.contains('/auth/token/blacklist')) {
      // Auth endpoint itself failed — clear credentials and log out
      await _clearAuthAndLogout();
      return super.onError(err, handler);
    }

    // Don't try to refresh if already refreshing (queued interceptor serializes,
    // but guard against re-entrant edge cases).
    if (_isRefreshing) {
      return super.onError(err, handler);
    }

    // Attempt to refresh the token
    final refreshToken = _prefs.getString(StorageKeys.refreshToken);
    if (refreshToken == null || refreshToken.isEmpty) {
      await _clearAuthAndLogout();
      return super.onError(err, handler);
    }

    _isRefreshing = true;
    try {
      debugPrint('🔄 [AuthInterceptor] Access token expired, refreshing...');

      // Use a fresh Dio instance to avoid interceptor loops
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: AppConfig.apiBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final response = await refreshDio.post(
        '/api/auth/token/refresh/',
        data: {'refresh': refreshToken},
      );

      final newAccess = response.data['access'] as String;
      final newRefresh = response.data['refresh'] as String;

      // Save the new tokens
      await _prefs.setString(StorageKeys.authToken, newAccess);
      await _prefs.setString(StorageKeys.refreshToken, newRefresh);

      debugPrint('✅ [AuthInterceptor] Token refreshed successfully');

      _isRefreshing = false;

      // Retry the original request with the new token
      final opts = err.requestOptions;
      opts.headers['Authorization'] = 'Bearer $newAccess';

      final retryDio = Dio(
        BaseOptions(
          baseUrl: opts.baseUrl,
          connectTimeout: opts.connectTimeout,
          receiveTimeout: opts.receiveTimeout,
          sendTimeout: opts.sendTimeout,
        ),
      );

      final retryResponse = await retryDio.fetch(opts);
      return handler.resolve(retryResponse);
    } on DioException catch (refreshError) {
      _isRefreshing = false;
      debugPrint(
        '❌ [AuthInterceptor] Token refresh failed: ${refreshError.message}',
      );
      await _clearAuthAndLogout();
      return super.onError(err, handler);
    } catch (e) {
      _isRefreshing = false;
      debugPrint('❌ [AuthInterceptor] Token refresh error: $e');
      await _clearAuthAndLogout();
      return super.onError(err, handler);
    }
  }

  /// Clear all auth data and notify the app to log out.
  Future<void> _clearAuthAndLogout() async {
    await _prefs.remove(StorageKeys.authToken);
    await _prefs.remove(StorageKeys.refreshToken);
    await _prefs.remove('user_phone');
    await _prefs.remove(StorageKeys.userId);
    await _prefs.remove(StorageKeys.userRole);
    await _prefs.remove(StorageKeys.restaurantId);
    onUnauthorized?.call();
  }
}
