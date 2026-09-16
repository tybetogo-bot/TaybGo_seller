import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teybatseller/core/i18n/app_localizations.dart';
import 'package:teybatseller/core/i18n/translation_service.dart';
import 'package:teybatseller/features/orders/data/models/order_model.dart';
import 'package:teybatseller/features/orders/presentation/widgets/incoming_order_timer.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await TranslationService.instance.load(AppLocales.english);
  });

  testWidgets('opening an older server sample does not restart its countdown', (
    tester,
  ) async {
    final order = _scheduledOrder();
    await tester.pumpWidget(_app(order));

    // Two minutes have already passed since this ten-minute sample arrived.
    expect(find.text('10:00'), findsNothing);
    expect(find.textContaining(RegExp(r'^0[78]:\d{2}$')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(_app(order));
    expect(find.text('10:00'), findsNothing);
    expect(find.textContaining(RegExp(r'^0[78]:\d{2}$')), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('resuming preserves elapsed time while requesting fresh state', (
    tester,
  ) async {
    var refreshes = 0;
    await tester.pumpWidget(
      _app(_scheduledOrder(), onRefresh: () async => refreshes++),
    );
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(refreshes, 1);
    expect(find.text('10:00'), findsNothing);
    expect(find.textContaining(RegExp(r'^0[78]:\d{2}$')), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('an expired dispatch timer refreshes once without dispatching', (
    tester,
  ) async {
    var refreshes = 0;
    final order = _scheduledOrder().copyWith(
      driverDispatchDueAt: DateTime.utc(2026, 9, 16, 12),
    );
    await tester.pumpWidget(_app(order, onRefresh: () async => refreshes++));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('00:00'), findsOneWidget);
    expect(refreshes, 1);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final dispatchStatus in ['SEARCHING', 'ASSIGNED']) {
    testWidgets('preparation estimate remains visible when $dispatchStatus', (
      tester,
    ) async {
      final order = _scheduledOrder().copyWith(
        preparationReadyAt: DateTime.utc(2026, 9, 16, 12, 15),
        preparationServerTime: DateTime.utc(2026, 9, 16, 12),
        preparationTimeMinutes: 15,
        preparationRemainingSeconds: 900,
        driverDispatchStatus: dispatchStatus,
        driverDispatchDueAt: null,
      );
      await tester.pumpWidget(_app(order));
      expect(find.textContaining('Estimated ready in'), findsOneWidget);
      expect(
        find.text(
          dispatchStatus == 'SEARCHING'
              ? 'Finding a driver...'
              : 'Driver assigned',
        ),
        findsWidgets,
      );
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets(
    'fresh server clock at an unchanged deadline does not cause a refresh loop',
    (tester) async {
      var refreshes = 0;
      final order = _scheduledOrder().copyWith(
        driverDispatchDueAt: DateTime.utc(2026, 9, 16, 12),
        preparationReadyAt: DateTime.utc(2026, 9, 16, 12),
        preparationRemainingSeconds: 0,
      );
      Future<void> refresh() async {
        refreshes++;
      }

      await tester.pumpWidget(_app(order, onRefresh: refresh));
      await tester.pump(const Duration(seconds: 1));
      expect(refreshes, 1);
      await tester.pumpWidget(
        _app(
          order.copyWith(
            driverDispatchServerTime: DateTime.utc(2026, 9, 16, 12, 1),
            timingReceivedAt: DateTime.now().toUtc(),
          ),
          onRefresh: refresh,
        ),
      );
      await tester.pump(const Duration(seconds: 2));
      expect(refreshes, 1);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'server null remaining time suppresses a historical preparation estimate',
    (tester) async {
      await tester.pumpWidget(
        _app(
          _scheduledOrder().copyWith(
            preparationReadyAt: DateTime.utc(2026, 9, 16, 12, 15),
            preparationRemainingSeconds: null,
          ),
        ),
      );
      expect(find.textContaining('Estimated ready in'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('estimate expiry does not display food ready', (tester) async {
    final order = _scheduledOrder().copyWith(
      preparationReadyAt: DateTime.utc(2026, 9, 16, 12),
      preparationRemainingSeconds: 0,
      preparationServerTime: DateTime.utc(2026, 9, 16, 12),
      driverDispatchStatus: 'SEARCHING',
      driverDispatchDueAt: null,
    );
    await tester.pumpWidget(_app(order));
    expect(find.text('Preparation estimate elapsed'), findsOneWidget);
    expect(find.textContaining('Estimated ready in'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'terminal orders hide stale preparation and dispatch countdowns',
    (tester) async {
      final order = _scheduledOrder().copyWith(
        preparationReadyAt: DateTime.utc(2026, 9, 16, 12, 15),
        status: OrderStatusEnum.cancelled,
      );
      await tester.pumpWidget(_app(order));
      expect(find.textContaining('Estimated ready in'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}

OrderModel _scheduledOrder() =>
    OrderModel.fromJson({
      'id': 'timer-test',
      'items': const [],
      'status': 'ACCEPTED',
      'created_at': '2026-09-16T11:00:00Z',
      'driver_dispatch_status': 'SCHEDULED',
      'driver_dispatch_delay_minutes': 10,
      'driver_dispatch_server_time': '2026-09-16T12:00:00Z',
      'driver_dispatch_due_at': '2026-09-16T12:10:00Z',
    }).copyWith(
      timingReceivedAt: DateTime.now().toUtc().subtract(
        const Duration(minutes: 2),
      ),
    );

Widget _app(OrderModel order, {Future<void> Function()? onRefresh}) =>
    ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, child) => MaterialApp(home: Scaffold(body: child)),
      child: IncomingOrderTimer(
        order: order,
        textPrimary: Colors.black,
        textSecondary: Colors.grey,
        onRefresh: onRefresh,
      ),
    );
