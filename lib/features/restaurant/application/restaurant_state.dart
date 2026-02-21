/// Restaurant state management with Riverpod 3.x
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../data/models/restaurant_model.dart';
import '../data/repositories/restaurant_repository.dart';
import '../data/datasources/restaurant_remote_data_source.dart';

/// Restaurant state sealed class hierarchy
sealed class RestaurantState {
  const RestaurantState();
}

/// Initial state
class RestaurantInitial extends RestaurantState {
  const RestaurantInitial();
}

/// Loading state
class RestaurantLoading extends RestaurantState {
  const RestaurantLoading();
}

/// Loaded state with restaurants list
class RestaurantLoaded extends RestaurantState {
  const RestaurantLoaded({required this.restaurants, this.selectedRestaurant});

  final List<RestaurantModel> restaurants;
  final RestaurantModel? selectedRestaurant;

  RestaurantLoaded copyWith({
    List<RestaurantModel>? restaurants,
    RestaurantModel? selectedRestaurant,
  }) {
    return RestaurantLoaded(
      restaurants: restaurants ?? this.restaurants,
      selectedRestaurant: selectedRestaurant ?? this.selectedRestaurant,
    );
  }
}

/// Error state
class RestaurantError extends RestaurantState {
  const RestaurantError({required this.message, this.previousState});

  final String message;
  final RestaurantState? previousState;
}

/// Restaurant notifier (Riverpod 3.x)
class RestaurantNotifier extends Notifier<RestaurantState> {
  late final RestaurantRepository _repository;

  @override
  RestaurantState build() {
    print('🟡 [RestaurantNotifier] build() called');
    _repository = ref.watch(restaurantRepositoryProvider);
    _initializeRestaurant();
    return const RestaurantInitial();
  }

  /// Initialize restaurant from storage or fetch from API
  Future<void> _initializeRestaurant() async {
    final storedRestaurantId = _repository.getSelectedRestaurantId();
    print('🟡 [RestaurantNotifier] Stored restaurant ID: $storedRestaurantId');

    if (storedRestaurantId != null) {
      // Fetch the stored restaurant details
      await fetchRestaurantById(storedRestaurantId);
    } else {
      // Fetch all restaurants for selection
      await fetchRestaurants();
    }
  }

  /// Fetch all restaurants for the seller
  Future<void> fetchRestaurants() async {
    print('🟡 [RestaurantNotifier] fetchRestaurants() called');
    state = const RestaurantLoading();

    final result = await _repository.getRestaurants();

    if (result.failure != null) {
      print(
        '🔴 [RestaurantNotifier] fetchRestaurants error: ${result.failure!.message}',
      );
      state = RestaurantError(
        message: result.failure!.message,
        previousState: const RestaurantInitial(),
      );
    } else if (result.data != null) {
      final restaurants = result.data!;
      print(
        '🟢 [RestaurantNotifier] Fetched ${restaurants.length} restaurants',
      );

      // If only one restaurant, auto-select it
      if (restaurants.length == 1) {
        print('🟢 [RestaurantNotifier] Auto-selecting single restaurant');
        await selectRestaurant(restaurants.first);
      } else {
        state = RestaurantLoaded(restaurants: restaurants);
      }
    }
  }

  /// Fetch restaurant by ID with today's stats
  Future<void> fetchRestaurantById(String id) async {
    state = const RestaurantLoading();

    final result = await _repository.getRestaurantById(id);

    if (result.failure != null) {
      state = RestaurantError(
        message: result.failure!.message,
        previousState: const RestaurantInitial(),
      );
    } else if (result.data != null) {
      final currentState = state;
      final restaurants = currentState is RestaurantLoaded
          ? currentState.restaurants
          : [result.data!];

      state = RestaurantLoaded(
        restaurants: restaurants,
        selectedRestaurant: result.data!,
      );
    }
  }

