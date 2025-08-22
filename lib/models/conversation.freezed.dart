// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Inquiry _$InquiryFromJson(Map<String, dynamic> json) {
  return _Inquiry.fromJson(json);
}

/// @nodoc
mixin _$Inquiry {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get chefId => throw _privateConstructorUsedError;
  String? get chefName => throw _privateConstructorUsedError;
  String? get chefImage => throw _privateConstructorUsedError;
  String? get userName => throw _privateConstructorUsedError;
  String? get userImage => throw _privateConstructorUsedError;
  String? get lastMessage => throw _privateConstructorUsedError;
  DateTime? get lastMessageAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  int get unreadCount => throw _privateConstructorUsedError;

  /// Serializes this Inquiry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Inquiry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InquiryCopyWith<Inquiry> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InquiryCopyWith<$Res> {
  factory $InquiryCopyWith(Inquiry value, $Res Function(Inquiry) then) =
      _$InquiryCopyWithImpl<$Res, Inquiry>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String chefId,
      String? chefName,
      String? chefImage,
      String? userName,
      String? userImage,
      String? lastMessage,
      DateTime? lastMessageAt,
      DateTime createdAt,
      DateTime updatedAt,
      int unreadCount});
}

/// @nodoc
class _$InquiryCopyWithImpl<$Res, $Val extends Inquiry>
    implements $InquiryCopyWith<$Res> {
  _$InquiryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Inquiry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? chefId = null,
    Object? chefName = freezed,
    Object? chefImage = freezed,
    Object? userName = freezed,
    Object? userImage = freezed,
    Object? lastMessage = freezed,
    Object? lastMessageAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? unreadCount = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      chefId: null == chefId
          ? _value.chefId
          : chefId // ignore: cast_nullable_to_non_nullable
              as String,
      chefName: freezed == chefName
          ? _value.chefName
          : chefName // ignore: cast_nullable_to_non_nullable
              as String?,
      chefImage: freezed == chefImage
          ? _value.chefImage
          : chefImage // ignore: cast_nullable_to_non_nullable
              as String?,
      userName: freezed == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String?,
      userImage: freezed == userImage
          ? _value.userImage
          : userImage // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessage: freezed == lastMessage
          ? _value.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessageAt: freezed == lastMessageAt
          ? _value.lastMessageAt
          : lastMessageAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      unreadCount: null == unreadCount
          ? _value.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InquiryImplCopyWith<$Res> implements $InquiryCopyWith<$Res> {
  factory _$$InquiryImplCopyWith(
          _$InquiryImpl value, $Res Function(_$InquiryImpl) then) =
      __$$InquiryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String chefId,
      String? chefName,
      String? chefImage,
      String? userName,
      String? userImage,
      String? lastMessage,
      DateTime? lastMessageAt,
      DateTime createdAt,
      DateTime updatedAt,
      int unreadCount});
}

