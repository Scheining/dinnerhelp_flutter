// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_intent.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PaymentIntent {
  String get id => throw _privateConstructorUsedError;
  String get bookingId => throw _privateConstructorUsedError;
  String get chefStripeAccountId => throw _privateConstructorUsedError;
  int get amount => throw _privateConstructorUsedError; // in øre (Danish cents)
  int get serviceFeeAmount => throw _privateConstructorUsedError;
  int get vatAmount => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  PaymentIntentStatus get status => throw _privateConstructorUsedError;
  PaymentIntentCaptureMethod get captureMethod =>
      throw _privateConstructorUsedError;
  String? get paymentMethodId => throw _privateConstructorUsedError;
  String? get clientSecret => throw _privateConstructorUsedError;
  String? get lastPaymentError => throw _privateConstructorUsedError;
  DateTime? get authorizedAt => throw _privateConstructorUsedError;
  DateTime? get capturedAt => throw _privateConstructorUsedError;
  DateTime? get cancelledAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Create a copy of PaymentIntent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaymentIntentCopyWith<PaymentIntent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentIntentCopyWith<$Res> {
  factory $PaymentIntentCopyWith(
          PaymentIntent value, $Res Function(PaymentIntent) then) =
      _$PaymentIntentCopyWithImpl<$Res, PaymentIntent>;
  @useResult
  $Res call(
      {String id,
      String bookingId,
      String chefStripeAccountId,
      int amount,
      int serviceFeeAmount,
      int vatAmount,
      String currency,
      PaymentIntentStatus status,
      PaymentIntentCaptureMethod captureMethod,
      String? paymentMethodId,
      String? clientSecret,
      String? lastPaymentError,
      DateTime? authorizedAt,
      DateTime? capturedAt,
      DateTime? cancelledAt,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$PaymentIntentCopyWithImpl<$Res, $Val extends PaymentIntent>
    implements $PaymentIntentCopyWith<$Res> {
  _$PaymentIntentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaymentIntent
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
    Object? status = null,
    Object? captureMethod = null,
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
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as PaymentIntentStatus,
      captureMethod: null == captureMethod
          ? _value.captureMethod
          : captureMethod // ignore: cast_nullable_to_non_nullable
              as PaymentIntentCaptureMethod,
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
abstract class _$$PaymentIntentImplCopyWith<$Res>
    implements $PaymentIntentCopyWith<$Res> {
  factory _$$PaymentIntentImplCopyWith(
          _$PaymentIntentImpl value, $Res Function(_$PaymentIntentImpl) then) =
      __$$PaymentIntentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String bookingId,
      String chefStripeAccountId,
      int amount,
      int serviceFeeAmount,
      int vatAmount,
      String currency,
      PaymentIntentStatus status,
      PaymentIntentCaptureMethod captureMethod,
      String? paymentMethodId,
      String? clientSecret,
      String? lastPaymentError,
      DateTime? authorizedAt,
      DateTime? capturedAt,
      DateTime? cancelledAt,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$PaymentIntentImplCopyWithImpl<$Res>
    extends _$PaymentIntentCopyWithImpl<$Res, _$PaymentIntentImpl>
    implements _$$PaymentIntentImplCopyWith<$Res> {
  __$$PaymentIntentImplCopyWithImpl(
      _$PaymentIntentImpl _value, $Res Function(_$PaymentIntentImpl) _then)
      : super(_value, _then);

  /// Create a copy of PaymentIntent
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
    Object? status = null,
    Object? captureMethod = null,
    Object? paymentMethodId = freezed,
    Object? clientSecret = freezed,
    Object? lastPaymentError = freezed,
    Object? authorizedAt = freezed,
    Object? capturedAt = freezed,
    Object? cancelledAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$PaymentIntentImpl(
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
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as PaymentIntentStatus,
      captureMethod: null == captureMethod
          ? _value.captureMethod
          : captureMethod // ignore: cast_nullable_to_non_nullable
              as PaymentIntentCaptureMethod,
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

class _$PaymentIntentImpl implements _PaymentIntent {
  const _$PaymentIntentImpl(
      {required this.id,
      required this.bookingId,
      required this.chefStripeAccountId,
      required this.amount,
      required this.serviceFeeAmount,
      required this.vatAmount,
      required this.currency,
      required this.status,
      required this.captureMethod,
      this.paymentMethodId,
      this.clientSecret,
      this.lastPaymentError,
      this.authorizedAt,
      this.capturedAt,
      this.cancelledAt,
      required this.createdAt,
      this.updatedAt});

  @override
  final String id;
  @override
  final String bookingId;
  @override
  final String chefStripeAccountId;
  @override
  final int amount;
// in øre (Danish cents)
  @override
  final int serviceFeeAmount;
  @override
  final int vatAmount;
  @override
  final String currency;
  @override
  final PaymentIntentStatus status;
  @override
  final PaymentIntentCaptureMethod captureMethod;
  @override
  final String? paymentMethodId;
  @override
  final String? clientSecret;
  @override
  final String? lastPaymentError;
  @override
  final DateTime? authorizedAt;
  @override
  final DateTime? capturedAt;
  @override
  final DateTime? cancelledAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'PaymentIntent(id: $id, bookingId: $bookingId, chefStripeAccountId: $chefStripeAccountId, amount: $amount, serviceFeeAmount: $serviceFeeAmount, vatAmount: $vatAmount, currency: $currency, status: $status, captureMethod: $captureMethod, paymentMethodId: $paymentMethodId, clientSecret: $clientSecret, lastPaymentError: $lastPaymentError, authorizedAt: $authorizedAt, capturedAt: $capturedAt, cancelledAt: $cancelledAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentIntentImpl &&
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
            (identical(other.status, status) || other.status == status) &&
            (identical(other.captureMethod, captureMethod) ||
                other.captureMethod == captureMethod) &&
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
      status,
      captureMethod,
      paymentMethodId,
      clientSecret,
      lastPaymentError,
      authorizedAt,
      capturedAt,
      cancelledAt,
      createdAt,
      updatedAt);

  /// Create a copy of PaymentIntent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentIntentImplCopyWith<_$PaymentIntentImpl> get copyWith =>
      __$$PaymentIntentImplCopyWithImpl<_$PaymentIntentImpl>(this, _$identity);
}

abstract class _PaymentIntent implements PaymentIntent {
  const factory _PaymentIntent(
      {required final String id,
      required final String bookingId,
      required final String chefStripeAccountId,
      required final int amount,
      required final int serviceFeeAmount,
      required final int vatAmount,
      required final String currency,
      required final PaymentIntentStatus status,
      required final PaymentIntentCaptureMethod captureMethod,
      final String? paymentMethodId,
      final String? clientSecret,
      final String? lastPaymentError,
      final DateTime? authorizedAt,
      final DateTime? capturedAt,
      final DateTime? cancelledAt,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$PaymentIntentImpl;

  @override
  String get id;
  @override
  String get bookingId;
  @override
  String get chefStripeAccountId;
  @override
  int get amount; // in øre (Danish cents)
  @override
  int get serviceFeeAmount;
  @override
  int get vatAmount;
  @override
  String get currency;
  @override
  PaymentIntentStatus get status;
  @override
  PaymentIntentCaptureMethod get captureMethod;
  @override
  String? get paymentMethodId;
  @override
  String? get clientSecret;
  @override
  String? get lastPaymentError;
  @override
  DateTime? get authorizedAt;
  @override
  DateTime? get capturedAt;
  @override
  DateTime? get cancelledAt;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of PaymentIntent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentIntentImplCopyWith<_$PaymentIntentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
