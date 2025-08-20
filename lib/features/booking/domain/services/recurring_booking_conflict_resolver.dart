import 'package:dartz/dartz.dart';
import 'package:homechef/core/error/failures.dart';
import '../entities/recurring_conflict.dart';
import '../entities/chef_time_off.dart';

abstract class RecurringBookingConflictResolver {
  /// Detect conflicts between recurring bookings and chef time off
  Future<Either<Failure, List<RecurringBookingConflict>>> detectTimeOffConflicts({
    required String seriesId,
    required ChefTimeOff timeOffPeriod,
  });

  /// Cancel affected occurrences of a recurring booking series
  Future<Either<Failure, Unit>> cancelAffectedOccurrences({
    required String seriesId,
    required List<DateTime> dates,
    required String reason,
  });

  /// Offer rescheduling options for affected bookings
  Future<Either<Failure, List<ResolutionOption>>> offerReschedulingOptions({
    required List<ConflictOccurrence> affectedBookings,
  });

  /// Update recurring series after conflict resolution
  Future<Either<Failure, Unit>> updateSeriesAfterConflict({
    required String seriesId,
    required ConflictResolutionResult resolution,
  });

  /// Notify users about recurring booking changes
  Future<Either<Failure, Unit>> notifyRecurringBookingChanges({
    required String seriesId,
    required List<RecurringBookingChange> changes,
  });

  /// Process resolution option selected by user
  Future<Either<Failure, ConflictResolutionResult>> processResolutionChoice({
    required String conflictId,
    required String selectedResolutionId,
    required Map<String, dynamic> parameters,
  });

  /// Get all active conflicts for a chef
  Future<Either<Failure, List<RecurringBookingConflict>>> getActiveConflicts({
    required String chefId,
  });

  /// Resolve multiple conflicts in batch
  Future<Either<Failure, List<ConflictResolutionResult>>> resolveBatchConflicts({
    required List<BatchConflictResolution> resolutions,
  });
}

class RecurringBookingChange {
  final String bookingId;
  final ChangeType changeType;
  final DateTime? originalDate;
  final DateTime? newDate;
  final String? originalChefId;
  final String? newChefId;
  final BookingChangeStatus status;
  final String? reason;

  const RecurringBookingChange({
    required this.bookingId,
    required this.changeType,
    this.originalDate,
    this.newDate,
    this.originalChefId,
    this.newChefId,
    required this.status,
    this.reason,
  });
}

enum ChangeType {
  cancelled,
  rescheduled,
  chefChanged,
  suspended,
}

enum BookingChangeStatus {
  pending,
  confirmed,
  rejected,
  processed,
}

class BatchConflictResolution {
  final String conflictId;
  final String selectedResolutionId;
  final Map<String, dynamic> parameters;
  final int priority; // 1-10, higher numbers processed first

  const BatchConflictResolution({
    required this.conflictId,
    required this.selectedResolutionId,
    this.parameters = const {},
    this.priority = 5,
  });
}