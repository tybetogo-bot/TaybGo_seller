/// Route paths and names
class Routes {
  Routes._();

  // ============ Splash ============
  static const String splash = '/splash';
  static const String splashName = 'splash';

  // ============ Auth ============
  static const String login = '/login';
  static const String loginName = 'login';

  static const String register = '/register';
  static const String registerName = 'register';

  static const String forgotPassword = '/forgot-password';
  static const String forgotPasswordName = 'forgotPassword';

  static const String otp = '/otp';
  static const String otpName = 'otp';

  // ============ Restaurant Selection ============
  static const String restaurantSelection = '/restaurant-selection';
  static const String restaurantSelectionName = 'restaurantSelection';

  // ============ Main Tabs ============
  static const String home = '/home';
  static const String homeName = 'home';

  static const String orders = '/orders';
  static const String ordersName = 'orders';

  static const String menu = '/menu';
  static const String menuName = 'menu';

  static const String profile = '/profile';
  static const String profileName = 'profile';

  // ============ Orders ============
  static const String orderDetails = '/orders/details/:orderId';
  static const String orderDetailsName = 'orderDetails';

  static const String createOrder = '/orders/create';
  static const String createOrderName = 'createOrder';

  static const String scanOrder = '/orders/scan';
  static const String scanOrderName = 'scanOrder';

  // ============ Menu ============
  static const String menuItem = '/menu/item/:itemId';
  static const String menuItemName = 'menuItem';

  static const String addMenuItem = '/menu/add';
  static const String addMenuItemName = 'addMenuItem';

  static const String categories = '/menu/categories';
  static const String categoriesName = 'categories';

  // ============ Profile ============
  static const String settings = '/profile/settings';
  static const String settingsName = 'settings';

  static const String restaurantSettings = '/profile/restaurant';
  static const String restaurantSettingsName = 'restaurantSettings';

  static const String coupons = '/profile/coupons';
  static const String couponsName = 'coupons';

  // ============ Coupons ============
  static const String addCoupon = '/coupons/add';
  static const String addCouponName = 'addCoupon';

  static const String editCoupon = '/coupons/edit/:couponId';
  static const String editCouponName = 'editCoupon';

  /// Get edit coupon path with id
  static String editCouponPath(String couponId) => '/coupons/edit/$couponId';

  static const String statistics = '/profile/statistics';
  static const String statisticsName = 'statistics';

  static const String notifications = '/profile/notifications';
  static const String notificationsName = 'notifications';

  static const String language = '/profile/language';
  static const String languageName = 'language';

  static const String currency = '/profile/currency';
  static const String currencyName = 'currency';

  static const String help = '/profile/help';
  static const String helpName = 'help';

  static const String about = '/profile/about';
  static const String aboutName = 'about';

  // ============ Helper Methods ============

  /// Get order details path with id
  static String orderDetailsPath(String orderId) => '/orders/details/$orderId';

  /// Get menu item path with id
  static String menuItemPath(String itemId) => '/menu/item/$itemId';
}
