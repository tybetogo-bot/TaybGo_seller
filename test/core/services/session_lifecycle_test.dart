import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:teybatseller/core/services/session_lifecycle.dart';

void main() {
  test(
    'logout invalidates synchronously and next login waits for actual deletion',
    () async {
      final session = SessionLifecycle();
      final old = await session.beginLogin();
      session.accept(old);
      final deletion = Completer<void>();
      final logout = session.end(() => deletion.future);
      expect(session.isAuthenticated(old), isFalse);
      var started = false;
      final login = session.beginLogin().then((value) {
        started = true;
        return value;
      });
      await Future<void>.delayed(Duration.zero);
      expect(started, isFalse);
      deletion.complete();
      await logout;
      final next = await login;
      expect(next, isNot(old));
      session.accept(next);
      expect(session.isAuthenticated(next), isTrue);
    },
  );

  test('concurrent forced/manual cleanup shares a single barrier', () async {
    final session = SessionLifecycle();
    final deletion = Completer<void>();
    var calls = 0;
    final first = session.end(() {
      calls++;
      return deletion.future;
    });
    final second = session.end(() async {
      calls++;
    });
    expect(identical(first, second), isTrue);
    deletion.complete();
    await first;
    expect(calls, 1);
  });

  test('cleanup drains late token work before deleting SDK state', () async {
    final session = SessionLifecycle();
    final events = <String>[];
    final token = Completer<void>();
    final work = session.trackPush(() async {
      await token.future;
      events.add('token');
    });
    final logout = session.end(() async {
      await session.drainPush();
      events.add('delete');
    });
    await Future<void>.delayed(Duration.zero);
    expect(events, isEmpty);
    token.complete();
    await Future.wait([work, logout]);
    expect(events, ['token', 'delete']);
  });
}
