import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/routes.dart';
import '../../../../core/i18n/i18n.dart';
import '../../../../core/services/session_lifecycle.dart';
import '../../../restaurant/application/restaurant_state.dart';
import '../../application/rescue_deals_notifier.dart';
import '../../data/models/rescue_deal.dart';
import '../../data/repositories/rescue_deals_repository.dart';
import '../widgets/rescue_widgets.dart';
import '../widgets/rescue_stock_sheet.dart';

class RescueDealDetailsScreen extends ConsumerStatefulWidget {
  const RescueDealDetailsScreen({super.key, required this.dealId});
  final String dealId;
  @override
  ConsumerState<RescueDealDetailsScreen> createState() =>
      _RescueDealDetailsScreenState();
}

class _RescueDealDetailsScreenState
    extends ConsumerState<RescueDealDetailsScreen> {
  late final int _generation;
  String? _restaurantId;
  RescueDeal? _deal;
  String? _error;
  bool _loading = true, _busy = false;
  int _request = 0;
  Timer? _timer;
  bool get _current =>
      mounted &&
      SessionLifecycle.instance.isAuthenticated(_generation) &&
      _restaurantId != null &&
      ref.read(selectedRestaurantIdProvider) == _restaurantId;
  @override
  void initState() {
    super.initState();
    _generation = SessionLifecycle.instance.generation;
    _restaurantId = ref.read(selectedRestaurantIdProvider);
    Future.microtask(_load);
    _timer = Timer.periodic(const Duration(seconds: 45), (_) {
      if (_current &&
          !_busy &&
          !_loading &&
          WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed &&
          ModalRoute.of(context)?.isCurrent == true) {
        _load();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    if (!_current) return;
    final request = ++_request;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final deal = await ref
          .read(rescueDealsRepositoryProvider)
          .detail(widget.dealId);
      if (!_current || request != _request) return;
      if (deal.restaurantId != _restaurantId) {
        setState(() {
          _deal = null;
          _loading = false;
          _error = 'rescue.wrongRestaurant'.tr;
        });
        return;
      }
      setState(() {
        _deal = deal;
        _loading = false;
      });
    } catch (error) {
      if (_current && request == _request) {
        setState(() {
          _loading = false;
          _error = RescueDealsRepository.errorMessage(
            error,
            'rescue.loadError'.tr,
          );
        });
      }
    }
  }

  void _receive(RescueDeal deal) {
    if (!_current || deal.restaurantId != _restaurantId) return;
    _request++;
    setState(() {
      _deal = deal;
      _loading = false;
      _error = null;
    });
    ref.read(rescueDealsProvider.notifier).receive(deal);
  }

  Future<void> _toggle() async {
    final deal = _deal;
    if (!_current || _busy || deal == null || deal.archived) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final updated = await ref
          .read(rescueDealsRepositoryProvider)
          .setActive(deal.id, !deal.isActive);
      _receive(updated);
    } catch (error) {
      if (_current) {
        setState(
          () => _error = RescueDealsRepository.errorMessage(
            error,
            'rescue.actionError'.tr,
          ),
        );
      }
    } finally {
      if (_current) setState(() => _busy = false);
    }
  }

  Future<void> _stock() async {
    final deal = _deal;
    if (!_current || _busy || deal == null) return;
    setState(() => _busy = true);
    final updated = await showModalBottomSheet<RescueDeal>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      showDragHandle: true,
      builder: (_) => RescueStockSheet(deal: deal, isCurrent: () => _current),
    );
    if (!_current) return;
    if (updated != null) _receive(updated);
    setState(() => _busy = false);
  }

  Future<void> _archive() async {
    final deal = _deal;
    if (!_current || _busy || deal == null || deal.archived) return;
    if (!deal.supportsSafeManagement) return;
    if (ref.read(rescueDealsRepositoryProvider).pending(deal) != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('rescue.finishStockFirst'.tr)));
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('rescue.archiveTitle'.tr),
        content: Text('rescue.archiveBody'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('common.cancel'.tr),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('rescue.archive'.tr),
          ),
        ],
      ),
    );
    if (confirmed != true || !_current) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(rescueDealsRepositoryProvider).archive(deal.id);
      if (!_current) return;
      await ref.read(rescueDealsProvider.notifier).refresh();
      if (_current) await _load();
    } catch (error) {
      if (_current) {
        setState(
          () => _error = RescueDealsRepository.errorMessage(
            error,
            'rescue.actionError'.tr,
          ),
        );
      }
    } finally {
      if (_current) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(sessionGenerationProvider);
    ref.watch(selectedRestaurantIdProvider);
    final repository = ref.watch(rescueDealsRepositoryProvider);
    final theme = Theme.of(context);
    final deal = _deal;
    final pending = deal == null ? null : repository.pending(deal);
    return Scaffold(
      appBar: AppBar(
        title: Text('rescue.details'.tr),
        actions: [
          IconButton(
            onPressed: !_current || _busy || _loading ? null : _load,
            tooltip: 'rescue.refresh'.tr,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: !_current
          ? RescueMessage(
              title: 'rescue.sessionChanged'.tr,
              body: 'rescue.returnToDeals'.tr,
            )
          : _loading && deal == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: RescuePanel(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _error!,
                                    style: TextStyle(
                                      color: theme.colorScheme.error,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _busy ? null : _load,
                                    child: Text('common.retry'.tr),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (_loading || _busy)
                          const LinearProgressIndicator(minHeight: 2),
                        if (deal != null) ...[
                          RescuePanel(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RescueThumbnail(
                                      url: deal.imageUrl,
                                      size: 88,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          RescueStatusBadge(
                                            deal.statusAt(DateTime.now()),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            deal.itemName.isEmpty
                                                ? 'rescue.menuItem'.tr
                                                : deal.itemName,
                                            style: theme.textTheme.titleLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                RescuePrices(
                                  originalCents: deal.originalCents,
                                  dealCents: deal.dealCents,
                                  large: true,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'rescue.customerSaves'.trParams({
                                    'amount': rescuePrice(
                                      deal.originalCents - deal.dealCents,
                                    ),
                                    'percent': '${deal.discountPercent}',
                                  }),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          RescuePanel(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'rescue.portions'.tr,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (final entry in [
                                      (deal.remainingQty, 'rescue.available'),
                                      (deal.reservedQty, 'rescue.reserved'),
                                      (deal.soldQty, 'rescue.sold'),
                                    ])
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              entry.$1?.toString() ?? '—',
                                              style: theme
                                                  .textTheme
                                                  .headlineSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              entry.$2.tr,
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: theme
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'rescue.allocated'.trParams({
                                    'count': '${deal.maxQty}',
                                  }),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                if (!deal.archived || pending != null) ...[
                                  const SizedBox(height: 16),
                                  OutlinedButton.icon(
                                    onPressed: _busy ? null : _stock,
                                    icon: Icon(
                                      pending == null
                                          ? Icons.add_rounded
                                          : Icons.sync_rounded,
                                    ),
                                    label: Text(
                                      (pending == null
                                              ? 'rescue.adjustStock'
                                              : 'rescue.retryStock')
                                          .tr,
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(
                                        double.infinity,
                                        46,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          RescuePanel(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _detailRow(
                                  context,
                                  Icons.play_circle_outline,
                                  'rescue.starts'.tr,
                                  rescueWhen(context, deal.startsAt),
                                ),
                                const SizedBox(height: 20),
                                _detailRow(
                                  context,
                                  Icons.schedule_outlined,
                                  'rescue.ends'.tr,
                                  rescueWhen(context, deal.endsAt),
                                ),
                                const SizedBox(height: 20),
                                _detailRow(
                                  context,
                                  Icons.person_outline,
                                  'rescue.customerLimit'.tr,
                                  deal.maxPerCustomer == null
                                      ? 'rescue.noLimit'.tr
                                      : 'rescue.limitValue'.trParams({
                                          'count': '${deal.maxPerCustomer}',
                                        }),
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  'rescue.localTime'.trParams({
                                    'zone': rescueTimeZone(DateTime.now()),
                                  }),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!deal.supportsSafeManagement)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Text(
                                'rescue.managementUpdating'.tr,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          if (!deal.archived) ...[
                            const SizedBox(height: 20),
                            if (deal.statusAt(DateTime.now()) !=
                                RescueStatus.ended)
                              FilledButton.icon(
                                onPressed: _busy ? null : _toggle,
                                icon: Icon(
                                  deal.isActive
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                ),
                                label: Text(
                                  (deal.isActive
                                          ? 'rescue.pause'
                                          : 'rescue.resume')
                                      .tr,
                                ),
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 48),
                                ),
                              ),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: _busy
                                  ? null
                                  : () async {
                                      await context.push(
                                        Routes.editRescueDealPath(deal.id),
                                      );
                                      if (_current) _load();
                                    },
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              label: Text('rescue.editTiming'.tr),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 46),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: TextButton.icon(
                                onPressed: _busy || !deal.supportsSafeManagement
                                    ? null
                                    : _archive,
                                icon: const Icon(
                                  Icons.archive_outlined,
                                  size: 18,
                                ),
                                label: Text('rescue.archive'.tr),
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _detailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(
        icon,
        size: 20,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    ],
  );
}
