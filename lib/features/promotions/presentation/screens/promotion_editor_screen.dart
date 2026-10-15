import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/routes.dart';
import '../../../../core/i18n/i18n.dart';
import '../../../../core/services/session_lifecycle.dart';
import '../../../menu/presentation/widgets/image_picker_widget.dart';
import '../../../restaurant/application/restaurant_state.dart';
import '../../application/promos_notifier.dart';
import '../../data/models/promo_banner.dart';
import '../../data/repositories/promos_repository.dart';
import '../widgets/promo_card.dart';

class PromotionEditorScreen extends ConsumerStatefulWidget {
  const PromotionEditorScreen({super.key, this.promoId});
  final String? promoId;
  @override
  ConsumerState<PromotionEditorScreen> createState() =>
      _PromotionEditorScreenState();
}

class _PromotionEditorScreenState extends ConsumerState<PromotionEditorScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  late final int _generation;
  String? _restaurantId;
  PromoBanner? _original;
  String? _imageUrl;
  String? _error;
  bool _loading = false;
  bool _saving = false;
  bool _uploading = false;
  bool _dirty = false;
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
    if (widget.promoId != null) {
      _loading = true;
      Future.microtask(_load);
    }
  }

  Future<void> _load() async {
    if (!_current) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final promo = await ref
          .read(promosRepositoryProvider)
          .detail(widget.promoId!);
      if (!_current) return;
      if (promo.restaurantId != _restaurantId) {
        setState(() {
          _loading = false;
          _error = 'promotions.wrongRestaurant'.tr;
        });
        return;
      }
      setState(() {
        _original = promo;
        _title.text = promo.title;
        _description.text = promo.description;
        _imageUrl = promo.imageUrl;
        _loading = false;
      });
    } catch (error) {
      if (_current) {
        setState(() {
          _loading = false;
          _error = PromosRepository.errorMessage(
            error,
            'promotions.loadError'.tr,
          );
        });
      }
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.promotions);
    }
  }

  Future<void> _leave() async {
    if (_saving) return;
    if (!_dirty && !_uploading) {
      _back();
      return;
    }
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('promotions.discardTitle'.tr),
        content: Text('promotions.discardBody'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('promotions.keepEditing'.tr),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('promotions.discard'.tr),
          ),
        ],
      ),
    );
    if (discard == true && mounted) {
      setState(() {
        _dirty = false;
        _uploading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _back();
      });
    }
  }

  Future<void> _save() async {
    if (!_current || _saving || _uploading || !_form.currentState!.validate()) {
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(promosRepositoryProvider)
          .save(
            id: widget.promoId,
            restaurantId: _restaurantId!,
            title: _title.text,
            description: _description.text,
            imageUrl: _imageUrl!,
          );
      if (!mounted || !_current) return;
      ref.read(promosProvider.notifier).refresh();
      setState(() {
        _dirty = false;
        _saving = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('promotions.saved'.tr)));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_current) _back();
      });
    } catch (error) {
      if (_current) {
        setState(() {
          _saving = false;
          _error = PromosRepository.errorMessage(
            error,
            'promotions.saveError'.tr,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(selectedRestaurantIdProvider);
    ref.watch(sessionGenerationProvider);
    final theme = Theme.of(context);
    final submitLabel = widget.promoId == null
        ? 'promotions.submit'
        : _original?.needsReviewOnEdit == true
        ? 'promotions.resubmit'
        : 'promotions.save';
    return PopScope(
      canPop: !_dirty && !_saving && !_uploading,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            (widget.promoId == null ? 'promotions.create' : 'promotions.edit')
                .tr,
          ),
          leading: IconButton(
            onPressed: _saving ? null : _leave,
            icon: const BackButtonIcon(),
            tooltip: 'common.back'.tr,
          ),
        ),
        bottomNavigationBar:
            !_current ||
                _loading ||
                (widget.promoId != null && _original == null)
            ? null
            : SafeArea(
                top: false,
                child: Center(
                  heightFactor: 1,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: _submitButton(submitLabel),
                      ),
                    ),
                  ),
                ),
              ),
        body: !_current
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'promotions.sessionChanged'.tr,
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: _leave,
                        child: Text('promotions.backToList'.tr),
                      ),
                    ],
                  ),
                ),
              )
            : _loading
            ? const Center(child: CircularProgressIndicator())
            : widget.promoId != null && _original == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _error ?? 'promotions.loadError'.tr,
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: _load,
                        child: Text('common.retry'.tr),
                      ),
                    ],
                  ),
                ),
              )
            : SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                      child: Form(
                        key: _form,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'promotions.editorIntro'.tr,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.6,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (_original != null) ...[
                              const SizedBox(height: 16),
                              PromoStatusBadge(
                                status: _original!.displayStatus,
                              ),
                            ],
                            if (_original?.needsReviewOnEdit == true) ...[
                              const SizedBox(height: 16),
                              _notice(
                                Icons.info_outline_rounded,
                                'promotions.reviewAgainTitle'.tr,
                                (_original!.isActive
                                        ? 'promotions.reviewAgainLive'
                                        : 'promotions.reviewAgainBody')
                                    .tr,
                              ),
                            ],
                            if (_original?.status == PromoStatus.rejected &&
                                _original?.rejectionReason?.isNotEmpty ==
                                    true) ...[
                              const SizedBox(height: 12),
                              _notice(
                                Icons.chat_bubble_outline_rounded,
                                'promotions.reviewFeedback'.tr,
                                _original!.rejectionReason!,
                              ),
                            ],
                            const SizedBox(height: 24),
                            FormField<String>(
                              validator: (_) => _imageUrl?.isNotEmpty == true
                                  ? null
                                  : 'promotions.imageRequired'.tr,
                              builder: (field) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ImagePickerWidget(
                                    initialImageUrl: _imageUrl,
                                    titleText: 'promotions.bannerImage'.tr,
                                    isRequired: true,
                                    previewAspectRatio: 16 / 7,
                                    enabled: !_saving,
                                    onImageUploaded: (url) {
                                      if (_current) {
                                        setState(() {
                                          _imageUrl = url;
                                          _dirty = true;
                                          field.didChange(url);
                                        });
                                      }
                                    },
                                    onImageRemoved: () {
                                      if (_current) {
                                        setState(() {
                                          _imageUrl = null;
                                          _dirty = true;
                                          field.didChange(null);
                                        });
                                      }
                                    },
                                    onUploadStateChanged: (uploading) {
                                      if (_current) {
                                        setState(() => _uploading = uploading);
                                      }
                                    },
                                  ),
                                  if (field.hasError)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        field.errorText!,
                                        style: TextStyle(
                                          color: theme.colorScheme.error,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'promotions.imageHint'.tr,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _title,
                              enabled: !_saving,
                              maxLength: 255,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                labelText: 'promotions.titleLabel'.tr,
                                hintText: 'promotions.titleHint'.tr,
                              ),
                              onChanged: (_) => setState(() => _dirty = true),
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                  ? 'promotions.titleRequired'.tr
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _description,
                              enabled: !_saving,
                              minLines: 3,
                              maxLines: 6,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                labelText: 'promotions.descriptionLabel'.tr,
                                hintText: 'promotions.descriptionHint'.tr,
                              ),
                              onChanged: (_) => setState(() => _dirty = true),
                            ),
                            const SizedBox(height: 24),
                            _notice(
                              Icons.fact_check_outlined,
                              'promotions.whatNext'.tr,
                              'promotions.whatNextBody'.tr,
                            ),
                            if (_error != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Text(
                                  _error!,
                                  style: TextStyle(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 24),
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

  Widget _submitButton(String submitLabel) => FilledButton.icon(
    style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
    onPressed: _saving || _uploading || (widget.promoId != null && !_dirty)
        ? null
        : _save,
    icon: _saving
        ? const SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const Icon(Icons.arrow_forward_rounded, size: 18),
    label: Text(
      (_saving
              ? 'promotions.saving'
              : _uploading
              ? 'promotions.uploading'
              : submitLabel)
          .tr,
    ),
  );

  Widget _notice(IconData icon, String title, String body) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: .05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
