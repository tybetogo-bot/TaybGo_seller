/// Service for AI-powered order form scanning via backend API
library;

import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/network/orders_api.dart';
import 'order_form_parser.dart';

/// Result from backend AI scanning
class GeminiScanResult {
  final ParsedOrderData? parsedData;
  final String? imagePath;
  final List<String> imagePaths;
  final String? rawResponse;
  final bool success;
  final String? error;
  final Map<String, bool> extractedFields;

  GeminiScanResult({
    this.parsedData,
    this.imagePath,
    this.imagePaths = const [],
    this.rawResponse,
    required this.success,
    this.error,
    this.extractedFields = const {},
  });

  factory GeminiScanResult.success(
    ParsedOrderData parsedData,
    String imagePath,
    String rawResponse,
    Map<String, bool> extractedFields, {
    List<String> imagePaths = const [],
  }) {
    return GeminiScanResult(
      parsedData: parsedData,
      imagePath: imagePath,
      imagePaths: imagePaths.isNotEmpty ? imagePaths : [imagePath],
      rawResponse: rawResponse,
      success: true,
      extractedFields: extractedFields,
    );
  }

  factory GeminiScanResult.failure(String error) {
    return GeminiScanResult(success: false, error: error);
  }
}

/// Service for AI-powered order form scanning using backend extract-draft API
class GeminiScanService {
  final OrdersApi _ordersApi;
  final int _restaurantId;
  final ImagePicker _imagePicker = ImagePicker();

  GeminiScanService({
    required OrdersApi ordersApi,
    required int restaurantId,
  })  : _ordersApi = ordersApi,
        _restaurantId = restaurantId;

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

  /// Capture a single image from camera (returns path only)
  Future<String?> captureImage() async {
    try {
      final hasPermission = await checkCameraPermission();
      if (!hasPermission) {
        return null;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
        preferredCameraDevice: CameraDevice.rear,
      );

      return image?.path;
    } catch (e) {
      return null;
    }
  }

