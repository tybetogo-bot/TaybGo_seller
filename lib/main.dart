import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/router/app_router.dart';
import 'core/config/constants.dart';
import 'core/i18n/i18n.dart';
import 'core/providers/providers.dart';
import 'core/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      child: const TybeToGoApp(),
    ),
  );
}

/// Main application widget
class TybeToGoApp extends ConsumerWidget {
  const TybeToGoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    // Watch translations to ensure they reload when locale changes
    ref.watch(translationsLoadedProvider);

    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'TybeToGo Seller',
          debugShowCheckedModeBanner: false,

          // Theme
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
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
            final constrainedTextScaleFactor = mediaQueryData.textScaler.clamp(
              minScaleFactor: 0.8,
              maxScaleFactor: 1.2,
            );

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
        );
      },
    );
  }
}
