import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/constants.dart';
import 'session_lifecycle.dart';
import 'clear_web_notifications_stub.dart'
    if (dart.library.js_interop) 'clear_web_notifications_web.dart';
import '../../features/auth/application/auth_state.dart';
import '../providers/providers.dart';
import '../../features/notifications/application/notifications_notifier.dart';
import '../../features/notifications/application/notification_settings_notifier.dart';

/// Top-level background message handler (must be top-level function).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('🔔 [FCM] Background message: ${message.messageId}');
}

// Remote APNs alerts use notif_sound.caf (29 seconds). Keep the short tone
// separate for foreground alerts and their user-selected repeat settings.
const _iosNotificationSound = 'notif_sound_1.caf';
const _androidNotificationChannelPrefix = 'seller_order_alerts_v3';
const _androidBackgroundNotificationChannelId = 'seller_background_alerts_v2';
const _androidBackgroundNotificationSoundResource = 'notif_background';

String _androidNotificationChannelId(int repeatCount) {
  return '${_androidNotificationChannelPrefix}_$repeatCount';
}

String _androidNotificationSoundResource(int repeatCount) {
  return repeatCount == 1 ? 'notif_sound' : 'notif_sound_$repeatCount';
}

String _iosNotificationSoundResource(int repeatCount) {
  return repeatCount == 1
      ? _iosNotificationSound
      : 'notif_sound_$repeatCount.caf';
}

/// Decode the payload stored on a foreground local notification.
///
/// FCM data is JSON-serializable, so using JSON here keeps the payload intact
/// instead of relying on Dart's non-parseable [Map.toString] format.
Map<String, dynamic> decodeLocalNotificationPayload(String? payload) {
  if (payload == null || payload.trim().isEmpty) return const {};

  try {
    final decoded = jsonDecode(payload);
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
  } catch (_) {
    // Treat malformed payloads as generic notifications.
  }

  return const {};
}

/// Service that manages Firebase Cloud Messaging and local notifications.
class PushNotificationService {
  PushNotificationService({
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
  }) : _messagingOverride = messaging,
       _localNotifications =
           localNotifications ?? FlutterLocalNotificationsPlugin();

  static final PushNotificationService instance = PushNotificationService();

  final FirebaseMessaging? _messagingOverride;
  FirebaseMessaging get _messaging =>
      _messagingOverride ?? FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications;

  bool _initialized = false;
  final _session = SessionLifecycle.instance;
  final List<StreamSubscription<RemoteMessage>> _messageSubscriptions = [];
  StreamSubscription<String>? _tokenSubscription;
  Future<void>? _initialization;
  Future<void>? _tokenCancellation;

  void pause() {
    _pendingNotificationTapData = null;
    _onNotificationTap = null;
    onForegroundMessage = null;
    if (_tokenSubscription != null) {
      _tokenCancellation = _tokenSubscription!.cancel();
    }
    _tokenSubscription = null;
  }

  Future<void> cleanup() async {
    pause();
    // Keep the barrier until actual SDK completion, even if it takes a while.
    await _tokenCancellation;
    await _initialization;
    for (final subscription in _messageSubscriptions) {
      await subscription.cancel();
    }
    _messageSubscriptions.clear();
    _initialized = false;
    _initialization = null;
    try {
      await _messaging.setAutoInitEnabled(false);
    } catch (_) {}
    try {
      await _messaging.deleteToken();
    } catch (_) {}
    if (kIsWeb) {
      try {
        await clearWebNotifications();
      } catch (_) {}
    } else {
      try {
        await _localNotifications.cancelAll();
      } catch (_) {}
    }
  }

  Future<bool> prepare(int generation) async {
    await _session.settled;
    if (!_session.isAuthenticated(generation)) return false;
    await initialize();
    if (!_session.isAuthenticated(generation)) return false;
    // Web permission must remain a user gesture; never prompt from token work.
    final allowed = kIsWeb
        ? (await _messaging.getNotificationSettings()).authorizationStatus ==
              AuthorizationStatus.authorized
        : await requestPermission();
    if (!_session.isAuthenticated(generation) || !allowed) return false;
    await _messaging.setAutoInitEnabled(true);
    return _session.isAuthenticated(generation);
  }

  Map<String, dynamic>? _pendingNotificationTapData;
  void Function(Map<String, dynamic> data)? _onNotificationTap;

  /// Callback invoked when the user taps a notification.
  /// Set this from the app layer to handle navigation.
  void Function(Map<String, dynamic> data)? get onNotificationTap =>
      _onNotificationTap;

  set onNotificationTap(void Function(Map<String, dynamic> data)? handler) {
    _onNotificationTap = handler;

    // A terminated-state tap can be delivered before the app shell has had a
    // chance to register its navigation callback. Replay it once the handler
    // is available so the notification is not silently lost.
    final pendingData = _pendingNotificationTapData;
    if (handler == null || pendingData == null) return;

    _pendingNotificationTapData = null;
    final generation = _session.generation;
    Future<void>.microtask(() {
      if (_session.isAuthenticated(generation)) handler(pendingData);
    });
  }

