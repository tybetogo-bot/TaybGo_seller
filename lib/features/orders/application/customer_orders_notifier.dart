import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/customer_orders_api.dart';
import '../../../core/providers/providers.dart';
import '../data/datasources/customer_orders_remote_data_source.dart';
import '../data/models/food_checkout_model.dart';
import '../data/models/order_model.dart';
import '../data/repositories/customer_orders_repository.dart';

/// Customer orders state
class CustomerOrdersState {
  const CustomerOrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.error,
    this.currentPage = 1,
    this.hasMorePages = true,
  });

  final List<OrderModel> orders;
  final bool isLoading;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final String? error;
  final int currentPage;
  final bool hasMorePages;

  CustomerOrdersState copyWith({
    List<OrderModel>? orders,
    bool? isLoading,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    String? error,
    bool clearError = false,
    int? currentPage,
    bool? hasMorePages,
  }) {
    return CustomerOrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      error: clearError ? null : (error ?? this.error),
      currentPage: currentPage ?? this.currentPage,
      hasMorePages: hasMorePages ?? this.hasMorePages,
    );
  }

  /// Get orders by status
  List<OrderModel> get pendingOrders =>
      orders.where((o) =>
          o.status == OrderStatusEnum.pending ||
          o.status == OrderStatusEnum.searchingForDriver
      ).toList();

  List<OrderModel> get activeOrders => orders
      .where((o) =>
          o.status == OrderStatusEnum.accepted ||
          o.status == OrderStatusEnum.driverNotificationSent ||
          o.status == OrderStatusEnum.onTheWay)
      .toList();

  List<OrderModel> get completedOrders => orders
      .where((o) =>
          o.status == OrderStatusEnum.delivered ||
          o.status == OrderStatusEnum.completed ||
          o.status == OrderStatusEnum.rejected ||
          o.status == OrderStatusEnum.cancelled)
      .toList();
}

/// Customer orders notifier for managing order state (Riverpod 3.x)
class CustomerOrdersNotifier extends Notifier<CustomerOrdersState> {
  late final CustomerOrdersRepository _repository;

  @override
  CustomerOrdersState build() {
    _repository = ref.watch(customerOrdersRepositoryProvider);

    // Load initial orders
    Future.microtask(() => _loadOrders());
    return const CustomerOrdersState(isLoading: true);
  }

