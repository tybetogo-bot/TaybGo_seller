import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:phone_otp_auth_ui/phone_otp_auth_ui.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';
import '../../application/auth_state.dart';

/// OTP verification screen
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  Timer? _timer;
  int _remainingSeconds = 60;
  bool _canResend = false;
  String _phoneNumber = '';
  String? _debugOtp;

  @override
  void initState() {
    super.initState();
    _startTimer();
    final authState = ref.read(authProvider);
    if (authState is AuthOtpSent) {
      _phoneNumber = authState.formattedPhone;
      _debugOtp = authState.debugOtp;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _remainingSeconds = 60;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  void _resendOtp() {
    if (!_canResend) return;
    ref.read(authProvider.notifier).resendOtp();
    _startTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('auth.otpSentSuccess'.tr),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _goBack() {
    ref.read(authProvider.notifier).goBackToPhoneInput();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(translationsLoadedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (!mounted) return;
      if (next is AuthAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('auth.otpVerifiedSuccess'.tr),
            backgroundColor: AppColors.success,
          ),
        );
        context.go(Routes.restaurantSelection);
      } else if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      } else if (next is AuthUnauthenticated) {
        context.go(Routes.login);
      }
    });

    final isLoading = authState is AuthLoading;

    // Update phone number and debug OTP if we get a new AuthOtpSent state
    if (authState is AuthOtpSent) {
      if (_phoneNumber.isEmpty) {
        _phoneNumber = authState.formattedPhone;
      }
      if (authState.debugOtp != null) {
        _debugOtp = authState.debugOtp;
      }
    }

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : LightColors.background,
      appBar: AppBar(
        backgroundColor:
            isDark ? DarkColors.background : LightColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OtpVerifyForm(
                  phone: _phoneNumber,
                  isLoading: isLoading,
                  testOtp: _debugOtp,
                  strings: AuthUiStrings(
                    otpVerifyTitle: 'auth.verifyPhone'.tr,
                    otpCodeLabel: 'auth.enterOtp'.tr,
                    otpCodeHintText: '------',
                    enterOtpError: 'auth.enterOtp'.tr,
                    verifyLabel: 'auth.verifyOtp'.tr,
                    changePhoneNumberLabel: 'auth.changePhone'.tr,
                    testOtpLabel: 'Debug OTP:',
                    enterCodeSentToBuilder: (_) => 'auth.codeSentTo'.tr,
                  ),
                  onSubmit: (code) {
                    ref.read(authProvider.notifier).verifyOtp(code);
                  },
                  onChangePhoneNumber: _goBack,
                ),

                SizedBox(height: 24.h),

                // Resend OTP
                Center(
                  child: _canResend
                      ? TextButton(
                          onPressed: _resendOtp,
                          child: Text(
                            'auth.resendOtp'.tr,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        )
                      : Text(
                          'auth.resendIn'.trParams({
                            'seconds': _remainingSeconds.toString(),
                          }),
                          style: TextStyle(
                            fontSize: 14.sp,
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
      ),
    );
  }
}
