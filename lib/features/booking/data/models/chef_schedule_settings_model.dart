import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/chef_schedule_settings.dart';

part 'chef_schedule_settings_model.freezed.dart';
part 'chef_schedule_settings_model.g.dart';

@freezed
class ChefScheduleSettingsModel with _$ChefScheduleSettingsModel {
  const factory ChefScheduleSettingsModel({
    @JsonKey(name: 'chef_id') required String chefId,
    @JsonKey(name: 'buffer_time_minutes') @Default(60) int bufferTimeMinutes,
    @JsonKey(name: 'max_bookings_per_day') @Default(2) int maxBookingsPerDay,
    @JsonKey(name: 'min_notice_hours') @Default(24) int minNoticeHours,
    @JsonKey(name: 'allow_same_day_booking') @Default(false) bool allowSameDayBooking,
    @JsonKey(name: 'auto_accept_bookings') @Default(false) bool autoAcceptBookings,
    @JsonKey(name: 'max_advance_booking_days') @Default(180) int maxAdvanceBookingDays,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _ChefScheduleSettingsModel;

  const ChefScheduleSettingsModel._();

  factory ChefScheduleSettingsModel.fromJson(Map<String, dynamic> json) =>
      _$ChefScheduleSettingsModelFromJson(json);

  ChefScheduleSettings toDomain() {
    return ChefScheduleSettings(
      chefId: chefId,
      bufferTimeMinutes: bufferTimeMinutes,
      maxBookingsPerDay: maxBookingsPerDay,
      minNoticeHours: minNoticeHours,
      allowSameDayBooking: allowSameDayBooking,
      autoAcceptBookings: autoAcceptBookings,
      maxAdvanceBookingDays: maxAdvanceBookingDays,
    );
  }

  static ChefScheduleSettingsModel fromDomain(ChefScheduleSettings entity) {
    return ChefScheduleSettingsModel(
      chefId: entity.chefId,
      bufferTimeMinutes: entity.bufferTimeMinutes,
      maxBookingsPerDay: entity.maxBookingsPerDay,
      minNoticeHours: entity.minNoticeHours,
      allowSameDayBooking: entity.allowSameDayBooking,
      autoAcceptBookings: entity.autoAcceptBookings,
      maxAdvanceBookingDays: entity.maxAdvanceBookingDays,
    );
  }
}