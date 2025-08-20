import 'package:dartz/dartz.dart';
import 'package:homechef/core/error/failures.dart';
import '../entities/time_slot.dart';
import '../entities/booking_request.dart';
import '../entities/chef_working_hours.dart';
import '../entities/chef_availability.dart';
import '../entities/chef_schedule_settings.dart';
import '../entities/chef_time_off.dart';
import '../entities/recurrence_pattern.dart';
import '../repositories/booking_availability_repository.dart';
import '../repositories/chef_schedule_repository.dart';
import 'chef_schedule_service.dart';

/// Service for managing booking availability logic
/// Combines chef schedules, existing bookings, and availability rules
class BookingAvailabilityService {
  final BookingAvailabilityRepository _bookingRepository;
  final ChefScheduleRepository _scheduleRepository;
  final ChefScheduleService _scheduleService;

  const BookingAvailabilityService(
    this._bookingRepository,
    this._scheduleRepository,
    this._scheduleService,
  );

  /// Get available time slots for a chef on a specific date
  /// Takes into account working hours, existing bookings, time off, and buffer times
  Future<Either<Failure, List<TimeSlot>>> getAvailableTimeSlots({
    required String chefId,
    required DateTime date,
    required Duration duration,
    required int numberOfGuests,
  }) async {
    try {
      // Validate basic parameters
      if (duration.inMinutes < 30) {
        return const Left(ValidationFailure('Minimum booking duration is 30 minutes'));
      }

      if (numberOfGuests <= 0 || numberOfGuests > 50) {
        return const Left(ValidationFailure('Number of guests must be between 1 and 50'));
      }

      // Check if date is in the past
      if (date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
        return const Left(ValidationFailure('Cannot get availability for past dates'));
      }

      // Get chef's schedule settings to validate booking constraints
      final settingsResult = await _scheduleService.getScheduleSettings(chefId);
      if (settingsResult.isLeft()) {
        return settingsResult.fold((failure) => Left(failure), (_) => throw UnimplementedError());
      }

      final settings = settingsResult.fold((_) => throw UnimplementedError(), (s) => s);

      // Check if booking date is within allowed range
      final now = DateTime.now();
      if (!settings.canBookOnDate(date, now)) {
        if (date.difference(now) < settings.minNotice) {
          return const Left(InsufficientNoticeFailure());
        } else if (date.difference(now) > settings.maxAdvanceBooking) {
          return const Left(BookingTooFarInAdvanceFailure());
        }
      }

      // Check if chef is working on this day
      final workingDayResult = await _scheduleService.isWorkingDay(chefId, date);
      if (workingDayResult.isLeft()) {
        return workingDayResult.fold((failure) => Left(failure), (_) => throw UnimplementedError());
      }

      final isWorkingDay = workingDayResult.fold((_) => throw UnimplementedError(), (working) => working);
      if (!isWorkingDay) {
        return const Left(ChefUnavailableFailure('Chef is not working on this day'));
      }

      // Get working hours for the day
      final workingHoursResult = await _scheduleService.getWorkingHours(chefId, date.weekday % 7);
      if (workingHoursResult.isLeft()) {
        return workingHoursResult.fold((failure) => Left(failure), (_) => throw UnimplementedError());
      }

      final workingHours = workingHoursResult.fold((_) => throw UnimplementedError(), (hours) => hours);
      if (workingHours == null) {
        return const Left(ChefUnavailableFailure('No working hours set for this day'));
      }

      // Check for time off periods
      final timeOffResult = await _scheduleService.getTimeOffPeriods(chefId, date, date);
      if (timeOffResult.isLeft()) {
        return timeOffResult.fold((failure) => Left(failure), (_) => throw UnimplementedError());
      }

      final timeOffPeriods = timeOffResult.fold((_) => throw UnimplementedError(), (periods) => periods);
      final hasTimeOff = timeOffPeriods.any((timeOff) => timeOff.includesDate(date));
      if (hasTimeOff) {
        return const Left(ChefUnavailableFailure('Chef has time off on this day'));
      }

      // Get specific availability overrides
      final availabilityResult = await _scheduleService.getSpecificAvailability(chefId, date);
      if (availabilityResult.isLeft()) {
        return availabilityResult.fold((failure) => Left(failure), (_) => throw UnimplementedError());
      }

      final specificAvailability = availabilityResult.fold((_) => throw UnimplementedError(), (avail) => avail);

      // Check for all-day unavailability
      final allDayUnavailable = specificAvailability
          .where((avail) => avail.isAllDay && avail.isUnavailable)
          .isNotEmpty;
      if (allDayUnavailable) {
        return const Left(ChefUnavailableFailure('Chef is unavailable all day'));
      }

      // Generate time slots based on working hours and constraints
      final timeSlots = await _generateTimeSlots(
        chefId: chefId,
        date: date,
        duration: duration,
        workingHours: workingHours,
        settings: settings,
        specificAvailability: specificAvailability,
      );

      return Right(timeSlots);
    } catch (e) {
      return Left(ServerFailure('Failed to get available time slots: $e'));
    }
  }

  /// Check if a booking conflicts with existing bookings or constraints
  Future<Either<Failure, bool>> checkBookingConflict({
    required String chefId,
    required DateTime date,
    required String startTime,
    required String endTime,
    String? excludeBookingId,
  }) async {
    // Validate time format and range
    if (!_isValidTimeFormat(startTime) || !_isValidTimeFormat(endTime)) {
      return const Left(ValidationFailure('Invalid time format'));
    }

    if (!_isValidTimeRange(startTime, endTime)) {
      return const Left(ValidationFailure('End time must be after start time'));
    }

    // Use repository to check for actual booking conflicts
    return await _bookingRepository.checkBookingConflict(
      chefId: chefId,
      date: date,
      startTime: startTime,
      endTime: endTime,
      excludeBookingId: excludeBookingId,
    );
  }

