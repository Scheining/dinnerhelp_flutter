import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homechef/core/error/failures.dart';
import '../entities/recurring_conflict.dart' as conflict_types;
import '../entities/chef_time_off.dart';
import '../repositories/recurring_booking_repository.dart';
import '../repositories/chef_schedule_repository.dart';
import 'package:homechef/features/notifications/domain/services/notification_service.dart';
import 'package:homechef/features/payment/domain/services/payment_service.dart';
import 'package:homechef/features/payment/domain/entities/refund.dart';
import 'chef_unavailability_handler.dart' as unavail_handler;
import 'recurring_booking_conflict_resolver.dart';

class RecurringBookingConflictResolverImpl implements RecurringBookingConflictResolver {
  final SupabaseClient _supabaseClient;
  final RecurringBookingRepository _recurringRepository;
  final ChefScheduleRepository _scheduleRepository;
  final NotificationService _notificationService;
  final PaymentService _paymentService;
  final unavail_handler.ChefUnavailabilityHandler _unavailabilityHandler;

  RecurringBookingConflictResolverImpl({
    required SupabaseClient supabaseClient,
    required RecurringBookingRepository recurringRepository,
    required ChefScheduleRepository scheduleRepository,
    required NotificationService notificationService,
    required PaymentService paymentService,
    required unavail_handler.ChefUnavailabilityHandler unavailabilityHandler,
  })  : _supabaseClient = supabaseClient,
        _recurringRepository = recurringRepository,
        _scheduleRepository = scheduleRepository,
        _notificationService = notificationService,
        _paymentService = paymentService,
        _unavailabilityHandler = unavailabilityHandler;

  @override
  Future<Either<Failure, List<conflict_types.RecurringBookingConflict>>> detectTimeOffConflicts({
    required String seriesId,
    required ChefTimeOff timeOffPeriod,
  }) async {
    try {
      // Get all future bookings in the series
      final bookingsResult = await _recurringRepository.getFutureBookingsInSeries(seriesId);
      if (bookingsResult.isLeft()) {
        return bookingsResult.fold((l) => Left(l), (r) => throw Exception());
      }

      final bookings = bookingsResult.getOrElse(() => []);
      final conflicts = <conflict_types.RecurringBookingConflict>[];

      // Check each booking against the time off period
      final conflictedOccurrences = <conflict_types.ConflictOccurrence>[];

      for (final booking in bookings) {
        if (_isBookingInTimeOff(booking, timeOffPeriod)) {
          conflictedOccurrences.add(conflict_types.ConflictOccurrence(
            bookingId: booking.id,
            bookingDate: booking.date,
            timeSlot: '${booking.startTime}-${booking.endTime}',
            conflictType: _getConflictTypeFromTimeOff(timeOffPeriod),
            conflictDescription: 'Chef unavailable: ${timeOffPeriod.reason}',
            originalCreatedAt: booking.createdAt,
          ));
        }
      }

      if (conflictedOccurrences.isNotEmpty) {
        // Generate resolution options
        final resolutionOptions = await _generateResolutionOptions(
          seriesId: seriesId,
          conflictedOccurrences: conflictedOccurrences,
          timeOffPeriod: timeOffPeriod,
        );

        final conflict = conflict_types.RecurringBookingConflict(
          seriesId: seriesId,
          chefId: timeOffPeriod.chefId,
          userId: bookings.first.userId, // Assuming same user for series
          conflictedOccurrences: conflictedOccurrences,
          cause: conflict_types.ConflictCause.chefTimeOff,
          detectedAt: DateTime.now(),
          availableOptions: resolutionOptions,
        );

        conflicts.add(conflict);

        // Save conflict to database
        await _saveConflictToDatabase(conflict);
      }

      return Right(conflicts);

    } catch (e) {
      return const Left(RecurringBookingConflictFailure('Failed to detect time off conflicts'));
    }
  }

