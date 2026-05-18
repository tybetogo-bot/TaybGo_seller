import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/theme.dart';

/// Language selection screen
class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(translationsLoadedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLocale = ref.watch(localeProvider);

    final languages = [
      _Language('English', 'en', 'US', '🇺🇸'),
      _Language('Deutsch', 'de', 'DE', '🇩🇪'),
      _Language('Français', 'fr', 'FR', '🇫🇷'),
      _Language('العربية', 'ar', 'SA', '🇸🇦'),
      _Language('Lëtzebuergesch', 'lb', 'LU', '🇱🇺'),
      _Language('Italiano', 'it', 'IT', '🇮🇹'),
      _Language('Nederlands', 'nl', 'NL', '🇳🇱'),
      _Language('Svenska', 'sv', 'SE', '🇸🇪'),
      _Language('Norsk', 'no', 'NO', '🇳🇴'),
      _Language('Dansk', 'da', 'DK', '🇩🇰'),
      _Language('Suomi', 'fi', 'FI', '🇫🇮'),
    ];

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : LightColors.background,
      appBar: AppBar(
        title: Text('settings.language'.tr),
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
          child: ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: languages.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: isDark ? DarkColors.border : LightColors.border,
        ),
        itemBuilder: (context, index) {
          final lang = languages[index];
          final isSelected = currentLocale.languageCode == lang.code;

          return ListTile(
            leading: Text(lang.flag, style: TextStyle(fontSize: 24.sp)),
            title: Text(
              lang.name,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isDark
                    ? DarkColors.textPrimary
                    : LightColors.textPrimary,
              ),
            ),
            subtitle: Text(
              lang.code.toUpperCase(),
              style: TextStyle(
                fontSize: 12.sp,
                color: isDark
                    ? DarkColors.textSecondary
                    : LightColors.textSecondary,
              ),
            ),
            trailing: isSelected
                ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary, size: 24.w)
                : Icon(
                    Icons.circle_outlined,
                    color: isDark ? DarkColors.border : LightColors.border,
                    size: 24.w,
                  ),
            onTap: () {
              ref
                  .read(localeProvider.notifier)
                  .setLocale(Locale(lang.code, lang.country));
              Navigator.pop(context);
            },
          );
        },
      ),
        ),
      ),
    );
  }
}

class _Language {
  const _Language(this.name, this.code, this.country, this.flag);
  final String name;
  final String code;
  final String country;
  final String flag;
}
