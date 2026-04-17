import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teybatseller/core/config/constants.dart';
import 'package:teybatseller/core/errors/exceptions.dart';
import 'package:teybatseller/core/errors/failures.dart';
import 'package:teybatseller/core/i18n/i18n.dart';
import 'package:teybatseller/core/i18n/translation_service.dart';
import 'package:teybatseller/features/auth/data/datasources/auth_data_source.dart';
import 'package:teybatseller/features/auth/data/models/auth_model.dart';
import 'package:teybatseller/features/auth/data/repositories/auth_repository.dart';

class _ThrowingAuthDataSource implements AuthDataSource {
  _ThrowingAuthDataSource(this.exception);

  final DioException exception;

  @override
  Future<void> logout(String refreshToken) async {}

  @override
  Future<OtpRequestResponse> requestOtp({
    required String phone,
    required String targetRole,
  }) async {
    throw exception;
  }

  @override
  Future<TokenRefreshResponse> refreshToken(String refreshToken) async {
    throw UnimplementedError();
  }

  @override
  Future<OtpVerifyResponse> verifyOtp({
    required String phone,
    required String code,
    required String targetRole,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> verifyToken(String accessToken) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await TranslationService.instance.load(const Locale('en'));
  });

  test(
    'requestOtp maps 409 conflicts to the localized user exists message',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final requestOptions = RequestOptions(path: '/api/auth/otp/request/');
      const backendMessage =
          'A user with this phone number already exists in another role.';

      final repository = AuthRepositoryImpl(
        remoteDataSource: _ThrowingAuthDataSource(
          DioException(
            requestOptions: requestOptions,
            response: Response(requestOptions: requestOptions, statusCode: 409),
            error: const ApiException(message: backendMessage, statusCode: 409),
            type: DioExceptionType.badResponse,
          ),
        ),
        prefs: prefs,
      );

      final result = await repository.requestOtp(
        phone: '+963999999999',
        targetRole: UserRoles.seller,
      );

      expect(result.failure, isA<AuthFailure>());
      expect(result.failure?.message, 'errors.auth.phoneAlreadyRegistered'.tr);
      expect(result.failure?.message, isNot(backendMessage));
      expect(result.data, isNull);
    },
  );
}
