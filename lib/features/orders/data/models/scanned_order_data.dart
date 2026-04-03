/// Model for scanned order data that matches CreateOrderScreen fields
library;

import '../services/order_form_parser.dart';
import 'order_model.dart';

/// Scanned order data that can be directly used to fill CreateOrderScreen
class ScannedOrderData {
  final String? customerName;
  final String? phone;
  final String? countryCode;
  final AddressModel? address;
  final List<ScannedOrderItem> items;
  final double? deliveryFee;
  final double? tips;
  final double? total;
  final bool? isPaid;
  final String? notes;

  /// Map of which fields were extracted from the scan
  final Map<String, bool> extractedFields;

  const ScannedOrderData({
    this.customerName,
    this.phone,
    this.countryCode,
    this.address,
    this.items = const [],
    this.deliveryFee,
    this.tips,
    this.total,
    this.isPaid,
    this.notes,
    this.extractedFields = const {},
  });

  /// Create from ParsedOrderData (from Gemini scan)
  factory ScannedOrderData.fromParsedData(
    ParsedOrderData parsed,
    Map<String, bool> extractedFields,
  ) {
    // Parse phone and country code
    String? phone = parsed.phone;
    String? countryCode;

    if (phone != null) {
      // Check for country code prefix
      if (phone.startsWith('+')) {
        // Extract country code (e.g., +43, +31, +49)
        final match = RegExp(r'^(\+\d{1,3})(.*)$').firstMatch(phone);
        if (match != null) {
          countryCode = match.group(1);
          phone = match.group(2)?.replaceAll(RegExp(r'[\s\-]'), '');
        }
      } else if (phone.startsWith('00')) {
        // Handle 00xx format
        final match = RegExp(r'^00(\d{1,3})(.*)$').firstMatch(phone);
        if (match != null) {
          countryCode = '+${match.group(1)}';
          phone = match.group(2)?.replaceAll(RegExp(r'[\s\-]'), '');
        }
      }
    }

    // Build address model
    AddressModel? address;
    if (parsed.street != null || parsed.city != null || parsed.postalCode != null) {
      // Parse street and building number
      String street = '';
      String building = '';

      if (parsed.street != null) {
        // Try to extract house number from end of street
        final streetMatch = RegExp(r'^(.+?)\s+(\d+\s*[a-zA-Z]?)$').firstMatch(parsed.street!);
        if (streetMatch != null) {
          street = streetMatch.group(1) ?? parsed.street!;
          building = streetMatch.group(2) ?? '';
        } else {
          street = parsed.street!;
        }
      }

      address = AddressModel(
        street: street,
        building: building,
        city: parsed.city,
        postalCode: parsed.postalCode,
      );
    }

    // Convert parsed items to scanned items
    final items = parsed.items.map((item) => ScannedOrderItem(
      name: item.name,
      quantity: item.quantity,
      price: item.price,
      notes: item.toppings.isNotEmpty ? item.toppings.join(', ') : null,
    )).toList();

    // Determine if paid based on payment status
    bool? isPaid;
    if (parsed.paymentStatus != null) {
      final status = parsed.paymentStatus!.toLowerCase();
      isPaid = status.contains('paid') ||
               status.contains('betaald') ||
               status.contains('online') ||
               status.contains('ideal');
    }

    return ScannedOrderData(
      customerName: parsed.customerName,
      phone: phone,
      countryCode: countryCode,
      address: address,
      items: items,
      total: parsed.total,
      isPaid: isPaid,
      notes: _buildNotes(parsed),
      extractedFields: extractedFields,
    );
  }

  /// Build notes string from parsed data
  static String? _buildNotes(ParsedOrderData parsed) {
    final parts = <String>[];
    if (parsed.deliveryTime != null) {
      parts.add('Delivery time: ${parsed.deliveryTime}');
    }
    if (parsed.notes != null && parsed.notes!.isNotEmpty) {
      parts.add(parsed.notes!);
    }
    return parts.isNotEmpty ? parts.join('\n') : null;
  }

  /// Check if any data was extracted
  bool get hasData =>
      customerName != null ||
      phone != null ||
      address != null ||
      items.isNotEmpty ||
      total != null;

  /// Get list of extracted field names
  List<String> get extractedFieldNames =>
      extractedFields.entries.where((e) => e.value).map((e) => e.key).toList();

  /// Get list of missing field names
  List<String> get missingFieldNames =>
      extractedFields.entries.where((e) => !e.value).map((e) => e.key).toList();
}

/// Scanned order item
class ScannedOrderItem {
  final String name;
  final int quantity;
  final double? price;
  final String? notes;

  const ScannedOrderItem({
    required this.name,
    this.quantity = 1,
    this.price,
    this.notes,
  });
}
