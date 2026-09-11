/// Auth data source interface
library;

import '../models/auth_model.dart';

/// Abstract auth data source interface
abstract class AuthDataSource {
  Future<PasswordLoginResponse> loginWithPassword({
    required String phone,
    required String password,
  });

  /// Request OTP for phone number
  Future<OtpRequestResponse> requestOtp({
    required String phone,
    required String targetRole,
  });

  /// Verify OTP code and get tokens
  Future<OtpVerifyResponse> verifyOtp({
    required String phone,
    required String code,
    required String targetRole,
  });

  /// Refresh access token
  Future<TokenRefreshResponse> refreshToken(String refreshToken);

  /// Verify the current access token/session
  Future<void> verifyToken(String accessToken);

  /// Logout user (blacklist token)
  Future<void> logout(String refreshToken);
}
