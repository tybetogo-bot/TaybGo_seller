import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/i18n/i18n.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/theme.dart';
import '../../../auth/application/auth_state.dart';
import '../../application/user_profile_notifier.dart';

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  bool _acknowledged = false;
  final _confirmController = TextEditingController();
  bool _isDeleting = false;

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  bool get _canProceed =>
      _acknowledged &&
      _confirmController.text.trim().toUpperCase() == 'DELETE';

  Future<void> _onDeletePressed() async {
    final confirmed = await _showFinalConfirmationDialog();
    if (!confirmed || !mounted) return;

    setState(() => _isDeleting = true);

    final success =
        await ref.read(userProfileProvider.notifier).deleteAccount();

    if (!mounted) return;

    if (success) {
      await ref.read(authProvider.notifier).logout();
      if (mounted) {
        context.go(Routes.login);
      }
    } else {
      setState(() => _isDeleting = false);
      final error = ref.read(userProfileProvider).error;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'deleteAccount.error'.tr),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<bool> _showFinalConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _FinalConfirmationDialog(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : LightColors.background,
      appBar: AppBar(
        title: Text('deleteAccount.title'.tr),
        centerTitle: true,
        backgroundColor:
            isDark ? DarkColors.background : LightColors.background,
        elevation: 0,
      ),
      body: _isDeleting
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  SizedBox(height: 16.h),
                  Text(
                    'deleteAccount.deleting'.tr,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isDark
                          ? DarkColors.textSecondary
                          : LightColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: Breakpoints.maxContentWidth,
                ),
                child: ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                // Warning card
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 48.w,
                        color: AppColors.error,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'deleteAccount.warningTitle'.tr,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'deleteAccount.warningDescription'.tr,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isDark
                              ? DarkColors.textSecondary
                              : LightColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // Consequences list
                Text(
                  'deleteAccount.consequencesTitle'.tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? DarkColors.textPrimary
                        : LightColors.textPrimary,
                  ),
                ),
                SizedBox(height: 12.h),
                _ConsequenceItem(
                  text: 'deleteAccount.consequence1'.tr,
                  isDark: isDark,
                ),
                _ConsequenceItem(
                  text: 'deleteAccount.consequence2'.tr,
                  isDark: isDark,
                ),
                _ConsequenceItem(
                  text: 'deleteAccount.consequence3'.tr,
                  isDark: isDark,
                ),
                _ConsequenceItem(
                  text: 'deleteAccount.consequence4'.tr,
                  isDark: isDark,
                ),

                SizedBox(height: 24.h),
                Divider(
                    color: isDark ? DarkColors.border : LightColors.border),
                SizedBox(height: 24.h),

                // Checkbox acknowledgment
                GestureDetector(
                  onTap: () =>
                      setState(() => _acknowledged = !_acknowledged),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24.w,
                        height: 24.w,
                        child: Checkbox(
                          value: _acknowledged,
                          onChanged: (value) =>
                              setState(() => _acknowledged = value ?? false),
                          activeColor: AppColors.error,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'deleteAccount.acknowledgment'.tr,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: isDark
                                ? DarkColors.textPrimary
                                : LightColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // Type DELETE confirmation
                Text(
                  'deleteAccount.typeConfirmation'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isDark
                        ? DarkColors.textSecondary
                        : LightColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: _confirmController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'DELETE',
                    hintStyle: TextStyle(
                      color: isDark
                          ? DarkColors.textTertiary
                          : LightColors.textTertiary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(
                        color:
                            isDark ? DarkColors.border : LightColors.border,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(
                        color:
                            isDark ? DarkColors.border : LightColors.border,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: const BorderSide(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    color: isDark
                        ? DarkColors.textPrimary
                        : LightColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 32.h),

                // Delete button
                GestureDetector(
                  onTap: _canProceed ? _onDeletePressed : null,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    decoration: BoxDecoration(
                      color: _canProceed
                          ? AppColors.error
                          : AppColors.error.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.delete_forever,
                          size: 20.w,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'deleteAccount.deleteButton'.tr,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16.h),
              ],
            ),
              ),
            ),
    );
  }
}

class _ConsequenceItem extends StatelessWidget {
  const _ConsequenceItem({
    required this.text,
    required this.isDark,
  });

  final String text;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.cancel_outlined,
            size: 18.w,
            color: AppColors.error,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
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
    );
  }
}

class _FinalConfirmationDialog extends StatefulWidget {
  const _FinalConfirmationDialog();

  @override
  State<_FinalConfirmationDialog> createState() =>
      _FinalConfirmationDialogState();
}

class _FinalConfirmationDialogState extends State<_FinalConfirmationDialog> {
  int _countdown = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      icon: const Icon(
        Icons.warning_amber_rounded,
        color: AppColors.error,
        size: 40,
      ),
      title: Text(
        'deleteAccount.finalConfirmTitle'.tr,
        textAlign: TextAlign.center,
      ),
      content: Text(
        'deleteAccount.finalConfirmMessage'.tr,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'common.cancel'.tr,
            style: TextStyle(
              color:
                  isDark ? DarkColors.textSecondary : LightColors.textSecondary,
            ),
          ),
        ),
        TextButton(
          onPressed: _countdown > 0 ? null : () => Navigator.pop(context, true),
          child: Text(
            _countdown > 0
                ? '${'deleteAccount.deleteButton'.tr} ($_countdown)'
                : 'deleteAccount.deleteButton'.tr,
            style: TextStyle(
              color: _countdown > 0
                  ? AppColors.error.withValues(alpha: 0.4)
                  : AppColors.error,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
