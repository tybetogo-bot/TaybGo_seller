/// Parser for extracting order data from scanned text
library;

/// Parsed order data result
class ParsedOrderData {
  final String? orderId;
  final String? customerName;
  final String? phone;
  final String? street;
  final String? postalCode;
  final String? city;
  final String? deliveryTime;
  final String? paymentStatus;
  final List<ParsedOrderItem> items;
  final double? total;
  final String rawText;
  final String? notes;
  final List<String> missingForOrderCreate;

  // Confidence scores (0.0 to 1.0)
  final double orderIdConfidence;
  final double phoneConfidence;
  final double addressConfidence;

  ParsedOrderData({
    this.orderId,
    this.customerName,
    this.phone,
    this.street,
    this.postalCode,
    this.city,
    this.deliveryTime,
    this.paymentStatus,
    this.items = const [],
    this.total,
    required this.rawText,
    this.notes,
    this.missingForOrderCreate = const [],
    this.orderIdConfidence = 0.0,
    this.phoneConfidence = 0.0,
    this.addressConfidence = 0.0,
  });

  /// Check if minimum required fields are present
  bool get isValid =>
      orderId != null &&
      customerName != null &&
      phone != null;

  /// Get list of missing fields
  List<String> get missingFields {
    final missing = <String>[];
    if (orderId == null) missing.add('Order ID');
    if (customerName == null) missing.add('Customer Name');
    if (phone == null) missing.add('Phone Number');
    if (street == null) missing.add('Street Address');
    if (city == null) missing.add('City');
    return missing;
  }
}

/// Parsed order item
class ParsedOrderItem {
  final String name;
  final int quantity;
  final double? price;
  final List<String> toppings;

  ParsedOrderItem({
    required this.name,
    this.quantity = 1,
    this.price,
    this.toppings = const [],
  });
}

/// Parser for Dutch order forms
class OrderFormParser {
  // Regex patterns for Dutch order forms

  /// Pattern for order ID (e.g., "140908A8-013")
  static final RegExp _orderIdPattern = RegExp(
    r'(\d{6}[A-Z0-9]{2}-\d{3})',
    caseSensitive: false,
  );

  /// Pattern for Dutch phone numbers (e.g., "0643192837", "06 12345678")
  static final RegExp _phonePattern = RegExp(
    r'\b(06\s?\d{8}|0\d{9})\b',
  );

  /// Pattern for Dutch postal code (e.g., "7328 VT", "7328VT")
  static final RegExp _postalCodePattern = RegExp(
    r'\b(\d{4})\s?([A-Z]{2})\b',
  );

  /// Pattern for time (e.g., "18:00", "12:30")
  static final RegExp _timePattern = RegExp(
    r'\b(\d{1,2}):(\d{2})\b',
  );

  /// Pattern for prices (e.g., "€21.60", "€ 21,60", "21.60")
  static final RegExp _pricePattern = RegExp(
    r'€?\s?(\d+)[.,](\d{2})',
  );

  /// Pattern for item quantity (e.g., "1 x", "2x")
  static final RegExp _quantityPattern = RegExp(
    r'^(\d+)\s*x\s+',
    caseSensitive: false,
  );

  /// Parse scanned text into structured order data
  ParsedOrderData parse(String scannedText) {
    final lines = scannedText.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

    // Extract all fields
    final orderId = _extractOrderId(scannedText);
    final phone = _extractPhone(scannedText);
    final address = _extractAddress(lines);
    final time = _extractTime(scannedText);
    final payment = _extractPaymentStatus(lines);
    final items = _extractItems(lines);
    final total = _extractTotal(scannedText);
    final customerName = _extractCustomerName(lines, orderId, phone);

    // Calculate confidence scores
    final orderIdConf = orderId != null ? 0.95 : 0.0;
    final phoneConf = phone != null ? (phone.length == 10 ? 0.9 : 0.7) : 0.0;
    final addressConf = address['postalCode'] != null ? 0.85 : 0.3;

    return ParsedOrderData(
      orderId: orderId,
      customerName: customerName,
      phone: phone,
      street: address['street'],
      postalCode: address['postalCode'],
      city: address['city'],
      deliveryTime: time,
      paymentStatus: payment,
      items: items,
      total: total,
      rawText: scannedText,
      orderIdConfidence: orderIdConf,
      phoneConfidence: phoneConf,
      addressConfidence: addressConf,
    );
  }

  /// Extract order ID
  String? _extractOrderId(String text) {
    final match = _orderIdPattern.firstMatch(text);
    return match?.group(1);
  }

  /// Extract phone number
  String? _extractPhone(String text) {
    final match = _phonePattern.firstMatch(text);
    final phone = match?.group(1);
    // Remove spaces
    return phone?.replaceAll(' ', '');
  }

