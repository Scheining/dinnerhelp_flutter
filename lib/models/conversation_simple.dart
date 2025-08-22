// Simple conversation models without code generation

enum ConversationType { inquiry, booking }

class InquiryMessage {
  final String id;
  final String inquiryId;
  final String senderId;
  final String content;
  final bool isRead;
  final bool isFlagged;
  final String? flaggedReason;
  final DateTime createdAt;

  InquiryMessage({
    required this.id,
    required this.inquiryId,
    required this.senderId,
    required this.content,
    this.isRead = false,
    this.isFlagged = false,
    this.flaggedReason,
    required this.createdAt,
  });

  factory InquiryMessage.fromJson(Map<String, dynamic> json) {
    return InquiryMessage(
      id: json['id'] as String,
      inquiryId: json['inquiry_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      isRead: json['is_read'] as bool? ?? false,
      isFlagged: json['is_flagged'] as bool? ?? false,
      flaggedReason: json['flagged_reason'] as String?,
      createdAt: json['created_at'] is String 
          ? DateTime.parse(json['created_at'] as String)
          : json['created_at'] as DateTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inquiry_id': inquiryId,
      'sender_id': senderId,
      'content': content,
      'is_read': isRead,
      'is_flagged': isFlagged,
      'flagged_reason': flaggedReason,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Inquiry {
  final String id;
  final String userId;
  final String chefId;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Inquiry({
    required this.id,
    required this.userId,
    required this.chefId,
    this.lastMessage,
    this.lastMessageAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Inquiry.fromJson(Map<String, dynamic> json) {
    return Inquiry(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      chefId: json['chef_id'] as String,
      lastMessage: json['last_message'] as String?,
      lastMessageAt: json['last_message_at'] != null
          ? (json['last_message_at'] is String 
              ? DateTime.parse(json['last_message_at'] as String)
              : json['last_message_at'] as DateTime)
          : null,
      createdAt: json['created_at'] is String 
          ? DateTime.parse(json['created_at'] as String)
          : json['created_at'] as DateTime,
      updatedAt: json['updated_at'] is String 
          ? DateTime.parse(json['updated_at'] as String)
          : json['updated_at'] as DateTime,
    );
  }
}

class UnifiedConversation {
  final String id;
  final ConversationType type;
  final String? bookingId;
  final String? inquiryId;
  final String? chefId;
  final String? userId;
  final String? otherPersonName;
  final String? otherPersonImage;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final String? bookingStatus;
  final DateTime? bookingDate;
  final int unreadCount;

  UnifiedConversation({
    required this.id,
    required this.type,
    this.bookingId,
    this.inquiryId,
    this.chefId,
    this.userId,
    this.otherPersonName,
    this.otherPersonImage,
    this.lastMessage,
    this.lastMessageAt,
    this.bookingStatus,
    this.bookingDate,
    this.unreadCount = 0,
  });
}