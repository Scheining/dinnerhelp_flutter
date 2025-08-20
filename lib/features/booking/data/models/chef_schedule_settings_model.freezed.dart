// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chef_schedule_settings_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ChefScheduleSettingsModel _$ChefScheduleSettingsModelFromJson(
    Map<String, dynamic> json) {
  return _ChefScheduleSettingsModel.fromJson(json);
}

/// @nodoc
mixin _$ChefScheduleSettingsModel {
  @JsonKey(name: 'chef_id')
  String get chefId => throw _privateConstructorUsedError;
  @JsonKey(name: 'buffer_time_minutes')
  int get bufferTimeMinutes => throw _privateConstructorUsedError;
  @JsonKey(name: 'max_bookings_per_day')
  int get maxBookingsPerDay => throw _privateConstructorUsedError;
  @JsonKey(name: 'min_notice_hours')
  int get minNoticeHours => throw _privateConstructorUsedError;
  @JsonKey(name: 'allow_same_day_booking')
  bool get allowSameDayBooking => throw _privateConstructorUsedError;
  @JsonKey(name: 'auto_accept_bookings')
  bool get autoAcceptBookings => throw _privateConstructorUsedError;
  @JsonKey(name: 'max_advance_booking_days')
  int get maxAdvanceBookingDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ChefScheduleSettingsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChefScheduleSettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChefScheduleSettingsModelCopyWith<ChefScheduleSettingsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChefScheduleSettingsModelCopyWith<$Res> {
  factory $ChefScheduleSettingsModelCopyWith(ChefScheduleSettingsModel value,
          $Res Function(ChefScheduleSettingsModel) then) =
      _$ChefScheduleSettingsModelCopyWithImpl<$Res, ChefScheduleSettingsModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'chef_id') String chefId,
      @JsonKey(name: 'buffer_time_minutes') int bufferTimeMinutes,
      @JsonKey(name: 'max_bookings_per_day') int maxBookingsPerDay,
      @JsonKey(name: 'min_notice_hours') int minNoticeHours,
      @JsonKey(name: 'allow_same_day_booking') bool allowSameDayBooking,
      @JsonKey(name: 'auto_accept_bookings') bool autoAcceptBookings,
      @JsonKey(name: 'max_advance_booking_days') int maxAdvanceBookingDays,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt});
}

/// @nodoc
class _$ChefScheduleSettingsModelCopyWithImpl<$Res,
        $Val extends ChefScheduleSettingsModel>
    implements $ChefScheduleSettingsModelCopyWith<$Res> {
  _$ChefScheduleSettingsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChefScheduleSettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chefId = null,
    Object? bufferTimeMinutes = null,
    Object? maxBookingsPerDay = null,
    Object? minNoticeHours = null,
    Object? allowSameDayBooking = null,
    Object? autoAcceptBookings = null,
    Object? maxAdvanceBookingDays = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      chefId: null == chefId
          ? _value.chefId
          : chefId // ignore: cast_nullable_to_non_nullable
              as String,
      bufferTimeMinutes: null == bufferTimeMinutes
          ? _value.bufferTimeMinutes
          : bufferTimeMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      maxBookingsPerDay: null == maxBookingsPerDay
          ? _value.maxBookingsPerDay
          : maxBookingsPerDay // ignore: cast_nullable_to_non_nullable
              as int,
      minNoticeHours: null == minNoticeHours
          ? _value.minNoticeHours
          : minNoticeHours // ignore: cast_nullable_to_non_nullable
              as int,
      allowSameDayBooking: null == allowSameDayBooking
          ? _value.allowSameDayBooking
          : allowSameDayBooking // ignore: cast_nullable_to_non_nullable
              as bool,
      autoAcceptBookings: null == autoAcceptBookings
          ? _value.autoAcceptBookings
          : autoAcceptBookings // ignore: cast_nullable_to_non_nullable
              as bool,
      maxAdvanceBookingDays: null == maxAdvanceBookingDays
          ? _value.maxAdvanceBookingDays
          : maxAdvanceBookingDays // ignore: cast_nullable_to_non_nullable
              as int,
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
abstract class _$$ChefScheduleSettingsModelImplCopyWith<$Res>
    implements $ChefScheduleSettingsModelCopyWith<$Res> {
  factory _$$ChefScheduleSettingsModelImplCopyWith(
          _$ChefScheduleSettingsModelImpl value,
          $Res Function(_$ChefScheduleSettingsModelImpl) then) =
      __$$ChefScheduleSettingsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'chef_id') String chefId,
      @JsonKey(name: 'buffer_time_minutes') int bufferTimeMinutes,
      @JsonKey(name: 'max_bookings_per_day') int maxBookingsPerDay,
      @JsonKey(name: 'min_notice_hours') int minNoticeHours,
      @JsonKey(name: 'allow_same_day_booking') bool allowSameDayBooking,
      @JsonKey(name: 'auto_accept_bookings') bool autoAcceptBookings,
      @JsonKey(name: 'max_advance_booking_days') int maxAdvanceBookingDays,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt});
}

