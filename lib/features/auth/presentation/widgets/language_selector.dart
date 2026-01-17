import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';

/// Compact language selector widget for login screen
class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  static const _languages = [
    _Language('EN', 'en', 'US', '🇺🇸'),
    _Language('DE', 'de', 'DE', '🇩🇪'),
    _Language('FR', 'fr', 'FR', '🇫🇷'),
    _Language('عربي', 'ar', 'SA', '🇸🇦'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLocale = ref.watch(localeProvider);

    final currentLang = _languages.firstWhere(
      (l) => l.code == currentLocale.languageCode,
      orElse: () => _languages.first,
    );

    return PopupMenuButton<_Language>(
      offset: Offset(0, 40.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      color: isDark ? DarkColors.surface : LightColors.surface,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isDark
              ? DarkColors.backgroundSecondary
              : LightColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isDark ? DarkColors.border : LightColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentLang.flag,
              style: TextStyle(fontSize: 16.sp),
            ),
            SizedBox(width: 6.w),
            Text(
              currentLang.label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18.w,
              color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => _languages.map((lang) {
        final isSelected = lang.code == currentLocale.languageCode;
        return PopupMenuItem<_Language>(
          value: lang,
          child: Row(
            children: [
              Text(lang.flag, style: TextStyle(fontSize: 18.sp)),
              SizedBox(width: 12.w),
              Text(
                lang.label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (isSelected)
                Icon(
                  Icons.check_rounded,
                  size: 18.w,
                  color: AppColors.primary,
                ),
            ],
          ),
        );
      }).toList(),
      onSelected: (lang) {
        ref.read(localeProvider.notifier).setLocale(Locale(lang.code, lang.country));
      },
    );
  }
}

class _Language {
  const _Language(this.label, this.code, this.country, this.flag);
  final String label;
  final String code;
  final String country;
  final String flag;
}
