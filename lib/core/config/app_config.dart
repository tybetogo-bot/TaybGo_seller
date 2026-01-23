/// Application configuration
/// Contains all app-wide configuration settings
library;

class AppConfig {
  AppConfig._();

  // App Info
  static const String appName = 'TybeToGo Seller';
  static const String appNameAr = 'تايب تو جو البائع';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl = 'https://taybat-backend-dev.onrender.com';
  static const String stagingUrl = 'https://taybat-backend-dev.onrender.com';
  static const Duration apiTimeout = Duration(seconds: 15);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;

  // Cache
  static const Duration cacheValidDuration = Duration(minutes: 5);
  static const Duration imageCacheDuration = Duration(days: 7);

  // Maps
  static const double defaultLatitude = 52.520008; // Berlin
  static const double defaultLongitude = 13.404954;
  static const double defaultZoom = 14.0;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;
  static const int phoneNumberLength = 10;
  static const int otpLength = 6;

  // Order Settings
  static const Duration orderRefreshInterval = Duration(seconds: 30);
  static const int maxOrderItems = 50;

  // Image Upload
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Environment
  static bool get isProduction => const String.fromEnvironment('ENV') == 'production';
  static bool get isStaging => const String.fromEnvironment('ENV') == 'staging';
  static bool get isDevelopment => !isProduction && !isStaging;

  static String get apiBaseUrl => isProduction ? baseUrl : stagingUrl;
}
