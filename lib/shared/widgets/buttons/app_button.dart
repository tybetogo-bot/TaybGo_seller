import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/theme.dart';

/// Button variants
enum AppButtonVariant { primary, secondary, outline, text, danger }

/// Button sizes
enum AppButtonSize { small, medium, large }

/// Custom app button with multiple variants
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.iconPosition = IconPosition.left,
    this.isLoading = false,
    this.isFullWidth = true,
    this.isDisabled = false,
    this.borderRadius,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final IconPosition iconPosition;
  final bool isLoading;
  final bool isFullWidth;
  final bool isDisabled;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final isEnabled = !isDisabled && !isLoading && onPressed != null;

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: _getHeight(),
      child: _buildButton(context, isEnabled),
    );
  }

  Widget _buildButton(BuildContext context, bool isEnabled) {
    switch (variant) {
      case AppButtonVariant.primary:
        return _buildPrimaryButton(context, isEnabled);
      case AppButtonVariant.secondary:
        return _buildSecondaryButton(context, isEnabled);
      case AppButtonVariant.outline:
        return _buildOutlineButton(context, isEnabled);
      case AppButtonVariant.text:
        return _buildTextButton(context, isEnabled);
      case AppButtonVariant.danger:
        return _buildDangerButton(context, isEnabled);
    }
  }

  Widget _buildPrimaryButton(BuildContext context, bool isEnabled) {
    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        disabledBackgroundColor: AppColors.neutral[300],
        disabledForegroundColor: AppColors.neutral[500],
        elevation: 0,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? AppSpacing.radiusMd),
        ),
      ),
      child: _buildContent(AppColors.white),
    );
  }

  Widget _buildSecondaryButton(BuildContext context, bool isEnabled) {
    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary[50],
        foregroundColor: AppColors.primary,
        disabledBackgroundColor: AppColors.neutral[100],
        disabledForegroundColor: AppColors.neutral[400],
        elevation: 0,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? AppSpacing.radiusMd),
        ),
      ),
      child: _buildContent(AppColors.primary),
    );
  }

  Widget _buildOutlineButton(BuildContext context, bool isEnabled) {
    return OutlinedButton(
      onPressed: isEnabled ? onPressed : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        disabledForegroundColor: AppColors.neutral[400],
        padding: _getPadding(),
        side: BorderSide(
          color: isEnabled ? AppColors.primary : AppColors.neutral[300]!,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? AppSpacing.radiusMd),
        ),
      ),
      child: _buildContent(isEnabled ? AppColors.primary : AppColors.neutral[400]!),
    );
  }

  Widget _buildTextButton(BuildContext context, bool isEnabled) {
    return TextButton(
      onPressed: isEnabled ? onPressed : null,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        disabledForegroundColor: AppColors.neutral[400],
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? AppSpacing.radiusMd),
        ),
      ),
      child: _buildContent(isEnabled ? AppColors.primary : AppColors.neutral[400]!),
    );
  }

  Widget _buildDangerButton(BuildContext context, bool isEnabled) {
    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.error,
        foregroundColor: AppColors.white,
        disabledBackgroundColor: AppColors.neutral[300],
        disabledForegroundColor: AppColors.neutral[500],
        elevation: 0,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? AppSpacing.radiusMd),
        ),
      ),
      child: _buildContent(AppColors.white),
    );
  }

  Widget _buildContent(Color color) {
    if (isLoading) {
      return SizedBox(
        width: 20.w,
        height: 20.w,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    if (icon == null) {
      return Text(
        label,
        style: TextStyle(
          fontSize: _getFontSize(),
          fontWeight: FontWeight.w600,
        ),
      );
    }

    final iconWidget = Icon(icon, size: _getIconSize());
    final textWidget = Flexible(
      child: Text(
        label,
        style: TextStyle(
          fontSize: _getFontSize(),
          fontWeight: FontWeight.w600,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: iconPosition == IconPosition.left
          ? [iconWidget, SizedBox(width: 8.w), textWidget]
          : [textWidget, SizedBox(width: 8.w), iconWidget],
    );
  }

  double _getHeight() {
    switch (size) {
      case AppButtonSize.small:
        return 36.h;
      case AppButtonSize.medium:
        return 48.h;
      case AppButtonSize.large:
        return 56.h;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h);
      case AppButtonSize.medium:
        return EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h);
      case AppButtonSize.large:
        return EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h);
    }
  }

  double _getFontSize() {
    switch (size) {
      case AppButtonSize.small:
        return 12.sp;
      case AppButtonSize.medium:
        return 14.sp;
      case AppButtonSize.large:
        return 16.sp;
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return 16.w;
      case AppButtonSize.medium:
        return 20.w;
      case AppButtonSize.large:
        return 24.w;
    }
  }
}

/// Icon position in button
enum IconPosition { left, right }
