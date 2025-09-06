// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InquiryImpl _$$InquiryImplFromJson(Map<String, dynamic> json) =>
    _$InquiryImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      chefId: json['chefId'] as String,
      chefName: json['chefName'] as String?,
      chefImage: json['chefImage'] as String?,
      userName: json['userName'] as String?,
      userImage: json['userImage'] as String?,
      lastMessage: json['lastMessage'] as String?,
      lastMessageAt: json['lastMessageAt'] == null
          ? null
          : DateTime.parse(json['lastMessageAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$InquiryImplToJson(_$InquiryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'chefId': instance.chefId,
      'chefName': instance.chefName,
      'chefImage': instance.chefImage,
      'userName': instance.userName,
      'userImage': instance.userImage,
      'lastMessage': instance.lastMessage,
      'lastMessageAt': instance.lastMessageAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'unreadCount': instance.unreadCount,
    };

_$InquiryMessageImpl _$$InquiryMessageImplFromJson(Map<String, dynamic> json) =>
    _$InquiryMessageImpl(
      id: json['id'] as String,
      inquiryId: json['inquiry_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      isRead: json['is_read'] as bool? ?? false,
      isFlagged: json['is_flagged'] as bool? ?? false,
      flaggedReason: json['flagged_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$InquiryMessageImplToJson(
        _$InquiryMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'inquiry_id': instance.inquiryId,
      'sender_id': instance.senderId,
      'content': instance.content,
      'is_read': instance.isRead,
      'is_flagged': instance.isFlagged,
      'flagged_reason': instance.flaggedReason,
      'created_at': instance.createdAt.toIso8601String(),
    };

_$BookingChatImpl _$$BookingChatImplFromJson(Map<String, dynamic> json) =>
    _$BookingChatImpl(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      chefName: json['chefName'] as String?,
      chefImage: json['chefImage'] as String?,
      userName: json['userName'] as String?,
      userImage: json['userImage'] as String?,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      isArchived: json['isArchived'] as bool? ?? false,
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$BookingChatImplToJson(_$BookingChatImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bookingId': instance.bookingId,
      'senderId': instance.senderId,
      'receiverId': instance.receiverId,
      'chefName': instance.chefName,
      'chefImage': instance.chefImage,
      'userName': instance.userName,
      'userImage': instance.userImage,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
      'isRead': instance.isRead,
      'isArchived': instance.isArchived,
      'unreadCount': instance.unreadCount,
    };

_$UnifiedConversationImpl _$$UnifiedConversationImplFromJson(
        Map<String, dynamic> json) =>
    _$UnifiedConversationImpl(
      id: json['id'] as String,
      type: $enumDecode(_$ConversationTypeEnumMap, json['type']),
      bookingId: json['bookingId'] as String?,
      otherPersonName: json['otherPersonName'] as String?,
      otherPersonImage: json['otherPersonImage'] as String?,
      lastMessage: json['lastMessage'] as String?,
      lastMessageAt: json['lastMessageAt'] == null
          ? null
          : DateTime.parse(json['lastMessageAt'] as String),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      bookingStatus: json['bookingStatus'] as String?,
      bookingDate: json['bookingDate'] == null
          ? null
          : DateTime.parse(json['bookingDate'] as String),
    );

Map<String, dynamic> _$$UnifiedConversationImplToJson(
        _$UnifiedConversationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$ConversationTypeEnumMap[instance.type]!,
      'bookingId': instance.bookingId,
      'otherPersonName': instance.otherPersonName,
      'otherPersonImage': instance.otherPersonImage,
      'lastMessage': instance.lastMessage,
      'lastMessageAt': instance.lastMessageAt?.toIso8601String(),
      'unreadCount': instance.unreadCount,
      'bookingStatus': instance.bookingStatus,
      'bookingDate': instance.bookingDate?.toIso8601String(),
    };

const _$ConversationTypeEnumMap = {
  ConversationType.inquiry: 'inquiry',
  ConversationType.booking: 'booking',
};
