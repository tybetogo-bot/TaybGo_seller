import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/constants.dart';
import '../providers/providers.dart' show sharedPreferencesProvider;

/// Theme mode state
enum AppThemeMode { light, dark, system }

/// Theme state notifier (Riverpod 3.x)
class ThemeNotifier extends Notifier<AppThemeMode> {
  late SharedPreferences _prefs;

  @override
  AppThemeMode build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    return _loadInitialTheme(_prefs);
  }

  static AppThemeMode _loadInitialTheme(SharedPreferences prefs) {
    final savedTheme = prefs.getString(StorageKeys.themeMode);
    switch (savedTheme) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      default:
        return AppThemeMode.light;
    }
  }

  /// Set theme mode
  Future<void> setTheme(AppThemeMode mode) async {
    state = mode;
    await _prefs.setString(StorageKeys.themeMode, mode.name);
  }

  /// Toggle between light and dark (ignores system)
  Future<void> toggleTheme() async {
    final newMode = state == AppThemeMode.light ? AppThemeMode.dark : AppThemeMode.light;
    await setTheme(newMode);
  }

  /// Check if dark mode is active
  bool isDark(BuildContext context) {
    switch (state) {
      case AppThemeMode.light:
        return false;
      case AppThemeMode.dark:
        return true;
      case AppThemeMode.system:
        return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
  }

  /// Get the current ThemeMode for MaterialApp
  ThemeMode get themeMode {
    switch (state) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}

/// Provider for theme state (Riverpod 3.x)
final themeProvider = NotifierProvider<ThemeNotifier, AppThemeMode>(
  ThemeNotifier.new,
);

/// Provider for the actual ThemeMode used by MaterialApp
final themeModeProvider = Provider<ThemeMode>((ref) {
  final appThemeMode = ref.watch(themeProvider);
  switch (appThemeMode) {
    case AppThemeMode.light:
      return ThemeMode.light;
    case AppThemeMode.dark:
      return ThemeMode.dark;
    case AppThemeMode.system:
      return ThemeMode.system;
  }
});

/// Provider to check if currently in dark mode
final isDarkModeProvider = Provider.family<bool, BuildContext>((ref, context) {
  final appThemeMode = ref.watch(themeProvider);
  switch (appThemeMode) {
    case AppThemeMode.light:
      return false;
    case AppThemeMode.dark:
      return true;
    case AppThemeMode.system:
      return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
  }
});
