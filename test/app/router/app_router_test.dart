import 'package:flutter_test/flutter_test.dart';
import 'package:teybatseller/app/router/app_router.dart';
import 'package:teybatseller/app/router/routes.dart';

void main() {
  test('matches the canonical support notification deep link', () {
    final location = Routes.supportTicketDetailNotificationPath(
      '11',
      messageId: 18,
    );

    final match = AppRouter.router.configuration.findMatch(
      Uri.parse(location),
    );

    expect(match.isError, isFalse, reason: match.uri.toString());
    expect(match.fullPath, '/support/tickets/:ticketId');
    expect(match.pathParameters['ticketId'], '11');
    expect(match.uri.queryParameters['message_id'], '18');
  });
}
