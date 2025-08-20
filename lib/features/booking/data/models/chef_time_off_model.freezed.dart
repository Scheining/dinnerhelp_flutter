// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chef_time_off_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ChefTimeOffModel _$ChefTimeOffModelFromJson(Map<String, dynamic> json) {
  return _ChefTimeOffModel.fromJson(json);
}

/// @nodoc
mixin _$ChefTimeOffModel {
  @JsonKey(name: 'id')
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'chef_id')
  String get chefId => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_date')
  String get startDate => throw _privateConstructorUsedError; // ISO date string
  @JsonKey(name: 'end_date')
  String get endDate => throw _privateConstructorUsedError; // ISO date string
  @JsonKey(name: 'time_off_type')
  String get timeOffType => throw _privateConstructorUsedError;
  @JsonKey(name: 'reason')
  String? get reason => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_recurring')
  bool get isRecurring => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_approved')
  bool get isApproved => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ChefTimeOffModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChefTimeOffModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChefTimeOffModelCopyWith<ChefTimeOffModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChefTimeOffModelCopyWith<$Res> {
  factory $ChefTimeOffModelCopyWith(
          ChefTimeOffModel value, $Res Function(ChefTimeOffModel) then) =
      _$ChefTimeOffModelCopyWithImpl<$Res, ChefTimeOffModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'id') String? id,
      @JsonKey(name: 'chef_id') String chefId,
      @JsonKey(name: 'start_date') String startDate,
      @JsonKey(name: 'end_date') String endDate,
      @JsonKey(name: 'time_off_type') String timeOffType,
      @JsonKey(name: 'reason') String? reason,
      @JsonKey(name: 'is_recurring') bool isRecurring,
      @JsonKey(name: 'is_approved') bool isApproved,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt});
}

/// @nodoc
class _$ChefTimeOffModelCopyWithImpl<$Res, $Val extends ChefTimeOffModel>
    implements $ChefTimeOffModelCopyWith<$Res> {
  _$ChefTimeOffModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChefTimeOffModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? chefId = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? timeOffType = null,
    Object? reason = freezed,
    Object? isRecurring = null,
    Object? isApproved = null,
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
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as String,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as String,
      timeOffType: null == timeOffType
          ? _value.timeOffType
          : timeOffType // ignore: cast_nullable_to_non_nullable
              as String,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
      isRecurring: null == isRecurring
          ? _value.isRecurring
          : isRecurring // ignore: cast_nullable_to_non_nullable
              as bool,
      isApproved: null == isApproved
          ? _value.isApproved
          : isApproved // ignore: cast_nullable_to_non_nullable
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
abstract class _$$ChefTimeOffModelImplCopyWith<$Res>
    implements $ChefTimeOffModelCopyWith<$Res> {
  factory _$$ChefTimeOffModelImplCopyWith(_$ChefTimeOffModelImpl value,
          $Res Function(_$ChefTimeOffModelImpl) then) =
      __$$ChefTimeOffModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'id') String? id,
      @JsonKey(name: 'chef_id') String chefId,
      @JsonKey(name: 'start_date') String startDate,
      @JsonKey(name: 'end_date') String endDate,
      @JsonKey(name: 'time_off_type') String timeOffType,
      @JsonKey(name: 'reason') String? reason,
      @JsonKey(name: 'is_recurring') bool isRecurring,
      @JsonKey(name: 'is_approved') bool isApproved,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt});
}

