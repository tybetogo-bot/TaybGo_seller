/// Menu repository interface and implementation
library;

import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/menu_api.dart';
import '../datasources/menu_remote_data_source.dart';
import '../models/menu_item_model.dart';

/// Result type for repository methods
typedef MenuResult<T> = ({Failure? failure, T? data});

/// Menu repository interface
abstract class MenuRepository {
  Future<MenuResult<List<CategoryModel>>> getCategories(String restaurantId);
  Future<MenuResult<CategoryModel>> createCategory({
    required String restaurantId,
    required Map<String, dynamic> data,
  });
  Future<MenuResult<CategoryModel>> updateCategory(
    String id,
    Map<String, dynamic> data,
  );
  Future<MenuResult<void>> deleteCategory(String id);

  Future<MenuResult<List<MenuItemModel>>> getMenuItems(String restaurantId);
  Future<MenuResult<MenuItemModel>> getMenuItemById(String id);
  Future<MenuResult<MenuItemModel>> createMenuItem({
    required String restaurantId,
    required Map<String, dynamic> data,
  });
  Future<MenuResult<MenuItemModel>> updateMenuItem(
    String id,
    Map<String, dynamic> data,
  );
  Future<MenuResult<void>> deleteMenuItem(String id);
  Future<MenuResult<ItemStats>> getItemStats(String id);
}

/// Implementation of menu repository
class MenuRepositoryImpl implements MenuRepository {
  MenuRepositoryImpl({required MenuDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final MenuDataSource _remoteDataSource;

  @override
  Future<MenuResult<List<CategoryModel>>> getCategories(
    String restaurantId,
  ) async {
    try {
      final categories = await _remoteDataSource.getCategories(restaurantId);
      return (failure: null, data: categories);
    } on DioException catch (e) {
      final apiError = e.error;
      if (apiError is ApiException) {
        return (
          failure: ServerFailure(
            message: apiError.message,
            statusCode: apiError.statusCode,
            code: apiError.code,
          ),
          data: null,
        );
      }
      return (
        failure: NetworkFailure(message: 'Network error: ${e.message}'),
        data: null,
      );
    } on NetworkException catch (e) {
      return (failure: NetworkFailure(message: e.message), data: null);
    } catch (e, stackTrace) {
      // Log the full error for debugging
      print('Error loading categories: $e');
      print('Stack trace: $stackTrace');
      return (
        failure: ServerFailure(message: 'Error loading categories: $e'),
        data: null,
      );
    }
  }

  @override
  Future<MenuResult<CategoryModel>> createCategory({
    required String restaurantId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final category = await _remoteDataSource.createCategory(
        restaurantId: restaurantId,
        data: data,
      );
      return (failure: null, data: category);
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
  Future<MenuResult<CategoryModel>> updateCategory(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final category = await _remoteDataSource.updateCategory(id, data);
      return (failure: null, data: category);
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
  Future<MenuResult<void>> deleteCategory(String id) async {
    try {
      await _remoteDataSource.deleteCategory(id);
      return (failure: null, data: null);
    } on DioException catch (e) {
      final apiError = e.error;
      if (apiError is ApiException) {
        return (failure: ServerFailure(message: apiError.message), data: null);
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
  Future<MenuResult<List<MenuItemModel>>> getMenuItems(
    String restaurantId,
  ) async {
    try {
      final items = await _remoteDataSource.getMenuItems(restaurantId);
      return (failure: null, data: items);
    } on DioException catch (e) {
      final apiError = e.error;
      if (apiError is ApiException) {
        return (failure: ServerFailure(message: apiError.message), data: null);
      }
      return (
        failure: NetworkFailure(message: 'Network error: ${e.message}'),
        data: null,
      );
    } on NetworkException catch (e) {
      return (failure: NetworkFailure(message: e.message), data: null);
    } catch (e, stackTrace) {
      // Log the full error for debugging
      print('Error loading menu items: $e');
      print('Stack trace: $stackTrace');
      return (
        failure: ServerFailure(message: 'Error loading items: $e'),
        data: null,
      );
    }
  }

  @override
  Future<MenuResult<MenuItemModel>> getMenuItemById(String id) async {
    try {
      final item = await _remoteDataSource.getMenuItemById(id);
      return (failure: null, data: item);
    } on DioException catch (e) {
      final apiError = e.error;
      if (apiError is ApiException) {
        return (failure: ServerFailure(message: apiError.message), data: null);
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
  Future<MenuResult<MenuItemModel>> createMenuItem({
    required String restaurantId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final item = await _remoteDataSource.createMenuItem(
        restaurantId: restaurantId,
        data: data,
      );
      return (failure: null, data: item);
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
  Future<MenuResult<MenuItemModel>> updateMenuItem(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final item = await _remoteDataSource.updateMenuItem(id, data);
      return (failure: null, data: item);
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
  Future<MenuResult<void>> deleteMenuItem(String id) async {
    try {
      await _remoteDataSource.deleteMenuItem(id);
      return (failure: null, data: null);
    } on DioException catch (e) {
      final apiError = e.error;
      if (apiError is ApiException) {
        return (
          failure: ServerFailure(
            message: apiError.message,
            statusCode: apiError.statusCode,
            code: apiError.code,
          ),
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
  Future<MenuResult<ItemStats>> getItemStats(String id) async {
    try {
      final stats = await _remoteDataSource.getItemStats(id);
      return (failure: null, data: stats);
    } on DioException catch (e) {
      final apiError = e.error;
      if (apiError is ApiException) {
        return (failure: ServerFailure(message: apiError.message), data: null);
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
}
