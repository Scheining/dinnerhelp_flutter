// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'refund_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RefundModel _$RefundModelFromJson(Map<String, dynamic> json) {
  return _RefundModel.fromJson(json);
}

/// @nodoc
mixin _$RefundModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_intent_id')
  String get paymentIntentId => throw _privateConstructorUsedError;
  @JsonKey(name: 'booking_id')
  String get bookingId => throw _privateConstructorUsedError;
  int get amount => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  @JsonKey(name: 'status')
  String get statusString => throw _privateConstructorUsedError;
  @JsonKey(name: 'reason')
  String get reasonString => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'failure_reason')
  String? get failureReason => throw _privateConstructorUsedError;
  @JsonKey(name: 'processed_at')
  DateTime? get processedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this RefundModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RefundModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RefundModelCopyWith<RefundModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RefundModelCopyWith<$Res> {
  factory $RefundModelCopyWith(
          RefundModel value, $Res Function(RefundModel) then) =
      _$RefundModelCopyWithImpl<$Res, RefundModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'payment_intent_id') String paymentIntentId,
      @JsonKey(name: 'booking_id') String bookingId,
      int amount,
      String currency,
      @JsonKey(name: 'status') String statusString,
      @JsonKey(name: 'reason') String reasonString,
      String? description,
      @JsonKey(name: 'failure_reason') String? failureReason,
      @JsonKey(name: 'processed_at') DateTime? processedAt,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class _$RefundModelCopyWithImpl<$Res, $Val extends RefundModel>
    implements $RefundModelCopyWith<$Res> {
  _$RefundModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RefundModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? paymentIntentId = null,
    Object? bookingId = null,
    Object? amount = null,
    Object? currency = null,
    Object? statusString = null,
    Object? reasonString = null,
    Object? description = freezed,
    Object? failureReason = freezed,
    Object? processedAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      paymentIntentId: null == paymentIntentId
          ? _value.paymentIntentId
          : paymentIntentId // ignore: cast_nullable_to_non_nullable
              as String,
      bookingId: null == bookingId
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      statusString: null == statusString
          ? _value.statusString
          : statusString // ignore: cast_nullable_to_non_nullable
              as String,
      reasonString: null == reasonString
          ? _value.reasonString
          : reasonString // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      failureReason: freezed == failureReason
          ? _value.failureReason
          : failureReason // ignore: cast_nullable_to_non_nullable
              as String?,
      processedAt: freezed == processedAt
          ? _value.processedAt
          : processedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RefundModelImplCopyWith<$Res>
    implements $RefundModelCopyWith<$Res> {
  factory _$$RefundModelImplCopyWith(
          _$RefundModelImpl value, $Res Function(_$RefundModelImpl) then) =
      __$$RefundModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'payment_intent_id') String paymentIntentId,
      @JsonKey(name: 'booking_id') String bookingId,
      int amount,
      String currency,
      @JsonKey(name: 'status') String statusString,
      @JsonKey(name: 'reason') String reasonString,
      String? description,
      @JsonKey(name: 'failure_reason') String? failureReason,
      @JsonKey(name: 'processed_at') DateTime? processedAt,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class __$$RefundModelImplCopyWithImpl<$Res>
    extends _$RefundModelCopyWithImpl<$Res, _$RefundModelImpl>
    implements _$$RefundModelImplCopyWith<$Res> {
  __$$RefundModelImplCopyWithImpl(
      _$RefundModelImpl _value, $Res Function(_$RefundModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of RefundModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? paymentIntentId = null,
    Object? bookingId = null,
    Object? amount = null,
    Object? currency = null,
    Object? statusString = null,
    Object? reasonString = null,
    Object? description = freezed,
    Object? failureReason = freezed,
    Object? processedAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$RefundModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      paymentIntentId: null == paymentIntentId
          ? _value.paymentIntentId
          : paymentIntentId // ignore: cast_nullable_to_non_nullable
              as String,
      bookingId: null == bookingId
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      statusString: null == statusString
          ? _value.statusString
          : statusString // ignore: cast_nullable_to_non_nullable
              as String,
      reasonString: null == reasonString
          ? _value.reasonString
          : reasonString // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      failureReason: freezed == failureReason
          ? _value.failureReason
          : failureReason // ignore: cast_nullable_to_non_nullable
              as String?,
      processedAt: freezed == processedAt
          ? _value.processedAt
          : processedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RefundModelImpl extends _RefundModel {
  const _$RefundModelImpl(
      {required this.id,
      @JsonKey(name: 'payment_intent_id') required this.paymentIntentId,
      @JsonKey(name: 'booking_id') required this.bookingId,
      required this.amount,
      required this.currency,
      @JsonKey(name: 'status') required this.statusString,
      @JsonKey(name: 'reason') required this.reasonString,
      this.description,
      @JsonKey(name: 'failure_reason') this.failureReason,
      @JsonKey(name: 'processed_at') this.processedAt,
      @JsonKey(name: 'created_at') required this.createdAt})
      : super._();

  factory _$RefundModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$RefundModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'payment_intent_id')
  final String paymentIntentId;
  @override
  @JsonKey(name: 'booking_id')
  final String bookingId;
  @override
  final int amount;
  @override
  final String currency;
  @override
  @JsonKey(name: 'status')
  final String statusString;
  @override
  @JsonKey(name: 'reason')
  final String reasonString;
  @override
  final String? description;
  @override
  @JsonKey(name: 'failure_reason')
  final String? failureReason;
  @override
  @JsonKey(name: 'processed_at')
  final DateTime? processedAt;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'RefundModel(id: $id, paymentIntentId: $paymentIntentId, bookingId: $bookingId, amount: $amount, currency: $currency, statusString: $statusString, reasonString: $reasonString, description: $description, failureReason: $failureReason, processedAt: $processedAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RefundModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.paymentIntentId, paymentIntentId) ||
                other.paymentIntentId == paymentIntentId) &&
            (identical(other.bookingId, bookingId) ||
                other.bookingId == bookingId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.statusString, statusString) ||
                other.statusString == statusString) &&
            (identical(other.reasonString, reasonString) ||
                other.reasonString == reasonString) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.failureReason, failureReason) ||
                other.failureReason == failureReason) &&
            (identical(other.processedAt, processedAt) ||
                other.processedAt == processedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      paymentIntentId,
      bookingId,
      amount,
      currency,
      statusString,
      reasonString,
      description,
      failureReason,
      processedAt,
      createdAt);

  /// Create a copy of RefundModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RefundModelImplCopyWith<_$RefundModelImpl> get copyWith =>
      __$$RefundModelImplCopyWithImpl<_$RefundModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RefundModelImplToJson(
      this,
    );
  }
}

