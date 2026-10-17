import 'package:dio/dio.dart';
import '../config/constants.dart';
import '../../features/rescue_deals/data/models/rescue_deal.dart';
import 'restaurant_api.dart';

class RescueDealsApi {
  const RescueDealsApi(this.dio);
  final Dio dio;
  Future<PaginatedResponse<RescueDeal>> list(
    String restaurantId, {
    int page = 1,
  }) async {
    final response = await dio.get(
      ApiEndpoints.sellerRescueDeals,
      queryParameters: {'restaurant_id': restaurantId, 'page': page},
    );
    if (response.data is List) {
      final rows = (response.data as List)
          .map((e) => RescueDeal.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      return PaginatedResponse(count: rows.length, results: rows);
    }
    return PaginatedResponse.fromJson(
      Map<String, dynamic>.from(response.data as Map),
      RescueDeal.fromJson,
    );
  }

  Future<RescueDeal> detail(String id) async =>
      _parse(await dio.get(ApiEndpoints.sellerRescueDeal(id)));
  Future<RescueDeal> save(Map<String, dynamic> data, {String? id}) async =>
      _parse(
        id == null
            ? await dio.post(
                ApiEndpoints.sellerRescueDeals,
                data: data,
                options: _write,
              )
            : await dio.patch(
                ApiEndpoints.sellerRescueDeal(id),
                data: data,
                options: _write,
              ),
      );
  Future<void> archive(String id) =>
      dio.delete(ApiEndpoints.sellerRescueDeal(id), options: _write);
  Future<RescueDeal> stock(String id, int delta, String key) async => _parse(
    await dio.post(
      ApiEndpoints.sellerRescueDealStock(id),
      data: {'quantity_delta': delta, 'idempotency_key': key},
      options: _write,
    ),
  );
  static Options get _write => Options(extra: {'disableRetry': true});
  static RescueDeal _parse(Response response) =>
      RescueDeal.fromJson(Map<String, dynamic>.from(response.data as Map));
}
