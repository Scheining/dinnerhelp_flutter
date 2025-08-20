// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chef_availability_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChefAvailabilityModelImpl _$$ChefAvailabilityModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ChefAvailabilityModelImpl(
      id: json['id'] as String?,
      chefId: json['chef_id'] as String,
      date: json['date'] as String,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      availabilityType: json['availability_type'] as String,
      reason: json['reason'] as String?,
      overridesWorkingHours: json['overrides_working_hours'] as bool? ?? false,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$$ChefAvailabilityModelImplToJson(
        _$ChefAvailabilityModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chef_id': instance.chefId,
      'date': instance.date,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'availability_type': instance.availabilityType,
      'reason': instance.reason,
      'overrides_working_hours': instance.overridesWorkingHours,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
