// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chef_working_hours_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ChefWorkingHoursModel _$ChefWorkingHoursModelFromJson(
    Map<String, dynamic> json) {
  return _ChefWorkingHoursModel.fromJson(json);
}

/// @nodoc
mixin _$ChefWorkingHoursModel {
  @JsonKey(name: 'chef_id')
  String get chefId => throw _privateConstructorUsedError;
  @JsonKey(name: 'day_of_week')
  int get dayOfWeek => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_time')
  String get startTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_time')
  String get endTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ChefWorkingHoursModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChefWorkingHoursModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChefWorkingHoursModelCopyWith<ChefWorkingHoursModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChefWorkingHoursModelCopyWith<$Res> {
  factory $ChefWorkingHoursModelCopyWith(ChefWorkingHoursModel value,
          $Res Function(ChefWorkingHoursModel) then) =
      _$ChefWorkingHoursModelCopyWithImpl<$Res, ChefWorkingHoursModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'chef_id') String chefId,
      @JsonKey(name: 'day_of_week') int dayOfWeek,
      @JsonKey(name: 'start_time') String startTime,
      @JsonKey(name: 'end_time') String endTime,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt});
}

/// @nodoc
class _$ChefWorkingHoursModelCopyWithImpl<$Res,
        $Val extends ChefWorkingHoursModel>
    implements $ChefWorkingHoursModelCopyWith<$Res> {
  _$ChefWorkingHoursModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChefWorkingHoursModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chefId = null,
    Object? dayOfWeek = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? isActive = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      chefId: null == chefId
          ? _value.chefId
          : chefId // ignore: cast_nullable_to_non_nullable
              as String,
      dayOfWeek: null == dayOfWeek
          ? _value.dayOfWeek
          : dayOfWeek // ignore: cast_nullable_to_non_nullable
              as int,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChefWorkingHoursModelImplCopyWith<$Res>
    implements $ChefWorkingHoursModelCopyWith<$Res> {
  factory _$$ChefWorkingHoursModelImplCopyWith(
          _$ChefWorkingHoursModelImpl value,
          $Res Function(_$ChefWorkingHoursModelImpl) then) =
      __$$ChefWorkingHoursModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'chef_id') String chefId,
      @JsonKey(name: 'day_of_week') int dayOfWeek,
      @JsonKey(name: 'start_time') String startTime,
      @JsonKey(name: 'end_time') String endTime,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt});
}

/// @nodoc
class __$$ChefWorkingHoursModelImplCopyWithImpl<$Res>
    extends _$ChefWorkingHoursModelCopyWithImpl<$Res,
        _$ChefWorkingHoursModelImpl>
    implements _$$ChefWorkingHoursModelImplCopyWith<$Res> {
  __$$ChefWorkingHoursModelImplCopyWithImpl(_$ChefWorkingHoursModelImpl _value,
      $Res Function(_$ChefWorkingHoursModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChefWorkingHoursModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chefId = null,
    Object? dayOfWeek = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? isActive = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$ChefWorkingHoursModelImpl(
      chefId: null == chefId
          ? _value.chefId
          : chefId // ignore: cast_nullable_to_non_nullable
              as String,
      dayOfWeek: null == dayOfWeek
          ? _value.dayOfWeek
          : dayOfWeek // ignore: cast_nullable_to_non_nullable
              as int,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChefWorkingHoursModelImpl extends _ChefWorkingHoursModel {
  const _$ChefWorkingHoursModelImpl(
      {@JsonKey(name: 'chef_id') required this.chefId,
      @JsonKey(name: 'day_of_week') required this.dayOfWeek,
      @JsonKey(name: 'start_time') required this.startTime,
      @JsonKey(name: 'end_time') required this.endTime,
      @JsonKey(name: 'is_active') this.isActive = true,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt})
      : super._();

  factory _$ChefWorkingHoursModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChefWorkingHoursModelImplFromJson(json);

  @override
  @JsonKey(name: 'chef_id')
  final String chefId;
  @override
  @JsonKey(name: 'day_of_week')
  final int dayOfWeek;
  @override
  @JsonKey(name: 'start_time')
  final String startTime;
  @override
  @JsonKey(name: 'end_time')
  final String endTime;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  @override
  String toString() {
    return 'ChefWorkingHoursModel(chefId: $chefId, dayOfWeek: $dayOfWeek, startTime: $startTime, endTime: $endTime, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChefWorkingHoursModelImpl &&
            (identical(other.chefId, chefId) || other.chefId == chefId) &&
            (identical(other.dayOfWeek, dayOfWeek) ||
                other.dayOfWeek == dayOfWeek) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, chefId, dayOfWeek, startTime,
      endTime, isActive, createdAt, updatedAt);

  /// Create a copy of ChefWorkingHoursModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChefWorkingHoursModelImplCopyWith<_$ChefWorkingHoursModelImpl>
      get copyWith => __$$ChefWorkingHoursModelImplCopyWithImpl<
          _$ChefWorkingHoursModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChefWorkingHoursModelImplToJson(
      this,
    );
  }
}

abstract class _ChefWorkingHoursModel extends ChefWorkingHoursModel {
  const factory _ChefWorkingHoursModel(
          {@JsonKey(name: 'chef_id') required final String chefId,
          @JsonKey(name: 'day_of_week') required final int dayOfWeek,
          @JsonKey(name: 'start_time') required final String startTime,
          @JsonKey(name: 'end_time') required final String endTime,
          @JsonKey(name: 'is_active') final bool isActive,
          @JsonKey(name: 'created_at') final String? createdAt,
          @JsonKey(name: 'updated_at') final String? updatedAt}) =
      _$ChefWorkingHoursModelImpl;
  const _ChefWorkingHoursModel._() : super._();

  factory _ChefWorkingHoursModel.fromJson(Map<String, dynamic> json) =
      _$ChefWorkingHoursModelImpl.fromJson;

  @override
  @JsonKey(name: 'chef_id')
  String get chefId;
  @override
  @JsonKey(name: 'day_of_week')
  int get dayOfWeek;
  @override
  @JsonKey(name: 'start_time')
  String get startTime;
  @override
  @JsonKey(name: 'end_time')
  String get endTime;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  String? get updatedAt;

  /// Create a copy of ChefWorkingHoursModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChefWorkingHoursModelImplCopyWith<_$ChefWorkingHoursModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
