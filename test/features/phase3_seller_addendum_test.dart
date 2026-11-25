import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teybatseller/core/config/constants.dart';
import 'package:teybatseller/core/i18n/i18n.dart';
import 'package:teybatseller/core/network/orders_api.dart';
import 'package:teybatseller/core/network/user_api.dart';
import 'package:teybatseller/core/providers/providers.dart';
import 'package:teybatseller/core/services/session_lifecycle.dart';
import 'package:teybatseller/features/menu/data/models/menu_item_model.dart';
import 'package:teybatseller/features/monthly_exports/application/monthly_exports_notifier.dart';
import 'package:teybatseller/features/monthly_exports/presentation/monthly_exports_screen.dart';
import 'package:teybatseller/features/orders/application/orders_notifier.dart';
import 'package:teybatseller/features/orders/data/models/food_checkout_model.dart';
import 'package:teybatseller/features/orders/data/models/order_model.dart';
import 'package:teybatseller/features/orders/presentation/screens/order_details_screen.dart';
import 'package:teybatseller/features/restaurant/application/restaurant_state.dart';
import 'package:teybatseller/features/restaurant/data/models/restaurant_model.dart';

typedef _MockResponder =
    ResponseBody Function(
      RequestOptions options,
      Stream<Uint8List>? requestStream,
    );

class _MockDioAdapter implements HttpClientAdapter {
  _MockDioAdapter(this.handler);

