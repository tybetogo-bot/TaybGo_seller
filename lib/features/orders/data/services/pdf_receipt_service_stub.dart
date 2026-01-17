import 'dart:typed_data';

/// Stub implementation for web platform
/// These functions won't be called on web as kIsWeb checks handle it

Future<String?> savePdfToDevice(Uint8List pdfData, String orderId) async {
  // Not supported on web
  return null;
}

Future<void> shareReceiptFile(Uint8List pdfData, String orderId) async {
  // Not supported on web - handled by Printing.sharePdf
}
