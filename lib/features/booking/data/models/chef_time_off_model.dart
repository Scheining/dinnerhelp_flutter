import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/chef_time_off.dart';

part 'chef_time_off_model.freezed.dart';
part 'chef_time_off_model.g.dart';

@freezed
class ChefTimeOffModel with _$ChefTimeOffModel {
  const factory ChefTimeOffModel({
    @JsonKey(name: 'id') String? id,
    @JsonKey(name: 'chef_id') required String chefId,
    @JsonKey(name: 'start_date') required String startDate, // ISO date string
    @JsonKey(name: 'end_date') required String endDate, // ISO date string
    @JsonKey(name: 'time_off_type') required String timeOffType,
    @JsonKey(name: 'reason') String? reason,
    @JsonKey(name: 'is_recurring') @Default(false) bool isRecurring,
    @JsonKey(name: 'is_approved') @Default(true) bool isApproved,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _ChefTimeOffModel;

  const ChefTimeOffModel._();

  factory ChefTimeOffModel.fromJson(Map<String, dynamic> json) =>
      _$ChefTimeOffModelFromJson(json);

  ChefTimeOff toDomain() {
    return ChefTimeOff(
      chefId: chefId,
      startDate: DateTime.parse(startDate),
      endDate: DateTime.parse(endDate),
      type: _parseTimeOffType(timeOffType),
      reason: reason,
      isRecurring: isRecurring,
      isApproved: isApproved,
    );
  }

  static ChefTimeOffModel fromDomain(ChefTimeOff entity) {
    return ChefTimeOffModel(
      chefId: entity.chefId,
      startDate: entity.startDate.toIso8601String(),
      endDate: entity.endDate.toIso8601String(),
      timeOffType: _timeOffTypeToString(entity.type),
      reason: entity.reason,
      isRecurring: entity.isRecurring,
      isApproved: entity.isApproved,
    );
  }

  static TimeOffType _parseTimeOffType(String type) {
    switch (type.toLowerCase()) {
      case 'vacation':
        return TimeOffType.vacation;
      case 'holiday':
        return TimeOffType.holiday;
      case 'sick_leave':
        return TimeOffType.sickLeave;
      case 'personal_time':
        return TimeOffType.personalTime;
      case 'maintenance':
        return TimeOffType.maintenance;
      default:
        throw ArgumentError('Invalid time off type: $type');
    }
  }

  static String _timeOffTypeToString(TimeOffType type) {
    switch (type) {
      case TimeOffType.vacation:
        return 'vacation';
      case TimeOffType.holiday:
        return 'holiday';
      case TimeOffType.sickLeave:
        return 'sick_leave';
      case TimeOffType.personalTime:
        return 'personal_time';
      case TimeOffType.maintenance:
        return 'maintenance';
    }
  }
}