  /// Callback invoked when a foreground message is received.
  /// Use this to refresh in-app notification lists.
  void Function(RemoteMessage message)? onForegroundMessage;

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  /// Call once after [Firebase.initializeApp] and after the widget tree is up.
  Future<void> initialize() => _initialization ??= _initialize();

  Future<void> _initialize() async {
    if (_initialized) return;
    final generation = _session.generation;
    _initialized = true;

    try {
      // On web, only set up message listeners — skip native-only APIs.
      if (kIsWeb) {
        _messageSubscriptions.add(
          FirebaseMessaging.onMessage.listen(_handleForegroundMessage),
        );
        _messageSubscriptions.add(
          FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap),
        );
        // Don't request permission at startup on web — browsers block the
        // dialog unless triggered by a user gesture. Permission will be
        // requested later when the user interacts with notification settings.
        print('🔔 [FCM] Web push listeners registered (permission deferred)');
        return;
      }

      // Register the background handler (mobile only).
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Initialize local notifications plugin.
      await _localNotifications.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
        onDidReceiveNotificationResponse: _onLocalNotificationTap,
      );

      final localLaunch = await _localNotifications
          .getNotificationAppLaunchDetails();
      if (_session.isAuthenticated(generation) &&
          (localLaunch?.didNotificationLaunchApp ?? false)) {
        _dispatchNotificationTap(
          decodeLocalNotificationPayload(
            localLaunch?.notificationResponse?.payload,
          ),
        );
      }

      // Create one channel per supported sound profile. Android channel sound
      // settings are immutable after first creation, so each repeat count needs
      // its own versioned channel. The v3 IDs also avoid stale silent channels
      // created by earlier app versions.
      await _createAndroidNotificationChannels();

      if (!_session.isAuthenticated(generation)) return;

      // Listen for foreground messages.
      _messageSubscriptions.add(
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage),
      );

      // Listen for notification taps that open the app from background.
      _messageSubscriptions.add(
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap),
      );

      // Check if the app was opened from a terminated-state notification.
      final initialMessage = await _messaging.getInitialMessage();
      if (_session.isAuthenticated(generation) && initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      // iOS foreground presentation options.
      await _messaging.setForegroundNotificationPresentationOptions(
        // The local notification below presents the foreground alert and
        // configured sound; also presenting the remote alert duplicates it.
        alert: false,
        badge: false,
        sound: false,
      );

      print('🔔 [FCM] Push notification service initialized');
    } catch (e) {
      print('🔴 [FCM] Initialization error (non-fatal): $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Permission
  // ---------------------------------------------------------------------------

  /// Request notification permission. Returns `true` if authorized.
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    final authorized =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    print('🔔 [FCM] Permission status: ${settings.authorizationStatus}');
    return authorized;
  }

  // ---------------------------------------------------------------------------
  // FCM Token
  // ---------------------------------------------------------------------------

  /// Retrieve the current FCM token and persist it locally.
  Future<String?> getToken() async {
    final generation = _session.generation;
    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        // APNs registration can finish after permission and app startup.
        // Token refresh remains subscribed while this bounded wait runs.
        String? apnsToken;
        for (var attempt = 0; attempt < 10; attempt++) {
          if (!_session.isAuthenticated(generation)) return null;
          apnsToken = await _messaging.getAPNSToken();
          if (apnsToken != null) break;
          await Future<void>.delayed(const Duration(milliseconds: 500));
        }
        if (apnsToken == null) {
          print('🟡 [FCM] APNs token is not ready; waiting for token refresh');
          return null;
        }
      }
      if (!_session.isAuthenticated(generation)) return null;
      final token = await _messaging.getToken();
      if (!_session.isAuthenticated(generation)) return null;
      print('🔔 [FCM] Token available: ${token != null}');
      return token;
    } catch (e) {
      print('🔴 [FCM] Failed to get token: $e');
      return null;
    }
  }

  /// Listen for token refreshes and call [onRefresh] with the new token.
  StreamSubscription<String> onTokenRefresh(
    void Function(String token) onRefresh,
  ) {
    _tokenSubscription = _messaging.onTokenRefresh.listen(onRefresh);
    return _tokenSubscription!;
  }

  // ---------------------------------------------------------------------------
  // Message handlers
  // ---------------------------------------------------------------------------

  Future<void> _createAndroidNotificationChannels() async {
    final androidNotifications = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidNotifications == null) return;

    // FCM uses this channel when Android displays a notification while the app
    // is backgrounded or closed. Keep it separate from the configurable
    // foreground order-alert channels so foreground preferences remain intact.
    await androidNotifications.createNotificationChannel(
      const AndroidNotificationChannel(
        _androidBackgroundNotificationChannelId,
        'Background Notifications',
        description: 'Notifications received while the app is not open.',
        importance: Importance.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(
          _androidBackgroundNotificationSoundResource,
        ),
      ),
    );

    for (final repeatCount
        in AppNotificationSettings.supportedOrderAlertRepeatCounts) {
      await androidNotifications.createNotificationChannel(
        AndroidNotificationChannel(
          _androidNotificationChannelId(repeatCount),
          'High Importance Notifications',
          description: 'This channel is used for important notifications.',
          importance: Importance.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound(
            _androidNotificationSoundResource(repeatCount),
          ),
        ),
      );
    }
  }

  /// Show a local notification when a message arrives while the app is in
  /// the foreground.
  void _handleForegroundMessage(RemoteMessage message) {
    if (!_session.authenticated || _session.closing) return;
    print('🔔 [FCM] Foreground message: ${message.notification?.title}');

    // Notify listeners (e.g. to refresh notification list).
    onForegroundMessage?.call(message);

    final notification = message.notification;
    if (notification == null || kIsWeb) return;

    unawaited(_showForegroundNotification(message, notification));
  }

  Future<void> _showForegroundNotification(
    RemoteMessage message,
    RemoteNotification notification,
  ) async {
    final generation = _session.generation;
    if (!_session.isAuthenticated(generation)) return;
    var repeatCount = 1;
    if (message.data['type']?.toString() == 'new_order') {
      try {
        final prefs = await SharedPreferences.getInstance();
        repeatCount = AppNotificationSettings.fromPreferences(
          prefs,
        ).orderAlertRepeatCount;
      } catch (e) {
        print('🟡 [FCM] Could not load notification preferences: $e');
      }
    }

    final android = notification.android;
    final normalizedRepeatCount =
        AppNotificationSettings.supportedOrderAlertRepeatCounts.contains(
          repeatCount,
        )
        ? repeatCount
        : AppNotificationSettings.defaultOrderAlertRepeatCount;
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _androidNotificationChannelId(normalizedRepeatCount),
        'High Importance Notifications',
        channelDescription: 'This channel is used for important notifications.',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(
          _androidNotificationSoundResource(normalizedRepeatCount),
        ),
        icon: android?.smallIcon ?? '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: _iosNotificationSoundResource(normalizedRepeatCount),
      ),
    );

    // The selected platform sound contains the requested number of alert
    // plays. Posting one notification prevents Android from rate-limiting or
    // coalescing repeated notification entries in the tray.
    if (!_session.isAuthenticated(generation)) return;
    await _session.trackPush(
      () => _localNotifications.show(
        _notificationId(message),
        notification.title,
        notification.body,
        details,
        payload: jsonEncode(message.data),
      ),
    );
  }

  int _notificationId(RemoteMessage message) {
    final baseId = message.hashCode & 0x7fffffff;
    return baseId;
  }

  /// Called when the user taps a notification that opened the app from
  /// background/terminated state.
  void _handleNotificationTap(RemoteMessage message) {
    print('🔔 [FCM] Notification tap: ${message.data}');
    _dispatchNotificationTap(message.data);
  }

  /// Called when the user taps a local (foreground) notification.
  void _onLocalNotificationTap(NotificationResponse response) {
    print('🔔 [FCM] Local notification tap: ${response.payload}');
    _dispatchNotificationTap(decodeLocalNotificationPayload(response.payload));
  }

  void _dispatchNotificationTap(Map<String, dynamic> data) {
    if (!_session.authenticated || _session.closing) return;
    final handler = _onNotificationTap;
    if (handler == null) {
      _pendingNotificationTapData = Map<String, dynamic>.from(data);
      return;
    }

    handler(data);
  }
}

