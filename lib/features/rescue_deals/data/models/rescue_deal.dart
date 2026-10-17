String rescueDigits(String value) {
  const arabic = '٠١٢٣٤٥٦٧٨٩';
  const persian = '۰۱۲۳۴۵۶۷۸۹';
  var normalized = value;
  for (var i = 0; i < 10; i++) {
    normalized = normalized
        .replaceAll(arabic[i], '$i')
        .replaceAll(persian[i], '$i');
  }
  return normalized;
}

/// Money is kept in cents so seller input is never rounded through a float.
int? rescueMoneyCents(String value) {
  var normalized = rescueDigits(value.trim());
  normalized = normalized.replaceAll('٫', '.').replaceAll(',', '.');
  if (!RegExp(r'^\d{1,8}(\.\d{0,2})?$').hasMatch(normalized)) return null;
  final parts = normalized.split('.');
  return int.parse(parts[0]) * 100 +
      int.parse((parts.length == 1 ? '' : parts[1]).padRight(2, '0'));
}

String rescueDecimal(int cents) =>
    '${cents ~/ 100}.${(cents % 100).toString().padLeft(2, '0')}';
String rescuePrice(int cents) => '€${rescueDecimal(cents)}';

enum RescueStatus {
  live,
  scheduled,
  paused,
  soldOut,
  ended,
  unavailable,
  archived,
}

class RescueDeal {
  const RescueDeal({
    required this.id,
    required this.restaurantId,
    required this.itemId,
    required this.itemName,
    required this.originalCents,
    required this.dealCents,
    required this.startsAt,
    required this.endsAt,
    required this.maxQty,
    required this.remainingQty,
    required this.isActive,
    this.imageUrl,
    this.maxPerCustomer,
    this.reservedQty,
    this.soldQty,
    this.archivedAt,
    this.serverStatus,
    this.supportsSafeManagement = false,
  });
  final String id, restaurantId, itemId, itemName;
  final String? imageUrl;
  final int originalCents, dealCents, maxQty, remainingQty;
  final int? maxPerCustomer, reservedQty, soldQty;
  final DateTime startsAt, endsAt;
  final DateTime? archivedAt;
  final bool isActive;
  final bool supportsSafeManagement;
  final RescueStatus? serverStatus;
  bool get archived =>
      archivedAt != null || serverStatus == RescueStatus.archived;
  bool get priceLocked => (reservedQty ?? 0) + (soldQty ?? 0) > 0;
  int get discountPercent => originalCents <= 0
      ? 0
      : ((originalCents - dealCents) * 100 / originalCents).round();
  RescueStatus statusAt(DateTime now) {
    if (archived) return RescueStatus.archived;
    if (now.isAfter(endsAt)) return RescueStatus.ended;
    if (!isActive) return RescueStatus.paused;
    if (remainingQty <= 0) return RescueStatus.soldOut;
    if (now.isBefore(startsAt)) return RescueStatus.scheduled;
    if (serverStatus == RescueStatus.unavailable) {
      return RescueStatus.unavailable;
    }
    return RescueStatus.live;
  }

  factory RescueDeal.fromJson(Map<String, dynamic> json) => RescueDeal(
    id: json['id'].toString(),
    restaurantId: json['restaurant'].toString(),
    itemId: json['item'].toString(),
    itemName: json['item_name'] as String? ?? '',
    imageUrl: json['item_image'] as String?,
    originalCents:
        rescueMoneyCents(json['original_price_snapshot'].toString()) ?? 0,
    dealCents: rescueMoneyCents(json['deal_price'].toString()) ?? 0,
    startsAt: DateTime.parse(json['starts_at'] as String),
    endsAt: DateTime.parse(json['ends_at'] as String),
    maxQty: (json['max_qty'] as num).toInt(),
    remainingQty: (json['remaining_qty'] as num).toInt(),
    isActive: json['is_active'] == true,
    maxPerCustomer: (json['max_per_customer'] as num?)?.toInt(),
    reservedQty: (json['reserved_qty'] as num?)?.toInt(),
    soldQty: (json['sold_qty'] as num?)?.toInt(),
    archivedAt: DateTime.tryParse(json['archived_at']?.toString() ?? ''),
    supportsSafeManagement: json.containsKey('archived_at'),
    serverStatus: switch (json['status']) {
      'LIVE' => RescueStatus.live,
      'SCHEDULED' => RescueStatus.scheduled,
      'PAUSED' => RescueStatus.paused,
      'SOLD_OUT' => RescueStatus.soldOut,
      'ENDED' => RescueStatus.ended,
      'UNAVAILABLE' => RescueStatus.unavailable,
      'ARCHIVED' => RescueStatus.archived,
      _ => null,
    },
  );
}
