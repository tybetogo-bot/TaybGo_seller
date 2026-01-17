/// Restaurant repository interface and implementation
library;

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/config/constants.dart';
import '../datasources/restaurant_remote_data_source.dart';
import '../models/restaurant_model.dart';

/// Result type for repository methods
typedef RestaurantResult<T> = ({Failure? failure, T? data});

/// Restaurant repository interface
abstract class RestaurantRepository {
  Future<RestaurantResult<List<RestaurantModel>>> getRestaurants({int page = 1});
  Future<RestaurantResult<RestaurantModel>> getRestaurantById(String id);
  Future<RestaurantResult<RestaurantModel>> createRestaurant(Map<String, dynamic> data);
  Future<RestaurantResult<RestaurantModel>> updateRestaurant(String id, Map<String, dynamic> data);
  Future<RestaurantResult<RestaurantModel>> patchRestaurant(String id, Map<String, dynamic> data);
  Future<RestaurantResult<void>> deleteRestaurant(String id);

  // Local storage for selected restaurant
  Future<void> saveSelectedRestaurantId(String id);
  String? getSelectedRestaurantId();
  Future<void> clearSelectedRestaurant();
}

/// Implementation of restaurant repository
class RestaurantRepositoryImpl implements RestaurantRepository {
  RestaurantRepositoryImpl({
    required RestaurantDataSource remoteDataSource,
    required SharedPreferences prefs,
  })  : _remoteDataSource = remoteDataSource,
        _prefs = prefs;

  final RestaurantDataSource _remoteDataSource;
  final SharedPreferences _prefs;

  @override
  Future<RestaurantResult<List<RestaurantModel>>> getRestaurants({
    int page = 1,
  }) async {
    try {
      final response = await _remoteDataSource.getRestaurants(page: page);
      return (failure: null, data: response.results);
    } on DioException catch (e) {
      final apiError = e.error;
      if (apiError is ApiException) {
        return (
          failure: ServerFailure(message: apiError.message),
          data: null,
        );
      }
      return (
        failure: const NetworkFailure(message: 'Network error occurred'),
        data: null,
      );
    } on NetworkException catch (e) {
      return (failure: NetworkFailure(message: e.message), data: null);
    } catch (e) {
      return (
        failure: const ServerFailure(message: 'An unexpected error occurred'),
        data: null,
      );
    }
  }

  @override
  Future<RestaurantResult<RestaurantModel>> getRestaurantById(String id) async {
    try {
      final restaurant = await _remoteDataSource.getRestaurantById(id);
      return (failure: null, data: restaurant);
    } on DioException catch (e) {
      final apiError = e.error;
      if (apiError is ApiException) {
        return (
          failure: ServerFailure(message: apiError.message),
          data: null,
        );
      }
      return (
        failure: const NetworkFailure(message: 'Network error occurred'),
        data: null,
      );
    } on NetworkException catch (e) {
      return (failure: NetworkFailure(message: e.message), data: null);
    } catch (e) {
      return (
        failure: const ServerFailure(message: 'An unexpected error occurred'),
        data: null,
      );
    }
  }

  @override
  Future<RestaurantResult<RestaurantModel>> createRestaurant(
    Map<String, dynamic> data,
  ) async {
    try {
      final restaurant = await _remoteDataSource.createRestaurant(data);
      return (failure: null, data: restaurant);
    } on DioException catch (e) {
      final apiError = e.error;
      if (apiError is ApiException) {
        return (
          failure: ValidationFailure(message: apiError.message),
          data: null,
        );
      }
      return (
        failure: const NetworkFailure(message: 'Network error occurred'),
        data: null,
      );
    } catch (e) {
      return (
        failure: const ServerFailure(message: 'An unexpected error occurred'),
        data: null,
      );
    }
  }

  @override
  Future<RestaurantResult<RestaurantModel>> updateRestaurant(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final restaurant = await _remoteDataSource.updateRestaurant(id, data);
      return (failure: null, data: restaurant);
    } on DioException catch (e) {
      final apiError = e.error;
      if (apiError is ApiException) {
        return (
          failure: ValidationFailure(message: apiError.message),
          data: null,
        );
      }
      return (
        failure: const NetworkFailure(message: 'Network error occurred'),
        data: null,
      );
    } catch (e) {
      return (
        failure: const ServerFailure(message: 'An unexpected error occurred'),
        data: null,
      );
    }
  }

  @override
  Future<RestaurantResult<RestaurantModel>> patchRestaurant(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final restaurant = await _remoteDataSource.patchRestaurant(id, data);
      return (failure: null, data: restaurant);
    } on DioException catch (e) {
      final apiError = e.error;
      if (apiError is ApiException) {
        return (
          failure: ValidationFailure(message: apiError.message),
          data: null,
        );
      }
      return (
        failure: const NetworkFailure(message: 'Network error occurred'),
        data: null,
      );
    } catch (e) {
      return (
        failure: const ServerFailure(message: 'An unexpected error occurred'),
        data: null,
      );
    }
  }

  @override
  Future<RestaurantResult<void>> deleteRestaurant(String id) async {
    try {
      await _remoteDataSource.deleteRestaurant(id);
      return (failure: null, data: null);
    } on DioException catch (e) {
      final apiError = e.error;
      if (apiError is ApiException) {
        return (
          failure: ServerFailure(message: apiError.message),
          data: null,
        );
      }
      return (
        failure: const NetworkFailure(message: 'Network error occurred'),
        data: null,
      );
    } catch (e) {
      return (
        failure: const ServerFailure(message: 'An unexpected error occurred'),
        data: null,
      );
    }
  }

  @override
  Future<void> saveSelectedRestaurantId(String id) async {
    await _prefs.setString(StorageKeys.restaurantId, id);
  }

  @override
  String? getSelectedRestaurantId() {
    return _prefs.getString(StorageKeys.restaurantId);
  }

  @override
  Future<void> clearSelectedRestaurant() async {
    await _prefs.remove(StorageKeys.restaurantId);
  }
}
