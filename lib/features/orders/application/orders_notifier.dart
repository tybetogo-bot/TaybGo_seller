import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors/failures.dart';
import '../../../core/i18n/i18n.dart';
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
  late final List<OrderModel> _currentOrders;
  late final List<OrderModel> _pendingOrders;
  late final List<OrderModel> _activeOrders;
  late final List<OrderModel> _completedOrders;
  late final List<OrderModel> _expiredOrders;

  void _computeFilteredLists() {
    final query = searchQuery.toLowerCase();
    final bool hasSearch = searchQuery.isNotEmpty;

    final current = <OrderModel>[];
    final pending = <OrderModel>[];
    final active = <OrderModel>[];
    final completed = <OrderModel>[];
    final expired = <OrderModel>[];

    for (final order in orders) {
      // Apply search filter once
      if (hasSearch && !_matchesSearch(order, query)) continue;

      // Categorize by status
      switch (order.status) {
        case OrderStatusEnum.pending:
        case OrderStatusEnum.searchingForDriver:
        case OrderStatusEnum.driverNotificationSent:
          current.add(order);
          pending.add(order);
        case OrderStatusEnum.accepted:
        case OrderStatusEnum.onTheWay:
          current.add(order);
          active.add(order);
        case OrderStatusEnum.delivered:
        case OrderStatusEnum.restaurantDelivered:
        case OrderStatusEnum.rejected:
        case OrderStatusEnum.cancelled:
          completed.add(order);
        case OrderStatusEnum.expired:
          expired.add(order);
      }
    }

    _currentOrders = current;
    _pendingOrders = pending;
    _activeOrders = active;
    _completedOrders = completed;
    _expiredOrders = expired;
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
  List<OrderModel> get currentOrders => _currentOrders;
  List<OrderModel> get pendingOrders => _pendingOrders;
  List<OrderModel> get activeOrders => _activeOrders;
  List<OrderModel> get completedOrders => _completedOrders;
  List<OrderModel> get expiredOrders => _expiredOrders;
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

      final filteredOrders = _filterOrdersForSelectedRestaurant(
        result.data ?? const [],
      );

      state = state.copyWith(
        orders: filteredOrders,
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

      final newOrders = _filterOrdersForSelectedRestaurant(result.data!);

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

  List<OrderModel> _filterOrdersForSelectedRestaurant(List<OrderModel> orders) {
    final selectedRestaurantId = ref.read(selectedRestaurantIdProvider);
    if (selectedRestaurantId == null || selectedRestaurantId.isEmpty) {
      return orders;
    }

    return orders.where((order) {
      final orderRestaurantId =
          order.restaurantId ?? order.restaurant?.id.toString();
      return orderRestaurantId == null ||
          orderRestaurantId == selectedRestaurantId;
    }).toList();
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
          oldOrder.assignedDriverId != newOrder.assignedDriverId ||
          oldOrder.sellerTotalAmount != newOrder.sellerTotalAmount ||
          oldOrder.driverDispatchDueAt != newOrder.driverDispatchDueAt ||
          oldOrder.driverDispatchStatus != newOrder.driverDispatchStatus ||
          oldOrder.driverDispatchRemainingSeconds !=
              newOrder.driverDispatchRemainingSeconds ||
          oldOrder.driverDispatchServerTime !=
              newOrder.driverDispatchServerTime ||
          oldOrder.driverDispatchMaxDelayMinutes !=
              newOrder.driverDispatchMaxDelayMinutes ||
          oldOrder.fulfillmentType != newOrder.fulfillmentType ||
          !_listEquals(oldOrder.allowedActions, newOrder.allowedActions) ||
          !_listEquals(
            oldOrder.allowedStatusOptions,
            newOrder.allowedStatusOptions,
          )) {
        return true;
      }
    }

    return false;
  }

  bool _listEquals<T>(List<T> first, List<T> second) {
    if (identical(first, second)) return true;
    if (first.length != second.length) return false;

    for (var index = 0; index < first.length; index++) {
      if (first[index] != second[index]) return false;
    }

    return true;
  }

  /// Cancel an order (sellers can only cancel, not accept - acceptance is done by drivers)
  Future<bool> cancelOrder(String orderId, {String? reason}) async {
    return _performOrderAction(
      orderId,
      () => _repository.updateOrderStatus(orderId, 'CANCELLED'),
      fallbackError: 'Failed to cancel order',
    );
  }

  /// Update order status
  Future<bool> _updateStatus(String orderId, String status) async {
    return _performOrderAction(
      orderId,
      () => _repository.updateOrderStatus(orderId, status),
      fallbackError: 'Failed to update order status',
    );
  }

  /// Mark order as on the way
  Future<bool> markOnTheWay(String orderId) async {
    return _updateStatus(orderId, 'ON_THE_WAY');
  }

  /// Mark order as delivered
  Future<bool> markDelivered(String orderId) async {
    return _updateStatus(orderId, 'DELIVERED');
  }

  /// Accept an order, optionally delaying driver dispatch on the server.
  Future<bool> acceptOrder(
    String orderId, {
    int? driverDispatchDelayMinutes,
  }) async {
    return _performOrderAction(
      orderId,
      () => _repository.acceptOrder(
        orderId,
        driverDispatchDelayMinutes: driverDispatchDelayMinutes,
      ),
      fallbackError: 'Failed to accept order',
    );
  }

  /// Reject a new order before preparation begins.
  Future<bool> rejectOrder(String orderId) async {
    return _performOrderAction(
      orderId,
      () => _repository.rejectOrder(orderId),
      fallbackError: 'Failed to reject order',
    );
  }

  /// Apply item-only changes before a pending order is accepted.
  ///
  /// The server owns validation, pricing, inventory reconciliation, and the
  /// payment/status boundary. The request deliberately contains no customer,
  /// address, payment, delivery-fee, or seller-total fields.
  Future<bool> editPendingOrderItems(
    String orderId,
    List<CartItem> items,
  ) async {
    if (items.isEmpty) {
      state = state.copyWith(error: 'orders.emptyItemsWarning'.tr);
      return false;
    }

    // Keep one key for the whole user action. The Dio retry interceptor
    // replays timeout/connection failures with the same request body, and the
    // reconciliation below prevents a second key from being generated when
    // the final response is ambiguous.
    final idempotencyKey = const Uuid().v4();
    return _performOrderAction(
      orderId,
      () => _repository.editOrderItems(
        orderId,
        items: items,
        idempotencyKey: idempotencyKey,
      ),
      fallbackError: 'orders.incoming.editItemsFailed'.tr,
      failureFallbackErrorKey: 'orders.incoming.editItemsFailed',
      reconcileOnAmbiguousFailure: true,
    );
  }

  /// Request driver matching immediately.
  Future<bool> requestDriverNow(String orderId) async {
    return _performOrderAction(
      orderId,
      () => _repository.driverDispatch(
        orderId,
        action: DriverDispatchAction.requestNow,
      ),
      fallbackError: 'Failed to request a driver',
    );
  }

  /// Schedule driver matching after a server-validated delay.
  Future<bool> scheduleDriver(String orderId, int delayMinutes) async {
    return _performOrderAction(
      orderId,
      () => _repository.driverDispatch(
        orderId,
        action: DriverDispatchAction.schedule,
        driverDispatchDelayMinutes: delayMinutes,
      ),
      fallbackError: 'Failed to schedule driver request',
    );
  }

  /// Change an existing driver schedule. This operation is not retried by Dio;
  /// a failed response is treated as unknown and reconciled with a GET.
  Future<bool> rescheduleDriver(String orderId, int delayMinutes) async {
    return _performOrderAction(
      orderId,
      () => _repository.driverDispatch(
        orderId,
        action: DriverDispatchAction.reschedule,
        driverDispatchDelayMinutes: delayMinutes,
      ),
      fallbackError: 'Failed to change driver request time',
      refreshOnUnknownOutcome: true,
    );
  }

  Future<bool> _performOrderAction(
    String orderId,
    Future<OrdersResult<OrderModel>> Function() operation, {
    required String fallbackError,
    bool refreshOnUnknownOutcome = false,
    bool reconcileOnAmbiguousFailure = false,
    String? failureFallbackErrorKey,
  }) async {
    state = state.copyWith(clearError: true);

    try {
      final result = await operation();
      final failure = result.failure;
      if (failure != null) {
        if (failure.statusCode == 409 ||
            refreshOnUnknownOutcome ||
            (reconcileOnAmbiguousFailure && _isAmbiguousFailure(failure))) {
          await _refreshOrderForActionRace(orderId);
        }
        state = state.copyWith(
          error: _actionErrorMessage(
            failure,
            fallbackKey: failureFallbackErrorKey,
          ),
        );
        return false;
      }

      final updatedOrder = result.data;
      if (updatedOrder == null) {
        state = state.copyWith(error: fallbackError);
        return false;
      }
      _replaceOrder(updatedOrder);
      return true;
    } catch (e) {
      state = state.copyWith(error: '$fallbackError: $e');
      return false;
    }
  }

  bool _isAmbiguousFailure(Failure failure) {
    final statusCode = failure.statusCode;
    return statusCode == null ||
        statusCode == 0 ||
        statusCode == 408 ||
        statusCode >= 500;
  }

  Future<void> _refreshOrderForActionRace(String orderId) async {
    try {
      final result = await _repository.getOrderById(orderId);
      if (result.failure == null && result.data != null) {
        _replaceOrder(result.data!);
      }
    } catch (_) {
      // Preserve the original action error when the reconciliation request
      // cannot reach the server as well.
    }
  }

  void _replaceOrder(OrderModel updatedOrder) {
    final index = state.orders.indexWhere((o) => o.id == updatedOrder.id);
    final updatedOrders = List<OrderModel>.from(state.orders);
    if (index == -1) {
      updatedOrders.insert(0, updatedOrder);
    } else {
      updatedOrders[index] = updatedOrder;
    }
    state = state.copyWith(orders: updatedOrders, clearError: true);
  }

  String _actionErrorMessage(Failure failure, {String? fallbackKey}) {
    final key = switch (failure.code) {
      'driver_dispatch_delay_too_long' =>
        'orders.driverDispatchErrors.delayTooLong',
      'invalid_driver_dispatch_delay' =>
        'orders.driverDispatchErrors.invalidDelay',
      'pickup_driver_dispatch_unavailable' =>
        'orders.driverDispatchErrors.pickupUnavailable',
      'driver_dispatch_already_scheduled' =>
        'orders.driverDispatchErrors.alreadyScheduled',
      'driver_dispatch_not_scheduled' =>
        'orders.driverDispatchErrors.notScheduled',
      'driver_dispatch_schedule_due' =>
        'orders.driverDispatchErrors.scheduleDue',
      'driver_already_assigned' =>
        'orders.driverDispatchErrors.alreadyAssigned',
      'invalid_order_status' => 'orders.driverDispatchErrors.invalidStatus',
      'invalid_order_edit' => 'orders.incoming.invalidItems',
      'order_repricing_data_missing' => 'orders.incoming.repricingDataMissing',
      'customer_approval_required' =>
        'orders.incoming.customerApprovalRequired',
      'idempotency_conflict' => 'orders.incoming.editItemsConflict',
      _ => null,
    };
    if (key != null) return key.tr;

    // Known backend codes above are the source of truth. If a transport or
    // older backend response has no code, use the localized action fallback
    // rather than trying to infer the error from message text.
    if (fallbackKey != null &&
        (failure.code == null || failure.code!.isEmpty)) {
      return fallbackKey.tr;
    }

    return failure.message;
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

      final fetchedOrder = result.data;
      if (fetchedOrder == null) {
        state = state.copyWith(error: 'Failed to fetch order');
        return null;
      }

      // Keep the fetched order available for a notification-opened detail
      // route, even when it was not present in the currently loaded page.
      final index = state.orders.indexWhere((o) => o.id == orderId);
      final updatedOrders = List<OrderModel>.from(state.orders);
      if (index == -1) {
        updatedOrders.insert(0, fetchedOrder);
      } else {
        updatedOrders[index] = fetchedOrder;
      }
      state = state.copyWith(orders: updatedOrders);

      return fetchedOrder;
    } catch (e) {
      state = state.copyWith(error: 'Failed to fetch order: $e');
      return null;
    }
  }

  /// Update an app-created order through the authenticated order endpoint.
  Future<OrderModel?> updateManualOrder(
    String orderId,
    OrderUpdateRequest request,
  ) async {
    state = state.copyWith(clearError: true);

    try {
      final result = await _customerOrdersRepository.updateOrder(
        orderId,
        request,
      );

      if (result.failure != null) {
        state = state.copyWith(error: result.failure!.message);
        return null;
      }

      var updatedOrder = result.data!;
      final verifiedResult = await _repository.getOrderById(orderId);
      if (verifiedResult.failure == null && verifiedResult.data != null) {
        updatedOrder = verifiedResult.data!;
      }

      final index = state.orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        final updatedOrders = List<OrderModel>.from(state.orders);
        updatedOrders[index] = updatedOrder;
        state = state.copyWith(orders: updatedOrders);
      } else {
        await refreshOrders();
      }

      return updatedOrder;
    } catch (e) {
      state = state.copyWith(error: 'Failed to update order: $e');
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

  /// Move order to the next actionable seller status.
  /// Prefer backend-provided allowed status options when available.
  /// Fall back to the legacy local flow only when the API contract is absent.
  Future<bool> moveToNextStatus(String orderId) async {
    final order = getOrder(orderId);
    if (order == null) return false;

    final nextStatus = getNextStatusForOrder(order);
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
      case OrderStatusEnum.restaurantDelivered:
        return 'RESTAURANT_DELIVERED';
      case OrderStatusEnum.expired:
        return 'EXPIRED';
      case OrderStatusEnum.rejected:
        return 'REJECTED';
      case OrderStatusEnum.cancelled:
        return 'CANCELLED';
    }
  }

  OrderStatusEnum? getNextStatusForOrder(OrderModel order) {
    if (order.hasAllowedStatusOptions || order.allowedActions.isNotEmpty) {
      return order.preferredAllowedNextStatus;
    }

    return order.status.nextStatusForRestaurant(
      deliveryEnabled: isDeliveryEnabledForOrder(order),
    );
  }

  /// Return the highest-priority action supplied by the backend. Legacy
  /// responses are mapped to the equivalent status action for compatibility.
  OrderAllowedAction? getPrimaryAllowedAction(OrderModel order) {
    const priority = [
      'ACCEPTED',
      'REQUEST_DRIVER_NOW',
      'SCHEDULE_DRIVER',
      'RESCHEDULE_DRIVER',
      'REJECTED',
      'CANCELLED',
    ];
    for (final value in priority) {
      final action = order.allowedAction(value);
      if (action != null) return action;
    }

    if (order.allowedActions.isNotEmpty) {
      return order.allowedActions.first;
    }

    // Acceptance is a dedicated seller action even for legacy responses that
    // do not yet include allowed_actions. Do not derive PENDING -> SEARCHING
    // from the old status-only flow.
    if (order.status == OrderStatusEnum.pending) {
      return const OrderAllowedAction(value: 'ACCEPTED');
    }

    final nextStatus = getNextStatusForOrder(order);
    if (nextStatus != null) {
      return OrderAllowedAction(value: _statusToApiString(nextStatus));
    }
    return null;
  }

  bool canRejectOrder(OrderModel order) {
    if (order.allowedActions.isNotEmpty) {
      return order.allowsAction('REJECTED');
    }
    return order.status == OrderStatusEnum.pending;
  }

  bool canCancelOrder(OrderModel order) {
    return order.allowedActions.isNotEmpty && order.allowsAction('CANCELLED');
  }

  bool isDriverDispatchAvailableForOrder(OrderModel order) {
    if (order.orderType.trim().toUpperCase() != 'FOOD') return false;
    final fulfillmentType =
        (order.fulfillmentType ?? order.requestedDeliveryType ?? '')
            .trim()
            .toUpperCase();
    if (fulfillmentType != 'DELIVERY') return false;

    final embeddedDeliveryEnabled = order.restaurant?.deliveryEnabled;
    if (embeddedDeliveryEnabled != null) return embeddedDeliveryEnabled;

    final orderRestaurantId =
        order.restaurantId ?? order.restaurant?.id.toString();
    final restaurantState = ref.read(restaurantProvider);
    if (restaurantState is RestaurantLoaded) {
      final matching = restaurantState.restaurants.where(
        (restaurant) =>
            orderRestaurantId == null || restaurant.id == orderRestaurantId,
      );
      if (matching.length == 1) return matching.first.deliveryEnabled == true;
    }

    final selectedRestaurant = ref.read(selectedRestaurantProvider);
    return selectedRestaurant != null &&
        (orderRestaurantId == null ||
            selectedRestaurant.id == orderRestaurantId) &&
        selectedRestaurant.deliveryEnabled == true;
  }

  bool isDeliveryEnabledForOrder(OrderModel order) {
    final embeddedDeliveryEnabled = order.restaurant?.deliveryEnabled;
    if (embeddedDeliveryEnabled != null) return embeddedDeliveryEnabled;

    final orderRestaurantId =
        order.restaurantId ?? order.restaurant?.id.toString();

    final restaurantState = ref.read(restaurantProvider);
    if (restaurantState is RestaurantLoaded) {
      if (orderRestaurantId != null) {
        for (final restaurant in restaurantState.restaurants) {
          if (restaurant.id == orderRestaurantId) {
            return restaurant.deliveryEnabled != false;
          }
        }
      }

      if (restaurantState.restaurants.length == 1) {
        return restaurantState.restaurants.first.deliveryEnabled != false;
      }
    }

    final selectedRestaurant = ref.read(selectedRestaurantProvider);
    if (selectedRestaurant != null &&
        (orderRestaurantId == null ||
            selectedRestaurant.id == orderRestaurantId)) {
      return selectedRestaurant.deliveryEnabled != false;
    }

    return true;
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
/// This provider creates a polling service that refreshes orders every 5 seconds.
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
    final wasPolling = _service?.isPolling ?? false;
    _service?.dispose();
    _service = _createPollingService(state.interval);
    if (wasPolling) {
      _service?.start();
    }
  }

  PollingService _createPollingService(Duration interval) {
    return PollingService(
      onPoll: () async {
        // Use silentRefresh to only update UI when data changes
        await ref.read(ordersProvider.notifier).silentRefresh();
      },
      interval: interval,
      debugLabel: 'OrdersPolling',
      onNextPollScheduled: (nextPollAt) {
        state = state.copyWith(nextPollAt: nextPollAt);
      },
      onPollStarted: () {
        state = state.copyWith(isSyncing: true);
      },
      onPollCompleted: () {
        state = state.copyWith(isSyncing: false, lastPollAt: DateTime.now());
      },
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
    state = state.copyWith(
      isEnabled: false,
      isSyncing: false,
      clearNextPollAt: true,
    );
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
    final wasPolling = _service?.isPolling ?? false;
    state = state.copyWith(interval: interval);
    if (_service != null) {
      _service?.dispose();
      _service = _createPollingService(interval);
      if (wasPolling) {
        _service?.start();
      } else {
        state = state.copyWith(isSyncing: false, clearNextPollAt: true);
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
