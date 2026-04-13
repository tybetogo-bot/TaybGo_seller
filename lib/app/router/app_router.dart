import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/pending_review_screen.dart';
import '../../features/restaurant/presentation/screens/restaurant_selection_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/menu/presentation/screens/add_menu_item_screen.dart';
import '../../features/menu/presentation/screens/categories_screen.dart';
import '../../features/menu/presentation/screens/menu_screen.dart';
import '../../features/orders/presentation/screens/create_order_screen.dart';
import '../../features/orders/presentation/screens/order_details_screen.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';
import '../../features/orders/presentation/screens/scan_order_screen.dart';
import '../../features/profile/presentation/screens/about_screen.dart';
import '../../features/profile/presentation/screens/delete_account_screen.dart';
import '../../features/coupons/presentation/screens/add_edit_coupon_screen.dart';
import '../../features/profile/presentation/screens/coupons_screen.dart';
import '../../features/profile/presentation/screens/currency_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/knowledge_base/presentation/screens/knowledge_base_screen.dart';
import '../../features/profile/presentation/screens/help_screen.dart';
import '../../features/profile/presentation/screens/language_screen.dart';
import '../../features/profile/presentation/screens/notifications_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/restaurant_settings_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/earnings/presentation/screens/earnings_screen.dart';
import '../../features/profile/presentation/screens/statistics_screen.dart';
import '../../features/public_menu/presentation/screens/public_menu_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/support/presentation/screens/support_tickets_screen.dart';
import '../../features/support/presentation/screens/ticket_detail_screen.dart';
import '../../features/support/presentation/screens/create_ticket_screen.dart';
import '../shell/main_shell.dart';
import 'routes.dart';

/// App router provider
final routerProvider = Provider<GoRouter>((ref) {
  return AppRouter.router;
});

