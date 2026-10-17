import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:teybatseller/core/network/rescue_deals_api.dart';
import 'package:teybatseller/core/network/menu_api.dart';
import 'package:teybatseller/features/menu/data/models/menu_item_model.dart';
import 'package:teybatseller/features/rescue_deals/data/models/rescue_deal.dart';
import 'package:teybatseller/features/rescue_deals/data/repositories/rescue_deals_repository.dart';

Map<String, dynamic> rescueRow({
  String id = '1',
  String restaurant = '7',
  String name = 'Roasted vegetable bowl',
}) => {
  'archived_at': null,
  'id': id,
  'restaurant': restaurant,
  'item': '21',
  'item_name': name,
  'original_price_snapshot': '10.00',
  'deal_price': '6.00',
  'starts_at': DateTime.now()
      .subtract(const Duration(hours: 1))
      .toUtc()
      .toIso8601String(),
  'ends_at': DateTime.now()
      .add(const Duration(hours: 3))
      .toUtc()
      .toIso8601String(),
  'max_qty': 12,
  'remaining_qty': 7,
  'reserved_qty': 2,
  'sold_qty': 3,
  'max_per_customer': 2,
  'is_active': true,
  'status': 'LIVE',
};

class RescueAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  FutureOr<ResponseBody> Function(RequestOptions)? respond;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return await respond?.call(options) ?? jsonBody(rescueRow());
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonBody(Object data, {int status = 200}) =>
    ResponseBody.fromString(
      jsonEncode(data),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );

class RescueUiRepository extends RescueDealsRepository {
  RescueUiRepository() : super(RescueDealsApi(Dio()), MenuApi(Dio()));
  final rows = <Map<String, dynamic>>[rescueRow()];
  final saves = <Map<String, dynamic>>[];
  final stockCalls = <int>[];
  Object? saveError;
  Future<RescueDeal>? deferredSave;
  Future<RescueDeal>? deferredDetail;
  bool archived = false;
  @override
  Future<List<RescueDeal>> list(String restaurantId) async => rows
      .where((r) => r['restaurant'].toString() == restaurantId)
      .map(RescueDeal.fromJson)
      .toList();
  @override
  Future<List<MenuItemModel>> catalog(String restaurantId) async => [
    const MenuItemModel(
      id: '21',
      name: 'Roasted vegetable bowl',
      price: 10,
      categoryId: '2',
    ),
  ];
  @override
  Future<RescueDeal> detail(String id) async =>
      await deferredDetail ??
      RescueDeal.fromJson(rows.firstWhere((r) => r['id'] == id));
  @override
  Future<RescueDeal> save(Map<String, dynamic> data, {String? id}) async {
    saves.add({...data});
    if (saveError != null) throw saveError!;
    if (deferredSave != null) return deferredSave!;
    final row = {...rescueRow(), ...data, 'id': id ?? '1'};
    rows[0] = row;
    return RescueDeal.fromJson(row);
  }

  @override
  Future<RescueDeal> setActive(String id, bool active) async {
    rows[0]['is_active'] = active;
    return RescueDeal.fromJson(rows[0]);
  }

  @override
  Future<void> archive(String id) async {
    archived = true;
    rows[0]['archived_at'] = DateTime.now().toUtc().toIso8601String();
    rows[0]['is_active'] = false;
  }

  @override
  Future<RescueDeal> adjustStock(
    RescueDeal deal,
    int delta, {
    required bool Function() isCurrent,
  }) async {
    stockCalls.add(delta);
    rows[0]['remaining_qty'] = deal.remainingQty + delta;
    rows[0]['max_qty'] = deal.maxQty + delta;
    return RescueDeal.fromJson(rows[0]);
  }
}
