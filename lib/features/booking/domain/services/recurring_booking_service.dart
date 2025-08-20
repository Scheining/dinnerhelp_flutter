import 'package:dartz/dartz.dart';
import 'package:homechef/core/error/failures.dart';
import '../entities/recurrence_pattern.dart';
import '../entities/booking_request.dart';
import '../entities/booking_occurrence.dart';
import '../repositories/recurring_booking_repository.dart';
import '../repositories/booking_availability_repository.dart';
import 'booking_availability_service.dart';

/// Service for managing recurring bookings
class RecurringBookingService {
  final RecurringBookingRepository _recurringRepository;
  final BookingAvailabilityRepository _availabilityRepository;
  final BookingAvailabilityService _availabilityService;

  const RecurringBookingService(
    this._recurringRepository,
    this._availabilityRepository,
    this._availabilityService,
  );

  /// Generate occurrences for a recurring pattern
  Future<Either<Failure, List<DateTime>>> generateOccurrences({
    required RecurrencePattern pattern,
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    try {
      // Validate dates
      if (startDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
        return const Left(ValidationFailure('Start date cannot be in the past'));
      }

      final effectiveEndDate = endDate ?? startDate.add(const Duration(days: 180)); // Max 6 months
      final maxAdvanceDate = DateTime.now().add(const Duration(days: 180));
      
      if (effectiveEndDate.isAfter(maxAdvanceDate)) {
        return const Left(BookingTooFarInAdvanceFailure());
      }

      // Create a pattern with the provided dates
      final adjustedPattern = RecurrencePattern(
        type: pattern.type,
        intervalValue: pattern.intervalValue,
        startDate: startDate,
        endDate: effectiveEndDate,
        maxOccurrences: pattern.maxOccurrences,
      );

      final occurrences = adjustedPattern.generateOccurrences(until: effectiveEndDate);
      
      if (occurrences.isEmpty) {
        return const Left(InvalidRecurrencePatternFailure('Pattern generates no occurrences'));
      }

      if (occurrences.length > 100) {
        return const Left(InvalidRecurrencePatternFailure('Pattern generates too many occurrences (max 100)'));
      }

      return Right(occurrences);
    } catch (e) {
      return Left(ServerFailure('Failed to generate occurrences: $e'));
    }
  }

  /// Check for conflicts in recurring booking dates
  Future<Either<Failure, List<DateTime>>> checkRecurringConflicts({
    required String chefId,
    required List<DateTime> occurrences,
    required String startTime,
    required String endTime,
  }) async {
    try {
      if (chefId.isEmpty) {
        return const Left(ValidationFailure('Chef ID cannot be empty'));
      }

      if (occurrences.isEmpty) {
        return const Right([]);
      }

      // Validate time format
      if (!_isValidTimeFormat(startTime) || !_isValidTimeFormat(endTime)) {
        return const Left(ValidationFailure('Invalid time format'));
      }

      final conflicts = <DateTime>[];

      for (final occurrence in occurrences) {
        // Check for booking conflicts
        final conflictResult = await _availabilityService.checkBookingConflict(
          chefId: chefId,
          date: occurrence,
          startTime: startTime,
          endTime: endTime,
        );

        if (conflictResult.isLeft()) {
          return conflictResult.fold((failure) => Left(failure), (_) => throw UnimplementedError());
        }

        final hasConflict = conflictResult.fold((_) => throw UnimplementedError(), (conflict) => conflict);
        if (hasConflict) {
          conflicts.add(occurrence);
        }

        // Check if chef is available on this date
        final startDateTime = _parseDateTime(occurrence, startTime);
        final endDateTime = _parseDateTime(occurrence, endTime);
        
        final availabilityResult = await _availabilityRepository.isChefAvailable(
          chefId: chefId,
          startTime: startDateTime,
          endTime: endDateTime,
        );

        if (availabilityResult.isLeft()) {
          continue; // Skip this occurrence if we can't check availability
        }

        final isAvailable = availabilityResult.fold((_) => throw UnimplementedError(), (available) => available);
        if (!isAvailable) {
          conflicts.add(occurrence);
        }
      }

      return Right(conflicts.toSet().toList()); // Remove duplicates
    } catch (e) {
      return Left(ServerFailure('Failed to check recurring conflicts: $e'));
    }
  }

  /// Create a recurring booking series
  Future<Either<Failure, String>> createRecurringSeries({
    required BookingRequest bookingRequest,
    required RecurrencePattern pattern,
  }) async {
    try {
      if (!bookingRequest.isRecurring) {
        return const Left(ValidationFailure('Booking request must be configured for recurring bookings'));
      }

      // Validate the recurring pattern first
      final validationResult = await _availabilityService.validateRecurringBookingPattern(
        chefId: bookingRequest.chefId,
        pattern: pattern,
        startTime: bookingRequest.startTime,
        endTime: bookingRequest.endTime,
      );

      if (validationResult.isLeft()) {
        return validationResult.fold((failure) => Left(failure), (_) => throw UnimplementedError());
      }

      final isValid = validationResult.fold((_) => throw UnimplementedError(), (valid) => valid);
      if (!isValid) {
        return const Left(InvalidRecurrencePatternFailure('Recurring pattern is not valid for this chef'));
      }

      // Create the recurring series
      return await _recurringRepository.createRecurringSeries(
        bookingRequest: bookingRequest,
        pattern: pattern,
      );
    } catch (e) {
      return Left(ServerFailure('Failed to create recurring series: $e'));
    }
  }

  /// Cancel a recurring booking series
  Future<Either<Failure, void>> cancelRecurringBooking({
    required String seriesId,
    required CancellationType cancellationType,
  }) async {
    try {
      if (seriesId.isEmpty) {
        return const Left(ValidationFailure('Series ID cannot be empty'));
      }

      return await _recurringRepository.cancelRecurringSeries(
        seriesId: seriesId,
        cancellationType: cancellationType,
      );
    } catch (e) {
      return Left(ServerFailure('Failed to cancel recurring booking: $e'));
    }
  }

  /// Modify a recurring booking series
  Future<Either<Failure, void>> modifyRecurringBooking({
    required String seriesId,
    required RecurringSeriesModification modifications,
  }) async {
    try {
      if (seriesId.isEmpty) {
        return const Left(ValidationFailure('Series ID cannot be empty'));
      }

      // Validate modifications
      if (modifications.startTime != null && !_isValidTimeFormat(modifications.startTime!)) {
        return const Left(ValidationFailure('Invalid start time format'));
      }

      if (modifications.endTime != null && !_isValidTimeFormat(modifications.endTime!)) {
        return const Left(ValidationFailure('Invalid end time format'));
      }

      if (modifications.numberOfGuests != null) {
        if (modifications.numberOfGuests! <= 0 || modifications.numberOfGuests! > 50) {
          return const Left(ValidationFailure('Number of guests must be between 1 and 50'));
        }
      }

      if (modifications.newEndDate != null) {
        final maxAdvanceDate = DateTime.now().add(const Duration(days: 180));
        if (modifications.newEndDate!.isAfter(maxAdvanceDate)) {
          return const Left(BookingTooFarInAdvanceFailure());
        }
      }

      if (modifications.newMaxOccurrences != null) {
        if (modifications.newMaxOccurrences! <= 0 || modifications.newMaxOccurrences! > 100) {
          return const Left(ValidationFailure('Max occurrences must be between 1 and 100'));
        }
      }

      return await _recurringRepository.modifyRecurringSeries(
        seriesId: seriesId,
        modifications: modifications,
      );
    } catch (e) {
      return Left(ServerFailure('Failed to modify recurring booking: $e'));
    }
  }

  /// Get recurring booking series for a chef
  Future<Either<Failure, List<RecurringBookingSeries>>> getChefRecurringSeries({
    required String chefId,
    bool? activeOnly,
  }) async {
    if (chefId.isEmpty) {
      return const Left(ValidationFailure('Chef ID cannot be empty'));
    }

    return await _recurringRepository.getChefRecurringSeries(
      chefId: chefId,
      activeOnly: activeOnly,
    );
  }

  /// Get recurring booking series for a user
  Future<Either<Failure, List<RecurringBookingSeries>>> getUserRecurringSeries({
    required String userId,
    bool? activeOnly,
  }) async {
    if (userId.isEmpty) {
      return const Left(ValidationFailure('User ID cannot be empty'));
    }

    return await _recurringRepository.getUserRecurringSeries(
      userId: userId,
      activeOnly: activeOnly,
    );
  }

  /// Get individual booking occurrences for a series
  Future<Either<Failure, List<BookingOccurrence>>> getSeriesOccurrences({
    required String seriesId,
  }) async {
    if (seriesId.isEmpty) {
      return const Left(ValidationFailure('Series ID cannot be empty'));
    }

    return await _recurringRepository.getSeriesOccurrences(seriesId: seriesId);
  }

  /// Cancel an individual occurrence from a series
  Future<Either<Failure, void>> cancelSeriesOccurrence({
    required String seriesId,
    required String occurrenceId,
  }) async {
    if (seriesId.isEmpty) {
      return const Left(ValidationFailure('Series ID cannot be empty'));
    }

    if (occurrenceId.isEmpty) {
      return const Left(ValidationFailure('Occurrence ID cannot be empty'));
    }

    return await _recurringRepository.cancelSeriesOccurrence(
      seriesId: seriesId,
      occurrenceId: occurrenceId,
    );
  }

  /// Validate if a recurring booking pattern is feasible
  Future<Either<Failure, bool>> validateRecurringPattern({
    required String chefId,
    required RecurrencePattern pattern,
    required String startTime,
    required String endTime,
  }) async {
    try {
      // Basic validation
      if (chefId.isEmpty) {
        return const Left(ValidationFailure('Chef ID cannot be empty'));
      }

      if (!_isValidTimeFormat(startTime) || !_isValidTimeFormat(endTime)) {
        return const Left(ValidationFailure('Invalid time format'));
      }

      // Generate occurrences to check
      final occurrencesResult = await generateOccurrences(
        pattern: pattern,
        startDate: pattern.startDate,
        endDate: pattern.endDate,
      );

      if (occurrencesResult.isLeft()) {
        return occurrencesResult.fold((failure) => Left(failure), (_) => throw UnimplementedError());
      }

      final occurrences = occurrencesResult.fold((_) => throw UnimplementedError(), (dates) => dates);

      // Check for conflicts
      final conflictsResult = await checkRecurringConflicts(
        chefId: chefId,
        occurrences: occurrences,
        startTime: startTime,
        endTime: endTime,
      );

      if (conflictsResult.isLeft()) {
        return conflictsResult.fold((failure) => Left(failure), (_) => throw UnimplementedError());
      }

      final conflicts = conflictsResult.fold((_) => throw UnimplementedError(), (conflictList) => conflictList);

      // If there are conflicts, pattern is not valid
      if (conflicts.isNotEmpty) {
        return const Left(BookingConflictFailure('Recurring pattern has scheduling conflicts'));
      }

      return const Right(true);
    } catch (e) {
      return Left(ServerFailure('Failed to validate recurring pattern: $e'));
    }
  }

  /// Get suggested alternative dates for conflicted occurrences
  Future<Either<Failure, List<DateTime>>> getSuggestedAlternatives({
    required String chefId,
    required List<DateTime> conflictedDates,
    required String startTime,
    required String endTime,
    required Duration duration,
  }) async {
    try {
      final suggestions = <DateTime>[];

      for (final conflictedDate in conflictedDates) {
        // Try to find next available slot within a week of the conflicted date
        final weekAfter = conflictedDate.add(const Duration(days: 7));
        
        final nextSlotResult = await _availabilityService.getNextAvailableSlot(
          chefId: chefId,
          afterDate: conflictedDate,
          duration: duration,
        );

        if (nextSlotResult.isRight()) {
          final nextSlot = nextSlotResult.fold((_) => throw UnimplementedError(), (slot) => slot);
          if (nextSlot != null && nextSlot.startTime.isBefore(weekAfter)) {
            suggestions.add(nextSlot.startTime);
          }
        }
      }

      return Right(suggestions);
    } catch (e) {
      return Left(ServerFailure('Failed to get suggested alternatives: $e'));
    }
  }

  // Private helper methods

  bool _isValidTimeFormat(String time) {
    final regex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
    return regex.hasMatch(time);
  }

  DateTime _parseDateTime(DateTime date, String time) {
    final parts = time.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }
}