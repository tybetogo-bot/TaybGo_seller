import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.freezed.dart';

/// Notification model for user notifications
@freezed
sealed class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    required int id,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    @Default(false) bool isRead,
    DateTime? readAt,
    required DateTime createdAt,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? parsedData;
    final rawData = json['data'];
    if (rawData is Map<String, dynamic>) {
      parsedData = rawData;
    } else if (rawData is String && rawData.isNotEmpty) {
      try {
        parsedData = jsonDecode(rawData) as Map<String, dynamic>?;
      } catch (_) {
        parsedData = null;
      }
    }

    return NotificationModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      data: parsedData,
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] != null
          ? DateTime.tryParse(json['read_at'].toString())
          : null,
      createdAt: DateTime.tryParse(
            (json['created_at'] ?? '').toString(),
          ) ??
          DateTime.now(),
    );
  }
}

/// Extension for NotificationModel with utility methods
extension NotificationModelExtension on NotificationModel {
  /// Get time ago string
  String getTimeAgo() {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) {
      return 'just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h';
    } else {
      return '${diff.inDays}d';
    }
  }

  /// Get notification type from data
  String? get notificationType => data?['type'] as String?;

  /// Get related order ID from data
  int? get orderId => data?['order_id'] as int?;
}
