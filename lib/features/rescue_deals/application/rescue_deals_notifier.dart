import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/i18n/i18n.dart';
import '../../../core/network/rescue_deals_api.dart';
import '../../../core/providers/providers.dart';
import '../../../core/services/session_lifecycle.dart';
import '../../profile/application/user_profile_notifier.dart';
import '../../restaurant/application/restaurant_state.dart';
import '../data/models/rescue_deal.dart';
import '../data/repositories/rescue_deals_repository.dart';

final rescueDealsRepositoryProvider = Provider((ref) {
  ref.watch(sessionGenerationProvider);
  final owner = ref.watch(userProfileProvider).profile?.id;
  return RescueDealsRepository(
    RescueDealsApi(ref.watch(dioProvider)),
    ref.watch(menuApiProvider),
    stockStore: owner == null
        ? null
        : RescueStockStore(
            ref.watch(sharedPreferencesProvider),
            owner.toString(),
          ),
  );
});

class RescueDealsState {
  const RescueDealsState({
    this.items = const [],
    this.loading = false,
    this.error,
  });
  final List<RescueDeal> items;
  final bool loading;
  final String? error;
}

class RescueDealsNotifier extends Notifier<RescueDealsState> {
  int _request = 0;
  @override
  RescueDealsState build() {
    ref.watch(sessionGenerationProvider);
    final restaurantId = ref.watch(selectedRestaurantIdProvider);
    final generation = SessionLifecycle.instance.generation;
    _request++;
    if (restaurantId == null ||
        !SessionLifecycle.instance.isAuthenticated(generation)) {
      return const RescueDealsState();
    }
    Future.microtask(() {
      if (_current(generation, restaurantId)) refresh();
    });
    return const RescueDealsState(loading: true);
  }

  bool _current(int generation, String restaurantId) =>
      ref.mounted &&
      SessionLifecycle.instance.isAuthenticated(generation) &&
      ref.read(selectedRestaurantIdProvider) == restaurantId;
  Future<void> refresh() async {
    final restaurantId = ref.read(selectedRestaurantIdProvider);
    final generation = SessionLifecycle.instance.generation;
    if (restaurantId == null || !_current(generation, restaurantId)) return;
    final request = ++_request;
    final previous = state.items;
    state = RescueDealsState(items: previous, loading: true);
    try {
      final items = await ref
          .read(rescueDealsRepositoryProvider)
          .list(restaurantId);
      if (!_current(generation, restaurantId) || request != _request) return;
      state = RescueDealsState(
        items: items.where((d) => d.restaurantId == restaurantId).toList(),
      );
    } catch (error) {
      if (!_current(generation, restaurantId) || request != _request) return;
      state = RescueDealsState(
        items: previous,
        error: RescueDealsRepository.errorMessage(error, 'rescue.loadError'.tr),
      );
    }
  }

  void receive(RescueDeal deal) {
    if (deal.restaurantId != ref.read(selectedRestaurantIdProvider)) return;
    _request++;
    state = RescueDealsState(
      items: [deal, ...state.items.where((d) => d.id != deal.id)],
    );
  }
}

final rescueDealsProvider =
    NotifierProvider<RescueDealsNotifier, RescueDealsState>(
      RescueDealsNotifier.new,
    );
