/// Application constants
/// Contains all constant values used throughout the app
library;

import 'env_config.dart';

/// Deployment configuration constants
abstract class DeploymentConfig {
  /// Base URL for web deployment (used for QR code generation)
  static String get baseUrl => EnvConfig.webBaseUrl;
}

/// Storage keys for SharedPreferences/Hive
abstract class StorageKeys {
  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userRole = 'user_role';
  static const String themeMode = 'theme_mode';
  static const String accentColor = 'accent_color';
  static const String locale = 'locale';
  static const String currency = 'currency';
  static const String onboardingComplete = 'onboarding_complete';
  static const String fcmToken = 'fcm_token';
  static const String lastSyncTime = 'last_sync_time';
  static const String restaurantId = 'restaurant_id';
  static const String selectedCity = 'selected_city';
}

/// API endpoints
abstract class ApiEndpoints {
  // Auth - OTP
  static const String otpRequest = '/api/auth/otp/request/';
  static const String otpVerify = '/api/auth/otp/verify/';

  // Auth - Token
  static const String tokenRefresh = '/api/auth/token/refresh/';
  static const String tokenBlacklist = '/api/auth/token/blacklist/';
  static const String tokenVerify = '/api/auth/token/verify/';

  // User Profile
  static const String me = '/api/me/';
  static const String sellerProfile = '/api/seller/profile/';

  // Addresses
  static const String addresses = '/api/addresses/';
  static String address(int id) => '/api/addresses/$id/';

  // Seller Restaurants
  static const String sellerRestaurants = '/api/seller/restaurants/';
  static String sellerRestaurant(String id) => '/api/seller/restaurants/$id/';

  // Seller Categories
  static const String sellerCategories = '/api/seller/categories/';
  static String sellerCategory(String id) => '/api/seller/categories/$id/';

  // Seller Menu Items
  static const String sellerItems = '/api/seller/items/';
  static String sellerItem(String id) => '/api/seller/items/$id/';
  static String sellerItemStats(String id) => '/api/seller/items/$id/stats/';

  // Seller Orders
  static const String sellerOrders = '/api/seller/orders/';
  static String sellerOrder(String id) => '/api/seller/orders/$id/';
  static String sellerOrderStatus(String id) =>
      '/api/seller/orders/$id/status/';
  static String sellerOrderRefund(String id) =>
      '/api/seller/orders/$id/refund/';
  static const String sellerOrdersManual = '/api/seller/orders/manual/';
  static const String sellerOrdersExportExcel =
      '/api/seller/orders/export/excel/';
  static const String sellerOrdersExportPdf = '/api/seller/orders/export/pdf/';

  // Order extraction
  static const String ordersExtractDraft = '/api/orders/extract-draft/';

  // Seller Coupons
  static const String sellerCoupons = '/api/seller/coupons/';
  static String sellerCoupon(String id) => '/api/seller/coupons/$id/';

  // Notifications
  static const String notifications = '/api/notifications';
  static String notification(int id) => '/api/notifications/$id';
  static const String notificationsDevice = '/api/notifications/device';

  // Seller Earnings
  static const String sellerEarnings = '/api/seller/earnings/';

  // Config
  static const String configLegal = '/api/config/legal';
  static const String configVersion = '/api/config/version';
}

/// Order status values - matches API OrderStatusEnum
abstract class OrderStatus {
  static const String pending = 'PENDING';
  static const String searchingForDriver = 'SEARCHING_FOR_DRIVER';
  static const String driverNotificationSent = 'DRIVER_NOTIFICATION_SENT';
  static const String accepted = 'ACCEPTED';
  static const String onTheWay = 'ON_THE_WAY';
  static const String delivered = 'DELIVERED';
  static const String restaurantDelivered = 'RESTAURANT_DELIVERED';
  static const String completed = 'COMPLETED';
  static const String expired = 'EXPIRED';
  static const String rejected = 'REJECTED';
  static const String cancelled = 'CANCELLED';
}

/// User roles
abstract class UserRoles {
  static const String customer = 'customer';
  static const String seller = 'seller';
  static const String vendor = 'vendor';
  static const String owner = 'owner';
  static const String admin = 'admin';
}

/// Asset paths
abstract class AssetPaths {
  static const String images = 'assets/images';
  static const String icons = 'assets/icons';
  static const String animations = 'assets/animations';
  static const String translations = 'assets/translations';

  // Specific assets
  static const String logo = '$icons/TaybGo_green.png';
  static const String logoWhite = '$icons/TaybGo_white.png';
  static const String placeholder = '$images/placeholder.png';
  static const String emptyOrders = '$images/empty_orders.png';
  static const String emptyMenu = '$images/empty_menu.png';
  static const String noInternet = '$images/no_internet.png';
  static const String error = '$images/error.png';
}

/// Regex patterns for validation
abstract class ValidationPatterns {
  static final RegExp email = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  static final RegExp phone = RegExp(r'^\+?[0-9]{10,15}$');
  static final RegExp password = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*#?&]{8,}$',
  );
  static final RegExp name = RegExp(r'^[a-zA-Z\u0600-\u06FF\s]{2,50}$');
  static final RegExp price = RegExp(r'^\d+\.?\d{0,2}$');
}