/// @nodoc
class __$$InquiryImplCopyWithImpl<$Res>
    extends _$InquiryCopyWithImpl<$Res, _$InquiryImpl>
    implements _$$InquiryImplCopyWith<$Res> {
  __$$InquiryImplCopyWithImpl(
      _$InquiryImpl _value, $Res Function(_$InquiryImpl) _then)
      : super(_value, _then);

  /// Create a copy of Inquiry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? chefId = null,
    Object? chefName = freezed,
    Object? chefImage = freezed,
    Object? userName = freezed,
    Object? userImage = freezed,
    Object? lastMessage = freezed,
    Object? lastMessageAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? unreadCount = null,
  }) {
    return _then(_$InquiryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      chefId: null == chefId
          ? _value.chefId
          : chefId // ignore: cast_nullable_to_non_nullable
              as String,
      chefName: freezed == chefName
          ? _value.chefName
          : chefName // ignore: cast_nullable_to_non_nullable
              as String?,
      chefImage: freezed == chefImage
          ? _value.chefImage
          : chefImage // ignore: cast_nullable_to_non_nullable
              as String?,
      userName: freezed == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String?,
      userImage: freezed == userImage
          ? _value.userImage
          : userImage // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessage: freezed == lastMessage
          ? _value.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessageAt: freezed == lastMessageAt
          ? _value.lastMessageAt
          : lastMessageAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      unreadCount: null == unreadCount
          ? _value.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InquiryImpl implements _Inquiry {
  const _$InquiryImpl(
      {required this.id,
      required this.userId,
      required this.chefId,
      this.chefName,
      this.chefImage,
      this.userName,
      this.userImage,
      this.lastMessage,
      this.lastMessageAt,
      required this.createdAt,
      required this.updatedAt,
      this.unreadCount = 0});

  factory _$InquiryImpl.fromJson(Map<String, dynamic> json) =>
      _$$InquiryImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String chefId;
  @override
  final String? chefName;
  @override
  final String? chefImage;
  @override
  final String? userName;
  @override
  final String? userImage;
  @override
  final String? lastMessage;
  @override
  final DateTime? lastMessageAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  @JsonKey()
  final int unreadCount;

  @override
  String toString() {
    return 'Inquiry(id: $id, userId: $userId, chefId: $chefId, chefName: $chefName, chefImage: $chefImage, userName: $userName, userImage: $userImage, lastMessage: $lastMessage, lastMessageAt: $lastMessageAt, createdAt: $createdAt, updatedAt: $updatedAt, unreadCount: $unreadCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InquiryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.chefId, chefId) || other.chefId == chefId) &&
            (identical(other.chefName, chefName) ||
                other.chefName == chefName) &&
            (identical(other.chefImage, chefImage) ||
                other.chefImage == chefImage) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.userImage, userImage) ||
                other.userImage == userImage) &&
            (identical(other.lastMessage, lastMessage) ||
                other.lastMessage == lastMessage) &&
            (identical(other.lastMessageAt, lastMessageAt) ||
                other.lastMessageAt == lastMessageAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      chefId,
      chefName,
      chefImage,
      userName,
      userImage,
      lastMessage,
      lastMessageAt,
      createdAt,
      updatedAt,
      unreadCount);

  /// Create a copy of Inquiry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InquiryImplCopyWith<_$InquiryImpl> get copyWith =>
      __$$InquiryImplCopyWithImpl<_$InquiryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InquiryImplToJson(
      this,
    );
  }
}

abstract class _Inquiry implements Inquiry {
  const factory _Inquiry(
      {required final String id,
      required final String userId,
      required final String chefId,
      final String? chefName,
      final String? chefImage,
      final String? userName,
      final String? userImage,
      final String? lastMessage,
      final DateTime? lastMessageAt,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final int unreadCount}) = _$InquiryImpl;

  factory _Inquiry.fromJson(Map<String, dynamic> json) = _$InquiryImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get chefId;
  @override
  String? get chefName;
  @override
  String? get chefImage;
  @override
  String? get userName;
  @override
  String? get userImage;
  @override
  String? get lastMessage;
  @override
  DateTime? get lastMessageAt;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  int get unreadCount;

  /// Create a copy of Inquiry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InquiryImplCopyWith<_$InquiryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

InquiryMessage _$InquiryMessageFromJson(Map<String, dynamic> json) {
  return _InquiryMessage.fromJson(json);
}

/// @nodoc
mixin _$InquiryMessage {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'inquiry_id')
  String get inquiryId => throw _privateConstructorUsedError;
  String get senderId => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  bool get isRead => throw _privateConstructorUsedError;
  bool get isFlagged => throw _privateConstructorUsedError;
  String? get flaggedReason => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this InquiryMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InquiryMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InquiryMessageCopyWith<InquiryMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InquiryMessageCopyWith<$Res> {
  factory $InquiryMessageCopyWith(
          InquiryMessage value, $Res Function(InquiryMessage) then) =
      _$InquiryMessageCopyWithImpl<$Res, InquiryMessage>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'inquiry_id') String inquiryId,
      String senderId,
      String content,
      bool isRead,
      bool isFlagged,
      String? flaggedReason,
      DateTime createdAt});
}

