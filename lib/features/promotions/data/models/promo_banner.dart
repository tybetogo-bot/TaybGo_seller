/// Review status and publication are deliberately separate backend fields.
enum PromoStatus { pending, approved, rejected }

enum PromoDisplayStatus { live, paused, pending, rejected }

class PromoBanner {
  const PromoBanner({
    required this.id,
    required this.restaurantId,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.status,
    required this.isActive,
    this.rejectionReason,
  });

  final String id;
  final String restaurantId;
  final String title;
  final String description;
  final String imageUrl;
  final PromoStatus status;
  final bool isActive;
  final String? rejectionReason;

  bool get canPublish => status == PromoStatus.approved;
  bool get needsReviewOnEdit => status != PromoStatus.pending;
  PromoDisplayStatus get displayStatus => switch (status) {
    PromoStatus.pending => PromoDisplayStatus.pending,
    PromoStatus.rejected => PromoDisplayStatus.rejected,
    PromoStatus.approved =>
      isActive ? PromoDisplayStatus.live : PromoDisplayStatus.paused,
  };

  factory PromoBanner.fromJson(Map<String, dynamic> json) => PromoBanner(
    id: json['id'].toString(),
    restaurantId: json['restaurant'].toString(),
    title: json['title'] as String,
    description: json['description'] as String? ?? '',
    imageUrl: json['image_url'] as String,
    status: switch (json['status']) {
      'APPROVED' => PromoStatus.approved,
      'REJECTED' => PromoStatus.rejected,
      _ => PromoStatus.pending,
    },
    isActive: json['is_active'] == true,
    rejectionReason: json['rejection_reason'] as String?,
  );
}
