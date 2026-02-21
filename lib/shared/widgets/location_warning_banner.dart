import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/i18n/i18n.dart';
import '../../core/services/location_permission_service.dart';
import '../../core/theme/theme.dart';

/// A dismissible warning banner that appears when location permission is
/// denied or location services are disabled.
///
/// The banner can be dismissed by the user, but it will reappear on the next
/// app resume if the permission is still not granted (because the
/// [locationPermissionProvider] re-checks on resume and the dismissed flag
/// is reset).
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
    final isPermanentlyDenied =
        permissionState == LocationPermissionState.permanentlyDenied;

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
              Icons.location_off_rounded,
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
                  'location.permissionRequired'.tr,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.warning : AppColors.warningDark,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'location.permissionMessage'.tr,
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
                        final notifier =
                            ref.read(locationPermissionProvider.notifier);
                        if (isPermanentlyDenied) {
                          notifier.openSettings();
                        } else {
                          notifier.requestPermission();
                        }
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
                        isPermanentlyDenied
                            ? 'location.openSettings'.tr
                            : 'location.enable'.tr,
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
