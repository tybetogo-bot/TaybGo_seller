/// Screen for scanning order forms with OCR
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';
import '../../data/services/ocr_service.dart';
import '../../data/services/order_form_parser.dart';
import 'order_verification_screen.dart';

/// Scan order screen
class ScanOrderScreen extends ConsumerStatefulWidget {
  const ScanOrderScreen({super.key});

  @override
  ConsumerState<ScanOrderScreen> createState() => _ScanOrderScreenState();
}

class _ScanOrderScreenState extends ConsumerState<ScanOrderScreen> {
  final _ocrService = OCRService();
  final _parser = OrderFormParser();
  bool _isProcessing = false;
  String? _error;

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  Future<void> _scanFromCamera() async {
    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      // Scan with camera
      final result = await _ocrService.scanFromCamera();

      if (!result.success) {
        setState(() {
          _error = result.error;
          _isProcessing = false;
        });
        return;
      }

      // Parse the text
      final parsedData = _parser.parse(result.text);

      setState(() => _isProcessing = false);

      // Navigate to verification screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderVerificationScreen(
              scannedText: result.text,
              parsedData: parsedData,
              imagePath: result.imagePath,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Unexpected error: $e';
        _isProcessing = false;
      });
    }
  }

  Future<void> _scanFromGallery() async {
    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      // Scan from gallery
      final result = await _ocrService.scanFromGallery();

      if (!result.success) {
        setState(() {
          _error = result.error;
          _isProcessing = false;
        });
        return;
      }

      // Parse the text
      final parsedData = _parser.parse(result.text);

      setState(() => _isProcessing = false);

      // Navigate to verification screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderVerificationScreen(
              scannedText: result.text,
              parsedData: parsedData,
              imagePath: result.imagePath,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Unexpected error: $e';
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(translationsLoadedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : LightColors.background,
      appBar: AppBar(
        title: Text('orders.scan.title'.tr),
        backgroundColor: isDark ? DarkColors.background : LightColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icon and title
            Icon(
              Icons.document_scanner_outlined,
              size: 80.w,
              color: AppColors.primary,
            ),
            SizedBox(height: 24.h),

            Text(
              'orders.scan.subtitle'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),

            Text(
              'orders.scan.description'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
              ),
            ),
            SizedBox(height: 32.h),

            // Instructions card
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 20.w,
                        color: AppColors.info,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'orders.scan.tips.title'.tr,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _buildTip('orders.scan.tips.flatSurface'.tr),
                  _buildTip('orders.scan.tips.goodLighting'.tr),
                  _buildTip('orders.scan.tips.holdAbove'.tr),
                  _buildTip('orders.scan.tips.keepFocus'.tr),
                  _buildTip('orders.scan.tips.avoidGlare'.tr),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // Action buttons
            if (_isProcessing)
              Column(
                children: [
                  const CircularProgressIndicator(),
                  SizedBox(height: 16.h),
                  Text(
                    'orders.scan.processing'.tr,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  // Camera button
                  ElevatedButton.icon(
                    onPressed: _scanFromCamera,
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    label: Text(
                      'orders.scan.takePhoto'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(
                        horizontal: 32.w,
                        vertical: 16.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Gallery button
                  OutlinedButton.icon(
                    onPressed: _scanFromGallery,
                    icon: Icon(
                      Icons.photo_library_outlined,
                      color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
                    ),
                    label: Text(
                      'orders.scan.chooseFromGallery'.tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 32.w,
                        vertical: 16.h,
                      ),
                      side: BorderSide(
                        color: isDark ? DarkColors.border : LightColors.border,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ],
              ),
            SizedBox(height: 24.h),

            // Error message
            if (_error != null)
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
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 20.w,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(height: 24.h),

            // What happens next
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: isDark ? DarkColors.surface : LightColors.surface,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'orders.scan.whatNext.title'.tr,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _buildStep('1', 'orders.scan.whatNext.step1'.tr),
                  _buildStep('2', 'orders.scan.whatNext.step2'.tr),
                  _buildStep('3', 'orders.scan.whatNext.step3'.tr),
                  _buildStep('4', 'orders.scan.whatNext.step4'.tr),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String tip) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 16.w,
            color: AppColors.success,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: 13.sp,
                color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String description) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 13.sp,
                color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
