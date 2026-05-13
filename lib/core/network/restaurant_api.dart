// Restaurant API service using Dio directly.

import 'package:dio/dio.dart';

import '../../features/restaurant/data/models/restaurant_model.dart';

/// Paginated response wrapper
class PaginatedResponse<T> {
  final int count;
  final String? next;
  final String? previous;
  final List<T> results;

  PaginatedResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse(
      count: json['count'] as int,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List)
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Restaurant API service for seller restaurant management
class RestaurantApi {
  final Dio _dio;

  RestaurantApi(this._dio);

  /// List seller's restaurants
  /// GET /api/seller/restaurants/
  Future<PaginatedResponse<RestaurantModel>> getRestaurants({
    int page = 1,
  }) async {
    final response = await _dio.get(
      '/api/seller/restaurants/',
      queryParameters: {'page': page},
    );
    return PaginatedResponse.fromJson(
      response.data as Map<String, dynamic>,
      RestaurantModel.fromJson,
    );
  }

  /// Get restaurant details with today's stats
  /// GET /api/seller/restaurants/{id}/
  Future<RestaurantModel> getRestaurantById(String id) async {
    final response = await _dio.get('/api/seller/restaurants/$id/');
    return _restaurantFromResponse(response.data, fallbackId: id);
  }

  /// Create new restaurant
  /// POST /api/seller/restaurants/
  Future<RestaurantModel> createRestaurant(Map<String, dynamic> data) async {
    final response = await _dio.post('/api/seller/restaurants/', data: data);
    return RestaurantModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Update restaurant (full update)
  /// PUT /api/seller/restaurants/{id}/
  Future<RestaurantModel> updateRestaurant(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.put('/api/seller/restaurants/$id/', data: data);
    return _restaurantFromResponse(response.data, fallbackId: id);
  }

  /// Partial update restaurant
  /// PATCH /api/seller/restaurants/{id}/
  Future<RestaurantModel> patchRestaurant(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.patch(
      '/api/seller/restaurants/$id/',
      data: data,
    );
    return _restaurantFromResponse(response.data, fallbackId: id);
  }

  /// Delete restaurant
  /// DELETE /api/seller/restaurants/{id}/
  Future<void> deleteRestaurant(String id) async {
    await _dio.delete('/api/seller/restaurants/$id/');
  }

  RestaurantModel _restaurantFromResponse(
    dynamic responseData, {
    required String fallbackId,
  }) {
    final json = Map<String, dynamic>.from(responseData as Map);
    if ((json['id']?.toString().isEmpty ?? true) && fallbackId.isNotEmpty) {
      json['id'] = fallbackId;
    }
    return RestaurantModel.fromJson(json);
  }
}