  @override
  Future<Either<Failure, Unit>> cancelAffectedOccurrences({
    required String seriesId,
    required List<DateTime> dates,
    required String reason,
  }) async {
    try {
      final bookingsResult = await _recurringRepository.getBookingsByDates(seriesId, dates);
      if (bookingsResult.isLeft()) {
        return bookingsResult.fold((l) => Left(l), (r) => throw Exception());
      }

      final bookingsToCancel = bookingsResult.getOrElse(() => []);
      final cancelledBookingIds = <String>[];
      int totalRefundAmount = 0;

      for (final booking in bookingsToCancel) {
        // Calculate refund amount based on cancellation timing
        final refundAmount = await _calculateRefundForCancellation(
          booking.id,
          booking.date,
          reason,
        );

        // Process refund if payment was made
        if (booking.paymentStatus == 'succeeded' && refundAmount > 0) {
          final refundResult = await _paymentService.refundPayment(
            bookingId: booking.id,
            amount: refundAmount,
            reason: RefundReason.chefCancellation,
            description: 'Recurring booking cancellation: $reason',
          );

          if (refundResult.isLeft()) {
            // Log error but continue with other cancellations
            continue;
          }

          totalRefundAmount += refundAmount;
        }

        // Update booking status
        await _supabaseClient
            .from('bookings')
            .update({
              'status': 'cancelled',
              'cancellation_reason': reason,
              'refund_amount': refundAmount,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', booking.id);

        cancelledBookingIds.add(booking.id);
      }

      // Update series metadata
      await _updateSeriesMetadata(seriesId, {
        'cancelled_occurrences': cancelledBookingIds,
        'total_cancellations': cancelledBookingIds.length,
        'total_refunds': totalRefundAmount,
      });

      return const Right(unit);

    } catch (e) {
      return const Left(BookingModificationFailure('Failed to cancel affected occurrences'));
    }
  }

  @override
  Future<Either<Failure, List<conflict_types.ResolutionOption>>> offerReschedulingOptions({
    required List<conflict_types.ConflictOccurrence> affectedBookings,
  }) async {
    try {
      final options = <conflict_types.ResolutionOption>[];

      // Option 1: Cancel all conflicted bookings
      options.add(conflict_types.ResolutionOption(
        id: 'cancel_all',
        type: conflict_types.ResolutionType.cancel,
        title: 'Cancel Affected Bookings',
        description: 'Cancel all conflicted bookings with full refund',
        impact: conflict_types.ResolutionImpact(
          affectedBookings: affectedBookings.length,
          cancelledBookings: affectedBookings.length,
          userImpactLevel: conflict_types.UserImpactLevel.medium,
          chefImpactLevel: conflict_types.ChefImpactLevel.low,
          consequenceDescription: [
            'Full refund for all cancelled bookings',
            'Service credit for inconvenience',
          ],
        ),
        requiresUserApproval: true,
      ));

      // Option 2: Reschedule individual bookings
      if (affectedBookings.length <= 3) {
        options.add(conflict_types.ResolutionOption(
          id: 'reschedule_individual',
          type: conflict_types.ResolutionType.reschedule,
          title: 'Reschedule Each Booking',
          description: 'Find alternative dates for each affected booking',
          impact: conflict_types.ResolutionImpact(
            affectedBookings: affectedBookings.length,
            rescheduledBookings: affectedBookings.length,
            userImpactLevel: conflict_types.UserImpactLevel.low,
            chefImpactLevel: conflict_types.ChefImpactLevel.medium,
            consequenceDescription: [
              'Bookings moved to alternative dates',
              'No cancellation fees',
            ],
          ),
          requiresUserApproval: true,
          requiresChefApproval: true,
        ));
      }

      // Option 3: Find alternative chef for conflicted dates
      options.add(conflict_types.ResolutionOption(
        id: 'alternative_chef',
        type: conflict_types.ResolutionType.findAlternativeChef,
        title: 'Find Alternative Chef',
        description: 'Keep original dates but assign different chef',
        impact: conflict_types.ResolutionImpact(
          affectedBookings: affectedBookings.length,
          userImpactLevel: conflict_types.UserImpactLevel.medium,
          chefImpactLevel: conflict_types.ChefImpactLevel.low,
          consequenceDescription: [
            'Different chef for affected dates',
            'Price may vary slightly',
          ],
        ),
        requiresUserApproval: true,
      ));

      // Option 4: Skip conflicted occurrences
      if (affectedBookings.length < 5) {
        options.add(conflict_types.ResolutionOption(
          id: 'skip_occurrences',
          type: conflict_types.ResolutionType.skipConflicted,
          title: 'Skip Conflicted Dates',
          description: 'Continue series but skip the conflicted bookings',
          impact: conflict_types.ResolutionImpact(
            affectedBookings: affectedBookings.length,
            cancelledBookings: affectedBookings.length,
            userImpactLevel: conflict_types.UserImpactLevel.low,
            chefImpactLevel: conflict_types.ChefImpactLevel.low,
            consequenceDescription: [
              'Series continues with gaps',
              'Refund for skipped bookings',
            ],
          ),
          requiresUserApproval: true,
        ));
      }

      // Option 5: End series early
      options.add(conflict_types.ResolutionOption(
        id: 'end_series',
        type: conflict_types.ResolutionType.endSeries,
        title: 'End Recurring Series',
        description: 'Cancel remaining bookings and end the series',
        impact: conflict_types.ResolutionImpact(
          affectedBookings: affectedBookings.length,
          cancelledBookings: affectedBookings.length,
          userImpactLevel: conflict_types.UserImpactLevel.high,
          chefImpactLevel: conflict_types.ChefImpactLevel.medium,
          consequenceDescription: [
            'All future bookings cancelled',
            'Full refund for future bookings',
          ],
        ),
        requiresUserApproval: true,
      ));

      return Right(options);

    } catch (e) {
      return const Left(ReschedulingOptionsFailure('Failed to generate rescheduling options'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateSeriesAfterConflict({
    required String seriesId,
    required conflict_types.ConflictResolutionResult resolution,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'conflict_resolution': resolution.resolutionType.name,
        'resolution_date': resolution.resolvedAt.toIso8601String(),
        'cancelled_bookings': resolution.cancelledBookings,
        'rescheduled_bookings': resolution.rescheduledBookings
            .map((r) => {
                  'booking_id': r.originalBookingId,
                  'new_date': r.newDate.toIso8601String(),
                  'new_chef_id': r.alternativeChefId,
                })
            .toList(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Update booking series metadata
      await _supabaseClient
          .from('booking_series')
          .update(updateData)
          .eq('id', seriesId);

      // If series was ended, mark it as inactive
      if (resolution.resolutionType == conflict_types.ResolutionType.endSeries) {
        await _supabaseClient
            .from('booking_series')
            .update({
              'status': 'ended',
              'end_reason': 'Conflict resolution',
            })
            .eq('id', seriesId);
      }

      return const Right(unit);

    } catch (e) {
      return const Left(SeriesUpdateFailure('Failed to update series after conflict'));
    }
  }

  @override
  Future<Either<Failure, Unit>> notifyRecurringBookingChanges({
    required String seriesId,
    required List<RecurringBookingChange> changes,
  }) async {
    try {
      // Get series details
      final seriesData = await _supabaseClient
          .from('booking_series')
          .select('user_id, chef_id')
          .eq('id', seriesId)
          .single();

      final userId = seriesData['user_id'];
      final chefId = seriesData['chef_id'];

      // Group changes by type
      final cancelledCount = changes.where((c) => c.changeType == ChangeType.cancelled).length;
      final rescheduledCount = changes.where((c) => c.changeType == ChangeType.rescheduled).length;
      final chefChangedCount = changes.where((c) => c.changeType == ChangeType.chefChanged).length;

      // Notify user
      String userMessage = 'Your recurring booking series has been updated: ';
      if (cancelledCount > 0) userMessage += '$cancelledCount bookings cancelled';
      if (rescheduledCount > 0) userMessage += ', $rescheduledCount bookings rescheduled';
      if (chefChangedCount > 0) userMessage += ', $chefChangedCount bookings assigned to different chef';

      // Create notification in database for user
      await _supabaseClient.from('notifications').insert({
        'user_id': userId,
        'title': 'Recurring Booking Updated',
        'message': userMessage,
        'type': 'recurring_booking_change',
        'data': {
          'series_id': seriesId,
          'changes': changes.length,
          'cancelled': cancelledCount,
          'rescheduled': rescheduledCount,
          'chef_changed': chefChangedCount,
        },
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Create notification in database for chef
      await _supabaseClient.from('notifications').insert({
        'user_id': chefId,
        'title': 'Recurring Booking Changes',
        'message': 'A recurring booking series has been updated due to conflicts',
        'type': 'chef_series_update',
        'data': {
          'series_id': seriesId,
          'changes': changes.length,
        },
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Send detailed email notifications for significant changes
      if (cancelledCount > 2 || rescheduledCount > 2) {
        await _sendDetailedChangeNotification(seriesId, changes, userId);
      }

      return const Right(unit);

    } catch (e) {
      return const Left(NotificationSendFailure('Failed to send recurring booking change notifications'));
    }
  }

  @override
  Future<Either<Failure, conflict_types.ConflictResolutionResult>> processResolutionChoice({
    required String conflictId,
    required String selectedResolutionId,
    required Map<String, dynamic> parameters,
  }) async {
    try {
      // Get conflict details
      final conflict = await _getConflictById(conflictId);
      if (conflict == null) {
        return const Left(BookingNotFoundFailure('Conflict not found'));
      }

      conflict_types.ConflictResolutionResult result;

      switch (selectedResolutionId) {
        case 'cancel_all':
          result = await _processCancelAll(conflict);
          break;
        case 'reschedule_individual':
          result = await _processRescheduleIndividual(conflict, parameters);
          break;
        case 'alternative_chef':
          result = await _processAlternativeChef(conflict, parameters);
          break;
        case 'skip_occurrences':
          result = await _processSkipOccurrences(conflict);
          break;
        case 'end_series':
          result = await _processEndSeries(conflict);
          break;
        default:
          return const Left(ValidationFailure('Invalid resolution option'));
      }

      // Update conflict status
      await _updateConflictStatus(conflictId, conflict_types.ConflictResolutionStatus.resolved);

      // Update series after resolution
      await updateSeriesAfterConflict(
        seriesId: conflict.seriesId,
        resolution: result,
      );

      // Send notifications
      final changes = _createChangesFromResolution(result);
      await notifyRecurringBookingChanges(
        seriesId: conflict.seriesId,
        changes: changes,
      );

      return Right(result);

    } catch (e) {
      return Left(RecurringBookingConflictFailure('Failed to process resolution choice: $e'));
    }
  }

  @override
  Future<Either<Failure, List<conflict_types.RecurringBookingConflict>>> getActiveConflicts({
    required String chefId,
  }) async {
    try {
      final response = await _supabaseClient
          .from('recurring_conflicts')
          .select('*')
          .eq('chef_id', chefId)
          .eq('status', 'pending')
          .order('detected_at', ascending: false);

      final conflicts = <conflict_types.RecurringBookingConflict>[];

      for (final data in response) {
        final conflict = await _convertDataToConflict(data);
        if (conflict != null) conflicts.add(conflict);
      }

      return Right(conflicts);

    } catch (e) {
      return const Left(ServerFailure('Failed to get active conflicts'));
    }
  }

  @override
  Future<Either<Failure, List<conflict_types.ConflictResolutionResult>>> resolveBatchConflicts({
    required List<BatchConflictResolution> resolutions,
  }) async {
    try {
      final results = <conflict_types.ConflictResolutionResult>[];
      final errors = <String>[];

      // Sort by priority (highest first)
      resolutions.sort((a, b) => b.priority.compareTo(a.priority));

      for (final resolution in resolutions) {
        final result = await processResolutionChoice(
          conflictId: resolution.conflictId,
          selectedResolutionId: resolution.selectedResolutionId,
          parameters: resolution.parameters,
        );

        result.fold(
          (failure) => errors.add('${resolution.conflictId}: ${failure.message}'),
          (success) => results.add(success),
        );
      }

      if (errors.isNotEmpty && results.isEmpty) {
        return Left(RecurringBookingConflictFailure('All batch resolutions failed: ${errors.join(', ')}'));
      }

      return Right(results);

    } catch (e) {
      return const Left(RecurringBookingConflictFailure('Failed to resolve batch conflicts'));
    }
  }

  // Private helper methods

  bool _isBookingInTimeOff(dynamic booking, ChefTimeOff timeOff) {
    final bookingDate = booking.date;
    return bookingDate.isAfter(timeOff.startDate.subtract(const Duration(days: 1))) &&
           bookingDate.isBefore(timeOff.endDate.add(const Duration(days: 1)));
  }

  conflict_types.ConflictType _getConflictTypeFromTimeOff(ChefTimeOff timeOff) {
    final reason = timeOff.reason?.toLowerCase() ?? '';
    switch (reason) {
      case 'vacation':
      case 'holiday':
        return conflict_types.ConflictType.timeOff;
      case 'maintenance':
        return conflict_types.ConflictType.maintenanceWindow;
      case 'personal':
        return conflict_types.ConflictType.personalUnavailability;
      default:
        return conflict_types.ConflictType.timeOff;
    }
  }

  Future<List<conflict_types.ResolutionOption>> _generateResolutionOptions({
    required String seriesId,
    required List<conflict_types.ConflictOccurrence> conflictedOccurrences,
    required ChefTimeOff timeOffPeriod,
  }) async {
    return await offerReschedulingOptions(affectedBookings: conflictedOccurrences)
        .then((result) => result.getOrElse(() => []));
  }

  Future<void> _saveConflictToDatabase(conflict_types.RecurringBookingConflict conflict) async {
    await _supabaseClient.from('recurring_conflicts').insert({
      'series_id': conflict.seriesId,
      'chef_id': conflict.chefId,
      'user_id': conflict.userId,
      'cause': conflict.cause.name,
      'status': conflict.status.name,
      'affected_bookings': conflict.conflictedOccurrences.length,
      'detected_at': conflict.detectedAt.toIso8601String(),
      'conflicted_occurrences': conflict.conflictedOccurrences
          .map((o) => {
                'booking_id': o.bookingId,
                'booking_date': o.bookingDate.toIso8601String(),
                'time_slot': o.timeSlot,
                'conflict_type': o.conflictType.name,
                'description': o.conflictDescription,
              })
          .toList(),
      'available_options': conflict.availableOptions
          .map((o) => {
                'id': o.id,
                'type': o.type.name,
                'title': o.title,
                'description': o.description,
              })
          .toList(),
    });
  }

  Future<int> _calculateRefundForCancellation(String bookingId, DateTime bookingDate, String reason) async {
    final response = await _supabaseClient
        .from('bookings')
        .select('total_amount, payment_status')
        .eq('id', bookingId)
        .single();

    if (response['payment_status'] != 'succeeded') return 0;

    final totalAmount = (response['total_amount'] as num).toInt();
    final hoursUntilBooking = bookingDate.difference(DateTime.now()).inHours;

    // Full refund if more than 48 hours notice
    if (hoursUntilBooking > 48) return totalAmount;
    
    // 50% refund if 24-48 hours notice
    if (hoursUntilBooking > 24) return (totalAmount * 0.5).round();
    
    // No refund if less than 24 hours (chef's fault gets full refund)
    if (reason.contains('chef') || reason.contains('emergency')) return totalAmount;
    
    return 0;
  }

  Future<void> _updateSeriesMetadata(String seriesId, Map<String, dynamic> metadata) async {
    await _supabaseClient
        .from('booking_series')
        .update({
          'metadata': metadata,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', seriesId);
  }

  Future<conflict_types.RecurringBookingConflict?> _getConflictById(String conflictId) async {
    try {
      final response = await _supabaseClient
          .from('recurring_conflicts')
          .select('*')
          .eq('id', conflictId)
          .single();

      return await _convertDataToConflict(response);
    } catch (e) {
      return null;
    }
  }

  Future<conflict_types.RecurringBookingConflict?> _convertDataToConflict(Map<String, dynamic> data) async {
    // This would convert database data back to conflict_types.RecurringBookingConflict object
    // Implementation would depend on the exact database schema
    return null; // Placeholder
  }

  Future<conflict_types.ConflictResolutionResult> _processCancelAll(conflict_types.RecurringBookingConflict conflict) async {
    final cancelledBookings = conflict.conflictedOccurrences.map((o) => o.bookingId).toList();
    
    // Cancel all affected bookings
    await cancelAffectedOccurrences(
      seriesId: conflict.seriesId,
      dates: conflict.conflictedOccurrences.map((o) => o.bookingDate).toList(),
      reason: 'Series conflict resolution',
    );

    return conflict_types.ConflictResolutionResult(
      conflictId: conflict.seriesId,
      resolutionType: conflict_types.ResolutionType.cancel,
      success: true,
      cancelledBookings: cancelledBookings,
      resolvedAt: DateTime.now(),
    );
  }

  Future<conflict_types.ConflictResolutionResult> _processRescheduleIndividual(
    conflict_types.RecurringBookingConflict conflict,
    Map<String, dynamic> parameters,
  ) async {
    final rescheduledBookings = <conflict_types.RescheduledBookingInfo>[];
    
    // This would implement the actual rescheduling logic
    // For now, return a placeholder
    
    return conflict_types.ConflictResolutionResult(
      conflictId: conflict.seriesId,
      resolutionType: conflict_types.ResolutionType.reschedule,
      success: true,
      rescheduledBookings: rescheduledBookings,
      resolvedAt: DateTime.now(),
    );
  }

  Future<conflict_types.ConflictResolutionResult> _processAlternativeChef(
    conflict_types.RecurringBookingConflict conflict,
    Map<String, dynamic> parameters,
  ) async {
    // This would implement finding and assigning alternative chefs
    // For now, return a placeholder
    
    return conflict_types.ConflictResolutionResult(
      conflictId: conflict.seriesId,
      resolutionType: conflict_types.ResolutionType.findAlternativeChef,
      success: true,
      resolvedAt: DateTime.now(),
    );
  }

  Future<conflict_types.ConflictResolutionResult> _processSkipOccurrences(conflict_types.RecurringBookingConflict conflict) async {
    final cancelledBookings = conflict.conflictedOccurrences.map((o) => o.bookingId).toList();
    
    await cancelAffectedOccurrences(
      seriesId: conflict.seriesId,
      dates: conflict.conflictedOccurrences.map((o) => o.bookingDate).toList(),
      reason: 'Skipped due to chef unavailability',
    );

    return conflict_types.ConflictResolutionResult(
      conflictId: conflict.seriesId,
      resolutionType: conflict_types.ResolutionType.skipConflicted,
      success: true,
      cancelledBookings: cancelledBookings,
      resolvedAt: DateTime.now(),
    );
  }

  Future<conflict_types.ConflictResolutionResult> _processEndSeries(conflict_types.RecurringBookingConflict conflict) async {
    // Get all remaining future bookings in series
    final futureBookingsResult = await _recurringRepository.getFutureBookingsInSeries(conflict.seriesId);
    final futureBookings = futureBookingsResult.getOrElse(() => []);
    final allBookingIds = futureBookings.map((b) => b.id).toList();

    // Cancel all future bookings
    await cancelAffectedOccurrences(
      seriesId: conflict.seriesId,
      dates: futureBookings.map((b) => b.date).toList(),
      reason: 'Series ended due to conflicts',
    );

    return conflict_types.ConflictResolutionResult(
      conflictId: conflict.seriesId,
      resolutionType: conflict_types.ResolutionType.endSeries,
      success: true,
      cancelledBookings: allBookingIds,
      resolvedAt: DateTime.now(),
    );
  }

  Future<void> _updateConflictStatus(String conflictId, conflict_types.ConflictResolutionStatus status) async {
    await _supabaseClient
        .from('recurring_conflicts')
        .update({
          'status': status.name,
          'resolved_at': DateTime.now().toIso8601String(),
        })
        .eq('id', conflictId);
  }

  List<RecurringBookingChange> _createChangesFromResolution(conflict_types.ConflictResolutionResult result) {
    final changes = <RecurringBookingChange>[];

    for (final bookingId in result.cancelledBookings) {
      changes.add(RecurringBookingChange(
        bookingId: bookingId,
        changeType: ChangeType.cancelled,
        status: BookingChangeStatus.processed,
        reason: 'Conflict resolution',
      ));
    }

    for (final rescheduled in result.rescheduledBookings) {
      changes.add(RecurringBookingChange(
        bookingId: rescheduled.originalBookingId,
        changeType: ChangeType.rescheduled,
        originalDate: rescheduled.originalDate,
        newDate: rescheduled.newDate,
        originalChefId: null, // Would be filled from booking data
        newChefId: rescheduled.alternativeChefId,
        status: BookingChangeStatus.processed,
        reason: 'Conflict resolution',
      ));
    }

    return changes;
  }

  Future<void> _sendDetailedChangeNotification(
    String seriesId,
    List<RecurringBookingChange> changes,
    String userId,
  ) async {
    // This would send a detailed email notification
    // Implementation depends on email service integration
  }
}