/// @nodoc
class _$InquiryMessageCopyWithImpl<$Res, $Val extends InquiryMessage>
    implements $InquiryMessageCopyWith<$Res> {
  _$InquiryMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InquiryMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? inquiryId = null,
    Object? senderId = null,
    Object? content = null,
    Object? isRead = null,
    Object? isFlagged = null,
    Object? flaggedReason = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      inquiryId: null == inquiryId
          ? _value.inquiryId
          : inquiryId // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      isFlagged: null == isFlagged
          ? _value.isFlagged
          : isFlagged // ignore: cast_nullable_to_non_nullable
              as bool,
      flaggedReason: freezed == flaggedReason
          ? _value.flaggedReason
          : flaggedReason // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InquiryMessageImplCopyWith<$Res>
    implements $InquiryMessageCopyWith<$Res> {
  factory _$$InquiryMessageImplCopyWith(_$InquiryMessageImpl value,
          $Res Function(_$InquiryMessageImpl) then) =
      __$$InquiryMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'inquiry_id') String inquiryId,
      String senderId,
      String content,
      bool isRead,
      bool isFlagged,
      String? flaggedReason,
      DateTime createdAt});
}

/// @nodoc
class __$$InquiryMessageImplCopyWithImpl<$Res>
    extends _$InquiryMessageCopyWithImpl<$Res, _$InquiryMessageImpl>
    implements _$$InquiryMessageImplCopyWith<$Res> {
  __$$InquiryMessageImplCopyWithImpl(
      _$InquiryMessageImpl _value, $Res Function(_$InquiryMessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of InquiryMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? inquiryId = null,
    Object? senderId = null,
    Object? content = null,
    Object? isRead = null,
    Object? isFlagged = null,
    Object? flaggedReason = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$InquiryMessageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      inquiryId: null == inquiryId
          ? _value.inquiryId
          : inquiryId // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      isFlagged: null == isFlagged
          ? _value.isFlagged
          : isFlagged // ignore: cast_nullable_to_non_nullable
              as bool,
      flaggedReason: freezed == flaggedReason
          ? _value.flaggedReason
          : flaggedReason // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InquiryMessageImpl implements _InquiryMessage {
  const _$InquiryMessageImpl(
      {required this.id,
      @JsonKey(name: 'inquiry_id') required this.inquiryId,
      required this.senderId,
      required this.content,
      this.isRead = false,
      this.isFlagged = false,
      this.flaggedReason,
      required this.createdAt});

  factory _$InquiryMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$InquiryMessageImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'inquiry_id')
  final String inquiryId;
  @override
  final String senderId;
  @override
  final String content;
  @override
  @JsonKey()
  final bool isRead;
  @override
  @JsonKey()
  final bool isFlagged;
  @override
  final String? flaggedReason;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'InquiryMessage(id: $id, inquiryId: $inquiryId, senderId: $senderId, content: $content, isRead: $isRead, isFlagged: $isFlagged, flaggedReason: $flaggedReason, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InquiryMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.inquiryId, inquiryId) ||
                other.inquiryId == inquiryId) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.isFlagged, isFlagged) ||
                other.isFlagged == isFlagged) &&
            (identical(other.flaggedReason, flaggedReason) ||
                other.flaggedReason == flaggedReason) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, inquiryId, senderId, content,
      isRead, isFlagged, flaggedReason, createdAt);

  /// Create a copy of InquiryMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InquiryMessageImplCopyWith<_$InquiryMessageImpl> get copyWith =>
      __$$InquiryMessageImplCopyWithImpl<_$InquiryMessageImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InquiryMessageImplToJson(
      this,
    );
  }
}

abstract class _InquiryMessage implements InquiryMessage {
  const factory _InquiryMessage(
      {required final String id,
      @JsonKey(name: 'inquiry_id') required final String inquiryId,
      required final String senderId,
      required final String content,
      final bool isRead,
      final bool isFlagged,
      final String? flaggedReason,
      required final DateTime createdAt}) = _$InquiryMessageImpl;

  factory _InquiryMessage.fromJson(Map<String, dynamic> json) =
      _$InquiryMessageImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'inquiry_id')
  String get inquiryId;
  @override
  String get senderId;
  @override
  String get content;
  @override
  bool get isRead;
  @override
  bool get isFlagged;
  @override
  String? get flaggedReason;
  @override
  DateTime get createdAt;

  /// Create a copy of InquiryMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InquiryMessageImplCopyWith<_$InquiryMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BookingChat _$BookingChatFromJson(Map<String, dynamic> json) {
  return _BookingChat.fromJson(json);
}

