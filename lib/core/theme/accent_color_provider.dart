import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/constants.dart';
import '../providers/providers.dart' show sharedPreferencesProvider;
import 'app_colors.dart';

/// Accent color state notifier (Riverpod 3.x)
class AccentColorNotifier extends Notifier<AccentColor> {
  late SharedPreferences _prefs;

  @override
  AccentColor build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    return _loadInitialAccentColor(_prefs);
  }

  static AccentColor _loadInitialAccentColor(SharedPreferences prefs) {
    final savedColor = prefs.getString(StorageKeys.accentColor);
    if (savedColor != null) {
      return AppColors.getAccentByName(savedColor);
    }
    return AppColors.presetAccentColors.first; // Default to green
  }

  /// Set accent color
  Future<void> setAccentColor(AccentColor accent) async {
    state = accent;
    await _prefs.setString(StorageKeys.accentColor, accent.name);
  }

  /// Set accent color by name
  Future<void> setAccentColorByName(String name) async {
    final accent = AppColors.getAccentByName(name);
    await setAccentColor(accent);
  }
}

/// Provider for accent color state (Riverpod 3.x)
final accentColorProvider = NotifierProvider<AccentColorNotifier, AccentColor>(
  AccentColorNotifier.new,
);

/// Provider for the list of available accent colors
final availableAccentColorsProvider = Provider<List<AccentColor>>((ref) {
  return AppColors.presetAccentColors;
});
