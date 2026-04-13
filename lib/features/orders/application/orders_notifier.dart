import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../../../core/services/polling_service.dart';
import '../../restaurant/application/restaurant_state.dart';
import 'customer_orders_notifier.dart';
import '../data/datasources/orders_remote_data_source.dart';
import '../data/models/food_checkout_model.dart';
import '../data/models/order_model.dart';
import '../data/repositories/customer_orders_repository.dart';
import '../data/repositories/orders_repository.dart';

/// Orders state with cached filtered lists for performance
class OrdersState {
  OrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.hasMorePages = true,
    this.searchQuery = '',
  }) {
    // Pre-compute filtered lists once during construction
    _computeFilteredLists();
  }

  final List<OrderModel> orders;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final bool hasMorePages;
  final String searchQuery;

  // Cached filtered lists
  late final List<OrderModel> _pendingOrders;
  late final List<OrderModel> _activeOrders;
  late final List<OrderModel> _completedOrders;

  void _computeFilteredLists() {
    final query = searchQuery.toLowerCase();
    final bool hasSearch = searchQuery.isNotEmpty;

    final pending = <OrderModel>[];
    final active = <OrderModel>[];
    final completed = <OrderModel>[];

    for (final order in orders) {
      // Apply search filter once
      if (hasSearch && !_matchesSearch(order, query)) continue;

      // Categorize by status
      switch (order.status) {
        case OrderStatusEnum.pending:
        case OrderStatusEnum.searchingForDriver:
          pending.add(order);
        case OrderStatusEnum.accepted:
        case OrderStatusEnum.driverNotificationSent:
        case OrderStatusEnum.onTheWay:
          active.add(order);
        case OrderStatusEnum.delivered:
        case OrderStatusEnum.expired:
        case OrderStatusEnum.rejected:
        case OrderStatusEnum.cancelled:
          completed.add(order);
      }
    }

    _pendingOrders = pending;
    _activeOrders = active;
    _completedOrders = completed;
  }

  bool _matchesSearch(OrderModel order, String query) {
    if (order.id.toLowerCase().contains(query)) return true;
    if (order.customerName.toLowerCase().contains(query)) return true;
    if (order.phoneNumber.contains(query)) return true;
    if (order.items.any((item) => item.name.toLowerCase().contains(query))) {
      return true;
    }
    if (order.restaurant?.name.toLowerCase().contains(query) ?? false) {
      return true;
    }
    return false;
  }

  OrdersState copyWith({
    List<OrderModel>? orders,
    bool? isLoading,
    String? error,
    bool clearError = false,
    int? currentPage,
    bool? hasMorePages,
    String? searchQuery,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      currentPage: currentPage ?? this.currentPage,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  /// Cached getters - no computation on access
  List<OrderModel> get pendingOrders => _pendingOrders;
  List<OrderModel> get activeOrders => _activeOrders;
  List<OrderModel> get completedOrders => _completedOrders;
}

/// Orders notifier for managing order state (Riverpod 3.x)
class OrdersNotifier extends Notifier<OrdersState> {
  late final OrdersRepository _repository;
  late final CustomerOrdersRepository _customerOrdersRepository;

  @override
  OrdersState build() {
    _repository = ref.watch(ordersRepositoryProvider);
    _customerOrdersRepository = ref.watch(customerOrdersRepositoryProvider);

    // Listen to restaurant selection changes
    ref.listen(selectedRestaurantIdProvider, (previous, next) {
      if (next != null && previous != next) {
        Future.microtask(() => _loadOrders());
      }
    });

    // Load initial orders
    Future.microtask(() => _loadOrders());
    return OrdersState(isLoading: true);
  }

  /// Load orders from API
  /// Note: API auto-scopes to seller's restaurants
  Future<void> _loadOrders({int page = 1, String? status}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _repository.getOrders(page: page, status: status);

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

  /// Refresh orders (shows loading state)
  Future<void> refreshOrders() async {
    await _loadOrders(page: 1);
  }

  /// Set search query for filtering orders
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Clear search query
  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }

  /// Silent refresh - only updates UI if data has changed
  /// Used by polling to avoid unnecessary rebuilds
  Future<bool> silentRefresh() async {
    try {
      final result = await _repository.getOrders(page: 1);

      if (result.failure != null || result.data == null) {
        return false;
      }

      final newOrders = result.data!;

      // Check if data has actually changed
      if (_hasOrdersChanged(newOrders)) {
        state = state.copyWith(
          orders: newOrders,
          currentPage: 1,
          clearError: true,
        );
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Compare orders to detect changes
  bool _hasOrdersChanged(List<OrderModel> newOrders) {
    if (newOrders.length != state.orders.length) return true;

    for (final newOrder in newOrders) {
      final oldOrder = state.orders.firstWhere(
        (o) => o.id == newOrder.id,
        orElse: () => newOrder,
      );

      // Check if order exists and has same status/payment state
      if (oldOrder.id != newOrder.id ||
          oldOrder.status != newOrder.status ||
          oldOrder.isPaid != newOrder.isPaid ||
          oldOrder.assignedDriverId != newOrder.assignedDriverId) {
        return true;
      }
    }

    return false;
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

  /// Accept an order
  Future<bool> acceptOrder(String orderId) async {
    return _updateStatus(orderId, 'ACCEPTED');
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

  /// Recreate an expired order using the regular create-order API.
  Future<OrderModel?> reorderExpiredOrder(String orderId) async {
    state = state.copyWith(clearError: true);

    try {
      OrderModel? sourceOrder = getOrder(orderId);

      final detailResult = await _repository.getOrderById(orderId);
      if (detailResult.failure == null && detailResult.data != null) {
        sourceOrder = detailResult.data;

        final index = state.orders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          final updatedOrders = List<OrderModel>.from(state.orders);
          updatedOrders[index] = detailResult.data!;
          state = state.copyWith(orders: updatedOrders);
        }
      }

      if (sourceOrder == null) {
        state = state.copyWith(
          error:
              detailResult.failure?.message ??
              'Unable to load the order for reordering.',
        );
        return null;
      }

      if (sourceOrder.status != OrderStatusEnum.expired) {
        state = state.copyWith(error: 'Only expired orders can be reordered.');
        return null;
      }

      final reorderRequest = sourceOrder.toReorderRequest();
      final createResult = await _customerOrdersRepository.createFoodOrder(
        reorderRequest,
      );

      if (createResult.failure != null) {
        state = state.copyWith(error: createResult.failure!.message);
        return null;
      }

      await refreshOrders();
      return createResult.data;
    } on FormatException catch (e) {
      state = state.copyWith(
        error: e.message.isNotEmpty
            ? e.message
            : 'This order cannot be reordered because some data is missing.',
      );
      return null;
    } catch (e) {
      state = state.copyWith(error: 'Failed to reorder order: $e');
      return null;
    }
  }

  /// Move order to next status in the flow
  /// Flow: PENDING → SEARCHING_FOR_DRIVER → DRIVER_NOTIFICATION_SENT → ACCEPTED → ON_THE_WAY → DELIVERED
  Future<bool> moveToNextStatus(String orderId) async {
    final order = getOrder(orderId);
    if (order == null) return false;

    final nextStatus = order.status.nextStatus;
    if (nextStatus == null) return false;

    // Convert enum to API status string
    final statusString = _statusToApiString(nextStatus);
    return _updateStatus(orderId, statusString);
  }

  /// Update order to a specific status (used for undo functionality)
  Future<bool> updateToStatus(String orderId, OrderStatusEnum status) async {
    final statusString = _statusToApiString(status);
    return _updateStatus(orderId, statusString);
  }

  /// Convert OrderStatusEnum to API status string
  String _statusToApiString(OrderStatusEnum status) {
    switch (status) {
      case OrderStatusEnum.pending:
        return 'PENDING';
      case OrderStatusEnum.searchingForDriver:
        return 'SEARCHING_FOR_DRIVER';
      case OrderStatusEnum.driverNotificationSent:
        return 'DRIVER_NOTIFICATION_SENT';
      case OrderStatusEnum.accepted:
        return 'ACCEPTED';
      case OrderStatusEnum.onTheWay:
        return 'ON_THE_WAY';
      case OrderStatusEnum.delivered:
        return 'DELIVERED';
      case OrderStatusEnum.expired:
        return 'EXPIRED';
      case OrderStatusEnum.rejected:
        return 'REJECTED';
      case OrderStatusEnum.cancelled:
        return 'CANCELLED';
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

/// Provider for orders polling service
///
/// This provider creates a polling service that refreshes orders every 30 seconds.
/// Only updates UI when there's new data to avoid unnecessary rebuilds.
/// Usage:
/// ```dart
/// // In a widget or notifier:
/// final pollingNotifier = ref.read(ordersPollingProvider.notifier);
/// pollingNotifier.start(); // Start polling
/// pollingNotifier.stop();  // Stop polling
/// ```
final ordersPollingProvider =
    NotifierProvider<OrdersPollingNotifier, PollingState>(
      OrdersPollingNotifier.new,
    );

/// Notifier for orders polling
class OrdersPollingNotifier extends Notifier<PollingState> {
  PollingService? _service;
  static const _defaultInterval = Duration(seconds: 5);

  @override
  PollingState build() {
    ref.onDispose(() {
      _service?.dispose();
    });

    // Initialize the polling service
    Future.microtask(() => _initializeService());

    return const PollingState(interval: _defaultInterval);
  }

  void _initializeService() {
    _service?.dispose();
    _service = PollingService(
      onPoll: () async {
        // Use silentRefresh to only update UI when data changes
        await ref.read(ordersProvider.notifier).silentRefresh();
      },
      interval: state.interval,
      debugLabel: 'OrdersPolling',
    );
  }

  /// Start polling for new orders
  void start() {
    if (_service == null) {
      _initializeService();
    }
    state = state.copyWith(isEnabled: true);
    _service?.start();
  }

  /// Stop polling
  void stop() {
    state = state.copyWith(isEnabled: false);
    _service?.stop();
  }

  /// Toggle polling on/off
  void toggle() {
    if (state.isEnabled) {
      stop();
    } else {
      start();
    }
  }

  /// Update the polling interval
  void setInterval(Duration interval) {
    state = state.copyWith(interval: interval);
    if (_service != null) {
      final wasPolling = _service!.isPolling;
      _service?.dispose();
      _service = PollingService(
        onPoll: () async {
          // Use silentRefresh to only update UI when data changes
          await ref.read(ordersProvider.notifier).silentRefresh();
        },
        interval: interval,
        debugLabel: 'OrdersPolling',
      );
      if (wasPolling) {
        _service?.start();
      }
    }
  }

  /// Trigger an immediate poll
  Future<void> pollNow() async {
    await _service?.pollNow();
  }

  /// Whether polling is currently active
  bool get isPolling => _service?.isPolling ?? false;
}
