import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/config/constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/rescue_deals_api.dart';
import '../../../../core/network/menu_api.dart';
import '../../../../core/services/session_lifecycle.dart';
import '../../../menu/data/models/menu_item_model.dart';
import '../models/rescue_deal.dart';

class PendingStockAdjustment {
  const PendingStockAdjustment(this.key, this.delta);
  final String key;
  final int delta;
}

/// Account/restaurant/deal scoped, retained until a request has a known outcome.
class RescueStockStore {
  const RescueStockStore(this.prefs, this.ownerId);
  final SharedPreferences prefs;
  final String ownerId;
  String _key(RescueDeal deal) =>
      '${StorageKeys.rescueStockPending}:$ownerId:${deal.restaurantId}:${deal.id}';
  PendingStockAdjustment? read(RescueDeal deal) {
    final raw = prefs.getString(_key(deal));
    if (raw == null) return null;
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return PendingStockAdjustment(data['key'] as String, data['delta'] as int);
  }

  Future<PendingStockAdjustment> prepare(RescueDeal deal, int delta) =>
      SessionLifecycle.instance.serializeWrite(() async {
        final previous = read(deal);
        if (previous != null) {
          if (previous.delta != delta) {
            throw StateError('A stock update is still pending.');
          }
          return previous;
        }
        final pending = PendingStockAdjustment(const Uuid().v4(), delta);
        if (!await prefs.setString(
          _key(deal),
          jsonEncode({'key': pending.key, 'delta': delta}),
        )) {
          throw StateError('Unable to safely save the stock update.');
        }
        return pending;
      });
  Future<void> clear(RescueDeal deal, String key) =>
      SessionLifecycle.instance.serializeWrite(() async {
        if (read(deal)?.key == key) await prefs.remove(_key(deal));
      });
}

class RescueDealsRepository {
  const RescueDealsRepository(this.api, this.menu, {this.stockStore});
  final RescueDealsApi api;
  final MenuApi menu;
  final RescueStockStore? stockStore;
  Future<List<RescueDeal>> list(String restaurantId) async {
    final items = <String, RescueDeal>{};
    var page = 1;
    final seen = <int>{};
    while (seen.add(page)) {
      final result = await api.list(restaurantId, page: page);
      for (final deal in result.results) {
        if (deal.restaurantId == restaurantId) items[deal.id] = deal;
      }
      if (result.next == null) return items.values.toList();
      page =
          int.tryParse(Uri.parse(result.next!).queryParameters['page'] ?? '') ??
          page + 1;
    }
    throw const FormatException('Repeated pagination page');
  }

  Future<List<MenuItemModel>> catalog(String restaurantId) async {
    final items = <String, MenuItemModel>{};
    var page = 1;
    final seen = <int>{};
    while (seen.add(page)) {
      final result = await menu.getItems(
        restaurantId: restaurantId,
        page: page,
      );
      for (final item in result.results) {
        items[item.id] = item;
      }
      if (result.next == null) return items.values.toList();
      page =
          int.tryParse(Uri.parse(result.next!).queryParameters['page'] ?? '') ??
          page + 1;
    }
    throw const FormatException('Repeated catalog page');
  }

  Future<RescueDeal> detail(String id) => api.detail(id);
  Future<RescueDeal> save(Map<String, dynamic> data, {String? id}) =>
      api.save(data, id: id);
  Future<void> archive(String id) => api.archive(id);
  Future<RescueDeal> setActive(String id, bool active) =>
      api.save({'is_active': active}, id: id);
  PendingStockAdjustment? pending(RescueDeal deal) => stockStore?.read(deal);
  Future<RescueDeal> adjustStock(
    RescueDeal deal,
    int delta, {
    required bool Function() isCurrent,
  }) async {
    final store = stockStore;
    if (store == null) throw StateError('Seller profile is still loading.');
    final pending = await store.prepare(deal, delta);
    if (!isCurrent()) throw StateError('Session changed.');
    try {
      final updated = await api.stock(deal.id, pending.delta, pending.key);
      await store.clear(deal, pending.key);
      return updated;
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      // A timeout or server failure may follow a successful write; retain its key.
      if (status != null &&
          status >= 400 &&
          status < 500 &&
          status != 408 &&
          status != 429) {
        await store.clear(deal, pending.key);
      }
      rethrow;
    }
  }

  static Map<String, String> fieldErrors(Object error) {
    if (error is! DioException || error.response?.data is! Map) return {};
    final body = error.response!.data as Map;
    return {
      for (final entry in body.entries)
        if (entry.value is List && (entry.value as List).isNotEmpty)
          entry.key.toString(): (entry.value as List).join('\n'),
    };
  }

  static String errorMessage(Object error, String fallback) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['detail'] is String) {
        return data['detail'] as String;
      }
      final fields = fieldErrors(error);
      if (fields.isNotEmpty) return fields.values.join('\n');
      if (error.error case ApiException exception) return exception.message;
    }
    return fallback;
  }
}
