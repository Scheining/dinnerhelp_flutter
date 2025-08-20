// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dispute_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DisputeModel _$DisputeModelFromJson(Map<String, dynamic> json) {
  return _DisputeModel.fromJson(json);
}

/// @nodoc
mixin _$DisputeModel {
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
  @JsonKey(name: 'evidence_details')
  String? get evidenceDetails => throw _privateConstructorUsedError;
  @JsonKey(name: 'respond_by_date')
  DateTime? get respondByDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'resolved_at')
  DateTime? get resolvedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this DisputeModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DisputeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DisputeModelCopyWith<DisputeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DisputeModelCopyWith<$Res> {
  factory $DisputeModelCopyWith(
          DisputeModel value, $Res Function(DisputeModel) then) =
      _$DisputeModelCopyWithImpl<$Res, DisputeModel>;
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
      @JsonKey(name: 'evidence_details') String? evidenceDetails,
      @JsonKey(name: 'respond_by_date') DateTime? respondByDate,
      @JsonKey(name: 'resolved_at') DateTime? resolvedAt,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$DisputeModelCopyWithImpl<$Res, $Val extends DisputeModel>
    implements $DisputeModelCopyWith<$Res> {
  _$DisputeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DisputeModel
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
abstract class _$$DisputeModelImplCopyWith<$Res>
    implements $DisputeModelCopyWith<$Res> {
  factory _$$DisputeModelImplCopyWith(
          _$DisputeModelImpl value, $Res Function(_$DisputeModelImpl) then) =
      __$$DisputeModelImplCopyWithImpl<$Res>;
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
      @JsonKey(name: 'evidence_details') String? evidenceDetails,
      @JsonKey(name: 'respond_by_date') DateTime? respondByDate,
      @JsonKey(name: 'resolved_at') DateTime? resolvedAt,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$$DisputeModelImplCopyWithImpl<$Res>
    extends _$DisputeModelCopyWithImpl<$Res, _$DisputeModelImpl>
    implements _$$DisputeModelImplCopyWith<$Res> {
  __$$DisputeModelImplCopyWithImpl(
      _$DisputeModelImpl _value, $Res Function(_$DisputeModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of DisputeModel
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
    Object? evidenceDetails = freezed,
    Object? respondByDate = freezed,
    Object? resolvedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$DisputeModelImpl(
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
@JsonSerializable()
class _$DisputeModelImpl extends _DisputeModel {
  const _$DisputeModelImpl(
      {required this.id,
      @JsonKey(name: 'payment_intent_id') required this.paymentIntentId,
      @JsonKey(name: 'booking_id') required this.bookingId,
      required this.amount,
      required this.currency,
      @JsonKey(name: 'status') required this.statusString,
      @JsonKey(name: 'reason') required this.reasonString,
      this.description,
      @JsonKey(name: 'evidence_details') this.evidenceDetails,
      @JsonKey(name: 'respond_by_date') this.respondByDate,
      @JsonKey(name: 'resolved_at') this.resolvedAt,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt})
      : super._();

  factory _$DisputeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DisputeModelImplFromJson(json);

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
  @JsonKey(name: 'evidence_details')
  final String? evidenceDetails;
  @override
  @JsonKey(name: 'respond_by_date')
  final DateTime? respondByDate;
  @override
  @JsonKey(name: 'resolved_at')
  final DateTime? resolvedAt;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'DisputeModel(id: $id, paymentIntentId: $paymentIntentId, bookingId: $bookingId, amount: $amount, currency: $currency, statusString: $statusString, reasonString: $reasonString, description: $description, evidenceDetails: $evidenceDetails, respondByDate: $respondByDate, resolvedAt: $resolvedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DisputeModelImpl &&
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
      evidenceDetails,
      respondByDate,
      resolvedAt,
      createdAt,
      updatedAt);

  /// Create a copy of DisputeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DisputeModelImplCopyWith<_$DisputeModelImpl> get copyWith =>
      __$$DisputeModelImplCopyWithImpl<_$DisputeModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DisputeModelImplToJson(
      this,
    );
  }
}

abstract class _DisputeModel extends DisputeModel {
  const factory _DisputeModel(
      {required final String id,
      @JsonKey(name: 'payment_intent_id') required final String paymentIntentId,
      @JsonKey(name: 'booking_id') required final String bookingId,
      required final int amount,
      required final String currency,
      @JsonKey(name: 'status') required final String statusString,
      @JsonKey(name: 'reason') required final String reasonString,
      final String? description,
      @JsonKey(name: 'evidence_details') final String? evidenceDetails,
      @JsonKey(name: 'respond_by_date') final DateTime? respondByDate,
      @JsonKey(name: 'resolved_at') final DateTime? resolvedAt,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'updated_at')
      final DateTime? updatedAt}) = _$DisputeModelImpl;
  const _DisputeModel._() : super._();

  factory _DisputeModel.fromJson(Map<String, dynamic> json) =
      _$DisputeModelImpl.fromJson;

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
  @JsonKey(name: 'evidence_details')
  String? get evidenceDetails;
  @override
  @JsonKey(name: 'respond_by_date')
  DateTime? get respondByDate;
  @override
  @JsonKey(name: 'resolved_at')
  DateTime? get resolvedAt;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of DisputeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DisputeModelImplCopyWith<_$DisputeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
