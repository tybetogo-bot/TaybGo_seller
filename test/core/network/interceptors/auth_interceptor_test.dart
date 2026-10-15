import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teybatseller/core/config/constants.dart';
import 'package:teybatseller/core/network/interceptors/auth_interceptor.dart';
import 'package:teybatseller/core/network/api_client.dart';
import 'package:teybatseller/core/network/interceptors/retry_interceptor.dart';
import 'package:teybatseller/core/services/session_lifecycle.dart';

class Adapter implements HttpClientAdapter {
  Adapter(this.respond);
  final Future<ResponseBody> Function(RequestOptions) respond;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancelFuture,
  ) => respond(options);
  @override
  void close({bool force = false}) {}
}

ResponseBody jsonResponse(Object data, int status) => ResponseBody.fromString(
  jsonEncode(data),
  status,
  headers: {
    Headers.contentTypeHeader: ['application/json'],
  },
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final session = SessionLifecycle.instance;
  late SharedPreferences prefs;
  late Dio client;
  late Dio rotation;
  late int forced;

  setUp(() async {
    await session.end(() async {});
    final login = await session.beginLogin();
    session.accept(login);
    SharedPreferences.setMockInitialValues({
      StorageKeys.authToken: 'old-access',
      StorageKeys.refreshToken: 'old-refresh',
    });
    prefs = await SharedPreferences.getInstance();
    forced = 0;
    rotation = Dio(BaseOptions(baseUrl: 'https://test.invalid'));
    client = Dio(BaseOptions(baseUrl: 'https://test.invalid'));
    client.interceptors.add(
      AuthInterceptor(
        prefs,
        refreshDio: rotation,
        onUnauthorized: () async {
          forced++;
          await session.end(
            () => session.serializeWrite(() async {
              await prefs.remove(StorageKeys.authToken);
              await prefs.remove(StorageKeys.refreshToken);
            }),
          );
        },
      ),
    );
    client.httpClientAdapter = Adapter(
      (_) async => jsonResponse({'code': 'session_replaced'}, 401),
    );
  });

  tearDown(() {
    client.close();
    rotation.close();
  });

  test(
    'replacement tries refresh once then forces logout on rejection',
    () async {
      var calls = 0;
      rotation.httpClientAdapter = Adapter((_) async {
        calls++;
        return jsonResponse({'code': 'session_replaced'}, 401);
      });
      await expectLater(client.get('/protected'), throwsA(isA<DioException>()));
      expect(calls, 1);
      expect(forced, 1);
      expect(prefs.getString(StorageKeys.authToken), isNull);
    },
  );

  test(
    'refresh timeout preserves credentials and does not force logout',
    () async {
      rotation.httpClientAdapter = Adapter(
        (options) async => throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionTimeout,
        ),
      );
      await expectLater(
        client.get('/protected'),
        throwsA(
          isA<DioException>().having(
            (e) => e.type,
            'type',
            DioExceptionType.connectionTimeout,
          ),
        ),
      );
      expect(forced, 0);
      expect(prefs.getString(StorageKeys.refreshToken), 'old-refresh');
    },
  );

  test(
    'legacy verify replays with rotated access in both body and header',
    () async {
      var calls = 0;
      rotation.httpClientAdapter = Adapter((options) async {
        calls++;
        if (options.path == ApiEndpoints.tokenRefresh) {
          return jsonResponse({
            'access': 'new-access',
            'refresh': 'new-refresh',
          }, 200);
        }
        expect(options.headers['Authorization'], 'Bearer new-access');
        expect(options.data, {'token': 'new-access'});
        return jsonResponse({}, 200);
      });
      await client.post(
        ApiEndpoints.tokenVerify,
        data: {'token': 'old-access'},
      );
      expect(calls, 2);
      expect(forced, 0);
      expect(prefs.getString(StorageKeys.refreshToken), 'new-refresh');
    },
  );

  test(
    'failure of retried resource does not revoke a successfully refreshed login',
    () async {
      rotation.httpClientAdapter = Adapter(
        (options) async => options.path == ApiEndpoints.tokenRefresh
            ? jsonResponse({
                'access': 'new-access',
                'refresh': 'new-refresh',
              }, 200)
            : jsonResponse({}, 503),
      );
      await expectLater(client.get('/protected'), throwsA(isA<DioException>()));
      expect(forced, 0);
      expect(prefs.getString(StorageKeys.authToken), 'new-access');
    },
  );

  test(
    'late refresh cannot overwrite a new login, including same-account login',
    () async {
      final started = Completer<void>();
      final response = Completer<ResponseBody>();
      rotation.httpClientAdapter = Adapter((_) {
        started.complete();
        return response.future;
      });
      final result = expectLater(
        client.get('/protected'),
        throwsA(isA<DioException>()),
      );
      await started.future;
      await session.end(() async {});
      final login = await session.beginLogin();
      session.accept(login);
      await prefs.setString(StorageKeys.authToken, 'other-access');
      await prefs.setString(StorageKeys.refreshToken, 'other-refresh');
      response.complete(
        jsonResponse({
          'access': 'stale-access',
          'refresh': 'stale-refresh',
        }, 200),
      );
      await result;
      expect(forced, 0);
      expect(prefs.getString(StorageKeys.authToken), 'other-access');
      expect(prefs.getString(StorageKeys.refreshToken), 'other-refresh');
    },
  );

  test('concurrent 401 responses share one refresh', () async {
    var rotations = 0;
    rotation.httpClientAdapter = Adapter((options) async {
      if (options.path == ApiEndpoints.tokenRefresh) {
        rotations++;
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return jsonResponse({
          'access': 'new-access',
          'refresh': 'new-refresh',
        }, 200);
      }
      return jsonResponse({}, 200);
    });
    await Future.wait([client.get('/one'), client.get('/two')]);
    expect(rotations, 1);
    expect(forced, 0);
  });

  test(
    'a scheduled transport retry never uses the next login credentials',
    () async {
      final sent = Completer<void>();
      var sends = 0;
      client.httpClientAdapter = Adapter((options) async {
        sends++;
        sent.complete();
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        );
      });
      client.interceptors.add(
        RetryInterceptor(
          dio: client,
          maxRetries: 1,
          retryDelays: [const Duration(milliseconds: 20)],
        ),
      );
      final result = expectLater(
        client.post(
          ApiEndpoints.notificationDevice,
          data: {'token': 'previous-device'},
        ),
        throwsA(isA<DioException>()),
      );
      await sent.future;
      await session.end(() async {});
      session.accept(await session.beginLogin());
      await prefs.setString(StorageKeys.authToken, 'other-access');
      await result;
      expect(sends, 1);
    },
  );

  test(
    'rejected push registration can finish while forced cleanup drains it',
    () async {
      client.interceptors.clear();
      client.interceptors.add(
        AuthInterceptor(
          prefs,
          refreshDio: rotation,
          onUnauthorized: () => session.end(() async {
            await session.drainPush();
            await prefs.remove(StorageKeys.authToken);
          }),
        ),
      );
      rotation.httpClientAdapter = Adapter((_) async => jsonResponse({}, 401));
      await expectLater(
        session
            .trackPush(() async {
              await client.post(
                ApiEndpoints.notificationDevice,
                data: {'token': 'device'},
              );
            })
            .timeout(const Duration(seconds: 1)),
        throwsA(isA<DioException>()),
      );
      await session.settled;
      expect(prefs.getString(StorageKeys.authToken), isNull);
    },
  );

  test(
    'public configuration remains usable while SDK cleanup is pending',
    () async {
      final deletion = Completer<void>();
      final logout = session.end(() => deletion.future);
      client.httpClientAdapter = Adapter((options) async {
        expect(options.headers.containsKey('Authorization'), isFalse);
        return jsonResponse({}, 200);
      });
      await client.get('/public', options: Options(extra: {'anonymous': true}));
      deletion.complete();
      await logout;
      expect(forced, 0);
    },
  );

  test(
    'request creation captures the login before asynchronous interceptors run',
    () async {
      final productionClient = ApiClient.getInstance(prefs);
      var sends = 0;
      productionClient.httpClientAdapter = Adapter((_) async {
        sends++;
        return jsonResponse({}, 200);
      });
      final oldRequest = productionClient.post(
        ApiEndpoints.notificationDevice,
        data: {'token': 'previous-device'},
      );
      final result = expectLater(oldRequest, throwsA(isA<DioException>()));
      await session.end(() async {});
      session.accept(await session.beginLogin());
      await result;
      expect(sends, 0);
      ApiClient.reset();
    },
  );

  test('invalid password does not clean up another saved session', () async {
    await expectLater(
      client.post(ApiEndpoints.passwordLogin),
      throwsA(isA<DioException>()),
    );
    expect(forced, 0);
    expect(prefs.getString(StorageKeys.authToken), 'old-access');
  });
}
