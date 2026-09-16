import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/notifications_api.dart';
import '../../../core/providers/providers.dart';
import '../../../core/services/polling_service.dart';
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
  bool _requestInFlight = false;

  @override
  NotificationsState build() {
    _repository = ref.watch(notificationsRepositoryProvider);

    // Load notifications on build
    Future.microtask(() => loadNotifications());
    return const NotificationsState(isLoading: true);
  }

  /// Load notifications from API
  Future<void> loadNotifications() async {
    if (_requestInFlight) return;

    _requestInFlight = true;
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
    } finally {
      _requestInFlight = false;
    }
  }

  /// Refresh notifications
  Future<void> refresh() async {
    await loadNotifications();
  }

  /// Silent refresh - only updates UI if data has changed
  /// Used by polling to avoid unnecessary rebuilds
  Future<bool> silentRefresh() async {
    if (_requestInFlight) return false;

    _requestInFlight = true;
    try {
      final result = await _repository.getNotifications();

      if (result.failure != null || result.data == null) {
        return false;
      }

      final newNotifications = result.data!;

      // Check if data has actually changed
      if (_hasNotificationsChanged(newNotifications)) {
        state = state.copyWith(
          notifications: newNotifications,
          clearError: true,
        );
        return true;
      }

      return false;
    } catch (e) {
      return false;
    } finally {
      _requestInFlight = false;
    }
  }

  /// Compare notifications to detect changes
  bool _hasNotificationsChanged(List<NotificationModel> newNotifications) {
    if (newNotifications.length != state.notifications.length) return true;

    for (final newNotif in newNotifications) {
      final oldNotif = state.notifications.firstWhere(
        (n) => n.id == newNotif.id,
        orElse: () => newNotif,
      );

      // Freezed equality includes the routing payload and all display fields,
      // so updates to a ticket notification are also reflected locally.
      if (oldNotif != newNotif) {
        return true;
      }
    }

    return false;
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

  /// Reconcile a push payload with the server notification list and mark the
  /// matching database notification as read. Push payloads intentionally do
  /// not contain the database notification ID, so the stable support target
  /// fields are used for matching instead.
  Future<void> markPushTargetAsRead(Map<String, dynamic> data) async {
    final type = data['type']?.toString().trim().toLowerCase();
    final ticketId = _asInt(data['ticket_id'] ?? data['ticketId']);
    final messageId = _asInt(data['message_id'] ?? data['messageId']);

    if ((type != 'support_message_from_staff' &&
            type != 'support_ticket_updated') ||
        ticketId == null) {
      return;
    }

    try {
      final result = await _repository.getNotifications();
      if (result.failure != null || result.data == null) return;

      final notifications = result.data!;
      state = state.copyWith(
        notifications: notifications,
        isLoading: false,
        clearError: true,
      );

      final matches = notifications
          .where(
            (notification) => notification.matchesPushTarget(
              type: type!,
              ticketId: ticketId,
              messageId: messageId,
            ),
          )
          .toList();
      if (matches.isEmpty) return;

      // Ticket updates without a message ID can have several records. The
      // newest matching server notification is the one the seller opened.
      matches.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final matching = matches.first;
      if (!matching.isRead) await markAsRead(matching.id);
    } catch (_) {
      // Push navigation must remain usable even when reconciliation fails.
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
final notificationsDataSourceProvider = Provider<NotificationsDataSource>((
  ref,
) {
  final api = ref.watch(notificationsApiProvider);
  return NotificationsRemoteDataSource(api);
});

/// Provider for notifications repository
final notificationsRepositoryProvider = Provider<NotificationsRepository>((
  ref,
) {
  final dataSource = ref.watch(notificationsDataSourceProvider);
  return NotificationsRepositoryImpl(remoteDataSource: dataSource);
});

/// Provider for notifications state (Riverpod 3.x)
final notificationsProvider =
    NotifierProvider<NotificationsNotifier, NotificationsState>(
      NotificationsNotifier.new,
    );

/// Provider for unread notifications count
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notificationsState = ref.watch(notificationsProvider);
  return notificationsState.unreadCount;
});

/// Provider for notifications polling service
///
/// This provider creates a polling service that refreshes notifications every 5 seconds.
/// Only updates UI when there's new data to avoid unnecessary rebuilds.
/// Usage:
/// ```dart
/// // In a widget or notifier:
/// final pollingNotifier = ref.read(notificationsPollingProvider.notifier);
/// pollingNotifier.start(); // Start polling
/// pollingNotifier.stop();  // Stop polling
/// ```
final notificationsPollingProvider =
    NotifierProvider<NotificationsPollingNotifier, PollingState>(
      NotificationsPollingNotifier.new,
    );

/// Notifier for notifications polling
class NotificationsPollingNotifier extends Notifier<PollingState> {
  PollingService? _service;
  static const _defaultInterval = Duration(seconds: 5);

  @override
  PollingState build() {
    ref.onDispose(() {
      _service?.dispose();
    });

    // Initialize the polling service
    Future.microtask(() => _initializeService());

    return const PollingState(interval: _defaultInterval);
  }

  void _initializeService() {
    final wasPolling = _service?.isPolling ?? false;
    _service?.dispose();
    _service = PollingService(
      onPoll: () async {
        // Use silentRefresh to only update UI when data changes
        await ref.read(notificationsProvider.notifier).silentRefresh();
      },
      interval: state.interval,
      debugLabel: 'NotificationsPolling',
    );
    if (wasPolling) _service?.start();
  }

  /// Start polling for new notifications
  void start() {
    if (_service == null) {
      _initializeService();
    }
    state = state.copyWith(isEnabled: true);
    _service?.start();
  }

  /// Stop polling
  void stop() {
    state = state.copyWith(isEnabled: false);
    _service?.stop();
  }

  /// Toggle polling on/off
  void toggle() {
    if (state.isEnabled) {
      stop();
    } else {
      start();
    }
  }

  /// Update the polling interval
  void setInterval(Duration interval) {
    state = state.copyWith(interval: interval);
    if (_service != null) {
      final wasPolling = _service!.isPolling;
      _service?.dispose();
      _service = PollingService(
        onPoll: () async {
          // Use silentRefresh to only update UI when data changes
          await ref.read(notificationsProvider.notifier).silentRefresh();
        },
        interval: interval,
        debugLabel: 'NotificationsPolling',
      );
      if (wasPolling) {
        _service?.start();
      }
    }
  }

  /// Trigger an immediate poll
  Future<void> pollNow() async {
    await _service?.pollNow();
  }

  /// Whether polling is currently active
  bool get isPolling => _service?.isPolling ?? false;
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}
