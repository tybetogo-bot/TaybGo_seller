import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/routes.dart';
import '../../../../core/i18n/i18n.dart';
import '../../../../core/services/session_lifecycle.dart';
import '../../../menu/data/models/menu_item_model.dart';
import '../../../restaurant/application/restaurant_state.dart';
import '../../application/rescue_deals_notifier.dart';
import '../../data/models/rescue_deal.dart';
import '../../data/repositories/rescue_deals_repository.dart';
import '../widgets/rescue_widgets.dart';

class RescueDealEditorScreen extends ConsumerStatefulWidget {
  const RescueDealEditorScreen({super.key, this.dealId});
  final String? dealId;
  @override
  ConsumerState<RescueDealEditorScreen> createState() =>
      _RescueDealEditorScreenState();
}

class _RescueDealEditorScreenState
    extends ConsumerState<RescueDealEditorScreen> {
  final _form = GlobalKey<FormState>();
  final _price = TextEditingController(),
      _quantity = TextEditingController(),
      _limit = TextEditingController(text: '2');
  late final int _generation;
  String? _restaurantId;
  List<MenuItemModel> _items = [];
  MenuItemModel? _item;
  RescueDeal? _original;
  late DateTime _starts, _ends;
  bool _scheduled = false,
      _limited = false,
      _loading = true,
      _saving = false,
      _loaded = false,
      _dirty = false,
      _allowPop = false;
  String? _error;
  Map<String, String> _fields = {};
  bool get _current =>
      mounted &&
      SessionLifecycle.instance.isAuthenticated(_generation) &&
      _restaurantId != null &&
      ref.read(selectedRestaurantIdProvider) == _restaurantId;
  int get _originalCents =>
      _original?.originalCents ?? ((_item?.price ?? 0) * 100).round();
  String get _itemName =>
      _original?.itemName ??
      _item?.getLocalizedName(TranslationService.instance.currentLanguage) ??
      '';
  String? get _imageUrl => _original?.imageUrl ?? _item?.imageUrl;
  @override
  void initState() {
    super.initState();
    _generation = SessionLifecycle.instance.generation;
    _restaurantId = ref.read(selectedRestaurantIdProvider);
    _starts = DateTime.now();
    _ends = DateTime(_starts.year, _starts.month, _starts.day, 21);
    if (!_ends.isAfter(_starts.add(const Duration(minutes: 30)))) {
      _ends = _starts.add(const Duration(hours: 2));
    }
    Future.microtask(_load);
  }

  @override
  void dispose() {
    _price.dispose();
    _quantity.dispose();
    _limit.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!_current) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repository = ref.read(rescueDealsRepositoryProvider);
      if (widget.dealId == null) {
        final items = await repository.catalog(_restaurantId!);
        if (!_current) return;
        setState(() {
          _items = items
              .where((item) => item.isAvailable && item.price > 0)
              .toList();
          _loaded = true;
          _loading = false;
        });
      } else {
        final deal = await repository.detail(widget.dealId!);
        if (!_current) return;
        if (deal.restaurantId != _restaurantId || deal.archived) {
          setState(() {
            _error = 'rescue.uneditable'.tr;
            _loading = false;
          });
          return;
        }
        setState(() {
          _original = deal;
          _starts = deal.startsAt.toLocal();
          _ends = deal.endsAt.toLocal();
          _scheduled = _starts.isAfter(DateTime.now());
          _limited = deal.maxPerCustomer != null;
          _price.text = rescueDecimal(deal.dealCents);
          _quantity.text = '${deal.maxQty}';
          _limit.text = '${deal.maxPerCustomer ?? 2}';
          _loaded = true;
          _loading = false;
        });
      }
    } catch (error) {
      if (_current) {
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

  void _change([String? _]) {
    setState(() {
      _dirty = true;
      _fields = {};
      _error = null;
    });
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.rescueDeals);
    }
  }

  Future<void> _leave() async {
    if (_saving) return;
    if (_dirty && _current) {
      final discard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('rescue.discardTitle'.tr),
          content: Text('rescue.discardBody'.tr),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('rescue.keepEditing'.tr),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('rescue.discard'.tr),
            ),
          ],
        ),
      );
      if (discard != true || !mounted) return;
    }
    if (!mounted) return;
    setState(() {
      _allowPop = true;
      _dirty = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _back();
    });
  }

  Future<void> _pickItem() async {
    final choice = await showModalBottomSheet<MenuItemModel>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) =>
          _MenuPicker(items: _items, isCurrent: () => _current),
    );
    if (!_current || choice == null) return;
    setState(() {
      _item = choice;
      _dirty = true;
      _fields = {};
      _error = null;
    });
  }

  Future<void> _pickDate(bool start) async {
    final previous = start ? _starts : _ends;
    final date = await showDatePicker(
      context: context,
      initialDate: previous,
      firstDate: DateTime(2020),
      lastDate: DateTime(DateTime.now().year + 2),
    );
    if (!mounted || !_current || date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(previous),
    );
    if (!_current || time == null) return;
    final instant = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() {
      if (start) {
        _starts = instant;
      } else {
        _ends = instant;
      }
      _dirty = true;
      _fields = {};
      _error = null;
    });
  }

  Future<void> _save() async {
    if (!_current || !_loaded || _saving || !_form.currentState!.validate()) {
      return;
    }
    final start = _original != null || _scheduled ? _starts : DateTime.now();
    if (!_ends.isAfter(start) || !_ends.isAfter(DateTime.now())) {
      setState(() => _fields = {'ends_at': 'rescue.invalidEnd'.tr});
      return;
    }
    if (_original == null && _item == null) {
      setState(() => _fields = {'item_id': 'rescue.selectItemError'.tr});
      return;
    }
    final price = rescueMoneyCents(_price.text)!;
    final data = <String, dynamic>{
      'ends_at': _ends.toUtc().toIso8601String(),
      'max_per_customer': _limited ? int.parse(_limit.text) : null,
      if (_original == null) ...{
        'restaurant_id': int.parse(_restaurantId!),
        'item_id': int.parse(_item!.id),
        'deal_price': rescueDecimal(price),
        'max_qty': int.parse(_quantity.text),
        'starts_at': start.toUtc().toIso8601String(),
        'is_active': true,
      } else if (_scheduled)
        'starts_at': _starts.toUtc().toIso8601String(),
    };
    setState(() {
      _saving = true;
      _error = null;
      _fields = {};
    });
    try {
      final saved = await ref
          .read(rescueDealsRepositoryProvider)
          .save(data, id: widget.dealId);
      if (!_current) return;
      if (saved.restaurantId != _restaurantId) {
        throw StateError('Unexpected restaurant');
      }
      ref.read(rescueDealsProvider.notifier).receive(saved);
      setState(() {
        _saving = false;
        _dirty = false;
        _allowPop = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_current) return;
        if (_original == null) {
          context.replace(Routes.rescueDealPath(saved.id));
        } else {
          _back();
        }
      });
    } catch (error) {
      if (_current) {
        setState(() {
          _saving = false;
          _fields = RescueDealsRepository.fieldErrors(error);
          _error = _fields.isEmpty
              ? RescueDealsRepository.errorMessage(error, 'rescue.saveError'.tr)
              : null;
          if (_fields.keys.any(
            (key) => !{
              'deal_price',
              'max_qty',
              'max_per_customer',
              'starts_at',
              'ends_at',
              'item_id',
            }.contains(key),
          )) {
            _error = _fields.values.join('\n');
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(sessionGenerationProvider);
    ref.watch(selectedRestaurantIdProvider);
    final theme = Theme.of(context);
    final editing = widget.dealId != null;
    return PopScope(
      canPop: _allowPop || (!_dirty && !_saving),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: _saving ? null : _leave,
            tooltip: 'common.back'.tr,
            icon: const BackButtonIcon(),
          ),
          title: Text((editing ? 'rescue.editTiming' : 'rescue.create').tr),
        ),
        bottomNavigationBar: !_current || !_loaded
            ? null
            : SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: .6,
                        ),
                      ),
                    ),
                  ),
                  child: Center(
                    heightFactor: 1,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: FilledButton(
                        onPressed: _saving || (editing && !_dirty)
                            ? null
                            : _save,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: Text(
                          (_saving
                                  ? 'rescue.saving'
                                  : editing
                                  ? 'common.save'
                                  : 'rescue.publish')
                              .tr,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
        body: !_current
            ? RescueMessage(
                title: 'rescue.sessionChanged'.tr,
                body: 'rescue.returnToDeals'.tr,
                action: TextButton(
                  onPressed: _leave,
                  child: Text('rescue.title'.tr),
                ),
              )
            : _loading
            ? const Center(child: CircularProgressIndicator())
            : !_loaded
            ? RescueMessage(
                title: 'rescue.loadError'.tr,
                body: _error ?? '',
                action: TextButton(
                  onPressed: _load,
                  child: Text('common.retry'.tr),
                ),
              )
            : Form(
                key: _form,
                child: SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1080),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                        child: LayoutBuilder(
                          builder: (context, layout) {
                            final content = Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_error != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Text(
                                      _error!,
                                      style: TextStyle(
                                        color: theme.colorScheme.error,
                                      ),
                                    ),
                                  ),
                                RescuePanel(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _section(
                                        context,
                                        Icons.restaurant_menu_outlined,
                                        'rescue.menuItem'.tr,
                                      ),
                                      const SizedBox(height: 18),
                                      if (_itemName.isNotEmpty)
                                        Row(
                                          children: [
                                            RescueThumbnail(
                                              url: _imageUrl,
                                              size: 60,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    _itemName,
                                                    style: theme
                                                        .textTheme
                                                        .titleMedium
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    'rescue.menuPrice'
                                                        .trParams({
                                                          'price': rescuePrice(
                                                            _originalCents,
                                                          ),
                                                        }),
                                                    style: theme
                                                        .textTheme
                                                        .bodySmall
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
                                      if (!editing) ...[
                                        if (_itemName.isNotEmpty)
                                          const SizedBox(height: 12),
                                        OutlinedButton.icon(
                                          onPressed: _saving || _items.isEmpty
                                              ? null
                                              : _pickItem,
                                          icon: Icon(
                                            _item == null
                                                ? Icons.add
                                                : Icons.swap_horiz_rounded,
                                          ),
                                          label: Text(
                                            (_item == null
                                                    ? 'rescue.chooseItem'
                                                    : 'rescue.changeItem')
                                                .tr,
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            minimumSize: const Size(
                                              double.infinity,
                                              46,
                                            ),
                                          ),
                                        ),
                                        if (_items.isEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 8,
                                            ),
                                            child: Text('rescue.noItems'.tr),
                                          ),
                                        if (_fields['item_id'] != null)
                                          Text(
                                            _fields['item_id']!,
                                            style: TextStyle(
                                              color: theme.colorScheme.error,
                                            ),
                                          ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                RescuePanel(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _section(
                                        context,
                                        Icons.local_offer_outlined,
                                        'rescue.offerDetails'.tr,
                                      ),
                                      const SizedBox(height: 20),
                                      TextFormField(
                                        key: const ValueKey('rescue-price'),
                                        controller: _price,
                                        enabled: !_saving && !editing,
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        onChanged: _change,
                                        decoration: InputDecoration(
                                          labelText: 'rescue.dealPrice'.tr,
                                          prefixText: '€ ',
                                          hintText: '6.00',
                                          errorText: _fields['deal_price'],
                                          border: const OutlineInputBorder(),
                                        ),
                                        validator: (value) {
                                          final cents = rescueMoneyCents(
                                            value ?? '',
                                          );
                                          if (cents == null ||
                                              cents <= 0 ||
                                              cents >= _originalCents) {
                                            return 'rescue.invalidPrice'.tr;
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      if (!editing)
                                        TextFormField(
                                          key: const ValueKey(
                                            'rescue-quantity',
                                          ),
                                          controller: _quantity,
                                          enabled: !_saving,
                                          onChanged: _change,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            TextInputFormatter.withFunction(
                                              (oldValue, newValue) =>
                                                  newValue.copyWith(
                                                    text: rescueDigits(
                                                      newValue.text,
                                                    ),
                                                  ),
                                            ),
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          decoration: InputDecoration(
                                            labelText: 'rescue.quantity'.tr,
                                            helperText:
                                                'rescue.quantityHint'.tr,
                                            errorText: _fields['max_qty'],
                                            border: const OutlineInputBorder(),
                                          ),
                                          validator: (value) {
                                            final count = int.tryParse(
                                              value ?? '',
                                            );
                                            return count == null ||
                                                    count < 1 ||
                                                    count > 2147483647
                                                ? 'rescue.invalidQuantity'.tr
                                                : null;
                                          },
                                        )
                                      else
                                        Text(
                                          'rescue.fixedPriceHint'.tr,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                                height: 1.5,
                                              ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                RescuePanel(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _section(
                                        context,
                                        Icons.schedule_outlined,
                                        'rescue.availability'.tr,
                                      ),
                                      const SizedBox(height: 12),
                                      if (!editing)
                                        SwitchListTile.adaptive(
                                          contentPadding: EdgeInsets.zero,
                                          title: Text('rescue.schedule'.tr),
                                          subtitle: Text(
                                            'rescue.scheduleHint'.tr,
                                          ),
                                          value: _scheduled,
                                          onChanged: _saving
                                              ? null
                                              : (value) {
                                                  setState(() {
                                                    _scheduled = value;
                                                    if (value &&
                                                        _starts.isBefore(
                                                          DateTime.now(),
                                                        )) {
                                                      _starts = DateTime.now()
                                                          .add(
                                                            const Duration(
                                                              hours: 1,
                                                            ),
                                                          );
                                                    }
                                                  });
                                                  _change();
                                                },
                                        ),
                                      const SizedBox(height: 12),
                                      _dateTile(
                                        context,
                                        'rescue.starts'.tr,
                                        !editing && !_scheduled
                                            ? 'rescue.now'.tr
                                            : rescueWhen(context, _starts),
                                        _fields['starts_at'],
                                        !_saving && _scheduled
                                            ? () => _pickDate(true)
                                            : null,
                                      ),
                                      const SizedBox(height: 12),
                                      _dateTile(
                                        context,
                                        'rescue.ends'.tr,
                                        rescueWhen(context, _ends),
                                        _fields['ends_at'],
                                        _saving ? null : () => _pickDate(false),
                                      ),
                                      const SizedBox(height: 14),
                                      Text(
                                        'rescue.localTime'.trParams({
                                          'zone': rescueTimeZone(_ends),
                                        }),
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
                                const SizedBox(height: 16),
                                RescuePanel(
                                  child: Column(
                                    children: [
                                      SwitchListTile.adaptive(
                                        contentPadding: EdgeInsets.zero,
                                        title: Text('rescue.limitOptional'.tr),
                                        subtitle: Text('rescue.limitHint'.tr),
                                        value: _limited,
                                        onChanged: _saving
                                            ? null
                                            : (value) {
                                                setState(
                                                  () => _limited = value,
                                                );
                                                _change();
                                              },
                                      ),
                                      if (_limited) ...[
                                        const SizedBox(height: 14),
                                        TextFormField(
                                          key: const ValueKey('rescue-limit'),
                                          controller: _limit,
                                          enabled: !_saving,
                                          onChanged: _change,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            TextInputFormatter.withFunction(
                                              (oldValue, newValue) =>
                                                  newValue.copyWith(
                                                    text: rescueDigits(
                                                      newValue.text,
                                                    ),
                                                  ),
                                            ),
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          decoration: InputDecoration(
                                            labelText:
                                                'rescue.customerLimit'.tr,
                                            errorText:
                                                _fields['max_per_customer'],
                                            border: const OutlineInputBorder(),
                                          ),
                                          validator: (value) {
                                            final count = int.tryParse(
                                              value ?? '',
                                            );
                                            return count == null ||
                                                    count < 1 ||
                                                    count > 2147483647
                                                ? 'rescue.invalidQuantity'.tr
                                                : null;
                                          },
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            );
                            return layout.maxWidth >= 860
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(child: content),
                                      const SizedBox(width: 24),
                                      SizedBox(
                                        width: 300,
                                        child: _preview(context),
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      content,
                                      const SizedBox(height: 20),
                                      _preview(context),
                                    ],
                                  );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _section(BuildContext context, IconData icon, String title) => Row(
    children: [
      Icon(
        icon,
        size: 19,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    ],
  );
  Widget _dateTile(
    BuildContext context,
    String label,
    String value,
    String? error,
    VoidCallback? onTap,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.all(14),
          alignment: AlignmentDirectional.centerStart,
        ),
        child: Row(
          children: [
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
                  const SizedBox(height: 5),
                  Text(value, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            if (onTap != null) const Icon(Icons.edit_outlined, size: 17),
          ],
        ),
      ),
      if (error != null)
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            error,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12,
            ),
          ),
        ),
    ],
  );
  Widget _preview(BuildContext context) {
    final cents = rescueMoneyCents(_price.text) ?? 0;
    return RescuePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'rescue.preview'.tr,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              RescueThumbnail(url: _imageUrl, size: 60),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _itemName.isEmpty ? 'rescue.yourItem'.tr : _itemName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (cents > 0 && cents < _originalCents)
            RescuePrices(originalCents: _originalCents, dealCents: cents)
          else
            Text(
              'rescue.previewHint'.tr,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: 14),
          Text(
            'rescue.previewNote'.tr,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              height: 1.5,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuPicker extends ConsumerStatefulWidget {
  const _MenuPicker({required this.items, required this.isCurrent});
  final bool Function() isCurrent;
  final List<MenuItemModel> items;
  @override
  ConsumerState<_MenuPicker> createState() => _MenuPickerState();
}

class _MenuPickerState extends ConsumerState<_MenuPicker> {
  String _search = '';
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
    final items = widget.items
        .where(
          (item) => item
              .getLocalizedName(TranslationService.instance.currentLanguage)
              .toLowerCase()
              .contains(_search.toLowerCase()),
        )
        .toList();
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .65,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: TextField(
                  autofocus: false,
                  onChanged: (value) => setState(() => _search = value),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search_rounded),
                    hintText: 'rescue.searchItems'.tr,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 5,
                      ),
                      leading: RescueThumbnail(url: item.imageUrl, size: 48),
                      title: Text(
                        item.getLocalizedName(
                          TranslationService.instance.currentLanguage,
                        ),
                      ),
                      subtitle: Text(rescuePrice((item.price * 100).round())),
                      onTap: () => Navigator.pop(context, item),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