/// @nodoc
mixin _$BookingChat {
  String get id => throw _privateConstructorUsedError;
  String get bookingId => throw _privateConstructorUsedError;
  String get senderId => throw _privateConstructorUsedError;
  String get receiverId => throw _privateConstructorUsedError;
  String? get chefName => throw _privateConstructorUsedError;
  String? get chefImage => throw _privateConstructorUsedError;
  String? get userName => throw _privateConstructorUsedError;
  String? get userImage => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  bool get isRead => throw _privateConstructorUsedError;
  bool get isArchived => throw _privateConstructorUsedError;
  int get unreadCount => throw _privateConstructorUsedError;

  /// Serializes this BookingChat to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BookingChat
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BookingChatCopyWith<BookingChat> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookingChatCopyWith<$Res> {
  factory $BookingChatCopyWith(
          BookingChat value, $Res Function(BookingChat) then) =
      _$BookingChatCopyWithImpl<$Res, BookingChat>;
  @useResult
  $Res call(
      {String id,
      String bookingId,
      String senderId,
      String receiverId,
      String? chefName,
      String? chefImage,
      String? userName,
      String? userImage,
      String content,
      DateTime createdAt,
      bool isRead,
      bool isArchived,
      int unreadCount});
}

/// @nodoc
class _$BookingChatCopyWithImpl<$Res, $Val extends BookingChat>
    implements $BookingChatCopyWith<$Res> {
  _$BookingChatCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BookingChat
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bookingId = null,
    Object? senderId = null,
    Object? receiverId = null,
    Object? chefName = freezed,
    Object? chefImage = freezed,
    Object? userName = freezed,
    Object? userImage = freezed,
    Object? content = null,
    Object? createdAt = null,
    Object? isRead = null,
    Object? isArchived = null,
    Object? unreadCount = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      bookingId: null == bookingId
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      receiverId: null == receiverId
          ? _value.receiverId
          : receiverId // ignore: cast_nullable_to_non_nullable
              as String,
      chefName: freezed == chefName
          ? _value.chefName
          : chefName // ignore: cast_nullable_to_non_nullable
              as String?,
      chefImage: freezed == chefImage
          ? _value.chefImage
          : chefImage // ignore: cast_nullable_to_non_nullable
              as String?,
      userName: freezed == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String?,
      userImage: freezed == userImage
          ? _value.userImage
          : userImage // ignore: cast_nullable_to_non_nullable
              as String?,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      isArchived: null == isArchived
          ? _value.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
              as bool,
      unreadCount: null == unreadCount
          ? _value.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BookingChatImplCopyWith<$Res>
    implements $BookingChatCopyWith<$Res> {
  factory _$$BookingChatImplCopyWith(
          _$BookingChatImpl value, $Res Function(_$BookingChatImpl) then) =
      __$$BookingChatImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String bookingId,
      String senderId,
      String receiverId,
      String? chefName,
      String? chefImage,
      String? userName,
      String? userImage,
      String content,
      DateTime createdAt,
      bool isRead,
      bool isArchived,
      int unreadCount});
}

