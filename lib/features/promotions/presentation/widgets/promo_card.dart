import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/i18n/i18n.dart';
import '../../data/models/promo_banner.dart';

String promoStatusLabel(PromoDisplayStatus status) =>
    'promotions.${status.name}'.tr;

class PromoStatusBadge extends StatelessWidget {
  const PromoStatusBadge({super.key, required this.status});
  final PromoDisplayStatus status;
  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      PromoDisplayStatus.live => const Color(0xFF16834B),
      PromoDisplayStatus.paused => const Color(0xFF617084),
      PromoDisplayStatus.pending => const Color(0xFFB26A00),
      PromoDisplayStatus.rejected => const Color(0xFFCF3545),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: .25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            switch (status) {
              PromoDisplayStatus.live => Icons.check_circle_outline_rounded,
              PromoDisplayStatus.paused => Icons.pause_circle_outline_rounded,
              PromoDisplayStatus.pending => Icons.schedule_rounded,
              PromoDisplayStatus.rejected => Icons.info_outline_rounded,
            },
            size: 14,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            promoStatusLabel(status),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class PromoCard extends StatelessWidget {
  const PromoCard({
    super.key,
    required this.promo,
    required this.busy,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });
  final PromoBanner promo;
  final bool busy;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: .14),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 7,
                child: CachedNetworkImage(
                  imageUrl: promo.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => ColoredBox(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Center(
                      child: Icon(Icons.image_outlined, size: 32),
                    ),
                  ),
                  errorWidget: (_, _, _) => ColoredBox(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Center(
                      child: Text('promotions.imageUnavailable'.tr),
                    ),
                  ),
                ),
              ),
              PositionedDirectional(
                top: 12,
                start: 12,
                child: PromoStatusBadge(status: promo.displayStatus),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  promo.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (promo.description.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    promo.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  'promotions.${promo.displayStatus.name}Hint'.tr,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                if (promo.status == PromoStatus.rejected &&
                    promo.rejectionReason?.isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withValues(alpha: .06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'promotions.reviewFeedback'.tr,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          promo.rejectionReason!,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: promo.canPublish
                          ? (promo.isActive
                                ? OutlinedButton.icon(
                                    onPressed: busy ? null : onToggle,
                                    icon: const Icon(
                                      Icons.pause_rounded,
                                      size: 18,
                                    ),
                                    label: Text('promotions.pause'.tr),
                                  )
                                : FilledButton.icon(
                                    onPressed: busy ? null : onToggle,
                                    icon: const Icon(
                                      Icons.publish_rounded,
                                      size: 18,
                                    ),
                                    label: Text('promotions.publish'.tr),
                                  ))
                          : OutlinedButton.icon(
                              onPressed: busy ? null : onEdit,
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              label: Text('promotions.edit'.tr),
                            ),
                    ),
                    if (promo.canPublish) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: busy ? null : onEdit,
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        tooltip: 'promotions.edit'.tr,
                      ),
                    ],
                    if (busy)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else
                      PopupMenuButton<String>(
                        tooltip: 'promotions.more'.tr,
                        onSelected: (_) => onDelete(),
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              'common.delete'.tr,
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                          ),
                        ],
                        icon: const Icon(Icons.more_horiz_rounded),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
