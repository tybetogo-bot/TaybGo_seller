import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/theme.dart';

/// Custom card widget with consistent styling
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.shadow,
    this.onTap,
    this.onLongPress,
  });

  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final List<BoxShadow>? shadow;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? (isDark ? DarkColors.cardBackground : LightColors.cardBackground),
        borderRadius: BorderRadius.circular(borderRadius ?? AppSpacing.radiusLg),
        border: borderColor != null || borderWidth != null
            ? Border.all(
                color: borderColor ?? (isDark ? DarkColors.border : LightColors.border),
                width: borderWidth ?? 1,
              )
            : null,
        boxShadow: shadow ?? (isDark ? AppShadows.darkSm : AppShadows.sm),
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(16.w),
        child: child,
      ),
    );

    if (onTap != null || onLongPress != null) {
      return GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: card,
      );
    }

    return card;
  }
}

/// Elevated card with more prominent shadow
class AppElevatedCard extends StatelessWidget {
  const AppElevatedCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? borderRadius;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppCard(
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      backgroundColor: backgroundColor,
      shadow: isDark ? AppShadows.darkMd : AppShadows.md,
      onTap: onTap,
      child: child,
    );
  }
}

/// Outlined card with border and no shadow
class AppOutlinedCard extends StatelessWidget {
  const AppOutlinedCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.borderColor,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? borderRadius;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppCard(
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      borderColor: borderColor ?? (isDark ? DarkColors.border : LightColors.border),
      borderWidth: 1,
      shadow: AppShadows.none,
      onTap: onTap,
      child: child,
    );
  }
}

/// Interactive card with ripple effect
class AppInteractiveCard extends StatelessWidget {
  const AppInteractiveCard({
    super.key,
    required this.child,
    required this.onTap,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
  });

  final Widget child;
  final VoidCallback onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? borderRadius;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: margin,
      child: Material(
        color: backgroundColor ?? (isDark ? DarkColors.cardBackground : LightColors.cardBackground),
        borderRadius: BorderRadius.circular(borderRadius ?? AppSpacing.radiusLg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius ?? AppSpacing.radiusLg),
          child: Container(
            padding: padding ?? EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius ?? AppSpacing.radiusLg),
              boxShadow: isDark ? AppShadows.darkSm : AppShadows.sm,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