/// @nodoc
class __$$BookingChatImplCopyWithImpl<$Res>
    extends _$BookingChatCopyWithImpl<$Res, _$BookingChatImpl>
    implements _$$BookingChatImplCopyWith<$Res> {
  __$$BookingChatImplCopyWithImpl(
      _$BookingChatImpl _value, $Res Function(_$BookingChatImpl) _then)
      : super(_value, _then);

  /// Create a copy of BookingChat
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bookingId = null,
    Object? senderId = null,
    Object? receiverId = null,
    Object? chefName = freezed,
    Object? chefImage = freezed,
    Object? userName = freezed,
    Object? userImage = freezed,
    Object? content = null,
    Object? createdAt = null,
    Object? isRead = null,
    Object? isArchived = null,
    Object? unreadCount = null,
  }) {
    return _then(_$BookingChatImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      bookingId: null == bookingId
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      receiverId: null == receiverId
          ? _value.receiverId
          : receiverId // ignore: cast_nullable_to_non_nullable
              as String,
      chefName: freezed == chefName
          ? _value.chefName
          : chefName // ignore: cast_nullable_to_non_nullable
              as String?,
      chefImage: freezed == chefImage
          ? _value.chefImage
          : chefImage // ignore: cast_nullable_to_non_nullable
              as String?,
      userName: freezed == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String?,
      userImage: freezed == userImage
          ? _value.userImage
          : userImage // ignore: cast_nullable_to_non_nullable
              as String?,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      isArchived: null == isArchived
          ? _value.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
              as bool,
      unreadCount: null == unreadCount
          ? _value.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BookingChatImpl implements _BookingChat {
  const _$BookingChatImpl(
      {required this.id,
      required this.bookingId,
      required this.senderId,
      required this.receiverId,
      this.chefName,
      this.chefImage,
      this.userName,
      this.userImage,
      required this.content,
      required this.createdAt,
      this.isRead = false,
      this.isArchived = false,
      this.unreadCount = 0});

  factory _$BookingChatImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookingChatImplFromJson(json);

  @override
  final String id;
  @override
  final String bookingId;
  @override
  final String senderId;
  @override
  final String receiverId;
  @override
  final String? chefName;
  @override
  final String? chefImage;
  @override
  final String? userName;
  @override
  final String? userImage;
  @override
  final String content;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final bool isRead;
  @override
  @JsonKey()
  final bool isArchived;
  @override
  @JsonKey()
  final int unreadCount;

  @override
  String toString() {
    return 'BookingChat(id: $id, bookingId: $bookingId, senderId: $senderId, receiverId: $receiverId, chefName: $chefName, chefImage: $chefImage, userName: $userName, userImage: $userImage, content: $content, createdAt: $createdAt, isRead: $isRead, isArchived: $isArchived, unreadCount: $unreadCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookingChatImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.bookingId, bookingId) ||
                other.bookingId == bookingId) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.receiverId, receiverId) ||
                other.receiverId == receiverId) &&
            (identical(other.chefName, chefName) ||
                other.chefName == chefName) &&
            (identical(other.chefImage, chefImage) ||
                other.chefImage == chefImage) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.userImage, userImage) ||
                other.userImage == userImage) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.isArchived, isArchived) ||
                other.isArchived == isArchived) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      bookingId,
      senderId,
      receiverId,
      chefName,
      chefImage,
      userName,
      userImage,
      content,
      createdAt,
      isRead,
      isArchived,
      unreadCount);

  /// Create a copy of BookingChat
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BookingChatImplCopyWith<_$BookingChatImpl> get copyWith =>
      __$$BookingChatImplCopyWithImpl<_$BookingChatImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookingChatImplToJson(
      this,
    );
  }
}

abstract class _BookingChat implements BookingChat {
  const factory _BookingChat(
      {required final String id,
      required final String bookingId,
      required final String senderId,
      required final String receiverId,
      final String? chefName,
      final String? chefImage,
      final String? userName,
      final String? userImage,
      required final String content,
      required final DateTime createdAt,
      final bool isRead,
      final bool isArchived,
      final int unreadCount}) = _$BookingChatImpl;

  factory _BookingChat.fromJson(Map<String, dynamic> json) =
      _$BookingChatImpl.fromJson;

  @override
  String get id;
  @override
  String get bookingId;
  @override
  String get senderId;
  @override
  String get receiverId;
  @override
  String? get chefName;
  @override
  String? get chefImage;
  @override
  String? get userName;
  @override
  String? get userImage;
  @override
  String get content;
  @override
  DateTime get createdAt;
  @override
  bool get isRead;
  @override
  bool get isArchived;
  @override
  int get unreadCount;

