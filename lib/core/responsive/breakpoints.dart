import 'package:flutter/widgets.dart';

/// Responsive breakpoints used throughout the app.
///
/// - phone:   width < [tablet]
/// - tablet:  [tablet] <= width < [desktop]
/// - desktop: width >= [desktop]
///
/// These values match common Material 3 layout breakpoints adapted for
/// our app: phones in portrait, small tablets / phones in landscape, and
/// large tablets + web/desktop.
class Breakpoints {
  Breakpoints._();

  /// Above this width we switch from phone layouts to tablet layouts.
  static const double tablet = 600;

  /// Above this width we switch from tablet layouts to desktop layouts.
  static const double desktop = 1024;

  /// Max content width for centered content blocks (forms, auth, settings).
  static const double maxContentWidth = 720;

  /// Max content width for narrow centered content (auth cards, dialogs).
  static const double maxNarrowContentWidth = 480;

  /// Max content width for wide content (dashboards, lists).
  static const double maxWideContentWidth = 1200;
}

/// Form factor of the current screen.
enum FormFactor { phone, tablet, desktop }

/// Convenience extension to query the current form factor and breakpoints
/// from any [BuildContext].
extension ResponsiveContext on BuildContext {
  /// Current screen width.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Current screen height.
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Returns the current [FormFactor] based on the screen width.
  FormFactor get formFactor {
    final width = screenWidth;
    if (width >= Breakpoints.desktop) return FormFactor.desktop;
    if (width >= Breakpoints.tablet) return FormFactor.tablet;
    return FormFactor.phone;
  }

  /// True when the screen is at least tablet-width.
  bool get isTabletOrLarger => screenWidth >= Breakpoints.tablet;

  /// True when the screen is at least desktop-width.
  bool get isDesktop => screenWidth >= Breakpoints.desktop;

  /// True when the screen is phone-width.
  bool get isPhone => screenWidth < Breakpoints.tablet;

  /// True when the screen is tablet-width specifically (not desktop).
  bool get isTablet =>
      screenWidth >= Breakpoints.tablet && screenWidth < Breakpoints.desktop;

  /// Picks a value based on the current form factor.
  ///
  /// `tablet` falls back to `phone` if omitted, `desktop` falls back to
  /// `tablet` (then `phone`) if omitted. This makes it easy to specify only
  /// the values that differ between breakpoints.
  T responsive<T>({required T phone, T? tablet, T? desktop}) {
    switch (formFactor) {
      case FormFactor.desktop:
        return desktop ?? tablet ?? phone;
      case FormFactor.tablet:
        return tablet ?? phone;
      case FormFactor.phone:
        return phone;
    }
  }
}
