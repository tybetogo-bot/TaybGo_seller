import 'package:flutter/material.dart';

import 'breakpoints.dart';

/// Builds a different widget tree depending on the current [FormFactor].
///
/// Provide a [phone] builder always. [tablet] and [desktop] fall back to the
/// previous smaller breakpoint when omitted.
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.phone,
    this.tablet,
    this.desktop,
  });

  final WidgetBuilder phone;
  final WidgetBuilder? tablet;
  final WidgetBuilder? desktop;

  @override
  Widget build(BuildContext context) {
    final ff = context.formFactor;
    if (ff == FormFactor.desktop) {
      return (desktop ?? tablet ?? phone)(context);
    }
    if (ff == FormFactor.tablet) {
      return (tablet ?? phone)(context);
    }
    return phone(context);
  }
}

/// Wraps [child] in a horizontally-centered [ConstrainedBox] so it doesn't
/// stretch across the full width of a wide screen.
///
/// Use this for forms, settings pages, auth screens, etc. On phone-width
/// screens it has no effect (the child fills naturally).
class ContentMaxWidth extends StatelessWidget {
  const ContentMaxWidth({
    super.key,
    required this.child,
    this.maxWidth = Breakpoints.maxContentWidth,
    this.padding,
    this.alignment = Alignment.topCenter,
  });

  /// Convenience constructor for narrow content (auth cards, small forms).
  const ContentMaxWidth.narrow({
    super.key,
    required this.child,
    this.padding,
    this.alignment = Alignment.topCenter,
  }) : maxWidth = Breakpoints.maxNarrowContentWidth;

  /// Convenience constructor for wide content (dashboards, lists).
  const ContentMaxWidth.wide({
    super.key,
    required this.child,
    this.padding,
    this.alignment = Alignment.topCenter,
  }) : maxWidth = Breakpoints.maxWideContentWidth;

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: padding == null ? child : Padding(padding: padding!, child: child),
      ),
    );
  }
}

/// A sliver version of [ContentMaxWidth] for use inside [CustomScrollView].
class SliverContentMaxWidth extends StatelessWidget {
  const SliverContentMaxWidth({
    super.key,
    required this.sliver,
    this.maxWidth = Breakpoints.maxContentWidth,
  });

  const SliverContentMaxWidth.wide({
    super.key,
    required this.sliver,
  }) : maxWidth = Breakpoints.maxWideContentWidth;

  final Widget sliver;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    // Center the sliver by adding equal horizontal padding when the
    // screen is wider than [maxWidth].
    final screenWidth = MediaQuery.sizeOf(context).width;
    if (screenWidth <= maxWidth) return sliver;
    final horizontalPadding = (screenWidth - maxWidth) / 2;
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: sliver,
    );
  }
}

/// Picks an appropriate number of grid columns for the current screen width.
///
/// [minItemWidth] is the smallest acceptable width (in logical pixels) for a
/// single item. The returned column count is clamped between [min] and [max].
int responsiveColumnCount(
  BuildContext context, {
  double minItemWidth = 280,
  int min = 1,
  int max = 4,
}) {
  final width = MediaQuery.sizeOf(context).width;
  final count = (width / minItemWidth).floor();
  return count.clamp(min, max);
}

/// Drop-in replacement for [ListView.builder] that uses a single column on
/// phone-width screens and switches to a multi-column grid on tablet/desktop.
///
/// The number of columns is calculated from [minItemWidth] so each item stays
/// at a comfortable width regardless of the viewport.
class ResponsiveListGrid extends StatelessWidget {
  const ResponsiveListGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding,
    this.physics,
    this.controller,
    this.shrinkWrap = false,
    this.minItemWidth = 360,
    this.crossAxisSpacing = 12,
    this.mainAxisSpacing = 12,
    this.childAspectRatio,
    this.maxColumns = 3,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final ScrollController? controller;
  final bool shrinkWrap;

  /// Minimum width an item should occupy. Used to compute column count.
  final double minItemWidth;
  final double crossAxisSpacing;
  final double mainAxisSpacing;

  /// If null, items size naturally (use a [SliverGrid] with a max cross-axis
  /// extent delegate). Otherwise we force the given aspect ratio.
  final double? childAspectRatio;
  final int maxColumns;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = (width / minItemWidth).floor().clamp(1, maxColumns);
        if (columns <= 1) {
          // Phone: behave like a normal ListView for natural item heights.
          return ListView.builder(
            padding: padding,
            physics: physics,
            controller: controller,
            shrinkWrap: shrinkWrap,
            itemCount: itemCount,
            itemBuilder: itemBuilder,
          );
        }
        return GridView.builder(
          padding: padding,
          physics: physics,
          controller: controller,
          shrinkWrap: shrinkWrap,
          gridDelegate: childAspectRatio == null
              ? SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: width / columns,
                  crossAxisSpacing: crossAxisSpacing,
                  mainAxisSpacing: mainAxisSpacing,
                  childAspectRatio: 1.6,
                )
              : SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: crossAxisSpacing,
                  mainAxisSpacing: mainAxisSpacing,
                  childAspectRatio: childAspectRatio!,
                ),
          itemCount: itemCount,
          itemBuilder: itemBuilder,
        );
      },
    );
  }
}

/// Wraps the body of a screen so it's:
/// - Full width on phones (no constraint)
/// - Centered with a max width on tablet/desktop
///
/// Drop this around your screen's body to make a single-column layout feel
/// natural on wide screens instead of stretching across the full viewport.
class ResponsiveScreenBody extends StatelessWidget {
  const ResponsiveScreenBody({
    super.key,
    required this.child,
    this.maxWidth = Breakpoints.maxContentWidth,
    this.padding,
  });

  /// Narrow variant for auth and dialog-like content.
  const ResponsiveScreenBody.narrow({
    super.key,
    required this.child,
    this.padding,
  }) : maxWidth = Breakpoints.maxNarrowContentWidth;

  /// Wide variant for dashboards and list-heavy screens.
  const ResponsiveScreenBody.wide({
    super.key,
    required this.child,
    this.padding,
  }) : maxWidth = Breakpoints.maxWideContentWidth;

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    if (screenWidth <= maxWidth) {
      return padding == null ? child : Padding(padding: padding!, child: child);
    }
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: padding == null ? child : Padding(padding: padding!, child: child),
      ),
    );
  }
}

/// Wraps a single scrollable form (Column inside SingleChildScrollView, or
/// any vertically-scrolling body) so it stays a comfortable reading width on
/// wide screens. Equivalent to [ResponsiveScreenBody] with the narrow
/// breakpoint; provided as a separate name for clarity at call sites.
class FormMaxWidth extends StatelessWidget {
  const FormMaxWidth({
    super.key,
    required this.child,
    this.maxWidth = Breakpoints.maxContentWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    if (screenWidth <= maxWidth) return child;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
