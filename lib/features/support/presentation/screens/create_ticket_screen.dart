import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/theme.dart';
import '../../../orders/application/orders_notifier.dart';
import '../../../orders/data/models/order_model.dart';
import '../../application/support_notifier.dart';
import '../../data/models/support_ticket_model.dart';

class CreateTicketScreen extends ConsumerStatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  ConsumerState<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends ConsumerState<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  TicketPriority _priority = TicketPriority.low;
  String? _selectedOrderId;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedOrderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('support.selectOrder'.tr),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final success = await ref
        .read(supportProvider.notifier)
        .createTicket(
          subject: _subjectController.text.trim(),
          category: TicketCategory.order,
          priority: _priority,
          orderId: int.tryParse(_selectedOrderId!),
        );

    if (success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('support.ticketCreated'.tr)));
      context.pop();
    } else if (mounted) {
      final error = ref.read(supportProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'errors.unexpected'.tr),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(translationsLoadedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(supportProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final ordersState = ref.watch(ordersProvider);

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : LightColors.background,
      appBar: AppBar(
        title: Text('support.createTicket'.tr),
        centerTitle: true,
        backgroundColor: isDark
            ? DarkColors.background
            : LightColors.background,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: Breakpoints.maxContentWidth,
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                // Order selector
                _SectionLabel(label: 'support.relatedOrder'.tr, isDark: isDark),
            SizedBox(height: 6.h),
            _OrderSelector(
              orders: ordersState.orders,
              selectedOrderId: _selectedOrderId,
              isDark: isDark,
              primaryColor: primaryColor,
              onSelected: (id) => setState(() => _selectedOrderId = id),
            ),

            SizedBox(height: 20.h),

            // Subject
            _SectionLabel(label: 'support.subject'.tr, isDark: isDark),
            SizedBox(height: 6.h),
            TextFormField(
              controller: _subjectController,
              decoration: _inputDecoration(
                hint: 'support.subjectHint'.tr,
                isDark: isDark,
                primaryColor: primaryColor,
              ),
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark
                    ? DarkColors.textPrimary
                    : LightColors.textPrimary,
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'validation.required'.tr
                  : null,
            ),

            SizedBox(height: 20.h),

            // Priority
            _SectionLabel(label: 'support.priority'.tr, isDark: isDark),
            SizedBox(height: 6.h),
            _OptionSelector<TicketPriority>(
              options: TicketPriority.values,
              selected: _priority,
              labelBuilder: _priorityLabel,
              colorBuilder: _priorityColor,
              isDark: isDark,
              primaryColor: primaryColor,
              onSelected: (p) => setState(() => _priority = p),
            ),

            SizedBox(height: 20.h),

            // Message
            _SectionLabel(label: 'support.initialMessage'.tr, isDark: isDark),
            SizedBox(height: 6.h),
            TextFormField(
              controller: _messageController,
              maxLines: 5,
              minLines: 3,
              decoration: _inputDecoration(
                hint: 'support.initialMessageHint'.tr,
                isDark: isDark,
                primaryColor: primaryColor,
              ),
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark
                    ? DarkColors.textPrimary
                    : LightColors.textPrimary,
              ),
            ),

            SizedBox(height: 32.h),

            // Submit button
            GestureDetector(
              onTap: state.isCreating ? null : _submit,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  color: state.isCreating
                      ? primaryColor.withValues(alpha: 0.5)
                      : primaryColor,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: state.isCreating
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'support.createTicket'.tr,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
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

  InputDecoration _inputDecoration({
    required String hint,
    required bool isDark,
    required Color primaryColor,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 13.sp,
        color: isDark ? DarkColors.textTertiary : LightColors.textTertiary,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(
          color: isDark ? DarkColors.border : LightColors.border,
          width: 0.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(
          color: isDark ? DarkColors.border : LightColors.border,
          width: 0.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: primaryColor, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      filled: true,
      fillColor: isDark ? DarkColors.surface : LightColors.surface,
    );
  }

  String _priorityLabel(TicketPriority p) {
    switch (p) {
      case TicketPriority.low:
        return 'support.priorityLow'.tr;
      case TicketPriority.medium:
        return 'support.priorityMedium'.tr;
      case TicketPriority.high:
        return 'support.priorityHigh'.tr;
      case TicketPriority.urgent:
        return 'support.priorityUrgent'.tr;
    }
  }

  Color _priorityColor(TicketPriority p) {
    switch (p) {
      case TicketPriority.low:
        return AppColors.success;
      case TicketPriority.medium:
        return AppColors.warning;
      case TicketPriority.high:
        return AppColors.error;
      case TicketPriority.urgent:
        return AppColors.error;
    }
  }
}

class _OrderSelector extends StatelessWidget {
  const _OrderSelector({
    required this.orders,
    required this.selectedOrderId,
    required this.isDark,
    required this.primaryColor,
    required this.onSelected,
  });

  final List<OrderModel> orders;
  final String? selectedOrderId;
  final bool isDark;
  final Color primaryColor;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final selectedOrder = selectedOrderId != null
        ? orders.where((o) => o.id == selectedOrderId).firstOrNull
        : null;

    return GestureDetector(
      onTap: () => _showOrderPicker(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isDark ? DarkColors.surface : LightColors.surface,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isDark ? DarkColors.border : LightColors.border,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedOrder != null
                    ? '#${selectedOrder.id} - ${selectedOrder.customerName}'
                    : 'support.selectOrder'.tr,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: selectedOrder != null
                      ? (isDark
                            ? DarkColors.textPrimary
                            : LightColors.textPrimary)
                      : (isDark
                            ? DarkColors.textTertiary
                            : LightColors.textTertiary),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              size: 20.w,
              color: isDark
                  ? DarkColors.textSecondary
                  : LightColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? DarkColors.surface : LightColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                'support.selectOrder'.tr,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? DarkColors.textPrimary
                      : LightColors.textPrimary,
                ),
              ),
            ),
            Divider(
              height: 1,
              color: isDark ? DarkColors.border : LightColors.border,
            ),
            if (orders.isEmpty)
              Padding(
                padding: EdgeInsets.all(32.w),
                child: Text(
                  'common.noData'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isDark
                        ? DarkColors.textTertiary
                        : LightColors.textTertiary,
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: orders.length,
                  itemBuilder: (ctx, index) {
                    final order = orders[index];
                    final isSelected = order.id == selectedOrderId;
                    return ListTile(
                      leading: Icon(
                        Icons.receipt_outlined,
                        size: 20.w,
                        color: isSelected
                            ? primaryColor
                            : (isDark
                                  ? DarkColors.textSecondary
                                  : LightColors.textSecondary),
                      ),
                      title: Text(
                        '#${order.id} - ${order.customerName}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? primaryColor
                              : (isDark
                                    ? DarkColors.textPrimary
                                    : LightColors.textPrimary),
                        ),
                      ),
                      subtitle: Text(
                        order.status.name,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: isDark
                              ? DarkColors.textTertiary
                              : LightColors.textTertiary,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check, color: primaryColor, size: 20.w)
                          : null,
                      onTap: () {
                        onSelected(order.id);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.isDark});

  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
      ),
    );
  }
}

class _OptionSelector<T> extends StatelessWidget {
  const _OptionSelector({
    required this.options,
    required this.selected,
    required this.labelBuilder,
    required this.isDark,
    required this.primaryColor,
    required this.onSelected,
    this.iconBuilder,
    this.colorBuilder,
  });

  final List<T> options;
  final T selected;
  final String Function(T) labelBuilder;
  final IconData Function(T)? iconBuilder;
  final Color Function(T)? colorBuilder;
  final bool isDark;
  final Color primaryColor;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: options.map((option) {
        final isSelected = option == selected;
        final optColor = colorBuilder?.call(option);

        return GestureDetector(
          onTap: () => onSelected(option),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? (optColor ?? primaryColor).withValues(alpha: 0.15)
                  : (isDark ? DarkColors.surface : LightColors.surface),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: isSelected
                    ? (optColor ?? primaryColor)
                    : (isDark ? DarkColors.border : LightColors.border),
                width: isSelected ? 1.5 : 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (colorBuilder != null) ...[
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: optColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6.w),
                ],
                Text(
                  labelBuilder(option),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? (optColor ?? primaryColor)
                        : (isDark
                              ? DarkColors.textPrimary
                              : LightColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