/// @nodoc
class __$$ChefScheduleSettingsModelImplCopyWithImpl<$Res>
    extends _$ChefScheduleSettingsModelCopyWithImpl<$Res,
        _$ChefScheduleSettingsModelImpl>
    implements _$$ChefScheduleSettingsModelImplCopyWith<$Res> {
  __$$ChefScheduleSettingsModelImplCopyWithImpl(
      _$ChefScheduleSettingsModelImpl _value,
      $Res Function(_$ChefScheduleSettingsModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChefScheduleSettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chefId = null,
    Object? bufferTimeMinutes = null,
    Object? maxBookingsPerDay = null,
    Object? minNoticeHours = null,
    Object? allowSameDayBooking = null,
    Object? autoAcceptBookings = null,
    Object? maxAdvanceBookingDays = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$ChefScheduleSettingsModelImpl(
      chefId: null == chefId
          ? _value.chefId
          : chefId // ignore: cast_nullable_to_non_nullable
              as String,
      bufferTimeMinutes: null == bufferTimeMinutes
          ? _value.bufferTimeMinutes
          : bufferTimeMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      maxBookingsPerDay: null == maxBookingsPerDay
          ? _value.maxBookingsPerDay
          : maxBookingsPerDay // ignore: cast_nullable_to_non_nullable
              as int,
      minNoticeHours: null == minNoticeHours
          ? _value.minNoticeHours
          : minNoticeHours // ignore: cast_nullable_to_non_nullable
              as int,
      allowSameDayBooking: null == allowSameDayBooking
          ? _value.allowSameDayBooking
          : allowSameDayBooking // ignore: cast_nullable_to_non_nullable
              as bool,
      autoAcceptBookings: null == autoAcceptBookings
          ? _value.autoAcceptBookings
          : autoAcceptBookings // ignore: cast_nullable_to_non_nullable
              as bool,
      maxAdvanceBookingDays: null == maxAdvanceBookingDays
          ? _value.maxAdvanceBookingDays
          : maxAdvanceBookingDays // ignore: cast_nullable_to_non_nullable
              as int,
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
class _$ChefScheduleSettingsModelImpl extends _ChefScheduleSettingsModel {
  const _$ChefScheduleSettingsModelImpl(
      {@JsonKey(name: 'chef_id') required this.chefId,
      @JsonKey(name: 'buffer_time_minutes') this.bufferTimeMinutes = 60,
      @JsonKey(name: 'max_bookings_per_day') this.maxBookingsPerDay = 2,
      @JsonKey(name: 'min_notice_hours') this.minNoticeHours = 24,
      @JsonKey(name: 'allow_same_day_booking') this.allowSameDayBooking = false,
      @JsonKey(name: 'auto_accept_bookings') this.autoAcceptBookings = false,
      @JsonKey(name: 'max_advance_booking_days')
      this.maxAdvanceBookingDays = 180,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt})
      : super._();

  factory _$ChefScheduleSettingsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChefScheduleSettingsModelImplFromJson(json);

  @override
  @JsonKey(name: 'chef_id')
  final String chefId;
  @override
  @JsonKey(name: 'buffer_time_minutes')
  final int bufferTimeMinutes;
  @override
  @JsonKey(name: 'max_bookings_per_day')
  final int maxBookingsPerDay;
  @override
  @JsonKey(name: 'min_notice_hours')
  final int minNoticeHours;
  @override
  @JsonKey(name: 'allow_same_day_booking')
  final bool allowSameDayBooking;
  @override
  @JsonKey(name: 'auto_accept_bookings')
  final bool autoAcceptBookings;
  @override
  @JsonKey(name: 'max_advance_booking_days')
  final int maxAdvanceBookingDays;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  @override
  String toString() {
    return 'ChefScheduleSettingsModel(chefId: $chefId, bufferTimeMinutes: $bufferTimeMinutes, maxBookingsPerDay: $maxBookingsPerDay, minNoticeHours: $minNoticeHours, allowSameDayBooking: $allowSameDayBooking, autoAcceptBookings: $autoAcceptBookings, maxAdvanceBookingDays: $maxAdvanceBookingDays, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChefScheduleSettingsModelImpl &&
            (identical(other.chefId, chefId) || other.chefId == chefId) &&
            (identical(other.bufferTimeMinutes, bufferTimeMinutes) ||
                other.bufferTimeMinutes == bufferTimeMinutes) &&
            (identical(other.maxBookingsPerDay, maxBookingsPerDay) ||
                other.maxBookingsPerDay == maxBookingsPerDay) &&
            (identical(other.minNoticeHours, minNoticeHours) ||
                other.minNoticeHours == minNoticeHours) &&
            (identical(other.allowSameDayBooking, allowSameDayBooking) ||
                other.allowSameDayBooking == allowSameDayBooking) &&
            (identical(other.autoAcceptBookings, autoAcceptBookings) ||
                other.autoAcceptBookings == autoAcceptBookings) &&
            (identical(other.maxAdvanceBookingDays, maxAdvanceBookingDays) ||
                other.maxAdvanceBookingDays == maxAdvanceBookingDays) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      chefId,
      bufferTimeMinutes,
      maxBookingsPerDay,
      minNoticeHours,
      allowSameDayBooking,
      autoAcceptBookings,
      maxAdvanceBookingDays,
      createdAt,
      updatedAt);

  /// Create a copy of ChefScheduleSettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChefScheduleSettingsModelImplCopyWith<_$ChefScheduleSettingsModelImpl>
      get copyWith => __$$ChefScheduleSettingsModelImplCopyWithImpl<
          _$ChefScheduleSettingsModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChefScheduleSettingsModelImplToJson(
      this,
    );
  }
}

abstract class _ChefScheduleSettingsModel extends ChefScheduleSettingsModel {
  const factory _ChefScheduleSettingsModel(
      {@JsonKey(name: 'chef_id') required final String chefId,
      @JsonKey(name: 'buffer_time_minutes') final int bufferTimeMinutes,
      @JsonKey(name: 'max_bookings_per_day') final int maxBookingsPerDay,
      @JsonKey(name: 'min_notice_hours') final int minNoticeHours,
      @JsonKey(name: 'allow_same_day_booking') final bool allowSameDayBooking,
      @JsonKey(name: 'auto_accept_bookings') final bool autoAcceptBookings,
      @JsonKey(name: 'max_advance_booking_days')
      final int maxAdvanceBookingDays,
      @JsonKey(name: 'created_at') final String? createdAt,
      @JsonKey(name: 'updated_at')
      final String? updatedAt}) = _$ChefScheduleSettingsModelImpl;
  const _ChefScheduleSettingsModel._() : super._();

  factory _ChefScheduleSettingsModel.fromJson(Map<String, dynamic> json) =
      _$ChefScheduleSettingsModelImpl.fromJson;

  @override
  @JsonKey(name: 'chef_id')
  String get chefId;
  @override
  @JsonKey(name: 'buffer_time_minutes')
  int get bufferTimeMinutes;
  @override
  @JsonKey(name: 'max_bookings_per_day')
  int get maxBookingsPerDay;
  @override
  @JsonKey(name: 'min_notice_hours')
  int get minNoticeHours;
  @override
  @JsonKey(name: 'allow_same_day_booking')
  bool get allowSameDayBooking;
  @override
  @JsonKey(name: 'auto_accept_bookings')
  bool get autoAcceptBookings;
  @override
  @JsonKey(name: 'max_advance_booking_days')
  int get maxAdvanceBookingDays;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  String? get updatedAt;

  /// Create a copy of ChefScheduleSettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChefScheduleSettingsModelImplCopyWith<_$ChefScheduleSettingsModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
