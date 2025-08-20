// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_notification_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BookingNotificationData _$BookingNotificationDataFromJson(
    Map<String, dynamic> json) {
  return _BookingNotificationData.fromJson(json);
}

/// @nodoc
mixin _$BookingNotificationData {
  String get bookingId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get chefId => throw _privateConstructorUsedError;
  String get chefName => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  DateTime get dateTime => throw _privateConstructorUsedError;
  int get guestCount => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  int get durationHours => throw _privateConstructorUsedError;
  String? get userEmail => throw _privateConstructorUsedError;
  String? get userPhone => throw _privateConstructorUsedError;
  String? get chefEmail => throw _privateConstructorUsedError;
  String? get chefPhone => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  double? get totalAmount => throw _privateConstructorUsedError;
  String? get paymentStatus => throw _privateConstructorUsedError;
  List<String>? get dishNames => throw _privateConstructorUsedError;
  Map<String, dynamic>? get additionalData =>
      throw _privateConstructorUsedError;

  /// Serializes this BookingNotificationData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BookingNotificationData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BookingNotificationDataCopyWith<BookingNotificationData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookingNotificationDataCopyWith<$Res> {
  factory $BookingNotificationDataCopyWith(BookingNotificationData value,
          $Res Function(BookingNotificationData) then) =
      _$BookingNotificationDataCopyWithImpl<$Res, BookingNotificationData>;
  @useResult
  $Res call(
      {String bookingId,
      String userId,
      String chefId,
      String chefName,
      String userName,
      DateTime dateTime,
      int guestCount,
      String address,
      int durationHours,
      String? userEmail,
      String? userPhone,
      String? chefEmail,
      String? chefPhone,
      String? notes,
      double? totalAmount,
      String? paymentStatus,
      List<String>? dishNames,
      Map<String, dynamic>? additionalData});
}

