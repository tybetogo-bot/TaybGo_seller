/// Auth repository interface and implementation
library;

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/config/constants.dart';
import '../../../../core/i18n/i18n.dart';
import '../datasources/auth_data_source.dart';
import '../models/auth_model.dart';

/// Result type for repository methods
typedef AuthResult<T> = ({Failure? failure, T? data});

/// Auth repository interface
abstract class AuthRepository {
  /// Request OTP for phone number
  Future<AuthResult<OtpRequestResponse>> requestOtp({required String phone});

  /// Verify OTP code and get tokens
  Future<AuthResult<OtpVerifyResponse>> verifyOtp({
    required String phone,
    required String code,
  });

  /// Refresh access token
  Future<AuthResult<TokenRefreshResponse>> refreshToken();

  /// Logout user
  Future<AuthResult<void>> logout();

  /// Check if user is authenticated
  bool isAuthenticated();

  /// Get stored phone number
  String? getStoredPhone();

  /// Get access token
  String? getAccessToken();

  /// Save authentication data
  Future<void> saveAuthData({
    required String accessToken,
    required String refreshToken,
    required String phone,
  });

  /// Clear authentication data
  Future<void> clearAuthData();
}

/// Implementation of auth repository
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthDataSource remoteDataSource,
    required SharedPreferences prefs,
  })  : _remoteDataSource = remoteDataSource,
        _prefs = prefs;

  final AuthDataSource _remoteDataSource;
  final SharedPreferences _prefs;

  @override
  Future<AuthResult<OtpRequestResponse>> requestOtp({
    required String phone,
  }) async {
    try {
      final response = await _remoteDataSource.requestOtp(phone: phone);
      return (failure: null, data: response);
    } on DioException catch (e) {
      final apiError = e.error;
      if (apiError is ApiException) {
        return (failure: _mapAuthError(apiError, 'otp_request'), data: null);
      }
      return (failure: NetworkFailure(message: 'errors.network'.tr), data: null);
    } on NetworkException catch (_) {
      return (failure: NetworkFailure(message: 'errors.network'.tr), data: null);
    } catch (e) {
      return (
        failure: ServerFailure(message: 'errors.unexpected'.tr),
        data: null
      );
    }
  }

  @override
  Future<AuthResult<OtpVerifyResponse>> verifyOtp({
    required String phone,
    required String code,
  }) async {
    try {
      final response = await _remoteDataSource.verifyOtp(
        phone: phone,
        code: code,
      );

      // Save auth data after successful verification
      await saveAuthData(
        accessToken: response.access,
        refreshToken: response.refresh,
        phone: phone,
      );

      return (failure: null, data: response);
    } on DioException catch (e) {
      final apiError = e.error;
      if (apiError is ApiException) {
        return (failure: _mapAuthError(apiError, 'otp_verify'), data: null);
      }
      return (failure: NetworkFailure(message: 'errors.network'.tr), data: null);
    } on NetworkException catch (_) {
      return (failure: NetworkFailure(message: 'errors.network'.tr), data: null);
    } catch (e) {
      return (
        failure: ServerFailure(message: 'errors.unexpected'.tr),
        data: null
      );
    }
  }

  @override
  Future<AuthResult<TokenRefreshResponse>> refreshToken() async {
    try {
      final refreshToken = _prefs.getString(StorageKeys.refreshToken);
      if (refreshToken == null) {
        return (
          failure: const AuthFailure(message: 'No refresh token available'),
          data: null
        );
      }

      final response = await _remoteDataSource.refreshToken(refreshToken);

      // Update stored tokens
      await _prefs.setString(StorageKeys.authToken, response.access);
      await _prefs.setString(StorageKeys.refreshToken, response.refresh);

      return (failure: null, data: response);
    } on ApiException catch (e) {
      // If refresh fails with 401, clear auth data
      if (e is UnauthorizedException) {
        await clearAuthData();
      }
      return (failure: ServerFailure(message: e.message), data: null);
    } on NetworkException catch (e) {
      return (failure: NetworkFailure(message: e.message), data: null);
    } catch (e) {
      return (
        failure: ServerFailure(message: 'An unexpected error occurred'),
        data: null
      );
    }
  }

  @override
  Future<AuthResult<void>> logout() async {
    try {
      final refreshToken = _prefs.getString(StorageKeys.refreshToken);
      if (refreshToken != null) {
        await _remoteDataSource.logout(refreshToken);
      }
      await clearAuthData();
      return (failure: null, data: null);
    } on ApiException catch (e) {
      // Even if API call fails, clear local data
      await clearAuthData();
      return (failure: ServerFailure(message: e.message), data: null);
    } catch (e) {
      // Even if API call fails, clear local data
      await clearAuthData();
      return (
        failure: ServerFailure(message: 'An unexpected error occurred'),
        data: null
      );
    }
  }

  @override
  bool isAuthenticated() {
    final token = _prefs.getString(StorageKeys.authToken);
    return token != null && token.isNotEmpty;
  }

  @override
  String? getStoredPhone() {
    return _prefs.getString('user_phone');
  }

  @override
  String? getAccessToken() {
    return _prefs.getString(StorageKeys.authToken);
  }

  @override
  Future<void> saveAuthData({
    required String accessToken,
    required String refreshToken,
    required String phone,
  }) async {
    await _prefs.setString(StorageKeys.authToken, accessToken);
    await _prefs.setString(StorageKeys.refreshToken, refreshToken);
    await _prefs.setString('user_phone', phone);
  }

  @override
  Future<void> clearAuthData() async {
    await _prefs.remove(StorageKeys.authToken);
    await _prefs.remove(StorageKeys.refreshToken);
    await _prefs.remove('user_phone');
    await _prefs.remove(StorageKeys.userId);
    await _prefs.remove(StorageKeys.userRole);
    await _prefs.remove(StorageKeys.restaurantId);
  }

  /// Maps API errors to user-friendly failure messages
  Failure _mapAuthError(ApiException error, String context) {
    final message = error.message.toLowerCase();
    final statusCode = error.statusCode;

    // Prioritize context-specific errors first
    // For OTP verification context, any 400-level error is likely an invalid OTP
    if (context == 'otp_verify' && (statusCode == 400 || statusCode == 401)) {
      if (message.contains('expired')) {
        return AuthFailure(message: 'errors.auth.otpExpired'.tr);
      }
      // Any other 400/401 error during OTP verification is treated as invalid OTP
      return AuthFailure(message: 'errors.auth.invalidOtp'.tr);
    }

    // For OTP request context, handle phone-specific errors
    if (context == 'otp_request' && statusCode == 400) {
      if (message.contains('invalid') && message.contains('phone')) {
        return ValidationFailure(message: 'errors.auth.invalidPhone'.tr);
      }
    }

    // Handle specific error messages from API
    if (message.contains('invalid') && message.contains('otp')) {
      return AuthFailure(message: 'errors.auth.invalidOtp'.tr);
    }
    if (message.contains('expired')) {
      return AuthFailure(message: 'errors.auth.otpExpired'.tr);
    }
    if (message.contains('not found') || message.contains('no user')) {
      return AuthFailure(message: 'errors.auth.phoneNotFound'.tr);
    }
    if (message.contains('already') && message.contains('registered')) {
      return AuthFailure(message: 'errors.auth.phoneAlreadyRegistered'.tr);
    }
    if (message.contains('too many') || statusCode == 429) {
      return AuthFailure(message: 'errors.auth.tooManyAttempts'.tr);
    }

    // Handle by status code
    switch (statusCode) {
      case 400:
        return ValidationFailure(message: 'errors.auth.invalidPhone'.tr);
      case 401:
        return AuthFailure(message: 'errors.auth.unauthorized'.tr);
      case 403:
        return AuthFailure(message: 'errors.auth.forbidden'.tr);
      case 404:
        if (context == 'otp_request') {
          return AuthFailure(message: 'errors.auth.phoneNotFound'.tr);
        }
        return ServerFailure(message: 'errors.notFound'.tr);
      case 422:
        return ValidationFailure(message: error.message);
      case 429:
        return AuthFailure(message: 'errors.auth.tooManyAttempts'.tr);
      case 500:
      case 502:
      case 503:
        return ServerFailure(message: 'errors.server'.tr);
      default:
        return ServerFailure(message: error.message);
    }
  }
}
