import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../../restaurant/application/restaurant_state.dart';
import '../data/datasources/coupons_remote_data_source.dart';
import '../data/models/coupon_model.dart';
import '../data/repositories/coupons_repository.dart';

/// Filter for coupon list
enum CouponFilter { all, active, expired }

/// Coupons state containing coupons and filters
class CouponsState {
  const CouponsState({
    this.coupons = const [],
    this.filter = CouponFilter.all,
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.hasMorePages = true,
  });

  final List<CouponModel> coupons;
  final CouponFilter filter;
  final String searchQuery;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final bool hasMorePages;

  CouponsState copyWith({
    List<CouponModel>? coupons,
    CouponFilter? filter,
    String? searchQuery,
    bool? isLoading,
    String? error,
    bool clearError = false,
    int? currentPage,
    bool? hasMorePages,
  }) {
    return CouponsState(
      coupons: coupons ?? this.coupons,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      currentPage: currentPage ?? this.currentPage,
      hasMorePages: hasMorePages ?? this.hasMorePages,
    );
  }

  /// Get filtered coupons based on current filter
  List<CouponModel> get filteredCoupons {
    var result = coupons;

    // Filter by status
    switch (filter) {
      case CouponFilter.active:
        result = result.where((c) => c.isValid).toList();
        break;
      case CouponFilter.expired:
        result = result.where((c) => c.isExpired || !c.isActive).toList();
        break;
      case CouponFilter.all:
        break;
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result.where((c) =>
        c.title.toLowerCase().contains(query) ||
        c.code.toLowerCase().contains(query) ||
        (c.description?.toLowerCase().contains(query) ?? false)
      ).toList();
    }

    return result;
  }

  /// Count of active coupons
  int get activeCount => coupons.where((c) => c.isValid).length;

  /// Count of expired coupons
  int get expiredCount => coupons.where((c) => c.isExpired || !c.isActive).length;
}

/// Coupons state notifier for managing coupons (Riverpod 3.x)
class CouponsNotifier extends Notifier<CouponsState> {
  late final CouponsRepository _repository;

  @override
  CouponsState build() {
    _repository = ref.watch(couponsRepositoryProvider);

    // Watch for restaurant state changes (loading -> loaded)
    ref.listen(restaurantProvider, (previous, next) {
      if (next is RestaurantLoaded && previous is! RestaurantLoaded) {
        Future.microtask(() => _loadCoupons());
      }
    });

    // Listen for restaurant selection changes
    ref.listen(selectedRestaurantIdProvider, (previous, next) {
      if (next != null && previous != next) {
        Future.microtask(() => _loadCoupons());
      }
    });

    Future.microtask(() => _loadCoupons());
    return const CouponsState(isLoading: true);
  }

  /// Get the current restaurant ID
  String? get _restaurantId => ref.read(selectedRestaurantIdProvider);

  /// Load coupons from API
  Future<void> _loadCoupons({
    int page = 1,
    bool? active,
    String? code,
  }) async {
    final restaurantState = ref.read(restaurantProvider);

    // If restaurant state is still loading, keep coupons in loading state
    if (restaurantState is RestaurantInitial || restaurantState is RestaurantLoading) {
      state = state.copyWith(isLoading: true, clearError: true);
      return;
    }

    final restaurantId = _restaurantId;
    if (restaurantId == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'No restaurant selected',
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _repository.getCoupons(
        restaurantId: restaurantId,
        page: page,
        active: active,
        code: code,
      );

      if (result.failure != null) {
        state = state.copyWith(
          isLoading: false,
          error: result.failure!.message,
        );
        return;
      }

      state = state.copyWith(
        coupons: result.data ?? [],
        isLoading: false,
        currentPage: page,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load coupons: $e',
      );
    }
  }

  /// Refresh coupons data
  Future<void> refresh() async {
    await _loadCoupons(page: 1);
  }

  /// Set filter
  void setFilter(CouponFilter filter) {
    state = state.copyWith(filter: filter);
  }

  /// Set search query
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Add a new coupon
  Future<void> addCoupon(CouponModel coupon) async {
    final restaurantId = _restaurantId;
    if (restaurantId == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'No restaurant selected',
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Prepare data for API
      final data = {
        'restaurant_id': restaurantId,
        'title': coupon.title,
        'code': coupon.code,
        'percentage': coupon.percentDiscount.toInt(),
        'min_price': coupon.minimumOrderPrice.toStringAsFixed(2),
        'start_date': coupon.startDate.toIso8601String(),
        'end_date': coupon.endDate.toIso8601String(),
        'is_active': coupon.isActive,
        if (coupon.description != null) 'description': coupon.description,
        if (coupon.maxTotalUsage != null) 'max_total_users': coupon.maxTotalUsage,
        if (coupon.maxUsagePerUser != null) 'max_per_customer': coupon.maxUsagePerUser,
      };

      final result = await _repository.createCoupon(
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
        coupons: [...state.coupons, result.data!],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to add coupon: $e',
      );
    }
  }

