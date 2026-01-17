/// Gemini AI Service for intelligent order form scanning
library;

import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'order_form_parser.dart';

/// Result from Gemini AI scanning
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

/// Service for AI-powered order form scanning using Gemini
class GeminiScanService {
  static const String _apiKey = 'AIzaSyCMDhk4Lzd-Vb1RbO7EABHPyj3mKYHAEcU';

  late final GenerativeModel _model;
  final ImagePicker _imagePicker = ImagePicker();

  GeminiScanService() {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.1,
        topK: 32,
        topP: 1,
        maxOutputTokens: 4096,
      ),
    );
  }

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

  /// Process multiple images with Gemini AI and combine results
  Future<GeminiScanResult> processMultipleImages(
    List<String> imagePaths,
  ) async {
    if (imagePaths.isEmpty) {
      return GeminiScanResult.failure('No images to process');
    }

    // If only one image, use single image processing
    if (imagePaths.length == 1) {
      return await _processImageWithGemini(imagePaths.first);
    }

    try {
      // Load all images (using XFile which works on both web and native)
      final List<DataPart> imageParts = [];
      for (final path in imagePaths) {
        final imageBytes = await XFile(path).readAsBytes();
        imageParts.add(DataPart('image/jpeg', imageBytes));
      }

      final prompt =
          '''
Analyze these ${imagePaths.length} images together. They are parts of the same order/receipt/form.
Combine all the information from all images into a single order.
Return a JSON object with the following structure. Only include fields that you can clearly identify in any of the images.
Be very accurate with the data extraction. If you're not sure about a field, don't include it.

{
  "customerName": "customer's full name",
  "phone": "phone number (format: just digits, no spaces)",
  "street": "street address with house number (e.g., 'Marktstraat 15')",
  "postalCode": "postal code",
  "city": "city name",
  "deliveryTime": "delivery or order time in HH:MM format",
  "paymentStatus": "payment method or status (e.g., 'Paid', 'Cash', 'Online', 'iDEAL', 'Card')",
  "total": 0.00,
  "items": [
    {
      "name": "item name",
      "quantity": 1,
      "price": 0.00,
      "toppings": ["topping1", "topping2"]
    }
  ],
  "notes": "any special instructions or notes"
}

Important:
- Combine information from ALL images into one unified order
- Extract ONLY information that is clearly visible in any image
- IMPORTANT: The street field must include the house number (e.g., "Marktstraat 15", NOT just "Marktstraat")
- If the same field appears in multiple images, use the most complete/clear version
- For phone numbers, remove spaces and special characters except + for country code
- For prices, use decimal format (e.g., 21.50)
- Combine items from all images into a single items array
- If a field is not visible or unclear in any image, omit it from the response
- Return ONLY valid JSON, no additional text or explanation
''';

      final content = [
        Content.multi([TextPart(prompt), ...imageParts]),
      ];

      final response = await _model.generateContent(content);
      final responseText = response.text;

      if (responseText == null || responseText.isEmpty) {
        return GeminiScanResult.failure(
          'No response from AI. Please try again.',
        );
      }

      // Parse the JSON response
      return _parseGeminiResponseMultiple(responseText, imagePaths);
    } catch (e) {
      if (e.toString().contains('API_KEY')) {
        return GeminiScanResult.failure(
          'API key error. Please check configuration.',
        );
      }
      return GeminiScanResult.failure('AI processing error: $e');
    }
  }

  /// Parse Gemini's JSON response for multiple images into ParsedOrderData
  GeminiScanResult _parseGeminiResponseMultiple(
    String responseText,
    List<String> imagePaths,
  ) {
    try {
      // Clean up the response - remove markdown code blocks if present
      String cleanJson = responseText.trim();
      if (cleanJson.startsWith('```json')) {
        cleanJson = cleanJson.substring(7);
      } else if (cleanJson.startsWith('```')) {
        cleanJson = cleanJson.substring(3);
      }
      if (cleanJson.endsWith('```')) {
        cleanJson = cleanJson.substring(0, cleanJson.length - 3);
      }
      cleanJson = cleanJson.trim();

      final Map<String, dynamic> data = json.decode(cleanJson);

      // Track which fields were extracted
      final extractedFields = <String, bool>{
        'customerName':
            data['customerName'] != null &&
            data['customerName'].toString().isNotEmpty,
        'phone': data['phone'] != null && data['phone'].toString().isNotEmpty,
        'street':
            data['street'] != null && data['street'].toString().isNotEmpty,
        'postalCode':
            data['postalCode'] != null &&
            data['postalCode'].toString().isNotEmpty,
        'city': data['city'] != null && data['city'].toString().isNotEmpty,
        'deliveryTime':
            data['deliveryTime'] != null &&
            data['deliveryTime'].toString().isNotEmpty,
        'paymentStatus':
            data['paymentStatus'] != null &&
            data['paymentStatus'].toString().isNotEmpty,
        'total': data['total'] != null && data['total'] != 0,
        'items': data['items'] != null && (data['items'] as List).isNotEmpty,
      };

      // Parse items
      final items = <ParsedOrderItem>[];
      if (data['items'] != null && data['items'] is List) {
        for (final item in data['items']) {
          if (item is Map<String, dynamic>) {
            items.add(
              ParsedOrderItem(
                name: item['name']?.toString() ?? 'Unknown Item',
                quantity: item['quantity'] is int
                    ? item['quantity']
                    : int.tryParse(item['quantity']?.toString() ?? '1') ?? 1,
                price: item['price'] is double
                    ? item['price']
                    : double.tryParse(item['price']?.toString() ?? '0'),
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
      if (data['total'] != null) {
        if (data['total'] is double) {
          total = data['total'];
        } else if (data['total'] is int) {
          total = (data['total'] as int).toDouble();
        } else {
          total = double.tryParse(data['total'].toString());
        }
      }

      // Calculate confidence based on number of fields extracted
      final fieldsExtracted = extractedFields.values.where((v) => v).length;
      final totalFields = extractedFields.length;
      final overallConfidence = fieldsExtracted / totalFields;

      final parsedData = ParsedOrderData(
        orderId: null, // Not extracting order ID anymore
        customerName: data['customerName']?.toString(),
        phone: data['phone']?.toString().replaceAll(RegExp(r'[\s\-\(\)]'), ''),
        street: data['street']?.toString(),
        postalCode: data['postalCode']?.toString(),
        city: data['city']?.toString(),
        deliveryTime: data['deliveryTime']?.toString(),
        paymentStatus: data['paymentStatus']?.toString(),
        items: items,
        total: total,
        rawText: responseText,
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
        responseText,
        extractedFields,
        imagePaths: imagePaths,
      );
    } catch (e) {
      return GeminiScanResult.failure(
        'Failed to parse AI response: $e\n\nRaw response: $responseText',
      );
    }
  }

  /// Scan order form from camera using Gemini AI
  Future<GeminiScanResult> scanFromCamera() async {
    try {
      final hasPermission = await checkCameraPermission();
      if (!hasPermission) {
        return GeminiScanResult.failure('Camera permission denied');
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image == null) {
        return GeminiScanResult.failure('No image captured');
      }

      return await _processImageWithGemini(image.path);
    } catch (e) {
      return GeminiScanResult.failure('Camera error: $e');
    }
  }

  /// Scan order form from gallery using Gemini AI
  Future<GeminiScanResult> scanFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (image == null) {
        return GeminiScanResult.failure('No image selected');
      }

      return await _processImageWithGemini(image.path);
    } catch (e) {
      return GeminiScanResult.failure('Gallery error: $e');
    }
  }

  /// Process image with Gemini AI
  Future<GeminiScanResult> _processImageWithGemini(String imagePath) async {
    try {
      // Using XFile which works on both web and native platforms
      final imageBytes = await XFile(imagePath).readAsBytes();

      final prompt = '''
Analyze this image and extract order/receipt/form information.
Return a JSON object with the following structure. Only include fields that you can clearly identify in the image.
Be very accurate with the data extraction. If you're not sure about a field, don't include it.

{
  "customerName": "customer's full name",
  "phone": "phone number (format: just digits, no spaces)",
  "street": "street address with house number (e.g., 'Marktstraat 15')",
  "postalCode": "postal code",
  "city": "city name",
  "deliveryTime": "delivery or order time in HH:MM format",
  "paymentStatus": "payment method or status (e.g., 'Paid', 'Cash', 'Online', 'iDEAL', 'Card')",
  "total": 0.00,
  "items": [
    {
      "name": "item name",
      "quantity": 1,
      "price": 0.00,
      "toppings": ["topping1", "topping2"]
    }
  ],
  "notes": "any special instructions or notes"
}

Important:
- Extract ONLY information that is clearly visible in the image
- IMPORTANT: The street field must include the house number (e.g., "Marktstraat 15", NOT just "Marktstraat")
- For phone numbers, remove spaces and special characters except + for country code
- For prices, use decimal format (e.g., 21.50)
- If a field is not visible or unclear, omit it from the response
- Return ONLY valid JSON, no additional text or explanation
''';

      final content = [
        Content.multi([TextPart(prompt), DataPart('image/jpeg', imageBytes)]),
      ];

      final response = await _model.generateContent(content);
      final responseText = response.text;

      if (responseText == null || responseText.isEmpty) {
        return GeminiScanResult.failure(
          'No response from AI. Please try again.',
        );
      }

      // Parse the JSON response
      final parsedData = _parseGeminiResponse(responseText, imagePath);

      return parsedData;
    } catch (e) {
      if (e.toString().contains('API_KEY')) {
        return GeminiScanResult.failure(
          'API key error. Please check configuration.',
        );
      }
      return GeminiScanResult.failure('AI processing error: $e');
    }
  }

  /// Parse Gemini's JSON response into ParsedOrderData
  GeminiScanResult _parseGeminiResponse(String responseText, String imagePath) {
    try {
      // Clean up the response - remove markdown code blocks if present
      String cleanJson = responseText.trim();
      if (cleanJson.startsWith('```json')) {
        cleanJson = cleanJson.substring(7);
      } else if (cleanJson.startsWith('```')) {
        cleanJson = cleanJson.substring(3);
      }
      if (cleanJson.endsWith('```')) {
        cleanJson = cleanJson.substring(0, cleanJson.length - 3);
      }
      cleanJson = cleanJson.trim();

      final Map<String, dynamic> data = json.decode(cleanJson);

      // Track which fields were extracted
      final extractedFields = <String, bool>{
        'customerName':
            data['customerName'] != null &&
            data['customerName'].toString().isNotEmpty,
        'phone': data['phone'] != null && data['phone'].toString().isNotEmpty,
        'street':
            data['street'] != null && data['street'].toString().isNotEmpty,
        'postalCode':
            data['postalCode'] != null &&
            data['postalCode'].toString().isNotEmpty,
        'city': data['city'] != null && data['city'].toString().isNotEmpty,
        'deliveryTime':
            data['deliveryTime'] != null &&
            data['deliveryTime'].toString().isNotEmpty,
        'paymentStatus':
            data['paymentStatus'] != null &&
            data['paymentStatus'].toString().isNotEmpty,
        'total': data['total'] != null && data['total'] != 0,
        'items': data['items'] != null && (data['items'] as List).isNotEmpty,
      };

      // Parse items
      final items = <ParsedOrderItem>[];
      if (data['items'] != null && data['items'] is List) {
        for (final item in data['items']) {
          if (item is Map<String, dynamic>) {
            items.add(
              ParsedOrderItem(
                name: item['name']?.toString() ?? 'Unknown Item',
                quantity: item['quantity'] is int
                    ? item['quantity']
                    : int.tryParse(item['quantity']?.toString() ?? '1') ?? 1,
                price: item['price'] is double
                    ? item['price']
                    : double.tryParse(item['price']?.toString() ?? '0'),
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
      if (data['total'] != null) {
        if (data['total'] is double) {
          total = data['total'];
        } else if (data['total'] is int) {
          total = (data['total'] as int).toDouble();
        } else {
          total = double.tryParse(data['total'].toString());
        }
      }

      // Calculate confidence based on number of fields extracted
      final fieldsExtracted = extractedFields.values.where((v) => v).length;
      final totalFields = extractedFields.length;
      final overallConfidence = fieldsExtracted / totalFields;

      final parsedData = ParsedOrderData(
        orderId: null, // Not extracting order ID anymore
        customerName: data['customerName']?.toString(),
        phone: data['phone']?.toString().replaceAll(RegExp(r'[\s\-\(\)]'), ''),
        street: data['street']?.toString(),
        postalCode: data['postalCode']?.toString(),
        city: data['city']?.toString(),
        deliveryTime: data['deliveryTime']?.toString(),
        paymentStatus: data['paymentStatus']?.toString(),
        items: items,
        total: total,
        rawText: responseText,
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
        imagePath,
        responseText,
        extractedFields,
      );
    } catch (e) {
      return GeminiScanResult.failure(
        'Failed to parse AI response: $e\n\nRaw response: $responseText',
      );
    }
  }

  /// Dispose resources
  void dispose() {
    // Nothing to dispose for Gemini
  }
}
