import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';

/// About screen
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  static const String _appVersion = '1.0.0+1';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(translationsLoadedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final borderColor = isDark ? DarkColors.border : LightColors.border;
    final cardColor = isDark ? DarkColors.surface : LightColors.surface;
    final year = DateTime.now().year;
    final websiteHost = Uri.parse(EnvConfig.websiteUrl).host;
    final partnerToolsLabel = _translated(
      context,
      'about.partnerTools',
      en: 'Seller workspace',
      ar: 'مساحة البائع',
    );
    final descriptionLabel = _translated(
      context,
      'about.description',
      en: 'Manage incoming orders, update your menu, run coupons, and track daily performance from one TaybGo seller dashboard.',
      ar: 'إدارة الطلبات والقائمة والعملاء في مكان واحد.',
    );
    final websiteLabel = _translated(
      context,
      'about.websiteLabel',
      en: 'Website',
      ar: 'الموقع الإلكتروني',
    );
    final supportEmailLabel = _translated(
      context,
      'about.supportEmailLabel',
      en: 'Support email',
      ar: 'بريد الدعم',
    );
    final visitWebsiteLabel = _translated(
      context,
      'about.visitWebsite',
      en: 'Visit TaybGo',
      ar: 'زيارة TaybGo',
    );

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : LightColors.background,
      appBar: AppBar(
        title: Text('settings.about'.tr),
        centerTitle: true,
        backgroundColor: isDark
            ? DarkColors.background
            : LightColors.background,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(24.w),
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: borderColor, width: 0.5),
            ),
            child: Column(
              children: [
                Container(
                  width: 84.w,
                  height: 84.w,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(22.r),
                  ),
                  child: Icon(
                    Icons.storefront_rounded,
                    size: 42.w,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'app.name'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? DarkColors.textPrimary
                        : LightColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    partnerToolsLabel,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  descriptionLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    height: 1.5,
                    color: isDark
                        ? DarkColors.textSecondary
                        : LightColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: borderColor, width: 0.5),
            ),
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.language_rounded,
                  label: websiteLabel,
                  value: websiteHost,
                  isDark: isDark,
                ),
                Divider(color: borderColor, height: 24.h),
                _InfoRow(
                  icon: Icons.alternate_email_rounded,
                  label: supportEmailLabel,
                  value: EnvConfig.supportEmail,
                  isDark: isDark,
                ),
                Divider(color: borderColor, height: 24.h),
                _InfoRow(
                  icon: Icons.info_outline_rounded,
                  label: 'common.version'.tr,
                  value: _appVersion,
                  isDark: isDark,
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openWebsite(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              icon: const Icon(Icons.open_in_new_rounded),
              label: Text(
                visitWebsiteLabel,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.push(Routes.help),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                side: BorderSide(color: borderColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              icon: Icon(Icons.support_agent_rounded, size: 18.w),
              label: Text(
                'settings.helpSupport'.tr,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Copyright $year TaybGo',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark
                  ? DarkColors.textTertiary
                  : LightColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openWebsite(BuildContext context) async {
    final launched = await launchUrl(Uri.parse(EnvConfig.websiteUrl));
    if (!launched && context.mounted) {
      _showLaunchError(context);
    }
  }

  void _showLaunchError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _translated(
            context,
            'help.linkError',
            en: 'Could not open TaybGo right now. Please try again.',
            ar: 'تعذر فتح TaybGo الآن. حاول مرة أخرى.',
          ),
        ),
        backgroundColor: AppColors.error,
      ),
    );
  }
}

String _translated(
  BuildContext context,
  String key, {
  required String en,
  String? ar,
}) {
  final translated = key.tr;
  if (translated != key) {
    return translated;
  }

  final isArabic = Localizations.localeOf(
    context,
  ).languageCode.toLowerCase().startsWith('ar');
  return isArabic ? (ar ?? en) : en;
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, size: 20.w, color: primaryColor),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDark
                      ? DarkColors.textTertiary
                      : LightColors.textTertiary,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? DarkColors.textPrimary
                      : LightColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
