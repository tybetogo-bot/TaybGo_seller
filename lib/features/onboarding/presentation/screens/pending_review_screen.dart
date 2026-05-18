import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/i18n/i18n.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../auth/application/auth_state.dart';
import '../../../auth/presentation/widgets/language_selector.dart';
import '../../../restaurant/application/restaurant_state.dart';
import '../../../restaurant/data/models/restaurant_model.dart';

/// Screen shown when seller's restaurant is pending review
class PendingReviewScreen extends ConsumerStatefulWidget {
  const PendingReviewScreen({super.key});

  @override
  ConsumerState<PendingReviewScreen> createState() =>
      _PendingReviewScreenState();
}

class _PendingReviewScreenState extends ConsumerState<PendingReviewScreen> {
  bool _isRefreshing = false;

  Future<void> _refreshStatus() async {
    setState(() => _isRefreshing = true);
    await ref.read(restaurantProvider.notifier).fetchRestaurants();
    if (mounted) {
      setState(() => _isRefreshing = false);
    }
  }

  Future<void> _logout() async {
    await ref.read(authProvider.notifier).logout();
    if (mounted) {
      context.go(Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    // Listen for restaurant status changes - if approved, navigate to home
    ref.listen(restaurantProvider, (previous, next) {
      if (next is RestaurantLoaded) {
        final hasActive = next.restaurants.any(
          (r) => r.status == RestaurantStatus.active,
        );
        if (hasActive) {
          // Auto-select the first active restaurant
          final active = next.restaurants.firstWhere(
            (r) => r.status == RestaurantStatus.active,
          );
          ref.read(restaurantProvider.notifier).selectRestaurant(active);
          context.go(Routes.home);
        }
      }
    });

    return AppScaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: Breakpoints.maxNarrowContentWidth,
            ),
            child: Column(
              children: [
                // Header with language selector
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const LanguageSelector(),
                    ],
                  ),
                ),

            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.screenPadding,
                child: Column(
                  children: [
                    SizedBox(height: 40.h),

                    // Hourglass icon
                    Container(
                      width: 100.w,
                      height: 100.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primary.withValues(alpha: 0.1),
                      ),
                      child: Icon(
                        Icons.hourglass_top_rounded,
                        size: 48.w,
                        color: primary,
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Title
                    Text(
                      'pendingReview.title'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? DarkColors.textPrimary
                            : LightColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Description
                    Text(
                      'pendingReview.description'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15.sp,
                        height: 1.5,
                        color: isDark
                            ? DarkColors.textSecondary
                            : LightColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 40.h),

                    // Refresh button
                    AppButton(
                      label: 'pendingReview.checkStatus'.tr,
                      onPressed: _isRefreshing ? null : _refreshStatus,
                      isLoading: _isRefreshing,
                    ),
                    SizedBox(height: 32.h),

                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: isDark
                                ? DarkColors.border
                                : LightColors.border,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text(
                            'pendingReview.meanwhile'.tr,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: isDark
                                  ? DarkColors.textSecondary
                                  : LightColors.textSecondary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: isDark
                                ? DarkColors.border
                                : LightColors.border,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    // Action cards
                    _ActionCard(
                      icon: Icons.menu_book_outlined,
                      title: 'pendingReview.knowledgeBase'.tr,
                      subtitle: 'pendingReview.knowledgeBaseDesc'.tr,
                      isDark: isDark,
                      onTap: () => context.push(Routes.standaloneKnowledgeBase),
                    ),
                    SizedBox(height: 32.h),

                    // Logout
                    TextButton.icon(
                      onPressed: _logout,
                      icon: Icon(
                        Icons.logout,
                        size: 20.w,
                        color: AppColors.error,
                      ),
                      label: Text(
                        'pendingReview.logout'.tr,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ],
        ),
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? DarkColors.surface : LightColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDark ? DarkColors.border : LightColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.1),
              ),
              child: Icon(
                icon,
                size: 22.w,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? DarkColors.textPrimary
                          : LightColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isDark
                          ? DarkColors.textSecondary
                          : LightColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20.w,
              color: isDark
                  ? DarkColors.textTertiary
                  : LightColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
