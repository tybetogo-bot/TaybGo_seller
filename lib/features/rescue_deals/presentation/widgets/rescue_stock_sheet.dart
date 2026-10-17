import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/i18n/i18n.dart';
import '../../../../core/services/session_lifecycle.dart';
import '../../../restaurant/application/restaurant_state.dart';
import 'rescue_widgets.dart';
import '../../application/rescue_deals_notifier.dart';
import '../../data/models/rescue_deal.dart';
import '../../data/repositories/rescue_deals_repository.dart';

class RescueStockSheet extends ConsumerStatefulWidget {
  const RescueStockSheet({
    super.key,
    required this.deal,
    required this.isCurrent,
  });
  final RescueDeal deal;
  final bool Function() isCurrent;
  @override
  ConsumerState<RescueStockSheet> createState() => _RescueStockSheetState();
}

class _RescueStockSheetState extends ConsumerState<RescueStockSheet> {
  final _quantity = TextEditingController();
  bool _remove = false, _saving = false;
  PendingStockAdjustment? _pending;
  String? _error;
  @override
  void initState() {
    super.initState();
    _pending = ref.read(rescueDealsRepositoryProvider).pending(widget.deal);
    if (_pending != null) {
      _quantity.text = '${_pending!.delta.abs()}';
      _remove = _pending!.delta < 0;
    }
  }

  @override
  void dispose() {
    _quantity.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !widget.isCurrent()) return;
    final count = int.tryParse(_quantity.text);
    if (count == null ||
        count <= 0 ||
        count > 2147483647 ||
        (_pending == null &&
            _remove &&
            (count > widget.deal.remainingQty ||
                widget.deal.maxQty - count < 1))) {
      setState(() => _error = 'rescue.invalidAdjustment'.tr);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final updated = await ref
          .read(rescueDealsRepositoryProvider)
          .adjustStock(
            widget.deal,
            _remove ? -count : count,
            isCurrent: widget.isCurrent,
          );
      if (!mounted) return;
      setState(() => _saving = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pop(context, widget.isCurrent() ? updated : null);
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _pending = ref.read(rescueDealsRepositoryProvider).pending(widget.deal);
        _error = _pending != null
            ? 'rescue.stockUnconfirmed'.tr
            : RescueDealsRepository.errorMessage(
                error,
                'rescue.actionError'.tr,
              );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(sessionGenerationProvider);
    ref.watch(selectedRestaurantIdProvider);
    if (!widget.isCurrent()) {
      return RescueMessage(
        title: 'rescue.sessionChanged'.tr,
        body: 'rescue.returnToDeals'.tr,
        action: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('common.close'.tr),
        ),
      );
    }
    final theme = Theme.of(context);
    final count = int.tryParse(_quantity.text) ?? 0;
    final result = widget.deal.remainingQty + (_remove ? -count : count);
    return PopScope(
      canPop: !_saving,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            4,
            24,
            MediaQuery.viewInsetsOf(context).bottom + 24,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'rescue.adjustStock'.tr,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.deal.itemName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 22),
                if (_pending != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'rescue.stockUnconfirmed'.tr,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                    ),
                  ),
                SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(
                      value: false,
                      icon: const Icon(Icons.add),
                      label: Text('rescue.addPortions'.tr),
                    ),
                    ButtonSegment(
                      value: true,
                      icon: const Icon(Icons.remove),
                      label: Text('rescue.removePortions'.tr),
                    ),
                  ],
                  selected: {_remove},
                  onSelectionChanged: _saving || _pending != null
                      ? null
                      : (values) => setState(() {
                          _remove = values.single;
                          _error = null;
                        }),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _quantity,
                  enabled: !_saving && _pending == null,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    TextInputFormatter.withFunction(
                      (oldValue, newValue) =>
                          newValue.copyWith(text: rescueDigits(newValue.text)),
                    ),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (_) => setState(() => _error = null),
                  decoration: InputDecoration(
                    labelText: 'rescue.quantity'.tr,
                    errorText: _error,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _pending == null
                      ? 'rescue.stockResult'.trParams({
                          'count': '${result < 0 ? 0 : result}',
                        })
                      : 'rescue.retrySameUpdate'.tr,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving || !widget.isCurrent() ? null : _save,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: Text(
                    (_saving
                            ? 'rescue.saving'
                            : _pending != null
                            ? 'rescue.retryStock'
                            : 'rescue.confirmStock')
                        .tr,
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: TextButton(
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    child: Text('common.cancel'.tr),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
