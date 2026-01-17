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
  });

  /// The callback to execute on each poll
  final Future<void> Function() onPoll;

  /// The interval between polls
  final Duration interval;

  /// Optional debug label for logging
  final String? debugLabel;

  Timer? _timer;
  bool _isPolling = false;

  /// Whether the service is currently polling
  bool get isPolling => _isPolling;

  /// Start polling
  void start() {
    if (_isPolling) return;

    _isPolling = true;
    _log('Starting polling');

    // Execute immediately, then start the timer
    _executePoll();

    _timer = Timer.periodic(interval, (_) {
      _executePoll();
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
  Future<void> _executePoll() async {
    try {
      _log('Executing poll');
      await onPoll();
    } catch (e) {
      _log('Poll error: $e');
    }
  }

  /// Trigger an immediate poll without affecting the timer
  Future<void> pollNow() async {
    await _executePoll();
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
  });

  final bool isEnabled;
  final Duration interval;

  PollingState copyWith({
    bool? isEnabled,
    Duration? interval,
  }) {
    return PollingState(
      isEnabled: isEnabled ?? this.isEnabled,
      interval: interval ?? this.interval,
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
    if (_service != null && state.isEnabled) {
      // Recreate the service with the new interval
      final onPoll = _service!.onPoll;
      final debugLabel = _service!.debugLabel;
      _service?.dispose();
      _service = PollingService(
        onPoll: onPoll,
        interval: interval,
        debugLabel: debugLabel,
      );
      _service?.start();
    }
  }

  /// Trigger an immediate poll
  Future<void> pollNow() async {
    await _service?.pollNow();
  }

  /// Whether polling is currently active
  bool get isPolling => _service?.isPolling ?? false;
}
