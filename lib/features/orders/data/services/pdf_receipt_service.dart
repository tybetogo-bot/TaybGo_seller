import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../data/models/order_model.dart';

// Conditional imports for platform-specific functionality
import 'pdf_receipt_service_stub.dart'
    if (dart.library.io) 'pdf_receipt_service_io.dart' as platform;

/// Service for generating PDF receipts for orders
class PdfReceiptService {
  static pw.Font? _regularFont;
  static pw.Font? _boldFont;

  /// Load fonts that support Unicode (Arabic, etc.)
  static Future<void> _loadFonts() async {
    if (_regularFont != null && _boldFont != null) return;

    try {
      // Try to load Noto Sans Arabic which supports both Latin and Arabic
      _regularFont = await PdfGoogleFonts.notoSansArabicRegular();
      _boldFont = await PdfGoogleFonts.notoSansArabicBold();
    } catch (e) {
      // Fallback to Roboto which at least supports Latin characters well
      try {
        _regularFont = await PdfGoogleFonts.robotoRegular();
        _boldFont = await PdfGoogleFonts.robotoBold();
      } catch (_) {
        // If all else fails, fonts will remain null and use default
      }
    }
  }

  /// Get text style with loaded font
  static pw.TextStyle _style({
    double fontSize = 11,
    bool bold = false,
    PdfColor? color,
    pw.FontStyle? fontStyle,
  }) {
    return pw.TextStyle(
      font: bold ? _boldFont : _regularFont,
      fontBold: _boldFont,
      fontSize: fontSize,
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      fontStyle: fontStyle,
      color: color,
    );
  }

