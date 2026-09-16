import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teybatseller/core/i18n/app_localizations.dart';
import 'package:teybatseller/core/i18n/translation_service.dart';
import 'package:teybatseller/features/orders/data/models/order_model.dart';
import 'package:teybatseller/features/orders/presentation/widgets/driver_dispatch_selector.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await TranslationService.instance.load(AppLocales.english);
  });

  test('preparation input needs explicit capability and server limits', () {
    final order = OrderModel.fromJson({
      'id': '42',
      'items': const [],
      'order_type': 'FOOD',
      'fulfillment_type': 'DELIVERY',
      'supports_preparation_timing': true,
      'preparation_max_minutes': 60,
      'driver_dispatch_lead_minutes': 5,
    });
    expect(order.canSetPreparationTime, isTrue);
    expect(
      order.copyWith(supportsPreparationTiming: false).canSetPreparationTime,
      isFalse,
    );
    expect(
      order.copyWith(preparationMaxMinutes: null).canSetPreparationTime,
      isFalse,
    );
    expect(
      order.copyWith(fulfillmentType: 'PICKUP').canSetPreparationTime,
      isFalse,
    );
    expect(order.copyWith(orderType: 'TAXI').canSetPreparationTime, isFalse);
  });

  testWidgets(
    'fifteen minute estimate explains ten minute driver search delay',
    (tester) async {
      int? chosen;
      await _open(tester, onSelected: (value) => chosen = value);
      expect(find.text('Preparation time'), findsOneWidget);
      expect(find.text('Driver search starts in 10 min'), findsOneWidget);
      expect(find.text('Driver search starts immediately'), findsNWidgets(2));
      await tester.tap(find.text('15 minutes'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(chosen, 15);
    },
  );

  testWidgets(
    'custom preparation respects server maximum and explains lead time',
    (tester) async {
      int? chosen;
      await _open(tester, maximum: 10, onSelected: (value) => chosen = value);
      expect(find.text('15 minutes'), findsNothing);
      await tester.tap(find.text('Custom preparation time'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '11');
      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(chosen, isNull);
      expect(
        find.text('Enter a whole number of minutes within the allowed range.'),
        findsOneWidget,
      );
      await tester.enterText(find.byType(TextField), '6');
      await tester.pumpAndSettle();
      expect(find.text('Driver search starts in 1 min'), findsOneWidget);
      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(chosen, 6);
    },
  );

  testWidgets('legacy selector keeps driver delay wording', (tester) async {
    await _open(tester, preparation: false, onSelected: (_) {});
    expect(find.text('Request a driver'), findsOneWidget);
    expect(find.text('Preparation time'), findsNothing);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
  });
}

Future<void> _open(
  WidgetTester tester, {
  int maximum = 60,
  bool preparation = true,
  required void Function(int?) onSelected,
}) async {
  tester.view.physicalSize = const Size(390, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final order = OrderModel.fromJson({'id': '42', 'items': const []});
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, _) => MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async => onSelected(
                await showDriverDispatchDelaySelector(
                  context,
                  order: order,
                  preparationTiming: preparation,
                  preparationMaximum: maximum,
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}
