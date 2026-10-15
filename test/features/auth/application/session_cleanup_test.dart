import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teybatseller/core/config/constants.dart';
import 'package:teybatseller/core/network/notifications_api.dart';
import 'package:teybatseller/core/providers/providers.dart';
import 'package:teybatseller/core/services/push_notification_service.dart';
import 'package:teybatseller/core/services/session_lifecycle.dart';
import 'package:teybatseller/features/auth/application/auth_state.dart';
import 'package:teybatseller/features/auth/data/datasources/auth_data_source.dart';
import 'package:teybatseller/features/auth/data/repositories/auth_repository.dart';
import 'package:teybatseller/features/notifications/application/notifications_notifier.dart';

class FakeSource implements AuthDataSource {
  FakeSource(this.prefs, this.events);
  final SharedPreferences prefs;
  final List<String> events;
  @override
  Future<void> logout(String refreshToken) async {
    expect(refreshToken, 'refresh');
    expect(prefs.getString(StorageKeys.authToken), 'access');
    events.add('logout');
    throw DioException(
      requestOptions: RequestOptions(path: '/logout'),
      type: DioExceptionType.connectionError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeMessaging implements FirebaseMessaging {
  FakeMessaging(this.events);
  final List<String> events;
  Completer<void>? deletion;
  Completer<String?>? token;
  @override
  Future<void> setAutoInitEnabled(bool enabled) async {
    events.add('auto:$enabled');
  }

  @override
  Future<void> deleteToken() async {
    events.add('delete');
    await deletion?.future;
  }

  @override
  Future<String?> getToken({
    String? vapidKey,
    String? serviceWorkerScriptPath,
  }) async {
    events.add('getToken');
    return token?.future;
  }

  @override
  Stream<String> get onTokenRefresh => const Stream.empty();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeNotifications implements FlutterLocalNotificationsPlugin {
  FakeNotifications(this.events);
  final List<String> events;
  @override
  Future<void> cancelAll() async {
    events.add('clear-alerts');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakePush extends PushNotificationService {
  FakePush(FakeMessaging messaging, List<String> events)
    : super(
        messaging: messaging,
        localNotifications: FakeNotifications(events),
      );
  @override
  Future<void> initialize() async {}
  @override
  Future<bool> prepare(int generation) async =>
      SessionLifecycle.instance.isAuthenticated(generation);
}

class FakeApi extends NotificationsApi {
  FakeApi(this.prefs, this.events) : super(Dio());
  final SharedPreferences prefs;
  final List<String> events;
  int registrations = 0;
  @override
  Future<void> unregisterDeviceToken({
    required String token,
    required String? access,
  }) async {
    expect(token, 'device');
    expect(access, 'access');
    expect(prefs.getString(StorageKeys.refreshToken), 'refresh');
    events.add('unregister');
    throw DioException(
      requestOptions: RequestOptions(path: '/device'),
      response: Response(
        requestOptions: RequestOptions(path: '/device'),
        statusCode: 401,
      ),
    );
  }

  @override
  Future<void> registerDeviceToken({
    required String token,
    String? deviceType,
  }) async {
    registrations++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final session = SessionLifecycle.instance;
  late SharedPreferences prefs;
  late ProviderContainer container;
  late List<String> events;
  late FakeMessaging messaging;
  late FakeApi api;

  setUp(() async {
    await session.end(() async {});
    session.accept(await session.beginLogin());
    SharedPreferences.setMockInitialValues({
      StorageKeys.authToken: 'access',
      StorageKeys.refreshToken: 'refresh',
      StorageKeys.fcmToken: 'device',
      'user_phone': '+963999999999',
      StorageKeys.restaurantId: '42',
    });
    prefs = await SharedPreferences.getInstance();
    events = [];
    messaging = FakeMessaging(events);
    api = FakeApi(prefs, events);
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authRepositoryProvider.overrideWithValue(
          AuthRepositoryImpl(
            remoteDataSource: FakeSource(prefs, events),
            prefs: prefs,
          ),
        ),
        pushNotificationServiceProvider.overrideWithValue(
          FakePush(messaging, events),
        ),
        notificationsApiProvider.overrideWithValue(api),
      ],
    );
    container.read(authProvider);
  });
  tearDown(() {
    container.dispose();
  });

  test(
    'manual logout unregisters and revokes before credentials, even offline/401',
    () async {
      await container.read(authProvider.notifier).logout();
      expect(events, [
        'unregister',
        'logout',
        'auto:false',
        'delete',
        'clear-alerts',
      ]);
      expect(prefs.getString(StorageKeys.authToken), isNull);
      expect(prefs.getString(StorageKeys.refreshToken), isNull);
      expect(prefs.getString(StorageKeys.restaurantId), isNull);
      expect(prefs.getString(StorageKeys.fcmToken), isNull);
      expect(container.read(authProvider), isA<AuthUnauthenticated>());
    },
  );

  test(
    'forced logout performs SDK and local cleanup without usable network credentials',
    () async {
      await container.read(authProvider.notifier).handleUnauthorized();
      expect(events, ['auto:false', 'delete', 'clear-alerts']);
      expect(prefs.getString(StorageKeys.authToken), isNull);
      expect(prefs.getString(StorageKeys.fcmToken), isNull);
    },
  );

  test('same-account re-login waits for actual old SDK deletion', () async {
    messaging.deletion = Completer<void>();
    final logout = container.read(authProvider.notifier).handleUnauthorized();
    await Future<void>.delayed(Duration.zero);
    expect(events, contains('delete'));
    var ready = false;
    final next = session.beginLogin().then((value) {
      ready = true;
      return value;
    });
    await Future<void>.delayed(Duration.zero);
    expect(ready, isFalse);
    messaging.deletion!.complete();
    await logout;
    final generation = await next;
    await prefs.setString(StorageKeys.authToken, 'new-access');
    session.accept(generation);
    expect(prefs.getString(StorageKeys.authToken), 'new-access');
    expect(events.where((e) => e == 'delete').length, 1);
  });

  test(
    'late getToken cannot register after logout or delete a new login token',
    () async {
      messaging.token = Completer<String?>();
      final subscription = container.listen(fcmTokenProvider, (_, _) {});
      // FakePush skips platform initialization; token-refresh subscription needs a
      // platform stream, which Firebase exposes without any network calls.
      await Future<void>.delayed(Duration.zero);
      expect(events, contains('getToken'));
      final logout = container.read(authProvider.notifier).handleUnauthorized();
      messaging.token!.complete('old-device');
      await logout;
      expect(api.registrations, 0);
      expect(prefs.getString(StorageKeys.fcmToken), isNull);
      subscription.close();
    },
  );
}
