import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_localizations.dart';
import 'locale_provider.dart';

/// Translation service for loading and accessing translations from JSON files
class TranslationService {
  TranslationService._();

  static final TranslationService _instance = TranslationService._();
  static TranslationService get instance => _instance;

  Map<String, dynamic> _translations = {};
  String _currentLanguage = 'en';
  bool _isLoaded = false;

  /// Check if translations are loaded
  bool get isLoaded => _isLoaded;

  /// Get current language code
  String get currentLanguage => _currentLanguage;

  /// Load translations for a specific locale
  Future<void> load(Locale locale) async {
    final languageCode = locale.languageCode;

    try {
      // Clear asset cache to ensure fresh load
      rootBundle.evict('assets/translations/$languageCode.json');
      
      // Load the translation file
      final jsonString = await rootBundle.loadString(
        'assets/translations/$languageCode.json',
      );
      _translations = json.decode(jsonString) as Map<String, dynamic>;
      _currentLanguage = languageCode;
      _isLoaded = true;
      debugPrint('Loaded translations for $languageCode');
    } catch (e) {
      // Fallback to English if translation file not found
      if (languageCode != 'en') {
        debugPrint('Translation file for $languageCode not found, falling back to English');
        await load(AppLocales.english);
      } else {
        debugPrint('Error loading translations: $e');
        _translations = {};
        _isLoaded = false;
      }
    }
  }

  /// Get a translated string by key
  /// Key format: 'category.subcategory.key' e.g., 'common.save', 'orders.status.pending'
  String translate(String key, {Map<String, String>? params}) {
    final keys = key.split('.');
    dynamic value = _translations;

    for (final k in keys) {
      if (value is Map<String, dynamic> && value.containsKey(k)) {
        value = value[k];
      } else {
        // Return key if translation not found
        return key;
      }
    }

    if (value is! String) {
      return key;
    }

    // Replace parameters in the string
    var result = value;
    if (params != null) {
      params.forEach((paramKey, paramValue) {
        result = result.replaceAll('{$paramKey}', paramValue);
      });
    }

    return result;
  }

  /// Get translation with pluralization
  String translatePlural(String key, int count, {Map<String, String>? params}) {
    final baseParams = {'count': count.toString(), ...?params};
    
    // Try to get plural form first
    if (count == 0) {
      final zeroKey = '${key}_zero';
      final zeroTranslation = translate(zeroKey, params: baseParams);
      if (zeroTranslation != zeroKey) return zeroTranslation;
    } else if (count == 1) {
      final oneKey = '${key}_one';
      final oneTranslation = translate(oneKey, params: baseParams);
      if (oneTranslation != oneKey) return oneTranslation;
    }
    
    // Fallback to regular or plural form
    final pluralKey = '${key}_other';
    final pluralTranslation = translate(pluralKey, params: baseParams);
    if (pluralTranslation != pluralKey) return pluralTranslation;
    
    return translate(key, params: baseParams);
  }
}

/// Provider for translation service
final translationServiceProvider = Provider<TranslationService>((ref) {
  return TranslationService.instance;
});

/// Provider that loads translations when locale changes
final translationsLoadedProvider = FutureProvider<bool>((ref) async {
  final locale = ref.watch(localeProvider);
  await TranslationService.instance.load(locale);
  return TranslationService.instance.isLoaded;
});

/// Extension on String for easy translation access
extension TranslationExtension on String {
  /// Translate this string key
  /// Usage: 'common.save'.tr or 'orders.title'.tr
  String get tr => TranslationService.instance.translate(this);

  /// Translate with parameters
  /// Usage: 'auth.resendIn'.trParams({'seconds': '30'})
  String trParams(Map<String, String> params) {
    return TranslationService.instance.translate(this, params: params);
  }

  /// Translate with pluralization
  /// Usage: 'orders.itemCount'.trPlural(5)
  String trPlural(int count, {Map<String, String>? params}) {
    return TranslationService.instance.translatePlural(this, count, params: params);
  }
}

/// Widget that ensures translations are loaded before building
class TranslationLoader extends ConsumerWidget {
  const TranslationLoader({
    super.key,
    required this.child,
    this.loader,
  });

  final Widget child;
  final Widget? loader;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translationsAsync = ref.watch(translationsLoadedProvider);

    return translationsAsync.when(
      data: (_) => child,
      loading: () => loader ?? const SizedBox.shrink(),
      error: (_, __) => child, // Fallback to child even on error
    );
  }
}

/// Helper class for accessing translations in a type-safe way
class Tr {
  Tr._();

