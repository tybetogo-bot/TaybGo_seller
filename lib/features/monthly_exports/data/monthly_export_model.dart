double _parseDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

/// Monthly PDF export statement for a single seller store (`GET /api/seller/exports/monthly/`).
class SellerMonthlyExport {
  final int id;
  final int restaurantId;
  final String restaurantName;
  final String storeType;
  final int year;
  final int month;
  final String periodLabel;
  final String status;
  final String fileFormat;
  final int rowCount;
  final String? downloadUrl;
  final DateTime? generatedAt;
  final String? errorMessage;
  final int deliveryCount;
  final int pickupCount;
  final double grossTotalEur;

  const SellerMonthlyExport({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.storeType,
    required this.year,
    required this.month,
    required this.periodLabel,
    required this.status,
    required this.fileFormat,
    required this.rowCount,
    this.downloadUrl,
    this.generatedAt,
    this.errorMessage,
    this.deliveryCount = 0,
    this.pickupCount = 0,
    this.grossTotalEur = 0.0,
  });

  bool get isReady => status.toUpperCase() == 'READY';
  bool get hasDownload => downloadUrl != null && downloadUrl!.trim().isNotEmpty;
  bool get isGeneralMarket => storeType.toUpperCase() == 'GENERAL_MARKET';

  factory SellerMonthlyExport.fromJson(Map<String, dynamic> json) {
    final year = _parseInt(json['year']);
    final month = _parseInt(json['month']);
    final fallbackPeriod = (year > 0 && month > 0)
        ? '${month.toString().padLeft(2, '0')}.$year'
        : '';
    final summary = json['summary_json'] is Map
        ? Map<String, dynamic>.from(json['summary_json'] as Map)
        : (json['summary'] is Map
              ? Map<String, dynamic>.from(json['summary'] as Map)
              : const <String, dynamic>{});

    return SellerMonthlyExport(
      id: _parseInt(json['id']),
      restaurantId: _parseInt(json['restaurant'] ?? json['restaurant_id']),
      restaurantName: (json['restaurant_name'] ?? '').toString(),
      storeType: (json['store_type'] ?? 'RESTAURANT').toString().toUpperCase(),
      year: year,
      month: month,
      periodLabel: (json['period_label'] ?? fallbackPeriod).toString(),
      status: (json['status'] ?? 'PENDING').toString().toUpperCase(),
      fileFormat: (json['file_format'] ?? 'PDF').toString().toUpperCase(),
      rowCount: _parseInt(json['row_count']),
      downloadUrl: json['download_url']?.toString(),
      generatedAt: json['generated_at'] is String
          ? DateTime.tryParse(json['generated_at'] as String)
          : null,
      errorMessage: json['error_message']?.toString(),
      deliveryCount: _parseInt(summary['delivery_count']),
      pickupCount: _parseInt(summary['pickup_count']),
      grossTotalEur: _parseDouble(
        summary['gross_total_eur'] ?? summary['gross_total'],
      ),
    );
  }
}
