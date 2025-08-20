// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chef_working_hours_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChefWorkingHoursModelImpl _$$ChefWorkingHoursModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ChefWorkingHoursModelImpl(
      chefId: json['chef_id'] as String,
      dayOfWeek: (json['day_of_week'] as num).toInt(),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$$ChefWorkingHoursModelImplToJson(
        _$ChefWorkingHoursModelImpl instance) =>
    <String, dynamic>{
      'chef_id': instance.chefId,
      'day_of_week': instance.dayOfWeek,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'is_active': instance.isActive,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
