import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/theme.dart';
import '../../../notifications/application/notification_settings_notifier.dart';

/// Local notification preferences for seller order alerts.
class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(translationsLoadedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final settings = ref.watch(notificationSettingsProvider);

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : LightColors.background,
      appBar: AppBar(
        title: Text('notifications.settings'.tr),
        backgroundColor: isDark
            ? DarkColors.background
            : LightColors.background,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: Breakpoints.maxContentWidth,
          ),
          child: ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              _IntroCard(isDark: isDark, primaryColor: primaryColor),
              SizedBox(height: 16.h),
              _SettingsCard(
                title: 'notifications.repeatCount'.tr,
                subtitle: 'notifications.repeatCountDesc'.tr,
                isDark: isDark,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: AppNotificationSettings
                          .supportedOrderAlertRepeatCounts
                          .map(
                            (count) => _RepeatCountChip(
                              count: count,
                              isSelected:
                                  settings.orderAlertRepeatCount == count,
                              isDark: isDark,
                              primaryColor: primaryColor,
                              onSelected: () => ref
                                  .read(notificationSettingsProvider.notifier)
                                  .setOrderAlertRepeatCount(count),
                            ),
                          )
                          .toList(),
                    ),
                    SizedBox(height: 14.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: isDark
                            ? DarkColors.background
                            : LightColors.background,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 18.w,
                            color: primaryColor,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              'notifications.repeatInterval'.tr,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: isDark
                                    ? DarkColors.textSecondary
                                    : LightColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              _InfoCard(isDark: isDark),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.isDark, required this.primaryColor});

  final bool isDark;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_active_outlined,
              color: primaryColor,
              size: 24.w,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'notifications.orderAlerts'.tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? DarkColors.textPrimary
                        : LightColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'notifications.orderAlertsDesc'.tr,
                  style: TextStyle(
                    fontSize: 12.sp,
                    height: 1.4,
                    color: isDark
                        ? DarkColors.textSecondary
                        : LightColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.child,
  });

  final String title;
  final String subtitle;
  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: isDark ? DarkColors.surface : LightColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(
          color: isDark ? DarkColors.border : LightColors.border,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? DarkColors.textPrimary
                    : LightColors.textPrimary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12.sp,
                height: 1.4,
                color: isDark
                    ? DarkColors.textSecondary
                    : LightColors.textSecondary,
              ),
            ),
            SizedBox(height: 18.h),
            child,
          ],
        ),
      ),
    );
  }
}

class _RepeatCountChip extends StatelessWidget {
  const _RepeatCountChip({
    required this.count,
    required this.isSelected,
    required this.isDark,
    required this.primaryColor,
    required this.onSelected,
  });

  final int count;
  final bool isSelected;
  final bool isDark;
  final Color primaryColor;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(
        'notifications.repeatCountValue'.trParams({'count': '$count'}),
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      labelStyle: TextStyle(
        color: isSelected
            ? Colors.white
            : (isDark ? DarkColors.textSecondary : LightColors.textSecondary),
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
      ),
      selectedColor: primaryColor,
      backgroundColor: isDark ? DarkColors.surface : LightColors.surface,
      side: BorderSide(
        color: isSelected
            ? primaryColor
            : (isDark ? DarkColors.border : LightColors.border),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999.r)),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline_rounded,
          size: 18.w,
          color: isDark ? DarkColors.textTertiary : LightColors.textTertiary,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            'notifications.backgroundNotice'.tr,
            style: TextStyle(
              fontSize: 12.sp,
              height: 1.4,
              color: isDark
                  ? DarkColors.textSecondary
                  : LightColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
