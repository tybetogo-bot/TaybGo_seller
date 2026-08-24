import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/env_config.dart';
import '../../core/config/public_app_config.dart';
import '../../core/i18n/i18n.dart';
import '../../core/providers/public_config_provider.dart';
import '../../core/theme/theme.dart';

class RequiredUpdateGate extends ConsumerWidget {
  const RequiredUpdateGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(publicAppConfigProvider);
    return switch (config) {
      AsyncData(:final value) when value.forceUpdate => _RequiredUpdateScreen(
        config: value,
      ),
      _ => child,
    };
  }
}

class _RequiredUpdateScreen extends ConsumerStatefulWidget {
  const _RequiredUpdateScreen({required this.config});

  final PublicAppConfig config;

  @override
  ConsumerState<_RequiredUpdateScreen> createState() =>
      _RequiredUpdateScreenState();
}

class _RequiredUpdateScreenState extends ConsumerState<_RequiredUpdateScreen> {
  bool _isOpening = false;
  String? _error;

  Uri? get _updateUri {
    final value = widget.config.updateUrl;
    if (value == null) return null;
    final parsed = Uri.tryParse(value);
    if (parsed == null) return null;
    return parsed.hasScheme
        ? parsed
        : Uri.parse(EnvConfig.apiBaseUrl).resolveUri(parsed);
  }

  Future<void> _openUpdate() async {
    final uri = _updateUri;
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      setState(() => _error = 'update.invalidUrl'.tr);
      return;
    }

    setState(() {
      _isOpening = true;
      _error = null;
    });
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted) return;
    setState(() {
      _isOpening = false;
      if (!opened) _error = 'update.openFailed'.tr;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final background = isDark ? DarkColors.background : LightColors.background;
    final textPrimary = isDark
        ? DarkColors.textPrimary
        : LightColors.textPrimary;
    final textSecondary = isDark
        ? DarkColors.textSecondary
        : LightColors.textSecondary;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 112.w,
                      height: 112.w,
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.system_update_alt_rounded,
                        size: 58.w,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: 28.h),
                    Text(
                      'update.requiredTitle'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'update.requiredMessage'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15.sp,
                        height: 1.5,
                        color: textSecondary,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        'update.latestVersion'.trParams({
                          'version': widget.config.latestVersion,
                        }),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    if (_error != null) ...[
                      SizedBox(height: 18.h),
                      _UpdateError(message: _error!),
                    ],
                    SizedBox(height: 28.h),
                    SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: ElevatedButton.icon(
                        onPressed: _isOpening ? null : _openUpdate,
                        icon: _isOpening
                            ? SizedBox(
                                width: 18.w,
                                height: 18.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.open_in_new_rounded),
                        label: Text('update.updateNow'.tr),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextButton.icon(
                      onPressed: () => ref.invalidate(publicAppConfigProvider),
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text('update.checkAgain'.tr),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UpdateError extends StatelessWidget {
  const _UpdateError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.error),
      ),
    );
  }
}
