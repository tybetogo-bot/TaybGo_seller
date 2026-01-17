import 'dart:math' as math;

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

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _shimmerAnimation;
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

    // Shimmer effect controller
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
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

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _mainController.forward();
    _shimmerController.repeat();
    _pulseController.repeat(reverse: true);

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

    // Wait for auth state to be resolved (not initial or loading)
    if (authState is AuthInitial || authState is AuthLoading) {
      print('🟡 [SplashScreen] Auth still checking, waiting...');
      return; // Will be called again when state changes via listener
    }

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
    _mainController.dispose();
    _shimmerController.dispose();
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
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFF5F5F5),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background circles with green accent
            ..._buildBackgroundCircles(),

            // Main content
            Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _mainController,
                  _pulseController,
                  _shimmerController,
                ]),
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo with animations - no container, blends with background
                        Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: Transform.scale(
                            scale: _scaleAnimation.value * _pulseAnimation.value,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Logo image - larger and seamless
                                Image.asset(
                                  'assets/icons/logo.jpg',
                                  width: 280.w,
                                  height: 140.w,
                                  fit: BoxFit.contain,
                                ),
                                // Shimmer overlay
                                Positioned.fill(
                                  child: _buildShimmerOverlay(),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 32.h),

                        // "Seller" badge with slide animation - green themed
                        Transform.translate(
                          offset: Offset(0, _slideAnimation.value * 0.5),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 10.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(30.r),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.storefront_rounded,
                                  color: AppColors.primary,
                                  size: 20.w,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Seller Portal',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
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
                  );
                },
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
                  color: AppColors.primary.withValues(alpha: 0.05),
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
                  color: AppColors.primary.withValues(alpha: 0.03),
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
            color: AppColors.primary.withValues(alpha: 0.04),
          ),
        ),
      ),
    ];
  }

  Widget _buildShimmerOverlay() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.0),
                AppColors.primary.withValues(alpha: 0.15),
                AppColors.primary.withValues(alpha: 0.0),
              ],
              stops: [
                _shimmerAnimation.value - 0.3,
                _shimmerAnimation.value,
                _shimmerAnimation.value + 0.3,
              ].map((s) => s.clamp(0.0, 1.0)).toList(),
              transform: GradientRotation(math.pi / 4),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: Container(
            color: AppColors.primary.withValues(alpha: 0.1),
          ),
        );
      },
    );
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
                    AppColors.primary.withValues(alpha: 0.8),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary.withValues(alpha: 0.6),
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
