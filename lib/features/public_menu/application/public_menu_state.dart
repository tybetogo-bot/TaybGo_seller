import '../../../features/menu/data/models/menu_item_model.dart';
import '../../../features/restaurant/data/models/restaurant_model.dart';

/// Public menu state - sealed class for all possible states
sealed class PublicMenuState {
  const PublicMenuState();
}

/// Initial state - before loading
final class PublicMenuInitial extends PublicMenuState {
  const PublicMenuInitial();
}

/// Loading state - fetching data
final class PublicMenuLoading extends PublicMenuState {
  const PublicMenuLoading();
}

/// Loaded state - data successfully fetched
final class PublicMenuLoaded extends PublicMenuState {
  final RestaurantModel restaurant;
  final List<CategoryModel> categories;
  final List<MenuItemModel> items;
  final Map<String, List<MenuItemModel>> itemsByCategory;

  const PublicMenuLoaded({
    required this.restaurant,
    required this.categories,
    required this.items,
    required this.itemsByCategory,
  });

  PublicMenuLoaded copyWith({
    RestaurantModel? restaurant,
    List<CategoryModel>? categories,
    List<MenuItemModel>? items,
    Map<String, List<MenuItemModel>>? itemsByCategory,
  }) {
    return PublicMenuLoaded(
      restaurant: restaurant ?? this.restaurant,
      categories: categories ?? this.categories,
      items: items ?? this.items,
      itemsByCategory: itemsByCategory ?? this.itemsByCategory,
    );
  }
}

/// Error state - something went wrong
final class PublicMenuError extends PublicMenuState {
  final String message;

  const PublicMenuError(this.message);
}
