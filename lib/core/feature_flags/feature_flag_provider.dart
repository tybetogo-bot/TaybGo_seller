import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/providers.dart' show sharedPreferencesProvider;
import 'feature_flags.dart';

/// Feature flags state
class FeatureFlagsState {
  const FeatureFlagsState({
    this.overrides = const {},
    this.remoteFlags = const {},
  });

  /// Local overrides
  final Map<FeatureFlag, bool> overrides;

  /// Remote flags from server
  final Map<FeatureFlag, bool> remoteFlags;

  /// Get value for a flag
  bool getValue(FeatureFlag flag) {
    // Priority: local override > remote > default
    return overrides[flag] ?? remoteFlags[flag] ?? flag.defaultValue;
  }

  FeatureFlagsState copyWith({
    Map<FeatureFlag, bool>? overrides,
    Map<FeatureFlag, bool>? remoteFlags,
  }) {
    return FeatureFlagsState(
      overrides: overrides ?? this.overrides,
      remoteFlags: remoteFlags ?? this.remoteFlags,
    );
  }
}

/// Feature flags notifier (Riverpod 3.x)
class FeatureFlagsNotifier extends Notifier<FeatureFlagsState> {
  late SharedPreferences _prefs;

  @override
  FeatureFlagsState build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    _loadOverrides();
    return const FeatureFlagsState();
  }
  static const String _storageKey = 'feature_flag_overrides';

  /// Load saved overrides from storage
  void _loadOverrides() {
    final saved = _prefs.getStringList(_storageKey);
    if (saved != null) {
      final overrides = <FeatureFlag, bool>{};
      for (final item in saved) {
        final parts = item.split(':');
        if (parts.length == 2) {
          try {
            final flag = FeatureFlag.values.firstWhere((f) => f.name == parts[0]);
            overrides[flag] = parts[1] == 'true';
          } catch (_) {
            // Ignore invalid flags
          }
        }
      }
      state = state.copyWith(overrides: overrides);
    }
  }

  /// Save overrides to storage
  Future<void> _saveOverrides() async {
    final list = state.overrides.entries.map((e) => '${e.key.name}:${e.value}').toList();
    await _prefs.setStringList(_storageKey, list);
  }

  /// Check if a feature is enabled
  bool isEnabled(FeatureFlag flag) {
    return state.getValue(flag);
  }

  /// Set a local override
  Future<void> setOverride(FeatureFlag flag, bool value) async {
    final newOverrides = Map<FeatureFlag, bool>.from(state.overrides);
    newOverrides[flag] = value;
    state = state.copyWith(overrides: newOverrides);
    await _saveOverrides();
  }

  /// Remove a local override
  Future<void> removeOverride(FeatureFlag flag) async {
    final newOverrides = Map<FeatureFlag, bool>.from(state.overrides);
    newOverrides.remove(flag);
    state = state.copyWith(overrides: newOverrides);
    await _saveOverrides();
  }

  /// Clear all local overrides
  Future<void> clearOverrides() async {
    state = state.copyWith(overrides: {});
    await _prefs.remove(_storageKey);
  }

  /// Update remote flags (from server)
  void updateRemoteFlags(Map<String, bool> flags) {
    final remoteFlags = <FeatureFlag, bool>{};
    for (final entry in flags.entries) {
      try {
        final flag = FeatureFlag.values.firstWhere((f) => f.name == entry.key);
        remoteFlags[flag] = entry.value;
      } catch (_) {
        // Ignore unknown flags
      }
    }
    state = state.copyWith(remoteFlags: remoteFlags);
  }

  /// Toggle a feature flag
  Future<void> toggle(FeatureFlag flag) async {
    final currentValue = isEnabled(flag);
    await setOverride(flag, !currentValue);
  }
}

/// Provider for feature flags (Riverpod 3.x)
final featureFlagsProvider = NotifierProvider<FeatureFlagsNotifier, FeatureFlagsState>(
  FeatureFlagsNotifier.new,
);

/// Provider to check if a specific feature is enabled
final isFeatureEnabledProvider = Provider.family<bool, FeatureFlag>((ref, flag) {
  final flagsState = ref.watch(featureFlagsProvider);
  return flagsState.getValue(flag);
});

/// Widget to conditionally render based on feature flag
class FeatureGate extends ConsumerWidget {
  const FeatureGate({
    super.key,
    required this.flag,
    required this.child,
    this.fallback,
  });

  /// The feature flag to check
  final FeatureFlag flag;

  /// Widget to show when feature is enabled
  final Widget child;

  /// Widget to show when feature is disabled (optional)
  final Widget? fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEnabled = ref.watch(isFeatureEnabledProvider(flag));

    if (isEnabled) {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }
}

/// Extension for easy feature checking
extension FeatureFlagExtension on WidgetRef {
  /// Check if a feature is enabled
  bool isFeatureEnabled(FeatureFlag flag) {
    return watch(isFeatureEnabledProvider(flag));
  }
}
