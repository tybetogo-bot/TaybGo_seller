import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teybatseller/core/i18n/app_localizations.dart';
import 'package:teybatseller/core/providers/providers.dart';
import 'package:teybatseller/core/i18n/translation_service.dart';
import 'package:teybatseller/features/orders/application/orders_notifier.dart';
import 'package:teybatseller/features/orders/data/models/order_model.dart';
import 'package:teybatseller/features/orders/presentation/screens/order_details_screen.dart';
import 'package:teybatseller/features/restaurant/application/restaurant_state.dart';

class _TestOrdersNotifier extends OrdersNotifier {
  _TestOrdersNotifier(this._fetchOrder);

  final Future<OrderModel?> Function(String orderId) _fetchOrder;

  @override
  OrdersState build() => OrdersState(isLoading: true);

  @override
  Future<OrderModel?> fetchOrderById(String orderId) => _fetchOrder(orderId);
}

class _TestRestaurantNotifier extends RestaurantNotifier {
  @override
  RestaurantState build() => const RestaurantInitial();
}

late SharedPreferences _testPreferences;

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    _testPreferences = await SharedPreferences.getInstance();
    await TranslationService.instance.load(AppLocales.english);
  });

  testWidgets('keeps order details loading until the ID request settles', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(2400, 3000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final fetchCompleter = Completer<OrderModel?>();
    String? requestedOrderId;

    await tester.pumpWidget(
      _buildTestApp(
        fetchOrder: (orderId) {
          requestedOrderId = orderId;
          return fetchCompleter.future;
        },
      ),
    );
    await tester.pump();

    expect(requestedOrderId, '42');
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Order not found'), findsNothing);

    fetchCompleter.complete(_testOrder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('#42'), findsOneWidget);
    expect(find.text('Order not found'), findsNothing);
  });

  testWidgets('shows not found only after the ID request completes empty', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(2400, 3000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final fetchCompleter = Completer<OrderModel?>();

    await tester.pumpWidget(
      _buildTestApp(fetchOrder: (_) => fetchCompleter.future),
    );
    await tester.pump();

    expect(find.text('Order not found'), findsNothing);

    fetchCompleter.complete(null);
    await tester.pump();

    expect(find.text('Order not found'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}

Widget _buildTestApp({
  required Future<OrderModel?> Function(String orderId) fetchOrder,
}) {
  return ProviderScope(
    overrides: [
      ordersProvider.overrideWith(() => _TestOrdersNotifier(fetchOrder)),
      sharedPreferencesProvider.overrideWithValue(_testPreferences),
      restaurantProvider.overrideWith(_TestRestaurantNotifier.new),
      selectedRestaurantProvider.overrideWith((ref) => null),
      translationsLoadedProvider.overrideWithValue(const AsyncData(true)),
    ],
    child: MaterialApp(
      theme: ThemeData.light(),
      home: ScreenUtilInit(
        designSize: const Size(390, 844),
        child: const OrderDetailsScreen(orderId: '42'),
      ),
    ),
  );
}

final _testOrder = OrderModel(
  id: '42',
  customerName: 'Test Customer',
  phoneNumber: '+43123456789',
  countryCode: 'AT',
  address: AddressModel(street: 'Main Street', building: '1'),
  items: const [],
  status: OrderStatusEnum.delivered,
  createdAt: DateTime(2026, 9, 2),
);
