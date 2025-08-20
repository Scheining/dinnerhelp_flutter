// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_calculation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PaymentCalculation {
  int get baseAmount => throw _privateConstructorUsedError; // in øre
  int get serviceFeeAmount => throw _privateConstructorUsedError;
  int get vatAmount => throw _privateConstructorUsedError;
  int get stripeFeeAmount => throw _privateConstructorUsedError;
  int get totalAmount => throw _privateConstructorUsedError;
  int get chefPayoutAmount => throw _privateConstructorUsedError;
  double get serviceFeePercentage => throw _privateConstructorUsedError;
  double get vatPercentage => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  DateTime? get bankHolidayDate => throw _privateConstructorUsedError;
  int? get bankHolidayExtraCharge => throw _privateConstructorUsedError;
  DateTime? get newYearEveDate => throw _privateConstructorUsedError;
  int? get newYearEveExtraCharge => throw _privateConstructorUsedError;

  /// Create a copy of PaymentCalculation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaymentCalculationCopyWith<PaymentCalculation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentCalculationCopyWith<$Res> {
  factory $PaymentCalculationCopyWith(
          PaymentCalculation value, $Res Function(PaymentCalculation) then) =
      _$PaymentCalculationCopyWithImpl<$Res, PaymentCalculation>;
  @useResult
  $Res call(
      {int baseAmount,
      int serviceFeeAmount,
      int vatAmount,
      int stripeFeeAmount,
      int totalAmount,
      int chefPayoutAmount,
      double serviceFeePercentage,
      double vatPercentage,
      String currency,
      DateTime? bankHolidayDate,
      int? bankHolidayExtraCharge,
      DateTime? newYearEveDate,
      int? newYearEveExtraCharge});
}

