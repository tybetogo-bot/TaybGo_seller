import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';
import '../../application/tour_notifier.dart';
import '../../application/tour_state.dart';

/// Reusable tour section widget (used in home screen and profile screen)
class TourSectionWidget extends ConsumerWidget {
  const TourSectionWidget({super.key});

  void _startTour(BuildContext context, WidgetRef ref, TourType tourType) {
    final router = GoRouter.of(context);
    ref.read(tourProvider.notifier).setRouter(router);
    ref.read(tourProvider.notifier).startTour(tourType);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withValues(alpha: 0.12),
            primaryColor.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main tour button
          GestureDetector(
            onTap: () => _startTour(context, ref, TourType.fullApp),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.tour_outlined,
                    size: 22.w,
                    color: primaryColor,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'knowledgeBase.startTour'.tr,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? DarkColors.textPrimary
                              : LightColors.textPrimary,
                        ),
                      ),
                      Text(
                        'knowledgeBase.tourDescription'.tr,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDark
                              ? DarkColors.textSecondary
                              : LightColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.play_circle_outlined,
                  size: 28.w,
                  color: primaryColor,
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          // Quick tour chips
          Row(
            children: [
              _TourChip(
                label: 'knowledgeBase.fullTour'.tr,
                icon: Icons.apps_outlined,
                primaryColor: primaryColor,
                isDark: isDark,
                onTap: () => _startTour(context, ref, TourType.fullApp),
              ),
              SizedBox(width: 8.w),
              _TourChip(
                label: 'knowledgeBase.ordersTour'.tr,
                icon: Icons.receipt_long_outlined,
                primaryColor: primaryColor,
                isDark: isDark,
                onTap: () => _startTour(context, ref, TourType.ordersQuick),
              ),
              SizedBox(width: 8.w),
              _TourChip(
                label: 'knowledgeBase.menuTour'.tr,
                icon: Icons.restaurant_menu_outlined,
                primaryColor: primaryColor,
                isDark: isDark,
                onTap: () => _startTour(context, ref, TourType.menuQuick),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TourChip extends StatelessWidget {
  const _TourChip({
    required this.label,
    required this.icon,
    required this.primaryColor,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color primaryColor;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
          decoration: BoxDecoration(
            color: isDark ? DarkColors.surface : Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.25),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14.w, color: primaryColor),
              SizedBox(width: 4.w),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: primaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
