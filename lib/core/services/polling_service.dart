import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A service that polls for new data at a specified interval.
///
/// Usage:
/// ```dart
/// final pollingService = ref.watch(ordersPollingServiceProvider);
/// pollingService.start(); // Start polling
/// pollingService.stop();  // Stop polling
/// ```
class PollingService {
  PollingService({
    required this.onPoll,
    this.interval = const Duration(seconds: 10),
    this.debugLabel,
    this.onNextPollScheduled,
    this.onPollStarted,
    this.onPollCompleted,
  });

  /// The callback to execute on each poll
  final Future<void> Function() onPoll;

  /// The interval between polls
  final Duration interval;

  /// Optional debug label for logging
  final String? debugLabel;

  /// Called whenever the next automatic poll is scheduled.
  final void Function(DateTime nextPollAt)? onNextPollScheduled;

  /// Called immediately before a poll callback starts.
  final void Function()? onPollStarted;

  /// Called after a poll callback completes, including when it fails.
  final void Function()? onPollCompleted;

  Timer? _timer;
  bool _isPolling = false;
  bool _pollInFlight = false;

  /// Whether the service is currently polling
  bool get isPolling => _isPolling;

  /// Start polling
  void start() {
    if (_isPolling) return;

    _isPolling = true;
    _log('Starting polling');

    // Execute immediately, then start the timer
    _executePoll(scheduleNextPoll: true);

    _timer = Timer.periodic(interval, (_) {
      _executePoll(scheduleNextPoll: true);
    });
  }

  /// Stop polling
  void stop() {
    if (!_isPolling) return;

    _log('Stopping polling');
    _timer?.cancel();
    _timer = null;
    _isPolling = false;
  }

  /// Restart polling (stop and start)
  void restart() {
    stop();
    start();
  }

  /// Execute a single poll
  Future<void> _executePoll({bool scheduleNextPoll = false}) async {
    if (_pollInFlight) {
      _log('Skipping poll; previous poll is still running');
      return;
    }

    if (scheduleNextPoll) {
      _scheduleNextPoll();
    }

    _pollInFlight = true;
    try {
      onPollStarted?.call();
      _log('Executing poll');
      await onPoll();
    } catch (e) {
      _log('Poll error: $e');
    } finally {
      _pollInFlight = false;
      onPollCompleted?.call();
    }
  }

  /// Trigger an immediate poll without affecting the timer
  Future<void> pollNow() async {
    await _executePoll();
  }

  void _scheduleNextPoll() {
    onNextPollScheduled?.call(DateTime.now().add(interval));
  }

  void _log(String message) {
    if (kDebugMode && debugLabel != null) {
      debugPrint('[$debugLabel] $message');
    }
  }

  /// Dispose the service
  void dispose() {
    stop();
  }
}

/// State for managing polling configuration
class PollingState {
  const PollingState({
    this.isEnabled = true,
    this.interval = const Duration(seconds: 10),
    this.nextPollAt,
    this.isSyncing = false,
    this.lastPollAt,
  });

  final bool isEnabled;
  final Duration interval;
  final DateTime? nextPollAt;
  final bool isSyncing;
  final DateTime? lastPollAt;

  PollingState copyWith({
    bool? isEnabled,
    Duration? interval,
    DateTime? nextPollAt,
    bool clearNextPollAt = false,
    bool? isSyncing,
    DateTime? lastPollAt,
    bool clearLastPollAt = false,
  }) {
    return PollingState(
      isEnabled: isEnabled ?? this.isEnabled,
      interval: interval ?? this.interval,
      nextPollAt: clearNextPollAt ? null : (nextPollAt ?? this.nextPollAt),
      isSyncing: isSyncing ?? this.isSyncing,
      lastPollAt: clearLastPollAt ? null : (lastPollAt ?? this.lastPollAt),
    );
  }
}

/// Notifier for managing polling state
class PollingNotifier extends Notifier<PollingState> {
  PollingService? _service;

  @override
  PollingState build() {
    ref.onDispose(() {
      _service?.dispose();
    });
    return const PollingState();
  }

  /// Initialize the polling service with a callback
  void initialize(Future<void> Function() onPoll, {String? debugLabel}) {
    _service?.dispose();
    _service = PollingService(
      onPoll: onPoll,
      interval: state.interval,
      debugLabel: debugLabel,
      onNextPollScheduled: (nextPollAt) {
        state = state.copyWith(nextPollAt: nextPollAt);
      },
      onPollStarted: () {
        state = state.copyWith(isSyncing: true);
      },
      onPollCompleted: () {
        state = state.copyWith(isSyncing: false, lastPollAt: DateTime.now());
      },
    );

    if (state.isEnabled) {
      _service?.start();
    }
  }

  /// Start polling
  void start() {
    state = state.copyWith(isEnabled: true);
    _service?.start();
  }

  /// Stop polling
  void stop() {
    state = state.copyWith(
      isEnabled: false,
      isSyncing: false,
      clearNextPollAt: true,
    );
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
    final wasPolling = _service?.isPolling ?? false;
    state = state.copyWith(interval: interval);
    if (_service != null && state.isEnabled) {
      // Recreate the service with the new interval
      final onPoll = _service!.onPoll;
      final debugLabel = _service!.debugLabel;
      _service?.dispose();
      _service = PollingService(
        onPoll: onPoll,
        interval: interval,
        debugLabel: debugLabel,
        onNextPollScheduled: (nextPollAt) {
          state = state.copyWith(nextPollAt: nextPollAt);
        },
        onPollStarted: () {
          state = state.copyWith(isSyncing: true);
        },
        onPollCompleted: () {
          state = state.copyWith(isSyncing: false, lastPollAt: DateTime.now());
        },
      );
      _service?.start();
    } else if (!wasPolling) {
      state = state.copyWith(clearNextPollAt: true);
    }
  }

  /// Trigger an immediate poll
  Future<void> pollNow() async {
    await _service?.pollNow();
  }

  /// Whether polling is currently active
  bool get isPolling => _service?.isPolling ?? false;
}
