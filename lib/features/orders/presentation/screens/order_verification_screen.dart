/// Screen for verifying and correcting OCR-scanned order data
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';
import '../../data/services/order_form_parser.dart';
import '../../application/orders_notifier.dart';

/// Order verification screen
class OrderVerificationScreen extends ConsumerStatefulWidget {
  const OrderVerificationScreen({
    super.key,
    required this.scannedText,
    required this.parsedData,
    this.imagePath,
  });

  final String scannedText;
  final ParsedOrderData parsedData;
  final String? imagePath;

  @override
  ConsumerState<OrderVerificationScreen> createState() =>
      _OrderVerificationScreenState();
}

class _OrderVerificationScreenState
    extends ConsumerState<OrderVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  String? _submitError;

  // Controllers for editable fields
  late final TextEditingController _orderIdController;
  late final TextEditingController _customerNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _streetController;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _cityController;
  late final TextEditingController _deliveryTimeController;
  late final TextEditingController _paymentStatusController;
  late final TextEditingController _totalController;

  @override
  void initState() {
    super.initState();
    final data = widget.parsedData;

    _orderIdController = TextEditingController(text: data.orderId ?? '');
    _customerNameController = TextEditingController(
      text: data.customerName ?? '',
    );
    _phoneController = TextEditingController(text: data.phone ?? '');
    _streetController = TextEditingController(text: data.street ?? '');
    _postalCodeController = TextEditingController(text: data.postalCode ?? '');
    _cityController = TextEditingController(text: data.city ?? '');
    _deliveryTimeController = TextEditingController(
      text: data.deliveryTime ?? '',
    );
    _paymentStatusController = TextEditingController(
      text: data.paymentStatus ?? '',
    );
    _totalController = TextEditingController(
      text: data.total?.toStringAsFixed(2) ?? '',
    );
  }

  @override
  void dispose() {
    _orderIdController.dispose();
    _customerNameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    _deliveryTimeController.dispose();
    _paymentStatusController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      // Prepare scanned form data
      final scannedFormData = {
        'orderId': _orderIdController.text.trim(),
        'customerName': _customerNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'street': _streetController.text.trim(),
        'postalCode': _postalCodeController.text.trim(),
        'city': _cityController.text.trim(),
        'deliveryTime': _deliveryTimeController.text.trim().isNotEmpty
            ? _deliveryTimeController.text.trim()
            : null,
        'paymentStatus': _paymentStatusController.text.trim().isNotEmpty
            ? _paymentStatusController.text.trim()
            : null,
        'total': double.tryParse(_totalController.text.trim()),
        'items': widget.parsedData.items
            .map(
              (item) => {
                'name': item.name,
                'quantity': item.quantity,
                'price': item.price,
                'toppings': item.toppings,
              },
            )
            .toList(),
        'rawText': widget.scannedText,
        'confidence': {
          'orderId': widget.parsedData.orderIdConfidence,
          'phone': widget.parsedData.phoneConfidence,
          'address': widget.parsedData.addressConfidence,
        },
      };

      // Submit via orders notifier
      final success = await ref
          .read(ordersProvider.notifier)
          .logManualOrder(scannedFormData);

      setState(() => _isSubmitting = false);

      if (success && mounted) {
        // Show success message and navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('orders.verify.orderLogged'.tr),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(); // Close verification screen
        Navigator.of(context).pop(); // Close scan screen
      } else {
        setState(() {
          _submitError = 'orders.verify.orderLogFailed'.tr;
        });
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _submitError = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : LightColors.background,
      appBar: AppBar(
        title: Text('orders.verify.title'.tr),
        backgroundColor: isDark
            ? DarkColors.background
            : LightColors.background,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info banner
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.warning,
                      size: 20.w,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'orders.verify.verifyAndCorrect'.tr,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Scanned image preview (if available)
              if (widget.imagePath != null) ...[
                Text(
                  'orders.verify.scannedImage'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? DarkColors.textPrimary
                        : LightColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  height: 200.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isDark ? DarkColors.border : LightColors.border,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.file(
                      File(widget.imagePath!),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
              ],

              // Extracted fields
              Text(
                'orders.verify.orderDetails'.tr,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? DarkColors.textPrimary
                      : LightColors.textPrimary,
                ),
              ),
              SizedBox(height: 12.h),

              // Order ID
              _buildTextField(
                controller: _orderIdController,
                label: 'orders.verify.orderId'.tr,
                icon: Icons.tag,
                required: true,
                confidence: widget.parsedData.orderIdConfidence,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'orders.verify.requiredField'.trParams({'field': 'orders.verify.orderId'.tr});
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.h),

              // Customer name
              _buildTextField(
                controller: _customerNameController,
                label: 'orders.verify.customerName'.tr,
                icon: Icons.person,
                required: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'orders.verify.requiredField'.trParams({'field': 'orders.verify.customerName'.tr});
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.h),

              // Phone
              _buildTextField(
                controller: _phoneController,
                label: 'orders.verify.phoneNumber'.tr,
                icon: Icons.phone,
                required: true,
                confidence: widget.parsedData.phoneConfidence,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'orders.verify.requiredField'.trParams({'field': 'orders.verify.phoneNumber'.tr});
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Address section
              Text(
                'orders.verify.deliveryAddress'.tr,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? DarkColors.textPrimary
                      : LightColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),

              _buildTextField(
                controller: _streetController,
                label: 'orders.verify.streetAndNumber'.tr,
                icon: Icons.home,
                confidence: widget.parsedData.addressConfidence,
              ),
              SizedBox(height: 12.h),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      controller: _postalCodeController,
                      label: 'orders.verify.postalCode'.tr,
                      icon: Icons.mail,
                      confidence: widget.parsedData.addressConfidence,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    flex: 3,
                    child: _buildTextField(
                      controller: _cityController,
                      label: 'orders.verify.city'.tr,
                      icon: Icons.location_city,
                      confidence: widget.parsedData.addressConfidence,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Optional fields
              Text(
                'orders.verify.additionalInfo'.tr,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? DarkColors.textPrimary
                      : LightColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),

              _buildTextField(
                controller: _deliveryTimeController,
                label: 'orders.verify.deliveryTime'.tr,
                icon: Icons.access_time,
              ),
              SizedBox(height: 12.h),

              _buildTextField(
                controller: _paymentStatusController,
                label: 'orders.verify.paymentStatus'.tr,
                icon: Icons.payment,
              ),
              SizedBox(height: 12.h),

              _buildTextField(
                controller: _totalController,
                label: 'orders.verify.totalAmount'.tr,
                icon: Icons.euro,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              SizedBox(height: 16.h),

              // Items section
              if (widget.parsedData.items.isNotEmpty) ...[
                Text(
                  'orders.verify.orderItems'.trParams({'count': widget.parsedData.items.length.toString()}),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? DarkColors.textPrimary
                        : LightColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: isDark ? DarkColors.surface : LightColors.surface,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    children: widget.parsedData.items
                        .map((item) => _buildItemTile(item, isDark))
                        .toList(),
                  ),
                ),
                SizedBox(height: 16.h),
              ],

              // Missing fields warning
              if (!widget.parsedData.isValid) ...[
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_outlined,
                        color: AppColors.error,
                        size: 20.w,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'orders.verify.missingFields'.tr,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.error,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              widget.parsedData.missingFields.join(', '),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
              ],

              // Submit error
              if (_submitError != null) ...[
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    _submitError!,
                    style: TextStyle(fontSize: 13.sp, color: AppColors.error),
                  ),
                ),
                SizedBox(height: 16.h),
              ],

              // Submit button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  disabledBackgroundColor: AppColors.primary.withValues(
                    alpha: 0.5,
                  ),
                ),
                child: _isSubmitting
                    ? SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        'orders.verify.submitOrder'.tr,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
    double? confidence,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLowConfidence = confidence != null && confidence < 0.8;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: '$label${required ? ' *' : ''}',
        prefixIcon: Icon(icon, size: 20.w),
        suffixIcon: isLowConfidence
            ? Tooltip(
                message:
                    'orders.verify.lowConfidence'.trParams({'percent': (confidence * 100).toStringAsFixed(0)}),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.warning,
                  size: 20.w,
                ),
              )
            : null,
        filled: true,
        fillColor: isLowConfidence
            ? AppColors.warning.withValues(alpha: 0.05)
            : (isDark ? DarkColors.surface : LightColors.surface),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(
            color: isLowConfidence
                ? AppColors.warning
                : (isDark ? DarkColors.border : LightColors.border),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(
            color: isLowConfidence
                ? AppColors.warning.withValues(alpha: 0.5)
                : (isDark ? DarkColors.border : LightColors.border),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(
            color: isLowConfidence ? AppColors.warning : AppColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: AppColors.error),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      ),
    );
  }

  Widget _buildItemTile(ParsedOrderItem item, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  '${item.quantity}x',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? DarkColors.textPrimary
                        : LightColors.textPrimary,
                  ),
                ),
              ),
              if (item.price != null)
                Text(
                  '€${item.price!.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
          if (item.toppings.isNotEmpty) ...[
            SizedBox(height: 4.h),
            ...item.toppings.map(
              (topping) => Padding(
                padding: EdgeInsets.only(left: 32.w, top: 2.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.add,
                      size: 12.w,
                      color: isDark
                          ? DarkColors.textSecondary
                          : LightColors.textSecondary,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      topping,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark
                            ? DarkColors.textSecondary
                            : LightColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
