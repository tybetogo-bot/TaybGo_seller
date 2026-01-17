/// Menu remote data source
library;

import '../../../../core/network/menu_api.dart';
import '../models/menu_item_model.dart';

/// Abstract interface for menu data source
abstract class MenuDataSource {
  Future<List<CategoryModel>> getCategories(String restaurantId);
  Future<CategoryModel> getCategoryById(String id);
  Future<CategoryModel> createCategory({
    required String restaurantId,
    required Map<String, dynamic> data,
  });
  Future<CategoryModel> updateCategory(String id, Map<String, dynamic> data);
  Future<void> deleteCategory(String id);

  Future<List<MenuItemModel>> getMenuItems(String restaurantId);
  Future<MenuItemModel> getMenuItemById(String id);
  Future<MenuItemModel> createMenuItem({
    required String restaurantId,
    required Map<String, dynamic> data,
  });
  Future<MenuItemModel> updateMenuItem(String id, Map<String, dynamic> data);
  Future<void> deleteMenuItem(String id);
  Future<ItemStats> getItemStats(String id);
}

/// Remote data source implementation
class MenuRemoteDataSource implements MenuDataSource {
  MenuRemoteDataSource(this._api);

  final MenuApi _api;

  @override
  Future<List<CategoryModel>> getCategories(String restaurantId) async {
    final response = await _api.getCategories(restaurantId: restaurantId);
    return response.results;
  }

  @override
  Future<CategoryModel> getCategoryById(String id) async {
    return await _api.getCategoryById(id);
  }

  @override
  Future<CategoryModel> createCategory({
    required String restaurantId,
    required Map<String, dynamic> data,
  }) async {
    return await _api.createCategory(
      restaurantId: restaurantId,
      data: data,
    );
  }

  @override
  Future<CategoryModel> updateCategory(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await _api.updateCategory(id, data);
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _api.deleteCategory(id);
  }

  @override
  Future<List<MenuItemModel>> getMenuItems(String restaurantId) async {
    final response = await _api.getItems(restaurantId: restaurantId);
    return response.results;
  }

  @override
  Future<MenuItemModel> getMenuItemById(String id) async {
    return await _api.getItemById(id);
  }

  @override
  Future<MenuItemModel> createMenuItem({
    required String restaurantId,
    required Map<String, dynamic> data,
  }) async {
    return await _api.createItem(
      restaurantId: restaurantId,
      data: data,
    );
  }

  @override
  Future<MenuItemModel> updateMenuItem(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await _api.updateItem(id, data);
  }

  @override
  Future<void> deleteMenuItem(String id) async {
    await _api.deleteItem(id);
  }

  @override
  Future<ItemStats> getItemStats(String id) async {
    return await _api.getItemStats(id);
  }
}
