import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';

/// Help and support screen
class HelpScreen extends ConsumerWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(translationsLoadedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : LightColors.background,
      appBar: AppBar(
        title: Text('help.title'.tr),
        backgroundColor: isDark ? DarkColors.background : LightColors.background,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            SizedBox(height: 40.h),
            Icon(
              Icons.support_agent_outlined,
              size: 80.w,
              color: AppColors.primary,
            ),
            SizedBox(height: 24.h),
            Text(
              'help.contactUs'.tr,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'support@tybetogo.com',
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '+1 800 123 4567',
              style: TextStyle(
                fontSize: 16.sp,
                color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