  /// Pick a single image from gallery (returns path only)
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      return image?.path;
    } catch (e) {
      return null;
    }
  }

  /// Pick multiple images from gallery (returns paths)
  Future<List<String>> pickMultipleImagesFromGallery() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 100,
      );

      return images.map((img) => img.path).toList();
    } catch (e) {
      return [];
    }
  }

  /// Process multiple images via the backend extract-draft API
  Future<GeminiScanResult> processMultipleImages(
    List<String> imagePaths,
  ) async {
    if (imagePaths.isEmpty) {
      return GeminiScanResult.failure('No images to process');
    }

    try {
      final data = await _ordersApi.extractDraft(
        restaurantId: _restaurantId,
        imagePaths: imagePaths,
      );

      return _parseApiResponse(data, imagePaths);
    } catch (e) {
      final message = e.toString();
      if (message.contains('415')) {
        return GeminiScanResult.failure(
          'Unsupported file type. Please use JPEG or PNG images.',
        );
      }
      if (message.contains('400')) {
        return GeminiScanResult.failure(
          'Invalid request. Please check images and try again.',
        );
      }
      if (message.contains('404')) {
        return GeminiScanResult.failure(
          'Restaurant not found. Please check your settings.',
        );
      }
      if (message.contains('502')) {
        return GeminiScanResult.failure(
          'Server is temporarily unavailable. Please try again later.',
        );
      }
      return GeminiScanResult.failure('Processing error: $e');
    }
  }

  /// Parse the backend API response into ParsedOrderData
  GeminiScanResult _parseApiResponse(
    Map<String, dynamic> data,
    List<String> imagePaths,
  ) {
    try {
      // Parse address from dropoff_address_draft
      final addressDraft = data['dropoff_address_draft'] as Map<String, dynamic>?;
      String? street;
      String? postalCode;
      String? city;

      if (addressDraft != null) {
        final streetName = addressDraft['street_name']?.toString();
        final houseNumber = addressDraft['house_number']?.toString();
        if (streetName != null && streetName.isNotEmpty) {
          street = houseNumber != null && houseNumber.isNotEmpty
              ? '$streetName $houseNumber'
              : streetName;
        }
        postalCode = addressDraft['postal_code']?.toString();
        city = addressDraft['city']?.toString();
      }

      // Parse items
      final items = <ParsedOrderItem>[];
      if (data['items'] != null && data['items'] is List) {
        for (final item in data['items'] as List) {
          if (item is Map<String, dynamic>) {
            double? price;
            if (item['unit_price'] != null) {
              price = double.tryParse(item['unit_price'].toString());
            }

            items.add(
              ParsedOrderItem(
                name: item['name']?.toString() ?? 'Unknown Item',
                quantity: item['quantity'] is int
                    ? item['quantity']
                    : int.tryParse(item['quantity']?.toString() ?? '1') ?? 1,
                price: price,
                toppings: item['toppings'] != null && item['toppings'] is List
                    ? (item['toppings'] as List)
                          .map((t) => t.toString())
                          .toList()
                    : [],
              ),
            );
          }
        }
      }

      // Parse total
      double? total;
      if (data['total_amount'] != null) {
        total = double.tryParse(data['total_amount'].toString());
      }

      // Build payment status from payment_type and payment_text
      String? paymentStatus;
      if (data['payment_type'] != null &&
          data['payment_type'].toString().isNotEmpty) {
        paymentStatus = data['payment_type'].toString();
      } else if (data['payment_text'] != null &&
          data['payment_text'].toString().isNotEmpty) {
        paymentStatus = data['payment_text'].toString();
      }

      // Track which fields were extracted
      final customerName = data['customer_name']?.toString();
      final phone = data['customer_phone_number']?.toString();
      final deliveryTime = data['delivery_time']?.toString();
      final deliveryInstructions = data['delivery_instructions']?.toString();

      final extractedFields = <String, bool>{
        'customerName': customerName != null && customerName.isNotEmpty,
        'phone': phone != null && phone.isNotEmpty,
        'street': street != null && street.isNotEmpty,
        'postalCode': postalCode != null && postalCode.isNotEmpty,
        'city': city != null && city.isNotEmpty,
        'deliveryTime': deliveryTime != null && deliveryTime.isNotEmpty,
        'paymentStatus': paymentStatus != null && paymentStatus.isNotEmpty,
        'total': total != null && total > 0,
        'items': items.isNotEmpty,
      };

      // Build notes from delivery_time and delivery_instructions
      String? notes;
      if (deliveryInstructions != null && deliveryInstructions.isNotEmpty) {
        notes = deliveryInstructions;
      }

      final fieldsExtracted = extractedFields.values.where((v) => v).length;
      final totalFields = extractedFields.length;
      final overallConfidence = fieldsExtracted / totalFields;

      final parsedData = ParsedOrderData(
        orderId: null,
        customerName: customerName,
        phone: phone?.replaceAll(RegExp(r'[\s\-\(\)]'), ''),
        street: street,
        postalCode: postalCode,
        city: city,
        deliveryTime: deliveryTime,
        paymentStatus: paymentStatus,
        items: items,
        total: total,
        rawText: data.toString(),
        notes: notes,
        missingForOrderCreate: data['missing_for_order_create'] != null
            ? (data['missing_for_order_create'] as List)
                  .map((e) => e.toString())
                  .toList()
            : [],
        orderIdConfidence: 0.0,
        phoneConfidence: extractedFields['phone'] == true ? 0.9 : 0.0,
        addressConfidence:
            (extractedFields['street'] == true ||
                extractedFields['postalCode'] == true ||
                extractedFields['city'] == true)
            ? overallConfidence
            : 0.0,
      );

      return GeminiScanResult.success(
        parsedData,
        imagePaths.first,
        data.toString(),
        extractedFields,
        imagePaths: imagePaths,
      );
    } catch (e) {
      return GeminiScanResult.failure(
        'Failed to parse response: $e',
      );
    }
  }

  /// Dispose resources
  void dispose() {
    // Nothing to dispose
  }
}
