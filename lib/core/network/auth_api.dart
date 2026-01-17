/// Auth API service using Dio directly
/// Simple, dependency-free implementation for better compatibility
library auth_api;

import 'package:dio/dio.dart';

import '../../features/auth/data/models/auth_model.dart';

/// Auth API service for authentication endpoints
class AuthApi {
  final Dio _dio;

  AuthApi(this._dio);

  /// Request OTP for phone number
  /// POST /api/auth/otp/request/
  Future<OtpRequestResponse> requestOtp(OtpRequest request) async {
    final response = await _dio.post(
      '/api/auth/otp/request/',
      data: request.toJson(),
    );
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

  /// Blacklist token (logout)
  /// POST /api/auth/token/blacklist/
  Future<void> blacklistToken(TokenBlacklistRequest request) async {
    await _dio.post(
      '/api/auth/token/blacklist/',
      data: request.toJson(),
    );
  }
}
