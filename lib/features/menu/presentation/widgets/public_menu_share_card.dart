import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/config/constants.dart';
import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';

/// Widget displaying QR code and link for sharing public menu
class PublicMenuShareCard extends StatelessWidget {
  final String restaurantId;

  const PublicMenuShareCard({
    super.key,
    required this.restaurantId,
  });

  String get _publicMenuUrl =>
      '${DeploymentConfig.baseUrl}/public-menu/$restaurantId';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : LightColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? DarkColors.border : LightColors.border,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          childrenPadding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            bottom: 16.h,
          ),
          leading: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.qr_code_2,
              size: 20.sp,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: Text(
            'menuShare.title'.tr,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color:
                  isDark ? DarkColors.textPrimary : LightColors.textPrimary,
            ),
          ),
          subtitle: Text(
            'Tap to view QR code and link',
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark
                  ? DarkColors.textSecondary
                  : LightColors.textSecondary,
            ),
          ),
          children: [
            Column(
              children: [
                // QR Code - centered and smaller
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isDark ? DarkColors.border : LightColors.border,
                      width: 2,
                    ),
                  ),
                  child: QrImageView(
                    data: _publicMenuUrl,
                    version: QrVersions.auto,
                    size: 120.w,
                    backgroundColor: Colors.white,
                    errorCorrectionLevel: QrErrorCorrectLevel.H,
                  ),
                ),

                SizedBox(height: 16.h),

                // URL display
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: isDark
                        ? DarkColors.background
                        : LightColors.background,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color:
                          isDark ? DarkColors.border : LightColors.border,
                    ),
                  ),
                  child: SelectableText(
                    _publicMenuUrl,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontFamily: 'monospace',
                      color: isDark
                          ? DarkColors.textSecondary
                          : LightColors.textSecondary,
                    ),
                    maxLines: 2,
                  ),
                ),

                SizedBox(height: 12.h),

                // Action buttons - side by side
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _copyToClipboard(context),
                        icon: Icon(Icons.copy, size: 16.sp),
                        label: Text(
                          'Copy',
                          style: TextStyle(fontSize: 13.sp),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _previewMenu(context),
                        icon: Icon(Icons.open_in_new, size: 16.sp),
                        label: Text(
                          'Preview',
                          style: TextStyle(fontSize: 13.sp),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _publicMenuUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('menuShare.linkCopied'.tr),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _previewMenu(BuildContext context) {
    context.push(Routes.publicMenuPath(restaurantId));
  }
}