/// @nodoc
class _$PaymentCalculationCopyWithImpl<$Res, $Val extends PaymentCalculation>
    implements $PaymentCalculationCopyWith<$Res> {
  _$PaymentCalculationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaymentCalculation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? baseAmount = null,
    Object? serviceFeeAmount = null,
    Object? vatAmount = null,
    Object? stripeFeeAmount = null,
    Object? totalAmount = null,
    Object? chefPayoutAmount = null,
    Object? serviceFeePercentage = null,
    Object? vatPercentage = null,
    Object? currency = null,
    Object? bankHolidayDate = freezed,
    Object? bankHolidayExtraCharge = freezed,
    Object? newYearEveDate = freezed,
    Object? newYearEveExtraCharge = freezed,
  }) {
    return _then(_value.copyWith(
      baseAmount: null == baseAmount
          ? _value.baseAmount
          : baseAmount // ignore: cast_nullable_to_non_nullable
              as int,
      serviceFeeAmount: null == serviceFeeAmount
          ? _value.serviceFeeAmount
          : serviceFeeAmount // ignore: cast_nullable_to_non_nullable
              as int,
      vatAmount: null == vatAmount
          ? _value.vatAmount
          : vatAmount // ignore: cast_nullable_to_non_nullable
              as int,
      stripeFeeAmount: null == stripeFeeAmount
          ? _value.stripeFeeAmount
          : stripeFeeAmount // ignore: cast_nullable_to_non_nullable
              as int,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as int,
      chefPayoutAmount: null == chefPayoutAmount
          ? _value.chefPayoutAmount
          : chefPayoutAmount // ignore: cast_nullable_to_non_nullable
              as int,
      serviceFeePercentage: null == serviceFeePercentage
          ? _value.serviceFeePercentage
          : serviceFeePercentage // ignore: cast_nullable_to_non_nullable
              as double,
      vatPercentage: null == vatPercentage
          ? _value.vatPercentage
          : vatPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      bankHolidayDate: freezed == bankHolidayDate
          ? _value.bankHolidayDate
          : bankHolidayDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      bankHolidayExtraCharge: freezed == bankHolidayExtraCharge
          ? _value.bankHolidayExtraCharge
          : bankHolidayExtraCharge // ignore: cast_nullable_to_non_nullable
              as int?,
      newYearEveDate: freezed == newYearEveDate
          ? _value.newYearEveDate
          : newYearEveDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      newYearEveExtraCharge: freezed == newYearEveExtraCharge
          ? _value.newYearEveExtraCharge
          : newYearEveExtraCharge // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PaymentCalculationImplCopyWith<$Res>
    implements $PaymentCalculationCopyWith<$Res> {
  factory _$$PaymentCalculationImplCopyWith(_$PaymentCalculationImpl value,
          $Res Function(_$PaymentCalculationImpl) then) =
      __$$PaymentCalculationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int baseAmount,
      int serviceFeeAmount,
      int vatAmount,
      int stripeFeeAmount,
      int totalAmount,
      int chefPayoutAmount,
      double serviceFeePercentage,
      double vatPercentage,
      String currency,
      DateTime? bankHolidayDate,
      int? bankHolidayExtraCharge,
      DateTime? newYearEveDate,
      int? newYearEveExtraCharge});
}

/// @nodoc
class __$$PaymentCalculationImplCopyWithImpl<$Res>
    extends _$PaymentCalculationCopyWithImpl<$Res, _$PaymentCalculationImpl>
    implements _$$PaymentCalculationImplCopyWith<$Res> {
  __$$PaymentCalculationImplCopyWithImpl(_$PaymentCalculationImpl _value,
      $Res Function(_$PaymentCalculationImpl) _then)
      : super(_value, _then);

  /// Create a copy of PaymentCalculation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? baseAmount = null,
    Object? serviceFeeAmount = null,
    Object? vatAmount = null,
    Object? stripeFeeAmount = null,
    Object? totalAmount = null,
    Object? chefPayoutAmount = null,
    Object? serviceFeePercentage = null,
    Object? vatPercentage = null,
    Object? currency = null,
    Object? bankHolidayDate = freezed,
    Object? bankHolidayExtraCharge = freezed,
    Object? newYearEveDate = freezed,
    Object? newYearEveExtraCharge = freezed,
  }) {
    return _then(_$PaymentCalculationImpl(
      baseAmount: null == baseAmount
          ? _value.baseAmount
          : baseAmount // ignore: cast_nullable_to_non_nullable
              as int,
      serviceFeeAmount: null == serviceFeeAmount
          ? _value.serviceFeeAmount
          : serviceFeeAmount // ignore: cast_nullable_to_non_nullable
              as int,
      vatAmount: null == vatAmount
          ? _value.vatAmount
          : vatAmount // ignore: cast_nullable_to_non_nullable
              as int,
      stripeFeeAmount: null == stripeFeeAmount
          ? _value.stripeFeeAmount
          : stripeFeeAmount // ignore: cast_nullable_to_non_nullable
              as int,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as int,
      chefPayoutAmount: null == chefPayoutAmount
          ? _value.chefPayoutAmount
          : chefPayoutAmount // ignore: cast_nullable_to_non_nullable
              as int,
      serviceFeePercentage: null == serviceFeePercentage
          ? _value.serviceFeePercentage
          : serviceFeePercentage // ignore: cast_nullable_to_non_nullable
              as double,
      vatPercentage: null == vatPercentage
          ? _value.vatPercentage
          : vatPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      bankHolidayDate: freezed == bankHolidayDate
          ? _value.bankHolidayDate
          : bankHolidayDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      bankHolidayExtraCharge: freezed == bankHolidayExtraCharge
          ? _value.bankHolidayExtraCharge
          : bankHolidayExtraCharge // ignore: cast_nullable_to_non_nullable
              as int?,
      newYearEveDate: freezed == newYearEveDate
          ? _value.newYearEveDate
          : newYearEveDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      newYearEveExtraCharge: freezed == newYearEveExtraCharge
          ? _value.newYearEveExtraCharge
          : newYearEveExtraCharge // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$PaymentCalculationImpl extends _PaymentCalculation {
  const _$PaymentCalculationImpl(
      {required this.baseAmount,
      required this.serviceFeeAmount,
      required this.vatAmount,
      required this.stripeFeeAmount,
      required this.totalAmount,
      required this.chefPayoutAmount,
      required this.serviceFeePercentage,
      required this.vatPercentage,
      required this.currency,
      this.bankHolidayDate,
      this.bankHolidayExtraCharge,
      this.newYearEveDate,
      this.newYearEveExtraCharge})
      : super._();

  @override
  final int baseAmount;
// in øre
  @override
  final int serviceFeeAmount;
  @override
  final int vatAmount;
  @override
  final int stripeFeeAmount;
  @override
  final int totalAmount;
  @override
  final int chefPayoutAmount;
  @override
  final double serviceFeePercentage;
  @override
  final double vatPercentage;
  @override
  final String currency;
  @override
  final DateTime? bankHolidayDate;
  @override
  final int? bankHolidayExtraCharge;
  @override
  final DateTime? newYearEveDate;
  @override
  final int? newYearEveExtraCharge;

  @override
  String toString() {
    return 'PaymentCalculation(baseAmount: $baseAmount, serviceFeeAmount: $serviceFeeAmount, vatAmount: $vatAmount, stripeFeeAmount: $stripeFeeAmount, totalAmount: $totalAmount, chefPayoutAmount: $chefPayoutAmount, serviceFeePercentage: $serviceFeePercentage, vatPercentage: $vatPercentage, currency: $currency, bankHolidayDate: $bankHolidayDate, bankHolidayExtraCharge: $bankHolidayExtraCharge, newYearEveDate: $newYearEveDate, newYearEveExtraCharge: $newYearEveExtraCharge)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentCalculationImpl &&
            (identical(other.baseAmount, baseAmount) ||
                other.baseAmount == baseAmount) &&
            (identical(other.serviceFeeAmount, serviceFeeAmount) ||
                other.serviceFeeAmount == serviceFeeAmount) &&
            (identical(other.vatAmount, vatAmount) ||
                other.vatAmount == vatAmount) &&
            (identical(other.stripeFeeAmount, stripeFeeAmount) ||
                other.stripeFeeAmount == stripeFeeAmount) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.chefPayoutAmount, chefPayoutAmount) ||
                other.chefPayoutAmount == chefPayoutAmount) &&
            (identical(other.serviceFeePercentage, serviceFeePercentage) ||
                other.serviceFeePercentage == serviceFeePercentage) &&
            (identical(other.vatPercentage, vatPercentage) ||
                other.vatPercentage == vatPercentage) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.bankHolidayDate, bankHolidayDate) ||
                other.bankHolidayDate == bankHolidayDate) &&
            (identical(other.bankHolidayExtraCharge, bankHolidayExtraCharge) ||
                other.bankHolidayExtraCharge == bankHolidayExtraCharge) &&
            (identical(other.newYearEveDate, newYearEveDate) ||
                other.newYearEveDate == newYearEveDate) &&
            (identical(other.newYearEveExtraCharge, newYearEveExtraCharge) ||
                other.newYearEveExtraCharge == newYearEveExtraCharge));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      baseAmount,
      serviceFeeAmount,
      vatAmount,
      stripeFeeAmount,
      totalAmount,
      chefPayoutAmount,
      serviceFeePercentage,
      vatPercentage,
      currency,
      bankHolidayDate,
      bankHolidayExtraCharge,
      newYearEveDate,
      newYearEveExtraCharge);

  /// Create a copy of PaymentCalculation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentCalculationImplCopyWith<_$PaymentCalculationImpl> get copyWith =>
      __$$PaymentCalculationImplCopyWithImpl<_$PaymentCalculationImpl>(
          this, _$identity);
}

