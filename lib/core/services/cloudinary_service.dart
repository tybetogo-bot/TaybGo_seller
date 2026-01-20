import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
      // Get file bytes (works on all platforms)
      final bytes = await xFile.readAsBytes();
      final fileName = xFile.name;

      // Prepare form data for upload
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
        ),
        'upload_preset': CloudinaryConfig.uploadPreset,
      });

      // Upload to Cloudinary
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

      // Extract the secure URL from response
      final secureUrl = response.data['secure_url'] as String?;
      if (secureUrl == null || secureUrl.isEmpty) {
        return (
          failure: const ServerFailure(message: 'No image URL in response'),
          imageUrl: null,
        );
      }

      return (failure: null, imageUrl: secureUrl);
    } on DioException catch (e) {
      // Map DioException to appropriate failure type
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

      // Server error response
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

  /// Upload an image to Cloudinary (legacy method for File objects)
  ///
  /// [imageFile] - The image file to upload
  /// [onProgress] - Optional callback for upload progress (0.0 to 1.0)
  ///
  /// Returns a [CloudinaryResult] with either the image URL or a failure
  Future<CloudinaryResult> uploadImage(
    File imageFile, {
    void Function(double progress)? onProgress,
  }) async {
    // Validate the image file
    final validationError = await _validateImage(imageFile);
    if (validationError != null) {
      return (failure: validationError, imageUrl: null);
    }

    try {
      // Prepare form data for upload
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: path.basename(imageFile.path),
        ),
        'upload_preset': CloudinaryConfig.uploadPreset,
      });

      // Upload to Cloudinary
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

      // Extract the secure URL from response
      final secureUrl = response.data['secure_url'] as String?;
      if (secureUrl == null || secureUrl.isEmpty) {
        return (
          failure: const ServerFailure(message: 'No image URL in response'),
          imageUrl: null,
        );
      }

      return (failure: null, imageUrl: secureUrl);
    } on DioException catch (e) {
      // Map DioException to appropriate failure type
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

      // Server error response
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

  /// Validate an image file before upload
  ///
  /// Returns a [Failure] if validation fails, null if valid
  Future<Failure?> _validateImage(File file) async {
    // On web, skip all validation since ImagePicker already handles it
    if (kIsWeb) {
      return null;
    }

    try {
      // Check if file exists (only on mobile/desktop)
      if (!await file.exists()) {
        return const ValidationFailure(message: 'Image file not found');
      }

      // Check file size (only on mobile/desktop)
      final fileSize = await file.length();
      if (fileSize > AppConfig.maxImageSize) {
        return const ValidationFailure(
          message: 'Image must be under 5MB',
        );
      }

      // Check file extension (only on mobile/desktop)
      final extension = path.extension(file.path).toLowerCase();
      final extensionWithoutDot = extension.startsWith('.')
          ? extension.substring(1)
          : extension;

      if (!AppConfig.allowedImageFormats.contains(extensionWithoutDot)) {
        return const ValidationFailure(
          message: 'Only JPG, PNG, and WEBP formats allowed',
        );
      }

      return null;
    } catch (e) {
      return ValidationFailure(message: 'Error validating image: $e');
    }
  }

  /// Public validation method for UI layer
  Future<bool> validateImage(File file) async {
    final error = await _validateImage(file);
    return error == null;
  }
}
