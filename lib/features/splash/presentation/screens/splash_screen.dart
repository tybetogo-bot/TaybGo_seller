import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/theme/theme.dart';
import '../../../auth/application/auth_state.dart';
import '../../../restaurant/application/restaurant_state.dart';

/// Splash screen shown on app launch
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _minimumDelayPassed = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();

    // Set minimum delay before navigation can happen
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _minimumDelayPassed = true;
        _tryNavigate();
      }
    });
  }

  /// Try to navigate if conditions are met (minimum delay passed + states resolved)
  void _tryNavigate() {
    if (_hasNavigated || !_minimumDelayPassed || !mounted) return;

    final authState = ref.read(authProvider);
    final restaurantState = ref.read(restaurantProvider);

    print('🟡 [SplashScreen] Auth state: $authState');
    print('🟡 [SplashScreen] Restaurant state: $restaurantState');

    // Check if user is authenticated
    if (authState is AuthAuthenticated) {
      // Wait for restaurant state to finish loading
      if (restaurantState is RestaurantInitial || restaurantState is RestaurantLoading) {
        print('🟡 [SplashScreen] Restaurant still loading, waiting...');
        return; // Will be called again when state changes via listener
      }

      _hasNavigated = true;

      // Check if restaurant is selected
      if (restaurantState is RestaurantLoaded &&
          restaurantState.selectedRestaurant != null) {
        print('🟢 [SplashScreen] -> Going to home');
        context.go(Routes.home);
      } else {
        print('🟢 [SplashScreen] -> Going to restaurant selection');
        context.go(Routes.restaurantSelection);
      }
    } else {
      print('🟢 [SplashScreen] -> Going to login');
      _hasNavigated = true;
      context.go(Routes.login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to restaurant state changes and try to navigate when state resolves
    ref.listen(restaurantProvider, (previous, next) {
      print('🟡 [SplashScreen] Restaurant state changed: $previous -> $next');
      _tryNavigate();
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo placeholder
                      Container(
                        width: 120.w,
                        height: 120.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24.r),
                          boxShadow: AppShadows.lg,
                        ),
                        child: Icon(
                          Icons.storefront_rounded,
                          size: 64.w,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        'TybeToGo',
                        style: TextStyle(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Seller',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.9),
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
