import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../auth/application/auth_state.dart';
import '../../../restaurant/application/restaurant_state.dart';
import '../../../restaurant/data/models/restaurant_model.dart';

/// Splash screen shown on app launch
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  bool _minimumDelayPassed = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    // Main animation controller for logo entrance
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    // Pulse animation controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Delay animation start to avoid jank during initial build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _mainController.forward();
        _pulseController.repeat(reverse: true);
      }
    });

    // Set minimum delay before navigation can happen
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _minimumDelayPassed = true;
        _tryNavigate();
      }
    });

    // Timeout fallback - if nothing happens in 20 seconds, go to login
    Future.delayed(const Duration(seconds: 20), () {
      if (mounted && !_hasNavigated) {
        print('🟠 [SplashScreen] Timeout reached, forcing navigation to login');
        _hasNavigated = true;
        context.go(Routes.login);
      }
    });
  }

  /// Try to navigate if conditions are met (minimum delay passed + states resolved)
  void _tryNavigate() {
    if (_hasNavigated || !_minimumDelayPassed || !mounted) return;

    // Don't navigate if we're coming from a public route (like public menu)
    // This prevents splash screen from redirecting when user lands on public menu directly
    final router = GoRouter.of(context);
    final currentLocation = router.routerDelegate.currentConfiguration.uri.path;
    if (currentLocation.startsWith('/public-menu')) {
      print('🟢 [SplashScreen] Public route detected, skipping navigation');
      _hasNavigated = true; // Mark as navigated to prevent timeout redirect
      return;
    }

    final authState = ref.read(authProvider);
    final restaurantState = ref.read(restaurantProvider);

    print('🟡 [SplashScreen] Auth state: $authState');
    print('🟡 [SplashScreen] Restaurant state: $restaurantState');

    // Wait for auth state to be resolved (not initial or loading)
    if (authState is AuthInitial || authState is AuthLoading) {
      print('🟡 [SplashScreen] Auth still checking, waiting...');
      return; // Will be called again when state changes via listener
    }

    // Check if user is authenticated
    if (authState is AuthAuthenticated) {
      // Wait for restaurant state to finish loading (but not indefinitely)
      if (restaurantState is RestaurantInitial ||
          restaurantState is RestaurantLoading) {
        print('🟡 [SplashScreen] Restaurant still loading, waiting...');
        return; // Will be called again when state changes via listener
      }

      _hasNavigated = true;

      // Handle restaurant error - go to restaurant selection to retry
      if (restaurantState is RestaurantError) {
        print('🟠 [SplashScreen] Restaurant error: ${restaurantState.message}');
        print('🟢 [SplashScreen] -> Going to restaurant selection');
        context.go(Routes.restaurantSelection);
        return;
      }

      if (restaurantState is RestaurantLoaded) {
        // No restaurants -> onboarding
        if (restaurantState.restaurants.isEmpty) {
          print('🟢 [SplashScreen] -> No restaurants, going to onboarding');
          context.go(Routes.onboarding);
          return;
        }

        // All restaurants pending -> pending review
        final allPending = restaurantState.restaurants.every(
          (r) => r.status == RestaurantStatus.pending,
        );
        if (allPending) {
          print('🟢 [SplashScreen] -> All restaurants pending, going to pending review');
          context.go(Routes.pendingReview);
          return;
        }

        // Has a selected active restaurant -> home
        if (restaurantState.selectedRestaurant != null) {
          print('🟢 [SplashScreen] -> Going to home');
          context.go(Routes.home);
        } else {
          print('🟢 [SplashScreen] -> Going to restaurant selection');
          context.go(Routes.restaurantSelection);
        }
      } else {
        print('🟢 [SplashScreen] -> Going to restaurant selection');
        context.go(Routes.restaurantSelection);
      }
    } else {
      // Handle unauthenticated, error, or any other auth state -> go to login
      print('🟢 [SplashScreen] -> Going to login');
      _hasNavigated = true;
      context.go(Routes.login);
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes and try to navigate when state resolves
    ref.listen(authProvider, (previous, next) {
      print('🟡 [SplashScreen] Auth state changed: $previous -> $next');
      _tryNavigate();
    });

    // Listen to restaurant state changes and try to navigate when state resolves
    ref.listen(restaurantProvider, (previous, next) {
      print('🟡 [SplashScreen] Restaurant state changed: $previous -> $next');
      _tryNavigate();
    });

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), Color(0xFFF5F5F5)],
          ),
        ),
        child: Stack(
          children: [
            // Animated background circles with green accent
            ..._buildBackgroundCircles(),

            // Main content - using separate AnimatedBuilders to reduce rebuilds
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo with slide and scale animations
                    AnimatedBuilder(
                      animation: _mainController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: Transform.scale(
                            scale: _scaleAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: RepaintBoundary(
                        child: Image.asset(
                          'assets/icons/logo.jpg',
                          width: 280.w,
                          height: 140.w,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    SizedBox(height: 32.h),

                    // "Seller" badge with slide animation
                    AnimatedBuilder(
                      animation: _mainController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _slideAnimation.value * 0.5),
                          child: child,
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(30.r),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.storefront_rounded,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20.w,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Seller Portal',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 60.h),

                    // Loading indicator
                    _buildLoadingIndicator(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBackgroundCircles() {
    return [
      Positioned(
        top: -100.h,
        right: -50.w,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1 + (_pulseAnimation.value - 1) * 2,
              child: Container(
                width: 300.w,
                height: 300.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.05),
                ),
              ),
            );
          },
        ),
      ),
      Positioned(
        bottom: -150.h,
        left: -100.w,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.1 - (_pulseAnimation.value - 1),
              child: Container(
                width: 400.w,
                height: 400.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.03),
                ),
              ),
            );
          },
        ),
      ),
      Positioned(
        top: MediaQuery.of(context).size.height * 0.3,
        left: -50.w,
        child: Container(
          width: 150.w,
          height: 150.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.04),
          ),
        ),
      ),
    ];
  }

  Widget _buildLoadingIndicator() {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        final opacity = _fadeAnimation.value;
        return Opacity(
          opacity: opacity,
          child: Column(
            children: [
              SizedBox(
                width: 28.w,
                height: 28.w,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.8),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.6),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