abstract class _RefundModel extends RefundModel {
  const factory _RefundModel(
      {required final String id,
      @JsonKey(name: 'payment_intent_id') required final String paymentIntentId,
      @JsonKey(name: 'booking_id') required final String bookingId,
      required final int amount,
      required final String currency,
      @JsonKey(name: 'status') required final String statusString,
      @JsonKey(name: 'reason') required final String reasonString,
      final String? description,
      @JsonKey(name: 'failure_reason') final String? failureReason,
      @JsonKey(name: 'processed_at') final DateTime? processedAt,
      @JsonKey(name: 'created_at')
      required final DateTime createdAt}) = _$RefundModelImpl;
  const _RefundModel._() : super._();

  factory _RefundModel.fromJson(Map<String, dynamic> json) =
      _$RefundModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'payment_intent_id')
  String get paymentIntentId;
  @override
  @JsonKey(name: 'booking_id')
  String get bookingId;
  @override
  int get amount;
  @override
  String get currency;
  @override
  @JsonKey(name: 'status')
  String get statusString;
  @override
  @JsonKey(name: 'reason')
  String get reasonString;
  @override
  String? get description;
  @override
  @JsonKey(name: 'failure_reason')
  String? get failureReason;
  @override
  @JsonKey(name: 'processed_at')
  DateTime? get processedAt;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of RefundModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RefundModelImplCopyWith<_$RefundModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
