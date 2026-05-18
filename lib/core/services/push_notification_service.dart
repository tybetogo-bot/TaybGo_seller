import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/constants.dart';
import '../providers/providers.dart';
import '../../features/notifications/application/notifications_notifier.dart';

/// Top-level background message handler (must be top-level function).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('🔔 [FCM] Background message: ${message.messageId}');
}

const _androidNotificationSound = RawResourceAndroidNotificationSound(
  'notif_sound',
);
const _iosNotificationSound = 'notif_sound.caf';

/// Android notification channel for high-importance messages.
const AndroidNotificationChannel _highImportanceChannel =
    AndroidNotificationChannel(
      // Channel settings are immutable after first creation on Android, so use
      // a versioned id when changing the sound configuration.
      'high_importance_channel_v2',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
      playSound: true,
      sound: _androidNotificationSound,
    );

/// Service that manages Firebase Cloud Messaging and local notifications.
class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Callback invoked when the user taps a notification.
  /// Set this from the app layer to handle navigation.
  void Function(Map<String, dynamic> data)? onNotificationTap;

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

      // Create the Android notification channel.
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_highImportanceChannel);

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
      print('🔔 [FCM] Token: ${token?.substring(0, 20)}...');
      return token;
    } catch (e) {
      print('🔴 [FCM] Failed to get token: $e');
      return null;
    }
  }

  /// Listen for token refreshes and call [onRefresh] with the new token.
  void onTokenRefresh(void Function(String token) onRefresh) {
    _messaging.onTokenRefresh.listen(onRefresh);
  }

  // ---------------------------------------------------------------------------
  // Message handlers
  // ---------------------------------------------------------------------------

  /// Show a local notification when a message arrives while the app is in
  /// the foreground.
  void _handleForegroundMessage(RemoteMessage message) {
    print('🔔 [FCM] Foreground message: ${message.notification?.title}');

    // Notify listeners (e.g. to refresh notification list).
    onForegroundMessage?.call(message);

    final notification = message.notification;
    if (notification == null) return;

    final android = notification.android;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _highImportanceChannel.id,
          _highImportanceChannel.name,
          channelDescription: _highImportanceChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          sound: _androidNotificationSound,
          icon: android?.smallIcon ?? '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: _iosNotificationSound,
        ),
      ),
      payload: message.data.toString(),
    );
  }

  /// Called when the user taps a notification that opened the app from
  /// background/terminated state.
  void _handleNotificationTap(RemoteMessage message) {
    print('🔔 [FCM] Notification tap: ${message.data}');
    onNotificationTap?.call(message.data);
  }

  /// Called when the user taps a local (foreground) notification.
  void _onLocalNotificationTap(NotificationResponse response) {
    print('🔔 [FCM] Local notification tap: ${response.payload}');
    // The payload is a stringified map; for now just trigger a generic tap.
    onNotificationTap?.call({});
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
final fcmTokenProvider = FutureProvider<String?>((ref) async {
  final service = ref.watch(pushNotificationServiceProvider);

  // Get current token.
  final token = await service.getToken();
  if (token == null) return null;

  // Persist locally.
  final prefs = ref.watch(sharedPreferencesProvider);
  final previousToken = prefs.getString(StorageKeys.fcmToken);
  await prefs.setString(StorageKeys.fcmToken, token);

  // Register with backend if it's a new or changed token.
  if (token != previousToken) {
    try {
      final api = ref.watch(notificationsApiProvider);
      await api.registerDeviceToken(
        token: token,
        deviceType: defaultTargetPlatform == TargetPlatform.iOS
            ? 'ios'
            : 'android',
      );
      print('🔔 [FCM] Token registered with backend');
    } catch (e) {
      print('🔴 [FCM] Failed to register token with backend: $e');
    }
  }

  // Listen for future refreshes.
  service.onTokenRefresh((newToken) async {
    await prefs.setString(StorageKeys.fcmToken, newToken);
    try {
      final api = ref.read(notificationsApiProvider);
      await api.registerDeviceToken(
        token: newToken,
        deviceType: defaultTargetPlatform == TargetPlatform.iOS
            ? 'ios'
            : 'android',
      );
      print('🔔 [FCM] Refreshed token registered with backend');
    } catch (e) {
      print('🔴 [FCM] Failed to register refreshed token: $e');
    }
  });

  return token;
});
