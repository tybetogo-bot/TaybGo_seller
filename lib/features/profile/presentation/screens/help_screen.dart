import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/i18n/i18n.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/theme.dart';

/// Help and support screen
class HelpScreen extends ConsumerWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(translationsLoadedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final borderColor = isDark ? DarkColors.border : LightColors.border;
    final cardColor = isDark ? DarkColors.surface : LightColors.surface;
    final websiteHost = Uri.parse(EnvConfig.websiteUrl).host;
    final descriptionLabel = _translated(
      context,
      'help.description',
      en: 'Use TaybGo support whenever you need help with account access, orders, payouts, or day-to-day seller operations.',
      ar: 'استخدم دعم TaybGo عندما تحتاج إلى مساعدة بخصوص الحساب أو الطلبات أو المدفوعات أو تشغيل المتجر اليومي.',
    );
    final visitWebsiteLabel = _translated(
      context,
      'help.visitWebsite',
      en: 'Go to taybgo.com',
      ar: 'الانتقال إلى taybgo.com',
    );
    final websiteTitleLabel = _translated(
      context,
      'help.websiteTitle',
      en: 'TaybGo website',
      ar: 'موقع TaybGo',
    );
    final websiteDescriptionLabel = _translated(
      context,
      'help.websiteDescription',
      en: 'Open taybgo.com for platform information and direct contact options.',
      ar: 'افتح taybgo.com للاطلاع على معلومات المنصة وطرق التواصل المباشر.',
    );
    final emailTitleLabel = _translated(
      context,
      'help.emailTitle',
      en: 'Email support',
      ar: 'مراسلة الدعم',
    );
    final emailDescriptionLabel = _translated(
      context,
      'help.emailDescription',
      en: 'Send a message to our support team from your default mail app.',
      ar: 'أرسل رسالة إلى فريق الدعم عبر تطبيق البريد الافتراضي لديك.',
    );
    final responseNoteLabel = _translated(
      context,
      'help.responseNote',
      en: 'For live account or order issues, creating a support ticket in the app is the fastest way for our team to track and resolve the problem.',
      ar: 'في مشاكل الحساب أو الطلبات، إنشاء تذكرة دعم من داخل التطبيق هو أسرع طريقة ليتابع فريقنا المشكلة ويحلها.',
    );

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : LightColors.background,
      appBar: AppBar(
        title: Text('settings.helpSupport'.tr),
        centerTitle: true,
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
                      width: 76.w,
                      height: 76.w,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Icon(
                        Icons.support_agent_rounded,
                        size: 40.w,
                        color: primaryColor,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'settings.helpSupport'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? DarkColors.textPrimary
                            : LightColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 12.h),
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
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              _HelpActionCard(
                icon: Icons.language_rounded,
                title: websiteTitleLabel,
                subtitle: websiteDescriptionLabel,
                value: websiteHost,
                isDark: isDark,
                onTap: () => _openWebsite(context),
              ),
              SizedBox(height: 12.h),
              _HelpActionCard(
                icon: Icons.support_agent_rounded,
                title: 'support.createTicket'.tr,
                subtitle: 'support.noTicketsDesc'.tr,
                isDark: isDark,
                onTap: () => context.push(Routes.createSupportTicket),
              ),
              SizedBox(height: 12.h),
              _HelpActionCard(
                icon: Icons.auto_awesome_rounded,
                title: 'changelog.title'.tr,
                subtitle: 'changelog.menuSubtitle'.tr,
                isDark: isDark,
                onTap: () => context.push(Routes.changelog),
              ),
              SizedBox(height: 12.h),
              _HelpActionCard(
                icon: Icons.alternate_email_rounded,
                title: emailTitleLabel,
                subtitle: emailDescriptionLabel,
                value: EnvConfig.supportEmail,
                isDark: isDark,
                onTap: () => _sendSupportEmail(context),
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.15),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  responseNoteLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.5,
                    color: isDark
                        ? DarkColors.textSecondary
                        : LightColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openWebsite(BuildContext context) async {
    final launched = await launchUrl(Uri.parse(EnvConfig.websiteUrl));
    if (!launched && context.mounted) {
      _showLaunchError(context);
    }
  }

  Future<void> _sendSupportEmail(BuildContext context) async {
    final launched = await launchUrl(
      Uri(scheme: 'mailto', path: EnvConfig.supportEmail),
    );
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

class _HelpActionCard extends StatelessWidget {
  const _HelpActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.onTap,
    this.value,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? value;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? DarkColors.surface : LightColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark ? DarkColors.border : LightColors.border,
            width: 0.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(icon, color: primaryColor, size: 22.w),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
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
                  if (value != null) ...[
                    SizedBox(height: 8.h),
                    Text(
                      value!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.chevron_right_rounded,
              size: 20.w,
              color: isDark
                  ? DarkColors.textTertiary
                  : LightColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
