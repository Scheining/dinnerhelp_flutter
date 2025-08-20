import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/chef_availability.dart';

part 'chef_availability_model.freezed.dart';
part 'chef_availability_model.g.dart';

@freezed
class ChefAvailabilityModel with _$ChefAvailabilityModel {
  const factory ChefAvailabilityModel({
    @JsonKey(name: 'id') String? id,
    @JsonKey(name: 'chef_id') required String chefId,
    @JsonKey(name: 'date') required String date, // ISO date string
    @JsonKey(name: 'start_time') String? startTime,
    @JsonKey(name: 'end_time') String? endTime,
    @JsonKey(name: 'availability_type') required String availabilityType,
    @JsonKey(name: 'reason') String? reason,
    @JsonKey(name: 'overrides_working_hours') @Default(false) bool overridesWorkingHours,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _ChefAvailabilityModel;

  const ChefAvailabilityModel._();

  factory ChefAvailabilityModel.fromJson(Map<String, dynamic> json) =>
      _$ChefAvailabilityModelFromJson(json);

  ChefAvailability toDomain() {
    return ChefAvailability(
      chefId: chefId,
      date: DateTime.parse(date),
      startTime: startTime,
      endTime: endTime,
      type: _parseAvailabilityType(availabilityType),
      reason: reason,
      overridesWorkingHours: overridesWorkingHours,
    );
  }

  static ChefAvailabilityModel fromDomain(ChefAvailability entity) {
    return ChefAvailabilityModel(
      chefId: entity.chefId,
      date: entity.date.toIso8601String().split('T')[0], // Date only
      startTime: entity.startTime,
      endTime: entity.endTime,
      availabilityType: _availabilityTypeToString(entity.type),
      reason: entity.reason,
      overridesWorkingHours: entity.overridesWorkingHours,
    );
  }

  static AvailabilityType _parseAvailabilityType(String type) {
    switch (type.toLowerCase()) {
      case 'available':
        return AvailabilityType.available;
      case 'unavailable':
        return AvailabilityType.unavailable;
      case 'busy':
        return AvailabilityType.busy;
      default:
        throw ArgumentError('Invalid availability type: $type');
    }
  }

  static String _availabilityTypeToString(AvailabilityType type) {
    switch (type) {
      case AvailabilityType.available:
        return 'available';
      case AvailabilityType.unavailable:
        return 'unavailable';
      case AvailabilityType.busy:
        return 'busy';
    }
  }
}