  /// Extract address components
  Map<String, String?> _extractAddress(List<String> lines) {
    for (final line in lines) {
      final postalMatch = _postalCodePattern.firstMatch(line);
      if (postalMatch != null) {
        // Line contains postal code - this is likely the address line
        // Example: "Houtsnijdershorst 6  7328 VT Apeldoorn"
        // or: "Houtsnijdershorst 6 7328 VT Apeldoorn"

        final postalCode = '${postalMatch.group(1)} ${postalMatch.group(2)}';

        // Split by multiple spaces or by postal code
        final beforePostal = line.substring(0, postalMatch.start).trim();
        final afterPostal = line.substring(postalMatch.end).trim();

        return {
          'street': beforePostal.isNotEmpty ? beforePostal : null,
          'postalCode': postalCode,
          'city': afterPostal.isNotEmpty ? afterPostal : null,
        };
      }
    }
    return {'street': null, 'postalCode': null, 'city': null};
  }

  /// Extract delivery time
  String? _extractTime(String text) {
    final matches = _timePattern.allMatches(text);
    for (final match in matches) {
      final hour = int.tryParse(match.group(1)!);
      final minute = int.tryParse(match.group(2)!);

      // Validate time (0-23 hours, 0-59 minutes)
      if (hour != null && minute != null && hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
        return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      }
    }
    return null;
  }

  /// Extract payment status
  String? _extractPaymentStatus(List<String> lines) {
    final paymentKeywords = [
      'online betaald',
      'online',
      'betaald',
      'cash',
      'contant',
      'pin',
      'ideal',
    ];

    for (final line in lines) {
      final lowerLine = line.toLowerCase();
      for (final keyword in paymentKeywords) {
        if (lowerLine.contains(keyword)) {
          return line.trim();
        }
      }
    }
    return null;
  }

  /// Extract order items
  List<ParsedOrderItem> _extractItems(List<String> lines) {
    final items = <ParsedOrderItem>[];
    ParsedOrderItem? currentItem;

    for (final line in lines) {
      final trimmed = line.trim();

      // Check if line is a main item (starts with quantity like "1 x")
      final quantityMatch = _quantityPattern.firstMatch(trimmed);
      if (quantityMatch != null) {
        // Save previous item if exists
        if (currentItem != null) {
          items.add(currentItem);
        }

        // Extract item details
        final quantity = int.tryParse(quantityMatch.group(1)!) ?? 1;
        final rest = trimmed.substring(quantityMatch.end);

        // Split by multiple spaces to separate name and price
        final parts = rest.split(RegExp(r'\s{2,}'));
        final itemName = parts.first.trim();
        final priceStr = parts.length > 1 ? parts.last.trim() : null;
        final price = priceStr != null ? _parsePrice(priceStr) : null;

        currentItem = ParsedOrderItem(
          name: itemName,
          quantity: quantity,
          price: price,
          toppings: [],
        );
      }
      // Check if line is a topping (starts with "+")
      else if (trimmed.startsWith('+') && currentItem != null) {
        final topping = trimmed.replaceFirst('+', '').trim();
        if (topping.isNotEmpty) {
          currentItem = ParsedOrderItem(
            name: currentItem.name,
            quantity: currentItem.quantity,
            price: currentItem.price,
            toppings: [...currentItem.toppings, topping],
          );
        }
      }
    }

    // Don't forget the last item
    if (currentItem != null) {
      items.add(currentItem);
    }

    return items;
  }

  /// Extract total price
  double? _extractTotal(String text) {
    // Get all prices from text
    final matches = _pricePattern.allMatches(text);
    if (matches.isEmpty) return null;

    // The last price is usually the total
    final lastMatch = matches.last;
    return _parsePrice(lastMatch.group(0)!);
  }

  /// Extract customer name
  String? _extractCustomerName(List<String> lines, String? orderId, String? phone) {
    // Customer name typically appears after order ID and before phone number
    bool foundOrderId = false;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Skip lines until we find the order ID
      if (orderId != null && line.contains(orderId)) {
        foundOrderId = true;
        continue;
      }

      // If we found order ID, look for customer name
      if (foundOrderId) {
        // Stop if we hit the phone number
        if (phone != null && line.contains(phone)) {
          break;
        }

        final trimmed = line.trim();

        // Skip lines that look like other fields
        if (_isLikelyCustomerName(trimmed)) {
          return trimmed;
        }
      }
    }

    return null;
  }

  /// Check if line looks like a customer name
  bool _isLikelyCustomerName(String line) {
    // Name should be:
    // - Not empty
    // - Not contain postal code pattern
    // - Not contain price symbols
    // - Not start with "+"
    // - Not be just numbers
    // - Have at least one letter
    return line.isNotEmpty &&
           !_postalCodePattern.hasMatch(line) &&
           !line.contains('€') &&
           !line.startsWith('+') &&
           !line.startsWith(RegExp(r'\d')) &&
           line.contains(RegExp(r'[a-zA-Z]')) &&
           line.split(' ').length >= 2; // At least first and last name
  }

  /// Parse price string to double
  double? _parsePrice(String priceStr) {
    final match = _pricePattern.firstMatch(priceStr);
    if (match != null) {
      final euros = match.group(1);
      final cents = match.group(2);
      return double.tryParse('$euros.$cents');
    }
    return null;
  }
}
