import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation.freezed.dart';
part 'conversation.g.dart';

// Inquiry for pre-booking messages
@freezed
class Inquiry with _$Inquiry {
  const factory Inquiry({
    required String id,
    required String userId,
    required String chefId,
    String? chefName,
    String? chefImage,
    String? userName,
    String? userImage,
    String? lastMessage,
    DateTime? lastMessageAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(0) int unreadCount,
  }) = _Inquiry;

  factory Inquiry.fromJson(Map<String, dynamic> json) =>
      _$InquiryFromJson(json);
}

@freezed
class InquiryMessage with _$InquiryMessage {
  const factory InquiryMessage({
    required String id,
    @JsonKey(name: 'inquiry_id') required String inquiryId,
    required String senderId,
    required String content,
    @Default(false) bool isRead,
    @Default(false) bool isFlagged,
    String? flaggedReason,
    required DateTime createdAt,
  }) = _InquiryMessage;

  factory InquiryMessage.fromJson(Map<String, dynamic> json) =>
      _$InquiryMessageFromJson(json);
}

// Booking chat for post-booking messages
@freezed
class BookingChat with _$BookingChat {
  const factory BookingChat({
    required String id,
    required String bookingId,
    required String senderId,
    required String receiverId,
    String? chefName,
    String? chefImage,
    String? userName,
    String? userImage,
    required String content,
    required DateTime createdAt,
    @Default(false) bool isRead,
    @Default(false) bool isArchived,
    @Default(0) int unreadCount,
  }) = _BookingChat;

  factory BookingChat.fromJson(Map<String, dynamic> json) =>
      _$BookingChatFromJson(json);
}

// Unified conversation model for the messages list
@freezed
class UnifiedConversation with _$UnifiedConversation {
  const factory UnifiedConversation({
    required String id,
    required ConversationType type,
    String? bookingId,
    String? otherPersonName,
    String? otherPersonImage,
    String? lastMessage,
    DateTime? lastMessageAt,
    @Default(0) int unreadCount,
    String? bookingStatus,
    DateTime? bookingDate,
  }) = _UnifiedConversation;

  factory UnifiedConversation.fromJson(Map<String, dynamic> json) =>
      _$UnifiedConversationFromJson(json);
}

enum ConversationType {
  inquiry,
  booking
}