import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Save PDF to device documents directory (mobile only)
Future<String?> savePdfToDevice(Uint8List pdfData, String orderId) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/receipt_order_$orderId.pdf');
  await file.writeAsBytes(pdfData);
  return file.path;
}

/// Share PDF via system share sheet (mobile only)
Future<void> shareReceiptFile(Uint8List pdfData, String orderId) async {
  final directory = await getTemporaryDirectory();
  final file = File('${directory.path}/receipt_order_$orderId.pdf');
  await file.writeAsBytes(pdfData);

  await Share.shareXFiles(
    [XFile(file.path)],
    subject: 'Receipt - Order #$orderId',
  );
}