  /// Generate PDF receipt for an order
  static Future<Uint8List> generateReceipt(
    OrderModel order, {
    String? restaurantName,
    String? restaurantAddress,
    String? restaurantPhone,
  }) async {
    // Load Unicode fonts
    await _loadFonts();

    final pdf = pw.Document();

    // Calculate totals
    double subtotal = order.subtotal;
    if (subtotal <= 0) {
      subtotal = order.calculatedSubtotal;
    }
    final deliveryFee = order.deliveryFee;
    final discountAmount = order.discountAmount;
    final tip = order.tips;
    final total = order.total > 0 ? order.total : (subtotal + deliveryFee - discountAmount + tip);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(restaurantName ?? 'TaybGo', restaurantAddress, restaurantPhone),
              pw.SizedBox(height: 24),

              // Receipt title
              pw.Center(
                child: pw.Text(
                  'ORDER RECEIPT',
                  style: _style(fontSize: 18, bold: true),
                ),
              ),
              pw.SizedBox(height: 8),

              // Order ID and Date
              pw.Center(
                child: pw.Text(
                  'Order #${order.id}',
                  style: _style(fontSize: 14, bold: true, color: PdfColors.grey700),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  _formatDateTime(order.createdAt),
                  style: _style(fontSize: 11, color: PdfColors.grey600),
                ),
              ),
              pw.SizedBox(height: 16),

              // Status badge
              pw.Center(
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: pw.BoxDecoration(
                    color: _getStatusColor(order.status),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                    order.status.displayName.toUpperCase(),
                    style: _style(fontSize: 10, bold: true, color: PdfColors.white),
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              _buildDivider(),
              pw.SizedBox(height: 16),

              // Customer info
              _buildSectionTitle('CUSTOMER INFORMATION'),
              pw.SizedBox(height: 8),
              _buildInfoRow('Name', order.customerName),
              _buildInfoRow('Phone', order.formattedPhone),
              pw.SizedBox(height: 16),

              // Delivery address
              _buildSectionTitle('DELIVERY ADDRESS'),
              pw.SizedBox(height: 8),
              if (order.dropoffAddress != null) ...[
                pw.Text(
                  order.dropoffAddress!.displayAddress,
                  style: _style(fontSize: 11),
                ),
              ] else ...[
                pw.Text(
                  order.fullAddress,
                  style: _style(fontSize: 11),
                ),
              ],
              pw.SizedBox(height: 16),

              _buildDivider(),
              pw.SizedBox(height: 16),

              // Order items
              _buildSectionTitle('ORDER ITEMS'),
              pw.SizedBox(height: 12),
              _buildItemsTable(order.items),
              pw.SizedBox(height: 16),

              _buildDivider(),
              pw.SizedBox(height: 16),

              // Payment summary
              _buildSectionTitle('PAYMENT SUMMARY'),
              pw.SizedBox(height: 12),
              _buildPaymentSummary(
                subtotal: subtotal,
                deliveryFee: deliveryFee,
                discountAmount: discountAmount,
                tip: tip,
                total: total,
                isPaid: order.isPaid,
              ),

              // Notes if present
              if (order.notes != null && order.notes!.isNotEmpty) ...[
                pw.SizedBox(height: 16),
                _buildDivider(),
                pw.SizedBox(height: 16),
                _buildSectionTitle('ORDER NOTES'),
                pw.SizedBox(height: 8),
                pw.Text(
                  order.notes!,
                  style: _style(fontSize: 11, color: PdfColors.grey700),
                ),
              ],

              // Driver info if assigned
              if (order.driver != null) ...[
                pw.SizedBox(height: 16),
                _buildDivider(),
                pw.SizedBox(height: 16),
                _buildSectionTitle('DRIVER INFORMATION'),
                pw.SizedBox(height: 8),
                _buildInfoRow('Name', order.driver!.name),
                if (order.driver!.phone != null)
                  _buildInfoRow('Phone', order.driver!.phone!),
              ],

              pw.Spacer(),

              // Footer
              _buildFooter(),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(String name, String? address, String? phone) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          name,
          style: _style(fontSize: 24, bold: true),
        ),
        if (address != null) ...[
          pw.SizedBox(height: 4),
          pw.Text(
            address,
            style: _style(fontSize: 10, color: PdfColors.grey600),
          ),
        ],
        if (phone != null) ...[
          pw.SizedBox(height: 2),
          pw.Text(
            phone,
            style: _style(fontSize: 10, color: PdfColors.grey600),
          ),
        ],
      ],
    );
  }

  static pw.Widget _buildDivider() {
    return pw.Container(
      height: 1,
      color: PdfColors.grey300,
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Text(
      title,
      style: _style(fontSize: 12, bold: true, color: PdfColors.grey800),
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              '$label:',
              style: _style(fontSize: 11, color: PdfColors.grey600),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: _style(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildItemsTable(List<OrderItemModel> items) {
    return pw.Table(
      border: null,
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(4),
        2: const pw.FlexColumnWidth(2),
      },
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.grey300),
            ),
          ),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Text(
                'QTY',
                style: _style(fontSize: 10, bold: true, color: PdfColors.grey600),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Text(
                'ITEM',
                style: _style(fontSize: 10, bold: true, color: PdfColors.grey600),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Text(
                'PRICE',
                style: _style(fontSize: 10, bold: true, color: PdfColors.grey600),
                textAlign: pw.TextAlign.right,
              ),
            ),
          ],
        ),
        // Item rows
        ...items.map((item) => pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 6),
              child: pw.Text(
                '${item.quantity}x',
                style: _style(fontSize: 11),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 6),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    item.name.isNotEmpty ? item.name : 'Unknown Item',
                    style: _style(fontSize: 11),
                  ),
                  if (item.customizationsText != null && item.customizationsText!.isNotEmpty)
                    pw.Text(
                      item.customizationsText!,
                      style: _style(fontSize: 9, color: PdfColors.grey600),
                    ),
                  if (item.notes != null && item.notes!.isNotEmpty)
                    pw.Text(
                      item.notes!,
                      style: _style(fontSize: 9, color: PdfColors.grey600, fontStyle: pw.FontStyle.italic),
                    ),
                ],
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 6),
              child: pw.Text(
                item.totalPrice > 0 ? '\$${item.totalPrice.toStringAsFixed(2)}' : '-',
                style: _style(fontSize: 11),
                textAlign: pw.TextAlign.right,
              ),
            ),
          ],
        )),
      ],
    );
  }

  static pw.Widget _buildPaymentSummary({
    required double subtotal,
    required double deliveryFee,
    required double discountAmount,
    required double tip,
    required double total,
    required bool isPaid,
  }) {
    return pw.Column(
      children: [
        if (subtotal > 0)
          _buildSummaryRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
        if (deliveryFee > 0)
          _buildSummaryRow('Delivery Fee', '\$${deliveryFee.toStringAsFixed(2)}'),
        if (discountAmount > 0)
          _buildSummaryRow('Discount', '-\$${discountAmount.toStringAsFixed(2)}', isDiscount: true),
        if (tip > 0)
          _buildSummaryRow('Tip', '\$${tip.toStringAsFixed(2)}'),
        pw.SizedBox(height: 8),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 8),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              top: pw.BorderSide(color: PdfColors.grey400),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'TOTAL',
                style: _style(fontSize: 14, bold: true),
              ),
              pw.Text(
                '\$${total.toStringAsFixed(2)}',
                style: _style(fontSize: 14, bold: true),
              ),
            ],
          ),
        ),
        if (isPaid) ...[
          pw.SizedBox(height: 8),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: pw.BoxDecoration(
              color: PdfColors.green100,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Row(
              mainAxisSize: pw.MainAxisSize.min,
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'PAID ONLINE',
                  style: _style(fontSize: 10, bold: true, color: PdfColors.green800),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  static pw.Widget _buildSummaryRow(String label, String value, {bool isDiscount = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: _style(fontSize: 11, color: isDiscount ? PdfColors.green700 : PdfColors.grey700),
          ),
          pw.Text(
            value,
            style: _style(fontSize: 11, color: isDiscount ? PdfColors.green700 : PdfColors.grey800),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        _buildDivider(),
        pw.SizedBox(height: 12),
        pw.Center(
          child: pw.Text(
            'Thank you for your order!',
            style: _style(fontSize: 12, bold: true),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Center(
          child: pw.Text(
            'Powered by TybeToGo',
            style: _style(fontSize: 9, color: PdfColors.grey500),
          ),
        ),
      ],
    );
  }

  static PdfColor _getStatusColor(OrderStatusEnum status) {
    switch (status) {
      case OrderStatusEnum.pending:
      case OrderStatusEnum.searchingForDriver:
        return PdfColors.orange;
      case OrderStatusEnum.driverNotificationSent:
        return PdfColors.amber800;
      case OrderStatusEnum.accepted:
        return PdfColors.blue;
      case OrderStatusEnum.onTheWay:
        return PdfColors.purple;
      case OrderStatusEnum.delivered:
      case OrderStatusEnum.completed:
        return PdfColors.green;
      case OrderStatusEnum.rejected:
      case OrderStatusEnum.cancelled:
        return PdfColors.red;
    }
  }

  static String _formatDateTime(DateTime dateTime) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final hourStr = hour == 0 ? '12' : hour.toString();
    final minuteStr = dateTime.minute.toString().padLeft(2, '0');
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year} at $hourStr:$minuteStr $period';
  }

  /// Save PDF to device and return file path (mobile only)
  static Future<String?> savePdf(Uint8List pdfData, String orderId) async {
    if (kIsWeb) {
      // On web, use sharePdf which triggers a download
      await Printing.sharePdf(bytes: pdfData, filename: 'receipt_order_$orderId.pdf');
      return null;
    }
    return platform.savePdfToDevice(pdfData, orderId);
  }

  /// Show print dialog
  static Future<void> printReceipt(BuildContext context, Uint8List pdfData, String orderId) async {
    if (kIsWeb) {
      // On web, share/download the PDF instead of printing
      await Printing.sharePdf(bytes: pdfData, filename: 'receipt_order_$orderId.pdf');
      return;
    }

    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfData,
        name: 'Receipt - Order #$orderId',
      );
    } catch (e) {
      // Fallback to share if print fails
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Printing not available. Downloading instead...'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      await Printing.sharePdf(bytes: pdfData, filename: 'receipt_order_$orderId.pdf');
    }
  }

  /// Share PDF via system share sheet
  static Future<void> shareReceipt(Uint8List pdfData, String orderId) async {
    if (kIsWeb) {
      // On web, download the PDF
      await Printing.sharePdf(bytes: pdfData, filename: 'receipt_order_$orderId.pdf');
      return;
    }
    await platform.shareReceiptFile(pdfData, orderId);
  }

  /// Show options dialog and handle the selected action
  static Future<void> showReceiptOptions(
    BuildContext context,
    OrderModel order, {
    String? restaurantName,
    String? restaurantAddress,
    String? restaurantPhone,
  }) async {
    final pdfData = await generateReceipt(
      order,
      restaurantName: restaurantName,
      restaurantAddress: restaurantAddress,
      restaurantPhone: restaurantPhone,
    );

    if (!context.mounted) return;

    // On web, directly download the PDF
    if (kIsWeb) {
      await Printing.sharePdf(bytes: pdfData, filename: 'receipt_order_${order.id}.pdf');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Receipt downloaded'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    // On mobile, show bottom sheet with options
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Receipt - Order #${order.id}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.print_outlined),
                title: const Text('Print Receipt'),
                onTap: () {
                  Navigator.pop(ctx);
                  printReceipt(context, pdfData, order.id);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_outlined),
                title: const Text('Share Receipt'),
                onTap: () {
                  Navigator.pop(ctx);
                  shareReceipt(pdfData, order.id);
                },
              ),
              ListTile(
                leading: const Icon(Icons.download_outlined),
                title: const Text('Save to Device'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final path = await savePdf(pdfData, order.id);
                  if (context.mounted && path != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Receipt saved to: $path'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
