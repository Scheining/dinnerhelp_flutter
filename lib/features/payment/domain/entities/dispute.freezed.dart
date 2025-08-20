// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dispute.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Dispute {
  String get id => throw _privateConstructorUsedError;
  String get paymentIntentId => throw _privateConstructorUsedError;
  String get bookingId => throw _privateConstructorUsedError;
  int get amount => throw _privateConstructorUsedError; // in øre
  String get currency => throw _privateConstructorUsedError;
  DisputeStatus get status => throw _privateConstructorUsedError;
  DisputeReason get reason => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get evidenceDetails => throw _privateConstructorUsedError;
  DateTime? get respondByDate => throw _privateConstructorUsedError;
  DateTime? get resolvedAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Create a copy of Dispute
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DisputeCopyWith<Dispute> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DisputeCopyWith<$Res> {
  factory $DisputeCopyWith(Dispute value, $Res Function(Dispute) then) =
      _$DisputeCopyWithImpl<$Res, Dispute>;
  @useResult
  $Res call(
      {String id,
      String paymentIntentId,
      String bookingId,
      int amount,
      String currency,
      DisputeStatus status,
      DisputeReason reason,
      String? description,
      String? evidenceDetails,
      DateTime? respondByDate,
      DateTime? resolvedAt,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$DisputeCopyWithImpl<$Res, $Val extends Dispute>
    implements $DisputeCopyWith<$Res> {
  _$DisputeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Dispute
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? paymentIntentId = null,
    Object? bookingId = null,
    Object? amount = null,
    Object? currency = null,
    Object? status = null,
    Object? reason = null,
    Object? description = freezed,
    Object? evidenceDetails = freezed,
    Object? respondByDate = freezed,
    Object? resolvedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
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
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DisputeStatus,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as DisputeReason,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      evidenceDetails: freezed == evidenceDetails
          ? _value.evidenceDetails
          : evidenceDetails // ignore: cast_nullable_to_non_nullable
              as String?,
      respondByDate: freezed == respondByDate
          ? _value.respondByDate
          : respondByDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      resolvedAt: freezed == resolvedAt
          ? _value.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DisputeImplCopyWith<$Res> implements $DisputeCopyWith<$Res> {
  factory _$$DisputeImplCopyWith(
          _$DisputeImpl value, $Res Function(_$DisputeImpl) then) =
      __$$DisputeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String paymentIntentId,
      String bookingId,
      int amount,
      String currency,
      DisputeStatus status,
      DisputeReason reason,
      String? description,
      String? evidenceDetails,
      DateTime? respondByDate,
      DateTime? resolvedAt,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$DisputeImplCopyWithImpl<$Res>
    extends _$DisputeCopyWithImpl<$Res, _$DisputeImpl>
    implements _$$DisputeImplCopyWith<$Res> {
  __$$DisputeImplCopyWithImpl(
      _$DisputeImpl _value, $Res Function(_$DisputeImpl) _then)
      : super(_value, _then);

  /// Create a copy of Dispute
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? paymentIntentId = null,
    Object? bookingId = null,
    Object? amount = null,
    Object? currency = null,
    Object? status = null,
    Object? reason = null,
    Object? description = freezed,
    Object? evidenceDetails = freezed,
    Object? respondByDate = freezed,
    Object? resolvedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$DisputeImpl(
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
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DisputeStatus,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as DisputeReason,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      evidenceDetails: freezed == evidenceDetails
          ? _value.evidenceDetails
          : evidenceDetails // ignore: cast_nullable_to_non_nullable
              as String?,
      respondByDate: freezed == respondByDate
          ? _value.respondByDate
          : respondByDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      resolvedAt: freezed == resolvedAt
          ? _value.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$DisputeImpl implements _Dispute {
  const _$DisputeImpl(
      {required this.id,
      required this.paymentIntentId,
      required this.bookingId,
      required this.amount,
      required this.currency,
      required this.status,
      required this.reason,
      this.description,
      this.evidenceDetails,
      this.respondByDate,
      this.resolvedAt,
      required this.createdAt,
      this.updatedAt});

  @override
  final String id;
  @override
  final String paymentIntentId;
  @override
  final String bookingId;
  @override
  final int amount;
// in øre
  @override
  final String currency;
  @override
  final DisputeStatus status;
  @override
  final DisputeReason reason;
  @override
  final String? description;
  @override
  final String? evidenceDetails;
  @override
  final DateTime? respondByDate;
  @override
  final DateTime? resolvedAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Dispute(id: $id, paymentIntentId: $paymentIntentId, bookingId: $bookingId, amount: $amount, currency: $currency, status: $status, reason: $reason, description: $description, evidenceDetails: $evidenceDetails, respondByDate: $respondByDate, resolvedAt: $resolvedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DisputeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.paymentIntentId, paymentIntentId) ||
                other.paymentIntentId == paymentIntentId) &&
            (identical(other.bookingId, bookingId) ||
                other.bookingId == bookingId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.evidenceDetails, evidenceDetails) ||
                other.evidenceDetails == evidenceDetails) &&
            (identical(other.respondByDate, respondByDate) ||
                other.respondByDate == respondByDate) &&
            (identical(other.resolvedAt, resolvedAt) ||
                other.resolvedAt == resolvedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      paymentIntentId,
      bookingId,
      amount,
      currency,
      status,
      reason,
      description,
      evidenceDetails,
      respondByDate,
      resolvedAt,
      createdAt,
      updatedAt);

  /// Create a copy of Dispute
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DisputeImplCopyWith<_$DisputeImpl> get copyWith =>
      __$$DisputeImplCopyWithImpl<_$DisputeImpl>(this, _$identity);
}

abstract class _Dispute implements Dispute {
  const factory _Dispute(
      {required final String id,
      required final String paymentIntentId,
      required final String bookingId,
      required final int amount,
      required final String currency,
      required final DisputeStatus status,
      required final DisputeReason reason,
      final String? description,
      final String? evidenceDetails,
      final DateTime? respondByDate,
      final DateTime? resolvedAt,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$DisputeImpl;

  @override
  String get id;
  @override
  String get paymentIntentId;
  @override
  String get bookingId;
  @override
  int get amount; // in øre
  @override
  String get currency;
  @override
  DisputeStatus get status;
  @override
  DisputeReason get reason;
  @override
  String? get description;
  @override
  String? get evidenceDetails;
  @override
  DateTime? get respondByDate;
  @override
  DateTime? get resolvedAt;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of Dispute
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DisputeImplCopyWith<_$DisputeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
