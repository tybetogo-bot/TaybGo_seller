import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import '../config/app_config.dart';
import '../config/cloudinary_config.dart';
import '../errors/failures.dart';

/// Result type for Cloudinary upload operations
typedef CloudinaryResult = ({Failure? failure, String? imageUrl});

/// Service for uploading images to Cloudinary
class CloudinaryService {
  CloudinaryService(this._dio);

  final Dio _dio;

  /// Upload an image from XFile (works on all platforms including web)
  ///
  /// [xFile] - The XFile from image_picker
  /// [onProgress] - Optional callback for upload progress (0.0 to 1.0)
  ///
  /// Returns a [CloudinaryResult] with either the image URL or a failure
  Future<CloudinaryResult> uploadImageFromXFile(
    XFile xFile, {
    void Function(double progress)? onProgress,
  }) async {
    try {
      final bytes = await xFile.readAsBytes();
      return uploadImageFromBytes(
        bytes,
        fileName: xFile.name,
        onProgress: onProgress,
      );
    } catch (e) {
      return (
        failure: ServerFailure(message: 'Failed to read image: $e'),
        imageUrl: null,
      );
    }
  }

  /// Upload an image from raw bytes.
  ///
  /// This keeps the upload path web-safe and lets callers reuse the same
  /// bytes for preview rendering without touching `dart:io`.
  Future<CloudinaryResult> uploadImageFromBytes(
    Uint8List bytes, {
    required String fileName,
    void Function(double progress)? onProgress,
  }) async {
    final validationError = _validateImage(
      bytes: bytes,
      fileName: fileName,
    );
    if (validationError != null) {
      return (failure: validationError, imageUrl: null);
    }

    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: fileName),
        'upload_preset': CloudinaryConfig.uploadPreset,
      });

      final response = await _dio.post(
        CloudinaryConfig.uploadUrl,
        data: formData,
        onSendProgress: (sent, total) {
          if (onProgress != null && total > 0) {
            onProgress(sent / total);
          }
        },
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      final secureUrl = response.data['secure_url'] as String?;
      if (secureUrl == null || secureUrl.isEmpty) {
        return (
          failure: const ServerFailure(message: 'No image URL in response'),
          imageUrl: null,
        );
      }

      return (failure: null, imageUrl: secureUrl);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return (
          failure: const NetworkFailure(message: 'Upload timeout'),
          imageUrl: null,
        );
      }

      if (e.type == DioExceptionType.connectionError) {
        return (
          failure: const NetworkFailure(message: 'No internet connection'),
          imageUrl: null,
        );
      }

      final errorMessage = e.response?.data?['error']?['message'] as String? ??
          'Upload failed';
      return (
        failure: ServerFailure(message: errorMessage),
        imageUrl: null,
      );
    } catch (e) {
      return (
        failure: ServerFailure(message: 'Unexpected error: $e'),
        imageUrl: null,
      );
    }
  }

  /// Validate an image before upload.
  ///
  /// Returns a [Failure] if validation fails, null if valid.
  Failure? _validateImage({
    required Uint8List bytes,
    required String fileName,
  }) {
    if (bytes.isEmpty) {
      return const ValidationFailure(message: 'Image file is empty');
    }

    if (bytes.lengthInBytes > AppConfig.maxImageSize) {
      return const ValidationFailure(message: 'Image must be under 5MB');
    }

    final extension = path.extension(fileName).toLowerCase();
    final extensionWithoutDot = extension.startsWith('.')
        ? extension.substring(1)
        : extension;

    if (!AppConfig.allowedImageFormats.contains(extensionWithoutDot)) {
      return const ValidationFailure(
        message: 'Only JPG, PNG, and WEBP formats allowed',
      );
    }

    return null;
  }
}