  final _MockResponder handler;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return handler(options, requestStream);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await TranslationService.instance.load(const Locale('en'));
  });

  setUp(() async {
    await SessionLifecycle.instance.end(() async {});
    SessionLifecycle.instance.accept(
      await SessionLifecycle.instance.beginLogin(),
    );
  });

  group('Phase 3 Seller Models & Validation', () {
    test('email validation normalizes case and supports long TLDs', () {
      expect(
        ValidationPatterns.normalizeEmail('  Seller.Owner+AT@Market.Shop '),
        'seller.owner+at@market.shop',
      );
      expect(
        ValidationPatterns.email.hasMatch('owner@taybgo.technology'),
        isTrue,
      );
      expect(ValidationPatterns.email.hasMatch('invalid@localhost'), isFalse);

      final missingEmailUser = UserProfile.fromJson({
        'id': 1,
        'phone': '+43660123456',
        'email': '   ',
      });
      expect(missingEmailUser.needsEmail, isTrue);

      final completeUser = UserProfile.fromJson({
        'id': 2,
        'phone': '+43660123457',
        'email': 'Owner@TaybGo.At',
        'needs_email': false,
      });
      expect(completeUser.email, 'owner@taybgo.at');
      expect(completeUser.needsEmail, isFalse);
    });

    test('RestaurantModel parses store_type and min_order_amount', () {
      final market = RestaurantModel.fromJson({
        'id': 12,
        'name': 'Vienna Biomarkt',
        'store_type': 'GENERAL_MARKET',
        'min_order_amount': '18.50',
        'status': 'ACTIVE',
      });
      expect(market.storeType, 'GENERAL_MARKET');
      expect(market.isGeneralMarket, isTrue);
      expect(market.minimumOrder, 18.50);
    });

    test('MenuItemModel tracks stock separately from manual availability', () {
      final outOfStockButEnabled = MenuItemModel.fromJson({
        'id': 55,
        'name': 'Organic Milk 1L',
        'price': '2.40',
        'category': 3,
        'is_available': true,
        'stock_quantity': 0,
        'is_out_of_stock': true,
        'effective_is_available': false,
      });
      expect(outOfStockButEnabled.isAvailable, isTrue);
      expect(outOfStockButEnabled.stockQuantity, 0);
      expect(outOfStockButEnabled.isOutOfStock, isTrue);
      expect(outOfStockButEnabled.effectiveAvailability, isFalse);
    });

    test('OrderModel parses PICKUP, attachments, change requests, and splits', () {
      final order = OrderModel.fromJson({
        'id': 91,
        'created_at': '2026-11-24T10:00:00Z',
        'order_type': 'FOOD',
        'fulfillment_type': 'PICKUP',
        'status': 'PENDING',
        'is_paid': false,
        'total_amount': '24.50',
        'seller_total_amount': '24.50',
        'gift_card_amount_applied': '10.00',
        'cash_amount_due': '14.50',
        'card_amount_due': '0.00',
        'has_pending_change_request': true,
        'pending_change_request': {
          'id': 'cr-123',
          'status': 'PENDING',
          'proposed_total': '22.00',
          'expires_at': '2099-01-01T12:00:00Z',
        },
        'attachments': [
          {
            'id': 'att-1',
            'original_filename': 'list.pdf',
            'mime_type': 'application/pdf',
            'size_bytes': 12400,
            'download_url': 'https://cdn.example.test/list.pdf?sig=1',
          },
          {
            'id': 'att-2',
            'original_filename': 'photo.jpg',
            'mime_type': 'image/jpeg',
            'size_bytes': 40200,
            'download_url': 'https://cdn.example.test/photo.jpg?sig=2',
          },
        ],
        'items': const <Map<String, dynamic>>[],
      });

      expect(order.isPickup, isTrue);
      expect(order.hasActiveChangeRequest, isTrue);
      expect(order.pendingChangeRequest?.id, 'cr-123');
      expect(order.attachments, hasLength(2));
      expect(order.attachments[0].isPdf, isTrue);
      expect(order.attachments[1].isImage, isTrue);
      expect(order.giftCardAmountApplied, 10.0);
      expect(order.cashAmountDue, 14.5);
    });
  });

  group('Phase 3 Seller API Contracts & Screens', () {
    test('OrdersApi.proposeOrderChangeRequest preserves rescue deal lines', () async {
      RequestOptions? captured;
      final dio = Dio();
      dio.httpClientAdapter = _MockDioAdapter((options, _) {
        if (options.method == 'POST' &&
            options.path == '/api/seller/orders/42/change-requests/') {
          captured = options;
          return ResponseBody.fromString(
            jsonEncode({
              'order': {
                'id': 42,
                'created_at': '2026-11-24T10:00:00Z',
                'status': 'PENDING',
                'has_pending_change_request': true,
                'items': const <Map<String, dynamic>>[],
              },
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        if (options.method == 'GET' && options.path == '/api/seller/orders/42/') {
          return ResponseBody.fromString(
            jsonEncode({
              'id': 42,
              'created_at': '2026-11-24T10:00:00Z',
              'status': 'PENDING',
              'has_pending_change_request': true,
              'items': const <Map<String, dynamic>>[],
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        return ResponseBody.fromString('{}', 404);
      });

      final api = OrdersApi(dio);
      final updated = await api.proposeOrderChangeRequest(
        '42',
        idempotencyKey: 'uuid-v4-key',
        reason: 'Item out of stock',
        items: const [
          CartItem(itemId: 7, quantity: 1),
          CartItem(
            itemId: 7,
            quantity: 2,
            rescueDealId: 99,
            expectedDealPrice: '4.50',
          ),
        ],
      );

      expect(updated.hasActiveChangeRequest, isTrue);
      expect(captured?.data['idempotency_key'], 'uuid-v4-key');
      expect(captured?.data['reason'], 'Item out of stock');
      expect(captured?.data['items'], [
        {'item_id': 7, 'quantity': 1},
        {
          'item_id': 7,
          'quantity': 2,
          'rescue_deal_id': 99,
          'expected_deal_price': '4.50',
        },
      ]);
    });

    test('MonthlyExportsNotifier fetches list and fresh signed download URL', () async {
      final dio = Dio();
      dio.httpClientAdapter = _MockDioAdapter((options, _) {
        if (options.path == '/api/seller/exports/monthly/') {
          return ResponseBody.fromString(
            jsonEncode({
              'results': [
                {
                  'id': 9,
                  'restaurant': 12,
                  'restaurant_name': 'Vienna Biomarkt',
                  'store_type': 'GENERAL_MARKET',
                  'year': 2026,
                  'month': 10,
                  'period_label': '10.2026',
                  'status': 'READY',
                  'row_count': 44,
                  'summary_json': {'gross_total_eur': '1890.50'},
                  'download_url': 'https://cdn.example.test/old.pdf',
                },
              ],
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        if (options.path == '/api/seller/exports/monthly/9/') {
          return ResponseBody.fromString(
            jsonEncode({
              'id': 9,
              'restaurant': 12,
              'restaurant_name': 'Vienna Biomarkt',
              'store_type': 'GENERAL_MARKET',
              'year': 2026,
              'month': 10,
              'period_label': '10.2026',
              'status': 'READY',
              'row_count': 44,
              'download_url': 'https://cdn.example.test/fresh-signed.pdf?sig=abc',
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        return ResponseBody.fromString('{}', 404);
      });

      final container = ProviderContainer(
        overrides: [
          dioProvider.overrideWithValue(dio),
          selectedRestaurantIdProvider.overrideWithValue('12'),
        ],
      );
      addTearDown(container.dispose);

      await container.read(monthlyExportsProvider.notifier).loadExports();
      final state = container.read(monthlyExportsProvider);
      expect(state.exports, hasLength(1));
      expect(state.exports.first.periodLabel, '10.2026');
      expect(state.exports.first.grossTotalEur, 1890.50);

      final freshUrl = await container
          .read(monthlyExportsProvider.notifier)
          .fetchFreshDownloadUrl(state.exports.first);
      expect(freshUrl, 'https://cdn.example.test/fresh-signed.pdf?sig=abc');
    });

    testWidgets('MonthlyExportsScreen renders statements', (tester) async {
      final dio = Dio();
      dio.httpClientAdapter = _MockDioAdapter((options, _) {
        if (options.path == '/api/seller/exports/monthly/') {
          return ResponseBody.fromString(
            jsonEncode({
              'results': [
                {
                  'id': 9,
                  'restaurant': 12,
                  'restaurant_name': 'Vienna Biomarkt',
                  'year': 2026,
                  'month': 10,
                  'period_label': '10.2026',
                  'status': 'READY',
                  'row_count': 44,
                  'summary_json': {'gross_total_eur': '1890.50'},
                },
              ],
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        return ResponseBody.fromString('{}', 404);
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dioProvider.overrideWithValue(dio),
            selectedRestaurantIdProvider.overrideWithValue('12'),
          ],
          child: ScreenUtilInit(
            designSize: const Size(390, 844),
            builder: (_, _) => const MaterialApp(home: MonthlyExportsScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('10.2026'), findsOneWidget);
      expect(find.text('Vienna Biomarkt'), findsOneWidget);
      expect(find.byKey(const ValueKey('download-monthly-pdf-9')), findsOneWidget);
    });

    testWidgets(
      'OrderDetailsScreen shows IN-STORE PICKUP, pending change lock, attachments, and split payment',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        tester.view.physicalSize = const Size(390, 2000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final order = OrderModel.fromJson({
          'id': 91,
          'created_at': '2026-11-24T10:00:00Z',
          'order_type': 'FOOD',
          'fulfillment_type': 'PICKUP',
          'status': 'PENDING',
          'is_paid': false,
          'subtotal_amount': '24.50',
          'total_amount': '24.50',
          'seller_total_amount': '24.50',
          'gift_card_amount_applied': '10.00',
          'cash_amount_due': '14.50',
          'has_pending_change_request': true,
          'pending_change_request': {
            'id': 'cr-123',
            'status': 'PENDING',
            'proposed_total': '22.00',
          },
          'allowed_actions': [
            {'value': 'ACCEPTED', 'label': 'Accept'},
          ],
          'attachments': [
            {
              'id': 'att-1',
              'original_filename': 'prescription.pdf',
              'mime_type': 'application/pdf',
              'size_bytes': 12400,
              'download_url': 'https://cdn.example.test/list.pdf?sig=1',
            },
          ],
          'items': [
            {
              'id': 1,
              'item': 10,
              'item_name': 'Olive Oil',
              'quantity': 1,
              'unit_price_snapshot': '24.50',
            },
          ],
        });

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(prefs),
              orderByIdProvider('91').overrideWithValue(order),
              selectedRestaurantProvider.overrideWithValue(
                const RestaurantModel(
                  id: '12',
                  name: 'Vienna Biomarkt',
                  storeType: 'GENERAL_MARKET',
                ),
              ),
            ],
            child: ScreenUtilInit(
              designSize: const Size(390, 844),
              builder: (_, _) =>
                  const MaterialApp(home: OrderDetailsScreen(orderId: '91')),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('orders.inStorePickup'.tr), findsOneWidget);
        expect(
          find.text('orders.awaitingCustomerApproval'.tr),
          findsNWidgets(2),
        );
        expect(find.text('prescription.pdf'), findsOneWidget);
        expect(find.text('-€10.00'), findsOneWidget);
        expect(find.text('€14.50'), findsOneWidget);
        expect(find.text('orders.deliverTo'.tr), findsNothing);
      },
    );
  });
}
