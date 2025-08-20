import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/chef_working_hours.dart';

part 'chef_working_hours_model.freezed.dart';
part 'chef_working_hours_model.g.dart';

@freezed
class ChefWorkingHoursModel with _$ChefWorkingHoursModel {
  const factory ChefWorkingHoursModel({
    @JsonKey(name: 'chef_id') required String chefId,
    @JsonKey(name: 'day_of_week') required int dayOfWeek,
    @JsonKey(name: 'start_time') required String startTime,
    @JsonKey(name: 'end_time') required String endTime,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _ChefWorkingHoursModel;

  const ChefWorkingHoursModel._();

  factory ChefWorkingHoursModel.fromJson(Map<String, dynamic> json) =>
      _$ChefWorkingHoursModelFromJson(json);

  ChefWorkingHours toDomain() {
    return ChefWorkingHours(
      chefId: chefId,
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
      isActive: isActive,
    );
  }

  static ChefWorkingHoursModel fromDomain(ChefWorkingHours entity) {
    return ChefWorkingHoursModel(
      chefId: entity.chefId,
      dayOfWeek: entity.dayOfWeek,
      startTime: entity.startTime,
      endTime: entity.endTime,
      isActive: entity.isActive,
    );
  }
}