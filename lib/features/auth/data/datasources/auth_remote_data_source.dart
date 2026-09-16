/// Remote auth data source implementation using API
library;

import '../../../../core/network/auth_api.dart';
import '../models/auth_model.dart';
import 'auth_data_source.dart';

/// Implementation of auth data source using the API
class AuthRemoteDataSource implements AuthDataSource {
  AuthRemoteDataSource(this._authApi);

  final AuthApi _authApi;

  @override
  Future<PasswordLoginResponse> loginWithPassword({
    required String phone,
    required String password,
  }) {
    return _authApi.loginWithPassword(
      PasswordLoginRequest(phone: phone, password: password),
    );
  }

  @override
  Future<OtpRequestResponse> requestOtp({
    required String phone,
    required String targetRole,
  }) async {
    final request = OtpRequest(phone: phone, targetRole: targetRole);
    return await _authApi.requestOtp(request);
  }

  @override
  Future<OtpVerifyResponse> verifyOtp({
    required String phone,
    required String code,
    required String targetRole,
  }) async {
    final request = OtpVerifyRequest(
      phone: phone,
      code: code,
      targetRole: targetRole,
    );
    return await _authApi.verifyOtp(request);
  }

  @override
  Future<TokenRefreshResponse> refreshToken(String refreshToken) async {
    final request = TokenRefreshRequest(refresh: refreshToken);
    return await _authApi.refreshToken(request);
  }

  @override
  Future<void> verifyToken(String accessToken) async {
    final request = TokenVerifyRequest(token: accessToken);
    await _authApi.verifyToken(request);
  }

  @override
  Future<void> logout(String refreshToken) async {
    final request = TokenBlacklistRequest(refresh: refreshToken);
    await _authApi.blacklistToken(request);
  }
}
