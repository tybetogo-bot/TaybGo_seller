/// Application configuration
/// Contains all app-wide configuration settings
library;

import 'env_config.dart';

class AppConfig {
  AppConfig._();

  // App Info (environment-aware)
  static String get appName => EnvConfig.appName;
  static String get appNameAr => EnvConfig.appNameAr;
  static const String appVersion = '1.0.3+4';

  // API Configuration (environment-aware)
  static String get apiBaseUrl => EnvConfig.apiBaseUrl;
  static const Duration apiTimeout = Duration(seconds: 15);

  // Environment
  static bool get isProduction => EnvConfig.isProd;
  static bool get isDevelopment => EnvConfig.isDev;

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
  static const List<String> allowedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}