/// @nodoc
class _$BookingNotificationDataCopyWithImpl<$Res,
        $Val extends BookingNotificationData>
    implements $BookingNotificationDataCopyWith<$Res> {
  _$BookingNotificationDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BookingNotificationData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bookingId = null,
    Object? userId = null,
    Object? chefId = null,
    Object? chefName = null,
    Object? userName = null,
    Object? dateTime = null,
    Object? guestCount = null,
    Object? address = null,
    Object? durationHours = null,
    Object? userEmail = freezed,
    Object? userPhone = freezed,
    Object? chefEmail = freezed,
    Object? chefPhone = freezed,
    Object? notes = freezed,
    Object? totalAmount = freezed,
    Object? paymentStatus = freezed,
    Object? dishNames = freezed,
    Object? additionalData = freezed,
  }) {
    return _then(_value.copyWith(
      bookingId: null == bookingId
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      chefId: null == chefId
          ? _value.chefId
          : chefId // ignore: cast_nullable_to_non_nullable
              as String,
      chefName: null == chefName
          ? _value.chefName
          : chefName // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      dateTime: null == dateTime
          ? _value.dateTime
          : dateTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      guestCount: null == guestCount
          ? _value.guestCount
          : guestCount // ignore: cast_nullable_to_non_nullable
              as int,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      durationHours: null == durationHours
          ? _value.durationHours
          : durationHours // ignore: cast_nullable_to_non_nullable
              as int,
      userEmail: freezed == userEmail
          ? _value.userEmail
          : userEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      userPhone: freezed == userPhone
          ? _value.userPhone
          : userPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      chefEmail: freezed == chefEmail
          ? _value.chefEmail
          : chefEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      chefPhone: freezed == chefPhone
          ? _value.chefPhone
          : chefPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      totalAmount: freezed == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      paymentStatus: freezed == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      dishNames: freezed == dishNames
          ? _value.dishNames
          : dishNames // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      additionalData: freezed == additionalData
          ? _value.additionalData
          : additionalData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BookingNotificationDataImplCopyWith<$Res>
    implements $BookingNotificationDataCopyWith<$Res> {
  factory _$$BookingNotificationDataImplCopyWith(
          _$BookingNotificationDataImpl value,
          $Res Function(_$BookingNotificationDataImpl) then) =
      __$$BookingNotificationDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String bookingId,
      String userId,
      String chefId,
      String chefName,
      String userName,
      DateTime dateTime,
      int guestCount,
      String address,
      int durationHours,
      String? userEmail,
      String? userPhone,
      String? chefEmail,
      String? chefPhone,
      String? notes,
      double? totalAmount,
      String? paymentStatus,
      List<String>? dishNames,
      Map<String, dynamic>? additionalData});
}

/// @nodoc
class __$$BookingNotificationDataImplCopyWithImpl<$Res>
    extends _$BookingNotificationDataCopyWithImpl<$Res,
        _$BookingNotificationDataImpl>
    implements _$$BookingNotificationDataImplCopyWith<$Res> {
  __$$BookingNotificationDataImplCopyWithImpl(
      _$BookingNotificationDataImpl _value,
      $Res Function(_$BookingNotificationDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of BookingNotificationData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bookingId = null,
    Object? userId = null,
    Object? chefId = null,
    Object? chefName = null,
    Object? userName = null,
    Object? dateTime = null,
    Object? guestCount = null,
    Object? address = null,
    Object? durationHours = null,
    Object? userEmail = freezed,
    Object? userPhone = freezed,
    Object? chefEmail = freezed,
    Object? chefPhone = freezed,
    Object? notes = freezed,
    Object? totalAmount = freezed,
    Object? paymentStatus = freezed,
    Object? dishNames = freezed,
    Object? additionalData = freezed,
  }) {
    return _then(_$BookingNotificationDataImpl(
      bookingId: null == bookingId
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      chefId: null == chefId
          ? _value.chefId
          : chefId // ignore: cast_nullable_to_non_nullable
              as String,
      chefName: null == chefName
          ? _value.chefName
          : chefName // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      dateTime: null == dateTime
          ? _value.dateTime
          : dateTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      guestCount: null == guestCount
          ? _value.guestCount
          : guestCount // ignore: cast_nullable_to_non_nullable
              as int,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      durationHours: null == durationHours
          ? _value.durationHours
          : durationHours // ignore: cast_nullable_to_non_nullable
              as int,
      userEmail: freezed == userEmail
          ? _value.userEmail
          : userEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      userPhone: freezed == userPhone
          ? _value.userPhone
          : userPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      chefEmail: freezed == chefEmail
          ? _value.chefEmail
          : chefEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      chefPhone: freezed == chefPhone
          ? _value.chefPhone
          : chefPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      totalAmount: freezed == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      paymentStatus: freezed == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      dishNames: freezed == dishNames
          ? _value._dishNames
          : dishNames // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      additionalData: freezed == additionalData
          ? _value._additionalData
          : additionalData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BookingNotificationDataImpl implements _BookingNotificationData {
  const _$BookingNotificationDataImpl(
      {required this.bookingId,
      required this.userId,
      required this.chefId,
      required this.chefName,
      required this.userName,
      required this.dateTime,
      required this.guestCount,
      required this.address,
      required this.durationHours,
      this.userEmail,
      this.userPhone,
      this.chefEmail,
      this.chefPhone,
      this.notes,
      this.totalAmount,
      this.paymentStatus,
      final List<String>? dishNames,
      final Map<String, dynamic>? additionalData})
      : _dishNames = dishNames,
        _additionalData = additionalData;

  factory _$BookingNotificationDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookingNotificationDataImplFromJson(json);

  @override
  final String bookingId;
  @override
  final String userId;
  @override
  final String chefId;
  @override
  final String chefName;
  @override
  final String userName;
  @override
  final DateTime dateTime;
  @override
  final int guestCount;
  @override
  final String address;
  @override
  final int durationHours;
  @override
  final String? userEmail;
  @override
  final String? userPhone;
  @override
  final String? chefEmail;
  @override
  final String? chefPhone;
  @override
  final String? notes;
  @override
  final double? totalAmount;
  @override
  final String? paymentStatus;
  final List<String>? _dishNames;
  @override
  List<String>? get dishNames {
    final value = _dishNames;
    if (value == null) return null;
    if (_dishNames is EqualUnmodifiableListView) return _dishNames;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final Map<String, dynamic>? _additionalData;
  @override
  Map<String, dynamic>? get additionalData {
    final value = _additionalData;
    if (value == null) return null;
    if (_additionalData is EqualUnmodifiableMapView) return _additionalData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'BookingNotificationData(bookingId: $bookingId, userId: $userId, chefId: $chefId, chefName: $chefName, userName: $userName, dateTime: $dateTime, guestCount: $guestCount, address: $address, durationHours: $durationHours, userEmail: $userEmail, userPhone: $userPhone, chefEmail: $chefEmail, chefPhone: $chefPhone, notes: $notes, totalAmount: $totalAmount, paymentStatus: $paymentStatus, dishNames: $dishNames, additionalData: $additionalData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookingNotificationDataImpl &&
            (identical(other.bookingId, bookingId) ||
                other.bookingId == bookingId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.chefId, chefId) || other.chefId == chefId) &&
            (identical(other.chefName, chefName) ||
                other.chefName == chefName) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.dateTime, dateTime) ||
                other.dateTime == dateTime) &&
            (identical(other.guestCount, guestCount) ||
                other.guestCount == guestCount) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.durationHours, durationHours) ||
                other.durationHours == durationHours) &&
            (identical(other.userEmail, userEmail) ||
                other.userEmail == userEmail) &&
            (identical(other.userPhone, userPhone) ||
                other.userPhone == userPhone) &&
            (identical(other.chefEmail, chefEmail) ||
                other.chefEmail == chefEmail) &&
            (identical(other.chefPhone, chefPhone) ||
                other.chefPhone == chefPhone) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            const DeepCollectionEquality()
                .equals(other._dishNames, _dishNames) &&
            const DeepCollectionEquality()
                .equals(other._additionalData, _additionalData));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      bookingId,
      userId,
      chefId,
      chefName,
      userName,
      dateTime,
      guestCount,
      address,
      durationHours,
      userEmail,
      userPhone,
      chefEmail,
      chefPhone,
      notes,
      totalAmount,
      paymentStatus,
      const DeepCollectionEquality().hash(_dishNames),
      const DeepCollectionEquality().hash(_additionalData));

  /// Create a copy of BookingNotificationData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BookingNotificationDataImplCopyWith<_$BookingNotificationDataImpl>
      get copyWith => __$$BookingNotificationDataImplCopyWithImpl<
          _$BookingNotificationDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookingNotificationDataImplToJson(
      this,
    );
  }
}

