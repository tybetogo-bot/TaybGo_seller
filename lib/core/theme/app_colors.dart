import 'package:flutter/material.dart';

/// Dynamic color palette for the application
/// Based on the TybeToGo design system (green primary color)
class AppColors {
  AppColors._();

  // ============ Brand Colors ============
  /// Primary green color palette
  static const MaterialColor primary = MaterialColor(
    0xFF00C853,
    <int, Color>{
      50: Color(0xFFE8FDF5),
      100: Color(0xFFD1FBE9),
      200: Color(0xFFA3F7D4),
      300: Color(0xFF5EEDB3),
      400: Color(0xFF2DD881),
      500: Color(0xFF00C853), // Main
      600: Color(0xFF00A344),
      700: Color(0xFF007D35),
      800: Color(0xFF005726),
      900: Color(0xFF003017),
    },
  );

  /// Secondary color palette
  static const MaterialColor secondary = MaterialColor(
    0xFF212121,
    <int, Color>{
      50: Color(0xFFFAFAFA),
      100: Color(0xFFF5F5F5),
      200: Color(0xFFEEEEEE),
      300: Color(0xFFE0E0E0),
      400: Color(0xFFBDBDBD),
      500: Color(0xFF212121), // Main
      600: Color(0xFF1A1A1A),
      700: Color(0xFF141414),
      800: Color(0xFF0D0D0D),
      900: Color(0xFF050505),
    },
  );

  // ============ Neutral Colors ============
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static const MaterialColor neutral = MaterialColor(
    0xFF6B7280,
    <int, Color>{
      0: Color(0xFFFFFFFF),
      50: Color(0xFFF9FAFB),
      100: Color(0xFFF3F4F6),
      200: Color(0xFFE5E7EB),
      300: Color(0xFFD1D5DB),
      400: Color(0xFF9CA3AF),
      500: Color(0xFF6B7280),
      600: Color(0xFF4B5563),
      700: Color(0xFF374151),
      800: Color(0xFF1F2937),
      900: Color(0xFF111827),
      1000: Color(0xFF000000),
    },
  );

  // ============ Semantic Colors ============
  /// Success colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color successDark = Color(0xFF065F46);

  /// Warning colors
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFF92400E);

  /// Error colors
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFF991B1B);

  /// Info colors
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color infoDark = Color(0xFF1E40AF);

  // ============ Gradient Colors ============
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00C853), Color(0xFF00A344)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF212121), Color(0xFF171717)],
  );

  // ============ Social Colors ============
  static const Color google = Color(0xFFDB4437);
  static const Color apple = Color(0xFF000000);
  static const Color facebook = Color(0xFF1877F2);

  // ============ Status Colors ============
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusAccepted = Color(0xFF3B82F6);
  static const Color statusPreparing = Color(0xFF8B5CF6);
  static const Color statusReady = Color(0xFF10B981);
  static const Color statusDelivered = Color(0xFF059669);
  static const Color statusCancelled = Color(0xFFEF4444);

  // ============ Rating Colors ============
  static const Color ratingStar = Color(0xFFFBBF24);
  static const Color ratingStarEmpty = Color(0xFFD1D5DB);
}

/// Light theme color scheme
class LightColors {
  LightColors._();

  // Backgrounds
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundSecondary = Color(0xFFF9FAFB);
  static const Color backgroundTertiary = Color(0xFFF3F4F6);

  // Surfaces
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textDisabled = Color(0xFFD1D5DB);
  static const Color textInverse = Color(0xFFFFFFFF);

  // Borders
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);
  static const Color borderFocused = AppColors.primary;

  // Input
  static const Color inputBackground = Color(0xFFF9FAFB);
  static const Color inputBorder = Color(0xFFE5E7EB);

  // Card
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardShadow = Color(0x1A000000);

  // Bottom Navigation
  static const Color bottomNavBackground = Color(0xFFFFFFFF);
  static const Color bottomNavActive = AppColors.primary;
  static const Color bottomNavInactive = Color(0xFF9CA3AF);

  // Divider
  static const Color divider = Color(0xFFE5E7EB);

  // Shimmer
  static const Color shimmerBase = Color(0xFFE5E7EB);
  static const Color shimmerHighlight = Color(0xFFF9FAFB);
}

/// Dark theme color scheme
class DarkColors {
  DarkColors._();

  // Backgrounds
  static const Color background = Color(0xFF171717);
  static const Color backgroundSecondary = Color(0xFF212121);
  static const Color backgroundTertiary = Color(0xFF2E2E2E);

  // Surfaces
  static const Color surface = Color(0xFF212121);
  static const Color surfaceElevated = Color(0xFF2E2E2E);

  // Text
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFBDBDBD);
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color textDisabled = Color(0xFF616161);
  static const Color textInverse = Color(0xFF171717);

  // Borders
  static const Color border = Color(0xFF2E2E2E);
  static const Color borderLight = Color(0xFF424242);
  static const Color borderFocused = AppColors.primary;

  // Input
  static const Color inputBackground = Color(0xFF212121);
  static const Color inputBorder = Color(0xFF2E2E2E);

  // Card
  static const Color cardBackground = Color(0xFF212121);
  static const Color cardShadow = Color(0x40000000);

  // Bottom Navigation
  static const Color bottomNavBackground = Color(0xFF212121);
  static const Color bottomNavActive = AppColors.primary;
  static const Color bottomNavInactive = Color(0xFF9E9E9E);

  // Divider
  static const Color divider = Color(0xFF2E2E2E);

  // Shimmer
  static const Color shimmerBase = Color(0xFF2E2E2E);
  static const Color shimmerHighlight = Color(0xFF424242);
}
