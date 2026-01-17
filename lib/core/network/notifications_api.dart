/// Notifications API service for fetching user notifications
library;

import 'package:dio/dio.dart';

import '../../features/notifications/data/models/notification_model.dart';

/// Notifications API service
class NotificationsApi {
  final Dio _dio;

  NotificationsApi(this._dio);

  /// List notifications for the authenticated user
  /// GET /api/notifications
  Future<List<NotificationModel>> getNotifications() async {
    final response = await _dio.get('/api/notifications');
    final List<dynamic> data = response.data as List<dynamic>? ?? [];
    return data
        .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Mark a notification as read
  /// PATCH /api/notifications/{notification_id}
  Future<NotificationModel> markAsRead(int notificationId) async {
    final response = await _dio.patch(
      '/api/notifications/$notificationId',
      data: {'is_read': true},
    );
    return NotificationModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Mark all notifications as read by patching each one
  /// Note: No bulk endpoint exists in API, so we mark individually
  Future<void> markAllAsRead(List<int> notificationIds) async {
    await Future.wait(
      notificationIds.map((id) => markAsRead(id)),
    );
  }

  /// Delete a notification
  /// DELETE /api/notifications/{notification_id}
  Future<void> deleteNotification(int notificationId) async {
    await _dio.delete('/api/notifications/$notificationId');
  }

  /// Create a notification (for internal use)
  /// POST /api/notifications
  Future<NotificationModel> createNotification(Map<String, dynamic> data) async {
    final response = await _dio.post('/api/notifications', data: data);
    return NotificationModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Register device token for push notifications
  /// POST /api/notifications/device
  Future<void> registerDeviceToken({
    required String token,
    String? deviceType,
  }) async {
    await _dio.post('/api/notifications/device', data: {
      'token': token,
      if (deviceType != null) 'device_type': deviceType,
    });
  }
}
