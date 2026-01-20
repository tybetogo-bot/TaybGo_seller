import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/theme/theme.dart';

/// Widget for picking and uploading images to Cloudinary
class ImagePickerWidget extends ConsumerStatefulWidget {
  const ImagePickerWidget({
    super.key,
    this.initialImageUrl,
    this.onImageUploaded,
    this.onImageRemoved,
    this.onUploadStateChanged,
  });

  final String? initialImageUrl;
  final void Function(String url)? onImageUploaded;
  final void Function()? onImageRemoved;
  final void Function(bool isUploading)? onUploadStateChanged;

  @override
  ConsumerState<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends ConsumerState<ImagePickerWidget> {
  String? _imageUrl;
  File? _selectedFile;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.initialImageUrl;
  }

  @override
  void didUpdateWidget(ImagePickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialImageUrl != oldWidget.initialImageUrl) {
      setState(() {
        _imageUrl = widget.initialImageUrl;
      });
    }
  }

  Future<void> _showImageSourceDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? DarkColors.surface : LightColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'menu.selectImageSource'.tr,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
                ),
              ),
              SizedBox(height: 20.h),
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text('menu.gallery'.tr),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.camera_alt,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text('menu.camera'.tr),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (!mounted || pickedFile == null) return;

      await _uploadImageFromXFile(pickedFile);
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Error picking image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _uploadImageFromXFile(XFile xFile) async {
    // Read the service first, before any state changes
    final cloudinaryService = ref.read(cloudinaryServiceProvider);

    if (!mounted) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _error = null;
    });

    widget.onUploadStateChanged?.call(true);

    final result = await cloudinaryService.uploadImageFromXFile(
      xFile,
      onProgress: (progress) {
        if (mounted) {
          setState(() => _uploadProgress = progress);
        }
      },
    );

    if (!mounted) return;

    setState(() => _isUploading = false);
    widget.onUploadStateChanged?.call(false);

    if (result.failure != null) {
      if (mounted) {
        setState(() => _error = result.failure!.message);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.failure!.message),
            backgroundColor: AppColors.error,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _uploadImageFromXFile(xFile),
            ),
          ),
        );
      }
      return;
    }

    if (mounted) {
      setState(() {
        _imageUrl = result.imageUrl;
        // On web, we can't use File, so only set it on mobile
        if (!kIsWeb) {
          _selectedFile = File(xFile.path);
        }
        _error = null;
      });

      widget.onImageUploaded?.call(result.imageUrl!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('menu.imageUploadSuccess'.tr),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _removeImage() {
    setState(() {
      _imageUrl = null;
      _selectedFile = null;
      _error = null;
    });
    widget.onImageRemoved?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : LightColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: _error != null
              ? AppColors.error
              : (isDark ? DarkColors.border : LightColors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.image,
                size: 20.w,
                color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
              ),
              SizedBox(width: 8.w),
              Text(
                'menu.itemImage'.tr,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                'common.optional'.tr,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDark ? DarkColors.textTertiary : LightColors.textTertiary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Image preview or placeholder
          if (_imageUrl != null && !_isUploading)
            _buildImagePreview(isDark)
          else if (_isUploading)
            _buildUploadingState(isDark)
          else
            _buildPlaceholder(isDark),

          // Error message
          if (_error != null && !_isUploading) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.error, size: 16.w),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    _error!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImagePreview(bool isDark) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: _selectedFile != null
              ? Image.file(
                  _selectedFile!,
                  height: 200.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : CachedNetworkImage(
                  imageUrl: _imageUrl!,
                  height: 200.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200.h,
                    width: double.infinity,
                    color: isDark ? DarkColors.background : LightColors.background,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200.h,
                    width: double.infinity,
                    color: isDark ? DarkColors.background : LightColors.background,
                    child: const Center(child: Icon(Icons.error)),
                  ),
                ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showImageSourceDialog,
                  icon: const Icon(Icons.edit, size: 18),
                  label: Text('menu.changeImage'.tr),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _removeImage,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: Text('menu.removeImage'.tr),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUploadingState(bool isDark) {
    return Container(
      width: double.infinity,
      height: 200.h,
      decoration: BoxDecoration(
        color: isDark ? DarkColors.background : LightColors.background,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: 16.h),
          Text(
            'menu.uploadingImage'.tr,
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: LinearProgressIndicator(
              value: _uploadProgress,
              backgroundColor: isDark ? DarkColors.border : LightColors.border,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '${(_uploadProgress * 100).toInt()}%',
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark ? DarkColors.textTertiary : LightColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    return InkWell(
      onTap: _showImageSourceDialog,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        width: double.infinity,
        height: 200.h,
        decoration: BoxDecoration(
          color: isDark ? DarkColors.background : LightColors.background,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isDark ? DarkColors.border : LightColors.border,
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 48.w,
              color: isDark ? DarkColors.textTertiary : LightColors.textTertiary,
            ),
            SizedBox(height: 8.h),
            Text(
              'menu.addImage'.tr,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
