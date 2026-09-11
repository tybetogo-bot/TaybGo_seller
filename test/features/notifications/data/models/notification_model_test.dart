import 'package:flutter_test/flutter_test.dart';
import 'package:teybatseller/features/notifications/data/models/notification_model.dart';

void main() {
  group('NotificationModel support targets', () {
    test('parses string IDs and JSON routing data', () {
      final notification = NotificationModel.fromJson({
        'id': '501',
        'title': 'Support replied',
        'body': 'You have a new reply.',
        'data':
            '{"type":"support_message_from_staff","ticket_id":"124","message_id":"900"}',
        'is_read': false,
        'created_at': '2026-09-11T10:05:00Z',
      });

      expect(notification.id, 501);
      expect(notification.notificationType, 'support_message_from_staff');
      expect(notification.ticketId, 124);
      expect(notification.messageId, 900);
      expect(notification.isSupportNotification, isTrue);
    });

    test('matches a message push by type, ticket, and message', () {
      final notification = NotificationModel.fromJson({
        'id': 501,
        'title': 'Support replied',
        'body': 'You have a new reply.',
        'data': {
          'type': 'SUPPORT_MESSAGE_FROM_STAFF',
          'ticket_id': 124,
          'message_id': 900,
        },
        'created_at': '2026-09-11T10:05:00Z',
      });

      expect(
        notification.matchesPushTarget(
          type: 'support_message_from_staff',
          ticketId: 124,
          messageId: 900,
        ),
        isTrue,
      );
      expect(
        notification.matchesPushTarget(
          type: 'support_message_from_staff',
          ticketId: 124,
          messageId: 901,
        ),
        isFalse,
      );
    });

    test(
      'treats malformed routing metadata as a safe generic notification',
      () {
        final notification = NotificationModel.fromJson({
          'id': 502,
          'title': 'Unknown',
          'body': 'No routing target',
          'data': '{not-json}',
          'created_at': '2026-09-11T10:05:00Z',
        });

        expect(notification.data, isNull);
        expect(notification.isSupportNotification, isFalse);
        expect(notification.ticketId, isNull);
      },
    );
  });
}
