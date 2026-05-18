import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/services/web_file_picker.dart' as web_picker;
import '../../../../core/theme/theme.dart';

/// Registration document picker with photo, file, and camera capture options.
class DocumentUploadWidget extends ConsumerStatefulWidget {
  const DocumentUploadWidget({
    super.key,
    this.initialDocumentUrl,
    this.titleText,
    this.helperText,
    this.icon = Icons.description_outlined,
    this.isRequired = false,
    this.onDocumentUploaded,
    this.onDocumentRemoved,
    this.onUploadStateChanged,
  });

  final String? initialDocumentUrl;
  final String? titleText;
  final String? helperText;
  final IconData icon;
  final bool isRequired;
  final void Function(String url)? onDocumentUploaded;
  final void Function()? onDocumentRemoved;
  final void Function(bool isUploading)? onUploadStateChanged;

  @override
  ConsumerState<DocumentUploadWidget> createState() =>
      _DocumentUploadWidgetState();
}

class _DocumentUploadWidgetState extends ConsumerState<DocumentUploadWidget> {
  String? _documentUrl;
  Uint8List? _selectedBytes;
  String? _fileName;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _documentUrl = widget.initialDocumentUrl;
  }

  @override
  void didUpdateWidget(DocumentUploadWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDocumentUrl != oldWidget.initialDocumentUrl) {
      setState(() {
        _documentUrl = widget.initialDocumentUrl;
        _selectedBytes = null;
        _fileName = null;
      });
    }
  }

  bool get _hasImagePreview => _isImageName(_fileName) || _isImageUrl(_documentUrl);

  bool _isImageName(String? fileName) {
    if (fileName == null || fileName.isEmpty) return false;
    final lower = fileName.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.bmp');
  }

  bool _isImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    final path = (uri?.path ?? url).toLowerCase();
    return path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png') ||
        path.endsWith('.webp') ||
        path.endsWith('.gif') ||
        path.endsWith('.bmp');
  }

  Future<void> _showSourcePicker() async {
    // On web, image_picker's camera source isn't supported, and popping a
    // modal bottom sheet before invoking the picker breaks the browser's
    // user-activation chain (especially on iOS Safari) so the hidden
    // <input type="file"> click gets ignored. Open the native file picker
    // directly from the initial tap — iOS Safari's own sheet already
    // offers Photo Library / Take Photo / Choose File.
    if (kIsWeb) {
      await _pickFile();
      return;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showModalBottomSheet<void>(
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
                widget.titleText ?? 'onboarding.documentTitle'.tr,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? DarkColors.textPrimary
                      : LightColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                widget.helperText ?? 'onboarding.documentUploadHelper'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: isDark
                      ? DarkColors.textSecondary
                      : LightColors.textSecondary,
                ),
              ),
              SizedBox(height: 20.h),
              ListTile(
                leading: Icon(
                  Icons.photo_library_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text('onboarding.choosePhoto'.tr),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.camera_alt_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text('onboarding.useCamera'.tr),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.attach_file,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text('onboarding.chooseFile'.tr),
                onTap: () {
                  Navigator.pop(context);
                  _pickFile();
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
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 90,
      );

      if (!mounted || pickedFile == null) return;

      final bytes = await pickedFile.readAsBytes();
      await _uploadBytes(bytes, fileName: pickedFile.name);
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'onboarding.errorPickingPhoto'.tr);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('onboarding.errorPickingPhoto'.tr),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      // On web, bypass file_picker (which detaches the <input type="file">
      // element immediately after .click(), causing dropped change events
      // in recent browsers) and use a direct DOM-based picker instead.
      if (kIsWeb) {
        final picked = await web_picker.pickFileFromWeb();
        if (!mounted || picked == null) return;
        if (picked.bytes.isEmpty) {
          throw Exception('onboarding.couldNotReadSelectedFile'.tr);
        }
        await _uploadBytes(picked.bytes, fileName: picked.name);
        return;
      }

      final result = await FilePicker.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        withData: true,
      );

      if (!mounted || result == null || result.files.isEmpty) return;

      final file = result.files.single;
      final bytes = file.bytes ??
          (file.path != null ? await XFile(file.path!).readAsBytes() : null);

      if (bytes == null || bytes.isEmpty) {
        throw Exception('onboarding.couldNotReadSelectedFile'.tr);
      }

      await _uploadBytes(bytes, fileName: file.name);
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'onboarding.errorPickingFile'.tr);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('onboarding.errorPickingFile'.tr),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _uploadBytes(
    Uint8List bytes, {
    required String fileName,
  }) async {
    final cloudinaryService = ref.read(cloudinaryServiceProvider);

    try {
      if (!mounted) return;

      setState(() {
        _selectedBytes = bytes;
        _fileName = fileName;
        _isUploading = true;
        _uploadProgress = 0.0;
        _error = null;
      });

      widget.onUploadStateChanged?.call(true);

      final result = await cloudinaryService.uploadAssetFromBytes(
        bytes,
        fileName: fileName,
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
        setState(() => _error = 'onboarding.documentUploadFailed'.tr);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('onboarding.documentUploadFailed'.tr),
            backgroundColor: AppColors.error,
            action: SnackBarAction(
              label: 'common.retry'.tr,
              textColor: Colors.white,
              onPressed: () => _uploadBytes(bytes, fileName: fileName),
            ),
          ),
        );
        return;
      }

      if (result.imageUrl != null) {
        setState(() {
          _documentUrl = result.imageUrl;
          _selectedBytes = null;
          _error = null;
        });

        widget.onDocumentUploaded?.call(result.imageUrl!);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('onboarding.documentUploadedSuccess'.tr),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _error = 'onboarding.errorUploadingDocument'.tr;
        });
        widget.onUploadStateChanged?.call(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('onboarding.errorUploadingDocument'.tr),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _removeDocument() {
    setState(() {
      _documentUrl = null;
      _selectedBytes = null;
      _fileName = null;
      _error = null;
    });
    widget.onDocumentRemoved?.call();
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
                widget.icon,
                size: 20.w,
                color: isDark
                    ? DarkColors.textSecondary
                    : LightColors.textSecondary,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  widget.titleText ?? 'onboarding.documentTitle'.tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? DarkColors.textPrimary
                        : LightColors.textPrimary,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                widget.isRequired ? 'common.required'.tr : 'common.optional'.tr,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDark
                      ? DarkColors.textTertiary
                      : LightColors.textTertiary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (_documentUrl != null && !_isUploading)
            _buildPreview(isDark)
          else if (_isUploading)
            _buildUploadingState(isDark)
          else
            _buildPlaceholder(isDark),
          if (_error != null && !_isUploading) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.error, size: 16.w),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    _error!,
                    style: TextStyle(fontSize: 12.sp, color: AppColors.error),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreview(bool isDark) {
    if (_hasImagePreview) {
      return Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: _selectedBytes != null
                ? Image.memory(
                    _selectedBytes!,
                    height: 200.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    _documentUrl!,
                    height: 200.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildFileCard(isDark),
                  ),
          ),
          SizedBox(height: 12.h),
          _buildActions(),
        ],
      );
    }

    return Column(
      children: [
        _buildFileCard(isDark),
        SizedBox(height: 12.h),
        _buildActions(),
      ],
    );
  }

  Widget _buildFileCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.background : LightColors.background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: isDark ? DarkColors.border : LightColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.insert_drive_file_outlined,
            size: 32.w,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _fileName ?? 'onboarding.uploadedDocument'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? DarkColors.textPrimary
                        : LightColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  _isImageName(_fileName) || _isImageUrl(_documentUrl)
                      ? 'onboarding.photoUploaded'.tr
                      : 'onboarding.fileUploaded'.tr,
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
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _showSourcePicker,
            icon: const Icon(Icons.edit, size: 18),
            label: Text('onboarding.changeDocument'.tr),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _removeDocument,
            icon: const Icon(Icons.delete_outline, size: 18),
            label: Text('onboarding.removeDocument'.tr),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: BorderSide(color: AppColors.error),
            ),
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
            'onboarding.uploadingDocument'.tr,
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark
                  ? DarkColors.textSecondary
                  : LightColors.textSecondary,
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
              color: isDark
                  ? DarkColors.textTertiary
                  : LightColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    return InkWell(
      onTap: _showSourcePicker,
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
              widget.icon,
              size: 48.w,
              color: isDark
                  ? DarkColors.textTertiary
                  : LightColors.textTertiary,
            ),
            SizedBox(height: 8.h),
            Text(
              'onboarding.tapToUploadDocument'.tr,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark
                    ? DarkColors.textSecondary
                    : LightColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
