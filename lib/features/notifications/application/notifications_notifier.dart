import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/notifications_api.dart';
import '../../../core/providers/providers.dart';
import '../data/datasources/notifications_remote_data_source.dart';
import '../data/models/notification_model.dart';
import '../data/repositories/notifications_repository.dart';

/// Notifications state containing notifications list and metadata
class NotificationsState {
  const NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
    this.isMarkingAllRead = false,
  });

  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? error;
  final bool isMarkingAllRead;

  NotificationsState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool? isMarkingAllRead,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isMarkingAllRead: isMarkingAllRead ?? this.isMarkingAllRead,
    );
  }

  /// Get unread notifications count
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  /// Check if there are any unread notifications
  bool get hasUnread => unreadCount > 0;
}

/// Notifications state notifier for managing notifications (Riverpod 3.x)
class NotificationsNotifier extends Notifier<NotificationsState> {
  late final NotificationsRepository _repository;

  @override
  NotificationsState build() {
    _repository = ref.watch(notificationsRepositoryProvider);

    // Load notifications on build
    Future.microtask(() => loadNotifications());
    return const NotificationsState(isLoading: true);
  }

  /// Load notifications from API
  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _repository.getNotifications();

      if (result.failure != null) {
        state = state.copyWith(
          isLoading: false,
          error: result.failure!.message,
        );
        return;
      }

      state = state.copyWith(
        notifications: result.data ?? [],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load notifications: $e',
      );
    }
  }

  /// Refresh notifications
  Future<void> refresh() async {
    await loadNotifications();
  }

  /// Mark a single notification as read
  Future<void> markAsRead(int id) async {
    // Optimistically update the UI
    final updatedNotifications = state.notifications.map((n) {
      if (n.id == id) {
        return NotificationModel(
          id: n.id,
          title: n.title,
          body: n.body,
          data: n.data,
          isRead: true,
          readAt: DateTime.now(),
          createdAt: n.createdAt,
        );
      }
      return n;
    }).toList();

    state = state.copyWith(notifications: updatedNotifications);

    // Call API in background
    try {
      final result = await _repository.markAsRead(id);
      if (result.failure != null) {
        // Revert on failure - reload from server
        await loadNotifications();
      }
    } catch (_) {
      // Revert on failure
      await loadNotifications();
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (state.isMarkingAllRead) return;

    // Get IDs of unread notifications
    final unreadIds = state.notifications
        .where((n) => !n.isRead)
        .map((n) => n.id)
        .toList();

    if (unreadIds.isEmpty) return;

    state = state.copyWith(isMarkingAllRead: true);

    // Optimistically update the UI
    final updatedNotifications = state.notifications.map((n) {
      return NotificationModel(
        id: n.id,
        title: n.title,
        body: n.body,
        data: n.data,
        isRead: true,
        readAt: n.readAt ?? DateTime.now(),
        createdAt: n.createdAt,
      );
    }).toList();

    state = state.copyWith(
      notifications: updatedNotifications,
      isMarkingAllRead: false,
    );

    // Call API in background
    try {
      final result = await _repository.markAllAsRead(unreadIds);
      if (result.failure != null) {
        // Revert on failure - reload from server
        await loadNotifications();
      }
    } catch (_) {
      // Revert on failure
      await loadNotifications();
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Provider for notifications API
final notificationsApiProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return NotificationsApi(dio);
});

/// Provider for notifications data source
final notificationsDataSourceProvider = Provider<NotificationsDataSource>((ref) {
  final api = ref.watch(notificationsApiProvider);
  return NotificationsRemoteDataSource(api);
});

/// Provider for notifications repository
final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  final dataSource = ref.watch(notificationsDataSourceProvider);
  return NotificationsRepositoryImpl(remoteDataSource: dataSource);
});

/// Provider for notifications state (Riverpod 3.x)
final notificationsProvider = NotifierProvider<NotificationsNotifier, NotificationsState>(
  NotificationsNotifier.new,
);

/// Provider for unread notifications count
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notificationsState = ref.watch(notificationsProvider);
  return notificationsState.unreadCount;
});
