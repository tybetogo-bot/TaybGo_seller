/// Feature flags configuration
/// Use this to enable/disable features across the app
library;

/// All feature flags for the application
enum FeatureFlag {
  // ============ Core Features ============
  /// Enable dark mode theme switching
  darkMode(defaultValue: true, description: 'Dark mode theme support'),

  /// Enable multiple language support
  multiLanguage(defaultValue: true, description: 'Multi-language support'),

  /// Enable multiple currency support
  multiCurrency(defaultValue: true, description: 'Multi-currency support'),

  // ============ Auth Features ============
  /// Enable social login (Google, Apple)
  socialLogin(defaultValue: true, description: 'Social login options'),

  /// Enable Apple Sign In
  appleSignIn(defaultValue: true, description: 'Apple Sign In'),

  /// Enable Google Sign In
  googleSignIn(defaultValue: true, description: 'Google Sign In'),

  /// Enable phone number authentication
  phoneAuth(defaultValue: true, description: 'Phone number authentication'),

  /// Enable biometric authentication
  biometricAuth(defaultValue: false, description: 'Biometric authentication'),

  // ============ Order Features ============
  /// Enable order tracking
  orderTracking(defaultValue: true, description: 'Real-time order tracking'),

  /// Enable order scanning (QR/barcode)
  orderScanning(defaultValue: true, description: 'QR/Barcode order scanning'),

  /// Enable order notifications
  orderNotifications(defaultValue: true, description: 'Push notifications for orders'),

  /// Enable order history
  orderHistory(defaultValue: true, description: 'Order history view'),

  // ============ Menu Features ============
  /// Enable menu customizations
  menuCustomizations(defaultValue: true, description: 'Item customization options'),

  /// Enable menu item images
  menuImages(defaultValue: true, description: 'Menu item images'),

  /// Enable menu categories
  menuCategories(defaultValue: true, description: 'Menu categories'),

  /// Enable item availability toggle
  itemAvailability(defaultValue: true, description: 'Toggle item availability'),

  // ============ Promo Features ============
  /// Enable coupon/promo codes
  promoCodes(defaultValue: true, description: 'Promotional codes'),

  /// Enable discount management
  discounts(defaultValue: true, description: 'Discount management'),

  // ============ Vendor Features ============
  /// Enable vendor mode
  vendorMode(defaultValue: true, description: 'Vendor/Seller mode'),

  /// Enable vendor statistics
  vendorStatistics(defaultValue: true, description: 'Sales statistics'),

  /// Enable vendor coupons management
  vendorCoupons(defaultValue: true, description: 'Coupon management'),

  /// Enable manual order creation
  manualOrderCreation(defaultValue: true, description: 'Create orders manually'),

  /// Enable restaurant settings
  restaurantSettings(defaultValue: true, description: 'Restaurant profile settings'),

  // ============ Payment Features ============
  /// Enable cash on delivery
  cashOnDelivery(defaultValue: true, description: 'Cash on delivery payment'),

  /// Enable card payments
  cardPayments(defaultValue: true, description: 'Card payment option'),

  /// Enable Apple Pay
  applePay(defaultValue: false, description: 'Apple Pay integration'),

  /// Enable Google Pay
  googlePay(defaultValue: false, description: 'Google Pay integration'),

  // ============ Location Features ============
  /// Enable maps integration
  mapsIntegration(defaultValue: true, description: 'Google Maps integration'),

  /// Enable address verification
  addressVerification(defaultValue: true, description: 'Address verification via map'),

  /// Enable delivery zones
  deliveryZones(defaultValue: true, description: 'Delivery zone management'),

  // ============ Analytics Features ============
  /// Enable analytics tracking
  analytics(defaultValue: true, description: 'Analytics tracking'),

  /// Enable crash reporting
  crashReporting(defaultValue: true, description: 'Crash reporting'),

  // ============ Experimental Features ============
  /// Enable AI recommendations
  aiRecommendations(defaultValue: false, description: 'AI-powered recommendations'),

  /// Enable voice search
  voiceSearch(defaultValue: false, description: 'Voice search'),

  /// Enable AR menu preview
  arMenuPreview(defaultValue: false, description: 'AR menu item preview');

  const FeatureFlag({
    required this.defaultValue,
    required this.description,
  });

  /// Default value if not overridden
  final bool defaultValue;

  /// Human-readable description
  final String description;
}

/// Feature flag overrides storage
class FeatureFlagOverrides {
  FeatureFlagOverrides._();

  static final Map<FeatureFlag, bool> _overrides = {};

  /// Set an override for a feature flag
  static void setOverride(FeatureFlag flag, bool value) {
    _overrides[flag] = value;
  }

  /// Remove an override
  static void removeOverride(FeatureFlag flag) {
    _overrides.remove(flag);
  }

  /// Clear all overrides
  static void clearOverrides() {
    _overrides.clear();
  }

  /// Get the current value for a flag
  static bool getValue(FeatureFlag flag) {
    return _overrides[flag] ?? flag.defaultValue;
  }

  /// Check if a flag has an override
  static bool hasOverride(FeatureFlag flag) {
    return _overrides.containsKey(flag);
  }

  /// Get all current overrides
  static Map<FeatureFlag, bool> get allOverrides => Map.unmodifiable(_overrides);
}
