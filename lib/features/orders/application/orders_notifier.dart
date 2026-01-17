import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../../restaurant/application/restaurant_state.dart';
import '../data/datasources/orders_remote_data_source.dart';
import '../data/models/order_model.dart';
import '../data/repositories/orders_repository.dart';

/// Orders state
class OrdersState {
  const OrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.hasMorePages = true,
  });

  final List<OrderModel> orders;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final bool hasMorePages;

  OrdersState copyWith({
    List<OrderModel>? orders,
    bool? isLoading,
    String? error,
    bool clearError = false,
    int? currentPage,
    bool? hasMorePages,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
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
          o.status == OrderStatusEnum.rejected ||
          o.status == OrderStatusEnum.cancelled)
      .toList();
}

/// Orders notifier for managing order state (Riverpod 3.x)
class OrdersNotifier extends Notifier<OrdersState> {
  late final OrdersRepository _repository;

  @override
  OrdersState build() {
    _repository = ref.watch(ordersRepositoryProvider);

    // Listen to restaurant selection changes
    ref.listen(selectedRestaurantIdProvider, (previous, next) {
      if (next != null && previous != next) {
        Future.microtask(() => _loadOrders());
      }
    });

    // Load initial orders
    Future.microtask(() => _loadOrders());
    return const OrdersState(isLoading: true);
  }

  /// Load orders from API
  /// Note: API auto-scopes to seller's restaurants
  Future<void> _loadOrders({
    int page = 1,
    String? status,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _repository.getOrders(
        page: page,
        status: status,
      );

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

  /// Cancel an order (sellers can only cancel, not accept - acceptance is done by drivers)
  Future<bool> cancelOrder(String orderId, {String? reason}) async {
    state = state.copyWith(clearError: true);

    try {
      final result = await _repository.updateOrderStatus(orderId, 'CANCELLED');

      if (result.failure != null) {
        state = state.copyWith(error: result.failure!.message);
        return false;
      }

      // Update local state with server response
      final index = state.orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        final updatedOrders = List<OrderModel>.from(state.orders);
        updatedOrders[index] = result.data!;
        state = state.copyWith(orders: updatedOrders);
      }

      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to cancel order: $e');
      return false;
    }
  }

  /// Update order status
  Future<bool> _updateStatus(String orderId, String status) async {
    state = state.copyWith(clearError: true);

    try {
      final result = await _repository.updateOrderStatus(orderId, status);

      if (result.failure != null) {
        state = state.copyWith(error: result.failure!.message);
        return false;
      }

      // Update local state with server response
      final index = state.orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        final updatedOrders = List<OrderModel>.from(state.orders);
        updatedOrders[index] = result.data!;
        state = state.copyWith(orders: updatedOrders);
      }

      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to update order status: $e');
      return false;
    }
  }

  /// Mark order as on the way
  Future<bool> markOnTheWay(String orderId) async {
    return _updateStatus(orderId, 'ON_THE_WAY');
  }

  /// Mark order as delivered
  Future<bool> markDelivered(String orderId) async {
    return _updateStatus(orderId, 'DELIVERED');
  }

  /// Mark order as completed
  Future<bool> markCompleted(String orderId) async {
    return _updateStatus(orderId, 'COMPLETED');
  }

  /// Get order by ID from local state
  OrderModel? getOrder(String orderId) {
    try {
      return state.orders.firstWhere((o) => o.id == orderId);
    } catch (_) {
      return null;
    }
  }

  /// Fetch order by ID from API
  Future<OrderModel?> fetchOrderById(String orderId) async {
    state = state.copyWith(clearError: true);

    try {
      final result = await _repository.getOrderById(orderId);

      if (result.failure != null) {
        state = state.copyWith(error: result.failure!.message);
        return null;
      }

      // Update local state if order exists in list
      final index = state.orders.indexWhere((o) => o.id == orderId);
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

  /// Move order to next status
  /// Note: Sellers cannot accept orders - that's handled by drivers
  Future<bool> moveToNextStatus(String orderId) async {
    final order = getOrder(orderId);
    if (order == null) return false;

    switch (order.status) {
      case OrderStatusEnum.pending:
      case OrderStatusEnum.searchingForDriver:
      case OrderStatusEnum.driverNotificationSent:
        // Sellers cannot change status for pending orders - handled by driver assignment
        return false;
      case OrderStatusEnum.accepted:
        return markOnTheWay(orderId);
      case OrderStatusEnum.onTheWay:
        return markDelivered(orderId);
      case OrderStatusEnum.delivered:
        return markCompleted(orderId);
      default:
        return false;
    }
  }

  /// Log manual order from scanned form
  Future<bool> logManualOrder(Map<String, dynamic> data) async {
    state = state.copyWith(clearError: true);

    try {
      final result = await _repository.logManualOrder(data: data);

      if (result.failure != null) {
        state = state.copyWith(error: result.failure!.message);
        return false;
      }

      // Refresh orders list to include the newly logged order
      await refreshOrders();

      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to log manual order: $e');
      return false;
    }
  }
}

/// Provider for orders data source
final ordersDataSourceProvider = Provider<OrdersDataSource>((ref) {
  final api = ref.watch(ordersApiProvider);
  return OrdersRemoteDataSource(api);
});

/// Provider for orders repository
final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  final dataSource = ref.watch(ordersDataSourceProvider);
  return OrdersRepositoryImpl(remoteDataSource: dataSource);
});

/// Provider for orders state (Riverpod 3.x)
final ordersProvider = NotifierProvider<OrdersNotifier, OrdersState>(
  OrdersNotifier.new,
);

/// Provider for a specific order
final orderByIdProvider = Provider.family<OrderModel?, String>((ref, id) {
  final ordersState = ref.watch(ordersProvider);
  try {
    return ordersState.orders.firstWhere((o) => o.id == id);
  } catch (_) {
    return null;
  }
});
