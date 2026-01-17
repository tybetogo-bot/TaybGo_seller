import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/data/countries.dart';
import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../application/auth_state.dart';
import '../widgets/country_picker_widget.dart';

/// Login screen with phone number and OTP authentication
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Country _selectedCountry = Countries.defaultCountry; // Austria by default

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleRequestOtp() async {
    if (!_formKey.currentState!.validate()) return;

    // Combine country code and phone number for API
    final fullPhone = '${_selectedCountry.dialCode}${_phoneController.text.trim()}';
    ref.read(authProvider.notifier).requestOtp(phone: fullPhone);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(translationsLoadedProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authProvider);

    // Listen for state changes
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next is AuthOtpSent) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('auth.otpSentSuccess'.tr),
            backgroundColor: AppColors.success,
          ),
        );
        context.push(Routes.otp);
      } else if (next is AuthAuthenticated) {
        // Note: Restaurant fetching is triggered in AuthNotifier.verifyOtp()
        // Navigation to home happens in RestaurantSelectionScreen after restaurant is selected
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

    return AppScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40.h),

                // Logo
                Center(
                  child: Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary[50],
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Icon(
                      Icons.storefront_rounded,
                      size: 48.w,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                SizedBox(height: 32.h),

                // Title
                Text(
                  'app.name'.tr,
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 8.h),

                Text(
                  'app.tagline'.tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 40.h),

                // Description
                Text(
                  'auth.enterPhone'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isDark
                        ? DarkColors.textSecondary
                        : LightColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 24.h),

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

                SizedBox(height: 8.h),

                // Helper text
                SizedBox(height: 32.h),

                // Request OTP button
                AppButton(
                  label: 'common.next'.tr,
                  onPressed: isLoading ? null : _handleRequestOtp,
                  isLoading: isLoading,
                ),

                SizedBox(height: 24.h),

                // Terms and privacy
                Text.rich(
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
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(text: ' ${'auth.and'.tr} '),
                      TextSpan(
                        text: 'auth.privacyPolicy'.tr,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
