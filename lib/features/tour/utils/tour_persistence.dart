import 'package:shared_preferences/shared_preferences.dart';

class TourPersistence {
  static const String _tourCompletedKey = 'tour_completed';
  static const String _tourLastShownKey = 'tour_last_shown';
  static const String _tourPromptShownKey = 'tour_prompt_shown';
  static const String _tourSkipCountKey = 'tour_skip_count';

  static Future<bool> hasTourPromptBeenShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_tourPromptShownKey) ?? false;
  }

  static Future<void> markTourPromptAsShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tourPromptShownKey, true);
  }

  static Future<bool> hasTourBeenCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_tourCompletedKey) ?? false;
  }

  static Future<void> markTourAsCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tourCompletedKey, true);
    await prefs.setString(_tourLastShownKey, DateTime.now().toIso8601String());
  }

  static Future<DateTime?> getLastTourShownDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_tourLastShownKey);
    if (dateString != null) {
      return DateTime.tryParse(dateString);
    }
    return null;
  }

  static Future<int> getTourSkipCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_tourSkipCountKey) ?? 0;
  }

  static Future<void> incrementSkipCount() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = await getTourSkipCount();
    await prefs.setInt(_tourSkipCountKey, currentCount + 1);
  }

  static Future<void> resetTourData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tourCompletedKey);
    await prefs.remove(_tourLastShownKey);
    await prefs.remove(_tourSkipCountKey);
    // Keep tour_prompt_shown so we don't spam users
  }
}