  /// Select a restaurant
  Future<void> selectRestaurant(RestaurantModel restaurant) async {
    print(
      '🟢 [RestaurantNotifier] selectRestaurant: ${restaurant.id} - ${restaurant.name}',
    );
    await _repository.saveSelectedRestaurantId(restaurant.id);

    final currentState = state;
    if (currentState is RestaurantLoaded) {
      state = currentState.copyWith(selectedRestaurant: restaurant);
    } else {
      state = RestaurantLoaded(
        restaurants: [restaurant],
        selectedRestaurant: restaurant,
      );
    }
    print('🟢 [RestaurantNotifier] Restaurant selected and saved!');
  }

  /// Clear selected restaurant
  Future<void> clearSelection() async {
    await _repository.clearSelectedRestaurant();

    final currentState = state;
    if (currentState is RestaurantLoaded) {
      state = RestaurantLoaded(
        restaurants: currentState.restaurants,
        selectedRestaurant: null,
      );
    }
  }

  /// Create new restaurant
  Future<void> createRestaurant(Map<String, dynamic> data) async {
    state = const RestaurantLoading();

    final result = await _repository.createRestaurant(data);

    if (result.failure != null) {
      state = RestaurantError(
        message: result.failure!.message,
        previousState: const RestaurantInitial(),
      );
    } else if (result.data != null) {
      // Auto-select the newly created restaurant
      await selectRestaurant(result.data!);
    }
  }

  /// Update restaurant
  Future<void> updateRestaurant(String id, Map<String, dynamic> data) async {
    final result = await _repository.updateRestaurant(id, data);

    if (result.failure != null) {
      state = RestaurantError(
        message: result.failure!.message,
        previousState: state,
      );
    } else if (result.data != null) {
      // Refresh the current state with updated restaurant
      final currentState = state;
      if (currentState is RestaurantLoaded) {
        state = currentState.copyWith(selectedRestaurant: result.data!);
      }
    }
  }

  /// Patch restaurant (partial update)
  Future<void> patchRestaurant(String id, Map<String, dynamic> data) async {
    final result = await _repository.patchRestaurant(id, data);

    if (result.failure != null) {
      state = RestaurantError(
        message: result.failure!.message,
        previousState: state,
      );
    } else if (result.data != null) {
      // Refresh the current state with updated restaurant
      final currentState = state;
      if (currentState is RestaurantLoaded) {
        state = currentState.copyWith(selectedRestaurant: result.data!);
      }
    }
  }

  /// Get selected restaurant (convenience method)
  RestaurantModel? get selectedRestaurant {
    final currentState = state;
    if (currentState is RestaurantLoaded) {
      return currentState.selectedRestaurant;
    }
    return null;
  }

  /// Get selected restaurant ID (convenience method)
  String? get selectedRestaurantId {
    return selectedRestaurant?.id;
  }
}

/// Provider for restaurant data source
final restaurantDataSourceProvider = Provider<RestaurantDataSource>((ref) {
  final api = ref.watch(restaurantApiProvider);
  return RestaurantRemoteDataSource(api);
});

/// Provider for restaurant repository
final restaurantRepositoryProvider = Provider<RestaurantRepository>((ref) {
  final dataSource = ref.watch(restaurantDataSourceProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return RestaurantRepositoryImpl(remoteDataSource: dataSource, prefs: prefs);
});

/// Provider for restaurant state (Riverpod 3.x)
final restaurantProvider =
    NotifierProvider<RestaurantNotifier, RestaurantState>(
      RestaurantNotifier.new,
    );

/// Provider for selected restaurant
final selectedRestaurantProvider = Provider<RestaurantModel?>((ref) {
  final state = ref.watch(restaurantProvider);
  if (state is RestaurantLoaded) {
    return state.selectedRestaurant;
  }
  return null;
});

/// Provider for selected restaurant ID
final selectedRestaurantIdProvider = Provider<String?>((ref) {
  return ref.watch(selectedRestaurantProvider)?.id;
});
