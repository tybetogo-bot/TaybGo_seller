/// Screen for scanning order forms with Gemini AI
library;

import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';
import '../../data/models/scanned_order_data.dart';
import '../../data/services/gemini_scan_service.dart';
import 'order_verification_screen.dart';

/// Scan order screen with multi-image support
class ScanOrderScreen extends ConsumerStatefulWidget {
  const ScanOrderScreen({
    super.key,
    this.onDataScanned,
  });

  /// Callback when data is successfully scanned and verified
  /// If provided, returns data to caller instead of navigating to verification
  final void Function(ScannedOrderData data)? onDataScanned;

  @override
  ConsumerState<ScanOrderScreen> createState() => _ScanOrderScreenState();
}

class _ScanOrderScreenState extends ConsumerState<ScanOrderScreen> {
  final _geminiService = GeminiScanService();
  final List<String> _capturedImages = [];
  bool _isProcessing = false;
  String? _error;

  @override
  void dispose() {
    _geminiService.dispose();
    super.dispose();
  }

  Future<void> _captureFromCamera() async {
    setState(() => _error = null);

    final imagePath = await _geminiService.captureImage();
    if (imagePath != null) {
      setState(() {
        _capturedImages.add(imagePath);
      });
    }
  }

  Future<void> _pickFromGallery() async {
    setState(() => _error = null);

    final imagePath = await _geminiService.pickImageFromGallery();
    if (imagePath != null) {
      setState(() {
        _capturedImages.add(imagePath);
      });
    }
  }

  Future<void> _pickMultipleFromGallery() async {
    setState(() => _error = null);

    final imagePaths = await _geminiService.pickMultipleImagesFromGallery();
    if (imagePaths.isNotEmpty) {
      setState(() {
        _capturedImages.addAll(imagePaths);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _capturedImages.removeAt(index);
    });
  }

  void _clearAllImages() {
    setState(() {
      _capturedImages.clear();
    });
  }

  Future<void> _processImages() async {
    if (_capturedImages.isEmpty) {
      setState(() {
        _error = 'orders.scan.noImages'.tr;
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      final result = await _geminiService.processMultipleImages(_capturedImages);

      if (!result.success || result.parsedData == null) {
        setState(() {
          _error = result.error ?? 'Failed to process images';
          _isProcessing = false;
        });
        return;
      }

      setState(() => _isProcessing = false);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderVerificationScreen(
              scannedText: result.rawResponse ?? '',
              parsedData: result.parsedData!,
              imagePath: result.imagePath,
              extractedFields: result.extractedFields,
              onDataConfirmed: widget.onDataScanned,
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
        actions: [
          if (_capturedImages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'orders.scan.clearAll'.tr,
              onPressed: _clearAllImages,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icon and title
            Icon(
              Icons.document_scanner_outlined,
              size: 60.w,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 16.h),

            Text(
              'orders.scan.subtitle'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),

            Text(
              'orders.scan.description'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
              ),
            ),
            SizedBox(height: 24.h),

            // Captured images preview
            if (_capturedImages.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'orders.scan.capturedImages'.tr.replaceAll('{count}', '${_capturedImages.length}'),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _captureFromCamera,
                    icon: Icon(Icons.add_a_photo, size: 18.w),
                    label: Text('orders.scan.addMore'.tr),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              SizedBox(
                height: 120.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _capturedImages.length,
                  itemBuilder: (context, index) {
                    return _buildImageThumbnail(index, isDark);
                  },
                ),
              ),
              SizedBox(height: 24.h),
            ],

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
            else if (_capturedImages.isEmpty)
              Column(
                children: [
                  // Camera button
                  ElevatedButton.icon(
                    onPressed: _captureFromCamera,
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
                      backgroundColor: Theme.of(context).colorScheme.primary,
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
                    onPressed: _pickMultipleFromGallery,
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
              )
            else
              Column(
                children: [
                  // Process button
                  ElevatedButton.icon(
                    onPressed: _processImages,
                    icon: const Icon(Icons.auto_awesome, color: Colors.white),
                    label: Text(
                      'orders.scan.processImages'.tr.replaceAll('{count}', '${_capturedImages.length}'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
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

                  // Add more options
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12.w,
                    runSpacing: 12.h,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _captureFromCamera,
                        icon: Icon(
                          Icons.camera_alt,
                          size: 18.w,
                          color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
                        ),
                        label: Text(
                          'orders.scan.addCamera'.tr,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          side: BorderSide(
                            color: isDark ? DarkColors.border : LightColors.border,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: _pickFromGallery,
                        icon: Icon(
                          Icons.photo_library_outlined,
                          size: 18.w,
                          color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
                        ),
                        label: Text(
                          'orders.scan.addGallery'.tr,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          side: BorderSide(
                            color: isDark ? DarkColors.border : LightColors.border,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                    ],
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

            // Tips card (show only if no images)
            if (_capturedImages.isEmpty) ...[
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
                    _buildTip('orders.scan.tips.multiplePages'.tr),
                    _buildTip('orders.scan.tips.keepFocus'.tr),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
            ],

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

  Widget _buildImageThumbnail(int index, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(right: 12.w),
      child: Stack(
        children: [
          Container(
            width: 100.w,
            height: 120.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isDark ? DarkColors.border : LightColors.border,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: kIsWeb
                  ? Image.network(
                      _capturedImages[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(
                          Icons.broken_image,
                          color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
                        ),
                      ),
                    )
                  : Image.file(
                      File(_capturedImages[index]),
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          // Image number badge
          Positioned(
            top: 4.h,
            left: 4.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Remove button
          Positioned(
            top: 4.h,
            right: 4.w,
            child: GestureDetector(
              onTap: () => _removeImage(index),
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  size: 14.w,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
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
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
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
