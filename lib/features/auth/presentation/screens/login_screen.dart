import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/config/constants.dart';
import '../../../../core/data/countries.dart';
import '../../../../core/i18n/i18n.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/theme.dart';
import '../../application/auth_state.dart';
import '../widgets/country_picker_widget.dart';
import '../widgets/language_selector.dart';

/// Minimal login screen with phone number and OTP authentication
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Country _selectedCountry = Countries.defaultCountry;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleRequestOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final fullPhone =
        '${_selectedCountry.dialCode}${_phoneController.text.trim()}';
    ref
        .read(authProvider.notifier)
        .requestOtp(phone: fullPhone, targetRole: UserRoles.seller);
  }

  @override
  Widget build(BuildContext context) {
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
                    child: IntrinsicHeight(
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
                      Expanded(
                        child: Padding(
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

                                SizedBox(height: 48.h),

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
                                  enabled: !isLoading,
                                ),

                                SizedBox(height: 24.h),

                                // Continue button
                                SizedBox(
                                  height: 52.h,
                                  child: ElevatedButton(
                                    onPressed: isLoading
                                        ? null
                                        : _handleRequestOtp,
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
                                            'common.next'.tr,
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
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(text: ' ${'auth.and'.tr} '),
                              TextSpan(
                                text: 'auth.privacyPolicy'.tr,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
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
        ),
      ),
    );
  }
}
