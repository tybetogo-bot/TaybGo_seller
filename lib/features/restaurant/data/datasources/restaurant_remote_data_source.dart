/// Restaurant remote data source
library;

import '../../../../core/network/restaurant_api.dart';
import '../models/restaurant_model.dart';

/// Abstract interface for restaurant data source
abstract class RestaurantDataSource {
  Future<PaginatedResponse<RestaurantModel>> getRestaurants({int page = 1});
  Future<RestaurantModel> getRestaurantById(String id);
  Future<RestaurantModel> createRestaurant(Map<String, dynamic> data);
  Future<RestaurantModel> updateRestaurant(String id, Map<String, dynamic> data);
  Future<RestaurantModel> patchRestaurant(String id, Map<String, dynamic> data);
  Future<void> deleteRestaurant(String id);
}

/// Remote data source implementation
class RestaurantRemoteDataSource implements RestaurantDataSource {
  RestaurantRemoteDataSource(this._api);

  final RestaurantApi _api;

  @override
  Future<PaginatedResponse<RestaurantModel>> getRestaurants({int page = 1}) async {
    return await _api.getRestaurants(page: page);
  }

  @override
  Future<RestaurantModel> getRestaurantById(String id) async {
    return await _api.getRestaurantById(id);
  }

  @override
  Future<RestaurantModel> createRestaurant(Map<String, dynamic> data) async {
    return await _api.createRestaurant(data);
  }

  @override
  Future<RestaurantModel> updateRestaurant(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await _api.updateRestaurant(id, data);
  }

  @override
  Future<RestaurantModel> patchRestaurant(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await _api.patchRestaurant(id, data);
  }

  @override
  Future<void> deleteRestaurant(String id) async {
    await _api.deleteRestaurant(id);
  }
}
