import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/promos_api.dart';
import '../../../core/providers/providers.dart';
import '../../../core/services/session_lifecycle.dart';
import '../../../core/i18n/i18n.dart';
import '../../restaurant/application/restaurant_state.dart';
import '../data/models/promo_banner.dart';
import '../data/repositories/promos_repository.dart';

final promosRepositoryProvider = Provider(
  (ref) => PromosRepository(PromosApi(ref.watch(dioProvider))),
);

class PromosState {
  const PromosState({
    this.items = const [],
    this.loading = false,
    this.loadingMore = false,
    this.nextPage,
    this.error,
    this.busy = const {},
  });
  final List<PromoBanner> items;
  final bool loading;
  final bool loadingMore;
  final int? nextPage;
  final String? error;
  final Set<String> busy;
}

class PromosNotifier extends Notifier<PromosState> {
  int _request = 0;
  @override
  PromosState build() {
    ref.watch(sessionGenerationProvider);
    final restaurantId = ref.watch(selectedRestaurantIdProvider);
    final generation = SessionLifecycle.instance.generation;
    _request++;
    if (restaurantId == null ||
        !SessionLifecycle.instance.isAuthenticated(generation)) {
      return const PromosState();
    }
    Future.microtask(() {
      if (_current(generation, restaurantId)) refresh();
    });
    return const PromosState(loading: true);
  }

  bool _current(int generation, String restaurantId) =>
      ref.mounted &&
      SessionLifecycle.instance.isAuthenticated(generation) &&
      ref.read(selectedRestaurantIdProvider) == restaurantId;

  Future<void> refresh({bool more = false}) async {
    final restaurantId = ref.read(selectedRestaurantIdProvider);
    final generation = SessionLifecycle.instance.generation;
    if (restaurantId == null || !_current(generation, restaurantId)) return;
    if (more &&
        (state.loading || state.loadingMore || state.nextPage == null)) {
      return;
    }
    final page = more ? state.nextPage! : 1;
    final request = ++_request;
    final previous = state;
    state = PromosState(
      items: previous.items,
      loading: !more,
      loadingMore: more,
      nextPage: previous.nextPage,
      busy: previous.busy,
    );
    try {
      final result = await ref
          .read(promosRepositoryProvider)
          .list(restaurantId, page: page);
      if (!_current(generation, restaurantId) || request != _request) return;
      final owned = result.results
          .where((item) => item.restaurantId == restaurantId)
          .toList();
      final items = more
          ? <String, PromoBanner>{
              for (final item in [...previous.items, ...owned]) item.id: item,
            }.values.toList()
          : owned;
      final nextPage = result.next == null
          ? null
          : int.tryParse(
                  Uri.parse(result.next!).queryParameters['page'] ?? '',
                ) ??
                page + 1;
      state = PromosState(items: items, nextPage: nextPage, busy: state.busy);
    } catch (error) {
      if (!_current(generation, restaurantId) || request != _request) return;
      state = PromosState(
        items: previous.items,
        nextPage: previous.nextPage,
        busy: state.busy,
        error: PromosRepository.errorMessage(error, 'promotions.loadError'.tr),
      );
    }
  }

  Future<String?> change(
    PromoBanner promo, {
    bool? active,
    bool delete = false,
  }) async {
    final generation = SessionLifecycle.instance.generation;
    final restaurantId = promo.restaurantId;
    if (!_current(generation, restaurantId) || state.busy.contains(promo.id)) {
      return 'promotions.sessionChanged'.tr;
    }
    if (active == true && !promo.canPublish) {
      return 'promotions.awaitApproval'.tr;
    }
    state = PromosState(
      items: state.items,
      nextPage: state.nextPage,
      busy: {...state.busy, promo.id},
    );
    try {
      PromoBanner? updated;
      if (delete) {
        await ref.read(promosRepositoryProvider).delete(promo.id);
      } else {
        updated = await ref
            .read(promosRepositoryProvider)
            .setActive(promo.id, active!);
      }
      if (!_current(generation, restaurantId)) {
        return 'promotions.sessionChanged'.tr;
      }
      // Keep all loaded pages and use the server's authoritative response.
      state = PromosState(
        items: [
          for (final item in state.items)
            if (item.id != promo.id) item else if (updated != null) updated,
        ],
        nextPage: state.nextPage,
        busy: state.busy,
      );
      return null;
    } catch (error) {
      return PromosRepository.errorMessage(error, 'promotions.actionError'.tr);
    } finally {
      if (_current(generation, restaurantId)) {
        state = PromosState(
          items: state.items,
          loading: state.loading,
          loadingMore: state.loadingMore,
          nextPage: state.nextPage,
          error: state.error,
          busy: {...state.busy}..remove(promo.id),
        );
      }
    }
  }
}

final promosProvider = NotifierProvider<PromosNotifier, PromosState>(
  PromosNotifier.new,
);
