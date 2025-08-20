// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chef_availability_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ChefAvailabilityModel _$ChefAvailabilityModelFromJson(
    Map<String, dynamic> json) {
  return _ChefAvailabilityModel.fromJson(json);
}

/// @nodoc
mixin _$ChefAvailabilityModel {
  @JsonKey(name: 'id')
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'chef_id')
  String get chefId => throw _privateConstructorUsedError;
  @JsonKey(name: 'date')
  String get date => throw _privateConstructorUsedError; // ISO date string
  @JsonKey(name: 'start_time')
  String? get startTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_time')
  String? get endTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'availability_type')
  String get availabilityType => throw _privateConstructorUsedError;
  @JsonKey(name: 'reason')
  String? get reason => throw _privateConstructorUsedError;
  @JsonKey(name: 'overrides_working_hours')
  bool get overridesWorkingHours => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ChefAvailabilityModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChefAvailabilityModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChefAvailabilityModelCopyWith<ChefAvailabilityModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChefAvailabilityModelCopyWith<$Res> {
  factory $ChefAvailabilityModelCopyWith(ChefAvailabilityModel value,
          $Res Function(ChefAvailabilityModel) then) =
      _$ChefAvailabilityModelCopyWithImpl<$Res, ChefAvailabilityModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'id') String? id,
      @JsonKey(name: 'chef_id') String chefId,
      @JsonKey(name: 'date') String date,
      @JsonKey(name: 'start_time') String? startTime,
      @JsonKey(name: 'end_time') String? endTime,
      @JsonKey(name: 'availability_type') String availabilityType,
      @JsonKey(name: 'reason') String? reason,
      @JsonKey(name: 'overrides_working_hours') bool overridesWorkingHours,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt});
}

/// @nodoc
class _$ChefAvailabilityModelCopyWithImpl<$Res,
        $Val extends ChefAvailabilityModel>
    implements $ChefAvailabilityModelCopyWith<$Res> {
  _$ChefAvailabilityModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChefAvailabilityModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? chefId = null,
    Object? date = null,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? availabilityType = null,
    Object? reason = freezed,
    Object? overridesWorkingHours = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      chefId: null == chefId
          ? _value.chefId
          : chefId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: freezed == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String?,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String?,
      availabilityType: null == availabilityType
          ? _value.availabilityType
          : availabilityType // ignore: cast_nullable_to_non_nullable
              as String,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
      overridesWorkingHours: null == overridesWorkingHours
          ? _value.overridesWorkingHours
          : overridesWorkingHours // ignore: cast_nullable_to_non_nullable
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
abstract class _$$ChefAvailabilityModelImplCopyWith<$Res>
    implements $ChefAvailabilityModelCopyWith<$Res> {
  factory _$$ChefAvailabilityModelImplCopyWith(
          _$ChefAvailabilityModelImpl value,
          $Res Function(_$ChefAvailabilityModelImpl) then) =
      __$$ChefAvailabilityModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'id') String? id,
      @JsonKey(name: 'chef_id') String chefId,
      @JsonKey(name: 'date') String date,
      @JsonKey(name: 'start_time') String? startTime,
      @JsonKey(name: 'end_time') String? endTime,
      @JsonKey(name: 'availability_type') String availabilityType,
      @JsonKey(name: 'reason') String? reason,
      @JsonKey(name: 'overrides_working_hours') bool overridesWorkingHours,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt});
}

