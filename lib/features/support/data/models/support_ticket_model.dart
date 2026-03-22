/// Support ticket models for the ticketing/chat system
library;

/// Ticket category enum
enum TicketCategory {
  order,
  payment,
  delivery,
  account,
  other;

  String get apiValue {
    switch (this) {
      case TicketCategory.order:
        return 'ORDER';
      case TicketCategory.payment:
        return 'PAYMENT';
      case TicketCategory.delivery:
        return 'DELIVERY';
      case TicketCategory.account:
        return 'ACCOUNT';
      case TicketCategory.other:
        return 'OTHER';
    }
  }

  static TicketCategory fromApi(String value) {
    switch (value.toUpperCase()) {
      case 'ORDER':
        return TicketCategory.order;
      case 'PAYMENT':
        return TicketCategory.payment;
      case 'DELIVERY':
        return TicketCategory.delivery;
      case 'ACCOUNT':
        return TicketCategory.account;
      default:
        return TicketCategory.other;
    }
  }
}

/// Ticket priority enum
enum TicketPriority {
  low,
  medium,
  high,
  urgent;

  String get apiValue {
    switch (this) {
      case TicketPriority.low:
        return 'LOW';
      case TicketPriority.medium:
        return 'MEDIUM';
      case TicketPriority.high:
        return 'HIGH';
      case TicketPriority.urgent:
        return 'URGENT';
    }
  }

  static TicketPriority fromApi(String value) {
    switch (value.toUpperCase()) {
      case 'MEDIUM':
        return TicketPriority.medium;
      case 'HIGH':
        return TicketPriority.high;
      case 'URGENT':
        return TicketPriority.urgent;
      default:
        return TicketPriority.low;
    }
  }
}

/// Ticket status enum
enum TicketStatus {
  open,
  inProgress,
  waitingOnCustomer,
  resolved,
  closed;

  String get apiValue {
    switch (this) {
      case TicketStatus.open:
        return 'OPEN';
      case TicketStatus.inProgress:
        return 'IN_PROGRESS';
      case TicketStatus.waitingOnCustomer:
        return 'WAITING_ON_CUSTOMER';
      case TicketStatus.resolved:
        return 'RESOLVED';
      case TicketStatus.closed:
        return 'CLOSED';
    }
  }

  static TicketStatus fromApi(String value) {
    switch (value.toUpperCase()) {
      case 'IN_PROGRESS':
        return TicketStatus.inProgress;
      case 'WAITING_ON_CUSTOMER':
        return TicketStatus.waitingOnCustomer;
      case 'RESOLVED':
        return TicketStatus.resolved;
      case 'CLOSED':
        return TicketStatus.closed;
      default:
        return TicketStatus.open;
    }
  }
}

/// Author role enum
enum AuthorRole {
  customer,
  seller,
  driver,
  staff;

  static AuthorRole fromApi(String value) {
    switch (value.toUpperCase()) {
      case 'SELLER':
        return AuthorRole.seller;
      case 'DRIVER':
        return AuthorRole.driver;
      case 'STAFF':
      case 'ADMIN':
      case 'SUPPORT':
        return AuthorRole.staff;
      default:
        return AuthorRole.customer;
    }
  }
}

/// Message attachment model
class TicketAttachment {
  final int id;
  final String fileUrl;
  final String mimeType;
  final DateTime createdAt;

  TicketAttachment({
    required this.id,
    required this.fileUrl,
    required this.mimeType,
    required this.createdAt,
  });

  factory TicketAttachment.fromJson(Map<String, dynamic> json) {
    return TicketAttachment(
      id: json['id'] as int,
      fileUrl: json['file_url'] as String? ?? '',
      mimeType: json['mime_type'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {'file_url': fileUrl, 'mime_type': mimeType};

  bool get isImage {
    final lowerMimeType = mimeType.toLowerCase();
    if (lowerMimeType.startsWith('image/')) return true;

    final lowerUrl = fileUrl.toLowerCase();
    return lowerUrl.endsWith('.jpg') ||
        lowerUrl.endsWith('.jpeg') ||
        lowerUrl.endsWith('.png') ||
        lowerUrl.endsWith('.webp') ||
        lowerUrl.endsWith('.gif');
  }

  String get displayName {
    if (fileUrl.isEmpty) return 'Attachment';

    final uri = Uri.tryParse(fileUrl);
    if (uri != null && uri.pathSegments.isNotEmpty) {
      final fileName = uri.pathSegments.last;
      if (fileName.isNotEmpty) return fileName;
    }

    if (mimeType.isNotEmpty) return mimeType;
    return 'Attachment';
  }
}

/// Ticket message model
class TicketMessage {
  final int id;
  final int? author;
  final String authorName;
  final AuthorRole authorRole;
  final String body;
  final DateTime createdAt;
  final List<TicketAttachment> attachments;

  TicketMessage({
    required this.id,
    required this.author,
    required this.authorName,
    required this.authorRole,
    required this.body,
    required this.createdAt,
    this.attachments = const [],
  });

  factory TicketMessage.fromJson(Map<String, dynamic> json) {
    return TicketMessage(
      id: json['id'] as int,
      author: json['author'] as int?,
      authorName: json['author_name'] as String? ?? '',
      authorRole: AuthorRole.fromApi(
        json['author_role'] as String? ?? 'CUSTOMER',
      ),
      body: json['body'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      attachments:
          (json['attachments'] as List<dynamic>?)
              ?.map((e) => TicketAttachment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Support ticket model
class SupportTicket {
  final int id;
  final String subject;
  final TicketCategory category;
  final TicketPriority priority;
  final TicketStatus status;
  final int requester;
  final String requesterName;
  final int? order;
  final int? restaurant;
  final int? driver;
  final int? assignedTo;
  final String? assignedToName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastActivityAt;
  final DateTime? closedAt;
  final List<TicketMessage> messages;

  SupportTicket({
    required this.id,
    required this.subject,
    required this.category,
    required this.priority,
    required this.status,
    required this.requester,
    required this.requesterName,
    this.order,
    this.restaurant,
    this.driver,
    this.assignedTo,
    this.assignedToName,
    required this.createdAt,
    required this.updatedAt,
    required this.lastActivityAt,
    this.closedAt,
    this.messages = const [],
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'] as int,
      subject: json['subject'] as String? ?? '',
      category: TicketCategory.fromApi(json['category'] as String? ?? 'OTHER'),
      priority: TicketPriority.fromApi(json['priority'] as String? ?? 'LOW'),
      status: TicketStatus.fromApi(json['status'] as String? ?? 'OPEN'),
      requester: json['requester'] as int? ?? 0,
      requesterName: json['requester_name'] as String? ?? '',
      order: json['order'] as int?,
      restaurant: json['restaurant'] as int?,
      driver: json['driver'] as int?,
      assignedTo: json['assigned_to'] as int?,
      assignedToName: json['assigned_to_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastActivityAt: DateTime.parse(json['last_activity_at'] as String),
      closedAt: json['closed_at'] != null
          ? DateTime.parse(json['closed_at'] as String)
          : null,
      messages:
          (json['messages'] as List<dynamic>?)
              ?.map((e) => TicketMessage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
