// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_intent_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PaymentIntentModel _$PaymentIntentModelFromJson(Map<String, dynamic> json) {
  return _PaymentIntentModel.fromJson(json);
}

/// @nodoc
mixin _$PaymentIntentModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'booking_id')
  String get bookingId => throw _privateConstructorUsedError;
  @JsonKey(name: 'chef_stripe_account_id')
  String get chefStripeAccountId => throw _privateConstructorUsedError;
  int get amount => throw _privateConstructorUsedError;
  @JsonKey(name: 'service_fee_amount')
  int get serviceFeeAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'vat_amount')
  int get vatAmount => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  @JsonKey(name: 'status')
  String get statusString => throw _privateConstructorUsedError;
  @JsonKey(name: 'capture_method')
  String get captureMethodString => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_method_id')
  String? get paymentMethodId => throw _privateConstructorUsedError;
  @JsonKey(name: 'client_secret')
  String? get clientSecret => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_payment_error')
  String? get lastPaymentError => throw _privateConstructorUsedError;
  @JsonKey(name: 'authorized_at')
  DateTime? get authorizedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'captured_at')
  DateTime? get capturedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'cancelled_at')
  DateTime? get cancelledAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this PaymentIntentModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PaymentIntentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaymentIntentModelCopyWith<PaymentIntentModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentIntentModelCopyWith<$Res> {
  factory $PaymentIntentModelCopyWith(
          PaymentIntentModel value, $Res Function(PaymentIntentModel) then) =
      _$PaymentIntentModelCopyWithImpl<$Res, PaymentIntentModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'booking_id') String bookingId,
      @JsonKey(name: 'chef_stripe_account_id') String chefStripeAccountId,
      int amount,
      @JsonKey(name: 'service_fee_amount') int serviceFeeAmount,
      @JsonKey(name: 'vat_amount') int vatAmount,
      String currency,
      @JsonKey(name: 'status') String statusString,
      @JsonKey(name: 'capture_method') String captureMethodString,
      @JsonKey(name: 'payment_method_id') String? paymentMethodId,
      @JsonKey(name: 'client_secret') String? clientSecret,
      @JsonKey(name: 'last_payment_error') String? lastPaymentError,
      @JsonKey(name: 'authorized_at') DateTime? authorizedAt,
      @JsonKey(name: 'captured_at') DateTime? capturedAt,
      @JsonKey(name: 'cancelled_at') DateTime? cancelledAt,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$PaymentIntentModelCopyWithImpl<$Res, $Val extends PaymentIntentModel>
    implements $PaymentIntentModelCopyWith<$Res> {
  _$PaymentIntentModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaymentIntentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bookingId = null,
    Object? chefStripeAccountId = null,
    Object? amount = null,
    Object? serviceFeeAmount = null,
    Object? vatAmount = null,
    Object? currency = null,
    Object? statusString = null,
    Object? captureMethodString = null,
    Object? paymentMethodId = freezed,
    Object? clientSecret = freezed,
    Object? lastPaymentError = freezed,
    Object? authorizedAt = freezed,
    Object? capturedAt = freezed,
    Object? cancelledAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
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
      chefStripeAccountId: null == chefStripeAccountId
          ? _value.chefStripeAccountId
          : chefStripeAccountId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
      serviceFeeAmount: null == serviceFeeAmount
          ? _value.serviceFeeAmount
          : serviceFeeAmount // ignore: cast_nullable_to_non_nullable
              as int,
      vatAmount: null == vatAmount
          ? _value.vatAmount
          : vatAmount // ignore: cast_nullable_to_non_nullable
              as int,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      statusString: null == statusString
          ? _value.statusString
          : statusString // ignore: cast_nullable_to_non_nullable
              as String,
      captureMethodString: null == captureMethodString
          ? _value.captureMethodString
          : captureMethodString // ignore: cast_nullable_to_non_nullable
              as String,
      paymentMethodId: freezed == paymentMethodId
          ? _value.paymentMethodId
          : paymentMethodId // ignore: cast_nullable_to_non_nullable
              as String?,
      clientSecret: freezed == clientSecret
          ? _value.clientSecret
          : clientSecret // ignore: cast_nullable_to_non_nullable
              as String?,
      lastPaymentError: freezed == lastPaymentError
          ? _value.lastPaymentError
          : lastPaymentError // ignore: cast_nullable_to_non_nullable
              as String?,
      authorizedAt: freezed == authorizedAt
          ? _value.authorizedAt
          : authorizedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      capturedAt: freezed == capturedAt
          ? _value.capturedAt
          : capturedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cancelledAt: freezed == cancelledAt
          ? _value.cancelledAt
          : cancelledAt // ignore: cast_nullable_to_non_nullable
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
abstract class _$$PaymentIntentModelImplCopyWith<$Res>
    implements $PaymentIntentModelCopyWith<$Res> {
  factory _$$PaymentIntentModelImplCopyWith(_$PaymentIntentModelImpl value,
          $Res Function(_$PaymentIntentModelImpl) then) =
      __$$PaymentIntentModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'booking_id') String bookingId,
      @JsonKey(name: 'chef_stripe_account_id') String chefStripeAccountId,
      int amount,
      @JsonKey(name: 'service_fee_amount') int serviceFeeAmount,
      @JsonKey(name: 'vat_amount') int vatAmount,
      String currency,
      @JsonKey(name: 'status') String statusString,
      @JsonKey(name: 'capture_method') String captureMethodString,
      @JsonKey(name: 'payment_method_id') String? paymentMethodId,
      @JsonKey(name: 'client_secret') String? clientSecret,
      @JsonKey(name: 'last_payment_error') String? lastPaymentError,
      @JsonKey(name: 'authorized_at') DateTime? authorizedAt,
      @JsonKey(name: 'captured_at') DateTime? capturedAt,
      @JsonKey(name: 'cancelled_at') DateTime? cancelledAt,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$$PaymentIntentModelImplCopyWithImpl<$Res>
    extends _$PaymentIntentModelCopyWithImpl<$Res, _$PaymentIntentModelImpl>
    implements _$$PaymentIntentModelImplCopyWith<$Res> {
  __$$PaymentIntentModelImplCopyWithImpl(_$PaymentIntentModelImpl _value,
      $Res Function(_$PaymentIntentModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of PaymentIntentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bookingId = null,
    Object? chefStripeAccountId = null,
    Object? amount = null,
    Object? serviceFeeAmount = null,
    Object? vatAmount = null,
    Object? currency = null,
    Object? statusString = null,
    Object? captureMethodString = null,
    Object? paymentMethodId = freezed,
    Object? clientSecret = freezed,
    Object? lastPaymentError = freezed,
    Object? authorizedAt = freezed,
    Object? capturedAt = freezed,
    Object? cancelledAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$PaymentIntentModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      bookingId: null == bookingId
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String,
      chefStripeAccountId: null == chefStripeAccountId
          ? _value.chefStripeAccountId
          : chefStripeAccountId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int,
      serviceFeeAmount: null == serviceFeeAmount
          ? _value.serviceFeeAmount
          : serviceFeeAmount // ignore: cast_nullable_to_non_nullable
              as int,
      vatAmount: null == vatAmount
          ? _value.vatAmount
          : vatAmount // ignore: cast_nullable_to_non_nullable
              as int,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      statusString: null == statusString
          ? _value.statusString
          : statusString // ignore: cast_nullable_to_non_nullable
              as String,
      captureMethodString: null == captureMethodString
          ? _value.captureMethodString
          : captureMethodString // ignore: cast_nullable_to_non_nullable
              as String,
      paymentMethodId: freezed == paymentMethodId
          ? _value.paymentMethodId
          : paymentMethodId // ignore: cast_nullable_to_non_nullable
              as String?,
      clientSecret: freezed == clientSecret
          ? _value.clientSecret
          : clientSecret // ignore: cast_nullable_to_non_nullable
              as String?,
      lastPaymentError: freezed == lastPaymentError
          ? _value.lastPaymentError
          : lastPaymentError // ignore: cast_nullable_to_non_nullable
              as String?,
      authorizedAt: freezed == authorizedAt
          ? _value.authorizedAt
          : authorizedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      capturedAt: freezed == capturedAt
          ? _value.capturedAt
          : capturedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cancelledAt: freezed == cancelledAt
          ? _value.cancelledAt
          : cancelledAt // ignore: cast_nullable_to_non_nullable
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
class _$PaymentIntentModelImpl extends _PaymentIntentModel {
  const _$PaymentIntentModelImpl(
      {required this.id,
      @JsonKey(name: 'booking_id') required this.bookingId,
      @JsonKey(name: 'chef_stripe_account_id')
      required this.chefStripeAccountId,
      required this.amount,
      @JsonKey(name: 'service_fee_amount') required this.serviceFeeAmount,
      @JsonKey(name: 'vat_amount') required this.vatAmount,
      required this.currency,
      @JsonKey(name: 'status') required this.statusString,
      @JsonKey(name: 'capture_method') required this.captureMethodString,
      @JsonKey(name: 'payment_method_id') this.paymentMethodId,
      @JsonKey(name: 'client_secret') this.clientSecret,
      @JsonKey(name: 'last_payment_error') this.lastPaymentError,
      @JsonKey(name: 'authorized_at') this.authorizedAt,
      @JsonKey(name: 'captured_at') this.capturedAt,
      @JsonKey(name: 'cancelled_at') this.cancelledAt,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt})
      : super._();

  factory _$PaymentIntentModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaymentIntentModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'booking_id')
  final String bookingId;
  @override
  @JsonKey(name: 'chef_stripe_account_id')
  final String chefStripeAccountId;
  @override
  final int amount;
  @override
  @JsonKey(name: 'service_fee_amount')
  final int serviceFeeAmount;
  @override
  @JsonKey(name: 'vat_amount')
  final int vatAmount;
  @override
  final String currency;
  @override
  @JsonKey(name: 'status')
  final String statusString;
  @override
  @JsonKey(name: 'capture_method')
  final String captureMethodString;
  @override
  @JsonKey(name: 'payment_method_id')
  final String? paymentMethodId;
  @override
  @JsonKey(name: 'client_secret')
  final String? clientSecret;
  @override
  @JsonKey(name: 'last_payment_error')
  final String? lastPaymentError;
  @override
  @JsonKey(name: 'authorized_at')
  final DateTime? authorizedAt;
  @override
  @JsonKey(name: 'captured_at')
  final DateTime? capturedAt;
  @override
  @JsonKey(name: 'cancelled_at')
  final DateTime? cancelledAt;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'PaymentIntentModel(id: $id, bookingId: $bookingId, chefStripeAccountId: $chefStripeAccountId, amount: $amount, serviceFeeAmount: $serviceFeeAmount, vatAmount: $vatAmount, currency: $currency, statusString: $statusString, captureMethodString: $captureMethodString, paymentMethodId: $paymentMethodId, clientSecret: $clientSecret, lastPaymentError: $lastPaymentError, authorizedAt: $authorizedAt, capturedAt: $capturedAt, cancelledAt: $cancelledAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentIntentModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.bookingId, bookingId) ||
                other.bookingId == bookingId) &&
            (identical(other.chefStripeAccountId, chefStripeAccountId) ||
                other.chefStripeAccountId == chefStripeAccountId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.serviceFeeAmount, serviceFeeAmount) ||
                other.serviceFeeAmount == serviceFeeAmount) &&
            (identical(other.vatAmount, vatAmount) ||
                other.vatAmount == vatAmount) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.statusString, statusString) ||
                other.statusString == statusString) &&
            (identical(other.captureMethodString, captureMethodString) ||
                other.captureMethodString == captureMethodString) &&
            (identical(other.paymentMethodId, paymentMethodId) ||
                other.paymentMethodId == paymentMethodId) &&
            (identical(other.clientSecret, clientSecret) ||
                other.clientSecret == clientSecret) &&
            (identical(other.lastPaymentError, lastPaymentError) ||
                other.lastPaymentError == lastPaymentError) &&
            (identical(other.authorizedAt, authorizedAt) ||
                other.authorizedAt == authorizedAt) &&
            (identical(other.capturedAt, capturedAt) ||
                other.capturedAt == capturedAt) &&
            (identical(other.cancelledAt, cancelledAt) ||
                other.cancelledAt == cancelledAt) &&
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
      bookingId,
      chefStripeAccountId,
      amount,
      serviceFeeAmount,
      vatAmount,
      currency,
      statusString,
      captureMethodString,
      paymentMethodId,
      clientSecret,
      lastPaymentError,
      authorizedAt,
      capturedAt,
      cancelledAt,
      createdAt,
      updatedAt);

  /// Create a copy of PaymentIntentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentIntentModelImplCopyWith<_$PaymentIntentModelImpl> get copyWith =>
      __$$PaymentIntentModelImplCopyWithImpl<_$PaymentIntentModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PaymentIntentModelImplToJson(
      this,
    );
  }
}