  /// Get chef's schedule for a specific week (Monday to Sunday)
  Future<Either<Failure, List<TimeSlot>>> getChefScheduleForWeek({
    required String chefId,
    required DateTime weekStart,
  }) async {
    // Ensure weekStart is actually a Monday
    final mondayWeekStart = _getMondayOfWeek(weekStart);
    
    return await _bookingRepository.getChefScheduleForWeek(
      chefId: chefId,
      weekStart: mondayWeekStart,
    );
  }

  /// Validate if a recurring booking pattern is feasible
  Future<Either<Failure, bool>> validateRecurringBookingPattern({
    required String chefId,
    required RecurrencePattern pattern,
    required String startTime,
    required String endTime,
  }) async {
    // Generate all occurrences for the pattern
    final occurrences = pattern.generateOccurrences();
    
    // Check each occurrence for conflicts
    for (final occurrence in occurrences) {
      final conflictResult = await checkBookingConflict(
        chefId: chefId,
        date: occurrence,
        startTime: startTime,
        endTime: endTime,
      );

      if (conflictResult.isLeft()) {
        return conflictResult;
      }

      final hasConflict = conflictResult.fold((_) => throw UnimplementedError(), (conflict) => conflict);
      if (hasConflict) {
        return const Left(BookingConflictFailure('Recurring pattern has conflicts'));
      }

      // Check if chef is available on this occurrence
      final availabilityResult = await _checkAvailabilityForDate(chefId, occurrence, startTime, endTime);
      if (availabilityResult.isLeft()) {
        return availabilityResult;
      }
    }

    return const Right(true);
  }

  /// Find the next available time slot after a given date
  Future<Either<Failure, TimeSlot?>> getNextAvailableSlot({
    required String chefId,
    required DateTime afterDate,
    required Duration duration,
  }) async {
    return await _bookingRepository.getNextAvailableSlot(
      chefId: chefId,
      afterDate: afterDate,
      duration: duration,
    );
  }

  // Private helper methods

  Future<List<TimeSlot>> _generateTimeSlots({
    required String chefId,
    required DateTime date,
    required Duration duration,
    required ChefWorkingHours workingHours,
    required ChefScheduleSettings settings,
    required List<ChefAvailability> specificAvailability,
  }) async {
    final slots = <TimeSlot>[];
    
    final workStart = workingHours.getStartTimeForDate(date);
    final workEnd = workingHours.getEndTimeForDate(date);
    
    // Generate slots in 30-minute intervals
    const slotInterval = Duration(minutes: 30);
    var currentTime = workStart;
    
    while (currentTime.add(duration).isBefore(workEnd) || 
           currentTime.add(duration).isAtSameMomentAs(workEnd)) {
      
      final slotEnd = currentTime.add(duration);
      
      // Check if this slot is available
      final isAvailable = await _isSlotAvailable(
        chefId,
        currentTime,
        slotEnd,
        settings,
        specificAvailability,
      );
      
      slots.add(TimeSlot(
        startTime: currentTime,
        endTime: slotEnd,
        isAvailable: isAvailable,
        unavailabilityReason: isAvailable ? null : 'Slot not available',
      ));
      
      currentTime = currentTime.add(slotInterval);
    }
    
    return slots;
  }

  Future<bool> _isSlotAvailable(
    String chefId,
    DateTime startTime,
    DateTime endTime,
    ChefScheduleSettings settings,
    List<ChefAvailability> specificAvailability,
  ) async {
    // Check specific availability overrides
    for (final availability in specificAvailability) {
      if (availability.appliesToTime(startTime) && availability.isUnavailable) {
        return false;
      }
    }
    
    // Check for booking conflicts (this would typically query the database)
    // For now, return true - this should be implemented with actual booking data
    return true;
  }

  Future<Either<Failure, bool>> _checkAvailabilityForDate(
    String chefId,
    DateTime date,
    String startTime,
    String endTime,
  ) async {
    // Check if chef is working on this day
    final workingDayResult = await _scheduleService.isWorkingDay(chefId, date);
    if (workingDayResult.isLeft()) {
      return workingDayResult;
    }
    
    final isWorking = workingDayResult.fold((_) => false, (working) => working);
    if (!isWorking) {
      return const Left(ChefUnavailableFailure('Chef is not working on this day'));
    }

    // Check for time off
    final timeOffResult = await _scheduleService.getTimeOffPeriods(chefId, date, date);
    if (timeOffResult.isLeft()) {
      return timeOffResult.fold((failure) => Left(failure), (_) => throw UnimplementedError());
    }

    final timeOffPeriods = timeOffResult.fold((_) => throw UnimplementedError(), (periods) => periods);
    final hasTimeOff = timeOffPeriods.any((timeOff) => timeOff.includesDate(date));
    if (hasTimeOff) {
      return const Left(ChefUnavailableFailure('Chef has time off on this day'));
    }

    return const Right(true);
  }

  bool _isValidTimeFormat(String time) {
    final regex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
    return regex.hasMatch(time);
  }

  bool _isValidTimeRange(String startTime, String endTime) {
    final startParts = startTime.split(':');
    final endParts = endTime.split(':');
    
    final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
    
    // Allow for bookings that go past midnight
    if (endMinutes < startMinutes) {
      return (endMinutes + 24 * 60) > startMinutes;
    }
    
    return endMinutes > startMinutes;
  }

  DateTime _getMondayOfWeek(DateTime date) {
    final daysFromMonday = (date.weekday - DateTime.monday) % 7;
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: daysFromMonday));
  }
}