/// @nodoc
class __$$ChefAvailabilityModelImplCopyWithImpl<$Res>
    extends _$ChefAvailabilityModelCopyWithImpl<$Res,
        _$ChefAvailabilityModelImpl>
    implements _$$ChefAvailabilityModelImplCopyWith<$Res> {
  __$$ChefAvailabilityModelImplCopyWithImpl(_$ChefAvailabilityModelImpl _value,
      $Res Function(_$ChefAvailabilityModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChefAvailabilityModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? chefId = null,
    Object? date = null,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? availabilityType = null,
    Object? reason = freezed,
    Object? overridesWorkingHours = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$ChefAvailabilityModelImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      chefId: null == chefId
          ? _value.chefId
          : chefId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: freezed == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String?,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String?,
      availabilityType: null == availabilityType
          ? _value.availabilityType
          : availabilityType // ignore: cast_nullable_to_non_nullable
              as String,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
      overridesWorkingHours: null == overridesWorkingHours
          ? _value.overridesWorkingHours
          : overridesWorkingHours // ignore: cast_nullable_to_non_nullable
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
class _$ChefAvailabilityModelImpl extends _ChefAvailabilityModel {
  const _$ChefAvailabilityModelImpl(
      {@JsonKey(name: 'id') this.id,
      @JsonKey(name: 'chef_id') required this.chefId,
      @JsonKey(name: 'date') required this.date,
      @JsonKey(name: 'start_time') this.startTime,
      @JsonKey(name: 'end_time') this.endTime,
      @JsonKey(name: 'availability_type') required this.availabilityType,
      @JsonKey(name: 'reason') this.reason,
      @JsonKey(name: 'overrides_working_hours')
      this.overridesWorkingHours = false,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt})
      : super._();

  factory _$ChefAvailabilityModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChefAvailabilityModelImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final String? id;
  @override
  @JsonKey(name: 'chef_id')
  final String chefId;
  @override
  @JsonKey(name: 'date')
  final String date;
// ISO date string
  @override
  @JsonKey(name: 'start_time')
  final String? startTime;
  @override
  @JsonKey(name: 'end_time')
  final String? endTime;
  @override
  @JsonKey(name: 'availability_type')
  final String availabilityType;
  @override
  @JsonKey(name: 'reason')
  final String? reason;
  @override
  @JsonKey(name: 'overrides_working_hours')
  final bool overridesWorkingHours;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  @override
  String toString() {
    return 'ChefAvailabilityModel(id: $id, chefId: $chefId, date: $date, startTime: $startTime, endTime: $endTime, availabilityType: $availabilityType, reason: $reason, overridesWorkingHours: $overridesWorkingHours, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChefAvailabilityModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.chefId, chefId) || other.chefId == chefId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.availabilityType, availabilityType) ||
                other.availabilityType == availabilityType) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.overridesWorkingHours, overridesWorkingHours) ||
                other.overridesWorkingHours == overridesWorkingHours) &&
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
      chefId,
      date,
      startTime,
      endTime,
      availabilityType,
      reason,
      overridesWorkingHours,
      createdAt,
      updatedAt);

  /// Create a copy of ChefAvailabilityModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChefAvailabilityModelImplCopyWith<_$ChefAvailabilityModelImpl>
      get copyWith => __$$ChefAvailabilityModelImplCopyWithImpl<
          _$ChefAvailabilityModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChefAvailabilityModelImplToJson(
      this,
    );
  }
}

abstract class _ChefAvailabilityModel extends ChefAvailabilityModel {
  const factory _ChefAvailabilityModel(
          {@JsonKey(name: 'id') final String? id,
          @JsonKey(name: 'chef_id') required final String chefId,
          @JsonKey(name: 'date') required final String date,
          @JsonKey(name: 'start_time') final String? startTime,
          @JsonKey(name: 'end_time') final String? endTime,
          @JsonKey(name: 'availability_type')
          required final String availabilityType,
          @JsonKey(name: 'reason') final String? reason,
          @JsonKey(name: 'overrides_working_hours')
          final bool overridesWorkingHours,
          @JsonKey(name: 'created_at') final String? createdAt,
          @JsonKey(name: 'updated_at') final String? updatedAt}) =
      _$ChefAvailabilityModelImpl;
  const _ChefAvailabilityModel._() : super._();

  factory _ChefAvailabilityModel.fromJson(Map<String, dynamic> json) =
      _$ChefAvailabilityModelImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  String? get id;
  @override
  @JsonKey(name: 'chef_id')
  String get chefId;
  @override
  @JsonKey(name: 'date')
  String get date; // ISO date string
  @override
  @JsonKey(name: 'start_time')
  String? get startTime;
  @override
  @JsonKey(name: 'end_time')
  String? get endTime;
  @override
  @JsonKey(name: 'availability_type')
  String get availabilityType;
  @override
  @JsonKey(name: 'reason')
  String? get reason;
  @override
  @JsonKey(name: 'overrides_working_hours')
  bool get overridesWorkingHours;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  String? get updatedAt;

  /// Create a copy of ChefAvailabilityModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChefAvailabilityModelImplCopyWith<_$ChefAvailabilityModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