  /// Create a copy of BookingChat
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookingChatImplCopyWith<_$BookingChatImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UnifiedConversation _$UnifiedConversationFromJson(Map<String, dynamic> json) {
  return _UnifiedConversation.fromJson(json);
}

/// @nodoc
mixin _$UnifiedConversation {
  String get id => throw _privateConstructorUsedError;
  ConversationType get type => throw _privateConstructorUsedError;
  String? get bookingId => throw _privateConstructorUsedError;
  String? get otherPersonName => throw _privateConstructorUsedError;
  String? get otherPersonImage => throw _privateConstructorUsedError;
  String? get lastMessage => throw _privateConstructorUsedError;
  DateTime? get lastMessageAt => throw _privateConstructorUsedError;
  int get unreadCount => throw _privateConstructorUsedError;
  String? get bookingStatus => throw _privateConstructorUsedError;
  DateTime? get bookingDate => throw _privateConstructorUsedError;

  /// Serializes this UnifiedConversation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UnifiedConversation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UnifiedConversationCopyWith<UnifiedConversation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UnifiedConversationCopyWith<$Res> {
  factory $UnifiedConversationCopyWith(
          UnifiedConversation value, $Res Function(UnifiedConversation) then) =
      _$UnifiedConversationCopyWithImpl<$Res, UnifiedConversation>;
  @useResult
  $Res call(
      {String id,
      ConversationType type,
      String? bookingId,
      String? otherPersonName,
      String? otherPersonImage,
      String? lastMessage,
      DateTime? lastMessageAt,
      int unreadCount,
      String? bookingStatus,
      DateTime? bookingDate});
}

/// @nodoc
class _$UnifiedConversationCopyWithImpl<$Res, $Val extends UnifiedConversation>
    implements $UnifiedConversationCopyWith<$Res> {
  _$UnifiedConversationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UnifiedConversation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? bookingId = freezed,
    Object? otherPersonName = freezed,
    Object? otherPersonImage = freezed,
    Object? lastMessage = freezed,
    Object? lastMessageAt = freezed,
    Object? unreadCount = null,
    Object? bookingStatus = freezed,
    Object? bookingDate = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ConversationType,
      bookingId: freezed == bookingId
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String?,
      otherPersonName: freezed == otherPersonName
          ? _value.otherPersonName
          : otherPersonName // ignore: cast_nullable_to_non_nullable
              as String?,
      otherPersonImage: freezed == otherPersonImage
          ? _value.otherPersonImage
          : otherPersonImage // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessage: freezed == lastMessage
          ? _value.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessageAt: freezed == lastMessageAt
          ? _value.lastMessageAt
          : lastMessageAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      unreadCount: null == unreadCount
          ? _value.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int,
      bookingStatus: freezed == bookingStatus
          ? _value.bookingStatus
          : bookingStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      bookingDate: freezed == bookingDate
          ? _value.bookingDate
          : bookingDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UnifiedConversationImplCopyWith<$Res>
    implements $UnifiedConversationCopyWith<$Res> {
  factory _$$UnifiedConversationImplCopyWith(_$UnifiedConversationImpl value,
          $Res Function(_$UnifiedConversationImpl) then) =
      __$$UnifiedConversationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      ConversationType type,
      String? bookingId,
      String? otherPersonName,
      String? otherPersonImage,
      String? lastMessage,
      DateTime? lastMessageAt,
      int unreadCount,
      String? bookingStatus,
      DateTime? bookingDate});
}

