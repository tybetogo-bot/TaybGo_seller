import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:teybatseller/core/i18n/i18n.dart';
import 'package:teybatseller/core/theme/theme.dart';
import 'package:teybatseller/features/tour/application/tour_notifier.dart';

/// Tour navigation controls with better design
class TourControls extends ConsumerWidget {
  const TourControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tourState = ref.watch(tourProvider);
    final tourNotifier = ref.read(tourProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 20.h,
      left: 20.w,
      right: 20.w,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? DarkColors.surface : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Skip button
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                tourNotifier.exitTour();
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
              child: Text(
                'tour.skip'.tr,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
                ),
              ),
            ),

            // Navigation buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Previous button
                if (!tourState.isOnFirstStep) ...[
                  _NavButton(
                    icon: Icons.arrow_back,
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      tourNotifier.previousStep();
                    },
                    isDark: isDark,
                  ),
                  SizedBox(width: 8.w),
                ],

                // Next/Finish button
                _NextButton(
                  isLastStep: tourState.isOnLastStep,
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    if (tourState.isOnLastStep) {
                      HapticFeedback.mediumImpact();
                      tourNotifier.completeTour();
                    } else {
                      tourNotifier.nextStep();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.onPressed,
    required this.isDark,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? DarkColors.backgroundSecondary : LightColors.backgroundSecondary,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: 44.w,
          height: 44.h,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 20.w,
            color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({
    required this.isLastStep,
    required this.onPressed,
  });

  final bool isLastStep;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Material(
      color: primaryColor,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isLastStep ? 'tour.finish'.tr : 'tour.next'.tr,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 6.w),
              Icon(
                isLastStep ? Icons.check : Icons.arrow_forward,
                size: 18.w,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
