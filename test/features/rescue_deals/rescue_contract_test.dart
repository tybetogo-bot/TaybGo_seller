import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teybatseller/core/i18n/i18n.dart';
import 'package:teybatseller/core/network/menu_api.dart';
import 'package:teybatseller/core/network/rescue_deals_api.dart';
import 'package:teybatseller/core/services/session_lifecycle.dart';
import 'package:teybatseller/features/restaurant/application/restaurant_state.dart';
import 'package:teybatseller/features/rescue_deals/application/rescue_deals_notifier.dart';
import 'package:teybatseller/features/rescue_deals/data/models/rescue_deal.dart';
import 'package:teybatseller/features/rescue_deals/data/repositories/rescue_deals_repository.dart';
import 'package:teybatseller/features/orders/data/models/order_model.dart';
import 'package:teybatseller/features/orders/data/models/food_checkout_model.dart';
import 'rescue_fixtures.dart';

class RestaurantChoice extends Notifier<String?> {
  @override
  String? build() => '7';
  void choose(String id) => state = id;
}

final choiceProvider = NotifierProvider<RestaurantChoice, String?>(
  RestaurantChoice.new,
);

class DelayedRepository extends RescueUiRepository {
  final calls = <String, Completer<List<RescueDeal>>>{};
  @override
  Future<List<RescueDeal>> list(String restaurantId) =>
      (calls[restaurantId] = Completer()).future;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SharedPreferences prefs;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    await SessionLifecycle.instance.end(() async {});
    SessionLifecycle.instance.accept(
      await SessionLifecycle.instance.beginLogin(),
    );
    await TranslationService.instance.load(const Locale('en'));
  });
  test('money accepts comma and Arabic input without float rounding', () {
    expect(rescueMoneyCents('6,25'), 625);
    expect(rescueMoneyCents('٦٫٢٥'), 625);
    expect(rescueMoneyCents('۶٫۲۵'), 625);
    expect(rescueMoneyCents('1.001'), isNull);
    expect(rescueMoneyCents('-1'), isNull);
    expect(rescueDecimal(625), '6.25');
  });
  test('archived, ended and paused statuses use current time', () {
    final row = rescueRow();
    final now = DateTime.now();
    row['ends_at'] = now.subtract(const Duration(seconds: 1)).toIso8601String();
    expect(RescueDeal.fromJson(row).statusAt(now), RescueStatus.ended);
    row['archived_at'] = now.toIso8601String();
    expect(RescueDeal.fromJson(row).statusAt(now), RescueStatus.archived);
  });
  test('all pages are loaded, deduplicated and tenant-filtered', () async {
    final adapter = RescueAdapter();
    final dio = Dio()..httpClientAdapter = adapter;
    adapter.respond = (options) => jsonBody({
      'count': 2,
      'next': options.queryParameters['page'] == 1
          ? '/api/seller/rescue-deals/?page=2'
          : null,
      'results': options.queryParameters['page'] == 1
          ? [rescueRow(), rescueRow(id: 'foreign', restaurant: '99')]
          : [rescueRow(), rescueRow(id: '2')],
    });
    final repository = RescueDealsRepository(RescueDealsApi(dio), MenuApi(dio));
    expect((await repository.list('7')).map((d) => d.id), ['1', '2']);
    expect(adapter.requests.map((r) => r.queryParameters['page']), [1, 2]);
  });
  test(
    'stock timeout survives reconstruction and reuses the exact key',
    () async {
      final adapter = RescueAdapter();
      final dio = Dio()..httpClientAdapter = adapter;
      final deal = RescueDeal.fromJson(rescueRow());
      final first = RescueDealsRepository(
        RescueDealsApi(dio),
        MenuApi(dio),
        stockStore: RescueStockStore(prefs, 'seller-a'),
      );
      adapter.respond = (options) => throw DioException(
        requestOptions: options,
        type: DioExceptionType.receiveTimeout,
      );
      await expectLater(
        first.adjustStock(deal, 3, isCurrent: () => true),
        throwsA(isA<DioException>()),
      );
      final key = first.pending(deal)!.key;
      final next = RescueDealsRepository(
        RescueDealsApi(dio),
        MenuApi(dio),
        stockStore: RescueStockStore(prefs, 'seller-a'),
      );
      expect(RescueStockStore(prefs, 'seller-b').read(deal), isNull);
      await expectLater(
        next.adjustStock(deal, 4, isCurrent: () => true),
        throwsStateError,
      );
      adapter.respond = (_) =>
          jsonBody({...rescueRow(), 'remaining_qty': 10, 'max_qty': 15});
      final updated = await next.adjustStock(deal, 3, isCurrent: () => true);
      expect(updated.remainingQty, 10);
      expect(adapter.requests.length, 2);
      for (final request in adapter.requests) {
        expect((request.data as Map)['idempotency_key'], key);
        expect(request.extra['disableRetry'], true);
        expect(request.path, '/api/seller/rescue-deals/1/stock/');
      }
      expect(next.pending(deal), isNull);
    },
  );
  test(
    'definitive validation rejection clears pending stock attempt',
    () async {
      final adapter = RescueAdapter()
        ..respond = (_) => jsonBody({
          'quantity_delta': ['Not enough stock'],
        }, status: 400);
      final dio = Dio()..httpClientAdapter = adapter;
      final repo = RescueDealsRepository(
        RescueDealsApi(dio),
        MenuApi(dio),
        stockStore: RescueStockStore(prefs, 'a'),
      );
      final deal = RescueDeal.fromJson(rescueRow());
      await expectLater(
        repo.adjustStock(deal, -9, isCurrent: () => true),
        throwsA(isA<DioException>()),
      );
      expect(repo.pending(deal), isNull);
    },
  );
  test('a restaurant switch discards an earlier list response', () async {
    final repository = DelayedRepository();
    final container = ProviderContainer(
      overrides: [
        rescueDealsRepositoryProvider.overrideWithValue(repository),
        selectedRestaurantIdProvider.overrideWith(
          (ref) => ref.watch(choiceProvider),
        ),
      ],
    );
    addTearDown(container.dispose);
    final sub = container.listen(rescueDealsProvider, (_, _) {});
    addTearDown(sub.close);
    await Future<void>.delayed(Duration.zero);
    container.read(choiceProvider.notifier).choose('8');
    await Future<void>.delayed(Duration.zero);
    repository.calls['8']!.complete([
      RescueDeal.fromJson(rescueRow(id: 'new', restaurant: '8')),
    ]);
    await Future<void>.delayed(Duration.zero);
    repository.calls['7']!.complete([
      RescueDeal.fromJson(rescueRow(id: 'old')),
    ]);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(rescueDealsProvider).items.single.id, 'new');
  });
  test(
    'order snapshots and rescue identity survive copying and cart payloads',
    () {
      final item = OrderItemModel.fromJson({
        'id': 7,
        'item': 21,
        'item_name': 'Meal',
        'quantity': 2,
        'price': '10.00',
        'unit_price_snapshot': '6.00',
        'original_unit_price_snapshot': '10.00',
        'rescue_deal_id': 12,
        'pricing_source': 'RESCUE_DEAL',
      });
      expect(item.unitPrice, 6);
      expect(item.originalUnitPrice, 10);
      expect(item.copyWith(quantity: 3).rescueDealId, '12');
      expect(item.isRescueDeal, true);
      expect(
        const CartItem(
          itemId: 21,
          quantity: 2,
          rescueDealId: 12,
          expectedDealPrice: '6.00',
        ).toJson(),
        {
          'item_id': 21,
          'quantity': 2,
          'rescue_deal_id': 12,
          'expected_deal_price': '6.00',
        },
      );
    },
  );
}
