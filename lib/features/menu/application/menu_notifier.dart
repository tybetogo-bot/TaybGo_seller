import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../../restaurant/application/restaurant_state.dart';
import '../data/models/menu_item_model.dart';
import '../data/datasources/menu_remote_data_source.dart';
import '../data/repositories/menu_repository.dart';

/// Menu state containing items, categories, and filters with cached filtering
class MenuState {
  MenuState({
    this.items = const [],
    this.categories = const [],
    this.selectedCategoryId,
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
    this.showOnlyAvailable = false,
  }) {
    // Pre-compute filtered items once during construction
    _computeFilteredItems();
  }

  final List<MenuItemModel> items;
  final List<CategoryModel> categories;
  final String? selectedCategoryId;
  final String searchQuery;
  final bool isLoading;
  final String? error;
  final bool showOnlyAvailable;

  // Cached filtered items
  late final List<MenuItemModel> _filteredItems;

  void _computeFilteredItems() {
    final query = searchQuery.toLowerCase();
    final hasSearch = searchQuery.isNotEmpty;
    final hasCategoryFilter = selectedCategoryId != null;

    final result = <MenuItemModel>[];
    for (final item in items) {
      // Filter by category
      if (hasCategoryFilter && item.categoryId != selectedCategoryId) continue;
      // Filter by availability
      if (showOnlyAvailable && !item.isAvailable) continue;
      // Filter by search query
      if (hasSearch && !_matchesSearch(item, query)) continue;
      result.add(item);
    }
    _filteredItems = result;
  }

  bool _matchesSearch(MenuItemModel item, String query) {
    if (item.name.toLowerCase().contains(query)) return true;
    if (item.description?.toLowerCase().contains(query) ?? false) return true;
    if (item.ingredients.any((i) => i.toLowerCase().contains(query)))
      return true;
    return false;
  }

  MenuState copyWith({
    List<MenuItemModel>? items,
    List<CategoryModel>? categories,
    String? selectedCategoryId,
    bool clearSelectedCategory = false,
    String? searchQuery,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool? showOnlyAvailable,
  }) {
    return MenuState(
      items: items ?? this.items,
      categories: categories ?? this.categories,
      selectedCategoryId: clearSelectedCategory
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      showOnlyAvailable: showOnlyAvailable ?? this.showOnlyAvailable,
    );
  }

  /// Cached getter - no computation on access
  List<MenuItemModel> get filteredItems => _filteredItems;

  /// Get item count for a category (still computed but only called occasionally)
  int getItemCountForCategory(String categoryId) {
    return items.where((item) => item.categoryId == categoryId).length;
  }
}

/// Menu state notifier for managing menu items and categories (Riverpod 3.x)
class MenuNotifier extends Notifier<MenuState> {
  late final MenuRepository _repository;

  @override
  MenuState build() {
    _repository = ref.watch(menuRepositoryProvider);

    // Watch for restaurant state changes (loading -> loaded)
    ref.listen(restaurantProvider, (previous, next) {
      if (next is RestaurantLoaded && previous is! RestaurantLoaded) {
        Future.microtask(() => _loadInitialData());
      }
    });

    // Watch for restaurant selection changes
    ref.listen(selectedRestaurantIdProvider, (previous, next) {
      if (next != null && previous != next) {
        Future.microtask(() => _loadInitialData());
      }
    });

    // Load initial data
    Future.microtask(() => _loadInitialData());
    return MenuState();
  }

  /// Load initial data from API
  Future<void> _loadInitialData() async {
    final restaurantState = ref.read(restaurantProvider);

    // If restaurant state is still loading, keep menu in loading state
    if (restaurantState is RestaurantInitial ||
        restaurantState is RestaurantLoading) {
      state = state.copyWith(isLoading: true, clearError: true);
      return;
    }

    final restaurantId = ref.read(selectedRestaurantIdProvider);
    if (restaurantId == null) {
      state = state.copyWith(isLoading: false, error: 'No restaurant selected');
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Load categories and items in parallel
      final categoriesResult = await _repository.getCategories(restaurantId);
      final itemsResult = await _repository.getMenuItems(restaurantId);

      if (categoriesResult.failure != null) {
        state = state.copyWith(
          isLoading: false,
          error: categoriesResult.failure!.message,
        );
        return;
      }

      if (itemsResult.failure != null) {
        state = state.copyWith(
          isLoading: false,
          error: itemsResult.failure!.message,
        );
        return;
      }

      state = state.copyWith(
        items: itemsResult.data ?? [],
        categories: categoriesResult.data ?? [],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load menu: $e',
      );
    }
  }

