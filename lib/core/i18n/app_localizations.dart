import 'package:flutter/material.dart';

/// Supported locales
class AppLocales {
  AppLocales._();

  static const Locale english = Locale('en', 'US');
  static const Locale arabic = Locale('ar', 'SA');
  static const Locale german = Locale('de', 'DE');
  static const Locale french = Locale('fr', 'FR');

  static const List<Locale> supportedLocales = [
    english,
    arabic,
    german,
    french,
  ];

  static const Locale defaultLocale = english;

  /// Check if locale is RTL
  static bool isRTL(Locale locale) {
    return locale.languageCode == 'ar';
  }

  /// Get locale name
  static String getLocaleName(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return 'العربية';
      case 'de':
        return 'Deutsch';
      case 'fr':
        return 'Français';
      case 'en':
      default:
        return 'English';
    }
  }

  /// Get locale by code
  static Locale? getLocaleByCode(String code) {
    try {
      return supportedLocales.firstWhere((l) => l.languageCode == code);
    } catch (_) {
      return null;
    }
  }
}

/// App strings (can be extended with intl package or json files)
class AppStrings {
  AppStrings._();

  // ============ Common ============
  static const String appName = 'TybeToGo Seller';
  static const String appNameAr = 'تايب تو جو البائع';

  // ============ Auth ============
  static const String login = 'Login';
  static const String loginAr = 'تسجيل الدخول';
  static const String register = 'Register';
  static const String registerAr = 'إنشاء حساب';
  static const String email = 'Email';
  static const String emailAr = 'البريد الإلكتروني';
  static const String password = 'Password';
  static const String passwordAr = 'كلمة المرور';
  static const String forgotPassword = 'Forgot Password?';
  static const String forgotPasswordAr = 'نسيت كلمة المرور؟';
  static const String signInWithGoogle = 'Sign in with Google';
  static const String signInWithGoogleAr = 'تسجيل الدخول بجوجل';
  static const String signInWithApple = 'Sign in with Apple';
  static const String signInWithAppleAr = 'تسجيل الدخول بأبل';

  // ============ Navigation ============
  static const String home = 'Home';
  static const String homeAr = 'الرئيسية';
  static const String orders = 'Orders';
  static const String ordersAr = 'الطلبات';
  static const String menu = 'Menu';
  static const String menuAr = 'القائمة';
  static const String profile = 'Profile';
  static const String profileAr = 'الملف الشخصي';
  static const String settings = 'Settings';
  static const String settingsAr = 'الإعدادات';

  // ============ Orders ============
  static const String newOrders = 'New Orders';
  static const String newOrdersAr = 'طلبات جديدة';
  static const String activeOrders = 'Active Orders';
  static const String activeOrdersAr = 'طلبات نشطة';
  static const String completedOrders = 'Completed';
  static const String completedOrdersAr = 'مكتملة';
  static const String acceptOrder = 'Accept';
  static const String acceptOrderAr = 'قبول';
  static const String rejectOrder = 'Reject';
  static const String rejectOrderAr = 'رفض';
  static const String orderDetails = 'Order Details';
  static const String orderDetailsAr = 'تفاصيل الطلب';

  // ============ Menu ============
  static const String categories = 'Categories';
  static const String categoriesAr = 'التصنيفات';
  static const String items = 'Items';
  static const String itemsAr = 'العناصر';
  static const String addItem = 'Add Item';
  static const String addItemAr = 'إضافة عنصر';
  static const String editItem = 'Edit Item';
  static const String editItemAr = 'تعديل العنصر';
  static const String itemName = 'Item Name';
  static const String itemNameAr = 'اسم العنصر';
  static const String price = 'Price';
  static const String priceAr = 'السعر';
  static const String description = 'Description';
  static const String descriptionAr = 'الوصف';
  static const String available = 'Available';
  static const String availableAr = 'متوفر';
  static const String unavailable = 'Unavailable';
  static const String unavailableAr = 'غير متوفر';

  // ============ Actions ============
  static const String save = 'Save';
  static const String saveAr = 'حفظ';
  static const String cancel = 'Cancel';
  static const String cancelAr = 'إلغاء';
  static const String delete = 'Delete';
  static const String deleteAr = 'حذف';
  static const String edit = 'Edit';
  static const String editAr = 'تعديل';
  static const String confirm = 'Confirm';
  static const String confirmAr = 'تأكيد';
  static const String submit = 'Submit';
  static const String submitAr = 'إرسال';
  static const String retry = 'Retry';
  static const String retryAr = 'إعادة المحاولة';

  // ============ Status ============
  static const String pending = 'Pending';
  static const String pendingAr = 'قيد الانتظار';
  static const String accepted = 'Accepted';
  static const String acceptedAr = 'مقبول';
  static const String preparing = 'Preparing';
  static const String preparingAr = 'جاري التحضير';
  static const String ready = 'Ready';
  static const String readyAr = 'جاهز';
  static const String delivered = 'Delivered';
  static const String deliveredAr = 'تم التوصيل';
  static const String cancelled = 'Cancelled';
  static const String cancelledAr = 'ملغي';

  // ============ Errors ============
  static const String error = 'Error';
  static const String errorAr = 'خطأ';
  static const String somethingWentWrong = 'Something went wrong';
  static const String somethingWentWrongAr = 'حدث خطأ ما';
  static const String noInternet = 'No internet connection';
  static const String noInternetAr = 'لا يوجد اتصال بالإنترنت';
  static const String sessionExpired = 'Session expired';
  static const String sessionExpiredAr = 'انتهت صلاحية الجلسة';

  // ============ Empty States ============
  static const String noOrders = 'No orders yet';
  static const String noOrdersAr = 'لا توجد طلبات';
  static const String noItems = 'No items yet';
  static const String noItemsAr = 'لا توجد عناصر';

  // ============ Validation ============
  static const String required = 'This field is required';
  static const String requiredAr = 'هذا الحقل مطلوب';
  static const String invalidEmail = 'Invalid email address';
  static const String invalidEmailAr = 'بريد إلكتروني غير صالح';
  static const String invalidPassword = 'Password must be at least 8 characters';
  static const String invalidPasswordAr = 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
  static const String invalidPhone = 'Invalid phone number';
  static const String invalidPhoneAr = 'رقم هاتف غير صالح';
}
