import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:teybatseller/core/theme/app_colors.dart';
import 'package:teybatseller/features/tour/application/tour_notifier.dart';

/// Progress indicator showing tour completion
class TourProgressIndicator extends ConsumerWidget {
  const TourProgressIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tourState = ref.watch(tourProvider);
    final progress = tourState.progress;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 16.h,
      left: 20.w,
      right: 20.w,
      child: Container(
        height: 4.h,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(2.r),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: progress,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.shade300,
                ],
              ),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ),
      ),
    );
  }
}
