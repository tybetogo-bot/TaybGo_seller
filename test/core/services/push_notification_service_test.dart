import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:teybatseller/core/services/push_notification_service.dart';

void main() {
  group('decodeLocalNotificationPayload', () {
    test('preserves the order ID from a JSON payload', () {
      final payload = jsonEncode({'type': 'new_order', 'order_id': '42'});

      expect(decodeLocalNotificationPayload(payload), {
        'type': 'new_order',
        'order_id': '42',
      });
    });

    test(
      'returns an empty payload when the local notification is malformed',
      () {
        expect(decodeLocalNotificationPayload('{order_id: 42}'), isEmpty);
        expect(decodeLocalNotificationPayload(null), isEmpty);
      },
    );
  });
}
