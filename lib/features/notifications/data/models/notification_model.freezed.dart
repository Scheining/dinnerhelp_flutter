// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) {
  return _NotificationModel.fromJson(json);
}

/// @nodoc
mixin _$NotificationModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String? get bookingId => throw _privateConstructorUsedError;
  String? get chefId => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get channel => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
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

  /// Serializes this NotificationModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationModelCopyWith<NotificationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationModelCopyWith<$Res> {
  factory $NotificationModelCopyWith(
          NotificationModel value, $Res Function(NotificationModel) then) =
      _$NotificationModelCopyWithImpl<$Res, NotificationModel>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String? bookingId,
      String? chefId,
      String type,
      String channel,
      String status,
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
class _$NotificationModelCopyWithImpl<$Res, $Val extends NotificationModel>
    implements $NotificationModelCopyWith<$Res> {
  _$NotificationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationModel
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
              as String,
      channel: null == channel
          ? _value.channel
          : channel // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
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
abstract class _$$NotificationModelImplCopyWith<$Res>
    implements $NotificationModelCopyWith<$Res> {
  factory _$$NotificationModelImplCopyWith(_$NotificationModelImpl value,
          $Res Function(_$NotificationModelImpl) then) =
      __$$NotificationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String? bookingId,
      String? chefId,
      String type,
      String channel,
      String status,
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
class __$$NotificationModelImplCopyWithImpl<$Res>
    extends _$NotificationModelCopyWithImpl<$Res, _$NotificationModelImpl>
    implements _$$NotificationModelImplCopyWith<$Res> {
  __$$NotificationModelImplCopyWithImpl(_$NotificationModelImpl _value,
      $Res Function(_$NotificationModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationModel
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
    return _then(_$NotificationModelImpl(
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
              as String,
      channel: null == channel
          ? _value.channel
          : channel // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
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
class _$NotificationModelImpl implements _NotificationModel {
  const _$NotificationModelImpl(
      {required this.id,
      required this.userId,
      this.bookingId,
      this.chefId,
      required this.type,
      required this.channel,
      this.status = 'pending',
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

  factory _$NotificationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String? bookingId;
  @override
  final String? chefId;
  @override
  final String type;
  @override
  final String channel;
  @override
  @JsonKey()
  final String status;
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
    return 'NotificationModel(id: $id, userId: $userId, bookingId: $bookingId, chefId: $chefId, type: $type, channel: $channel, status: $status, title: $title, content: $content, data: $data, templateId: $templateId, scheduledAt: $scheduledAt, sentAt: $sentAt, deliveredAt: $deliveredAt, failedAt: $failedAt, failureReason: $failureReason, retryCount: $retryCount, maxRetries: $maxRetries, externalId: $externalId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationModelImpl &&
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

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationModelImplCopyWith<_$NotificationModelImpl> get copyWith =>
      __$$NotificationModelImplCopyWithImpl<_$NotificationModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationModelImplToJson(
      this,
    );
  }
}

abstract class _NotificationModel implements NotificationModel {
  const factory _NotificationModel(
      {required final String id,
      required final String userId,
      final String? bookingId,
      final String? chefId,
      required final String type,
      required final String channel,
      final String status,
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
      required final DateTime updatedAt}) = _$NotificationModelImpl;

  factory _NotificationModel.fromJson(Map<String, dynamic> json) =
      _$NotificationModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String? get bookingId;
  @override
  String? get chefId;
  @override
  String get type;
  @override
  String get channel;
  @override
  String get status;
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

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationModelImplCopyWith<_$NotificationModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NotificationPreferencesModel _$NotificationPreferencesModelFromJson(
    Map<String, dynamic> json) {
  return _NotificationPreferencesModel.fromJson(json);
}

/// @nodoc
mixin _$NotificationPreferencesModel {
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

  /// Serializes this NotificationPreferencesModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationPreferencesModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationPreferencesModelCopyWith<NotificationPreferencesModel>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationPreferencesModelCopyWith<$Res> {
  factory $NotificationPreferencesModelCopyWith(
          NotificationPreferencesModel value,
          $Res Function(NotificationPreferencesModel) then) =
      _$NotificationPreferencesModelCopyWithImpl<$Res,
          NotificationPreferencesModel>;
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
class _$NotificationPreferencesModelCopyWithImpl<$Res,
        $Val extends NotificationPreferencesModel>
    implements $NotificationPreferencesModelCopyWith<$Res> {
  _$NotificationPreferencesModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationPreferencesModel
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
abstract class _$$NotificationPreferencesModelImplCopyWith<$Res>
    implements $NotificationPreferencesModelCopyWith<$Res> {
  factory _$$NotificationPreferencesModelImplCopyWith(
          _$NotificationPreferencesModelImpl value,
          $Res Function(_$NotificationPreferencesModelImpl) then) =
      __$$NotificationPreferencesModelImplCopyWithImpl<$Res>;
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
class __$$NotificationPreferencesModelImplCopyWithImpl<$Res>
    extends _$NotificationPreferencesModelCopyWithImpl<$Res,
        _$NotificationPreferencesModelImpl>
    implements _$$NotificationPreferencesModelImplCopyWith<$Res> {
  __$$NotificationPreferencesModelImplCopyWithImpl(
      _$NotificationPreferencesModelImpl _value,
      $Res Function(_$NotificationPreferencesModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationPreferencesModel
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
    return _then(_$NotificationPreferencesModelImpl(
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
class _$NotificationPreferencesModelImpl
    implements _NotificationPreferencesModel {
  const _$NotificationPreferencesModelImpl(
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

  factory _$NotificationPreferencesModelImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$NotificationPreferencesModelImplFromJson(json);

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
    return 'NotificationPreferencesModel(id: $id, userId: $userId, emailEnabled: $emailEnabled, pushEnabled: $pushEnabled, inAppEnabled: $inAppEnabled, smsEnabled: $smsEnabled, bookingConfirmations: $bookingConfirmations, bookingReminders: $bookingReminders, bookingUpdates: $bookingUpdates, marketingEmails: $marketingEmails, languagePreference: $languagePreference, timezone: $timezone, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationPreferencesModelImpl &&
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

  /// Create a copy of NotificationPreferencesModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationPreferencesModelImplCopyWith<
          _$NotificationPreferencesModelImpl>
      get copyWith => __$$NotificationPreferencesModelImplCopyWithImpl<
          _$NotificationPreferencesModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationPreferencesModelImplToJson(
      this,
    );
  }
}

abstract class _NotificationPreferencesModel
    implements NotificationPreferencesModel {
  const factory _NotificationPreferencesModel(
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
      required final DateTime updatedAt}) = _$NotificationPreferencesModelImpl;

  factory _NotificationPreferencesModel.fromJson(Map<String, dynamic> json) =
      _$NotificationPreferencesModelImpl.fromJson;

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

  /// Create a copy of NotificationPreferencesModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationPreferencesModelImplCopyWith<
          _$NotificationPreferencesModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

DeviceTokenModel _$DeviceTokenModelFromJson(Map<String, dynamic> json) {
  return _DeviceTokenModel.fromJson(json);
}

/// @nodoc
mixin _$DeviceTokenModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get token => throw _privateConstructorUsedError;
  String get platform => throw _privateConstructorUsedError;
  String? get appVersion => throw _privateConstructorUsedError;
  String? get deviceId => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime get lastUsedAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this DeviceTokenModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DeviceTokenModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeviceTokenModelCopyWith<DeviceTokenModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeviceTokenModelCopyWith<$Res> {
  factory $DeviceTokenModelCopyWith(
          DeviceTokenModel value, $Res Function(DeviceTokenModel) then) =
      _$DeviceTokenModelCopyWithImpl<$Res, DeviceTokenModel>;
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
class _$DeviceTokenModelCopyWithImpl<$Res, $Val extends DeviceTokenModel>
    implements $DeviceTokenModelCopyWith<$Res> {
  _$DeviceTokenModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeviceTokenModel
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
abstract class _$$DeviceTokenModelImplCopyWith<$Res>
    implements $DeviceTokenModelCopyWith<$Res> {
  factory _$$DeviceTokenModelImplCopyWith(_$DeviceTokenModelImpl value,
          $Res Function(_$DeviceTokenModelImpl) then) =
      __$$DeviceTokenModelImplCopyWithImpl<$Res>;
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
class __$$DeviceTokenModelImplCopyWithImpl<$Res>
    extends _$DeviceTokenModelCopyWithImpl<$Res, _$DeviceTokenModelImpl>
    implements _$$DeviceTokenModelImplCopyWith<$Res> {
  __$$DeviceTokenModelImplCopyWithImpl(_$DeviceTokenModelImpl _value,
      $Res Function(_$DeviceTokenModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of DeviceTokenModel
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
    return _then(_$DeviceTokenModelImpl(
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
class _$DeviceTokenModelImpl implements _DeviceTokenModel {
  const _$DeviceTokenModelImpl(
      {required this.id,
      required this.userId,
      required this.token,
      required this.platform,
      this.appVersion,
      this.deviceId,
      this.isActive = true,
      required this.lastUsedAt,
      required this.createdAt});

  factory _$DeviceTokenModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeviceTokenModelImplFromJson(json);

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
    return 'DeviceTokenModel(id: $id, userId: $userId, token: $token, platform: $platform, appVersion: $appVersion, deviceId: $deviceId, isActive: $isActive, lastUsedAt: $lastUsedAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeviceTokenModelImpl &&
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

  /// Create a copy of DeviceTokenModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceTokenModelImplCopyWith<_$DeviceTokenModelImpl> get copyWith =>
      __$$DeviceTokenModelImplCopyWithImpl<_$DeviceTokenModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeviceTokenModelImplToJson(
      this,
    );
  }
}

abstract class _DeviceTokenModel implements DeviceTokenModel {
  const factory _DeviceTokenModel(
      {required final String id,
      required final String userId,
      required final String token,
      required final String platform,
      final String? appVersion,
      final String? deviceId,
      final bool isActive,
      required final DateTime lastUsedAt,
      required final DateTime createdAt}) = _$DeviceTokenModelImpl;

  factory _DeviceTokenModel.fromJson(Map<String, dynamic> json) =
      _$DeviceTokenModelImpl.fromJson;

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

  /// Create a copy of DeviceTokenModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeviceTokenModelImplCopyWith<_$DeviceTokenModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EmailTemplateModel _$EmailTemplateModelFromJson(Map<String, dynamic> json) {
  return _EmailTemplateModel.fromJson(json);
}

/// @nodoc
mixin _$EmailTemplateModel {
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

  /// Serializes this EmailTemplateModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EmailTemplateModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EmailTemplateModelCopyWith<EmailTemplateModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EmailTemplateModelCopyWith<$Res> {
  factory $EmailTemplateModelCopyWith(
          EmailTemplateModel value, $Res Function(EmailTemplateModel) then) =
      _$EmailTemplateModelCopyWithImpl<$Res, EmailTemplateModel>;
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
class _$EmailTemplateModelCopyWithImpl<$Res, $Val extends EmailTemplateModel>
    implements $EmailTemplateModelCopyWith<$Res> {
  _$EmailTemplateModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EmailTemplateModel
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
abstract class _$$EmailTemplateModelImplCopyWith<$Res>
    implements $EmailTemplateModelCopyWith<$Res> {
  factory _$$EmailTemplateModelImplCopyWith(_$EmailTemplateModelImpl value,
          $Res Function(_$EmailTemplateModelImpl) then) =
      __$$EmailTemplateModelImplCopyWithImpl<$Res>;
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
class __$$EmailTemplateModelImplCopyWithImpl<$Res>
    extends _$EmailTemplateModelCopyWithImpl<$Res, _$EmailTemplateModelImpl>
    implements _$$EmailTemplateModelImplCopyWith<$Res> {
  __$$EmailTemplateModelImplCopyWithImpl(_$EmailTemplateModelImpl _value,
      $Res Function(_$EmailTemplateModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of EmailTemplateModel
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
    return _then(_$EmailTemplateModelImpl(
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
class _$EmailTemplateModelImpl implements _EmailTemplateModel {
  const _$EmailTemplateModelImpl(
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

  factory _$EmailTemplateModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$EmailTemplateModelImplFromJson(json);

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
    return 'EmailTemplateModel(id: $id, templateKey: $templateKey, name: $name, description: $description, subjectDa: $subjectDa, subjectEn: $subjectEn, htmlContentDa: $htmlContentDa, htmlContentEn: $htmlContentEn, textContentDa: $textContentDa, textContentEn: $textContentEn, variables: $variables, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmailTemplateModelImpl &&
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

  /// Create a copy of EmailTemplateModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EmailTemplateModelImplCopyWith<_$EmailTemplateModelImpl> get copyWith =>
      __$$EmailTemplateModelImplCopyWithImpl<_$EmailTemplateModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EmailTemplateModelImplToJson(
      this,
    );
  }
}

abstract class _EmailTemplateModel implements EmailTemplateModel {
  const factory _EmailTemplateModel(
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
      required final DateTime updatedAt}) = _$EmailTemplateModelImpl;

  factory _EmailTemplateModel.fromJson(Map<String, dynamic> json) =
      _$EmailTemplateModelImpl.fromJson;

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

  /// Create a copy of EmailTemplateModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EmailTemplateModelImplCopyWith<_$EmailTemplateModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