  /// Load orders from API
  Future<void> _loadOrders({int page = 1}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _repository.getCustomerOrders(page: page);

      if (result.failure != null) {
        state = state.copyWith(
          isLoading: false,
          error: result.failure!.message,
        );
        return;
      }

      state = state.copyWith(
        orders: result.data ?? [],
        isLoading: false,
        currentPage: page,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load orders: $e',
      );
    }
  }

  /// Refresh orders
  Future<void> refreshOrders() async {
    await _loadOrders(page: 1);
  }

  /// Create a new food order
  Future<OrderModel?> createFoodOrder(FoodCheckoutRequest request) async {
    state = state.copyWith(isCreating: true, clearError: true);

    try {
      final result = await _repository.createFoodOrder(request);

      if (result.failure != null) {
        state = state.copyWith(
          isCreating: false,
          error: result.failure!.message,
        );
        return null;
      }

      // Add to local state at the beginning
      final updatedOrders = [result.data!, ...state.orders];
      state = state.copyWith(
        orders: updatedOrders,
        isCreating: false,
      );

      return result.data;
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        error: 'Failed to create order: $e',
      );
      return null;
    }
  }

  /// Update an existing order
  Future<OrderModel?> updateOrder(String id, OrderUpdateRequest request) async {
    state = state.copyWith(isUpdating: true, clearError: true);

    try {
      final result = await _repository.updateOrder(id, request);

      if (result.failure != null) {
        state = state.copyWith(
          isUpdating: false,
          error: result.failure!.message,
        );
        return null;
      }

      // Update local state
      final index = state.orders.indexWhere((o) => o.id == id);
      if (index != -1) {
        final updatedOrders = List<OrderModel>.from(state.orders);
        updatedOrders[index] = result.data!;
        state = state.copyWith(
          orders: updatedOrders,
          isUpdating: false,
        );
      } else {
        state = state.copyWith(isUpdating: false);
      }

      return result.data;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Failed to update order: $e',
      );
      return null;
    }
  }

  /// Partial update an order
  Future<OrderModel?> patchOrder(String id, Map<String, dynamic> data) async {
    state = state.copyWith(isUpdating: true, clearError: true);

    try {
      final result = await _repository.patchOrder(id, data);

      if (result.failure != null) {
        state = state.copyWith(
          isUpdating: false,
          error: result.failure!.message,
        );
        return null;
      }

      // Update local state
      final index = state.orders.indexWhere((o) => o.id == id);
      if (index != -1) {
        final updatedOrders = List<OrderModel>.from(state.orders);
        updatedOrders[index] = result.data!;
        state = state.copyWith(
          orders: updatedOrders,
          isUpdating: false,
        );
      } else {
        state = state.copyWith(isUpdating: false);
      }

      return result.data;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Failed to update order: $e',
      );
      return null;
    }
  }

  /// Delete an order
  Future<bool> deleteOrder(String id) async {
    state = state.copyWith(isDeleting: true, clearError: true);

    try {
      final result = await _repository.deleteOrder(id);

      if (result.failure != null) {
        state = state.copyWith(
          isDeleting: false,
          error: result.failure!.message,
        );
        return false;
      }

      // Remove from local state
      final updatedOrders = state.orders.where((o) => o.id != id).toList();
      state = state.copyWith(
        orders: updatedOrders,
        isDeleting: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isDeleting: false,
        error: 'Failed to delete order: $e',
      );
      return false;
    }
  }

  /// Get order by ID from local state
  OrderModel? getOrder(String id) {
    try {
      return state.orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Fetch order by ID from API
  Future<OrderModel?> fetchOrderById(String id) async {
    state = state.copyWith(clearError: true);

    try {
      final result = await _repository.getOrderById(id);

      if (result.failure != null) {
        state = state.copyWith(error: result.failure!.message);
        return null;
      }

      // Update local state if order exists in list
      final index = state.orders.indexWhere((o) => o.id == id);
      if (index != -1) {
        final updatedOrders = List<OrderModel>.from(state.orders);
        updatedOrders[index] = result.data!;
        state = state.copyWith(orders: updatedOrders);
      }

      return result.data;
    } catch (e) {
      state = state.copyWith(error: 'Failed to fetch order: $e');
      return null;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Provider for customer orders API
final customerOrdersApiProvider = Provider<CustomerOrdersApi>((ref) {
  final dio = ref.watch(dioProvider);
  return CustomerOrdersApi(dio);
});

/// Provider for customer orders data source
final customerOrdersDataSourceProvider = Provider<CustomerOrdersDataSource>((ref) {
  final api = ref.watch(customerOrdersApiProvider);
  return CustomerOrdersRemoteDataSource(api);
});

/// Provider for customer orders repository
final customerOrdersRepositoryProvider = Provider<CustomerOrdersRepository>((ref) {
  final dataSource = ref.watch(customerOrdersDataSourceProvider);
  return CustomerOrdersRepositoryImpl(remoteDataSource: dataSource);
});

/// Provider for customer orders state (Riverpod 3.x)
final customerOrdersProvider = NotifierProvider<CustomerOrdersNotifier, CustomerOrdersState>(
  CustomerOrdersNotifier.new,
);

/// Provider for a specific customer order by ID
final customerOrderByIdProvider = Provider.family<OrderModel?, String>((ref, id) {
  final ordersState = ref.watch(customerOrdersProvider);
  try {
    return ordersState.orders.firstWhere((o) => o.id == id);
  } catch (_) {
    return null;
  }
});
