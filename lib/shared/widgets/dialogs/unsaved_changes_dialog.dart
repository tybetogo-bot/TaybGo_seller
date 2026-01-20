import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/i18n/i18n.dart';
import '../../../core/theme/theme.dart';

/// Dialog to warn users about unsaved changes when navigating away
class UnsavedChangesDialog extends StatelessWidget {
  const UnsavedChangesDialog({super.key});

  /// Shows the unsaved changes dialog and returns true if user wants to discard
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const UnsavedChangesDialog(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppColors.warning,
            size: 24.w,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'unsavedChanges.title'.tr,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        'unsavedChanges.message'.tr,
        style: TextStyle(
          fontSize: 14.sp,
          color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'unsavedChanges.keepEditing'.tr,
            style: TextStyle(
              color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
          ),
          child: Text(
            'unsavedChanges.discard'.tr,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

/// Mixin to add unsaved changes functionality to a StatefulWidget
///
/// Usage:
/// 1. Add the mixin to your State class
/// 2. Override [hasUnsavedChanges] getter to return whether there are unsaved changes
/// 3. Wrap your Scaffold with [buildWithUnsavedChangesGuard]
/// 4. Call [markAsSaved] when changes are successfully saved
mixin UnsavedChangesMixin<T extends StatefulWidget> on State<T> {
  bool _changesMade = false;

  /// Whether changes have been made since the form was opened or last saved
  bool get changesMade => _changesMade;

  /// Mark that changes have been made to the form
  void markAsChanged() {
    if (!_changesMade) {
      setState(() => _changesMade = true);
    }
  }

  /// Mark that changes have been saved (resets the unsaved state)
  void markAsSaved() {
    _changesMade = false;
  }

  /// Override this to provide custom logic for detecting unsaved changes
  /// By default, returns [changesMade]
  bool get hasUnsavedChanges => _changesMade;

  /// Handles the back navigation with unsaved changes check
  Future<bool> handleBackNavigation() async {
    if (!hasUnsavedChanges) return true;

    final shouldDiscard = await UnsavedChangesDialog.show(context);
    return shouldDiscard;
  }

  /// Wraps the child widget with PopScope to intercept back navigation
  Widget buildWithUnsavedChangesGuard({required Widget child}) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldPop = await handleBackNavigation();
        if (shouldPop && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: child,
    );
  }
}
