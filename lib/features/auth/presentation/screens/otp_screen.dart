import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

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
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _timer;
  int _remainingSeconds = 60;
  bool _canResend = false;
  String _phoneNumber = '';
  String? _debugOtp; // Preserve debug OTP even after errors

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Capture the phone number and debug OTP from the initial state
    final authState = ref.read(authProvider);
    if (authState is AuthOtpSent) {
      _phoneNumber = authState.formattedPhone;
      _debugOtp = authState.debugOtp; // Preserve debug OTP
    }
    // Auto-focus the first field and show keyboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _remainingSeconds = 60;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _onOtpChanged(int index, String value) {
    // Handle paste - if multiple digits are entered at once (especially in first field)
    if (value.length > 1) {
      _handlePaste(value);
      return;
    }

    if (value.length == 1) {
      // Move to next field if available
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Last field - unfocus to hide keyboard
        _focusNodes[index].unfocus();
      }
    } else if (value.isEmpty && index > 0) {
      // If field is cleared, move to previous field
      _focusNodes[index - 1].requestFocus();
    }

    // Auto-submit when all digits are entered
    if (_otp.length == 6) {
      _verifyOtp();
    }
  }

  void _onKeyPressed(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        // Move to previous field and clear it
        _controllers[index - 1].clear();
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  // Handle paste functionality
  void _handlePaste(String pastedText) {
    final digitsOnly = pastedText.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.isEmpty) return;

    // Fill in the OTP fields with pasted digits
    for (int i = 0; i < digitsOnly.length && i < 6; i++) {
      _controllers[i].text = digitsOnly[i];
    }

    // Focus the next empty field or last field
    final nextEmptyIndex = digitsOnly.length < 6 ? digitsOnly.length : 5;
    _focusNodes[nextEmptyIndex].requestFocus();

    // Auto-verify if all 6 digits are filled
    if (digitsOnly.length >= 6) {
      _verifyOtp();
    }
  }

  // Determine if a field should be tappable
  bool _isFieldTappable(int index) {
    // First field is always tappable
    if (index == 0) return true;

    // Other fields are only tappable if the previous field is filled
    return _controllers[index - 1].text.isNotEmpty;
  }

  void _verifyOtp() {
    if (_otp.length != 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('auth.enterOtp'.tr)));
      return;
    }

    ref.read(authProvider.notifier).verifyOtp(_otp);
  }

  void _resendOtp() {
    if (!_canResend) return;
    ref.read(authProvider.notifier).resendOtp();
    _startTimer();
    // Show resend success message
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

    // Listen for state changes
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next is AuthAuthenticated) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('auth.otpVerifiedSuccess'.tr),
            backgroundColor: AppColors.success,
          ),
        );
        // Go to restaurant selection after login
        context.go(Routes.restaurantSelection);
      } else if (next is AuthError) {
        // Clear OTP fields on error for retry
        for (final controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
        // Note: State is NOT restored here - the AuthNotifier.verifyOtp() now handles
        // retrying from AuthError state by using the previousState if it's AuthOtpSent
      } else if (next is AuthOtpSent && previous is AuthOtpSent) {
        // OTP was resent - message already shown in _resendOtp
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
        _debugOtp = authState.debugOtp; // Update debug OTP when resent
      }
    }

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : LightColors.background,
      appBar: AppBar(
        backgroundColor: isDark
            ? DarkColors.background
            : LightColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text(
                'auth.verifyPhone'.tr,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? DarkColors.textPrimary
                      : LightColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'auth.codeSentTo'.tr,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDark
                      ? DarkColors.textSecondary
                      : LightColors.textSecondary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                _phoneNumber,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              // Debug OTP display (only in dev/test) - preserved across errors
              if (_debugOtp != null) ...[
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bug_report, color: Colors.orange, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Debug OTP: $_debugOtp',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 32.h),

              // OTP input fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 50.w,
                    height: 60.h,
                    child: KeyboardListener(
                      focusNode: FocusNode(),
                      onKeyEvent: (event) => _onKeyPressed(index, event),
                      child: GestureDetector(
                        onTap: () {
                          // Only allow tapping if field is tappable (sequential order)
                          if (_isFieldTappable(index) && !isLoading) {
                            _focusNodes[index].requestFocus();
                          }
                        },
                        child: AbsorbPointer(
                          // Prevent direct text field interaction, use GestureDetector instead
                          absorbing: !_isFieldTappable(index) || isLoading,
                          child: TextFormField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            // Allow paste on first field
                            maxLength: index == 0 ? null : 1,
                            enabled: !isLoading,
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? DarkColors.textPrimary
                                  : LightColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                              filled: true,
                              fillColor: _isFieldTappable(index)
                                  ? (isDark
                                      ? DarkColors.inputBackground
                                      : LightColors.inputBackground)
                                  : (isDark
                                      ? DarkColors.inputBackground.withOpacity(0.5)
                                      : LightColors.inputBackground.withOpacity(0.5)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                  color: isDark
                                      ? DarkColors.border
                                      : LightColors.border,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                  color: isDark
                                      ? DarkColors.border
                                      : LightColors.border,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                  color: (isDark
                                          ? DarkColors.border
                                          : LightColors.border)
                                      .withOpacity(0.3),
                                ),
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              // Limit to 6 digits for paste support
                              LengthLimitingTextInputFormatter(index == 0 ? 6 : 1),
                            ],
                            onChanged: (value) => _onOtpChanged(index, value),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),

              SizedBox(height: 32.h),

              // Verify button
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          'auth.verifyOtp'.tr,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
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
