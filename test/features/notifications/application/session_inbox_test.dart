import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teybatseller/core/services/session_lifecycle.dart';
import 'package:teybatseller/features/notifications/application/notifications_notifier.dart';
import 'package:teybatseller/features/notifications/data/models/notification_model.dart';
import 'package:teybatseller/features/notifications/data/repositories/notifications_repository.dart';

class FakeRepository implements NotificationsRepository {
  final old = Completer<NotificationsResult<List<NotificationModel>>>();
  int calls = 0;
  @override
  Future<NotificationsResult<List<NotificationModel>>>
  getNotifications() async {
    calls++;
    return calls == 1
        ? old.future
        : (failure: null, data: <NotificationModel>[]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test(
    'old inbox response cannot repopulate state after account switching',
    () async {
      final session = SessionLifecycle.instance;
      await session.end(() async {});
      session.accept(await session.beginLogin());
      final repository = FakeRepository();
      final container = ProviderContainer(
        overrides: [
          notificationsRepositoryProvider.overrideWithValue(repository),
        ],
      );
      final subscription = container.listen(notificationsProvider, (_, _) {});
      await Future<void>.delayed(Duration.zero);
      expect(repository.calls, 1);
      await session.end(() async {});
      await container.pump();
      expect(container.read(notificationsProvider).notifications, isEmpty);
      session.accept(await session.beginLogin());
      await container.pump();
      await Future<void>.delayed(Duration.zero);
      repository.old.complete((
        failure: null,
        data: [
          NotificationModel(
            id: 42,
            title: 'Old account',
            body: 'private',
            createdAt: DateTime(2026),
          ),
        ],
      ));
      await Future<void>.delayed(Duration.zero);
      expect(repository.calls, 2);
      expect(container.read(notificationsProvider).notifications, isEmpty);
      subscription.close();
      container.dispose();
    },
  );
}
