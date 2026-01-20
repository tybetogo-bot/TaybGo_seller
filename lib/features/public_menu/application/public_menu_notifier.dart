import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../../menu/data/models/menu_item_model.dart';
import '../../restaurant/data/models/restaurant_model.dart';
import '../data/datasources/public_menu_data_source.dart';
import '../data/repositories/public_menu_repository.dart';
import 'public_menu_state.dart';

/// Provider for public menu data source
final publicMenuDataSourceProvider = Provider<PublicMenuDataSource>((ref) {
  // Use public API providers (no authentication required)
  final menuApi = ref.watch(publicMenuApiProvider);
  final restaurantApi = ref.watch(publicRestaurantApiProvider);
  return PublicMenuDataSourceImpl(
    menuApi: menuApi,
    restaurantApi: restaurantApi,
  );
});

/// Provider for public menu repository
final publicMenuRepositoryProvider = Provider<PublicMenuRepository>((ref) {
  final dataSource = ref.watch(publicMenuDataSourceProvider);
  return PublicMenuRepositoryImpl(dataSource);
});

/// Provider for public menu state using FutureProvider
final publicMenuProvider =
    FutureProvider.family<PublicMenuState, String>((ref, restaurantId) async {
  final repository = ref.watch(publicMenuRepositoryProvider);

  try {
    // Fetch all data in parallel
    final results = await Future.wait([
      repository.getRestaurant(restaurantId),
      repository.getCategories(restaurantId),
      repository.getMenuItems(restaurantId),
    ]);

    final restaurantResult = results[0];
    final categoriesResult = results[1];
    final itemsResult = results[2];

    // Check for errors
    if (restaurantResult.error != null) {
      return PublicMenuError(restaurantResult.error!);
    }
    if (categoriesResult.error != null) {
      return PublicMenuError(categoriesResult.error!);
    }
    if (itemsResult.error != null) {
      return PublicMenuError(itemsResult.error!);
    }

    // Extract data with proper type casting
    final restaurant = restaurantResult.data as RestaurantModel;
    final categories = categoriesResult.data as List<CategoryModel>;
    final items = itemsResult.data as List<MenuItemModel>;

    // Group items by category
    final itemsByCategory = _groupItemsByCategory(items, categories);

    return PublicMenuLoaded(
      restaurant: restaurant,
      categories: categories,
      items: items,
      itemsByCategory: itemsByCategory,
    );
  } catch (e) {
    return PublicMenuError('An unexpected error occurred: $e');
  }
});

/// Group menu items by category (only available items)
Map<String, List<MenuItemModel>> _groupItemsByCategory(
  List<MenuItemModel> items,
  List<CategoryModel> categories,
) {
  final Map<String, List<MenuItemModel>> grouped = {};

  // Initialize with empty lists for all categories
  for (final category in categories) {
    grouped[category.id] = [];
  }

  // Group items - only include available items
  for (final item in items) {
    if (item.isAvailable && grouped.containsKey(item.categoryId)) {
      grouped[item.categoryId]!.add(item);
    }
  }

  return grouped;
}
