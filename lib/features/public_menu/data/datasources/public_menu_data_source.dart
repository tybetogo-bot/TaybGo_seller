import '../../../../core/network/menu_api.dart';
import '../../../../core/network/restaurant_api.dart';
import '../../../menu/data/models/menu_item_model.dart';
import '../../../restaurant/data/models/restaurant_model.dart';

/// Abstract data source for public menu
abstract class PublicMenuDataSource {
  Future<RestaurantModel> getRestaurant(String restaurantId);
  Future<List<CategoryModel>> getCategories(String restaurantId);
  Future<List<MenuItemModel>> getMenuItems(String restaurantId);
}

/// Implementation of public menu data source
/// Reuses existing MenuApi and RestaurantApi
class PublicMenuDataSourceImpl implements PublicMenuDataSource {
  final MenuApi _menuApi;
  final RestaurantApi _restaurantApi;

  PublicMenuDataSourceImpl({
    required MenuApi menuApi,
    required RestaurantApi restaurantApi,
  })  : _menuApi = menuApi,
        _restaurantApi = restaurantApi;

  @override
  Future<RestaurantModel> getRestaurant(String restaurantId) async {
    return await _restaurantApi.getRestaurantById(restaurantId);
  }

  @override
  Future<List<CategoryModel>> getCategories(String restaurantId) async {
    final response = await _menuApi.getCategories(
      restaurantId: restaurantId,
      page: 1,
    );

    // Fetch all pages if paginated
    final allCategories = <CategoryModel>[...response.results];
    if (response.count > response.results.length) {
      // For simplicity, fetch up to 100 categories (assuming 10-20 per page)
      for (int page = 2; page <= 10; page++) {
        try {
          final nextResponse = await _menuApi.getCategories(
            restaurantId: restaurantId,
            page: page,
          );
          allCategories.addAll(nextResponse.results);
          if (nextResponse.next == null) break;
        } catch (_) {
          break; // Stop if we hit an error
        }
      }
    }

    return allCategories;
  }

  @override
  Future<List<MenuItemModel>> getMenuItems(String restaurantId) async {
    final response = await _menuApi.getItems(
      restaurantId: restaurantId,
      page: 1,
    );

    // Fetch all pages if paginated
    final allItems = <MenuItemModel>[...response.results];
    if (response.count > response.results.length) {
      // Fetch up to 100 pages (assuming reasonable menu sizes)
      for (int page = 2; page <= 100; page++) {
        try {
          final nextResponse = await _menuApi.getItems(
            restaurantId: restaurantId,
            page: page,
          );
          allItems.addAll(nextResponse.results);
          if (nextResponse.next == null) break;
        } catch (_) {
          break; // Stop if we hit an error
        }
      }
    }

    return allItems;
  }
}
