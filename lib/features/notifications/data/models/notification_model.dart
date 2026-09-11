import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.freezed.dart';

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

Map<String, dynamic>? _asDataMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }

  if (value is String && value.isNotEmpty) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (_) {
      // Treat malformed data as a notification without routing metadata.
    }
  }

  return null;
}

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
    return NotificationModel(
      id: _asInt(json['id']) ?? 0,
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      data: _asDataMap(json['data']),
      isRead:
          json['is_read'] == true ||
          json['is_read'] == 1 ||
          json['is_read']?.toString().toLowerCase() == 'true',
      readAt: json['read_at'] != null
          ? DateTime.tryParse(json['read_at'].toString())
          : null,
      createdAt:
          DateTime.tryParse((json['created_at'] ?? '').toString()) ??
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
  String? get notificationType =>
      data?['type']?.toString().trim().toLowerCase();

  /// Get related support ticket ID from data.
  int? get ticketId => _asInt(data?['ticket_id'] ?? data?['ticketId']);

  /// Get related support message ID from data.
  int? get messageId => _asInt(data?['message_id'] ?? data?['messageId']);

  /// Whether this notification belongs to the seller support flow.
  bool get isSupportNotification =>
      notificationType == 'support_message_from_staff' ||
      notificationType == 'support_ticket_updated';

  /// Match a push target against the authoritative notification record.
  bool matchesPushTarget({
    required String type,
    required int ticketId,
    int? messageId,
  }) {
    if (notificationType != type.trim().toLowerCase()) return false;
    if (this.ticketId != ticketId) return false;
    return messageId == null || this.messageId == messageId;
  }

  /// Get related order ID from data
  int? get orderId => _asInt(data?['order_id'] ?? data?['orderId']);
}
