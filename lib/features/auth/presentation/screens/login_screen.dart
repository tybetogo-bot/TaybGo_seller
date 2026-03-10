import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:phone_otp_auth_ui/phone_otp_auth_ui.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';
import '../../application/auth_state.dart';
import '../widgets/language_selector.dart';

/// Minimal login screen with phone number and OTP authentication
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(translationsLoadedProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authProvider);

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
      } else if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    final isLoading = authState is AuthLoading;

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : LightColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // Top bar with language selector
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 12.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: const [LanguageSelector()],
                        ),
                      ),

                      // Main content
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: PhoneSignInForm(
                            isLoading: isLoading,
                            strings: AuthUiStrings(
                              phoneNumberLabel: 'auth.enterPhone'.tr,
                              phoneHintText: 'auth.phoneNumber'.tr,
                              enterPhoneError: 'Please enter phone number',
                              sendOtpLabel: 'common.next'.tr,
                              searchCountryHint: 'auth.searchCountry'.tr,
                            ),
                            title: Column(
                              children: [
                                SizedBox(height: 40.h),

                                // Logo
                                Center(
                                  child: Container(
                                    width: 100.w,
                                    height: 100.w,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(18.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: theme.colorScheme.primary
                                              .withValues(alpha: 0.2),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(18.r),
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
                              ],
                            ),
                            subtitle: Padding(
                              padding: EdgeInsets.only(bottom: 24.h),
                              child: Text(
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
                            ),
                            onSubmit: (value) {
                              ref.read(authProvider.notifier).requestOtp(
                                    phone: value.fullNumber,
                                  );
                            },
                          ),
                        ),
                      ),

                      // Terms at bottom
                      Padding(
                        padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 20.h),
                        child: Text.rich(
                          TextSpan(
                            text: '${'auth.termsAgree'.tr} ',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: isDark
                                  ? DarkColors.textTertiary
                                  : LightColors.textTertiary,
                            ),
                            children: [
                              TextSpan(
                                text: 'auth.termsOfService'.tr,
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(text: ' ${'auth.and'.tr} '),
                              TextSpan(
                                text: 'auth.privacyPolicy'.tr,
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
