/// OCR Service for scanning printed order forms
library;

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/// Result from OCR scanning
class OCRResult {
  final String text;
  final List<TextBlock> blocks;
  final String? imagePath;
  final bool success;
  final String? error;

  OCRResult({
    required this.text,
    required this.blocks,
    this.imagePath,
    required this.success,
    this.error,
  });

  factory OCRResult.success(String text, List<TextBlock> blocks, String imagePath) {
    return OCRResult(
      text: text,
      blocks: blocks,
      imagePath: imagePath,
      success: true,
    );
  }

  factory OCRResult.failure(String error) {
    return OCRResult(
      text: '',
      blocks: [],
      success: false,
      error: error,
    );
  }
}

/// Service for OCR text recognition
class OCRService {
  final TextRecognizer _textRecognizer = TextRecognizer();
  final ImagePicker _imagePicker = ImagePicker();

  /// Check camera permission
  Future<bool> checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.camera.request();
      return result.isGranted;
    }

    return false;
  }

  /// Scan order form from camera
  Future<OCRResult> scanFromCamera() async {
    try {
      // Check permission
      final hasPermission = await checkCameraPermission();
      if (!hasPermission) {
        return OCRResult.failure('Camera permission denied');
      }

      // Capture image
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100, // Maximum quality for better OCR
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image == null) {
        return OCRResult.failure('No image captured');
      }

      // Process with OCR
      return await _processImage(image.path);
    } catch (e) {
      return OCRResult.failure('Camera error: $e');
    }
  }

  /// Scan order form from gallery
  Future<OCRResult> scanFromGallery() async {
    try {
      // Pick image from gallery
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (image == null) {
        return OCRResult.failure('No image selected');
      }

      // Process with OCR
      return await _processImage(image.path);
    } catch (e) {
      return OCRResult.failure('Gallery error: $e');
    }
  }

  /// Process image with OCR
  Future<OCRResult> _processImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      if (recognizedText.text.isEmpty) {
        return OCRResult.failure('No text found in image. Please ensure the order form is clearly visible and well-lit.');
      }

      return OCRResult.success(
        recognizedText.text,
        recognizedText.blocks,
        imagePath,
      );
    } catch (e) {
      return OCRResult.failure('OCR processing error: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _textRecognizer.close();
  }
}
