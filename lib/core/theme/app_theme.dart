import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Main theme configuration for the application
class AppTheme {
  AppTheme._();

  /// Light theme
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primarySwatch: AppColors.primary,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: LightColors.background,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
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
        elevatedButtonTheme: _elevatedButtonTheme,
        outlinedButtonTheme: _outlinedButtonTheme,
        textButtonTheme: _textButtonTheme,
        inputDecorationTheme: _lightInputDecorationTheme,
        cardTheme: _lightCardTheme,
        bottomNavigationBarTheme: _lightBottomNavTheme,
        dividerTheme: _lightDividerTheme,
        chipTheme: _lightChipTheme,
        floatingActionButtonTheme: _fabTheme,
        checkboxTheme: _checkboxTheme,
        radioTheme: _radioTheme,
        switchTheme: _switchTheme,
        bottomSheetTheme: _lightBottomSheetTheme,
        dialogTheme: _lightDialogTheme,
        snackBarTheme: _snackBarTheme,
        tabBarTheme: _lightTabBarTheme,
        progressIndicatorTheme: _progressIndicatorTheme,
      );

  /// Dark theme
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primarySwatch: AppColors.primary,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: DarkColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
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
        elevatedButtonTheme: _elevatedButtonTheme,
        outlinedButtonTheme: _outlinedButtonThemeDark,
        textButtonTheme: _textButtonTheme,
        inputDecorationTheme: _darkInputDecorationTheme,
        cardTheme: _darkCardTheme,
        bottomNavigationBarTheme: _darkBottomNavTheme,
        dividerTheme: _darkDividerTheme,
        chipTheme: _darkChipTheme,
        floatingActionButtonTheme: _fabTheme,
        checkboxTheme: _checkboxTheme,
        radioTheme: _radioTheme,
        switchTheme: _switchTheme,
        bottomSheetTheme: _darkBottomSheetTheme,
        dialogTheme: _darkDialogTheme,
        snackBarTheme: _snackBarTheme,
        tabBarTheme: _darkTabBarTheme,
        progressIndicatorTheme: _progressIndicatorTheme,
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
  static ElevatedButtonThemeData get _elevatedButtonTheme => ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
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

  static OutlinedButtonThemeData get _outlinedButtonTheme => OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.neutral[400],
          elevation: 0,
          minimumSize: Size(double.infinity, AppSpacing.buttonHeight),
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.md,
          ),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          textStyle: AppTypography.button().copyWith(color: AppColors.primary),
        ),
      );

  static OutlinedButtonThemeData get _outlinedButtonThemeDark => OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.neutral[600],
          elevation: 0,
          minimumSize: Size(double.infinity, AppSpacing.buttonHeight),
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.md,
          ),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          textStyle: AppTypography.button().copyWith(color: AppColors.primary),
        ),
      );

  static TextButtonThemeData get _textButtonTheme => TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          textStyle: AppTypography.link(),
        ),
      );

  // ============ Input Decoration Theme ============
  static InputDecorationTheme get _lightInputDecorationTheme => InputDecorationTheme(
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
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
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

  static InputDecorationTheme get _darkInputDecorationTheme => InputDecorationTheme(
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
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
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
  static BottomNavigationBarThemeData get _lightBottomNavTheme => BottomNavigationBarThemeData(
        backgroundColor: LightColors.bottomNavBackground,
        selectedItemColor: LightColors.bottomNavActive,
        unselectedItemColor: LightColors.bottomNavInactive,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
      );

  static BottomNavigationBarThemeData get _darkBottomNavTheme => BottomNavigationBarThemeData(
        backgroundColor: DarkColors.bottomNavBackground,
        selectedItemColor: DarkColors.bottomNavActive,
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
  static ChipThemeData get _lightChipTheme => ChipThemeData(
        backgroundColor: LightColors.backgroundSecondary,
        selectedColor: AppColors.primary,
        disabledColor: LightColors.backgroundTertiary,
        labelStyle: AppTypography.categoryChip(),
        secondaryLabelStyle: AppTypography.categoryChip(isSelected: true),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.full,
        ),
      );

  static ChipThemeData get _darkChipTheme => ChipThemeData(
        backgroundColor: DarkColors.backgroundSecondary,
        selectedColor: AppColors.primary,
        disabledColor: DarkColors.backgroundTertiary,
        labelStyle: AppTypography.categoryChip(),
        secondaryLabelStyle: AppTypography.categoryChip(isSelected: true),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.full,
        ),
      );

  // ============ FAB Theme ============
  static FloatingActionButtonThemeData get _fabTheme => FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
      );

  // ============ Checkbox Theme ============
  static CheckboxThemeData get _checkboxTheme => CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.r),
        ),
      );

  // ============ Radio Theme ============
  static RadioThemeData get _radioTheme => RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.neutral[400];
        }),
      );

  // ============ Switch Theme ============
  static SwitchThemeData get _switchTheme => SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.white;
          }
          return AppColors.neutral[400];
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
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
  static TabBarThemeData get _lightTabBarTheme => TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: LightColors.textSecondary,
        labelStyle: AppTypography.tabLabel(isSelected: true),
        unselectedLabelStyle: AppTypography.tabLabel(),
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
      );

  static TabBarThemeData get _darkTabBarTheme => TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: DarkColors.textSecondary,
        labelStyle: AppTypography.tabLabel(isSelected: true, isDark: true),
        unselectedLabelStyle: AppTypography.tabLabel(isDark: true),
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
      );

  // ============ Progress Indicator Theme ============
  static ProgressIndicatorThemeData get _progressIndicatorTheme => ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.primary[100],
        circularTrackColor: AppColors.primary[100],
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
