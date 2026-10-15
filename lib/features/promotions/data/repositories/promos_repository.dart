import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/promos_api.dart';
import '../../../../core/network/restaurant_api.dart';
import '../models/promo_banner.dart';

/// Keep the server contract and user-facing error handling out of the UI.
class PromosRepository {
  const PromosRepository(this.api);
  final PromosApi api;
  Future<PaginatedResponse<PromoBanner>> list(
    String restaurantId, {
    int page = 1,
  }) => api.list(restaurantId, page: page);
  Future<PromoBanner> detail(String id) => api.detail(id);
  Future<PromoBanner> save({
    String? id,
    required String restaurantId,
    required String title,
    required String description,
    required String imageUrl,
  }) => api.save(
    id: id,
    restaurantId: restaurantId,
    title: title,
    description: description,
    imageUrl: imageUrl,
  );
  Future<PromoBanner> setActive(String id, bool active) =>
      api.setActive(id, active);
  Future<void> delete(String id) => api.delete(id);

  static String errorMessage(Object error, String fallback) {
    if (error is DioException) {
      final body = error.response?.data;
      if (body is Map) {
        final detail = body['detail'];
        if (detail is String) return detail;
        final fields = body.values
            .whereType<List>()
            .expand((value) => value)
            .whereType<String>();
        if (fields.isNotEmpty) return fields.join('\n');
      }
      if (error.error case ApiException exception) return exception.message;
    }
    return fallback;
  }
}
