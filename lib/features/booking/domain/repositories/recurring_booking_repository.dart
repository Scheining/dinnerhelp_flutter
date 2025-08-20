import 'package:dartz/dartz.dart';
import 'package:homechef/core/error/failures.dart';
import '../entities/recurrence_pattern.dart';
import '../entities/booking_request.dart';
import '../entities/booking_occurrence.dart';

abstract class RecurringBookingRepository {
  /// Validate if a recurring booking pattern is feasible for a chef
  Future<Either<Failure, bool>> validateRecurringBookingPattern({
    required String chefId,
    required RecurrencePattern pattern,
    required String startTime,
    required String endTime,
  });

  /// Check for conflicts in recurring booking dates
  Future<Either<Failure, List<DateTime>>> checkRecurringConflicts({
    required String chefId,
    required List<DateTime> occurrences,
    required String startTime,
    required String endTime,
  });

  /// Create a recurring booking series
  Future<Either<Failure, String>> createRecurringSeries({
    required BookingRequest bookingRequest,
    required RecurrencePattern pattern,
  });

  /// Get all booking series for a chef
  Future<Either<Failure, List<RecurringBookingSeries>>> getChefRecurringSeries({
    required String chefId,
    bool? activeOnly,
  });

  /// Get all booking series for a user
  Future<Either<Failure, List<RecurringBookingSeries>>> getUserRecurringSeries({
    required String userId,
    bool? activeOnly,
  });

  /// Cancel a recurring booking series
  Future<Either<Failure, void>> cancelRecurringSeries({
    required String seriesId,
    required CancellationType cancellationType,
  });

  /// Get future bookings in a series
  Future<Either<Failure, List<BookingOccurrence>>> getFutureBookingsInSeries(String seriesId);

  /// Modify a recurring booking series
  Future<Either<Failure, void>> modifyRecurringSeries({
    required String seriesId,
    required RecurringSeriesModification modifications,
  });

  /// Get individual bookings for a recurring series
  Future<Either<Failure, List<BookingOccurrence>>> getSeriesOccurrences({
    required String seriesId,
  });

  /// Cancel individual occurrence from a series
  Future<Either<Failure, void>> cancelSeriesOccurrence({
    required String seriesId,
    required String occurrenceId,
  });
  
  /// Get bookings by specific dates
  Future<Either<Failure, List<BookingOccurrence>>> getBookingsByDates(
    String seriesId,
    List<DateTime> dates,
  );
}

enum CancellationType {
  thisAndFuture,
  thisOccurrenceOnly,
  entireSeries,
}

class RecurringBookingSeries {
  final String id;
  final String userId;
  final String chefId;
  final String title;
  final String? description;
  final RecurrencePattern pattern;
  final String startTime;
  final String endTime;
  final int numberOfGuests;
  final String? menuId;
  final bool isActive;
  final int totalOccurrences;
  final int completedOccurrences;
  final int cancelledOccurrences;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RecurringBookingSeries({
    required this.id,
    required this.userId,
    required this.chefId,
    required this.title,
    this.description,
    required this.pattern,
    required this.startTime,
    required this.endTime,
    required this.numberOfGuests,
    this.menuId,
    required this.isActive,
    required this.totalOccurrences,
    required this.completedOccurrences,
    required this.cancelledOccurrences,
    required this.createdAt,
    required this.updatedAt,
  });
}

enum BookingOccurrenceStatus {
  pending,
  confirmed,
  completed,
  cancelled,
  skipped,
}

class RecurringSeriesModification {
  final String? title;
  final String? description;
  final String? startTime;
  final String? endTime;
  final int? numberOfGuests;
  final DateTime? newEndDate;
  final int? newMaxOccurrences;
  final bool? isActive;

  const RecurringSeriesModification({
    this.title,
    this.description,
    this.startTime,
    this.endTime,
    this.numberOfGuests,
    this.newEndDate,
    this.newMaxOccurrences,
    this.isActive,
  });
}