/// Main application router
class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    // No fixed initialLocation - redirect decides based on route
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final currentPath = state.uri.path;
      final isPublicMenuRoute = currentPath.startsWith('/public-menu');
      final isAuthRoute =
          currentPath == Routes.login ||
          currentPath == Routes.register ||
          currentPath == Routes.forgotPassword ||
          currentPath == Routes.otp;
      final isSplash = currentPath == Routes.splash;
      final isRoot = currentPath == '/';

      print('🔵 [Router] Checking redirect for: $currentPath');

      // Public menu routes - allow direct access without authentication
      if (isPublicMenuRoute) {
        print('🟢 [Router] Public menu - allowing direct access');
        return null;
      }

      // Auth routes - allow direct access
      if (isAuthRoute) {
        print('🟢 [Router] Auth route - allowing direct access');
        return null;
      }

      // Splash route - allow it
      if (isSplash) {
        print('🟢 [Router] Splash route - allowing');
        return null;
      }

      // Root or other protected routes - redirect to splash for auth check
      if (isRoot) {
        print('🟡 [Router] Root path - redirecting to splash');
        return Routes.splash;
      }

      // Restaurant selection, onboarding, and coupon routes
      if (currentPath == Routes.restaurantSelection ||
          currentPath == Routes.onboarding ||
          currentPath == Routes.pendingReview ||
          currentPath == Routes.standaloneKnowledgeBase ||
          currentPath == Routes.addCoupon ||
          currentPath.startsWith(Routes.editCoupon.split(':').first)) {
        return null;
      }

      // Allow all other routes - splash screen handles auth/restaurant checks
      // Don't redirect protected routes here to avoid redirect loops
      print(
        '🟢 [Router] Protected route - allowing (auth check handled by splash)',
      );
      return null;
    },
    routes: [
      // Splash screen
      GoRoute(
        path: Routes.splash,
        name: Routes.splashName,
        builder: (context, state) => const SplashScreen(),
      ),

      // Coupon routes (outside shell for full-screen experience)
      GoRoute(
        path: Routes.addCoupon,
        name: Routes.addCouponName,
        builder: (context, state) => const AddEditCouponScreen(),
      ),
      GoRoute(
        path: Routes.editCoupon,
        name: Routes.editCouponName,
        builder: (context, state) {
          final couponId = state.pathParameters['couponId']!;
          return AddEditCouponScreen(couponId: couponId);
        },
      ),

      // Auth routes (outside shell)
      GoRoute(
        path: Routes.login,
        name: Routes.loginName,
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: Routes.register,
        name: Routes.registerName,
        builder: (context, state) => const RegisterScreen(),
      ),

      GoRoute(
        path: Routes.forgotPassword,
        name: Routes.forgotPasswordName,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      GoRoute(
        path: Routes.otp,
        name: Routes.otpName,
        builder: (context, state) => const OtpScreen(),
      ),

      // Onboarding (outside shell)
      GoRoute(
        path: Routes.onboarding,
        name: Routes.onboardingName,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Pending review (outside shell)
      GoRoute(
        path: Routes.pendingReview,
        name: Routes.pendingReviewName,
        builder: (context, state) => const PendingReviewScreen(),
      ),

      // Standalone knowledge base (outside shell, for pending review)
      GoRoute(
        path: Routes.standaloneKnowledgeBase,
        name: Routes.standaloneKnowledgeBaseName,
        builder: (context, state) => const KnowledgeBaseScreen(),
      ),

      // Restaurant selection (outside shell)
      GoRoute(
        path: Routes.restaurantSelection,
        name: Routes.restaurantSelectionName,
        builder: (context, state) => const RestaurantSelectionScreen(),
      ),

      // Public menu (outside shell - no authentication required)
      GoRoute(
        path: Routes.publicMenu,
        name: Routes.publicMenuName,
        builder: (context, state) {
          final restaurantId = state.pathParameters['restaurantId']!;
          return PublicMenuScreen(restaurantId: restaurantId);
        },
      ),

      // Main app shell with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          // Home tab
          GoRoute(
            path: Routes.home,
            name: Routes.homeName,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomeScreen()),
          ),

          // Orders tab
          GoRoute(
            path: Routes.orders,
            name: Routes.ordersName,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: OrdersScreen()),
            routes: [
              GoRoute(
                path: 'details/:orderId',
                name: Routes.orderDetailsName,
                builder: (context, state) {
                  final orderId = state.pathParameters['orderId']!;
                  return OrderDetailsScreen(orderId: orderId);
                },
              ),
              GoRoute(
                path: 'create',
                name: Routes.createOrderName,
                builder: (context, state) => const CreateOrderScreen(),
              ),
              GoRoute(
                path: 'scan',
                name: Routes.scanOrderName,
                builder: (context, state) => const ScanOrderScreen(),
              ),
            ],
          ),

          // Menu tab
          GoRoute(
            path: Routes.menu,
            name: Routes.menuName,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: MenuScreen()),
            routes: [
              GoRoute(
                path: 'item/:itemId',
                name: Routes.menuItemName,
                builder: (context, state) {
                  final itemId = state.pathParameters['itemId']!;
                  return AddMenuItemScreen(itemId: itemId);
                },
              ),
              GoRoute(
                path: 'add',
                name: Routes.addMenuItemName,
                builder: (context, state) => const AddMenuItemScreen(),
              ),
              GoRoute(
                path: 'categories',
                name: Routes.categoriesName,
                builder: (context, state) => const CategoriesScreen(),
              ),
            ],
          ),

          // Profile tab
          GoRoute(
            path: Routes.profile,
            name: Routes.profileName,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfileScreen()),
            routes: [
              GoRoute(
                path: 'settings',
                name: Routes.settingsName,
                builder: (context, state) => const SettingsScreen(),
              ),
              GoRoute(
                path: 'edit',
                name: Routes.editProfileName,
                builder: (context, state) => const EditProfileScreen(),
              ),
              GoRoute(
                path: 'restaurant',
                name: Routes.restaurantSettingsName,
                builder: (context, state) => const RestaurantSettingsScreen(),
              ),
              GoRoute(
                path: 'coupons',
                name: Routes.couponsName,
                builder: (context, state) => const CouponsScreen(),
              ),
              GoRoute(
                path: 'earnings',
                name: Routes.earningsName,
                builder: (context, state) => const EarningsScreen(),
              ),
              GoRoute(
                path: 'statistics',
                name: Routes.statisticsName,
                builder: (context, state) => const StatisticsScreen(),
              ),
              GoRoute(
                path: 'notifications',
                name: Routes.notificationsName,
                builder: (context, state) => const NotificationsScreen(),
              ),
              GoRoute(
                path: 'language',
                name: Routes.languageName,
                builder: (context, state) => const LanguageScreen(),
              ),
              GoRoute(
                path: 'currency',
                name: Routes.currencyName,
                builder: (context, state) => const CurrencyScreen(),
              ),
              GoRoute(
                path: 'knowledge-base',
                name: Routes.knowledgeBaseName,
                builder: (context, state) => const KnowledgeBaseScreen(),
              ),
              GoRoute(
                path: 'support',
                name: Routes.supportName,
                builder: (context, state) => const SupportTicketsScreen(),
                routes: [
                  GoRoute(
                    path: 'create',
                    name: Routes.createSupportTicketName,
                    builder: (context, state) => const CreateTicketScreen(),
                  ),
                  GoRoute(
                    path: ':ticketId',
                    name: Routes.supportTicketDetailName,
                    builder: (context, state) {
                      final ticketId = state.pathParameters['ticketId']!;
                      return TicketDetailScreen(ticketId: int.parse(ticketId));
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'help',
                name: Routes.helpName,
                builder: (context, state) => const HelpScreen(),
              ),
              GoRoute(
                path: 'about',
                name: Routes.aboutName,
                builder: (context, state) => const AboutScreen(),
              ),
              GoRoute(
                path: 'delete-account',
                name: Routes.deleteAccountName,
                builder: (context, state) => const DeleteAccountScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(state.error?.message ?? 'Unknown error'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(Routes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
