import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';
import '../../data/models/order_model.dart';

/// Opens the server-bounded driver dispatch delay selector.
///
/// Returning null means the seller cancelled. The value is always a whole
/// number of minutes, with zero representing immediate driver matching.
Future<int?> showDriverDispatchDelaySelector(
  BuildContext context, {
  required OrderModel order,
}) {
  final maximum = order.driverDispatchMaxDelayMinutes;
  final presets = [
    0,
    5,
    10,
    15,
  ].where((minutes) => maximum == null || minutes <= maximum).toList();

  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.42),
    barrierLabel: 'orders.driverDispatchTitle'.tr,
    builder: (_) => _DriverDispatchSheet(maximum: maximum, presets: presets),
  );
}

class _DriverDispatchSheet extends StatefulWidget {
  const _DriverDispatchSheet({required this.maximum, required this.presets});

  final int? maximum;
  final List<int> presets;

  @override
  State<_DriverDispatchSheet> createState() => _DriverDispatchSheetState();
}

class _DriverDispatchSheetState extends State<_DriverDispatchSheet> {
  late final TextEditingController _customController;
  late final FocusNode _customFocusNode;
  int? _selectedMinutes;
  bool _customSelected = false;
  String? _validationMessage;

  @override
  void initState() {
    super.initState();
    _customController = TextEditingController();
    _customFocusNode = FocusNode();
    _selectedMinutes = widget.presets.isNotEmpty ? widget.presets.first : null;
  }

  @override
  void dispose() {
    _customController.dispose();
    _customFocusNode.dispose();
    super.dispose();
  }

  void _selectPreset(int minutes) {
    setState(() {
      _selectedMinutes = minutes;
      _customSelected = false;
      _validationMessage = null;
    });
    _customFocusNode.unfocus();
  }

  void _selectCustom({bool focus = true}) {
    setState(() {
      _selectedMinutes = null;
      _customSelected = true;
      _validationMessage = null;
    });
    if (focus) {
      Future<void>.delayed(Duration.zero, () {
        if (mounted) _customFocusNode.requestFocus();
      });
    }
  }

  void _continue() {
    if (!_customSelected && _selectedMinutes != null) {
      Navigator.of(context).pop(_selectedMinutes);
      return;
    }

    final value = int.tryParse(_customController.text.trim());
    if (value == null ||
        value < 0 ||
        (widget.maximum != null && value > widget.maximum!)) {
      setState(() {
        _validationMessage = 'orders.driverDispatchValidation'.tr;
      });
      return;
    }

    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Padding(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 10.h,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16.h,
      ),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24.r),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 18.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(99.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42.w,
                    height: 42.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(13.r),
                    ),
                    child: Icon(
                      Icons.delivery_dining_rounded,
                      color: AppColors.primary,
                      size: 23.w,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'orders.driverDispatchTitle'.tr,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'orders.driverDispatchDescription'.tr,
                          style: TextStyle(
                            fontSize: 12.sp,
                            height: 1.3,
                            color: theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.66),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (widget.maximum != null) ...[
                SizedBox(height: 14.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 11.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(11.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16.w,
                        color: AppColors.info,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'orders.driverDispatchMaximum'.trParams({
                            'count': widget.maximum.toString(),
                          }),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.info,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 16.h),
              for (final minutes in widget.presets)
                Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: _DispatchChoice(
                    title: minutes == 0
                        ? 'orders.driverDispatchImmediately'.tr
                        : 'orders.driverDispatchMinutes'.trParams({
                            'count': minutes.toString(),
                          }),
                    subtitle: minutes == 0 ? 'orders.requestDriver'.tr : null,
                    icon: minutes == 0
                        ? Icons.flash_on_rounded
                        : Icons.schedule_rounded,
                    selected: !_customSelected && _selectedMinutes == minutes,
                    onTap: () => _selectPreset(minutes),
                  ),
                ),
              _buildCustomChoice(primaryColor),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(Icons.close_rounded, size: 18.w),
                          label: Text('common.cancel'.tr),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            backgroundColor: primaryColor.withValues(
                              alpha: 0.05,
                            ),
                            side: BorderSide(
                              color: primaryColor.withValues(alpha: 0.65),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13.r),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: SizedBox(
                        height: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _continue,
                          icon: Icon(Icons.check_rounded, size: 18.w),
                          label: Text('orders.driverDispatchContinue'.tr),
                          style: FilledButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13.r),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomChoice(Color primaryColor) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _customSelected
            ? primaryColor.withValues(alpha: 0.08)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: _customSelected
              ? primaryColor
              : theme.dividerColor.withValues(alpha: 0.65),
          width: _customSelected ? 1.25 : 1,
        ),
      ),
      child: InkWell(
        onTap: _selectCustom,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 11.h),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 34.w,
                    height: 34.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      color: primaryColor,
                      size: 18.w,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'orders.driverDispatchCustom'.tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _SelectionIndicator(selected: _customSelected),
                ],
              ),
              if (_customSelected) ...[
                SizedBox(height: 12.h),
                TextField(
                  controller: _customController,
                  focusNode: _customFocusNode,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'orders.driverDispatchMinutesLabel'.tr,
                    hintText: '10',
                    suffixText: 'orders.driverDispatchMinutesShort'.tr,
                    errorText: _validationMessage,
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 11.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: theme.dividerColor.withValues(alpha: 0.65),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: theme.dividerColor.withValues(alpha: 0.65),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: primaryColor, width: 1.4),
                    ),
                  ),
                  onChanged: (_) {
                    if (_validationMessage != null) {
                      setState(() => _validationMessage = null);
                    }
                  },
                  onSubmitted: (_) => _continue(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DispatchChoice extends StatelessWidget {
  const _DispatchChoice({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Material(
      color: selected
          ? primaryColor.withValues(alpha: 0.08)
          : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(
          color: selected
              ? primaryColor
              : theme.dividerColor.withValues(alpha: 0.65),
          width: selected ? 1.25 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 10.h),
          child: Row(
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: primaryColor, size: 18.w),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: theme.textTheme.bodyMedium?.color?.withValues(
                            alpha: 0.66,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _SelectionIndicator(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 20.w,
      height: 20.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? primaryColor : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? primaryColor : Theme.of(context).dividerColor,
          width: 1.5,
        ),
      ),
      child: selected
          ? Icon(Icons.check_rounded, color: Colors.white, size: 13.w)
          : null,
    );
  }
}
