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

  test('parses the server-provided nullable seller total', () {
    final order = OrderModel.fromJson({
      'id': 'seller-total-1',
      'customer_name': 'Test Customer',
      'customer_phone_number': '+43123456789',
      'items': const [],
      'subtotal_amount': '20.00',
      'discount_amount': '2.00',
      'delivery_fee': '5.00',
      'tip': '1.00',
      'total_amount': '24.00',
      'seller_total_amount': '18.00',
      'created_at': '2026-09-02T12:00:00Z',
    });

    expect(order.sellerTotalAmount, 18.00);

    final legacyOrder = OrderModel.fromJson({
      'id': 'legacy-1',
      'customer_name': 'Legacy Customer',
      'customer_phone_number': '+43123456789',
      'items': const [],
      'created_at': '2026-09-02T12:00:00Z',
      'seller_total_amount': null,
    });

    expect(legacyOrder.sellerTotalAmount, isNull);
  });

  test('preserves delayed dispatch fields and non-status allowed actions', () {
    final order = OrderModel.fromJson({
      'id': 'dispatch-1',
      'customer_name': 'Delivery Customer',
      'items': const [],
      'created_at': '2026-09-02T12:00:00Z',
      'order_type': 'FOOD',
      'fulfillment_type': 'DELIVERY',
      'restaurant': {'id': 9, 'name': 'Test Cafe', 'delivery_enabled': true},
      'driver_dispatch_status': 'SCHEDULED',
      'driver_dispatch_remaining_seconds': 600,
      'driver_dispatch_max_delay_minutes': 30,
      'allowed_actions': [
        {'value': 'REQUEST_DRIVER_NOW', 'label': 'Request driver now'},
        {'value': 'RESCHEDULE_DRIVER', 'label': 'Change driver request time'},
        {'value': 'CANCELLED', 'label': 'Cancel order'},
      ],
    });

    expect(order.fulfillmentType, 'DELIVERY');
    expect(order.restaurant?.deliveryEnabled, isTrue);
    expect(order.driverDispatchStatus, 'SCHEDULED');
    expect(order.driverDispatchRemainingSeconds, 600);
    expect(order.driverDispatchMaxDelayMinutes, 30);
    expect(
      order.allowedActions.map((action) => action.value),
      containsAll(<String>[
        'REQUEST_DRIVER_NOW',
        'RESCHEDULE_DRIVER',
        'CANCELLED',
      ]),
    );
    expect(
      order.allowedStatusOptions.map((option) => option.value),
      contains('CANCELLED'),
    );
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
