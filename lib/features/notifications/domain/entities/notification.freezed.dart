// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

NotificationEntity _$NotificationEntityFromJson(Map<String, dynamic> json) {
  return _NotificationEntity.fromJson(json);
}

/// @nodoc
mixin _$NotificationEntity {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String? get bookingId => throw _privateConstructorUsedError;
  String? get chefId => throw _privateConstructorUsedError;
  NotificationType get type => throw _privateConstructorUsedError;
  NotificationChannel get channel => throw _privateConstructorUsedError;
  NotificationStatus get status => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  Map<String, dynamic> get data => throw _privateConstructorUsedError;
  String? get templateId => throw _privateConstructorUsedError;
  DateTime? get scheduledAt => throw _privateConstructorUsedError;
  DateTime? get sentAt => throw _privateConstructorUsedError;
  DateTime? get deliveredAt => throw _privateConstructorUsedError;
  DateTime? get failedAt => throw _privateConstructorUsedError;
  String? get failureReason => throw _privateConstructorUsedError;
  int get retryCount => throw _privateConstructorUsedError;
  int get maxRetries => throw _privateConstructorUsedError;
  String? get externalId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this NotificationEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationEntityCopyWith<NotificationEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationEntityCopyWith<$Res> {
  factory $NotificationEntityCopyWith(
          NotificationEntity value, $Res Function(NotificationEntity) then) =
      _$NotificationEntityCopyWithImpl<$Res, NotificationEntity>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String? bookingId,
      String? chefId,
      NotificationType type,
      NotificationChannel channel,
      NotificationStatus status,
      String title,
      String content,
      Map<String, dynamic> data,
      String? templateId,
      DateTime? scheduledAt,
      DateTime? sentAt,
      DateTime? deliveredAt,
      DateTime? failedAt,
      String? failureReason,
      int retryCount,
      int maxRetries,
      String? externalId,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$NotificationEntityCopyWithImpl<$Res, $Val extends NotificationEntity>
    implements $NotificationEntityCopyWith<$Res> {
  _$NotificationEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? bookingId = freezed,
    Object? chefId = freezed,
    Object? type = null,
    Object? channel = null,
    Object? status = null,
    Object? title = null,
    Object? content = null,
    Object? data = null,
    Object? templateId = freezed,
    Object? scheduledAt = freezed,
    Object? sentAt = freezed,
    Object? deliveredAt = freezed,
    Object? failedAt = freezed,
    Object? failureReason = freezed,
    Object? retryCount = null,
    Object? maxRetries = null,
    Object? externalId = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
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
      bookingId: freezed == bookingId
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String?,
      chefId: freezed == chefId
          ? _value.chefId
          : chefId // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as NotificationType,
      channel: null == channel
          ? _value.channel
          : channel // ignore: cast_nullable_to_non_nullable
              as NotificationChannel,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as NotificationStatus,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      templateId: freezed == templateId
          ? _value.templateId
          : templateId // ignore: cast_nullable_to_non_nullable
              as String?,
      scheduledAt: freezed == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      sentAt: freezed == sentAt
          ? _value.sentAt
          : sentAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deliveredAt: freezed == deliveredAt
          ? _value.deliveredAt
          : deliveredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      failedAt: freezed == failedAt
          ? _value.failedAt
          : failedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      failureReason: freezed == failureReason
          ? _value.failureReason
          : failureReason // ignore: cast_nullable_to_non_nullable
              as String?,
      retryCount: null == retryCount
          ? _value.retryCount
          : retryCount // ignore: cast_nullable_to_non_nullable
              as int,
      maxRetries: null == maxRetries
          ? _value.maxRetries
          : maxRetries // ignore: cast_nullable_to_non_nullable
              as int,
      externalId: freezed == externalId
          ? _value.externalId
          : externalId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationEntityImplCopyWith<$Res>
    implements $NotificationEntityCopyWith<$Res> {
  factory _$$NotificationEntityImplCopyWith(_$NotificationEntityImpl value,
          $Res Function(_$NotificationEntityImpl) then) =
      __$$NotificationEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String? bookingId,
      String? chefId,
      NotificationType type,
      NotificationChannel channel,
      NotificationStatus status,
      String title,
      String content,
      Map<String, dynamic> data,
      String? templateId,
      DateTime? scheduledAt,
      DateTime? sentAt,
      DateTime? deliveredAt,
      DateTime? failedAt,
      String? failureReason,
      int retryCount,
      int maxRetries,
      String? externalId,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$NotificationEntityImplCopyWithImpl<$Res>
    extends _$NotificationEntityCopyWithImpl<$Res, _$NotificationEntityImpl>
    implements _$$NotificationEntityImplCopyWith<$Res> {
  __$$NotificationEntityImplCopyWithImpl(_$NotificationEntityImpl _value,
      $Res Function(_$NotificationEntityImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? bookingId = freezed,
    Object? chefId = freezed,
    Object? type = null,
    Object? channel = null,
    Object? status = null,
    Object? title = null,
    Object? content = null,
    Object? data = null,
    Object? templateId = freezed,
    Object? scheduledAt = freezed,
    Object? sentAt = freezed,
    Object? deliveredAt = freezed,
    Object? failedAt = freezed,
    Object? failureReason = freezed,
    Object? retryCount = null,
    Object? maxRetries = null,
    Object? externalId = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$NotificationEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      bookingId: freezed == bookingId
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String?,
      chefId: freezed == chefId
          ? _value.chefId
          : chefId // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as NotificationType,
      channel: null == channel
          ? _value.channel
          : channel // ignore: cast_nullable_to_non_nullable
              as NotificationChannel,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as NotificationStatus,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      data: null == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      templateId: freezed == templateId
          ? _value.templateId
          : templateId // ignore: cast_nullable_to_non_nullable
              as String?,
      scheduledAt: freezed == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      sentAt: freezed == sentAt
          ? _value.sentAt
          : sentAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deliveredAt: freezed == deliveredAt
          ? _value.deliveredAt
          : deliveredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      failedAt: freezed == failedAt
          ? _value.failedAt
          : failedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      failureReason: freezed == failureReason
          ? _value.failureReason
          : failureReason // ignore: cast_nullable_to_non_nullable
              as String?,
      retryCount: null == retryCount
          ? _value.retryCount
          : retryCount // ignore: cast_nullable_to_non_nullable
              as int,
      maxRetries: null == maxRetries
          ? _value.maxRetries
          : maxRetries // ignore: cast_nullable_to_non_nullable
              as int,
      externalId: freezed == externalId
          ? _value.externalId
          : externalId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationEntityImpl implements _NotificationEntity {
  const _$NotificationEntityImpl(
      {required this.id,
      required this.userId,
      this.bookingId,
      this.chefId,
      required this.type,
      required this.channel,
      this.status = NotificationStatus.pending,
      required this.title,
      required this.content,
      final Map<String, dynamic> data = const {},
      this.templateId,
      this.scheduledAt,
      this.sentAt,
      this.deliveredAt,
      this.failedAt,
      this.failureReason,
      this.retryCount = 0,
      this.maxRetries = 3,
      this.externalId,
      required this.createdAt,
      required this.updatedAt})
      : _data = data;

  factory _$NotificationEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationEntityImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String? bookingId;
  @override
  final String? chefId;
  @override
  final NotificationType type;
  @override
  final NotificationChannel channel;
  @override
  @JsonKey()
  final NotificationStatus status;
  @override
  final String title;
  @override
  final String content;
  final Map<String, dynamic> _data;
  @override
  @JsonKey()
  Map<String, dynamic> get data {
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_data);
  }

  @override
  final String? templateId;
  @override
  final DateTime? scheduledAt;
  @override
  final DateTime? sentAt;
  @override
  final DateTime? deliveredAt;
  @override
  final DateTime? failedAt;
  @override
  final String? failureReason;
  @override
  @JsonKey()
  final int retryCount;
  @override
  @JsonKey()
  final int maxRetries;
  @override
  final String? externalId;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'NotificationEntity(id: $id, userId: $userId, bookingId: $bookingId, chefId: $chefId, type: $type, channel: $channel, status: $status, title: $title, content: $content, data: $data, templateId: $templateId, scheduledAt: $scheduledAt, sentAt: $sentAt, deliveredAt: $deliveredAt, failedAt: $failedAt, failureReason: $failureReason, retryCount: $retryCount, maxRetries: $maxRetries, externalId: $externalId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.bookingId, bookingId) ||
                other.bookingId == bookingId) &&
            (identical(other.chefId, chefId) || other.chefId == chefId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.channel, channel) || other.channel == channel) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.templateId, templateId) ||
                other.templateId == templateId) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(other.sentAt, sentAt) || other.sentAt == sentAt) &&
            (identical(other.deliveredAt, deliveredAt) ||
                other.deliveredAt == deliveredAt) &&
            (identical(other.failedAt, failedAt) ||
                other.failedAt == failedAt) &&
            (identical(other.failureReason, failureReason) ||
                other.failureReason == failureReason) &&
            (identical(other.retryCount, retryCount) ||
                other.retryCount == retryCount) &&
            (identical(other.maxRetries, maxRetries) ||
                other.maxRetries == maxRetries) &&
            (identical(other.externalId, externalId) ||
                other.externalId == externalId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        userId,
        bookingId,
        chefId,
        type,
        channel,
        status,
        title,
        content,
        const DeepCollectionEquality().hash(_data),
        templateId,
        scheduledAt,
        sentAt,
        deliveredAt,
        failedAt,
        failureReason,
        retryCount,
        maxRetries,
        externalId,
        createdAt,
        updatedAt
      ]);

  /// Create a copy of NotificationEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationEntityImplCopyWith<_$NotificationEntityImpl> get copyWith =>
      __$$NotificationEntityImplCopyWithImpl<_$NotificationEntityImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationEntityImplToJson(
      this,
    );
  }
}

