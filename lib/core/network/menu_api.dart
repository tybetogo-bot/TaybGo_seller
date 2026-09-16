/// Menu API service for items and categories
library;

import 'package:dio/dio.dart';

import '../../features/menu/data/models/menu_item_model.dart';
import 'restaurant_api.dart';

/// Menu API service for seller menu management
class MenuApi {
  final Dio _dio;

  MenuApi(this._dio);

  // ========== CATEGORIES ==========

  /// List categories for a restaurant
  /// GET /api/seller/categories/?restaurant_id=<id>
  Future<PaginatedResponse<CategoryModel>> getCategories({
    required String restaurantId,
    int page = 1,
  }) async {
    final response = await _dio.get(
      '/api/seller/categories/',
      queryParameters: {
        'restaurant_id': restaurantId,
        'page': page,
      },
    );
    print('🟢 [MenuApi] Categories API response: ${response.data}');
    return PaginatedResponse.fromJson(
      response.data as Map<String, dynamic>,
      CategoryModel.fromJson,
    );
  }

  /// Get category details
  /// GET /api/seller/categories/{id}/
  Future<CategoryModel> getCategoryById(String id) async {
    final response = await _dio.get('/api/seller/categories/$id/');
    return CategoryModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Create category
  /// POST /api/seller/categories/?restaurant_id=<id>
  Future<CategoryModel> createCategory({
    required String restaurantId,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dio.post(
      '/api/seller/categories/',
      queryParameters: {'restaurant_id': restaurantId},
      data: data,
    );
    return CategoryModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Update category (full update)
  /// PUT /api/seller/categories/{id}/
  Future<CategoryModel> updateCategory(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.put(
      '/api/seller/categories/$id/',
      data: data,
    );
    return CategoryModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Partial update category
  /// PATCH /api/seller/categories/{id}/
  Future<CategoryModel> patchCategory(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.patch(
      '/api/seller/categories/$id/',
      data: data,
    );
    return CategoryModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Delete category
  /// DELETE /api/seller/categories/{id}/
  Future<void> deleteCategory(String id) async {
    await _dio.delete('/api/seller/categories/$id/');
  }

  // ========== ITEMS ==========

  /// List menu items for a restaurant
  /// GET /api/seller/items/?restaurant_id=<id>
  Future<PaginatedResponse<MenuItemModel>> getItems({
    required String restaurantId,
    int page = 1,
  }) async {
    final response = await _dio.get(
      '/api/seller/items/',
      queryParameters: {
        'restaurant_id': restaurantId,
        'page': page,
        // The order editor needs the complete catalog so an existing order
        // item can still be resolved when it is no longer available.
        'page_size': 200,
      },
    );
    return PaginatedResponse.fromJson(
      response.data as Map<String, dynamic>,
      MenuItemModel.fromJson,
    );
  }

  /// Get menu item details
  /// GET /api/seller/items/{id}/
  Future<MenuItemModel> getItemById(String id) async {
    final response = await _dio.get('/api/seller/items/$id/');
    return MenuItemModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Get item sales statistics
  /// GET /api/seller/items/{id}/stats/
  Future<ItemStats> getItemStats(String id) async {
    final response = await _dio.get('/api/seller/items/$id/stats/');
    return ItemStats.fromJson(response.data as Map<String, dynamic>);
  }

  /// Create menu item
  /// POST /api/seller/items/?restaurant_id=<id>
  Future<MenuItemModel> createItem({
    required String restaurantId,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dio.post(
      '/api/seller/items/',
      queryParameters: {'restaurant_id': restaurantId},
      data: data,
    );
    return MenuItemModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Update menu item (full update)
  /// PUT /api/seller/items/{id}/
  Future<MenuItemModel> updateItem(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.put(
      '/api/seller/items/$id/',
      data: data,
    );
    return MenuItemModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Partial update menu item
  /// PATCH /api/seller/items/{id}/
  Future<MenuItemModel> patchItem(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.patch(
      '/api/seller/items/$id/',
      data: data,
    );
    return MenuItemModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Delete menu item
  /// DELETE /api/seller/items/{id}/
  Future<void> deleteItem(String id) async {
    await _dio.delete('/api/seller/items/$id/');
  }
}

/// Item statistics model
class ItemStats {
  final String itemId;
  final int totalQuantity;
  final int totalOrders;
  final double totalRevenue;

  ItemStats({
    required this.itemId,
    required this.totalQuantity,
    required this.totalOrders,
    required this.totalRevenue,
  });

  factory ItemStats.fromJson(Map<String, dynamic> json) {
    return ItemStats(
      // item_id can be returned as int or string from API
      itemId: json['item_id']?.toString() ?? '',
      totalQuantity: (json['total_quantity'] as num?)?.toInt() ?? 0,
      totalOrders: (json['total_orders'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'total_quantity': totalQuantity,
      'total_orders': totalOrders,
      'total_revenue': totalRevenue,
    };
  }
}
