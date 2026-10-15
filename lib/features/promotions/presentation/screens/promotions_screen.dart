import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/routes.dart';
import '../../../../core/i18n/i18n.dart';
import '../../../../core/services/session_lifecycle.dart';
import '../../../restaurant/application/restaurant_state.dart';
import '../../application/promos_notifier.dart';
import '../../data/models/promo_banner.dart';
import '../widgets/promo_card.dart';

class PromotionsScreen extends ConsumerStatefulWidget {
  const PromotionsScreen({super.key});
  @override
  ConsumerState<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends ConsumerState<PromotionsScreen> {
  PromoDisplayStatus? _filter;
  bool _current(int generation, String restaurantId) =>
      mounted &&
      SessionLifecycle.instance.isAuthenticated(generation) &&
      ref.read(selectedRestaurantIdProvider) == restaurantId;

  Future<void> _delete(PromoBanner promo) async {
    final generation = SessionLifecycle.instance.generation;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('promotions.deleteTitle'.tr),
        content: Text('promotions.deleteBody'.trParams({'title': promo.title})),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('common.cancel'.tr),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('common.delete'.tr),
          ),
        ],
      ),
    );
    if (confirmed != true || !_current(generation, promo.restaurantId)) return;
    await _change(promo, delete: true);
  }

  Future<void> _change(PromoBanner promo, {bool delete = false}) async {
    final generation = SessionLifecycle.instance.generation;
    final error = await ref
        .read(promosProvider.notifier)
        .change(promo, delete: delete, active: !promo.isActive);
    if (!mounted || !_current(generation, promo.restaurantId)) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error ??
              (delete
                      ? 'promotions.deleted'
                      : promo.isActive
                      ? 'promotions.pausedSuccess'
                      : 'promotions.publishedSuccess')
                  .tr,
        ),
      ),
    );
  }

  void _edit(PromoBanner? promo) => context.push(
    promo == null ? Routes.addPromotion : Routes.editPromotionPath(promo.id),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final restaurant = ref.watch(selectedRestaurantProvider);
    final state = ref.watch(promosProvider);
    final items = state.items
        .where((item) => _filter == null || item.displayStatus == _filter)
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text('promotions.title'.tr),
        actions: [
          IconButton(
            tooltip: 'promotions.refresh'.tr,
            onPressed: state.loading
                ? null
                : () => ref.read(promosProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(promosProvider.notifier).refresh(),
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1056),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: .06,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.campaign_outlined,
                                  color: theme.colorScheme.primary,
                                  size: 24,
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    restaurant?.name ??
                                        'promotions.noRestaurant'.tr,
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'promotions.heading'.tr,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'promotions.intro'.tr,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.6,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 18),
                            FilledButton.icon(
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(0, 44),
                              ),
                              onPressed: restaurant == null
                                  ? null
                                  : () => _edit(null),
                              icon: const Icon(Icons.add_rounded),
                              label: Text('promotions.create'.tr),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'promotions.yourPromotions'.tr,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          DropdownButton<PromoDisplayStatus?>(
                            value: _filter,
                            underline: const SizedBox.shrink(),
                            items: [
                              DropdownMenuItem<PromoDisplayStatus?>(
                                value: null,
                                child: Text('promotions.all'.tr),
                              ),
                              for (final status in PromoDisplayStatus.values)
                                DropdownMenuItem(
                                  value: status,
                                  child: Text(promoStatusLabel(status)),
                                ),
                            ],
                            onChanged: (value) =>
                                setState(() => _filter = value),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (state.loading && state.items.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(48),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (restaurant == null)
                        _message(
                          Icons.storefront_outlined,
                          'promotions.noRestaurant'.tr,
                          'promotions.selectRestaurant'.tr,
                        )
                      else ...[
                        if (state.error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.error!,
                                  style: TextStyle(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () => ref
                                      .read(promosProvider.notifier)
                                      .refresh(),
                                  icon: const Icon(Icons.refresh),
                                  label: Text('common.retry'.tr),
                                ),
                              ],
                            ),
                          ),
                        if (items.isEmpty && state.error == null)
                          _message(
                            Icons.photo_library_outlined,
                            (_filter == null
                                    ? 'promotions.emptyTitle'
                                    : 'promotions.filterEmptyTitle')
                                .tr,
                            (_filter == null
                                    ? 'promotions.emptyBody'
                                    : 'promotions.filterEmptyBody')
                                .tr,
                          ),
                        LayoutBuilder(
                          builder: (context, layout) {
                            final columns = layout.maxWidth >= 820
                                ? 3
                                : layout.maxWidth >= 600
                                ? 2
                                : 1;
                            final width =
                                (layout.maxWidth - (columns - 1) * 16) /
                                columns;
                            return Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                for (final promo in items)
                                  SizedBox(
                                    width: width,
                                    child: PromoCard(
                                      key: ValueKey(promo.id),
                                      promo: promo,
                                      busy: state.busy.contains(promo.id),
                                      onEdit: () => _edit(promo),
                                      onToggle: () => _change(promo),
                                      onDelete: () => _delete(promo),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        if (state.nextPage != null)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: OutlinedButton(
                                onPressed: state.loadingMore
                                    ? null
                                    : () => ref
                                          .read(promosProvider.notifier)
                                          .refresh(more: true),
                                child: Text(
                                  (state.loadingMore
                                          ? 'common.loading'
                                          : 'promotions.loadMore')
                                      .tr,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _message(IconData icon, String title, String body) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Theme.of(context).colorScheme.outline.withValues(alpha: .14),
      ),
    ),
    child: Column(
      children: [
        Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          body,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
        ),
      ],
    ),
  );
}
