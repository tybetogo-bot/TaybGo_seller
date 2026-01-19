import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/dialogs/unsaved_changes_dialog.dart';
import '../../application/coupons_notifier.dart';
import '../../data/models/coupon_model.dart';

/// Screen for adding or editing a coupon
class AddEditCouponScreen extends ConsumerStatefulWidget {
  const AddEditCouponScreen({super.key, this.couponId});

  final String? couponId;

  @override
  ConsumerState<AddEditCouponScreen> createState() =>
      _AddEditCouponScreenState();
}

class _AddEditCouponScreenState extends ConsumerState<AddEditCouponScreen>
    with UnsavedChangesMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _codeController = TextEditingController();
  final _discountController = TextEditingController();
  final _minPriceController = TextEditingController(text: '0.00');
  final _maxUsageController = TextEditingController();
  final _maxPerUserController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  bool _isActive = true;
  bool _isLoading = false;
  bool _initialDataLoaded = false;

  bool get _isEditing => widget.couponId != null;

  @override
  void initState() {
    super.initState();
    _setupChangeListeners();
    if (_isEditing) {
      _loadExistingCoupon();
    } else {
      _initialDataLoaded = true;
    }
  }

  void _setupChangeListeners() {
    void onChange() {
      if (_initialDataLoaded) markAsChanged();
    }

    _titleController.addListener(onChange);
    _descriptionController.addListener(onChange);
    _codeController.addListener(onChange);
    _discountController.addListener(onChange);
    _minPriceController.addListener(onChange);
    _maxUsageController.addListener(onChange);
    _maxPerUserController.addListener(onChange);
  }

  void _loadExistingCoupon() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final coupon = ref
          .read(couponsProvider.notifier)
          .getCouponById(widget.couponId!);
      if (coupon != null) {
        setState(() {
          _titleController.text = coupon.title;
          _descriptionController.text = coupon.description ?? '';
          _codeController.text = coupon.code;
          _discountController.text = coupon.percentDiscount.toStringAsFixed(0);
          _minPriceController.text = coupon.minimumOrderPrice.toStringAsFixed(
            2,
          );
          _maxUsageController.text = coupon.maxTotalUsage?.toString() ?? '';
          _maxPerUserController.text = coupon.maxUsagePerUser?.toString() ?? '';
          _startDate = coupon.startDate;
          _endDate = coupon.endDate;
          _isActive = coupon.isActive;
          _initialDataLoaded = true;
        });
      } else {
        _initialDataLoaded = true;
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _codeController.dispose();
    _discountController.dispose();
    _minPriceController.dispose();
    _maxUsageController.dispose();
    _maxPerUserController.dispose();
    super.dispose();
  }

  void _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final code = List.generate(
      8,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
    _codeController.text = code;
  }

  Future<void> _selectDate(bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
      if (_initialDataLoaded) markAsChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(translationsLoadedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('MMM d, yyyy');

    return buildWithUnsavedChangesGuard(
      child: Scaffold(
      backgroundColor: isDark ? DarkColors.background : LightColors.background,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'coupons.editCoupon'.tr : 'coupons.addCoupon'.tr,
        ),
        backgroundColor: isDark
            ? DarkColors.background
            : LightColors.background,
        elevation: 0,
        actions: [
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: _showDeleteDialog,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: _inputDecoration('coupons.couponTitle'.tr, isDark),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'validation.required'.tr;
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),

            // Description
            TextFormField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: _inputDecoration('coupons.description'.tr, isDark),
            ),
            SizedBox(height: 16.h),

            // Code with generate button
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _codeController,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                      UpperCaseTextFormatter(),
                    ],
                    decoration: _inputDecoration('coupons.code'.tr, isDark),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'validation.required'.tr;
                      }
                      if (value.length < 4) {
                        return 'validation.codeTooShort'.tr;
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                FilledButton.icon(
                  onPressed: _generateCode,
                  icon: const Icon(Icons.auto_awesome),
                  label: Text('coupons.generateCode'.tr),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 18.h,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // Section: Discount
            _SectionHeader(
              title: 'coupons.discount'.tr,
              icon: Icons.percent,
              isDark: isDark,
            ),
            SizedBox(height: 12.h),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _discountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: _inputDecoration(
                      'coupons.percentDiscount'.tr,
                      isDark,
                      suffix: '%',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'validation.required'.tr;
                      }
                      final num = int.tryParse(value);
                      if (num == null || num < 1 || num > 100) {
                        return '1-100';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: TextFormField(
                    controller: _minPriceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: _inputDecoration(
                      'coupons.minOrderPrice'.tr,
                      isDark,
                      prefix: '€ ',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // Section: Usage Limits
            _SectionHeader(
              title: 'coupons.maxUsage'.tr,
              icon: Icons.people,
              isDark: isDark,
            ),
            SizedBox(height: 12.h),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _maxUsageController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: _inputDecoration(
                      'coupons.maxUsage'.tr,
                      isDark,
                      hint: 'menuItem.unlimited'.tr,
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: TextFormField(
                    controller: _maxPerUserController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: _inputDecoration(
                      'coupons.maxPerUser'.tr,
                      isDark,
                      hint: 'menuItem.unlimited'.tr,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // Section: Validity Period
            _SectionHeader(
              title: 'coupons.validUntil'.tr,
              icon: Icons.date_range,
              isDark: isDark,
            ),
            SizedBox(height: 12.h),

            Row(
              children: [
                Expanded(
                  child: _DatePicker(
                    label: 'coupons.startDate'.tr,
                    date: _startDate,
                    dateFormat: dateFormat,
                    onTap: () => _selectDate(true),
                    isDark: isDark,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _DatePicker(
                    label: 'coupons.endDate'.tr,
                    date: _endDate,
                    dateFormat: dateFormat,
                    onTap: () => _selectDate(false),
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // Active toggle
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isDark ? DarkColors.surface : LightColors.surface,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _isActive ? Icons.check_circle : Icons.cancel,
                        color: _isActive ? AppColors.success : AppColors.error,
                        size: 20.w,
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'coupons.active'.tr,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? DarkColors.textPrimary
                                  : LightColors.textPrimary,
                            ),
                          ),
                          Text(
                            _isActive
                                ? 'coupons.active'.tr
                                : 'coupons.inactive'.tr,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: isDark
                                  ? DarkColors.textTertiary
                                  : LightColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Switch.adaptive(
                    value: _isActive,
                    activeColor: AppColors.success,
                    onChanged: (value) {
                      setState(() => _isActive = value);
                      if (_initialDataLoaded) markAsChanged();
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveCoupon,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20.h,
                        width: 20.h,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _isEditing ? 'common.save'.tr : 'coupons.addCoupon'.tr,
                        style: TextStyle(fontSize: 16.sp, color: Colors.white),
                      ),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    ),
    );
  }

  InputDecoration _inputDecoration(
    String label,
    bool isDark, {
    String? prefix,
    String? suffix,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixText: prefix,
      suffixText: suffix,
      filled: true,
      fillColor: isDark ? DarkColors.surface : LightColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: isDark ? DarkColors.border : LightColors.border,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
      ),
    );
  }

  Future<void> _saveCoupon() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final coupon = CouponModel(
      id: widget.couponId ?? '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      code: _codeController.text.trim().toUpperCase(),
      percentDiscount: double.parse(_discountController.text),
      minimumOrderPrice: double.tryParse(_minPriceController.text) ?? 0.0,
      maxTotalUsage: int.tryParse(_maxUsageController.text),
      maxUsagePerUser: int.tryParse(_maxPerUserController.text),
      startDate: _startDate,
      endDate: _endDate,
      isActive: _isActive,
    );

    try {
      if (_isEditing) {
        await ref.read(couponsProvider.notifier).updateCoupon(coupon);
      } else {
        await ref.read(couponsProvider.notifier).addCoupon(coupon);
      }

      if (!mounted) return;

      // Check if the operation resulted in an error
      final state = ref.read(couponsProvider);
      if (state.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error!),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(couponsProvider.notifier).clearError();
      } else {
        // Only show success and pop if no error
        markAsSaved();
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'coupons.couponUpdated'.tr : 'coupons.couponCreated'.tr),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${"common.error".tr}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('coupons.deleteCoupon'.tr),
        content: Text('common.actionCannotBeUndone'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('common.cancel'.tr),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              // Capture references before async gap
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              await ref
                  .read(couponsProvider.notifier)
                  .deleteCoupon(widget.couponId!);
              if (mounted) {
                // Check if the delete operation resulted in an error
                final state = ref.read(couponsProvider);
                if (state.error != null) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(state.error!),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  ref.read(couponsProvider.notifier).clearError();
                } else {
                  markAsSaved();
                  context.pop();
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('coupons.couponDeleted'.tr),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              }
            },
            child: Text('common.delete'.tr, style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.isDark,
  });

  final String title;
  final IconData icon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18.w,
          color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isDark
                ? DarkColors.textSecondary
                : LightColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _DatePicker extends StatelessWidget {
  const _DatePicker({
    required this.label,
    required this.date,
    required this.dateFormat,
    required this.onTap,
    required this.isDark,
  });

  final String label;
  final DateTime date;
  final DateFormat dateFormat;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: isDark ? DarkColors.surface : LightColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDark ? DarkColors.border : LightColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: isDark
                    ? DarkColors.textTertiary
                    : LightColors.textTertiary,
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16.w,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 8.w),
                Text(
                  dateFormat.format(date),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? DarkColors.textPrimary
                        : LightColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Text input formatter to convert to uppercase
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
