import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography system for the application
/// Uses Poppins for Latin and Cairo for Arabic
class AppTypography {
  AppTypography._();

  /// Base font family
  static String get fontFamily => GoogleFonts.poppins().fontFamily!;

  /// Arabic font family
  static String get fontFamilyArabic => GoogleFonts.cairo().fontFamily!;

  /// Get text theme based on brightness
  static TextTheme getTextTheme({required bool isDark}) {
    final Color textColor = isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
    final Color secondaryColor = isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563);

    return TextTheme(
      // Display
      displayLarge: _textStyle(
        fontSize: 57.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: textColor,
      ),
      displayMedium: _textStyle(
        fontSize: 45.sp,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      displaySmall: _textStyle(
        fontSize: 36.sp,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),

      // Headline
      headlineLarge: _textStyle(
        fontSize: 32.sp,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineMedium: _textStyle(
        fontSize: 28.sp,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineSmall: _textStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),

      // Title
      titleLarge: _textStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleMedium: _textStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: textColor,
      ),
      titleSmall: _textStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: textColor,
      ),

      // Body
      bodyLarge: _textStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        color: textColor,
      ),
      bodyMedium: _textStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: textColor,
      ),
      bodySmall: _textStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: secondaryColor,
      ),

      // Label
      labelLarge: _textStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: textColor,
      ),
      labelMedium: _textStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: textColor,
      ),
      labelSmall: _textStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: secondaryColor,
      ),
    );
  }

  static TextStyle _textStyle({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
      color: color,
    );
  }

  // ============ Custom Text Styles ============

  /// Price text style
  static TextStyle price({bool isDark = false}) => _textStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
        color: isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827),
      );

  /// Price with strikethrough (original price)
  static TextStyle priceOriginal({bool isDark = false}) => _textStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF9CA3AF),
      ).copyWith(decoration: TextDecoration.lineThrough);

  /// Discount badge text
  static TextStyle discountBadge() => _textStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFFFFFFF),
      );

  /// Button text
  static TextStyle button() => _textStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFFFFFFF),
      );

  /// Tab label
  static TextStyle tabLabel({bool isSelected = false, bool isDark = false}) => _textStyle(
        fontSize: 14.sp,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        color: isSelected
            ? const Color(0xFF00C853)
            : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)),
      );

  /// Category chip text
  static TextStyle categoryChip({bool isSelected = false}) => _textStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        color: isSelected ? const Color(0xFFFFFFFF) : const Color(0xFF4B5563),
      );

  /// Input hint text
  static TextStyle inputHint({bool isDark = false}) => _textStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF9CA3AF),
      );

  /// Input text
  static TextStyle inputText({bool isDark = false}) => _textStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827),
      );

  /// Error text
  static TextStyle errorText() => _textStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        color: const Color(0xFFEF4444),
      );

  /// Link text
  static TextStyle link() => _textStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF00C853),
      );

  /// Badge text
  static TextStyle badge() => _textStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFFFFFFF),
      );

  /// Delivery time text
  static TextStyle deliveryTime({bool isDark = false}) => _textStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF6B7280),
      );

  /// Rating text
  static TextStyle rating() => _textStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFFBBF24),
      );
}
