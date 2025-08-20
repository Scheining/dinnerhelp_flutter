import 'package:dartz/dartz.dart';
import 'package:homechef/core/error/failures.dart';
import '../entities/recurrence_pattern.dart';
import '../repositories/recurring_booking_repository.dart';

class ValidateRecurringBookingPattern {
  final RecurringBookingRepository repository;

  const ValidateRecurringBookingPattern(this.repository);

  Future<Either<Failure, bool>> call(ValidateRecurringBookingPatternParams params) async {
    // Basic validation
    if (params.pattern.startDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return const Left(ValidationFailure('Recurring pattern cannot start in the past'));
    }

    // Validate 6 months maximum advance booking
    final maxAdvanceDate = DateTime.now().add(const Duration(days: 180));
    if (params.pattern.startDate.isAfter(maxAdvanceDate)) {
      return const Left(BookingTooFarInAdvanceFailure());
    }

    // Validate end date if provided
    if (params.pattern.endDate != null) {
      if (params.pattern.endDate!.isBefore(params.pattern.startDate)) {
        return const Left(ValidationFailure('End date cannot be before start date'));
      }
      
      if (params.pattern.endDate!.isAfter(maxAdvanceDate)) {
        return const Left(BookingTooFarInAdvanceFailure());
      }
    }

    // Validate max occurrences
    if (params.pattern.maxOccurrences != null) {
      if (params.pattern.maxOccurrences! <= 0) {
        return const Left(ValidationFailure('Max occurrences must be greater than 0'));
      }
      
      if (params.pattern.maxOccurrences! > 100) {
        return const Left(ValidationFailure('Max occurrences cannot exceed 100'));
      }
    }

    // Validate time format
    if (!_isValidTimeFormat(params.startTime) || !_isValidTimeFormat(params.endTime)) {
      return const Left(ValidationFailure('Invalid time format. Use HH:MM format'));
    }

    // Validate time range
    if (!_isValidTimeRange(params.startTime, params.endTime)) {
      return const Left(ValidationFailure('End time must be after start time'));
    }

    // Generate occurrences to validate feasibility
    final occurrences = params.pattern.generateOccurrences();
    
    if (occurrences.isEmpty) {
      return const Left(InvalidRecurrencePatternFailure('Pattern generates no valid occurrences'));
    }

    if (occurrences.length > 100) {
      return const Left(InvalidRecurrencePatternFailure('Pattern generates too many occurrences (max 100)'));
    }

    // Check with repository for chef-specific validation
    return await repository.validateRecurringBookingPattern(
      chefId: params.chefId,
      pattern: params.pattern,
      startTime: params.startTime,
      endTime: params.endTime,
    );
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
      // Assume next day
      return (endMinutes + 24 * 60) > startMinutes;
    }
    
    return endMinutes > startMinutes;
  }
}

class ValidateRecurringBookingPatternParams {
  final String chefId;
  final RecurrencePattern pattern;
  final String startTime;
  final String endTime;

  const ValidateRecurringBookingPatternParams({
    required this.chefId,
    required this.pattern,
    required this.startTime,
    required this.endTime,
  });
}