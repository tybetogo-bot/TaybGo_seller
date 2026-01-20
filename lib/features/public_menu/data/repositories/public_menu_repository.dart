import 'package:dio/dio.dart';

import '../../../menu/data/models/menu_item_model.dart';
import '../../../restaurant/data/models/restaurant_model.dart';
import '../datasources/public_menu_data_source.dart';

/// Result type for repository operations
typedef PublicMenuResult<T> = ({T? data, String? error});

/// Abstract repository for public menu
abstract class PublicMenuRepository {
  Future<PublicMenuResult<RestaurantModel>> getRestaurant(String restaurantId);
  Future<PublicMenuResult<List<CategoryModel>>> getCategories(
      String restaurantId);
  Future<PublicMenuResult<List<MenuItemModel>>> getMenuItems(
      String restaurantId);
}

/// Implementation of public menu repository with error handling
class PublicMenuRepositoryImpl implements PublicMenuRepository {
  final PublicMenuDataSource _dataSource;

  PublicMenuRepositoryImpl(this._dataSource);

  @override
  Future<PublicMenuResult<RestaurantModel>> getRestaurant(
      String restaurantId) async {
    try {
      final restaurant = await _dataSource.getRestaurant(restaurantId);
      return (data: restaurant, error: null);
    } on DioException catch (e) {
      return (data: null, error: _handleDioError(e));
    } catch (e) {
      return (data: null, error: 'An unexpected error occurred');
    }
  }

  @override
  Future<PublicMenuResult<List<CategoryModel>>> getCategories(
      String restaurantId) async {
    try {
      final categories = await _dataSource.getCategories(restaurantId);
      return (data: categories, error: null);
    } on DioException catch (e) {
      return (data: null, error: _handleDioError(e));
    } catch (e) {
      return (data: null, error: 'Failed to load categories');
    }
  }

  @override
  Future<PublicMenuResult<List<MenuItemModel>>> getMenuItems(
      String restaurantId) async {
    try {
      final items = await _dataSource.getMenuItems(restaurantId);
      return (data: items, error: null);
    } on DioException catch (e) {
      return (data: null, error: _handleDioError(e));
    } catch (e) {
      return (data: null, error: 'Failed to load menu items');
    }
  }

  /// Handle Dio errors and return user-friendly messages
  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 404) {
          return 'Restaurant not found';
        } else if (statusCode == 401 || statusCode == 403) {
          return 'Access denied. This menu may not be publicly available.';
        } else if (statusCode != null && statusCode >= 500) {
          return 'Server error. Please try again later.';
        }
        return 'Failed to load menu. Please try again.';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';
      default:
        return 'Failed to load menu. Please try again.';
    }
  }
}
