import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teybatseller/core/network/user_api.dart';
import 'package:teybatseller/features/menu/application/menu_notifier.dart';
import 'package:teybatseller/features/orders/application/orders_notifier.dart';
import 'package:teybatseller/features/orders/data/models/order_model.dart';
import 'package:teybatseller/features/profile/application/user_profile_notifier.dart';
import 'package:teybatseller/features/restaurant/application/restaurant_state.dart';
import 'package:teybatseller/features/restaurant/data/models/restaurant_model.dart';
import 'package:teybatseller/features/tour/data/mock_data_generator.dart';

void _mockLog(String message) {
  if (kDebugMode) {
    debugPrint('🎯 [MockProvider] $message');
  }
}

/// Mock Orders Notifier for tour demonstration
/// Returns mock data and simulates state changes without API calls
class MockOrdersNotifier extends OrdersNotifier {
  @override
  OrdersState build() {
    _mockLog('MockOrdersNotifier.build() called');
    // Generate mock orders immediately
    final mockOrders = MockDataGenerator.generateMockOrders(12);
    _mockLog('MockOrdersNotifier.build() → generated ${mockOrders.length} mock orders');
    return OrdersState(
      orders: mockOrders,
      isLoading: false,
    );
  }

  /// Refresh orders - simulate loading
  @override
  Future<void> refreshOrders() async {
    _mockLog('MockOrdersNotifier.refreshOrders() called');
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 500));

    // Return same mock data
    final mockOrders = MockDataGenerator.generateMockOrders(12);
    state = state.copyWith(
      orders: mockOrders,
      isLoading: false,
    );
  }

  /// Silent refresh - used by polling
  @override
  Future<bool> silentRefresh() async {
    _mockLog('MockOrdersNotifier.silentRefresh() called');
    await Future.delayed(const Duration(milliseconds: 300));
    return false; // No changes in mock mode
  }

  /// Set search query
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Clear search
  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }

  /// Cancel order - simulate status update
  Future<bool> cancelOrder(String orderId, {String? reason}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = state.orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return false;

    final updatedOrders = List<OrderModel>.from(state.orders);
    updatedOrders[index] = updatedOrders[index].copyWith(
      status: OrderStatusEnum.cancelled,
    );

    state = state.copyWith(orders: updatedOrders);
    return true;
  }

  /// Move order to next status - simulate progression
  Future<bool> moveToNextStatus(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = state.orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return false;

    final order = state.orders[index];
    final nextStatus = order.status.nextStatus;

    if (nextStatus == null) return false;

    final updatedOrders = List<OrderModel>.from(state.orders);
    updatedOrders[index] = updatedOrders[index].copyWith(
      status: nextStatus,
    );

    state = state.copyWith(orders: updatedOrders);
    return true;
  }

  /// Update order status
  Future<bool> updateOrderStatus(String orderId, String status) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = state.orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return false;

    OrderStatusEnum? parsedStatus;
    switch (status.toUpperCase()) {
      case 'PENDING':
        parsedStatus = OrderStatusEnum.pending;
      case 'SEARCHING_FOR_DRIVER':
        parsedStatus = OrderStatusEnum.searchingForDriver;
      case 'ACCEPTED':
        parsedStatus = OrderStatusEnum.accepted;
      case 'ON_THE_WAY':
        parsedStatus = OrderStatusEnum.onTheWay;
      case 'DELIVERED':
        parsedStatus = OrderStatusEnum.delivered;
      case 'COMPLETED':
        parsedStatus = OrderStatusEnum.completed;
      case 'CANCELLED':
        parsedStatus = OrderStatusEnum.cancelled;
      default:
        return false;
    }

    final updatedOrders = List<OrderModel>.from(state.orders);
    updatedOrders[index] = updatedOrders[index].copyWith(
      status: parsedStatus,
    );

    state = state.copyWith(orders: updatedOrders);
    return true;
  }

  /// Mark order as on the way
  Future<bool> markOnTheWay(String orderId) async {
    return updateOrderStatus(orderId, 'ON_THE_WAY');
  }

  /// Mark order as delivered
  Future<bool> markDelivered(String orderId) async {
    return updateOrderStatus(orderId, 'DELIVERED');
  }

  /// Mark order as completed
  Future<bool> markCompleted(String orderId) async {
    return updateOrderStatus(orderId, 'COMPLETED');
  }

  /// Accept order (for tour demo)
  Future<bool> acceptOrder(String orderId) async {
    return updateOrderStatus(orderId, 'ACCEPTED');
  }
}