/// @nodoc
class __$$ChefTimeOffModelImplCopyWithImpl<$Res>
    extends _$ChefTimeOffModelCopyWithImpl<$Res, _$ChefTimeOffModelImpl>
    implements _$$ChefTimeOffModelImplCopyWith<$Res> {
  __$$ChefTimeOffModelImplCopyWithImpl(_$ChefTimeOffModelImpl _value,
      $Res Function(_$ChefTimeOffModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChefTimeOffModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? chefId = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? timeOffType = null,
    Object? reason = freezed,
    Object? isRecurring = null,
    Object? isApproved = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$ChefTimeOffModelImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      chefId: null == chefId
          ? _value.chefId
          : chefId // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as String,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as String,
      timeOffType: null == timeOffType
          ? _value.timeOffType
          : timeOffType // ignore: cast_nullable_to_non_nullable
              as String,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
      isRecurring: null == isRecurring
          ? _value.isRecurring
          : isRecurring // ignore: cast_nullable_to_non_nullable
              as bool,
      isApproved: null == isApproved
          ? _value.isApproved
          : isApproved // ignore: cast_nullable_to_non_nullable
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
class _$ChefTimeOffModelImpl extends _ChefTimeOffModel {
  const _$ChefTimeOffModelImpl(
      {@JsonKey(name: 'id') this.id,
      @JsonKey(name: 'chef_id') required this.chefId,
      @JsonKey(name: 'start_date') required this.startDate,
      @JsonKey(name: 'end_date') required this.endDate,
      @JsonKey(name: 'time_off_type') required this.timeOffType,
      @JsonKey(name: 'reason') this.reason,
      @JsonKey(name: 'is_recurring') this.isRecurring = false,
      @JsonKey(name: 'is_approved') this.isApproved = true,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt})
      : super._();

  factory _$ChefTimeOffModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChefTimeOffModelImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final String? id;
  @override
  @JsonKey(name: 'chef_id')
  final String chefId;
  @override
  @JsonKey(name: 'start_date')
  final String startDate;
// ISO date string
  @override
  @JsonKey(name: 'end_date')
  final String endDate;
// ISO date string
  @override
  @JsonKey(name: 'time_off_type')
  final String timeOffType;
  @override
  @JsonKey(name: 'reason')
  final String? reason;
  @override
  @JsonKey(name: 'is_recurring')
  final bool isRecurring;
  @override
  @JsonKey(name: 'is_approved')
  final bool isApproved;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  @override
  String toString() {
    return 'ChefTimeOffModel(id: $id, chefId: $chefId, startDate: $startDate, endDate: $endDate, timeOffType: $timeOffType, reason: $reason, isRecurring: $isRecurring, isApproved: $isApproved, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChefTimeOffModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.chefId, chefId) || other.chefId == chefId) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.timeOffType, timeOffType) ||
                other.timeOffType == timeOffType) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.isRecurring, isRecurring) ||
                other.isRecurring == isRecurring) &&
            (identical(other.isApproved, isApproved) ||
                other.isApproved == isApproved) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, chefId, startDate, endDate,
      timeOffType, reason, isRecurring, isApproved, createdAt, updatedAt);

  /// Create a copy of ChefTimeOffModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChefTimeOffModelImplCopyWith<_$ChefTimeOffModelImpl> get copyWith =>
      __$$ChefTimeOffModelImplCopyWithImpl<_$ChefTimeOffModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChefTimeOffModelImplToJson(
      this,
    );
  }
}

abstract class _ChefTimeOffModel extends ChefTimeOffModel {
  const factory _ChefTimeOffModel(
          {@JsonKey(name: 'id') final String? id,
          @JsonKey(name: 'chef_id') required final String chefId,
          @JsonKey(name: 'start_date') required final String startDate,
          @JsonKey(name: 'end_date') required final String endDate,
          @JsonKey(name: 'time_off_type') required final String timeOffType,
          @JsonKey(name: 'reason') final String? reason,
          @JsonKey(name: 'is_recurring') final bool isRecurring,
          @JsonKey(name: 'is_approved') final bool isApproved,
          @JsonKey(name: 'created_at') final String? createdAt,
          @JsonKey(name: 'updated_at') final String? updatedAt}) =
      _$ChefTimeOffModelImpl;
  const _ChefTimeOffModel._() : super._();

  factory _ChefTimeOffModel.fromJson(Map<String, dynamic> json) =
      _$ChefTimeOffModelImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  String? get id;
  @override
  @JsonKey(name: 'chef_id')
  String get chefId;
  @override
  @JsonKey(name: 'start_date')
  String get startDate; // ISO date string
  @override
  @JsonKey(name: 'end_date')
  String get endDate; // ISO date string
  @override
  @JsonKey(name: 'time_off_type')
  String get timeOffType;
  @override
  @JsonKey(name: 'reason')
  String? get reason;
  @override
  @JsonKey(name: 'is_recurring')
  bool get isRecurring;
  @override
  @JsonKey(name: 'is_approved')
  bool get isApproved;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  String? get updatedAt;

  /// Create a copy of ChefTimeOffModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChefTimeOffModelImplCopyWith<_$ChefTimeOffModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
