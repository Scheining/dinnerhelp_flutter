// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chef_time_off_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChefTimeOffModelImpl _$$ChefTimeOffModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ChefTimeOffModelImpl(
      id: json['id'] as String?,
      chefId: json['chef_id'] as String,
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
      timeOffType: json['time_off_type'] as String,
      reason: json['reason'] as String?,
      isRecurring: json['is_recurring'] as bool? ?? false,
      isApproved: json['is_approved'] as bool? ?? true,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$$ChefTimeOffModelImplToJson(
        _$ChefTimeOffModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chef_id': instance.chefId,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'time_off_type': instance.timeOffType,
      'reason': instance.reason,
      'is_recurring': instance.isRecurring,
      'is_approved': instance.isApproved,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