abstract class _BookingNotificationData implements BookingNotificationData {
  const factory _BookingNotificationData(
          {required final String bookingId,
          required final String userId,
          required final String chefId,
          required final String chefName,
          required final String userName,
          required final DateTime dateTime,
          required final int guestCount,
          required final String address,
          required final int durationHours,
          final String? userEmail,
          final String? userPhone,
          final String? chefEmail,
          final String? chefPhone,
          final String? notes,
          final double? totalAmount,
          final String? paymentStatus,
          final List<String>? dishNames,
          final Map<String, dynamic>? additionalData}) =
      _$BookingNotificationDataImpl;

  factory _BookingNotificationData.fromJson(Map<String, dynamic> json) =
      _$BookingNotificationDataImpl.fromJson;

  @override
  String get bookingId;
  @override
  String get userId;
  @override
  String get chefId;
  @override
  String get chefName;
  @override
  String get userName;
  @override
  DateTime get dateTime;
  @override
  int get guestCount;
  @override
  String get address;
  @override
  int get durationHours;
  @override
  String? get userEmail;
  @override
  String? get userPhone;
  @override
  String? get chefEmail;
  @override
  String? get chefPhone;
  @override
  String? get notes;
  @override
  double? get totalAmount;
  @override
  String? get paymentStatus;
  @override
  List<String>? get dishNames;
  @override
  Map<String, dynamic>? get additionalData;

  /// Create a copy of BookingNotificationData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookingNotificationDataImplCopyWith<_$BookingNotificationDataImpl>
      get copyWith => throw _privateConstructorUsedError;
}

NotificationTemplate _$NotificationTemplateFromJson(Map<String, dynamic> json) {
  return _NotificationTemplate.fromJson(json);
}

/// @nodoc
mixin _$NotificationTemplate {
  String get key => throw _privateConstructorUsedError;
  String get nameDa => throw _privateConstructorUsedError;
  String get nameEn => throw _privateConstructorUsedError;
  String get subjectDa => throw _privateConstructorUsedError;
  String get subjectEn => throw _privateConstructorUsedError;
  String get contentDa => throw _privateConstructorUsedError;
  String get contentEn => throw _privateConstructorUsedError;
  String? get htmlContentDa => throw _privateConstructorUsedError;
  String? get htmlContentEn => throw _privateConstructorUsedError;
  List<String> get requiredVariables => throw _privateConstructorUsedError;
  Map<String, String> get defaultValues => throw _privateConstructorUsedError;

  /// Serializes this NotificationTemplate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationTemplate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationTemplateCopyWith<NotificationTemplate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationTemplateCopyWith<$Res> {
  factory $NotificationTemplateCopyWith(NotificationTemplate value,
          $Res Function(NotificationTemplate) then) =
      _$NotificationTemplateCopyWithImpl<$Res, NotificationTemplate>;
  @useResult
  $Res call(
      {String key,
      String nameDa,
      String nameEn,
      String subjectDa,
      String subjectEn,
      String contentDa,
      String contentEn,
      String? htmlContentDa,
      String? htmlContentEn,
      List<String> requiredVariables,
      Map<String, String> defaultValues});
}

