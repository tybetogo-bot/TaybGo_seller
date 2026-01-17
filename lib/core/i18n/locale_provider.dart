import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/constants.dart';
import '../providers/providers.dart' show sharedPreferencesProvider;
import 'app_localizations.dart';

/// Locale state notifier (Riverpod 3.x)
class LocaleNotifier extends Notifier<Locale> {
  late SharedPreferences _prefs;

  @override
  Locale build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    return _loadInitialLocale(_prefs);
  }

  static Locale _loadInitialLocale(SharedPreferences prefs) {
    final savedCode = prefs.getString(StorageKeys.locale);
    if (savedCode != null) {
      return AppLocales.getLocaleByCode(savedCode) ?? AppLocales.defaultLocale;
    }
    return AppLocales.defaultLocale;
  }

  /// Set locale
  Future<void> setLocale(Locale locale) async {
    if (AppLocales.supportedLocales.contains(locale)) {
      state = locale;
      await _prefs.setString(StorageKeys.locale, locale.languageCode);
    }
  }

  /// Set locale by language code
  Future<void> setLocaleByCode(String code) async {
    final locale = AppLocales.getLocaleByCode(code);
    if (locale != null) {
      await setLocale(locale);
    }
  }

  /// Check if current locale is RTL
  bool get isRTL => AppLocales.isRTL(state);

  /// Get text direction based on current locale
  TextDirection get textDirection => isRTL ? TextDirection.rtl : TextDirection.ltr;

  /// Get locale name
  String get localeName => AppLocales.getLocaleName(state);

  /// Toggle between English and Arabic
  Future<void> toggleLocale() async {
    if (state.languageCode == 'ar') {
      await setLocale(AppLocales.english);
    } else {
      await setLocale(AppLocales.arabic);
    }
  }
}

/// Provider for locale (Riverpod 3.x)
final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

/// Provider for RTL check
final isRTLProvider = Provider<bool>((ref) {
  final locale = ref.watch(localeProvider);
  return AppLocales.isRTL(locale);
});

/// Provider for text direction
final textDirectionProvider = Provider<TextDirection>((ref) {
  final isRTL = ref.watch(isRTLProvider);
  return isRTL ? TextDirection.rtl : TextDirection.ltr;
});

/// Provider for supported locales
final supportedLocalesProvider = Provider<List<Locale>>((ref) {
  return AppLocales.supportedLocales;
});

/// Simple localized string helper
/// In production, use a proper localization solution like intl or easy_localization
class L10n {
  L10n._();

  static String get(String key, Locale locale) {
    // This is a simplified version
    // In production, load from JSON files or use intl package
    final isArabic = locale.languageCode == 'ar';

    final strings = <String, Map<String, String>>{
      'appName': {'en': AppStrings.appName, 'ar': AppStrings.appNameAr},
      'login': {'en': AppStrings.login, 'ar': AppStrings.loginAr},
      'register': {'en': AppStrings.register, 'ar': AppStrings.registerAr},
      'email': {'en': AppStrings.email, 'ar': AppStrings.emailAr},
      'password': {'en': AppStrings.password, 'ar': AppStrings.passwordAr},
      'forgotPassword': {'en': AppStrings.forgotPassword, 'ar': AppStrings.forgotPasswordAr},
      'home': {'en': AppStrings.home, 'ar': AppStrings.homeAr},
      'orders': {'en': AppStrings.orders, 'ar': AppStrings.ordersAr},
      'menu': {'en': AppStrings.menu, 'ar': AppStrings.menuAr},
      'profile': {'en': AppStrings.profile, 'ar': AppStrings.profileAr},
      'settings': {'en': AppStrings.settings, 'ar': AppStrings.settingsAr},
      'save': {'en': AppStrings.save, 'ar': AppStrings.saveAr},
      'cancel': {'en': AppStrings.cancel, 'ar': AppStrings.cancelAr},
      'delete': {'en': AppStrings.delete, 'ar': AppStrings.deleteAr},
      'edit': {'en': AppStrings.edit, 'ar': AppStrings.editAr},
      'confirm': {'en': AppStrings.confirm, 'ar': AppStrings.confirmAr},
      'error': {'en': AppStrings.error, 'ar': AppStrings.errorAr},
      'required': {'en': AppStrings.required, 'ar': AppStrings.requiredAr},
    };

    final langCode = isArabic ? 'ar' : 'en';
    return strings[key]?[langCode] ?? key;
  }
}

/// Extension for easy localization in widgets
extension LocalizationExtension on BuildContext {
  /// Get localized string
  String tr(String key) {
    // In production, use proper localization
    return key;
  }

  /// Check if current locale is RTL
  bool get isRTL {
    return Directionality.of(this) == TextDirection.rtl;
  }
}