  // ============ Common ============
  static String get save => 'common.save'.tr;
  static String get cancel => 'common.cancel'.tr;
  static String get delete => 'common.delete'.tr;
  static String get edit => 'common.edit'.tr;
  static String get confirm => 'common.confirm'.tr;
  static String get error => 'common.error'.tr;
  static String get loading => 'common.loading'.tr;
  static String get retry => 'common.retry'.tr;
  static String get yes => 'common.yes'.tr;
  static String get no => 'common.no'.tr;
  static String get ok => 'common.ok'.tr;
  static String get close => 'common.close'.tr;
  static String get search => 'common.search'.tr;
  static String get add => 'common.add'.tr;
  static String get update => 'common.update'.tr;
  static String get submit => 'common.submit'.tr;
  static String get back => 'common.back'.tr;
  static String get next => 'common.next'.tr;
  static String get done => 'common.done'.tr;
  static String get noData => 'common.noData'.tr;
  static String get success => 'common.success'.tr;
  static String get warning => 'common.warning'.tr;

  // ============ Navigation ============
  static String get home => 'navigation.home'.tr;
  static String get orders => 'navigation.orders'.tr;
  static String get menu => 'navigation.menu'.tr;
  static String get profile => 'navigation.profile'.tr;

  // ============ Auth ============
  static String get phoneNumber => 'auth.phoneNumber'.tr;
  static String get enterPhone => 'auth.enterPhone'.tr;
  static String get enterOtp => 'auth.enterOtp'.tr;
  static String get sendOtp => 'auth.sendOtp'.tr;
  static String get verifyOtp => 'auth.verifyOtp'.tr;
  static String get resendOtp => 'auth.resendOtp'.tr;
  static String resendIn(int seconds) => 'auth.resendIn'.trParams({'seconds': seconds.toString()});
  static String get logout => 'auth.logout'.tr;
  static String get logoutConfirm => 'auth.logoutConfirm'.tr;

  // ============ Orders ============
  static String get ordersTitle => 'orders.title'.tr;
  static String get ordersNew => 'orders.new'.tr;
  static String get ordersActive => 'orders.active'.tr;
  static String get ordersDone => 'orders.done'.tr;
  static String get createOrder => 'orders.createOrder'.tr;
  static String get orderDetails => 'orders.orderDetails'.tr;
  static String get acceptOrder => 'orders.acceptOrder'.tr;
  static String get rejectOrder => 'orders.rejectOrder'.tr;

  // ============ Menu ============
  static String get menuTitle => 'menu.title'.tr;
  static String get addItem => 'menu.addItem'.tr;
  static String get editItem => 'menu.editItem'.tr;
  static String get itemName => 'menu.itemName'.tr;
  static String get price => 'menu.price'.tr;
  static String get description => 'menu.description'.tr;
  static String get ingredients => 'menu.ingredients'.tr;
  static String get customizations => 'menu.customizations'.tr;
  static String get available => 'menu.available'.tr;
  static String get unavailable => 'menu.unavailable'.tr;
  static String get categories => 'menu.categories'.tr;

  // ============ Coupons ============
  static String get couponsTitle => 'coupons.title'.tr;
  static String get addCoupon => 'coupons.addCoupon'.tr;
  static String get editCoupon => 'coupons.editCoupon'.tr;
  static String get couponCode => 'coupons.code'.tr;
  static String get discount => 'coupons.discount'.tr;
  static String get minPrice => 'coupons.minPrice'.tr;
  static String get validUntil => 'coupons.validUntil'.tr;
  static String get expired => 'coupons.expired'.tr;
  static String get active => 'coupons.active'.tr;

  // ============ Settings ============
  static String get settingsTitle => 'settings.title'.tr;
  static String get theme => 'settings.theme'.tr;
  static String get lightMode => 'settings.lightMode'.tr;
  static String get darkMode => 'settings.darkMode'.tr;
  static String get language => 'settings.language'.tr;
  static String get notifications => 'settings.notifications'.tr;

  // ============ Validation ============
  static String get required => 'validation.required'.tr;
  static String get invalidPhone => 'validation.invalidPhone'.tr;
  static String get invalidEmail => 'validation.invalidEmail'.tr;
  static String get invalidPrice => 'validation.invalidPrice'.tr;

  // ============ Errors ============
  static String get genericError => 'errors.generic'.tr;
  static String get networkError => 'errors.network'.tr;
  static String get serverError => 'errors.serverError'.tr;
  static String get unauthorized => 'errors.unauthorized'.tr;
}