// ---------------------------------------------------------------------------
// Riverpod integration
// ---------------------------------------------------------------------------

/// Provider that exposes the singleton [PushNotificationService].
final pushNotificationServiceProvider = Provider<PushNotificationService>((_) {
  return PushNotificationService.instance;
});

/// Provider that initializes FCM, retrieves the token, registers it with
/// the backend, and listens for token refreshes.
///
/// This should be watched from a widget that is alive while the user is
/// authenticated (e.g. the main shell or splash screen).
final fcmTokenProvider = FutureProvider.autoDispose<String?>((ref) async {
  ref.watch(sessionGenerationProvider);
  if (!ref.watch(isAuthenticatedProvider)) return null;
  final session = SessionLifecycle.instance;
  final generation = session.generation;
  final service = ref.watch(pushNotificationServiceProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  final api = ref.watch(notificationsApiProvider);
  bool current() => ref.mounted && session.isAuthenticated(generation);

  Future<void> registerToken(String token) => session.trackPush(() async {
    if (!current()) return;
    await session.serializeWrite(() async {
      if (current()) await prefs.setString(StorageKeys.fcmToken, token);
    });
    if (!current()) return;
    await api.registerDeviceToken(token: token, deviceType: _deviceType);
  });

  // Initialization, APNs waits and actual token creation are drained by logout.
  String? token;
  await session.trackPush(() async {
    if (!await service.prepare(generation) || !current()) return;
    final subscription = service.onTokenRefresh((newToken) async {
      try {
        await registerToken(newToken);
      } catch (_) {}
    });
    ref.onDispose(subscription.cancel);
    token = await service.getToken();
    if (token != null && current()) await registerToken(token!);
  });
  return current() ? token : null;
});

String get _deviceType {
  if (kIsWeb) return 'web';
  return defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
}
