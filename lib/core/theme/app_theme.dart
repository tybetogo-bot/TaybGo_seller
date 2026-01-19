import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Main theme configuration for the application
class AppTheme {
  AppTheme._();

  /// Default light theme (uses default green accent)
  static ThemeData get light => lightWithAccent(AppColors.presetAccentColors.first);

  /// Default dark theme (uses default green accent)
  static ThemeData get dark => darkWithAccent(AppColors.presetAccentColors.first);

  /// Light theme with custom accent color
  static ThemeData lightWithAccent(AccentColor accent) => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primarySwatch: accent.swatch,
        primaryColor: accent.color,
        scaffoldBackgroundColor: LightColors.background,
        colorScheme: ColorScheme.light(
          primary: accent.color,
          onPrimary: AppColors.white,
          secondary: AppColors.secondary,
          onSecondary: AppColors.white,
          surface: LightColors.surface,
          onSurface: LightColors.textPrimary,
          error: AppColors.error,
          onError: AppColors.white,
        ),
        textTheme: AppTypography.getTextTheme(isDark: false),
        appBarTheme: _lightAppBarTheme,
        elevatedButtonTheme: _elevatedButtonTheme(accent.color),
        outlinedButtonTheme: _outlinedButtonTheme(accent.color),
        textButtonTheme: _textButtonTheme(accent.color),
        inputDecorationTheme: _lightInputDecorationTheme(accent.color),
        cardTheme: _lightCardTheme,
        bottomNavigationBarTheme: _lightBottomNavTheme(accent.color),
        dividerTheme: _lightDividerTheme,
        chipTheme: _lightChipTheme(accent.color),
        floatingActionButtonTheme: _fabTheme(accent.color),
        checkboxTheme: _checkboxTheme(accent.color),
        radioTheme: _radioTheme(accent.color),
        switchTheme: _switchTheme(accent.color),
        bottomSheetTheme: _lightBottomSheetTheme,
        dialogTheme: _lightDialogTheme,
        snackBarTheme: _snackBarTheme,
        tabBarTheme: _lightTabBarTheme(accent.color),
        progressIndicatorTheme: _progressIndicatorTheme(accent),
      );

  /// Dark theme with custom accent color
  static ThemeData darkWithAccent(AccentColor accent) => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primarySwatch: accent.swatch,
        primaryColor: accent.color,
        scaffoldBackgroundColor: DarkColors.background,
        colorScheme: ColorScheme.dark(
          primary: accent.color,
          onPrimary: AppColors.white,
          secondary: AppColors.secondary,
          onSecondary: AppColors.white,
          surface: DarkColors.surface,
          onSurface: DarkColors.textPrimary,
          error: AppColors.error,
          onError: AppColors.white,
        ),
        textTheme: AppTypography.getTextTheme(isDark: true),
        appBarTheme: _darkAppBarTheme,
        elevatedButtonTheme: _elevatedButtonTheme(accent.color),
        outlinedButtonTheme: _outlinedButtonThemeDark(accent.color),
        textButtonTheme: _textButtonTheme(accent.color),
        inputDecorationTheme: _darkInputDecorationTheme(accent.color),
        cardTheme: _darkCardTheme,
        bottomNavigationBarTheme: _darkBottomNavTheme(accent.color),
        dividerTheme: _darkDividerTheme,
        chipTheme: _darkChipTheme(accent.color),
        floatingActionButtonTheme: _fabTheme(accent.color),
        checkboxTheme: _checkboxTheme(accent.color),
        radioTheme: _radioTheme(accent.color),
        switchTheme: _switchTheme(accent.color),
        bottomSheetTheme: _darkBottomSheetTheme,
        dialogTheme: _darkDialogTheme,
        snackBarTheme: _snackBarTheme,
        tabBarTheme: _darkTabBarTheme(accent.color),
        progressIndicatorTheme: _progressIndicatorTheme(accent),
      );

  // ============ AppBar Themes ============
  static AppBarTheme get _lightAppBarTheme => AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: LightColors.background,
        foregroundColor: LightColors.textPrimary,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        centerTitle: true,
        titleTextStyle: AppTypography.getTextTheme(isDark: false).titleLarge,
        iconTheme: const IconThemeData(
          color: LightColors.textPrimary,
          size: 24,
        ),
      );

  static AppBarTheme get _darkAppBarTheme => AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: DarkColors.background,
        foregroundColor: DarkColors.textPrimary,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        centerTitle: true,
        titleTextStyle: AppTypography.getTextTheme(isDark: true).titleLarge,
        iconTheme: const IconThemeData(
          color: DarkColors.textPrimary,
          size: 24,
        ),
      );

  // ============ Button Themes ============
  static ElevatedButtonThemeData _elevatedButtonTheme(Color accentColor) => ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.neutral[300],
          disabledForegroundColor: AppColors.neutral[500],
          elevation: 0,
          minimumSize: Size(double.infinity, AppSpacing.buttonHeight),
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.md,
          ),
          textStyle: AppTypography.button(),
        ),
      );

  static OutlinedButtonThemeData _outlinedButtonTheme(Color accentColor) => OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentColor,
          disabledForegroundColor: AppColors.neutral[400],
          elevation: 0,
          minimumSize: Size(double.infinity, AppSpacing.buttonHeight),
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.md,
          ),
          side: BorderSide(color: accentColor, width: 1.5),
          textStyle: AppTypography.button().copyWith(color: accentColor),
        ),
      );

  static OutlinedButtonThemeData _outlinedButtonThemeDark(Color accentColor) => OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentColor,
          disabledForegroundColor: AppColors.neutral[600],
          elevation: 0,
          minimumSize: Size(double.infinity, AppSpacing.buttonHeight),
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.md,
          ),
          side: BorderSide(color: accentColor, width: 1.5),
          textStyle: AppTypography.button().copyWith(color: accentColor),
        ),
      );

  static TextButtonThemeData _textButtonTheme(Color accentColor) => TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentColor,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          textStyle: AppTypography.link(),
        ),
      );

  // ============ Input Decoration Theme ============
  static InputDecorationTheme _lightInputDecorationTheme(Color accentColor) => InputDecorationTheme(
        filled: true,
        fillColor: LightColors.inputBackground,
        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        border: OutlineInputBorder(
          borderRadius: AppBorderRadius.md,
          borderSide: const BorderSide(color: LightColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.md,
          borderSide: const BorderSide(color: LightColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.md,
          borderSide: BorderSide(color: accentColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.md,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.md,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: AppTypography.inputHint(),
        errorStyle: AppTypography.errorText(),
        labelStyle: AppTypography.inputText(),
      );

  static InputDecorationTheme _darkInputDecorationTheme(Color accentColor) => InputDecorationTheme(
        filled: true,
        fillColor: DarkColors.inputBackground,
        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        border: OutlineInputBorder(
          borderRadius: AppBorderRadius.md,
          borderSide: const BorderSide(color: DarkColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.md,
          borderSide: const BorderSide(color: DarkColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.md,
          borderSide: BorderSide(color: accentColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.md,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.md,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: AppTypography.inputHint(isDark: true),
        errorStyle: AppTypography.errorText(),
        labelStyle: AppTypography.inputText(isDark: true),
      );

  // ============ Card Theme ============
  static CardThemeData get _lightCardTheme => CardThemeData(
        color: LightColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.lg,
        ),
        margin: EdgeInsets.zero,
      );

  static CardThemeData get _darkCardTheme => CardThemeData(
        color: DarkColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.lg,
        ),
        margin: EdgeInsets.zero,
      );

  // ============ Bottom Navigation Theme ============
  static BottomNavigationBarThemeData _lightBottomNavTheme(Color accentColor) => BottomNavigationBarThemeData(
        backgroundColor: LightColors.bottomNavBackground,
        selectedItemColor: accentColor,
        unselectedItemColor: LightColors.bottomNavInactive,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
      );

  static BottomNavigationBarThemeData _darkBottomNavTheme(Color accentColor) => BottomNavigationBarThemeData(
        backgroundColor: DarkColors.bottomNavBackground,
        selectedItemColor: accentColor,
        unselectedItemColor: DarkColors.bottomNavInactive,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
      );

  // ============ Divider Theme ============
  static DividerThemeData get _lightDividerTheme => const DividerThemeData(
        color: LightColors.divider,
        thickness: 1,
        space: 1,
      );

  static DividerThemeData get _darkDividerTheme => const DividerThemeData(
        color: DarkColors.divider,
        thickness: 1,
        space: 1,
      );

  // ============ Chip Theme ============
  static ChipThemeData _lightChipTheme(Color accentColor) => ChipThemeData(
        backgroundColor: LightColors.backgroundSecondary,
        selectedColor: accentColor,
        disabledColor: LightColors.backgroundTertiary,
        labelStyle: AppTypography.categoryChip(),
        secondaryLabelStyle: AppTypography.categoryChip(isSelected: true),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.full,
        ),
      );

  static ChipThemeData _darkChipTheme(Color accentColor) => ChipThemeData(
        backgroundColor: DarkColors.backgroundSecondary,
        selectedColor: accentColor,
        disabledColor: DarkColors.backgroundTertiary,
        labelStyle: AppTypography.categoryChip(),
        secondaryLabelStyle: AppTypography.categoryChip(isSelected: true),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.full,
        ),
      );

  // ============ FAB Theme ============
  static FloatingActionButtonThemeData _fabTheme(Color accentColor) => FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: AppColors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
      );

  // ============ Checkbox Theme ============
  static CheckboxThemeData _checkboxTheme(Color accentColor) => CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accentColor;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.r),
        ),
      );

  // ============ Radio Theme ============
  static RadioThemeData _radioTheme(Color accentColor) => RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accentColor;
          }
          return AppColors.neutral[400];
        }),
      );

  // ============ Switch Theme ============
  static SwitchThemeData _switchTheme(Color accentColor) => SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.white;
          }
          return AppColors.neutral[400];
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accentColor;
          }
          return AppColors.neutral[200];
        }),
      );

  // ============ Bottom Sheet Theme ============
  static BottomSheetThemeData get _lightBottomSheetTheme => BottomSheetThemeData(
        backgroundColor: LightColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.topXl,
        ),
        dragHandleColor: AppColors.neutral[300],
        dragHandleSize: Size(40.w, 4.h),
      );

  static BottomSheetThemeData get _darkBottomSheetTheme => BottomSheetThemeData(
        backgroundColor: DarkColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.topXl,
        ),
        dragHandleColor: AppColors.neutral[600],
        dragHandleSize: Size(40.w, 4.h),
      );

  // ============ Dialog Theme ============
  static DialogThemeData get _lightDialogTheme => DialogThemeData(
        backgroundColor: LightColors.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.xl,
        ),
      );

  static DialogThemeData get _darkDialogTheme => DialogThemeData(
        backgroundColor: DarkColors.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.xl,
        ),
      );

  // ============ SnackBar Theme ============
  static SnackBarThemeData get _snackBarTheme => SnackBarThemeData(
        backgroundColor: AppColors.neutral[800],
        contentTextStyle: const TextStyle(color: AppColors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.md,
        ),
      );

  // ============ TabBar Theme ============
  static TabBarThemeData _lightTabBarTheme(Color accentColor) => TabBarThemeData(
        labelColor: accentColor,
        unselectedLabelColor: LightColors.textSecondary,
        labelStyle: AppTypography.tabLabel(isSelected: true),
        unselectedLabelStyle: AppTypography.tabLabel(),
        indicatorColor: accentColor,
        indicatorSize: TabBarIndicatorSize.label,
      );

  static TabBarThemeData _darkTabBarTheme(Color accentColor) => TabBarThemeData(
        labelColor: accentColor,
        unselectedLabelColor: DarkColors.textSecondary,
        labelStyle: AppTypography.tabLabel(isSelected: true, isDark: true),
        unselectedLabelStyle: AppTypography.tabLabel(isDark: true),
        indicatorColor: accentColor,
        indicatorSize: TabBarIndicatorSize.label,
      );

  // ============ Progress Indicator Theme ============
  static ProgressIndicatorThemeData _progressIndicatorTheme(AccentColor accent) => ProgressIndicatorThemeData(
        color: accent.color,
        linearTrackColor: accent.lightVariant,
        circularTrackColor: accent.lightVariant,
      );
}

/// Extension to easily access custom colors
extension ThemeExtensions on ThemeData {
  bool get isDark => brightness == Brightness.dark;

  Color get textPrimary => isDark ? DarkColors.textPrimary : LightColors.textPrimary;
  Color get textSecondary => isDark ? DarkColors.textSecondary : LightColors.textSecondary;
  Color get textTertiary => isDark ? DarkColors.textTertiary : LightColors.textTertiary;

  Color get backgroundPrimary => isDark ? DarkColors.background : LightColors.background;
  Color get backgroundSecondary => isDark ? DarkColors.backgroundSecondary : LightColors.backgroundSecondary;

  Color get cardColor => isDark ? DarkColors.cardBackground : LightColors.cardBackground;
  Color get borderColor => isDark ? DarkColors.border : LightColors.border;
  Color get dividerColor => isDark ? DarkColors.divider : LightColors.divider;

  Color get shimmerBase => isDark ? DarkColors.shimmerBase : LightColors.shimmerBase;
  Color get shimmerHighlight => isDark ? DarkColors.shimmerHighlight : LightColors.shimmerHighlight;
}