  /// Update an existing coupon
  Future<void> updateCoupon(CouponModel coupon) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Prepare data for API (partial update)
      final data = {
        'title': coupon.title,
        'code': coupon.code,
        'percentage': coupon.percentDiscount.toInt(),
        'min_price': coupon.minimumOrderPrice.toStringAsFixed(2),
        'start_date': coupon.startDate.toIso8601String(),
        'end_date': coupon.endDate.toIso8601String(),
        'is_active': coupon.isActive,
        if (coupon.description != null) 'description': coupon.description,
        if (coupon.maxTotalUsage != null) 'max_total_users': coupon.maxTotalUsage,
        if (coupon.maxUsagePerUser != null) 'max_per_customer': coupon.maxUsagePerUser,
      };

      final result = await _repository.patchCoupon(coupon.id, data);

      if (result.failure != null) {
        state = state.copyWith(
          isLoading: false,
          error: result.failure!.message,
        );
        return;
      }

      final updatedCoupons = state.coupons
          .map((c) => c.id == coupon.id ? result.data! : c)
          .toList();

      state = state.copyWith(
        coupons: updatedCoupons,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update coupon: $e',
      );
    }
  }

  /// Delete a coupon
  Future<void> deleteCoupon(String couponId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _repository.deleteCoupon(couponId);

      if (result.failure != null) {
        state = state.copyWith(
          isLoading: false,
          error: result.failure!.message,
        );
        return;
      }

      final updatedCoupons = state.coupons.where((c) => c.id != couponId).toList();

      state = state.copyWith(
        coupons: updatedCoupons,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete coupon: $e',
      );
    }
  }

  /// Toggle coupon active status
  Future<void> toggleCouponStatus(String couponId) async {
    state = state.copyWith(clearError: true);

    try {
      final coupon = state.coupons.firstWhere((c) => c.id == couponId);

      // Use patch to update only the is_active field
      final result = await _repository.patchCoupon(
        couponId,
        {'is_active': !coupon.isActive},
      );

      if (result.failure != null) {
        state = state.copyWith(error: result.failure!.message);
        return;
      }

      final updatedCoupons = state.coupons
          .map((c) => c.id == couponId ? result.data! : c)
          .toList();

      state = state.copyWith(coupons: updatedCoupons);
    } catch (e) {
      state = state.copyWith(error: 'Failed to toggle coupon status: $e');
    }
  }

  /// Get coupon by ID
  CouponModel? getCouponById(String id) {
    try {
      return state.coupons.firstWhere((coupon) => coupon.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Generate a unique coupon code
  String generateCouponCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    final code = List.generate(8, (i) => chars[(random + i * 7) % chars.length]).join();
    return code;
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Provider for coupons data source
final couponsDataSourceProvider = Provider<CouponsDataSource>((ref) {
  final api = ref.watch(couponsApiProvider);
  return CouponsRemoteDataSource(api);
});

/// Provider for coupons repository
final couponsRepositoryProvider = Provider<CouponsRepository>((ref) {
  final dataSource = ref.watch(couponsDataSourceProvider);
  return CouponsRepositoryImpl(remoteDataSource: dataSource);
});

/// Provider for coupons state (Riverpod 3.x)
final couponsProvider = NotifierProvider<CouponsNotifier, CouponsState>(
  CouponsNotifier.new,
);

/// Provider for filtered coupons
final filteredCouponsProvider = Provider<List<CouponModel>>((ref) {
  final couponsState = ref.watch(couponsProvider);
  return couponsState.filteredCoupons;
});

/// Provider for a single coupon by ID
final couponProvider = Provider.family<CouponModel?, String>((ref, id) {
  final couponsState = ref.watch(couponsProvider);
  try {
    return couponsState.coupons.firstWhere((coupon) => coupon.id == id);
  } catch (_) {
    return null;
  }
});

/// Provider for active/valid coupons only (for use in order creation)
final activeCouponsProvider = Provider<List<CouponModel>>((ref) {
  final couponsState = ref.watch(couponsProvider);
  return couponsState.coupons.where((c) => c.isValid).toList();
});
