// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chef_schedule_settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChefScheduleSettingsModelImpl _$$ChefScheduleSettingsModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ChefScheduleSettingsModelImpl(
      chefId: json['chef_id'] as String,
      bufferTimeMinutes: (json['buffer_time_minutes'] as num?)?.toInt() ?? 60,
      maxBookingsPerDay: (json['max_bookings_per_day'] as num?)?.toInt() ?? 2,
      minNoticeHours: (json['min_notice_hours'] as num?)?.toInt() ?? 24,
      allowSameDayBooking: json['allow_same_day_booking'] as bool? ?? false,
      autoAcceptBookings: json['auto_accept_bookings'] as bool? ?? false,
      maxAdvanceBookingDays:
          (json['max_advance_booking_days'] as num?)?.toInt() ?? 180,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$$ChefScheduleSettingsModelImplToJson(
        _$ChefScheduleSettingsModelImpl instance) =>
    <String, dynamic>{
      'chef_id': instance.chefId,
      'buffer_time_minutes': instance.bufferTimeMinutes,
      'max_bookings_per_day': instance.maxBookingsPerDay,
      'min_notice_hours': instance.minNoticeHours,
      'allow_same_day_booking': instance.allowSameDayBooking,
      'auto_accept_bookings': instance.autoAcceptBookings,
      'max_advance_booking_days': instance.maxAdvanceBookingDays,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