/// Mock Menu Notifier for tour demonstration
class MockMenuNotifier extends MenuNotifier {
  @override
  MenuState build() {
    _mockLog('MockMenuNotifier.build() called');
    final mockItems = MockDataGenerator.generateMockMenuItems(20);
    final mockCategories = MockDataGenerator.generateMockCategories();

    return MenuState(
      items: mockItems,
      categories: mockCategories,
      isLoading: false,
    );
  }

  /// Refresh menu items
  Future<void> refreshItems() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 500));

    final mockItems = MockDataGenerator.generateMockMenuItems(20);
    state = state.copyWith(
      items: mockItems,
      isLoading: false,
    );
  }

  /// Toggle item availability
  @override
  Future<void> toggleItemAvailability(String itemId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = state.items.indexWhere((i) => i.id == itemId);
    if (index == -1) return;

    final updatedItems = List.of(state.items);
    updatedItems[index] = updatedItems[index].copyWith(
      isAvailable: !updatedItems[index].isAvailable,
    );

    state = state.copyWith(items: updatedItems);
  }

  /// Set selected category
  void setSelectedCategory(String? categoryId) {
    state = state.copyWith(selectedCategoryId: categoryId);
  }

  /// Set search query
  @override
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Clear search
  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }
}

/// Mock Restaurant Notifier for tour demonstration
class MockRestaurantNotifier extends RestaurantNotifier {
  @override
  RestaurantState build() {
    _mockLog('MockRestaurantNotifier.build() called');
    final mockRestaurant = MockDataGenerator.generateMockRestaurant();
    return RestaurantLoaded(
      restaurants: [mockRestaurant],
      selectedRestaurant: mockRestaurant,
    );
  }

  /// Fetch restaurants - return mock data
  @override
  Future<void> fetchRestaurants() async {
    state = const RestaurantLoading();
    await Future.delayed(const Duration(milliseconds: 500));

    final mockRestaurant = MockDataGenerator.generateMockRestaurant();
    state = RestaurantLoaded(
      restaurants: [mockRestaurant],
      selectedRestaurant: mockRestaurant,
    );
  }

  /// Select restaurant
  @override
  Future<void> selectRestaurant(RestaurantModel restaurant) async {
    if (state is! RestaurantLoaded) return;

    final loaded = state as RestaurantLoaded;
    state = RestaurantLoaded(
      restaurants: loaded.restaurants,
      selectedRestaurant: restaurant,
    );
  }

  /// Clear selection
  @override
  Future<void> clearSelection() async {
    if (state is! RestaurantLoaded) return;

    final loaded = state as RestaurantLoaded;
    state = RestaurantLoaded(
      restaurants: loaded.restaurants,
      selectedRestaurant: null,
    );
  }

  /// Update restaurant
  @override
  Future<void> updateRestaurant(String id, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (state is! RestaurantLoaded) return;

    final loaded = state as RestaurantLoaded;
    // For mock, just update the selected restaurant with new data
    if (loaded.selectedRestaurant != null) {
      state = RestaurantLoaded(
        restaurants: loaded.restaurants,
        selectedRestaurant: loaded.selectedRestaurant,
      );
    }
  }
}

/// Mock User Profile Notifier for tour demonstration
/// Returns mock profile data without API calls
class MockUserProfileNotifier extends UserProfileNotifier {
  @override
  UserProfileState build() {
    _mockLog('MockUserProfileNotifier.build() called');
    return UserProfileState(
      profile: UserProfile(
        id: 'mock-user-1',
        name: 'Demo Restaurant Owner',
        email: 'demo@restaurant.com',
        phone: '+1234567890',
        roles: const ['seller'],
        createdAt: DateTime.now(),
      ),
      isLoading: false,
    );
  }

  @override
  Future<void> loadProfile() async {
    _mockLog('MockUserProfileNotifier.loadProfile() — no-op in tour');
  }

  @override
  Future<void> refresh() async {
    _mockLog('MockUserProfileNotifier.refresh() — no-op in tour');
  }
}

/// Provider for mock orders (used during tour)
final mockOrdersProvider = NotifierProvider<MockOrdersNotifier, OrdersState>(() {
  return MockOrdersNotifier();
});

/// Provider for mock menu (used during tour)
final mockMenuProvider = NotifierProvider<MockMenuNotifier, MenuState>(() {
  return MockMenuNotifier();
});

/// Provider for mock restaurant (used during tour)
final mockRestaurantProvider = NotifierProvider<MockRestaurantNotifier, RestaurantState>(() {
  return MockRestaurantNotifier();
});
