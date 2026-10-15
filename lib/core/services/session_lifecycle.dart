import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A generation identifies a local login attempt, including same-account login.
/// Cleanup is a barrier: no new login or SDK token creation may pass it.
class SessionLifecycle extends ChangeNotifier {
  static final instance = SessionLifecycle();

  int generation = 0;
  bool authenticated = false;
  bool closing = false;
  Future<void>? _cleanup;
  Future<void> _writes = Future.value();
  Future<(String, String)?>? _rotation;
  int? _rotationGeneration;

  Future<(String, String)?> rotate(
    int login,
    Future<(String, String)?> Function() action,
  ) {
    if (_rotation != null && _rotationGeneration == login) return _rotation!;
    final work = action();
    _rotation = work;
    _rotationGeneration = login;
    void release() {
      if (identical(_rotation, work)) _rotation = null;
    }

    work.then<void>(
      (_) => release(),
      onError: (Object _, StackTrace _) => release(),
    );
    return work;
  }

  final Set<Future<void>> _pushWork = {};

  bool isCurrent(int value) => value == generation && !closing;
  bool isAuthenticated(int value) => isCurrent(value) && authenticated;
  Future<void> get settled => _cleanup ?? Future.value();

  void restore(bool hasCredentials) {
    authenticated = hasCredentials;
  }

  Future<int> beginLogin() async {
    await settled;
    generation++;
    authenticated = false;
    notifyListeners();
    return generation;
  }

  void accept(int value) {
    if (!isCurrent(value)) return;
    authenticated = true;
    notifyListeners();
  }

  Future<T> serializeWrite<T>(Future<T> Function() action) {
    final result = _writes.then((_) => action());
    _writes = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  Future<void> trackPush(Future<void> Function() action) async {
    final work = action();
    _pushWork.add(work);
    try {
      await work;
    } finally {
      _pushWork.remove(work);
    }
  }

  Future<void> drainPush() async {
    await Future.wait(
      _pushWork.toList().map((work) async {
        try {
          await work;
        } catch (_) {
          /* Best-effort registration. */
        }
      }),
    );
  }

  Future<void> end(Future<void> Function() cleanup) {
    if (_cleanup != null) return _cleanup!;
    final completer = Completer<void>();
    _cleanup = completer.future;
    generation++;
    closing = true;
    authenticated = false;
    notifyListeners();
    () async {
      try {
        await cleanup();
        completer.complete();
      } catch (error, stack) {
        completer.completeError(error, stack);
      } finally {
        closing = false;
        _cleanup = null;
      }
    }();
    return completer.future;
  }
}

/// Account-owned providers rebuild to empty state when the login changes.
final sessionGenerationProvider = Provider<(int, bool)>((ref) {
  final session = SessionLifecycle.instance;
  session.addListener(ref.invalidateSelf);
  ref.onDispose(() => session.removeListener(ref.invalidateSelf));
  return (session.generation, session.authenticated);
});
