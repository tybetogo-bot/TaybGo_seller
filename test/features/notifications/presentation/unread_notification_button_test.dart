import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teybatseller/features/notifications/presentation/widgets/unread_notification_button.dart';

void main() {
  Future<void> show(
    WidgetTester tester,
    int count, {
    bool reduceMotion = false,
    TextDirection direction = TextDirection.ltr,
    double textScale = 1,
    Brightness brightness = Brightness.light,
    VoidCallback? onPressed,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(brightness: brightness),
      home: MediaQuery(
        data: MediaQueryData(
          disableAnimations: reduceMotion,
          textScaler: TextScaler.linear(textScale),
        ),
        child: Directionality(
          textDirection: direction,
          child: Scaffold(
            body: Center(
              child: UnreadNotificationButton(
                unreadCount: count,
                label: 'Notifications, $count unread',
                onPressed: onPressed ?? () {},
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Finder bellRotation() => find
      .ancestor(
        of: find.byIcon(Icons.notifications_rounded),
        matching: find.byType(Transform),
      )
      .first;

  testWidgets(
    'count is readable, capped visually and does not clear on opening',
    (tester) async {
      var taps = 0;
      await show(tester, 124, onPressed: () => taps++);
      expect(find.text('99+'), findsOneWidget);
      expect(find.byTooltip('Notifications, 124 unread'), findsOneWidget);
      expect(tester.getSize(find.byType(IconButton)), const Size(48, 48));
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();
      expect(taps, 1);
      expect(find.text('99+'), findsOneWidget);
    },
  );

  testWidgets(
    'new unread counts animate briefly and polling does not restart them',
    (tester) async {
      await show(tester, 2);
      await show(tester, 3);
      await tester.pump(const Duration(milliseconds: 130));
      expect(
        tester.widget<Transform>(bellRotation()).transform.entry(0, 1).abs(),
        greaterThan(0.01),
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<Transform>(bellRotation()).transform.entry(0, 1),
        closeTo(0, 0.00001),
      );
      await show(tester, 3);
      await tester.pump(const Duration(milliseconds: 130));
      expect(
        tester.widget<Transform>(bellRotation()).transform.entry(0, 1),
        closeTo(0, 0.00001),
      );
      expect(tester.binding.hasScheduledFrame, isFalse);
    },
  );

  testWidgets(
    'reading notifications updates the badge without ringing the bell',
    (tester) async {
      await show(tester, 5);
      await show(tester, 4);
      await tester.pump(const Duration(milliseconds: 130));
      expect(tester.widget<Transform>(bellRotation()).transform.entry(0, 1), 0);
      await tester.pumpAndSettle();
      expect(find.text('4'), findsOneWidget);
      await show(tester, 0);
      await tester.pumpAndSettle();
      expect(find.text('4'), findsNothing);
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
    },
  );

  testWidgets(
    'reduced motion updates immediately without attention animation',
    (tester) async {
      await show(tester, 0, reduceMotion: true);
      await show(tester, 8, reduceMotion: true);
      await tester.pump();
      expect(find.text('8'), findsOneWidget);
      expect(tester.widget<Transform>(bellRotation()).transform.entry(0, 1), 0);
      expect(tester.binding.hasScheduledFrame, isFalse);
    },
  );

  testWidgets('badge mirrors in RTL and supports large text in dark mode', (
    tester,
  ) async {
    await show(
      tester,
      120,
      direction: TextDirection.rtl,
      textScale: 2,
      brightness: Brightness.dark,
    );
    final badge = tester.getRect(find.text('99+'));
    final button = tester.getRect(find.byType(IconButton));
    expect(badge.center.dx, lessThan(button.center.dx));
    expect(badge.left, greaterThanOrEqualTo(button.left));
    expect(tester.takeException(), isNull);
  });
}
