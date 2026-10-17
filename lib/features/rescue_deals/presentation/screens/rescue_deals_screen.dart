import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/routes.dart';
import '../../../../core/i18n/i18n.dart';
import '../../../restaurant/application/restaurant_state.dart';
import '../../application/rescue_deals_notifier.dart';
import '../../data/models/rescue_deal.dart';
import '../widgets/rescue_widgets.dart';

class RescueDealsScreen extends ConsumerStatefulWidget {
  const RescueDealsScreen({super.key});
  @override
  ConsumerState<RescueDealsScreen> createState() => _RescueDealsScreenState();
}

class _RescueDealsScreenState extends ConsumerState<RescueDealsScreen>
    with WidgetsBindingObserver {
  RescueStatus? _filter;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(seconds: 45), (_) {
      if (mounted &&
          WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed &&
          ModalRoute.of(context)?.isCurrent == true &&
          !ref.read(rescueDealsProvider).loading) {
        ref.read(rescueDealsProvider.notifier).refresh();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        mounted &&
        ModalRoute.of(context)?.isCurrent == true) {
      ref.read(rescueDealsProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final restaurant = ref.watch(selectedRestaurantProvider);
    final state = ref.watch(rescueDealsProvider);
    final items = state.items
        .where((d) => _filter == null || d.statusAt(DateTime.now()) == _filter)
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text('rescue.title'.tr),
        actions: [
          IconButton(
            tooltip: 'rescue.refresh'.tr,
            onPressed: state.loading
                ? null
                : () => ref.read(rescueDealsProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(rescueDealsProvider.notifier).refresh(),
        child: LayoutBuilder(
          builder: (context, viewport) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1040),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: .045,
                          ),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.eco_outlined,
                                  color: theme.colorScheme.primary,
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    restaurant?.name ??
                                        'rescue.noRestaurant'.tr,
                                    style: theme.textTheme.labelLarge,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'rescue.heading'.tr,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -.6,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 560),
                              child: Text(
                                'rescue.intro'.tr,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  height: 1.6,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            FilledButton.icon(
                              onPressed: restaurant == null
                                  ? null
                                  : () => context.push(Routes.addRescueDeal),
                              icon: const Icon(Icons.add_rounded, size: 20),
                              label: Text('rescue.create'.tr),
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(0, 46),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'rescue.yourDeals'.tr,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          DropdownButton<RescueStatus?>(
                            value: _filter,
                            underline: const SizedBox.shrink(),
                            borderRadius: BorderRadius.circular(14),
                            items: [
                              DropdownMenuItem<RescueStatus?>(
                                value: null,
                                child: Text('rescue.all'.tr),
                              ),
                              for (final status in RescueStatus.values)
                                DropdownMenuItem(
                                  value: status,
                                  child: Text(rescueStatusLabel(status)),
                                ),
                            ],
                            onChanged: (value) =>
                                setState(() => _filter = value),
                          ),
                        ],
                      ),
                      if (state.loading && state.items.isNotEmpty)
                        const LinearProgressIndicator(minHeight: 2),
                      const SizedBox(height: 10),
                      if (restaurant == null)
                        RescueMessage(
                          title: 'rescue.noRestaurant'.tr,
                          body: 'rescue.selectRestaurant'.tr,
                          icon: Icons.storefront_outlined,
                        )
                      else if (state.loading && state.items.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(50),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else ...[
                        if (state.error != null)
                          RescuePanel(
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
                                      .read(rescueDealsProvider.notifier)
                                      .refresh(),
                                  icon: const Icon(Icons.refresh),
                                  label: Text('common.retry'.tr),
                                ),
                              ],
                            ),
                          ),
                        if (items.isEmpty && state.error == null)
                          RescueMessage(
                            title:
                                (_filter == null
                                        ? 'rescue.emptyTitle'
                                        : 'rescue.filteredEmpty')
                                    .tr,
                            body:
                                (_filter == null
                                        ? 'rescue.emptyBody'
                                        : 'rescue.filteredBody')
                                    .tr,
                          ),
                        LayoutBuilder(
                          builder: (context, layout) {
                            final columns = layout.maxWidth >= 720 ? 2 : 1;
                            final width =
                                (layout.maxWidth - (columns - 1) * 16) /
                                columns;
                            return Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                for (final deal in items)
                                  SizedBox(
                                    width: width,
                                    child: RescueDealCard(
                                      deal: deal,
                                      onTap: () => context.push(
                                        Routes.rescueDealPath(deal.id),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
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
}