  /// Refresh menu data
  Future<void> refresh() async {
    await _loadInitialData();
  }

  /// Select a category
  void selectCategory(String? categoryId) {
    if (categoryId == null) {
      state = state.copyWith(clearSelectedCategory: true);
    } else {
      state = state.copyWith(selectedCategoryId: categoryId);
    }
  }

  /// Set search query
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Toggle availability filter
  void toggleAvailabilityFilter() {
    state = state.copyWith(showOnlyAvailable: !state.showOnlyAvailable);
  }

  /// Add a new menu item
  Future<void> addItem(MenuItemModel item) async {
    final restaurantId = ref.read(selectedRestaurantIdProvider);
    if (restaurantId == null) {
      state = state.copyWith(error: 'No restaurant selected');
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Prepare data for API
      // Note: API expects 'ingredients' as comma-separated string, not array
      final data = {
        'name': item.name,
        'price': item.price,
        'category': item.categoryId,
        if (item.description != null) 'description': item.description,
        if (item.imageUrl != null) 'image': item.imageUrl,
        'ingredients': item.ingredients.join(', '),
        'is_available': item.isAvailable,
        'preparation_time': item.preparationTime,
        if (item.customizations.isNotEmpty)
          'customizations': item.customizations
              .map(
                (c) => {
                  'name': c.name,
                  'type': c.type == CustomizationType.addition
                      ? 'addition'
                      : 'removal',
                  'price_modifier': c.priceModifier,
                  'is_available': c.isAvailable,
                },
              )
              .toList(),
      };

      final result = await _repository.createMenuItem(
        restaurantId: restaurantId,
        data: data,
      );

      if (result.failure != null) {
        state = state.copyWith(
          isLoading: false,
          error: result.failure!.message,
        );
        return;
      }

      state = state.copyWith(
        items: [...state.items, result.data!],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to add item: $e');
    }
  }

  /// Update an existing menu item
  Future<void> updateItem(MenuItemModel item) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Prepare data for API
      // Note: API expects 'ingredients' as comma-separated string, not array
      final data = {
        'name': item.name,
        'price': item.price,
        'category': item.categoryId,
        if (item.description != null) 'description': item.description,
        if (item.imageUrl != null) 'image': item.imageUrl,
        'ingredients': item.ingredients.join(', '),
        'is_available': item.isAvailable,
        'preparation_time': item.preparationTime,
        if (item.customizations.isNotEmpty)
          'customizations': item.customizations
              .map(
                (c) => {
                  'id': c.id,
                  'name': c.name,
                  'type': c.type == CustomizationType.addition
                      ? 'addition'
                      : 'removal',
                  'price_modifier': c.priceModifier,
                  'is_available': c.isAvailable,
                },
              )
              .toList(),
      };

      final result = await _repository.updateMenuItem(item.id, data);

      if (result.failure != null) {
        state = state.copyWith(
          isLoading: false,
          error: result.failure!.message,
        );
        return;
      }

      final updatedItems = state.items
          .map((i) => i.id == item.id ? result.data! : i)
          .toList();

      state = state.copyWith(items: updatedItems, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update item: $e',
      );
    }
  }

  /// Delete a menu item
  Future<void> deleteItem(String itemId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _repository.deleteMenuItem(itemId);

      if (result.failure != null) {
        state = state.copyWith(
          isLoading: false,
          error: result.failure!.message,
        );
        return;
      }

      final updatedItems = state.items.where((i) => i.id != itemId).toList();

      state = state.copyWith(items: updatedItems, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete item: $e',
      );
    }
  }

  /// Toggle item availability
  Future<void> toggleItemAvailability(String itemId) async {
    final item = state.items.firstWhere((i) => i.id == itemId);
    final updatedItem = item.copyWith(isAvailable: !item.isAvailable);
    await updateItem(updatedItem);
  }

  /// Get item by ID
  MenuItemModel? getItemById(String id) {
    try {
      return state.items.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get category by ID
  CategoryModel? getCategoryById(String id) {
    try {
      return state.categories.firstWhere((cat) => cat.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  // ========== CATEGORY MANAGEMENT ==========

  /// Add a new category
  Future<bool> addCategory(String name) async {
    final restaurantId = ref.read(selectedRestaurantIdProvider);
    if (restaurantId == null) {
      state = state.copyWith(error: 'No restaurant selected');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final data = {'name': name, 'view_order': state.categories.length + 1};

      final result = await _repository.createCategory(
        restaurantId: restaurantId,
        data: data,
      );

      if (result.failure != null) {
        state = state.copyWith(
          isLoading: false,
          error: result.failure!.message,
        );
        return false;
      }

      state = state.copyWith(
        categories: [...state.categories, result.data!],
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to add category: $e',
      );
      return false;
    }
  }

  /// Update an existing category
  Future<bool> updateCategory(String categoryId, String name) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final data = {'name': name};

      final result = await _repository.updateCategory(categoryId, data);

      if (result.failure != null) {
        state = state.copyWith(
          isLoading: false,
          error: result.failure!.message,
        );
        return false;
      }

      final updatedCategories = state.categories
          .map((c) => c.id == categoryId ? result.data! : c)
          .toList();

      state = state.copyWith(categories: updatedCategories, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update category: $e',
      );
      return false;
    }
  }

  /// Delete a category
  Future<bool> deleteCategory(String categoryId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _repository.deleteCategory(categoryId);

      if (result.failure != null) {
        state = state.copyWith(
          isLoading: false,
          error: result.failure!.message,
        );
        return false;
      }

      final updatedCategories = state.categories
          .where((c) => c.id != categoryId)
          .toList();

      // Also remove items from the deleted category from local state
      final updatedItems = state.items
          .where((i) => i.categoryId != categoryId)
          .toList();

      state = state.copyWith(
        categories: updatedCategories,
        items: updatedItems,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete category: $e',
      );
      return false;
    }
  }

  /// Reorder categories
  Future<void> reorderCategories(int oldIndex, int newIndex) async {
    // Update local state immediately for smooth UX
    final categories = List<CategoryModel>.from(state.categories);
    if (newIndex > oldIndex) newIndex--;
    final item = categories.removeAt(oldIndex);
    categories.insert(newIndex, item);
    state = state.copyWith(categories: categories);

    // TODO: Optionally sync order to backend if API supports it
  }
}

/// Provider for menu data source
final menuDataSourceProvider = Provider<MenuDataSource>((ref) {
  final api = ref.watch(menuApiProvider);
  return MenuRemoteDataSource(api);
});

/// Provider for menu repository
final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  final dataSource = ref.watch(menuDataSourceProvider);
  return MenuRepositoryImpl(remoteDataSource: dataSource);
});

/// Provider for menu state (Riverpod 3.x)
final menuProvider = NotifierProvider<MenuNotifier, MenuState>(
  MenuNotifier.new,
);

/// Provider for filtered menu items
final filteredMenuItemsProvider = Provider<List<MenuItemModel>>((ref) {
  final menuState = ref.watch(menuProvider);
  return menuState.filteredItems;
});

/// Provider for menu categories
final menuCategoriesProvider = Provider<List<CategoryModel>>((ref) {
  final menuState = ref.watch(menuProvider);
  return menuState.categories;
});

/// Provider for a single menu item by ID
final menuItemProvider = Provider.family<MenuItemModel?, String>((ref, id) {
  final menuState = ref.watch(menuProvider);
  try {
    return menuState.items.firstWhere((item) => item.id == id);
  } catch (_) {
    return null;
  }
});
