import 'package:dartz/dartz.dart';
import 'package:homechef/core/error/failures.dart';
import '../entities/chef_working_hours.dart';
import '../entities/chef_availability.dart';
import '../entities/chef_schedule_settings.dart';
import '../entities/chef_time_off.dart';
import '../entities/time_slot.dart';
import '../repositories/chef_schedule_repository.dart';

/// Service for managing chef schedules, working hours, and availability
class ChefScheduleService {
  final ChefScheduleRepository _repository;

  const ChefScheduleService(this._repository);

  /// Get chef's working hours for a specific day of the week
  /// @param dayOfWeek: 0 = Sunday, 1 = Monday, ..., 6 = Saturday
  Future<Either<Failure, ChefWorkingHours?>> getWorkingHours(
    String chefId, 
    int dayOfWeek,
  ) async {
    if (chefId.isEmpty) {
      return const Left(ValidationFailure('Chef ID cannot be empty'));
    }

    if (dayOfWeek < 0 || dayOfWeek > 6) {
      return const Left(ValidationFailure('Day of week must be between 0 (Sunday) and 6 (Saturday)'));
    }

    return await _repository.getWorkingHours(
      chefId: chefId,
      dayOfWeek: dayOfWeek,
    );
  }

  /// Get all working hours for a chef
  Future<Either<Failure, List<ChefWorkingHours>>> getAllWorkingHours(String chefId) async {
    if (chefId.isEmpty) {
      return const Left(ValidationFailure('Chef ID cannot be empty'));
    }

    return await _repository.getAllWorkingHours(chefId: chefId);
  }