/// @nodoc
class _$NotificationTemplateCopyWithImpl<$Res,
        $Val extends NotificationTemplate>
    implements $NotificationTemplateCopyWith<$Res> {
  _$NotificationTemplateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationTemplate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? nameDa = null,
    Object? nameEn = null,
    Object? subjectDa = null,
    Object? subjectEn = null,
    Object? contentDa = null,
    Object? contentEn = null,
    Object? htmlContentDa = freezed,
    Object? htmlContentEn = freezed,
    Object? requiredVariables = null,
    Object? defaultValues = null,
  }) {
    return _then(_value.copyWith(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      nameDa: null == nameDa
          ? _value.nameDa
          : nameDa // ignore: cast_nullable_to_non_nullable
              as String,
      nameEn: null == nameEn
          ? _value.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String,
      subjectDa: null == subjectDa
          ? _value.subjectDa
          : subjectDa // ignore: cast_nullable_to_non_nullable
              as String,
      subjectEn: null == subjectEn
          ? _value.subjectEn
          : subjectEn // ignore: cast_nullable_to_non_nullable
              as String,
      contentDa: null == contentDa
          ? _value.contentDa
          : contentDa // ignore: cast_nullable_to_non_nullable
              as String,
      contentEn: null == contentEn
          ? _value.contentEn
          : contentEn // ignore: cast_nullable_to_non_nullable
              as String,
      htmlContentDa: freezed == htmlContentDa
          ? _value.htmlContentDa
          : htmlContentDa // ignore: cast_nullable_to_non_nullable
              as String?,
      htmlContentEn: freezed == htmlContentEn
          ? _value.htmlContentEn
          : htmlContentEn // ignore: cast_nullable_to_non_nullable
              as String?,
      requiredVariables: null == requiredVariables
          ? _value.requiredVariables
          : requiredVariables // ignore: cast_nullable_to_non_nullable
              as List<String>,
      defaultValues: null == defaultValues
          ? _value.defaultValues
          : defaultValues // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationTemplateImplCopyWith<$Res>
    implements $NotificationTemplateCopyWith<$Res> {
  factory _$$NotificationTemplateImplCopyWith(_$NotificationTemplateImpl value,
          $Res Function(_$NotificationTemplateImpl) then) =
      __$$NotificationTemplateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String key,
      String nameDa,
      String nameEn,
      String subjectDa,
      String subjectEn,
      String contentDa,
      String contentEn,
      String? htmlContentDa,
      String? htmlContentEn,
      List<String> requiredVariables,
      Map<String, String> defaultValues});
}

/// @nodoc
class __$$NotificationTemplateImplCopyWithImpl<$Res>
    extends _$NotificationTemplateCopyWithImpl<$Res, _$NotificationTemplateImpl>
    implements _$$NotificationTemplateImplCopyWith<$Res> {
  __$$NotificationTemplateImplCopyWithImpl(_$NotificationTemplateImpl _value,
      $Res Function(_$NotificationTemplateImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationTemplate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? nameDa = null,
    Object? nameEn = null,
    Object? subjectDa = null,
    Object? subjectEn = null,
    Object? contentDa = null,
    Object? contentEn = null,
    Object? htmlContentDa = freezed,
    Object? htmlContentEn = freezed,
    Object? requiredVariables = null,
    Object? defaultValues = null,
  }) {
    return _then(_$NotificationTemplateImpl(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      nameDa: null == nameDa
          ? _value.nameDa
          : nameDa // ignore: cast_nullable_to_non_nullable
              as String,
      nameEn: null == nameEn
          ? _value.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String,
      subjectDa: null == subjectDa
          ? _value.subjectDa
          : subjectDa // ignore: cast_nullable_to_non_nullable
              as String,
      subjectEn: null == subjectEn
          ? _value.subjectEn
          : subjectEn // ignore: cast_nullable_to_non_nullable
              as String,
      contentDa: null == contentDa
          ? _value.contentDa
          : contentDa // ignore: cast_nullable_to_non_nullable
              as String,
      contentEn: null == contentEn
          ? _value.contentEn
          : contentEn // ignore: cast_nullable_to_non_nullable
              as String,
      htmlContentDa: freezed == htmlContentDa
          ? _value.htmlContentDa
          : htmlContentDa // ignore: cast_nullable_to_non_nullable
              as String?,
      htmlContentEn: freezed == htmlContentEn
          ? _value.htmlContentEn
          : htmlContentEn // ignore: cast_nullable_to_non_nullable
              as String?,
      requiredVariables: null == requiredVariables
          ? _value._requiredVariables
          : requiredVariables // ignore: cast_nullable_to_non_nullable
              as List<String>,
      defaultValues: null == defaultValues
          ? _value._defaultValues
          : defaultValues // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationTemplateImpl implements _NotificationTemplate {
  const _$NotificationTemplateImpl(
      {required this.key,
      required this.nameDa,
      required this.nameEn,
      required this.subjectDa,
      required this.subjectEn,
      required this.contentDa,
      required this.contentEn,
      this.htmlContentDa,
      this.htmlContentEn,
      final List<String> requiredVariables = const [],
      final Map<String, String> defaultValues = const {}})
      : _requiredVariables = requiredVariables,
        _defaultValues = defaultValues;

  factory _$NotificationTemplateImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationTemplateImplFromJson(json);

  @override
  final String key;
  @override
  final String nameDa;
  @override
  final String nameEn;
  @override
  final String subjectDa;
  @override
  final String subjectEn;
  @override
  final String contentDa;
  @override
  final String contentEn;
  @override
  final String? htmlContentDa;
  @override
  final String? htmlContentEn;
  final List<String> _requiredVariables;
  @override
  @JsonKey()
  List<String> get requiredVariables {
    if (_requiredVariables is EqualUnmodifiableListView)
      return _requiredVariables;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_requiredVariables);
  }

  final Map<String, String> _defaultValues;
  @override
  @JsonKey()
  Map<String, String> get defaultValues {
    if (_defaultValues is EqualUnmodifiableMapView) return _defaultValues;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_defaultValues);
  }

  @override
  String toString() {
    return 'NotificationTemplate(key: $key, nameDa: $nameDa, nameEn: $nameEn, subjectDa: $subjectDa, subjectEn: $subjectEn, contentDa: $contentDa, contentEn: $contentEn, htmlContentDa: $htmlContentDa, htmlContentEn: $htmlContentEn, requiredVariables: $requiredVariables, defaultValues: $defaultValues)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationTemplateImpl &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.nameDa, nameDa) || other.nameDa == nameDa) &&
            (identical(other.nameEn, nameEn) || other.nameEn == nameEn) &&
            (identical(other.subjectDa, subjectDa) ||
                other.subjectDa == subjectDa) &&
            (identical(other.subjectEn, subjectEn) ||
                other.subjectEn == subjectEn) &&
            (identical(other.contentDa, contentDa) ||
                other.contentDa == contentDa) &&
            (identical(other.contentEn, contentEn) ||
                other.contentEn == contentEn) &&
            (identical(other.htmlContentDa, htmlContentDa) ||
                other.htmlContentDa == htmlContentDa) &&
            (identical(other.htmlContentEn, htmlContentEn) ||
                other.htmlContentEn == htmlContentEn) &&
            const DeepCollectionEquality()
                .equals(other._requiredVariables, _requiredVariables) &&
            const DeepCollectionEquality()
                .equals(other._defaultValues, _defaultValues));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      key,
      nameDa,
      nameEn,
      subjectDa,
      subjectEn,
      contentDa,
      contentEn,
      htmlContentDa,
      htmlContentEn,
      const DeepCollectionEquality().hash(_requiredVariables),
      const DeepCollectionEquality().hash(_defaultValues));

  /// Create a copy of NotificationTemplate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationTemplateImplCopyWith<_$NotificationTemplateImpl>
      get copyWith =>
          __$$NotificationTemplateImplCopyWithImpl<_$NotificationTemplateImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationTemplateImplToJson(
      this,
    );
  }
}

abstract class _NotificationTemplate implements NotificationTemplate {
  const factory _NotificationTemplate(
      {required final String key,
      required final String nameDa,
      required final String nameEn,
      required final String subjectDa,
      required final String subjectEn,
      required final String contentDa,
      required final String contentEn,
      final String? htmlContentDa,
      final String? htmlContentEn,
      final List<String> requiredVariables,
      final Map<String, String> defaultValues}) = _$NotificationTemplateImpl;

  factory _NotificationTemplate.fromJson(Map<String, dynamic> json) =
      _$NotificationTemplateImpl.fromJson;

  @override
  String get key;
  @override
  String get nameDa;
  @override
  String get nameEn;
  @override
  String get subjectDa;
  @override
  String get subjectEn;
  @override
  String get contentDa;
  @override
  String get contentEn;
  @override
  String? get htmlContentDa;
  @override
  String? get htmlContentEn;
  @override
  List<String> get requiredVariables;
  @override
  Map<String, String> get defaultValues;

  /// Create a copy of NotificationTemplate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationTemplateImplCopyWith<_$NotificationTemplateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
