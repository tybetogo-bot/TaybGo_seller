import 'package:dio/dio.dart';
import '../config/constants.dart';
import '../../features/promotions/data/models/promo_banner.dart';
import 'restaurant_api.dart';

class PromosApi {
  const PromosApi(this._dio);
  final Dio _dio;

  Future<PaginatedResponse<PromoBanner>> list(
    String restaurantId, {
    int page = 1,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.sellerPromos,
      queryParameters: {'restaurant_id': restaurantId, 'page': page},
    );
    final data = response.data;
    if (data is List) {
      final items = data
          .map((e) => PromoBanner.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      return PaginatedResponse(count: items.length, results: items);
    }
    return PaginatedResponse.fromJson(
      Map<String, dynamic>.from(data as Map),
      PromoBanner.fromJson,
    );
  }

  Future<PromoBanner> detail(String id) async => PromoBanner.fromJson(
    Map<String, dynamic>.from(
      (await _dio.get(ApiEndpoints.sellerPromo(id))).data as Map,
    ),
  );

  Future<PromoBanner> save({
    String? id,
    required String restaurantId,
    required String title,
    required String description,
    required String imageUrl,
  }) async {
    final data = {
      'title': title.trim(),
      'description': description.trim(),
      'image_url': imageUrl,
    };
    final response = id == null
        ? await _dio.post(
            ApiEndpoints.sellerPromos,
            data: {...data, 'restaurant_id': int.parse(restaurantId)},
            options: Options(extra: {'disableRetry': true}),
          )
        : await _dio.patch(
            ApiEndpoints.sellerPromo(id),
            data: data,
            options: Options(extra: {'disableRetry': true}),
          );
    return PromoBanner.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<PromoBanner> setActive(String id, bool active) async {
    final response = await _dio.post(
      ApiEndpoints.sellerPromoAction(id, active ? 'activate' : 'deactivate'),
      options: Options(extra: {'disableRetry': true}),
    );
    return PromoBanner.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<void> delete(String id) async {
    await _dio.delete(ApiEndpoints.sellerPromo(id));
  }
}
