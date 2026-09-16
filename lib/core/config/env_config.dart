/// Environment configuration
/// Reads compile-time constants passed via --dart-define
library;

enum Environment { dev, prod }

class EnvConfig {
  EnvConfig._();

  static const String websiteUrl = 'https://taybgo.com';
  static const String supportEmail = 'support@taybgo.com';

  static const String _env = String.fromEnvironment('ENV', defaultValue: 'dev');
  static const String _apiBaseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
  );

  static Environment get environment =>
      _env == 'prod' ? Environment.prod : Environment.dev;

  static bool get isDev => environment == Environment.dev;
  static bool get isProd => environment == Environment.prod;

  /// API base URL
  static String get apiBaseUrl => _apiBaseUrlOverride.isNotEmpty
      ? _apiBaseUrlOverride
      : (isDev ? 'https://dev.taybgo.com' : 'https://taybgo.com');

  /// App display name
  static String get appName => isDev ? 'Seller Dev' : 'TaybGo Seller';

  /// App display name (Arabic)
  static String get appNameAr => isDev ? 'البائع تطوير' : 'طيب قو البائع';

  /// Web deployment base URL
  static String get webBaseUrl =>
      isDev ? 'https://dev-seller.taybgo.com' : 'https://sellertaybgo.web.app';

  /// Whether to show debug banner and verbose logging
  static bool get showDebugBanner => isDev;

  /// Whether to enable verbose network logging
  static bool get enableNetworkLogging => isDev;
}
