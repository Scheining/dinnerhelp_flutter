// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_method_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PaymentMethodModel _$PaymentMethodModelFromJson(Map<String, dynamic> json) {
  return _PaymentMethodModel.fromJson(json);
}

/// @nodoc
mixin _$PaymentMethodModel {
  @JsonKey(name: 'stripe_payment_method_id')
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'type')
  String get typeString => throw _privateConstructorUsedError;
  @JsonKey(name: 'last4')
  String get last4 => throw _privateConstructorUsedError;
  @JsonKey(name: 'brand')
  String get brand => throw _privateConstructorUsedError;
  @JsonKey(name: 'exp_month')
  int get expMonth => throw _privateConstructorUsedError;
  @JsonKey(name: 'exp_year')
  int get expYear => throw _privateConstructorUsedError;
  @JsonKey(name: 'holder_name')
  String? get holderName => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_default')
  bool get isDefault => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this PaymentMethodModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PaymentMethodModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaymentMethodModelCopyWith<PaymentMethodModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentMethodModelCopyWith<$Res> {
  factory $PaymentMethodModelCopyWith(
          PaymentMethodModel value, $Res Function(PaymentMethodModel) then) =
      _$PaymentMethodModelCopyWithImpl<$Res, PaymentMethodModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'stripe_payment_method_id') String id,
      @JsonKey(name: 'type') String typeString,
      @JsonKey(name: 'last4') String last4,
      @JsonKey(name: 'brand') String brand,
      @JsonKey(name: 'exp_month') int expMonth,
      @JsonKey(name: 'exp_year') int expYear,
      @JsonKey(name: 'holder_name') String? holderName,
      @JsonKey(name: 'is_default') bool isDefault,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class _$PaymentMethodModelCopyWithImpl<$Res, $Val extends PaymentMethodModel>
    implements $PaymentMethodModelCopyWith<$Res> {
  _$PaymentMethodModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaymentMethodModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? typeString = null,
    Object? last4 = null,
    Object? brand = null,
    Object? expMonth = null,
    Object? expYear = null,
    Object? holderName = freezed,
    Object? isDefault = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      typeString: null == typeString
          ? _value.typeString
          : typeString // ignore: cast_nullable_to_non_nullable
              as String,
      last4: null == last4
          ? _value.last4
          : last4 // ignore: cast_nullable_to_non_nullable
              as String,
      brand: null == brand
          ? _value.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as String,
      expMonth: null == expMonth
          ? _value.expMonth
          : expMonth // ignore: cast_nullable_to_non_nullable
              as int,
      expYear: null == expYear
          ? _value.expYear
          : expYear // ignore: cast_nullable_to_non_nullable
              as int,
      holderName: freezed == holderName
          ? _value.holderName
          : holderName // ignore: cast_nullable_to_non_nullable
              as String?,
      isDefault: null == isDefault
          ? _value.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PaymentMethodModelImplCopyWith<$Res>
    implements $PaymentMethodModelCopyWith<$Res> {
  factory _$$PaymentMethodModelImplCopyWith(_$PaymentMethodModelImpl value,
          $Res Function(_$PaymentMethodModelImpl) then) =
      __$$PaymentMethodModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'stripe_payment_method_id') String id,
      @JsonKey(name: 'type') String typeString,
      @JsonKey(name: 'last4') String last4,
      @JsonKey(name: 'brand') String brand,
      @JsonKey(name: 'exp_month') int expMonth,
      @JsonKey(name: 'exp_year') int expYear,
      @JsonKey(name: 'holder_name') String? holderName,
      @JsonKey(name: 'is_default') bool isDefault,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class __$$PaymentMethodModelImplCopyWithImpl<$Res>
    extends _$PaymentMethodModelCopyWithImpl<$Res, _$PaymentMethodModelImpl>
    implements _$$PaymentMethodModelImplCopyWith<$Res> {
  __$$PaymentMethodModelImplCopyWithImpl(_$PaymentMethodModelImpl _value,
      $Res Function(_$PaymentMethodModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of PaymentMethodModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? typeString = null,
    Object? last4 = null,
    Object? brand = null,
    Object? expMonth = null,
    Object? expYear = null,
    Object? holderName = freezed,
    Object? isDefault = null,
    Object? createdAt = null,
  }) {
    return _then(_$PaymentMethodModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      typeString: null == typeString
          ? _value.typeString
          : typeString // ignore: cast_nullable_to_non_nullable
              as String,
      last4: null == last4
          ? _value.last4
          : last4 // ignore: cast_nullable_to_non_nullable
              as String,
      brand: null == brand
          ? _value.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as String,
      expMonth: null == expMonth
          ? _value.expMonth
          : expMonth // ignore: cast_nullable_to_non_nullable
              as int,
      expYear: null == expYear
          ? _value.expYear
          : expYear // ignore: cast_nullable_to_non_nullable
              as int,
      holderName: freezed == holderName
          ? _value.holderName
          : holderName // ignore: cast_nullable_to_non_nullable
              as String?,
      isDefault: null == isDefault
          ? _value.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PaymentMethodModelImpl extends _PaymentMethodModel {
  const _$PaymentMethodModelImpl(
      {@JsonKey(name: 'stripe_payment_method_id') required this.id,
      @JsonKey(name: 'type') required this.typeString,
      @JsonKey(name: 'last4') required this.last4,
      @JsonKey(name: 'brand') required this.brand,
      @JsonKey(name: 'exp_month') required this.expMonth,
      @JsonKey(name: 'exp_year') required this.expYear,
      @JsonKey(name: 'holder_name') this.holderName,
      @JsonKey(name: 'is_default') required this.isDefault,
      @JsonKey(name: 'created_at') required this.createdAt})
      : super._();

  factory _$PaymentMethodModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaymentMethodModelImplFromJson(json);

  @override
  @JsonKey(name: 'stripe_payment_method_id')
  final String id;
  @override
  @JsonKey(name: 'type')
  final String typeString;
  @override
  @JsonKey(name: 'last4')
  final String last4;
  @override
  @JsonKey(name: 'brand')
  final String brand;
  @override
  @JsonKey(name: 'exp_month')
  final int expMonth;
  @override
  @JsonKey(name: 'exp_year')
  final int expYear;
  @override
  @JsonKey(name: 'holder_name')
  final String? holderName;
  @override
  @JsonKey(name: 'is_default')
  final bool isDefault;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'PaymentMethodModel(id: $id, typeString: $typeString, last4: $last4, brand: $brand, expMonth: $expMonth, expYear: $expYear, holderName: $holderName, isDefault: $isDefault, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentMethodModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.typeString, typeString) ||
                other.typeString == typeString) &&
            (identical(other.last4, last4) || other.last4 == last4) &&
            (identical(other.brand, brand) || other.brand == brand) &&
            (identical(other.expMonth, expMonth) ||
                other.expMonth == expMonth) &&
            (identical(other.expYear, expYear) || other.expYear == expYear) &&
            (identical(other.holderName, holderName) ||
                other.holderName == holderName) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, typeString, last4, brand,
      expMonth, expYear, holderName, isDefault, createdAt);

  /// Create a copy of PaymentMethodModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentMethodModelImplCopyWith<_$PaymentMethodModelImpl> get copyWith =>
      __$$PaymentMethodModelImplCopyWithImpl<_$PaymentMethodModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PaymentMethodModelImplToJson(
      this,
    );
  }
}

abstract class _PaymentMethodModel extends PaymentMethodModel {
  const factory _PaymentMethodModel(
          {@JsonKey(name: 'stripe_payment_method_id') required final String id,
          @JsonKey(name: 'type') required final String typeString,
          @JsonKey(name: 'last4') required final String last4,
          @JsonKey(name: 'brand') required final String brand,
          @JsonKey(name: 'exp_month') required final int expMonth,
          @JsonKey(name: 'exp_year') required final int expYear,
          @JsonKey(name: 'holder_name') final String? holderName,
          @JsonKey(name: 'is_default') required final bool isDefault,
          @JsonKey(name: 'created_at') required final DateTime createdAt}) =
      _$PaymentMethodModelImpl;
  const _PaymentMethodModel._() : super._();

  factory _PaymentMethodModel.fromJson(Map<String, dynamic> json) =
      _$PaymentMethodModelImpl.fromJson;

  @override
  @JsonKey(name: 'stripe_payment_method_id')
  String get id;
  @override
  @JsonKey(name: 'type')
  String get typeString;
  @override
  @JsonKey(name: 'last4')
  String get last4;
  @override
  @JsonKey(name: 'brand')
  String get brand;
  @override
  @JsonKey(name: 'exp_month')
  int get expMonth;
  @override
  @JsonKey(name: 'exp_year')
  int get expYear;
  @override
  @JsonKey(name: 'holder_name')
  String? get holderName;
  @override
  @JsonKey(name: 'is_default')
  bool get isDefault;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of PaymentMethodModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentMethodModelImplCopyWith<_$PaymentMethodModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
