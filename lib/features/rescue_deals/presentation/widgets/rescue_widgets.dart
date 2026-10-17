import 'package:flutter/material.dart';
import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/rescue_deal.dart';

String rescueStatusLabel(RescueStatus status) =>
    'rescue.status.${status.name}'.tr;
String rescueWhen(BuildContext context, DateTime instant) {
  final local = instant.toLocal();
  final strings = MaterialLocalizations.of(context);
  return '${strings.formatShortDate(local)} · ${strings.formatTimeOfDay(TimeOfDay.fromDateTime(local), alwaysUse24HourFormat: true)}';
}

String rescueTimeZone(DateTime date) {
  final offset = date.toLocal().timeZoneOffset;
  final minutes = offset.inMinutes.abs();
  return '${date.toLocal().timeZoneName} (UTC${offset.isNegative ? '-' : '+'}${minutes ~/ 60}:${(minutes % 60).toString().padLeft(2, '0')})';
}

class RescuePanel extends StatelessWidget {
  const RescuePanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Padding(
      padding: padding,
      child: SizedBox(width: double.infinity, child: child),
    ),
  );
}

class RescueThumbnail extends StatelessWidget {
  const RescueThumbnail({super.key, this.url, this.size = 76});
  final String? url;
  final double size;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    Widget fallback() => ColoredBox(
      color: colors.surfaceContainerLow,
      child: Center(
        child: Icon(
          Icons.restaurant_outlined,
          size: size * .34,
          color: colors.onSurfaceVariant.withValues(alpha: .55),
        ),
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox.square(
        dimension: size,
        child: url == null || url!.isEmpty
            ? fallback()
            : Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => fallback(),
              ),
      ),
    );
  }
}

class RescueStatusBadge extends StatelessWidget {
  const RescueStatusBadge(this.status, {super.key});
  final RescueStatus status;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final live = status == RescueStatus.live;
    final foreground = live
        ? (Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF9BDBB6)
              : const Color(0xFF246543))
        : colors.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: live
            ? foreground.withValues(alpha: .09)
            : colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            switch (status) {
              RescueStatus.live => Icons.circle,
              RescueStatus.scheduled => Icons.schedule_outlined,
              RescueStatus.paused => Icons.pause_circle_outline,
              RescueStatus.archived => Icons.archive_outlined,
              _ => Icons.timelapse_outlined,
            },
            size: live ? 7 : 13,
            color: foreground,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              rescueStatusLabel(status),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RescuePrices extends StatelessWidget {
  const RescuePrices({
    super.key,
    required this.originalCents,
    required this.dealCents,
    this.large = false,
  });
  final int originalCents, dealCents;
  final bool large;
  @override
  Widget build(BuildContext context) => Wrap(
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: 10,
    runSpacing: 4,
    children: [
      Text(
        rescuePrice(dealCents),
        style: TextStyle(
          fontSize: large ? 32 : 23,
          fontWeight: FontWeight.w700,
          letterSpacing: -.5,
        ),
      ),
      Text(
        rescuePrice(originalCents),
        style: TextStyle(
          fontSize: large ? 17 : 14,
          decoration: TextDecoration.lineThrough,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    ],
  );
}

class RescueDealCard extends StatelessWidget {
  const RescueDealCard({super.key, required this.deal, required this.onTap});
  final RescueDeal deal;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = deal.statusAt(DateTime.now());
    return Material(
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: .65),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RescueThumbnail(url: deal.imageUrl),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RescueStatusBadge(status),
                        const SizedBox(height: 10),
                        Text(
                          deal.itemName.isEmpty
                              ? 'rescue.menuItem'.tr
                              : deal.itemName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, size: 18),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: RescuePrices(
                      originalCents: deal.originalCents,
                      dealCents: deal.dealCents,
                    ),
                  ),
                  Text(
                    'rescue.percentOff'.trParams({
                      'percent': '${deal.discountPercent}',
                    }),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Divider(
                height: 1,
                color: theme.colorScheme.outlineVariant.withValues(alpha: .55),
              ),
              const SizedBox(height: 13),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _meta(
                    context,
                    Icons.inventory_2_outlined,
                    'rescue.portionsLeft'.trParams({
                      'count': '${deal.remainingQty}',
                    }),
                  ),
                  _meta(
                    context,
                    Icons.schedule_outlined,
                    rescueWhen(
                      context,
                      status == RescueStatus.scheduled
                          ? deal.startsAt
                          : deal.endsAt,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _meta(BuildContext context, IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        icon,
        size: 15,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      const SizedBox(width: 6),
      Flexible(
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    ],
  );
}

class RescueMessage extends StatelessWidget {
  const RescueMessage({
    super.key,
    required this.title,
    required this.body,
    this.action,
    this.icon = Icons.eco_outlined,
  });
  final String title, body;
  final Widget? action;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
    child: Column(
      children: [
        Icon(
          icon,
          size: 38,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 18),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 370),
          child: Text(
            body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ),
        if (action != null) ...[const SizedBox(height: 16), action!],
      ],
    ),
  );
}

class RescueTheme extends StatelessWidget {
  const RescueTheme({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final dark = base.brightness == Brightness.dark;
    final accent = HSLColor.fromColor(
      base.colorScheme.primary,
    ).withSaturation(.48).withLightness(dark ? .70 : .29).toColor();
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final family = arabic
        ? AppTypography.fontFamilyArabic
        : AppTypography.fontFamily;
    final border = dark ? const Color(0xFF3A403D) : const Color(0xFFE3E8E5);
    return Theme(
      data: base.copyWith(
        textTheme: base.textTheme.apply(fontFamily: family),
        appBarTheme: base.appBarTheme.copyWith(
          titleTextStyle: base.appBarTheme.titleTextStyle?.copyWith(
            fontFamily: family,
          ),
        ),
        colorScheme: base.colorScheme.copyWith(
          primary: accent,
          onPrimary: dark ? const Color(0xFF14261B) : Colors.white,
          outlineVariant: border,
          surfaceContainerLow: dark
              ? DarkColors.backgroundTertiary
              : LightColors.backgroundSecondary,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: base.colorScheme.onSurface,
            side: BorderSide(color: border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: accent),
        ),
        textSelectionTheme: base.textSelectionTheme.copyWith(
          cursorColor: accent,
          selectionColor: accent.withValues(alpha: .2),
          selectionHandleColor: accent,
        ),
        switchTheme: SwitchThemeData(
          trackOutlineColor: WidgetStatePropertyAll(border),
          thumbColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected) ? accent : null,
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? accent.withValues(alpha: .18)
                : null,
          ),
        ),
        inputDecorationTheme: base.inputDecorationTheme.copyWith(
          labelStyle: base.inputDecorationTheme.labelStyle?.copyWith(
            fontFamily: family,
          ),
          hintStyle: base.inputDecorationTheme.hintStyle?.copyWith(
            fontFamily: family,
          ),
          helperStyle: base.inputDecorationTheme.helperStyle?.copyWith(
            fontFamily: family,
          ),
          errorStyle: base.inputDecorationTheme.errorStyle?.copyWith(
            fontFamily: family,
          ),
          errorMaxLines: 4,
          helperMaxLines: 3,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: accent, width: 1.5),
          ),
        ),
      ),
      child: child,
    );
  }
}
