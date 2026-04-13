import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/theme.dart';

/// Custom text field with consistent styling
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.textDirection,
    this.fillColor,
    this.borderRadius,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final String? helperText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onSuffixTap;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final TextDirection? textDirection;
  final Color? fillColor;
  final double? borderRadius;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          obscureText: _obscureText,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          autofocus: widget.autofocus,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          keyboardType: widget.keyboardType,
          textDirection: _effectiveTextDirection(),
          textInputAction: widget.textInputAction,
          inputFormatters: widget.inputFormatters,
          textCapitalization: widget.textCapitalization,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          validator: widget.validator,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: isDark
                  ? DarkColors.textTertiary
                  : LightColors.textTertiary,
            ),
            errorText: widget.errorText,
            helperText: widget.helperText,
            filled: true,
            fillColor:
                widget.fillColor ??
                (isDark
                    ? DarkColors.inputBackground
                    : LightColors.inputBackground),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    size: 20.w,
                    color: isDark
                        ? DarkColors.textTertiary
                        : LightColors.textTertiary,
                  )
                : null,
            suffixIcon: _buildSuffixIcon(isDark),
            border: _buildBorder(isDark, false),
            enabledBorder: _buildBorder(isDark, false),
            focusedBorder: _buildBorder(isDark, true),
            errorBorder: _buildErrorBorder(),
            focusedErrorBorder: _buildErrorBorder(),
            disabledBorder: _buildBorder(isDark, false),
          ),
        ),
      ],
    );
  }

  /// Keep phone, number, and email inputs left-to-right so symbols stay in the right order in RTL locales.
  TextDirection? _effectiveTextDirection() {
    if (widget.textDirection != null) {
      return widget.textDirection;
    }

    final keyboardType = widget.keyboardType;
    final shouldForceLtr =
        keyboardType == TextInputType.phone ||
        keyboardType == TextInputType.emailAddress ||
        keyboardType == TextInputType.url ||
        keyboardType == TextInputType.number ||
        keyboardType?.toString().contains('numberWithOptions') == true;

    return shouldForceLtr ? ui.TextDirection.ltr : null;
  }

  Widget? _buildSuffixIcon(bool isDark) {
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          size: 20.w,
          color: isDark ? DarkColors.textTertiary : LightColors.textTertiary,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }

    if (widget.suffixIcon != null) {
      return GestureDetector(
        onTap: widget.onSuffixTap,
        child: widget.suffixIcon,
      );
    }

    return null;
  }

  OutlineInputBorder _buildBorder(bool isDark, bool isFocused) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        widget.borderRadius ?? AppSpacing.radiusMd,
      ),
      borderSide: BorderSide(
        color: isFocused
            ? primaryColor
            : (isDark ? DarkColors.border : LightColors.border),
        width: isFocused ? 1.5 : 1,
      ),
    );
  }

  OutlineInputBorder _buildErrorBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        widget.borderRadius ?? AppSpacing.radiusMd,
      ),
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    );
  }
}

/// Password text field with visibility toggle
class AppPasswordField extends StatelessWidget {
  const AppPasswordField({
    super.key,
    this.controller,
    this.label,
    this.hint = 'Enter your password',
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.focusNode,
    this.textInputAction,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: label,
      hint: hint,
      errorText: errorText,
      obscureText: true,
      prefixIcon: Icons.lock_outline,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: textInputAction ?? TextInputAction.done,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      validator: validator,
      focusNode: focusNode,
    );
  }
}

/// Email text field
class AppEmailField extends StatelessWidget {
  const AppEmailField({
    super.key,
    this.controller,
    this.label,
    this.hint = 'Enter your email',
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.focusNode,
    this.textInputAction,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: label,
      hint: hint,
      errorText: errorText,
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction ?? TextInputAction.next,
      textCapitalization: TextCapitalization.none,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      validator: validator,
      focusNode: focusNode,
    );
  }
}
