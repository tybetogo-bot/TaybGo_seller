import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/widgets.dart';

/// Register screen
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isLoading = false);
      context.go(Routes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppScaffold(
      appBar: AppAppBar(
        title: 'auth.createAccount'.tr,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20.h),

                // Restaurant name
                AppTextField(
                  controller: _nameController,
                  label: 'auth.restaurantName'.tr,
                  hint: 'Enter your restaurant name',
                  prefixIcon: Icons.storefront_outlined,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'validation.required'.tr;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Email
                AppEmailField(
                  controller: _emailController,
                  label: 'auth.email'.tr,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'validation.required'.tr;
                    }
                    if (!value.contains('@')) {
                      return 'validation.invalidEmail'.tr;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Phone
                AppTextField(
                  controller: _phoneController,
                  label: 'auth.phoneNumber'.tr,
                  hint: 'Enter your phone number',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'validation.required'.tr;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Password
                AppPasswordField(
                  controller: _passwordController,
                  label: 'auth.password'.tr,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'validation.required'.tr;
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 32.h),

                // Register button
                AppButton(
                  label: 'auth.createAccount'.tr,
                  onPressed: _handleRegister,
                  isLoading: _isLoading,
                ),
                SizedBox(height: 16.h),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go(Routes.login),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
