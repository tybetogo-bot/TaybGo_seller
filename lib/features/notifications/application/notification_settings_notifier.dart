import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/constants.dart';
import '../../../core/providers/providers.dart' show sharedPreferencesProvider;

/// Local notification preferences for the seller app.
class AppNotificationSettings {
  const AppNotificationSettings({required this.orderAlertRepeatCount});

  static const List<int> supportedOrderAlertRepeatCounts = [1, 2, 3, 5];
  static const int defaultOrderAlertRepeatCount = 1;

  final int orderAlertRepeatCount;

  factory AppNotificationSettings.fromPreferences(SharedPreferences prefs) {
    final savedCount = prefs.getInt(StorageKeys.orderAlertRepeatCount);
    final repeatCount = supportedOrderAlertRepeatCounts.contains(savedCount)
        ? savedCount!
        : defaultOrderAlertRepeatCount;

    return AppNotificationSettings(orderAlertRepeatCount: repeatCount);
  }

  AppNotificationSettings copyWith({int? orderAlertRepeatCount}) {
    return AppNotificationSettings(
      orderAlertRepeatCount:
          orderAlertRepeatCount ?? this.orderAlertRepeatCount,
    );
  }
}

/// Persists notification preferences on the current device.
class NotificationSettingsNotifier extends Notifier<AppNotificationSettings> {
  late SharedPreferences _prefs;

  @override
  AppNotificationSettings build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    return AppNotificationSettings.fromPreferences(_prefs);
  }

  Future<void> setOrderAlertRepeatCount(int count) async {
    if (!AppNotificationSettings.supportedOrderAlertRepeatCounts.contains(
      count,
    )) {
      return;
    }

    state = state.copyWith(orderAlertRepeatCount: count);
    await _prefs.setInt(StorageKeys.orderAlertRepeatCount, count);
  }
}

final notificationSettingsProvider =
    NotifierProvider<NotificationSettingsNotifier, AppNotificationSettings>(
      NotificationSettingsNotifier.new,
    );
