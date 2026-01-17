import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Spacing system for consistent layout throughout the app
class AppSpacing {
  AppSpacing._();

  // ============ Base spacing values ============
  static double get xs => 4.w;
  static double get sm => 8.w;
  static double get md => 12.w;
  static double get lg => 16.w;
  static double get xl => 20.w;
  static double get xxl => 24.w;
  static double get xxxl => 32.w;
  static double get huge => 40.w;
  static double get massive => 48.w;

  // ============ Semantic spacing ============
  /// Screen horizontal padding
  static double get screenPaddingH => 16.w;

  /// Screen vertical padding
  static double get screenPaddingV => 16.h;

  /// Card padding
  static double get cardPadding => 16.w;

  /// List item spacing
  static double get listSpacing => 12.h;

  /// Section spacing
  static double get sectionSpacing => 24.h;

  /// Input field spacing
  static double get inputSpacing => 16.h;

  /// Button height
  static double get buttonHeight => 52.h;

  /// Button height small
  static double get buttonHeightSm => 40.h;

  /// Icon size
  static double get iconSm => 16.w;
  static double get iconMd => 20.w;
  static double get iconLg => 24.w;
  static double get iconXl => 32.w;

  /// Avatar sizes
  static double get avatarSm => 32.w;
  static double get avatarMd => 40.w;
  static double get avatarLg => 56.w;
  static double get avatarXl => 80.w;

  /// Border radius
  static double get radiusXs => 4.r;
  static double get radiusSm => 8.r;
  static double get radiusMd => 12.r;
  static double get radiusLg => 16.r;
  static double get radiusXl => 20.r;
  static double get radiusXxl => 24.r;
  static double get radiusFull => 999.r;

  // ============ EdgeInsets helpers ============
  static EdgeInsets get screenPadding => EdgeInsets.symmetric(
        horizontal: screenPaddingH,
        vertical: screenPaddingV,
      );

  static EdgeInsets get screenPaddingHorizontal => EdgeInsets.symmetric(
        horizontal: screenPaddingH,
      );

  static EdgeInsets get cardMargin => EdgeInsets.all(cardPadding);

  static EdgeInsets paddingAll(double value) => EdgeInsets.all(value);

  static EdgeInsets paddingH(double value) => EdgeInsets.symmetric(horizontal: value);

  static EdgeInsets paddingV(double value) => EdgeInsets.symmetric(vertical: value);

  static EdgeInsets paddingSymmetric({double h = 0, double v = 0}) => EdgeInsets.symmetric(
        horizontal: h,
        vertical: v,
      );

  // ============ SizedBox helpers ============
  static SizedBox get horizontalXs => SizedBox(width: xs);
  static SizedBox get horizontalSm => SizedBox(width: sm);
  static SizedBox get horizontalMd => SizedBox(width: md);
  static SizedBox get horizontalLg => SizedBox(width: lg);
  static SizedBox get horizontalXl => SizedBox(width: xl);
  static SizedBox get horizontalXxl => SizedBox(width: xxl);

  static SizedBox get verticalXs => SizedBox(height: xs);
  static SizedBox get verticalSm => SizedBox(height: sm);
  static SizedBox get verticalMd => SizedBox(height: md);
  static SizedBox get verticalLg => SizedBox(height: lg);
  static SizedBox get verticalXl => SizedBox(height: xl);
  static SizedBox get verticalXxl => SizedBox(height: xxl);
  static SizedBox get verticalXxxl => SizedBox(height: xxxl);
  static SizedBox get verticalHuge => SizedBox(height: huge);

  static SizedBox horizontal(double width) => SizedBox(width: width);
  static SizedBox vertical(double height) => SizedBox(height: height);
}

/// Border radius presets
class AppBorderRadius {
  AppBorderRadius._();

  static BorderRadius get xs => BorderRadius.circular(AppSpacing.radiusXs);
  static BorderRadius get sm => BorderRadius.circular(AppSpacing.radiusSm);
  static BorderRadius get md => BorderRadius.circular(AppSpacing.radiusMd);
  static BorderRadius get lg => BorderRadius.circular(AppSpacing.radiusLg);
  static BorderRadius get xl => BorderRadius.circular(AppSpacing.radiusXl);
  static BorderRadius get xxl => BorderRadius.circular(AppSpacing.radiusXxl);
  static BorderRadius get full => BorderRadius.circular(AppSpacing.radiusFull);

  /// Top only border radius
  static BorderRadius get topMd => BorderRadius.only(
        topLeft: Radius.circular(AppSpacing.radiusMd),
        topRight: Radius.circular(AppSpacing.radiusMd),
      );

  static BorderRadius get topLg => BorderRadius.only(
        topLeft: Radius.circular(AppSpacing.radiusLg),
        topRight: Radius.circular(AppSpacing.radiusLg),
      );

  static BorderRadius get topXl => BorderRadius.only(
        topLeft: Radius.circular(AppSpacing.radiusXl),
        topRight: Radius.circular(AppSpacing.radiusXl),
      );

  /// Bottom only border radius
  static BorderRadius get bottomMd => BorderRadius.only(
        bottomLeft: Radius.circular(AppSpacing.radiusMd),
        bottomRight: Radius.circular(AppSpacing.radiusMd),
      );

  static BorderRadius get bottomLg => BorderRadius.only(
        bottomLeft: Radius.circular(AppSpacing.radiusLg),
        bottomRight: Radius.circular(AppSpacing.radiusLg),
      );
}
