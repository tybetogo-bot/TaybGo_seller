/// Remote data source for notifications
library;

import '../../../../core/network/notifications_api.dart';
import '../models/notification_model.dart';

/// Abstract interface for notifications data source
abstract class NotificationsDataSource {
  /// Get all notifications for the authenticated user
  Future<List<NotificationModel>> getNotifications();

  /// Mark a single notification as read
  Future<NotificationModel> markAsRead(int notificationId);

  /// Mark multiple notifications as read
  Future<void> markAllAsRead(List<int> notificationIds);

  /// Delete a notification
  Future<void> deleteNotification(int notificationId);

  /// Register device token for push notifications
  Future<void> registerDeviceToken({
    required String token,
    String? deviceType,
  });
}

/// Remote data source implementation using NotificationsApi
class NotificationsRemoteDataSource implements NotificationsDataSource {
  NotificationsRemoteDataSource(this._api);

  final NotificationsApi _api;

  @override
  Future<List<NotificationModel>> getNotifications() async {
    return await _api.getNotifications();
  }

  @override
  Future<NotificationModel> markAsRead(int notificationId) async {
    return await _api.markAsRead(notificationId);
  }

  @override
  Future<void> markAllAsRead(List<int> notificationIds) async {
    return await _api.markAllAsRead(notificationIds);
  }

  @override
  Future<void> deleteNotification(int notificationId) async {
    return await _api.deleteNotification(notificationId);
  }

  @override
  Future<void> registerDeviceToken({
    required String token,
    String? deviceType,
  }) async {
    return await _api.registerDeviceToken(
      token: token,
      deviceType: deviceType,
    );
  }
}
