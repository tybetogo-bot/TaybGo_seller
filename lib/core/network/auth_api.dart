/// Auth API service using Dio directly
/// Simple, dependency-free implementation for better compatibility
library auth_api;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../features/auth/data/models/auth_model.dart';
import '../config/constants.dart';

/// Auth API service for authentication endpoints
class AuthApi {
  final Dio _dio;

  AuthApi(this._dio);

  /// Authenticate a password-only role and get tokens.
  /// POST /api/auth/token/
  Future<PasswordLoginResponse> loginWithPassword(
    PasswordLoginRequest request,
  ) async {
    final response = await _dio.post(
      '/api/auth/token/',
      data: request.toJson(),
    );
    return PasswordLoginResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// Request OTP for phone number
  /// POST /api/auth/otp/request/
  Future<OtpRequestResponse> requestOtp(OtpRequest request) async {
    final response = await _dio.post(
      '/api/auth/otp/request/',
      data: request.toJson(),
    );
    debugPrint('[requestOtp] response: ${response.data}');
    return OtpRequestResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Verify OTP and get tokens
  /// POST /api/auth/otp/verify/
  Future<OtpVerifyResponse> verifyOtp(OtpVerifyRequest request) async {
    final response = await _dio.post(
      '/api/auth/otp/verify/',
      data: request.toJson(),
    );
    return OtpVerifyResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Refresh access token
  /// POST /api/auth/token/refresh/
  Future<TokenRefreshResponse> refreshToken(TokenRefreshRequest request) async {
    final response = await _dio.post(
      '/api/auth/token/refresh/',
      data: request.toJson(),
    );
    return TokenRefreshResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Verify access token
  /// POST /api/auth/token/verify/
  Future<void> verifyToken(TokenVerifyRequest request) async {
    await _dio.post('/api/auth/token/verify/', data: request.toJson());
  }

  /// Revoke the current login family, using credentials captured before cleanup.
  Future<void> logout(String refresh, String? access) async {
    await _dio.post(
      ApiEndpoints.logout,
      data: {'refresh': refresh},
      options: Options(
        headers: {'Authorization': 'Bearer $access'},
        extra: {
          'sessionCleanup': true,
          'skipAuthRefresh': true,
          'disableRetry': true,
        },
      ),
    );
  }

  /// Blacklist token (logout)
  /// POST /api/auth/token/blacklist/
  Future<void> blacklistToken(TokenBlacklistRequest request) async {
    await _dio.post('/api/auth/token/blacklist/', data: request.toJson());
  }
}
