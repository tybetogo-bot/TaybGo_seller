/// Auth data source interface
library;

import '../models/auth_model.dart';

/// Abstract auth data source interface
abstract class AuthDataSource {
  /// Request OTP for phone number
  Future<OtpRequestResponse> requestOtp({required String phone});

  /// Verify OTP code and get tokens
  Future<OtpVerifyResponse> verifyOtp({
    required String phone,
    required String code,
  });

  /// Refresh access token
  Future<TokenRefreshResponse> refreshToken(String refreshToken);

  /// Verify the current access token/session
  Future<void> verifyToken(String accessToken);

  /// Logout user (blacklist token)
  Future<void> logout(String refreshToken);
}
