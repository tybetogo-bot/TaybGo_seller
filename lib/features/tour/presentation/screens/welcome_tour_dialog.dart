import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:teybatseller/core/i18n/i18n.dart';
import 'package:teybatseller/core/theme/app_spacing.dart';
import 'package:teybatseller/features/tour/application/tour_notifier.dart';
import 'package:teybatseller/features/tour/application/tour_state.dart';
import 'package:teybatseller/features/tour/utils/tour_persistence.dart';
import 'package:teybatseller/shared/widgets/buttons/app_button.dart';

/// Welcome dialog shown on first app launch offering tour
class WelcomeTourDialog extends ConsumerStatefulWidget {
  const WelcomeTourDialog({super.key});

  @override
  ConsumerState<WelcomeTourDialog> createState() => _WelcomeTourDialogState();
}

class _WelcomeTourDialogState extends ConsumerState<WelcomeTourDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _dontShowAgain = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleStartTour() async {
    if (_dontShowAgain) {
      await TourPersistence.markTourPromptAsShown();
    }

    if (!mounted) return;

    // Inject router for navigation
    final router = GoRouter.of(context);
    ref.read(tourProvider.notifier).setRouter(router);

    // Start the full app tour
    ref.read(tourProvider.notifier).startTour(TourType.fullApp);

    // Close dialog
    Navigator.of(context).pop();
  }

  void _handleSkip() async {
    // Always mark prompt as shown when user skips
    await TourPersistence.markTourPromptAsShown();

    if (!mounted) return;

    // Close dialog
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Container(
            constraints: BoxConstraints(maxWidth: 340.w),
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tour icon
                Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.tour_outlined,
                    size: 40.w,
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: AppSpacing.lg),

                // Title
                Text(
                  'welcomeTour.title'.tr,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.sm),

                // Description
                Text(
                  'welcomeTour.description'.tr,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.md),

                // Benefits list
                _BenefitItem(
                  icon: Icons.lightbulb_outline,
                  text: 'welcomeTour.benefit1'.tr,
                  isDark: isDark,
                ),
                SizedBox(height: AppSpacing.xs),
                _BenefitItem(
                  icon: Icons.speed_outlined,
                  text: 'welcomeTour.benefit2'.tr,
                  isDark: isDark,
                ),
                SizedBox(height: AppSpacing.xs),
                _BenefitItem(
                  icon: Icons.verified_outlined,
                  text: 'welcomeTour.benefit3'.tr,
                  isDark: isDark,
                ),
                SizedBox(height: AppSpacing.lg),

                // Don't show again checkbox
                Row(
                  children: [
                    SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: Checkbox(
                        value: _dontShowAgain,
                        onChanged: (value) {
                          setState(() {
                            _dontShowAgain = value ?? false;
                          });
                        },
                        activeColor: primaryColor,
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'welcomeTour.dontShowAgain'.tr,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.lg),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _handleSkip,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        child: Text('welcomeTour.skipForNow'.tr),
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      flex: 2,
                      child: AppButton(
                        onPressed: _handleStartTour,
                        label: 'welcomeTour.startTour'.tr,
                        variant: AppButtonVariant.primary,
                        size: AppButtonSize.medium,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Benefit list item with icon
class _BenefitItem extends StatelessWidget {
  const _BenefitItem({
    required this.icon,
    required this.text,
    required this.isDark,
  });

  final IconData icon;
  final String text;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Row(
      children: [
        Icon(
          icon,
          size: 18.w,
          color: primaryColor,
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

/// Helper function to show the welcome tour dialog
Future<void> showWelcomeTourDialog(BuildContext context) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const WelcomeTourDialog(),
  );
}
