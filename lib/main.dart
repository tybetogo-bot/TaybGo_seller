import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
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
import 'core/responsive/responsive.dart';
import 'core/services/push_notification_service.dart';
import 'core/theme/theme.dart';
import 'features/auth/application/auth_state.dart';
import 'features/tour/application/tour_notifier.dart';
import 'features/tour/presentation/widgets/tour_overlay.dart';
import 'firebase_options.dart';
import 'shared/widgets/required_update_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (!kIsWeb) {
    await FirebaseCrashlytics.instance.setCustomKey(
      'environment',
      EnvConfig.environment.name,
    );

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  // Initialize push notification service (non-blocking so it doesn't stall the app)
  PushNotificationService.instance.initialize();

  // Orientation lock: portrait-only on phones (the rotation policy is then
  // enforced per-frame in [TaybGoApp.build] based on the current screen
  // width). We start with portrait by default so handsets don't briefly
  // rotate during startup.
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
    globalUnauthorizedCallback = () async {
      await ref.read(authProvider.notifier).handleUnauthorized();

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

    // ScreenUtil scales sizes proportionally to screen width using a 375px
    // (iPhone X) design reference. On wide screens (tablets, web/desktop)
    // this would multiply every dimension by 2-3x and make the UI look
    // ridiculous. We wrap it in a [LayoutBuilder] and clamp the effective
    // design width on larger screens so sizes plateau at ~tablet density
    // instead of scaling without bound. Layout reorganization (columns,
    // navigation rail, master-detail) happens on top of this via the
    // responsive widgets in [core/responsive].
    return LayoutBuilder(
      builder: (context, constraints) {
        final rawWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 375.0;
        // Phones use the natural 375 reference; on tablet+ we cap the scale
        // at 480/375 = 1.28x so dimensions stay close to phone values and
        // layout work (grids, max-widths) does the rest.
        const double maxScaleMultiplier = 1.28;
        final effectiveDesignWidth = rawWidth <= 480
            ? 375.0
            : rawWidth / maxScaleMultiplier;
        // Apply the per-frame orientation policy: free on tablet+, locked
        // on phone. Doing this in build means rotations on tablets stick
        // after the user resizes a desktop window across the breakpoint too.
        _applyOrientationPolicy(rawWidth);
        return ScreenUtilInit(
          designSize: Size(effectiveDesignWidth, 812),
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

                  return RequiredUpdateGate(
                    child: MediaQuery(
                      data: mediaQueryData.copyWith(
                        textScaler: constrainedTextScaleFactor,
                      ),
                      child: _DebugCrashlyticsTester(
                        // Dismiss keyboard when tapping outside of input fields
                        child: GestureDetector(
                          onTap: () => FocusScope.of(context).unfocus(),
                          child: child ?? const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

/// Track the orientation policy already applied so we don't spam the
/// platform channel on every rebuild.
List<DeviceOrientation>? _appliedOrientations;

/// Allow free rotation on tablet+ and desktop, lock phones to portrait.
///
/// Called from [TaybGoApp.build] with the current logical screen width so
/// rotations are re-evaluated when the user resizes a desktop window across
/// the tablet breakpoint or hot-restarts on a different form factor.
void _applyOrientationPolicy(double width) {
  final orientations = width >= Breakpoints.tablet
      ? <DeviceOrientation>[
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]
      : <DeviceOrientation>[
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ];

  if (_appliedOrientations != null &&
      _appliedOrientations!.length == orientations.length &&
      _appliedOrientations!.every(orientations.contains)) {
    return;
  }
  _appliedOrientations = orientations;
  // Fire-and-forget — SystemChrome calls are cheap and we don't need to
  // await them during a build.
  SystemChrome.setPreferredOrientations(orientations);
}

class _DebugCrashlyticsTester extends StatelessWidget {
  const _DebugCrashlyticsTester({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode || kIsWeb || !EnvConfig.isDev) {
      return child;
    }

    return Stack(
      children: [
        child,
        Positioned(
          right: 16,
          bottom: 24,
          child: SafeArea(
            child: FloatingActionButton.small(
              heroTag: 'crashlyticsTestFab',
              tooltip: 'Crashlytics test',
              onPressed: () => _showCrashlyticsTestSheet(context),
              child: const Icon(Icons.bug_report_outlined),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _recordNonFatal(BuildContext context) async {
    await FirebaseCrashlytics.instance.recordError(
      StateError('Crashlytics non-fatal test'),
      StackTrace.current,
      reason: 'Manual Crashlytics test from debug menu',
      fatal: false,
    );

    if (!context.mounted) return;

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Crashlytics non-fatal test sent')),
    );
  }

  void _showCrashlyticsTestSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.report_outlined),
                title: const Text('Record non-fatal test'),
                onTap: () => _recordNonFatal(context),
              ),
              ListTile(
                leading: const Icon(Icons.dangerous_outlined),
                title: const Text('Crash app'),
                onTap: () {
                  Navigator.of(context).pop();
                  Future<void>.delayed(
                    const Duration(milliseconds: 250),
                    FirebaseCrashlytics.instance.crash,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
