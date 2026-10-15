import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:teybatseller/core/network/public_config_api.dart';
import 'package:teybatseller/core/config/public_app_config.dart';

void main() {
  test(
    'public config works with production CORS while logout is pending',
    () async {
      final dio = Dio();
      RequestOptions? captured;
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            captured = options;
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.cancel,
              ),
            );
          },
        ),
      );
      await expectLater(
        PublicConfigApi(dio).fetch(currentVersion: '1.0.22'),
        throwsA(isA<DioException>()),
      );
      expect(
        captured!.headers.keys.map((key) => key.toLowerCase()),
        isNot(contains('cache-control')),
      );
      expect(captured!.extra['anonymous'], isTrue);
      expect(captured!.queryParameters['current_version'], '1.0.22');
      expect(captured!.queryParameters['_'], isA<int>());
    },
  );

  group('PublicAppConfig', () {
    test(
      'parses the flat dotted-key response and selects password for seller',
      () {
        final config = PublicAppConfig.fromJson({
          'auth.otp_enabled_roles': ['customer'],
          'auth.password_only_roles': ['seller', 'driver', 'admin'],
          'app.latest_version': '1.2.0',
          'app.min_supported_version': '1.1.0',
          'app.force_update': true,
          'app.update_url': '/download/',
          'legal.privacy_url': '/privacy-policy/',
          'legal.terms_url': '/terms-and-conditions/',
          'legal.support_url': '/contact/',
        });

        expect(config.usesPasswordFor('seller'), isTrue);
        expect(config.usesOtpFor('seller'), isFalse);
        expect(config.forceUpdate, isTrue);
        expect(config.updateUrl, '/download/');
      },
    );

    test(
      'password wins when a malformed response contains a role in both lists',
      () {
        final config = PublicAppConfig.fromJson({
          'auth.otp_enabled_roles': ['seller'],
          'auth.password_only_roles': ['seller'],
          'app.latest_version': '1.0.0',
          'app.min_supported_version': '1.0.0',
          'app.force_update': false,
          'app.update_url': null,
          'legal.privacy_url': '/privacy/',
          'legal.terms_url': '/terms/',
          'legal.support_url': '/support/',
        });

        expect(config.usesPasswordFor('seller'), isTrue);
        expect(config.usesOtpFor('seller'), isFalse);
      },
    );

    test('rejects a response missing required URLs', () {
      expect(
        () => PublicAppConfig.fromJson({
          'auth.otp_enabled_roles': ['customer'],
          'auth.password_only_roles': ['seller'],
          'app.latest_version': '1.0.0',
          'app.min_supported_version': '1.0.0',
          'app.force_update': false,
          'app.update_url': null,
        }),
        throwsFormatException,
      );
    });
  });
}
