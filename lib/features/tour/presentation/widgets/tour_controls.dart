import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:teybatseller/core/i18n/i18n.dart';
import 'package:teybatseller/core/theme/app_spacing.dart';
import 'package:teybatseller/features/tour/application/tour_notifier.dart';
import 'package:teybatseller/shared/widgets/buttons/app_button.dart';

/// Tour navigation controls (Skip, Previous, Next)
class TourControls extends ConsumerWidget {
  const TourControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tourState = ref.watch(tourProvider);
    final tourNotifier = ref.read(tourProvider.notifier);

    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 20.h,
      left: 20.w,
      right: 20.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Skip button (always visible)
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              tourNotifier.exitTour();
            },
            child: Text('tour.skip'.tr),
          ),

          // Previous/Next buttons
          Row(
            children: [
              // Previous button
              if (!tourState.isOnFirstStep)
                IconButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    tourNotifier.previousStep();
                  },
                  icon: const Icon(Icons.arrow_back),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                  ),
                ),

              SizedBox(width: AppSpacing.sm),

              // Next button
              AppButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  if (tourState.isOnLastStep) {
                    HapticFeedback.mediumImpact();
                    tourNotifier.completeTour();
                  } else {
                    tourNotifier.nextStep();
                  }
                },
                label: tourState.isOnLastStep
                    ? 'tour.finish'.tr
                    : 'tour.next'.tr,
                variant: AppButtonVariant.primary,
                size: AppButtonSize.medium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