/// @nodoc
class __$$UnifiedConversationImplCopyWithImpl<$Res>
    extends _$UnifiedConversationCopyWithImpl<$Res, _$UnifiedConversationImpl>
    implements _$$UnifiedConversationImplCopyWith<$Res> {
  __$$UnifiedConversationImplCopyWithImpl(_$UnifiedConversationImpl _value,
      $Res Function(_$UnifiedConversationImpl) _then)
      : super(_value, _then);

  /// Create a copy of UnifiedConversation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? bookingId = freezed,
    Object? otherPersonName = freezed,
    Object? otherPersonImage = freezed,
    Object? lastMessage = freezed,
    Object? lastMessageAt = freezed,
    Object? unreadCount = null,
    Object? bookingStatus = freezed,
    Object? bookingDate = freezed,
  }) {
    return _then(_$UnifiedConversationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ConversationType,
      bookingId: freezed == bookingId
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String?,
      otherPersonName: freezed == otherPersonName
          ? _value.otherPersonName
          : otherPersonName // ignore: cast_nullable_to_non_nullable
              as String?,
      otherPersonImage: freezed == otherPersonImage
          ? _value.otherPersonImage
          : otherPersonImage // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessage: freezed == lastMessage
          ? _value.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessageAt: freezed == lastMessageAt
          ? _value.lastMessageAt
          : lastMessageAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      unreadCount: null == unreadCount
          ? _value.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int,
      bookingStatus: freezed == bookingStatus
          ? _value.bookingStatus
          : bookingStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      bookingDate: freezed == bookingDate
          ? _value.bookingDate
          : bookingDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UnifiedConversationImpl implements _UnifiedConversation {
  const _$UnifiedConversationImpl(
      {required this.id,
      required this.type,
      this.bookingId,
      this.otherPersonName,
      this.otherPersonImage,
      this.lastMessage,
      this.lastMessageAt,
      this.unreadCount = 0,
      this.bookingStatus,
      this.bookingDate});

  factory _$UnifiedConversationImpl.fromJson(Map<String, dynamic> json) =>
      _$$UnifiedConversationImplFromJson(json);

  @override
  final String id;
  @override
  final ConversationType type;
  @override
  final String? bookingId;
  @override
  final String? otherPersonName;
  @override
  final String? otherPersonImage;
  @override
  final String? lastMessage;
  @override
  final DateTime? lastMessageAt;
  @override
  @JsonKey()
  final int unreadCount;
  @override
  final String? bookingStatus;
  @override
  final DateTime? bookingDate;

  @override
  String toString() {
    return 'UnifiedConversation(id: $id, type: $type, bookingId: $bookingId, otherPersonName: $otherPersonName, otherPersonImage: $otherPersonImage, lastMessage: $lastMessage, lastMessageAt: $lastMessageAt, unreadCount: $unreadCount, bookingStatus: $bookingStatus, bookingDate: $bookingDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnifiedConversationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.bookingId, bookingId) ||
                other.bookingId == bookingId) &&
            (identical(other.otherPersonName, otherPersonName) ||
                other.otherPersonName == otherPersonName) &&
            (identical(other.otherPersonImage, otherPersonImage) ||
                other.otherPersonImage == otherPersonImage) &&
            (identical(other.lastMessage, lastMessage) ||
                other.lastMessage == lastMessage) &&
            (identical(other.lastMessageAt, lastMessageAt) ||
                other.lastMessageAt == lastMessageAt) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount) &&
            (identical(other.bookingStatus, bookingStatus) ||
                other.bookingStatus == bookingStatus) &&
            (identical(other.bookingDate, bookingDate) ||
                other.bookingDate == bookingDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      type,
      bookingId,
      otherPersonName,
      otherPersonImage,
      lastMessage,
      lastMessageAt,
      unreadCount,
      bookingStatus,
      bookingDate);

  /// Create a copy of UnifiedConversation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnifiedConversationImplCopyWith<_$UnifiedConversationImpl> get copyWith =>
      __$$UnifiedConversationImplCopyWithImpl<_$UnifiedConversationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UnifiedConversationImplToJson(
      this,
    );
  }
}

abstract class _UnifiedConversation implements UnifiedConversation {
  const factory _UnifiedConversation(
      {required final String id,
      required final ConversationType type,
      final String? bookingId,
      final String? otherPersonName,
      final String? otherPersonImage,
      final String? lastMessage,
      final DateTime? lastMessageAt,
      final int unreadCount,
      final String? bookingStatus,
      final DateTime? bookingDate}) = _$UnifiedConversationImpl;

  factory _UnifiedConversation.fromJson(Map<String, dynamic> json) =
      _$UnifiedConversationImpl.fromJson;

  @override
  String get id;
  @override
  ConversationType get type;
  @override
  String? get bookingId;
  @override
  String? get otherPersonName;
  @override
  String? get otherPersonImage;
  @override
  String? get lastMessage;
  @override
  DateTime? get lastMessageAt;
  @override
  int get unreadCount;
  @override
  String? get bookingStatus;
  @override
  DateTime? get bookingDate;

  /// Create a copy of UnifiedConversation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnifiedConversationImplCopyWith<_$UnifiedConversationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
