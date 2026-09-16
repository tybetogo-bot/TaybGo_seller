import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/constants.dart';
import '../providers/providers.dart';
import '../../features/notifications/application/notifications_notifier.dart';
import '../../features/notifications/application/notification_settings_notifier.dart';

/// Top-level background message handler (must be top-level function).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('🔔 [FCM] Background message: ${message.messageId}');
}

const _iosNotificationSound = 'notif_sound.caf';
const _androidNotificationChannelPrefix = 'seller_order_alerts_v3';

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
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
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
    Future<void>.microtask(() => handler(pendingData));
  }

  /// Callback invoked when a foreground message is received.
  /// Use this to refresh in-app notification lists.
  void Function(RemoteMessage message)? onForegroundMessage;

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  /// Call once after [Firebase.initializeApp] and after the widget tree is up.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      // On web, only set up message listeners — skip native-only APIs.
      if (kIsWeb) {
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
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

      // Create one channel per supported sound profile. Android channel sound
      // settings are immutable after first creation, so each repeat count needs
      // its own versioned channel. The v3 IDs also avoid stale silent channels
      // created by earlier app versions.
      await _createAndroidNotificationChannels();

      // Request permission (shows the OS dialog on iOS / Android 13+).
      await requestPermission();

      // Listen for foreground messages.
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Listen for notification taps that open the app from background.
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Check if the app was opened from a terminated-state notification.
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      // iOS foreground presentation options.
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
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
    try {
      final token = await _messaging.getToken();
      final preview = token == null
          ? 'null'
          : '${token.substring(0, token.length < 20 ? token.length : 20)}...';
      print('🔔 [FCM] Token: $preview');
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
    return _messaging.onTokenRefresh.listen(onRefresh);
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
    await _localNotifications.show(
      _notificationId(message),
      notification.title,
      notification.body,
      details,
      payload: jsonEncode(message.data),
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
  final service = ref.watch(pushNotificationServiceProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  final api = ref.watch(notificationsApiProvider);

  Future<void> registerToken(String token, {required String logPrefix}) async {
    await prefs.setString(StorageKeys.fcmToken, token);
    await api.registerDeviceToken(token: token, deviceType: _deviceType);
    print('🔔 [FCM] $logPrefix token registered with backend');
  }

  // Register refresh handling before reading the current token so a token
  // that becomes available asynchronously is not missed.
  final tokenRefreshSubscription = service.onTokenRefresh((newToken) async {
    try {
      await registerToken(newToken, logPrefix: 'Refreshed');
    } catch (e) {
      print('🔴 [FCM] Failed to register refreshed token: $e');
    }
  });
  ref.onDispose(tokenRefreshSubscription.cancel);

  // Get current token.
  final token = await service.getToken();
  if (token == null) return null;

  // Register on every authenticated shell activation. The same device token
  // can belong to a different seller after logout/login, so a local token
  // cache alone is not enough to decide whether the backend needs it.
  try {
    await registerToken(token, logPrefix: 'Current');
  } catch (e) {
    print('🔴 [FCM] Failed to register token with backend: $e');
  }

  return token;
});

String get _deviceType {
  if (kIsWeb) return 'web';
  return defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
}