abstract class _PaymentIntentModel extends PaymentIntentModel {
  const factory _PaymentIntentModel(
      {required final String id,
      @JsonKey(name: 'booking_id') required final String bookingId,
      @JsonKey(name: 'chef_stripe_account_id')
      required final String chefStripeAccountId,
      required final int amount,
      @JsonKey(name: 'service_fee_amount') required final int serviceFeeAmount,
      @JsonKey(name: 'vat_amount') required final int vatAmount,
      required final String currency,
      @JsonKey(name: 'status') required final String statusString,
      @JsonKey(name: 'capture_method')
      required final String captureMethodString,
      @JsonKey(name: 'payment_method_id') final String? paymentMethodId,
      @JsonKey(name: 'client_secret') final String? clientSecret,
      @JsonKey(name: 'last_payment_error') final String? lastPaymentError,
      @JsonKey(name: 'authorized_at') final DateTime? authorizedAt,
      @JsonKey(name: 'captured_at') final DateTime? capturedAt,
      @JsonKey(name: 'cancelled_at') final DateTime? cancelledAt,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'updated_at')
      final DateTime? updatedAt}) = _$PaymentIntentModelImpl;
  const _PaymentIntentModel._() : super._();

  factory _PaymentIntentModel.fromJson(Map<String, dynamic> json) =
      _$PaymentIntentModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'booking_id')
  String get bookingId;
  @override
  @JsonKey(name: 'chef_stripe_account_id')
  String get chefStripeAccountId;
  @override
  int get amount;
  @override
  @JsonKey(name: 'service_fee_amount')
  int get serviceFeeAmount;
  @override
  @JsonKey(name: 'vat_amount')
  int get vatAmount;
  @override
  String get currency;
  @override
  @JsonKey(name: 'status')
  String get statusString;
  @override
  @JsonKey(name: 'capture_method')
  String get captureMethodString;
  @override
  @JsonKey(name: 'payment_method_id')
  String? get paymentMethodId;
  @override
  @JsonKey(name: 'client_secret')
  String? get clientSecret;
  @override
  @JsonKey(name: 'last_payment_error')
  String? get lastPaymentError;
  @override
  @JsonKey(name: 'authorized_at')
  DateTime? get authorizedAt;
  @override
  @JsonKey(name: 'captured_at')
  DateTime? get capturedAt;
  @override
  @JsonKey(name: 'cancelled_at')
  DateTime? get cancelledAt;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of PaymentIntentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentIntentModelImplCopyWith<_$PaymentIntentModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