  /// Get chef's time off periods within a date range
  Future<Either<Failure, List<ChefTimeOff>>> getTimeOffPeriods(
    String chefId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (chefId.isEmpty) {
      return const Left(ValidationFailure('Chef ID cannot be empty'));
    }

    if (endDate.isBefore(startDate)) {
      return const Left(ValidationFailure('End date cannot be before start date'));
    }

    // Limit the range to prevent excessive queries
    final maxRangeDays = 365; // 1 year maximum
    if (endDate.difference(startDate).inDays > maxRangeDays) {
      return const Left(ValidationFailure('Date range cannot exceed 1 year'));
    }

    return await _repository.getTimeOffPeriods(
      chefId: chefId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Get chef's specific availability overrides for a date
  Future<Either<Failure, List<ChefAvailability>>> getSpecificAvailability(
    String chefId,
    DateTime date,
  ) async {
    if (chefId.isEmpty) {
      return const Left(ValidationFailure('Chef ID cannot be empty'));
    }

    final dateOnly = DateTime(date.year, date.month, date.day);
    final nextDay = dateOnly.add(const Duration(days: 1));

    return await _repository.getSpecificAvailability(
      chefId: chefId,
      startDate: dateOnly,
      endDate: nextDay,
    );
  }

  /// Calculate buffer time for a chef (in minutes)
  Future<Either<Failure, Duration>> calculateBufferTime(String chefId) async {
    final settingsResult = await getScheduleSettings(chefId);
    
    return settingsResult.fold(
      (failure) => Left(failure),
      (settings) => Right(settings.bufferTime),
    );
  }

  /// Get maximum bookings per day for a chef
  Future<Either<Failure, int>> getMaxBookingsPerDay(String chefId) async {
    final settingsResult = await getScheduleSettings(chefId);
    
    return settingsResult.fold(
      (failure) => Left(failure),
      (settings) => Right(settings.maxBookingsPerDay),
    );
  }

  /// Get chef's schedule settings
  Future<Either<Failure, ChefScheduleSettings>> getScheduleSettings(String chefId) async {
    if (chefId.isEmpty) {
      return const Left(ValidationFailure('Chef ID cannot be empty'));
    }

    return await _repository.getScheduleSettings(chefId: chefId);
  }

  /// Check if chef is working on a specific date
  Future<Either<Failure, bool>> isWorkingDay(String chefId, DateTime date) async {
    if (chefId.isEmpty) {
      return const Left(ValidationFailure('Chef ID cannot be empty'));
    }

    // Get working hours for this day of week
    final dayOfWeek = date.weekday % 7; // Convert to 0-6 format
    final workingHoursResult = await getWorkingHours(chefId, dayOfWeek);
    
    if (workingHoursResult.isLeft()) {
      return workingHoursResult.fold((failure) => Left(failure), (_) => throw UnimplementedError());
    }

    final workingHours = workingHoursResult.fold((_) => throw UnimplementedError(), (hours) => hours);
    if (workingHours == null || !workingHours.isActive) {
      return const Right(false);
    }

    // Check for time off on this specific date
    final timeOffResult = await getTimeOffPeriods(chefId, date, date);
    if (timeOffResult.isLeft()) {
      return timeOffResult.fold((failure) => Left(failure), (_) => throw UnimplementedError());
    }

    final timeOffPeriods = timeOffResult.fold((_) => throw UnimplementedError(), (periods) => periods);
    final hasTimeOff = timeOffPeriods.any((timeOff) => timeOff.includesDate(date));

    if (hasTimeOff) {
      return const Right(false);
    }

    // Check for specific availability overrides
    final availabilityResult = await getSpecificAvailability(chefId, date);
    if (availabilityResult.isLeft()) {
      return availabilityResult.fold((failure) => Left(failure), (_) => throw UnimplementedError());
    }

    final specificAvailability = availabilityResult.fold((_) => throw UnimplementedError(), (avail) => avail);
    
    // If there's an all-day unavailability override, chef is not working
    final allDayUnavailable = specificAvailability
        .where((avail) => avail.isAllDay && avail.isUnavailable)
        .isNotEmpty;

    if (allDayUnavailable) {
      return const Right(false);
    }

    // If there's an all-day availability override that overrides working hours
    final allDayAvailable = specificAvailability
        .where((avail) => avail.isAllDay && avail.isAvailable && avail.overridesWorkingHours)
        .isNotEmpty;

    if (allDayAvailable) {
      return const Right(true);
    }

    // Default to working hours
    return const Right(true);
  }

  /// Get chef's effective working hours for a specific date
  /// Takes into account specific availability overrides
  Future<Either<Failure, List<TimeSlot>>> getEffectiveWorkingHours(
    String chefId,
    DateTime date,
  ) async {
    // Get regular working hours
    final dayOfWeek = date.weekday % 7;
    final workingHoursResult = await getWorkingHours(chefId, dayOfWeek);
    
    if (workingHoursResult.isLeft()) {
      return workingHoursResult.fold((failure) => Left(failure), (_) => throw UnimplementedError());
    }

    final workingHours = workingHoursResult.fold((_) => throw UnimplementedError(), (hours) => hours);
    if (workingHours == null) {
      return const Right([]);
    }

    // Get specific availability for the date
    final availabilityResult = await getSpecificAvailability(chefId, date);
    if (availabilityResult.isLeft()) {
      return availabilityResult.fold((failure) => Left(failure), (_) => throw UnimplementedError());
    }

    final specificAvailability = availabilityResult.fold((_) => throw UnimplementedError(), (avail) => avail);

    // Apply availability overrides
    final timeSlots = _applyAvailabilityOverrides(
      workingHours,
      date,
      specificAvailability,
    );

    return Right(timeSlots);
  }

  /// Update chef's working hours
  Future<Either<Failure, void>> updateWorkingHours(
    String chefId,
    List<ChefWorkingHours> workingHours,
  ) async {
    if (chefId.isEmpty) {
      return const Left(ValidationFailure('Chef ID cannot be empty'));
    }

    // Validate working hours
    for (final hours in workingHours) {
      if (hours.chefId != chefId) {
        return const Left(ValidationFailure('All working hours must belong to the same chef'));
      }

      if (!_isValidTimeFormat(hours.startTime) || !_isValidTimeFormat(hours.endTime)) {
        return const Left(ValidationFailure('Invalid time format in working hours'));
      }

      if (hours.dayOfWeek < 0 || hours.dayOfWeek > 6) {
        return const Left(ValidationFailure('Invalid day of week in working hours'));
      }
    }

    return await _repository.updateWorkingHours(
      chefId: chefId,
      workingHours: workingHours,
    );
  }

  /// Add time off period for chef
  Future<Either<Failure, void>> addTimeOff(String chefId, ChefTimeOff timeOff) async {
    if (chefId.isEmpty) {
      return const Left(ValidationFailure('Chef ID cannot be empty'));
    }

    if (timeOff.chefId != chefId) {
      return const Left(ValidationFailure('Time off must belong to the specified chef'));
    }

    if (timeOff.endDate.isBefore(timeOff.startDate)) {
      return const Left(ValidationFailure('Time off end date cannot be before start date'));
    }

    // Don't allow time off more than 2 years in advance
    final maxAdvanceDate = DateTime.now().add(const Duration(days: 730));
    if (timeOff.startDate.isAfter(maxAdvanceDate)) {
      return const Left(ValidationFailure('Time off cannot be scheduled more than 2 years in advance'));
    }

    return await _repository.addTimeOff(chefId: chefId, timeOff: timeOff);
  }

  /// Update chef's schedule settings
  Future<Either<Failure, void>> updateScheduleSettings(
    String chefId,
    ChefScheduleSettings settings,
  ) async {
    if (chefId.isEmpty) {
      return const Left(ValidationFailure('Chef ID cannot be empty'));
    }

    if (settings.chefId != chefId) {
      return const Left(ValidationFailure('Schedule settings must belong to the specified chef'));
    }

    // Validate settings
    if (settings.bufferTimeMinutes < 0 || settings.bufferTimeMinutes > 480) { // Max 8 hours
      return const Left(ValidationFailure('Buffer time must be between 0 and 480 minutes'));
    }

    if (settings.maxBookingsPerDay < 1 || settings.maxBookingsPerDay > 10) {
      return const Left(ValidationFailure('Max bookings per day must be between 1 and 10'));
    }

    if (settings.minNoticeHours < 0 || settings.minNoticeHours > 168) { // Max 1 week
      return const Left(ValidationFailure('Min notice hours must be between 0 and 168'));
    }

    if (settings.maxAdvanceBookingDays < 1 || settings.maxAdvanceBookingDays > 365) {
      return const Left(ValidationFailure('Max advance booking days must be between 1 and 365'));
    }

    return await _repository.updateScheduleSettings(
      chefId: chefId,
      settings: settings,
    );
  }

  // Private helper methods

  List<TimeSlot> _applyAvailabilityOverrides(
    ChefWorkingHours workingHours,
    DateTime date,
    List<ChefAvailability> specificAvailability,
  ) {
    final workStart = workingHours.getStartTimeForDate(date);
    final workEnd = workingHours.getEndTimeForDate(date);

    // Check for all-day overrides first
    final allDayUnavailable = specificAvailability
        .where((avail) => avail.isAllDay && avail.isUnavailable)
        .isNotEmpty;

    if (allDayUnavailable) {
      return []; // No available time
    }

    final allDayAvailable = specificAvailability
        .where((avail) => avail.isAllDay && avail.isAvailable)
        .isNotEmpty;

    if (allDayAvailable) {
      return [
        TimeSlot(
          startTime: workStart,
          endTime: workEnd,
          isAvailable: true,
        ),
      ];
    }

    // Apply specific time-based overrides
    final timeSlots = <TimeSlot>[];
    
    // For now, return basic working hours
    // In a full implementation, this would split the working hours
    // based on specific availability overrides
    timeSlots.add(TimeSlot(
      startTime: workStart,
      endTime: workEnd,
      isAvailable: true,
    ));

    return timeSlots;
  }

  bool _isValidTimeFormat(String time) {
    final regex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
    return regex.hasMatch(time);
  }
}

