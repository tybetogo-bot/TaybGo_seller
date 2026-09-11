import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/config/constants.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/config/public_app_config.dart';
import '../../../../core/data/countries.dart';
import '../../../../core/i18n/i18n.dart';
import '../../../../core/providers/public_config_provider.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/phone_number_normalizer.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../application/auth_state.dart';
import '../widgets/country_picker_widget.dart';
import '../widgets/language_selector.dart';

/// Seller login that follows the backend's runtime authentication policy.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Country _selectedCountry = Countries.defaultCountry;
  bool _forcePasswordMode = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit({required bool useOtp}) async {
    if (!_formKey.currentState!.validate()) return;

    final fullPhone = PhoneNumberNormalizer.normalizeLenient(
      _phoneController.text,
      _selectedCountry,
    );
    if (fullPhone == null) return;

    if (useOtp) {
      await ref
          .read(authProvider.notifier)
          .requestOtp(phone: fullPhone, targetRole: UserRoles.seller);
    } else {
      await ref
          .read(authProvider.notifier)
          .loginWithPassword(
            phone: fullPhone,
            password: _passwordController.text,
          );
    }
  }

  Uri _resolvePublicUrl(String value) {
    final uri = Uri.parse(value);
    return uri.hasScheme
        ? uri
        : Uri.parse(EnvConfig.apiBaseUrl).resolveUri(uri);
  }

  Future<void> _openPublicUrl(String value) async {
    final uri = _resolvePublicUrl(value);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('errors.openLink'.tr),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(translationsLoadedProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authProvider);
    final configState = ref.watch(publicAppConfigProvider);
    final config = switch (configState) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final useOtp =
        !_forcePasswordMode && (config?.usesOtpFor(UserRoles.seller) ?? false);
    final isConfigLoading = configState is AsyncLoading<PublicAppConfig>;

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next is AuthOtpSent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('auth.otpSentSuccess'.tr),
            backgroundColor: AppColors.success,
          ),
        );
        context.push(Routes.otp);
      } else if (next is AuthAuthenticated) {
        context.go(Routes.restaurantSelection);
      } else if (next is AuthError && next.code == 'otp_disabled_for_role') {
        setState(() => _forcePasswordMode = true);
        ref.invalidate(publicAppConfigProvider);
      }
    });

    final isLoading = authState is AuthLoading;

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : LightColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: Breakpoints.maxNarrowContentWidth,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      children: [
                        // Top bar with language selector
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 12.h,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: const [LanguageSelector()],
                          ),
                        ),

                        // Main content
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(height: 40.h),

                                // Logo
                                Center(
                                  child: Container(
                                    width: 100.w,
                                    height: 100.w,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withValues(alpha: 0.2),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(18.r),
                                      child: Image.asset(
                                        'assets/icons/TaybGo_green.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 28.h),

                                // App name
                                Text(
                                  'app.name'.tr,
                                  style: TextStyle(
                                    fontSize: 26.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? DarkColors.textPrimary
                                        : LightColors.textPrimary,
                                    letterSpacing: -0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                SizedBox(height: 8.h),

                                // Tagline
                                Text(
                                  'app.tagline'.tr,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: isDark
                                        ? DarkColors.textSecondary
                                        : LightColors.textSecondary,
                                    height: 1.4,
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                SizedBox(height: 24.h),

                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: isConfigLoading
                                      ? const _ConfigStatusBanner.loading()
                                      : configState is AsyncError
                                      ? _ConfigStatusBanner.error(
                                          onRetry: () => ref.invalidate(
                                            publicAppConfigProvider,
                                          ),
                                        )
                                      : null,
                                ),

                                if (isConfigLoading ||
                                    configState is AsyncError)
                                  SizedBox(height: 20.h),

                                Text(
                                  useOtp
                                      ? 'auth.otpLoginDescription'.tr
                                      : 'auth.passwordLoginDescription'.tr,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    height: 1.4,
                                    color: isDark
                                        ? DarkColors.textSecondary
                                        : LightColors.textSecondary,
                                  ),
                                ),

                                SizedBox(height: 28.h),

                                // Phone input section
                                Text(
                                  'auth.enterPhone'.tr,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? DarkColors.textSecondary
                                        : LightColors.textSecondary,
                                  ),
                                ),

                                SizedBox(height: 12.h),

                                // Phone input with country picker
                                PhoneInputField(
                                  controller: _phoneController,
                                  selectedCountry: _selectedCountry,
                                  onCountrySelected: (country) {
                                    setState(() {
                                      _selectedCountry = country;
                                    });
                                  },
                                  allowInternationalInput: true,
                                  onChanged: (_) => ref
                                      .read(authProvider.notifier)
                                      .clearError(),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'validation.required'.tr;
                                    }
                                    if (PhoneNumberNormalizer.normalizeLenient(
                                          value,
                                          _selectedCountry,
                                        ) ==
                                        null) {
                                      return 'validation.invalidPhone'.tr;
                                    }
                                    return null;
                                  },
                                  enabled: !isLoading,
                                ),

                                if (!useOtp) ...[
                                  SizedBox(height: 20.h),
                                  AppTextField(
                                    controller: _passwordController,
                                    label: 'auth.password'.tr,
                                    hint: 'auth.enterPassword'.tr,
                                    prefixIcon: Icons.lock_outline_rounded,
                                    obscureText: true,
                                    enabled: !isLoading,
                                    textInputAction: TextInputAction.done,
                                    onChanged: (_) => ref
                                        .read(authProvider.notifier)
                                        .clearError(),
                                    onSubmitted: (_) {
                                      if (!isLoading && !isConfigLoading) {
                                        _handleSubmit(useOtp: false);
                                      }
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'validation.required'.tr;
                                      }
                                      if (value.length <
                                          AppConfig.minPasswordLength) {
                                        return 'validation.passwordTooShort'
                                            .trParams({
                                              'length': AppConfig
                                                  .minPasswordLength
                                                  .toString(),
                                            });
                                      }
                                      return null;
                                    },
                                  ),
                                ],

                                if (authState is AuthError) ...[
                                  SizedBox(height: 18.h),
                                  _AuthErrorBanner(message: authState.message),
                                ],

                                SizedBox(height: 24.h),

                                // Continue button
                                SizedBox(
                                  height: 52.h,
                                  child: ElevatedButton(
                                    onPressed: isLoading || isConfigLoading
                                        ? null
                                        : () => _handleSubmit(useOtp: useOtp),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.5),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                    ),
                                    child: isLoading
                                        ? SizedBox(
                                            width: 22.w,
                                            height: 22.w,
                                            child:
                                                const CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Colors.white),
                                                ),
                                          )
                                        : Text(
                                            useOtp
                                                ? 'auth.sendOtp'.tr
                                                : 'auth.signIn'.tr,
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),

                                SizedBox(height: 32.h),
                              ],
                            ),
                          ),
                        ),

                        // Terms at bottom
                        Padding(
                          padding: EdgeInsets.only(bottom: 6.h),
                          child: Text(
                            AppConfig.compactReleaseLabel,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: isDark
                                  ? DarkColors.textTertiary
                                  : LightColors.textTertiary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 20.h),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                '${'auth.termsAgree'.tr} ',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: isDark
                                      ? DarkColors.textTertiary
                                      : LightColors.textTertiary,
                                ),
                              ),
                              _LegalLink(
                                label: 'auth.termsOfService'.tr,
                                onTap: () => _openPublicUrl(
                                  config?.termsUrl ?? '/terms-and-conditions/',
                                ),
                              ),
                              Text(
                                ' ${'auth.and'.tr} ',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: isDark
                                      ? DarkColors.textTertiary
                                      : LightColors.textTertiary,
                                ),
                              ),
                              _LegalLink(
                                label: 'auth.privacyPolicy'.tr,
                                onTap: () => _openPublicUrl(
                                  config?.privacyUrl ?? '/privacy-policy/',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfigStatusBanner extends StatelessWidget {
  const _ConfigStatusBanner.loading() : onRetry = null, isLoading = true;

  const _ConfigStatusBanner.error({required this.onRetry}) : isLoading = false;

  final VoidCallback? onRetry;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final color = isLoading
        ? Theme.of(context).colorScheme.primary
        : AppColors.warning;
    return Container(
      key: ValueKey(isLoading),
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          if (isLoading)
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            )
          else
            Icon(Icons.cloud_off_outlined, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isLoading ? 'auth.checkingSignIn'.tr : 'auth.configFallback'.tr,
              style: TextStyle(fontSize: 12, height: 1.35, color: color),
            ),
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: Text('common.retry'.tr)),
        ],
      ),
    );
  }
}

class _AuthErrorBanner extends StatelessWidget {
  const _AuthErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.error),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: AppColors.error, height: 1.35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegalLink extends StatelessWidget {
  const _LegalLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
            decorationColor: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