abstract class _NotificationEntity implements NotificationEntity {
  const factory _NotificationEntity(
      {required final String id,
      required final String userId,
      final String? bookingId,
      final String? chefId,
      required final NotificationType type,
      required final NotificationChannel channel,
      final NotificationStatus status,
      required final String title,
      required final String content,
      final Map<String, dynamic> data,
      final String? templateId,
      final DateTime? scheduledAt,
      final DateTime? sentAt,
      final DateTime? deliveredAt,
      final DateTime? failedAt,
      final String? failureReason,
      final int retryCount,
      final int maxRetries,
      final String? externalId,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$NotificationEntityImpl;

  factory _NotificationEntity.fromJson(Map<String, dynamic> json) =
      _$NotificationEntityImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String? get bookingId;
  @override
  String? get chefId;
  @override
  NotificationType get type;
  @override
  NotificationChannel get channel;
  @override
  NotificationStatus get status;
  @override
  String get title;
  @override
  String get content;
  @override
  Map<String, dynamic> get data;
  @override
  String? get templateId;
  @override
  DateTime? get scheduledAt;
  @override
  DateTime? get sentAt;
  @override
  DateTime? get deliveredAt;
  @override
  DateTime? get failedAt;
  @override
  String? get failureReason;
  @override
  int get retryCount;
  @override
  int get maxRetries;
  @override
  String? get externalId;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of NotificationEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationEntityImplCopyWith<_$NotificationEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NotificationPreferences _$NotificationPreferencesFromJson(
    Map<String, dynamic> json) {
  return _NotificationPreferences.fromJson(json);
}

/// @nodoc
mixin _$NotificationPreferences {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  bool get emailEnabled => throw _privateConstructorUsedError;
  bool get pushEnabled => throw _privateConstructorUsedError;
  bool get inAppEnabled => throw _privateConstructorUsedError;
  bool get smsEnabled => throw _privateConstructorUsedError;
  bool get bookingConfirmations => throw _privateConstructorUsedError;
  bool get bookingReminders => throw _privateConstructorUsedError;
  bool get bookingUpdates => throw _privateConstructorUsedError;
  bool get marketingEmails => throw _privateConstructorUsedError;
  String get languagePreference => throw _privateConstructorUsedError;
  String get timezone => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this NotificationPreferences to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationPreferences
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationPreferencesCopyWith<NotificationPreferences> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationPreferencesCopyWith<$Res> {
  factory $NotificationPreferencesCopyWith(NotificationPreferences value,
          $Res Function(NotificationPreferences) then) =
      _$NotificationPreferencesCopyWithImpl<$Res, NotificationPreferences>;
  @useResult
  $Res call(
      {String id,
      String userId,
      bool emailEnabled,
      bool pushEnabled,
      bool inAppEnabled,
      bool smsEnabled,
      bool bookingConfirmations,
      bool bookingReminders,
      bool bookingUpdates,
      bool marketingEmails,
      String languagePreference,
      String timezone,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$NotificationPreferencesCopyWithImpl<$Res,
        $Val extends NotificationPreferences>
    implements $NotificationPreferencesCopyWith<$Res> {
  _$NotificationPreferencesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationPreferences
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? emailEnabled = null,
    Object? pushEnabled = null,
    Object? inAppEnabled = null,
    Object? smsEnabled = null,
    Object? bookingConfirmations = null,
    Object? bookingReminders = null,
    Object? bookingUpdates = null,
    Object? marketingEmails = null,
    Object? languagePreference = null,
    Object? timezone = null,
    Object? createdAt = null,
    Object? updatedAt = null,
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
      emailEnabled: null == emailEnabled
          ? _value.emailEnabled
          : emailEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      pushEnabled: null == pushEnabled
          ? _value.pushEnabled
          : pushEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      inAppEnabled: null == inAppEnabled
          ? _value.inAppEnabled
          : inAppEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      smsEnabled: null == smsEnabled
          ? _value.smsEnabled
          : smsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      bookingConfirmations: null == bookingConfirmations
          ? _value.bookingConfirmations
          : bookingConfirmations // ignore: cast_nullable_to_non_nullable
              as bool,
      bookingReminders: null == bookingReminders
          ? _value.bookingReminders
          : bookingReminders // ignore: cast_nullable_to_non_nullable
              as bool,
      bookingUpdates: null == bookingUpdates
          ? _value.bookingUpdates
          : bookingUpdates // ignore: cast_nullable_to_non_nullable
              as bool,
      marketingEmails: null == marketingEmails
          ? _value.marketingEmails
          : marketingEmails // ignore: cast_nullable_to_non_nullable
              as bool,
      languagePreference: null == languagePreference
          ? _value.languagePreference
          : languagePreference // ignore: cast_nullable_to_non_nullable
              as String,
      timezone: null == timezone
          ? _value.timezone
          : timezone // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationPreferencesImplCopyWith<$Res>
    implements $NotificationPreferencesCopyWith<$Res> {
  factory _$$NotificationPreferencesImplCopyWith(
          _$NotificationPreferencesImpl value,
          $Res Function(_$NotificationPreferencesImpl) then) =
      __$$NotificationPreferencesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      bool emailEnabled,
      bool pushEnabled,
      bool inAppEnabled,
      bool smsEnabled,
      bool bookingConfirmations,
      bool bookingReminders,
      bool bookingUpdates,
      bool marketingEmails,
      String languagePreference,
      String timezone,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$NotificationPreferencesImplCopyWithImpl<$Res>
    extends _$NotificationPreferencesCopyWithImpl<$Res,
        _$NotificationPreferencesImpl>
    implements _$$NotificationPreferencesImplCopyWith<$Res> {
  __$$NotificationPreferencesImplCopyWithImpl(
      _$NotificationPreferencesImpl _value,
      $Res Function(_$NotificationPreferencesImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationPreferences
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? emailEnabled = null,
    Object? pushEnabled = null,
    Object? inAppEnabled = null,
    Object? smsEnabled = null,
    Object? bookingConfirmations = null,
    Object? bookingReminders = null,
    Object? bookingUpdates = null,
    Object? marketingEmails = null,
    Object? languagePreference = null,
    Object? timezone = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$NotificationPreferencesImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      emailEnabled: null == emailEnabled
          ? _value.emailEnabled
          : emailEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      pushEnabled: null == pushEnabled
          ? _value.pushEnabled
          : pushEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      inAppEnabled: null == inAppEnabled
          ? _value.inAppEnabled
          : inAppEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      smsEnabled: null == smsEnabled
          ? _value.smsEnabled
          : smsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      bookingConfirmations: null == bookingConfirmations
          ? _value.bookingConfirmations
          : bookingConfirmations // ignore: cast_nullable_to_non_nullable
              as bool,
      bookingReminders: null == bookingReminders
          ? _value.bookingReminders
          : bookingReminders // ignore: cast_nullable_to_non_nullable
              as bool,
      bookingUpdates: null == bookingUpdates
          ? _value.bookingUpdates
          : bookingUpdates // ignore: cast_nullable_to_non_nullable
              as bool,
      marketingEmails: null == marketingEmails
          ? _value.marketingEmails
          : marketingEmails // ignore: cast_nullable_to_non_nullable
              as bool,
      languagePreference: null == languagePreference
          ? _value.languagePreference
          : languagePreference // ignore: cast_nullable_to_non_nullable
              as String,
      timezone: null == timezone
          ? _value.timezone
          : timezone // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationPreferencesImpl implements _NotificationPreferences {
  const _$NotificationPreferencesImpl(
      {required this.id,
      required this.userId,
      this.emailEnabled = true,
      this.pushEnabled = true,
      this.inAppEnabled = true,
      this.smsEnabled = false,
      this.bookingConfirmations = true,
      this.bookingReminders = true,
      this.bookingUpdates = true,
      this.marketingEmails = false,
      this.languagePreference = 'da',
      this.timezone = 'Europe/Copenhagen',
      required this.createdAt,
      required this.updatedAt});

  factory _$NotificationPreferencesImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationPreferencesImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  @JsonKey()
  final bool emailEnabled;
  @override
  @JsonKey()
  final bool pushEnabled;
  @override
  @JsonKey()
  final bool inAppEnabled;
  @override
  @JsonKey()
  final bool smsEnabled;
  @override
  @JsonKey()
  final bool bookingConfirmations;
  @override
  @JsonKey()
  final bool bookingReminders;
  @override
  @JsonKey()
  final bool bookingUpdates;
  @override
  @JsonKey()
  final bool marketingEmails;
  @override
  @JsonKey()
  final String languagePreference;
  @override
  @JsonKey()
  final String timezone;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'NotificationPreferences(id: $id, userId: $userId, emailEnabled: $emailEnabled, pushEnabled: $pushEnabled, inAppEnabled: $inAppEnabled, smsEnabled: $smsEnabled, bookingConfirmations: $bookingConfirmations, bookingReminders: $bookingReminders, bookingUpdates: $bookingUpdates, marketingEmails: $marketingEmails, languagePreference: $languagePreference, timezone: $timezone, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationPreferencesImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.emailEnabled, emailEnabled) ||
                other.emailEnabled == emailEnabled) &&
            (identical(other.pushEnabled, pushEnabled) ||
                other.pushEnabled == pushEnabled) &&
            (identical(other.inAppEnabled, inAppEnabled) ||
                other.inAppEnabled == inAppEnabled) &&
            (identical(other.smsEnabled, smsEnabled) ||
                other.smsEnabled == smsEnabled) &&
            (identical(other.bookingConfirmations, bookingConfirmations) ||
                other.bookingConfirmations == bookingConfirmations) &&
            (identical(other.bookingReminders, bookingReminders) ||
                other.bookingReminders == bookingReminders) &&
            (identical(other.bookingUpdates, bookingUpdates) ||
                other.bookingUpdates == bookingUpdates) &&
            (identical(other.marketingEmails, marketingEmails) ||
                other.marketingEmails == marketingEmails) &&
            (identical(other.languagePreference, languagePreference) ||
                other.languagePreference == languagePreference) &&
            (identical(other.timezone, timezone) ||
                other.timezone == timezone) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      emailEnabled,
      pushEnabled,
      inAppEnabled,
      smsEnabled,
      bookingConfirmations,
      bookingReminders,
      bookingUpdates,
      marketingEmails,
      languagePreference,
      timezone,
      createdAt,
      updatedAt);

  /// Create a copy of NotificationPreferences
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationPreferencesImplCopyWith<_$NotificationPreferencesImpl>
      get copyWith => __$$NotificationPreferencesImplCopyWithImpl<
          _$NotificationPreferencesImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationPreferencesImplToJson(
      this,
    );
  }
}

abstract class _NotificationPreferences implements NotificationPreferences {
  const factory _NotificationPreferences(
      {required final String id,
      required final String userId,
      final bool emailEnabled,
      final bool pushEnabled,
      final bool inAppEnabled,
      final bool smsEnabled,
      final bool bookingConfirmations,
      final bool bookingReminders,
      final bool bookingUpdates,
      final bool marketingEmails,
      final String languagePreference,
      final String timezone,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$NotificationPreferencesImpl;

  factory _NotificationPreferences.fromJson(Map<String, dynamic> json) =
      _$NotificationPreferencesImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  bool get emailEnabled;
  @override
  bool get pushEnabled;
  @override
  bool get inAppEnabled;
  @override
  bool get smsEnabled;
  @override
  bool get bookingConfirmations;
  @override
  bool get bookingReminders;
  @override
  bool get bookingUpdates;
  @override
  bool get marketingEmails;
  @override
  String get languagePreference;
  @override
  String get timezone;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of NotificationPreferences
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationPreferencesImplCopyWith<_$NotificationPreferencesImpl>
      get copyWith => throw _privateConstructorUsedError;
}

DeviceToken _$DeviceTokenFromJson(Map<String, dynamic> json) {
  return _DeviceToken.fromJson(json);
}

/// @nodoc
mixin _$DeviceToken {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get token => throw _privateConstructorUsedError;
  String get platform => throw _privateConstructorUsedError;
  String? get appVersion => throw _privateConstructorUsedError;
  String? get deviceId => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime get lastUsedAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this DeviceToken to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DeviceToken
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeviceTokenCopyWith<DeviceToken> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeviceTokenCopyWith<$Res> {
  factory $DeviceTokenCopyWith(
          DeviceToken value, $Res Function(DeviceToken) then) =
      _$DeviceTokenCopyWithImpl<$Res, DeviceToken>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String token,
      String platform,
      String? appVersion,
      String? deviceId,
      bool isActive,
      DateTime lastUsedAt,
      DateTime createdAt});
}

/// @nodoc
class _$DeviceTokenCopyWithImpl<$Res, $Val extends DeviceToken>
    implements $DeviceTokenCopyWith<$Res> {
  _$DeviceTokenCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeviceToken
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? token = null,
    Object? platform = null,
    Object? appVersion = freezed,
    Object? deviceId = freezed,
    Object? isActive = null,
    Object? lastUsedAt = null,
    Object? createdAt = null,
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
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      platform: null == platform
          ? _value.platform
          : platform // ignore: cast_nullable_to_non_nullable
              as String,
      appVersion: freezed == appVersion
          ? _value.appVersion
          : appVersion // ignore: cast_nullable_to_non_nullable
              as String?,
      deviceId: freezed == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      lastUsedAt: null == lastUsedAt
          ? _value.lastUsedAt
          : lastUsedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DeviceTokenImplCopyWith<$Res>
    implements $DeviceTokenCopyWith<$Res> {
  factory _$$DeviceTokenImplCopyWith(
          _$DeviceTokenImpl value, $Res Function(_$DeviceTokenImpl) then) =
      __$$DeviceTokenImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String token,
      String platform,
      String? appVersion,
      String? deviceId,
      bool isActive,
      DateTime lastUsedAt,
      DateTime createdAt});
}

/// @nodoc
class __$$DeviceTokenImplCopyWithImpl<$Res>
    extends _$DeviceTokenCopyWithImpl<$Res, _$DeviceTokenImpl>
    implements _$$DeviceTokenImplCopyWith<$Res> {
  __$$DeviceTokenImplCopyWithImpl(
      _$DeviceTokenImpl _value, $Res Function(_$DeviceTokenImpl) _then)
      : super(_value, _then);

  /// Create a copy of DeviceToken
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? token = null,
    Object? platform = null,
    Object? appVersion = freezed,
    Object? deviceId = freezed,
    Object? isActive = null,
    Object? lastUsedAt = null,
    Object? createdAt = null,
  }) {
    return _then(_$DeviceTokenImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      platform: null == platform
          ? _value.platform
          : platform // ignore: cast_nullable_to_non_nullable
              as String,
      appVersion: freezed == appVersion
          ? _value.appVersion
          : appVersion // ignore: cast_nullable_to_non_nullable
              as String?,
      deviceId: freezed == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      lastUsedAt: null == lastUsedAt
          ? _value.lastUsedAt
          : lastUsedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DeviceTokenImpl implements _DeviceToken {
  const _$DeviceTokenImpl(
      {required this.id,
      required this.userId,
      required this.token,
      required this.platform,
      this.appVersion,
      this.deviceId,
      this.isActive = true,
      required this.lastUsedAt,
      required this.createdAt});

  factory _$DeviceTokenImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeviceTokenImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String token;
  @override
  final String platform;
  @override
  final String? appVersion;
  @override
  final String? deviceId;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime lastUsedAt;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'DeviceToken(id: $id, userId: $userId, token: $token, platform: $platform, appVersion: $appVersion, deviceId: $deviceId, isActive: $isActive, lastUsedAt: $lastUsedAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeviceTokenImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.platform, platform) ||
                other.platform == platform) &&
            (identical(other.appVersion, appVersion) ||
                other.appVersion == appVersion) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.lastUsedAt, lastUsedAt) ||
                other.lastUsedAt == lastUsedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, token, platform,
      appVersion, deviceId, isActive, lastUsedAt, createdAt);

  /// Create a copy of DeviceToken
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceTokenImplCopyWith<_$DeviceTokenImpl> get copyWith =>
      __$$DeviceTokenImplCopyWithImpl<_$DeviceTokenImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeviceTokenImplToJson(
      this,
    );
  }
}

abstract class _DeviceToken implements DeviceToken {
  const factory _DeviceToken(
      {required final String id,
      required final String userId,
      required final String token,
      required final String platform,
      final String? appVersion,
      final String? deviceId,
      final bool isActive,
      required final DateTime lastUsedAt,
      required final DateTime createdAt}) = _$DeviceTokenImpl;

  factory _DeviceToken.fromJson(Map<String, dynamic> json) =
      _$DeviceTokenImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get token;
  @override
  String get platform;
  @override
  String? get appVersion;
  @override
  String? get deviceId;
  @override
  bool get isActive;
  @override
  DateTime get lastUsedAt;
  @override
  DateTime get createdAt;

  /// Create a copy of DeviceToken
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeviceTokenImplCopyWith<_$DeviceTokenImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EmailTemplate _$EmailTemplateFromJson(Map<String, dynamic> json) {
  return _EmailTemplate.fromJson(json);
}

/// @nodoc
mixin _$EmailTemplate {
  String get id => throw _privateConstructorUsedError;
  String get templateKey => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String get subjectDa => throw _privateConstructorUsedError;
  String get subjectEn => throw _privateConstructorUsedError;
  String get htmlContentDa => throw _privateConstructorUsedError;
  String get htmlContentEn => throw _privateConstructorUsedError;
  String? get textContentDa => throw _privateConstructorUsedError;
  String? get textContentEn => throw _privateConstructorUsedError;
  List<String> get variables => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this EmailTemplate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EmailTemplate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EmailTemplateCopyWith<EmailTemplate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EmailTemplateCopyWith<$Res> {
  factory $EmailTemplateCopyWith(
          EmailTemplate value, $Res Function(EmailTemplate) then) =
      _$EmailTemplateCopyWithImpl<$Res, EmailTemplate>;
  @useResult
  $Res call(
      {String id,
      String templateKey,
      String name,
      String? description,
      String subjectDa,
      String subjectEn,
      String htmlContentDa,
      String htmlContentEn,
      String? textContentDa,
      String? textContentEn,
      List<String> variables,
      bool isActive,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$EmailTemplateCopyWithImpl<$Res, $Val extends EmailTemplate>
    implements $EmailTemplateCopyWith<$Res> {
  _$EmailTemplateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EmailTemplate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? templateKey = null,
    Object? name = null,
    Object? description = freezed,
    Object? subjectDa = null,
    Object? subjectEn = null,
    Object? htmlContentDa = null,
    Object? htmlContentEn = null,
    Object? textContentDa = freezed,
    Object? textContentEn = freezed,
    Object? variables = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      templateKey: null == templateKey
          ? _value.templateKey
          : templateKey // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      subjectDa: null == subjectDa
          ? _value.subjectDa
          : subjectDa // ignore: cast_nullable_to_non_nullable
              as String,
      subjectEn: null == subjectEn
          ? _value.subjectEn
          : subjectEn // ignore: cast_nullable_to_non_nullable
              as String,
      htmlContentDa: null == htmlContentDa
          ? _value.htmlContentDa
          : htmlContentDa // ignore: cast_nullable_to_non_nullable
              as String,
      htmlContentEn: null == htmlContentEn
          ? _value.htmlContentEn
          : htmlContentEn // ignore: cast_nullable_to_non_nullable
              as String,
      textContentDa: freezed == textContentDa
          ? _value.textContentDa
          : textContentDa // ignore: cast_nullable_to_non_nullable
              as String?,
      textContentEn: freezed == textContentEn
          ? _value.textContentEn
          : textContentEn // ignore: cast_nullable_to_non_nullable
              as String?,
      variables: null == variables
          ? _value.variables
          : variables // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EmailTemplateImplCopyWith<$Res>
    implements $EmailTemplateCopyWith<$Res> {
  factory _$$EmailTemplateImplCopyWith(
          _$EmailTemplateImpl value, $Res Function(_$EmailTemplateImpl) then) =
      __$$EmailTemplateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String templateKey,
      String name,
      String? description,
      String subjectDa,
      String subjectEn,
      String htmlContentDa,
      String htmlContentEn,
      String? textContentDa,
      String? textContentEn,
      List<String> variables,
      bool isActive,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$EmailTemplateImplCopyWithImpl<$Res>
    extends _$EmailTemplateCopyWithImpl<$Res, _$EmailTemplateImpl>
    implements _$$EmailTemplateImplCopyWith<$Res> {
  __$$EmailTemplateImplCopyWithImpl(
      _$EmailTemplateImpl _value, $Res Function(_$EmailTemplateImpl) _then)
      : super(_value, _then);

  /// Create a copy of EmailTemplate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? templateKey = null,
    Object? name = null,
    Object? description = freezed,
    Object? subjectDa = null,
    Object? subjectEn = null,
    Object? htmlContentDa = null,
    Object? htmlContentEn = null,
    Object? textContentDa = freezed,
    Object? textContentEn = freezed,
    Object? variables = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$EmailTemplateImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      templateKey: null == templateKey
          ? _value.templateKey
          : templateKey // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      subjectDa: null == subjectDa
          ? _value.subjectDa
          : subjectDa // ignore: cast_nullable_to_non_nullable
              as String,
      subjectEn: null == subjectEn
          ? _value.subjectEn
          : subjectEn // ignore: cast_nullable_to_non_nullable
              as String,
      htmlContentDa: null == htmlContentDa
          ? _value.htmlContentDa
          : htmlContentDa // ignore: cast_nullable_to_non_nullable
              as String,
      htmlContentEn: null == htmlContentEn
          ? _value.htmlContentEn
          : htmlContentEn // ignore: cast_nullable_to_non_nullable
              as String,
      textContentDa: freezed == textContentDa
          ? _value.textContentDa
          : textContentDa // ignore: cast_nullable_to_non_nullable
              as String?,
      textContentEn: freezed == textContentEn
          ? _value.textContentEn
          : textContentEn // ignore: cast_nullable_to_non_nullable
              as String?,
      variables: null == variables
          ? _value._variables
          : variables // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EmailTemplateImpl implements _EmailTemplate {
  const _$EmailTemplateImpl(
      {required this.id,
      required this.templateKey,
      required this.name,
      this.description,
      required this.subjectDa,
      required this.subjectEn,
      required this.htmlContentDa,
      required this.htmlContentEn,
      this.textContentDa,
      this.textContentEn,
      final List<String> variables = const [],
      this.isActive = true,
      required this.createdAt,
      required this.updatedAt})
      : _variables = variables;

  factory _$EmailTemplateImpl.fromJson(Map<String, dynamic> json) =>
      _$$EmailTemplateImplFromJson(json);

  @override
  final String id;
  @override
  final String templateKey;
  @override
  final String name;
  @override
  final String? description;
  @override
  final String subjectDa;
  @override
  final String subjectEn;
  @override
  final String htmlContentDa;
  @override
  final String htmlContentEn;
  @override
  final String? textContentDa;
  @override
  final String? textContentEn;
  final List<String> _variables;
  @override
  @JsonKey()
  List<String> get variables {
    if (_variables is EqualUnmodifiableListView) return _variables;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_variables);
  }

  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'EmailTemplate(id: $id, templateKey: $templateKey, name: $name, description: $description, subjectDa: $subjectDa, subjectEn: $subjectEn, htmlContentDa: $htmlContentDa, htmlContentEn: $htmlContentEn, textContentDa: $textContentDa, textContentEn: $textContentEn, variables: $variables, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmailTemplateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.templateKey, templateKey) ||
                other.templateKey == templateKey) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.subjectDa, subjectDa) ||
                other.subjectDa == subjectDa) &&
            (identical(other.subjectEn, subjectEn) ||
                other.subjectEn == subjectEn) &&
            (identical(other.htmlContentDa, htmlContentDa) ||
                other.htmlContentDa == htmlContentDa) &&
            (identical(other.htmlContentEn, htmlContentEn) ||
                other.htmlContentEn == htmlContentEn) &&
            (identical(other.textContentDa, textContentDa) ||
                other.textContentDa == textContentDa) &&
            (identical(other.textContentEn, textContentEn) ||
                other.textContentEn == textContentEn) &&
            const DeepCollectionEquality()
                .equals(other._variables, _variables) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      templateKey,
      name,
      description,
      subjectDa,
      subjectEn,
      htmlContentDa,
      htmlContentEn,
      textContentDa,
      textContentEn,
      const DeepCollectionEquality().hash(_variables),
      isActive,
      createdAt,
      updatedAt);

  /// Create a copy of EmailTemplate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EmailTemplateImplCopyWith<_$EmailTemplateImpl> get copyWith =>
      __$$EmailTemplateImplCopyWithImpl<_$EmailTemplateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EmailTemplateImplToJson(
      this,
    );
  }
}

abstract class _EmailTemplate implements EmailTemplate {
  const factory _EmailTemplate(
      {required final String id,
      required final String templateKey,
      required final String name,
      final String? description,
      required final String subjectDa,
      required final String subjectEn,
      required final String htmlContentDa,
      required final String htmlContentEn,
      final String? textContentDa,
      final String? textContentEn,
      final List<String> variables,
      final bool isActive,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$EmailTemplateImpl;

  factory _EmailTemplate.fromJson(Map<String, dynamic> json) =
      _$EmailTemplateImpl.fromJson;

  @override
  String get id;
  @override
  String get templateKey;
  @override
  String get name;
  @override
  String? get description;
  @override
  String get subjectDa;
  @override
  String get subjectEn;
  @override
  String get htmlContentDa;
  @override
  String get htmlContentEn;
  @override
  String? get textContentDa;
  @override
  String? get textContentEn;
  @override
  List<String> get variables;
  @override
  bool get isActive;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of EmailTemplate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EmailTemplateImplCopyWith<_$EmailTemplateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NotificationRequest _$NotificationRequestFromJson(Map<String, dynamic> json) {
  return _NotificationRequest.fromJson(json);
}

/// @nodoc
mixin _$NotificationRequest {
  String get userId => throw _privateConstructorUsedError;
  String? get bookingId => throw _privateConstructorUsedError;
  String? get chefId => throw _privateConstructorUsedError;
  NotificationType get type => throw _privateConstructorUsedError;
  NotificationChannel get channel => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  Map<String, dynamic> get data => throw _privateConstructorUsedError;
  String? get templateId => throw _privateConstructorUsedError;
  DateTime? get scheduledAt => throw _privateConstructorUsedError;

  /// Serializes this NotificationRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationRequestCopyWith<NotificationRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationRequestCopyWith<$Res> {
  factory $NotificationRequestCopyWith(
          NotificationRequest value, $Res Function(NotificationRequest) then) =
      _$NotificationRequestCopyWithImpl<$Res, NotificationRequest>;
  @useResult
  $Res call(
      {String userId,
      String? bookingId,
      String? chefId,
      NotificationType type,
      NotificationChannel channel,
      String title,
      String content,
      Map<String, dynamic> data,
      String? templateId,
      DateTime? scheduledAt});
}

/// @nodoc
class _$NotificationRequestCopyWithImpl<$Res, $Val extends NotificationRequest>
    implements $NotificationRequestCopyWith<$Res> {
  _$NotificationRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? bookingId = freezed,
    Object? chefId = freezed,
    Object? type = null,
    Object? channel = null,
    Object? title = null,
    Object? content = null,
    Object? data = null,
    Object? templateId = freezed,
    Object? scheduledAt = freezed,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      bookingId: freezed == bookingId
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String?,
      chefId: freezed == chefId
          ? _value.chefId
          : chefId // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as NotificationType,
      channel: null == channel
          ? _value.channel
          : channel // ignore: cast_nullable_to_non_nullable
              as NotificationChannel,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      templateId: freezed == templateId
          ? _value.templateId
          : templateId // ignore: cast_nullable_to_non_nullable
              as String?,
      scheduledAt: freezed == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationRequestImplCopyWith<$Res>
    implements $NotificationRequestCopyWith<$Res> {
  factory _$$NotificationRequestImplCopyWith(_$NotificationRequestImpl value,
          $Res Function(_$NotificationRequestImpl) then) =
      __$$NotificationRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      String? bookingId,
      String? chefId,
      NotificationType type,
      NotificationChannel channel,
      String title,
      String content,
      Map<String, dynamic> data,
      String? templateId,
      DateTime? scheduledAt});
}

/// @nodoc
class __$$NotificationRequestImplCopyWithImpl<$Res>
    extends _$NotificationRequestCopyWithImpl<$Res, _$NotificationRequestImpl>
    implements _$$NotificationRequestImplCopyWith<$Res> {
  __$$NotificationRequestImplCopyWithImpl(_$NotificationRequestImpl _value,
      $Res Function(_$NotificationRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? bookingId = freezed,
    Object? chefId = freezed,
    Object? type = null,
    Object? channel = null,
    Object? title = null,
    Object? content = null,
    Object? data = null,
    Object? templateId = freezed,
    Object? scheduledAt = freezed,
  }) {
    return _then(_$NotificationRequestImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      bookingId: freezed == bookingId
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String?,
      chefId: freezed == chefId
          ? _value.chefId
          : chefId // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as NotificationType,
      channel: null == channel
          ? _value.channel
          : channel // ignore: cast_nullable_to_non_nullable
              as NotificationChannel,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      data: null == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      templateId: freezed == templateId
          ? _value.templateId
          : templateId // ignore: cast_nullable_to_non_nullable
              as String?,
      scheduledAt: freezed == scheduledAt
          ? _value.scheduledAt
          : scheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationRequestImpl implements _NotificationRequest {
  const _$NotificationRequestImpl(
      {required this.userId,
      this.bookingId,
      this.chefId,
      required this.type,
      required this.channel,
      required this.title,
      required this.content,
      final Map<String, dynamic> data = const {},
      this.templateId,
      this.scheduledAt})
      : _data = data;

  factory _$NotificationRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationRequestImplFromJson(json);

  @override
  final String userId;
  @override
  final String? bookingId;
  @override
  final String? chefId;
  @override
  final NotificationType type;
  @override
  final NotificationChannel channel;
  @override
  final String title;
  @override
  final String content;
  final Map<String, dynamic> _data;
  @override
  @JsonKey()
  Map<String, dynamic> get data {
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_data);
  }

  @override
  final String? templateId;
  @override
  final DateTime? scheduledAt;

  @override
  String toString() {
    return 'NotificationRequest(userId: $userId, bookingId: $bookingId, chefId: $chefId, type: $type, channel: $channel, title: $title, content: $content, data: $data, templateId: $templateId, scheduledAt: $scheduledAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationRequestImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.bookingId, bookingId) ||
                other.bookingId == bookingId) &&
            (identical(other.chefId, chefId) || other.chefId == chefId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.channel, channel) || other.channel == channel) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.templateId, templateId) ||
                other.templateId == templateId) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      bookingId,
      chefId,
      type,
      channel,
      title,
      content,
      const DeepCollectionEquality().hash(_data),
      templateId,
      scheduledAt);

  /// Create a copy of NotificationRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationRequestImplCopyWith<_$NotificationRequestImpl> get copyWith =>
      __$$NotificationRequestImplCopyWithImpl<_$NotificationRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationRequestImplToJson(
      this,
    );
  }
}

abstract class _NotificationRequest implements NotificationRequest {
  const factory _NotificationRequest(
      {required final String userId,
      final String? bookingId,
      final String? chefId,
      required final NotificationType type,
      required final NotificationChannel channel,
      required final String title,
      required final String content,
      final Map<String, dynamic> data,
      final String? templateId,
      final DateTime? scheduledAt}) = _$NotificationRequestImpl;

  factory _NotificationRequest.fromJson(Map<String, dynamic> json) =
      _$NotificationRequestImpl.fromJson;

  @override
  String get userId;
  @override
  String? get bookingId;
  @override
  String? get chefId;
  @override
  NotificationType get type;
  @override
  NotificationChannel get channel;
  @override
  String get title;
  @override
  String get content;
  @override
  Map<String, dynamic> get data;
  @override
  String? get templateId;
  @override
  DateTime? get scheduledAt;

  /// Create a copy of NotificationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationRequestImplCopyWith<_$NotificationRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
