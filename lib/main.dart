import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/router/app_router.dart';
import 'app/router/routes.dart';
import 'core/config/config.dart';
import 'core/i18n/i18n.dart';
import 'core/providers/providers.dart';
import 'core/services/push_notification_service.dart';
import 'core/theme/theme.dart';
import 'features/tour/application/tour_notifier.dart';
import 'features/tour/presentation/widgets/tour_overlay.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize push notification service (non-blocking so it doesn't stall the app)
  PushNotificationService.instance.initialize();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Load initial translations before app starts
  final savedLocaleCode = sharedPreferences.getString(StorageKeys.locale);
  final initialLocale = savedLocaleCode != null
      ? AppLocales.getLocaleByCode(savedLocaleCode) ?? AppLocales.defaultLocale
      : AppLocales.defaultLocale;
  await TranslationService.instance.load(initialLocale);

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const TaybGoApp(),
    ),
  );
}

/// Main application widget
class TaybGoApp extends ConsumerWidget {
  const TaybGoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final accentColor = ref.watch(accentColorProvider);

    // Watch translations to ensure they reload when locale changes
    ref.watch(translationsLoadedProvider);

    // Set up global unauthorized callback to handle 401 errors
    // This callback will be called by the AuthInterceptor when a 401 error occurs
    globalUnauthorizedCallback = () {
      // Check if we're on a public route - don't redirect if so
      final currentLocation =
          router.routerDelegate.currentConfiguration.uri.path;
      if (currentLocation.startsWith('/public-menu')) {
        print(
          '🟡 [UnauthorizedCallback] On public route, skipping login redirect',
        );
        return;
      }

      // Check if tour is active — log this prominently so we can catch it
      final tourState = ref.read(tourProvider);
      if (tourState.isActive) {
        print(
          '🔴🎯 [UnauthorizedCallback] 401 fired DURING ACTIVE TOUR! '
          'step=${tourState.currentStepIndex}, route=$currentLocation. '
          'This will KILL the tour!',
        );
      }

      // Navigate to login screen when token is invalid (only for protected routes)
      print(
        '🔴 [UnauthorizedCallback] Unauthorized on protected route, redirecting to login',
      );
      router.go(Routes.login);
    };

    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return TourOverlay(
          child: MaterialApp.router(
            title: EnvConfig.appName,
            debugShowCheckedModeBanner: EnvConfig.showDebugBanner,

            // Theme with dynamic accent color
            theme: AppTheme.lightWithAccent(accentColor),
            darkTheme: AppTheme.darkWithAccent(accentColor),
            themeMode: themeMode,

            // Routing
            routerConfig: router,

            // Localization
            locale: locale,
            supportedLocales: AppLocales.supportedLocales,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // Builder for screen utils and text scaling
            builder: (context, child) {
              // Limit text scaling for accessibility
              final mediaQueryData = MediaQuery.of(context);
              final constrainedTextScaleFactor = mediaQueryData.textScaler
                  .clamp(minScaleFactor: 0.8, maxScaleFactor: 1.2);

              return MediaQuery(
                data: mediaQueryData.copyWith(
                  textScaler: constrainedTextScaleFactor,
                ),
                // Dismiss keyboard when tapping outside of input fields
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: child ?? const SizedBox.shrink(),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
