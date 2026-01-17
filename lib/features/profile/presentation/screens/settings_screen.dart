import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';

/// Settings screen
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(translationsLoadedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : LightColors.background,
      appBar: AppBar(
        title: Text('settings.title'.tr),
        backgroundColor: isDark
            ? DarkColors.background
            : LightColors.background,
        elevation: 0,
      ),
      body: ListView(
        children: [
          _SettingsTile(
            icon: Icons.palette_outlined,
            title: 'settings.appearance'.tr,
            subtitle: themeMode == AppThemeMode.dark
                ? 'settings.darkMode'.tr
                : (themeMode == AppThemeMode.light
                      ? 'settings.lightMode'.tr
                      : 'settings.systemMode'.tr),
            onTap: () => _showThemeDialog(context, ref, themeMode),
            isDark: isDark,
          ),
          _SettingsTile(
            icon: Icons.language_outlined,
            title: 'settings.language'.tr,
            subtitle: ref.watch(localeProvider).languageCode.toUpperCase(),
            onTap: () => context.push(Routes.language),
            isDark: isDark,
          ),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'settings.notifications'.tr,
            onTap: () => context.push(Routes.notifications),
            isDark: isDark,
          ),
          const Divider(height: 32),
          _SettingsTile(
            icon: Icons.help_outline,
            title: 'settings.helpSupport'.tr,
            onTap: () => context.push(Routes.help),
            isDark: isDark,
          ),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'settings.about'.tr,
            onTap: () => context.push(Routes.about),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(
    BuildContext context,
    WidgetRef ref,
    AppThemeMode current,
  ) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('settings.theme'.tr),
        children: [
          SimpleDialogOption(
            onPressed: () {
              ref.read(themeProvider.notifier).setTheme(AppThemeMode.light);
              Navigator.pop(context);
            },
            child: Row(
              children: [
                Icon(
                  current == AppThemeMode.light
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Text('settings.lightMode'.tr),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              ref.read(themeProvider.notifier).setTheme(AppThemeMode.dark);
              Navigator.pop(context);
            },
            child: Row(
              children: [
                Icon(
                  current == AppThemeMode.dark
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Text('settings.darkMode'.tr),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              ref.read(themeProvider.notifier).setTheme(AppThemeMode.system);
              Navigator.pop(context);
            },
            child: Row(
              children: [
                Icon(
                  current == AppThemeMode.system
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Text('settings.systemMode'.tr),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    required this.isDark,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
      ),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: Icon(
        Icons.chevron_right,
        color: isDark ? DarkColors.textTertiary : LightColors.textTertiary,
      ),
      onTap: onTap,
    );
  }
}