abstract class _PaymentCalculation extends PaymentCalculation {
  const factory _PaymentCalculation(
      {required final int baseAmount,
      required final int serviceFeeAmount,
      required final int vatAmount,
      required final int stripeFeeAmount,
      required final int totalAmount,
      required final int chefPayoutAmount,
      required final double serviceFeePercentage,
      required final double vatPercentage,
      required final String currency,
      final DateTime? bankHolidayDate,
      final int? bankHolidayExtraCharge,
      final DateTime? newYearEveDate,
      final int? newYearEveExtraCharge}) = _$PaymentCalculationImpl;
  const _PaymentCalculation._() : super._();

  @override
  int get baseAmount; // in øre
  @override
  int get serviceFeeAmount;
  @override
  int get vatAmount;
  @override
  int get stripeFeeAmount;
  @override
  int get totalAmount;
  @override
  int get chefPayoutAmount;
  @override
  double get serviceFeePercentage;
  @override
  double get vatPercentage;
  @override
  String get currency;
  @override
  DateTime? get bankHolidayDate;
  @override
  int? get bankHolidayExtraCharge;
  @override
  DateTime? get newYearEveDate;
  @override
  int? get newYearEveExtraCharge;

  /// Create a copy of PaymentCalculation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentCalculationImplCopyWith<_$PaymentCalculationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
