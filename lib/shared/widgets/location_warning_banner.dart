import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/i18n/i18n.dart';
import '../../core/services/location_permission_service.dart';
import '../../core/theme/theme.dart';

/// A dismissible warning banner that appears when location permission is
/// denied or location services are disabled.
///
/// Shows contextual messaging:
/// - GPS/location services off → prompts to enable GPS
/// - Permission denied → prompts to grant permission
/// - Permanently denied → prompts to open app settings
class LocationWarningBanner extends ConsumerStatefulWidget {
  const LocationWarningBanner({super.key});

  @override
  ConsumerState<LocationWarningBanner> createState() =>
      _LocationWarningBannerState();
}

class _LocationWarningBannerState extends ConsumerState<LocationWarningBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    final permissionState = ref.watch(locationPermissionProvider);

    // Reset the dismissed flag when the permission state changes
    // (e.g. user returns from settings and status is re-evaluated).
    ref.listen<LocationPermissionState>(locationPermissionProvider,
        (previous, next) {
      if (previous != next && _dismissed) {
        setState(() => _dismissed = false);
      }
    });

    // Don't show the banner when permission is granted, still loading,
    // or the user has dismissed it.
    if (permissionState == LocationPermissionState.granted ||
        permissionState == LocationPermissionState.loading ||
        _dismissed) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isServiceDisabled =
        permissionState == LocationPermissionState.serviceDisabled;
    final isPermanentlyDenied =
        permissionState == LocationPermissionState.permanentlyDenied;

    // Pick the right title, message, icon, and button text
    final String title;
    final String message;
    final IconData icon;
    final String buttonText;

    if (isServiceDisabled) {
      title = 'location.gpsDisabled'.tr;
      message = 'location.gpsDisabledMessage'.tr;
      icon = Icons.gps_off_rounded;
      buttonText = 'location.enableGps'.tr;
    } else if (isPermanentlyDenied) {
      title = 'location.permissionRequired'.tr;
      message = 'location.permissionDeniedMessage'.tr;
      icon = Icons.location_off_rounded;
      buttonText = 'location.openSettings'.tr;
    } else {
      title = 'location.permissionRequired'.tr;
      message = 'location.permissionMessage'.tr;
      icon = Icons.location_off_rounded;
      buttonText = 'location.enable'.tr;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.warningDark : AppColors.warningLight,
        border: Border(
          bottom: BorderSide(
            color: AppColors.warning.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Warning icon
          Padding(
            padding: EdgeInsets.only(top: 2.h),
            child: Icon(
              icon,
              color: isDark ? AppColors.warning : AppColors.warningDark,
              size: 20.w,
            ),
          ),
          SizedBox(width: 8.w),

          // Message text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.warning : AppColors.warningDark,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: isDark
                        ? DarkColors.textSecondary
                        : LightColors.textSecondary,
                  ),
                ),
                SizedBox(height: 6.h),

                // Action button
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    height: 28.h,
                    child: TextButton(
                      onPressed: () {
                        ref
                            .read(locationPermissionProvider.notifier)
                            .handleEnableAction();
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        backgroundColor:
                            AppColors.warning.withValues(alpha: 0.15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        buttonText,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.warning
                              : AppColors.warningDark,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Close / dismiss button
          GestureDetector(
            onTap: () => setState(() => _dismissed = true),
            child: Padding(
              padding: EdgeInsets.only(left: 4.w),
              child: Icon(
                Icons.close_rounded,
                color: isDark
                    ? DarkColors.textTertiary
                    : LightColors.textTertiary,
                size: 18.w,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
