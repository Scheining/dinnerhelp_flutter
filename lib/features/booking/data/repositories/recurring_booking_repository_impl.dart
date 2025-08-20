import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homechef/core/error/failures.dart';
import '../../domain/entities/recurrence_pattern.dart';
import '../../domain/entities/booking_request.dart';
import '../../domain/entities/booking_occurrence.dart';
import '../../domain/repositories/recurring_booking_repository.dart';

class RecurringBookingRepositoryImpl implements RecurringBookingRepository {
  final SupabaseClient _supabaseClient;

  RecurringBookingRepositoryImpl({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  @override
  Future<Either<Failure, bool>> validateRecurringBookingPattern({
    required String chefId,
    required RecurrencePattern pattern,
    required String startTime,
    required String endTime,
  }) async {
    try {
      // Generate occurrences to validate
      final occurrences = pattern.generateOccurrences();
      
      if (occurrences.isEmpty) {
        return const Left(InvalidRecurrencePatternFailure('Pattern generates no occurrences'));
      }

      if (occurrences.length > 100) {
        return const Left(InvalidRecurrencePatternFailure('Pattern generates too many occurrences'));
      }

      // Check each occurrence for conflicts
      for (final occurrence in occurrences) {
        final dateStr = occurrence.toIso8601String().split('T')[0];
        
        // Check for existing bookings
        final existingBookings = await _supabaseClient
            .from('bookings')
            .select('start_time, end_time')
            .eq('chef_id', chefId)
            .eq('date', dateStr)
            .inFilter('status', ['pending', 'accepted', 'confirmed', 'in_progress']);

        // Check for time conflicts
        for (final booking in existingBookings) {
          if (_timesOverlap(
            startTime, 
            endTime, 
            booking['start_time'] as String, 
            booking['end_time'] as String,
          )) {
            return const Left(BookingConflictFailure('Recurring pattern conflicts with existing booking'));
          }
        }

        // Check if chef is working on this day
        final dayOfWeek = occurrence.weekday % 7;
        final workingHours = await _supabaseClient
            .from('chef_working_hours')
            .select('start_time, end_time')
            .eq('chef_id', chefId)
            .eq('day_of_week', dayOfWeek)
            .eq('is_active', true)
            .maybeSingle();

        if (workingHours == null) {
          return const Left(ChefUnavailableFailure('Chef is not working on some of the recurring dates'));
        }

        // Check time off periods
        final timeOff = await _supabaseClient
            .from('chef_time_off')
            .select('start_date, end_date')
            .eq('chef_id', chefId)
            .eq('is_approved', true)
            .lte('start_date', dateStr)
            .gte('end_date', dateStr);

        if (timeOff.isNotEmpty) {
          return const Left(ChefUnavailableFailure('Chef has time off during some of the recurring dates'));
        }
      }

      return const Right(true);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Database error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<DateTime>>> checkRecurringConflicts({
    required String chefId,
    required List<DateTime> occurrences,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final conflicts = <DateTime>[];

      for (final occurrence in occurrences) {
        final dateStr = occurrence.toIso8601String().split('T')[0];
        
        // Check for existing bookings
        final existingBookings = await _supabaseClient
            .from('bookings')
            .select('start_time, end_time')
            .eq('chef_id', chefId)
            .eq('date', dateStr)
            .inFilter('status', ['pending', 'accepted', 'confirmed', 'in_progress']);

        // Check for conflicts
        for (final booking in existingBookings) {
          if (_timesOverlap(
            startTime, 
            endTime, 
            booking['start_time'] as String, 
            booking['end_time'] as String,
          )) {
            conflicts.add(occurrence);
            break;
          }
        }
      }

      return Right(conflicts);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Database error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> createRecurringSeries({
    required BookingRequest bookingRequest,
    required RecurrencePattern pattern,
  }) async {
    try {
      // Create booking series record
      final seriesData = {
        'title': 'Recurring Booking - ${bookingRequest.chefId}',
        'description': 'Recurring booking series',
        'pattern': pattern.type.name,
        'interval_value': pattern.intervalValue,
        'start_date': pattern.startDate.toIso8601String().split('T')[0],
        'end_date': pattern.endDate?.toIso8601String().split('T')[0],
        'max_occurrences': pattern.maxOccurrences,
        'chef_id': bookingRequest.chefId,
        'user_id': bookingRequest.userId,
        'start_time': bookingRequest.startTime,
        'end_time': bookingRequest.endTime,
        'number_of_guests': bookingRequest.numberOfGuests,
        'selected_menu_id': bookingRequest.menuId,
        'base_amount': 0, // This should be calculated based on chef rates
        'is_active': true,
        'total_occurrences': pattern.generateOccurrences().length,
        'completed_occurrences': 0,
        'cancelled_occurrences': 0,
      };

      final seriesResponse = await _supabaseClient
          .from('booking_series')
          .insert(seriesData)
          .select('id')
          .single();

      final seriesId = seriesResponse['id'] as String;

      // Generate and create individual booking occurrences
      final occurrences = pattern.generateOccurrences();
      final bookingOccurrenceData = occurrences.map((occurrence) => {
        'series_id': seriesId,
        'date': occurrence.toIso8601String().split('T')[0],
        'start_time': bookingRequest.startTime,
        'end_time': bookingRequest.endTime,
        'status': 'pending',
      }).toList();

      await _supabaseClient
          .from('booking_occurrences')
          .insert(bookingOccurrenceData);

      return Right(seriesId);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Database error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<RecurringBookingSeries>>> getChefRecurringSeries({
    required String chefId,
    bool? activeOnly,
  }) async {
    try {
      var query = _supabaseClient
          .from('booking_series')
          .select('*')
          .eq('chef_id', chefId);

      if (activeOnly == true) {
        query = query.eq('is_active', true);
      }

      final response = await query.order('created_at', ascending: false);

      final series = response.map((json) => _parseRecurringBookingSeries(json)).toList();
      return Right(series);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Database error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BookingOccurrence>>> getFutureBookingsInSeries(String seriesId) async {
    try {
      final now = DateTime.now();
      final response = await _supabaseClient
          .from('bookings')
          .select('*')
          .eq('series_id', seriesId)
          .gte('date', now.toIso8601String().split('T')[0])
          .order('date', ascending: true);

      final bookings = response.map<BookingOccurrence>((json) => BookingOccurrence(
        id: json['id'],
        userId: json['user_id'] ?? '',
        chefId: json['chef_id'] ?? '',
        seriesId: json['series_id'] ?? '',
        bookingId: json['id'],
        date: DateTime.parse(json['date']),
        startTime: json['start_time'],
        endTime: json['end_time'],
        numberOfGuests: json['number_of_guests'] ?? 0,
        status: _mapBookingStatus(json['status']),
        cancellationReason: json['cancellation_reason'],
        createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
        paymentStatus: json['payment_status'],
        stripePaymentIntentId: json['stripe_payment_intent_id'],
      )).toList();

      return Right(bookings);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Database error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<RecurringBookingSeries>>> getUserRecurringSeries({
    required String userId,
    bool? activeOnly,
  }) async {
    try {
      var query = _supabaseClient
          .from('booking_series')
          .select('*')
          .eq('user_id', userId);

      if (activeOnly == true) {
        query = query.eq('is_active', true);
      }

      final response = await query.order('created_at', ascending: false);

      final series = response.map((json) => _parseRecurringBookingSeries(json)).toList();
      return Right(series);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Database error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelRecurringSeries({
    required String seriesId,
    required CancellationType cancellationType,
  }) async {
    try {
      switch (cancellationType) {
        case CancellationType.entireSeries:
          // Mark series as inactive
          await _supabaseClient
              .from('booking_series')
              .update({'is_active': false})
              .eq('id', seriesId);

          // Cancel all pending occurrences
          await _supabaseClient
              .from('booking_occurrences')
              .update({'status': 'cancelled'})
              .eq('series_id', seriesId)
              .eq('status', 'pending');
          break;

        case CancellationType.thisAndFuture:
          final today = DateTime.now().toIso8601String().split('T')[0];
          
          // Cancel future occurrences
          await _supabaseClient
              .from('booking_occurrences')
              .update({'status': 'cancelled'})
              .eq('series_id', seriesId)
              .gte('date', today)
              .eq('status', 'pending');
          break;

        case CancellationType.thisOccurrenceOnly:
          // This should be handled by cancelSeriesOccurrence instead
          return const Left(ValidationFailure('Use cancelSeriesOccurrence for single occurrence cancellation'));
      }

      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Database error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> modifyRecurringSeries({
    required String seriesId,
    required RecurringSeriesModification modifications,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (modifications.title != null) {
        updateData['title'] = modifications.title;
      }
      if (modifications.description != null) {
        updateData['description'] = modifications.description;
      }
      if (modifications.startTime != null) {
        updateData['start_time'] = modifications.startTime;
      }
      if (modifications.endTime != null) {
        updateData['end_time'] = modifications.endTime;
      }
      if (modifications.numberOfGuests != null) {
        updateData['number_of_guests'] = modifications.numberOfGuests;
      }
      if (modifications.newEndDate != null) {
        updateData['end_date'] = modifications.newEndDate!.toIso8601String().split('T')[0];
      }
      if (modifications.newMaxOccurrences != null) {
        updateData['max_occurrences'] = modifications.newMaxOccurrences;
      }
      if (modifications.isActive != null) {
        updateData['is_active'] = modifications.isActive;
      }

      updateData['updated_at'] = DateTime.now().toIso8601String();

      await _supabaseClient
          .from('booking_series')
          .update(updateData)
          .eq('id', seriesId);

      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Database error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BookingOccurrence>>> getSeriesOccurrences({
    required String seriesId,
  }) async {
    try {
      final response = await _supabaseClient
          .from('booking_occurrences')
          .select('*')
          .eq('series_id', seriesId)
          .order('date');

      final occurrences = response.map((json) => _parseBookingOccurrence(json)).toList();
      return Right(occurrences);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Database error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelSeriesOccurrence({
    required String seriesId,
    required String occurrenceId,
  }) async {
    try {
      await _supabaseClient
          .from('booking_occurrences')
          .update({
            'status': 'cancelled',
            'cancellation_reason': 'Cancelled by user',
          })
          .eq('id', occurrenceId)
          .eq('series_id', seriesId);

      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Database error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  // Private helper methods

  RecurringBookingSeries _parseRecurringBookingSeries(Map<String, dynamic> json) {
    return RecurringBookingSeries(
      id: json['id'],
      userId: json['user_id'],
      chefId: json['chef_id'],
      title: json['title'],
      description: json['description'],
      pattern: RecurrencePattern(
        type: RecurrenceTypeExtension.fromString(json['pattern']),
        intervalValue: json['interval_value'] ?? 1,
        startDate: DateTime.parse(json['start_date']),
        endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
        maxOccurrences: json['max_occurrences'],
      ),
      startTime: json['start_time'],
      endTime: json['end_time'],
      numberOfGuests: json['number_of_guests'],
      menuId: json['selected_menu_id'],
      isActive: json['is_active'] ?? true,
      totalOccurrences: json['total_occurrences'] ?? 0,
      completedOccurrences: json['completed_occurrences'] ?? 0,
      cancelledOccurrences: json['cancelled_occurrences'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  BookingOccurrence _parseBookingOccurrence(Map<String, dynamic> json) {
    return BookingOccurrence(
      id: json['id'],
      userId: json['user_id'] ?? '',
      chefId: json['chef_id'] ?? '',
      seriesId: json['series_id'],
      bookingId: json['booking_id'] ?? '',
      date: DateTime.parse(json['date']),
      startTime: json['start_time'],
      endTime: json['end_time'],
      numberOfGuests: json['number_of_guests'] ?? 0,
      status: _parseOccurrenceStatus(json['status']),
      cancellationReason: json['cancellation_reason'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      paymentStatus: json['payment_status'],
      stripePaymentIntentId: json['stripe_payment_intent_id'],
    );
  }

  BookingOccurrenceStatus _mapBookingStatus(String status) {
    return _parseOccurrenceStatus(status);
  }

  BookingOccurrenceStatus _parseOccurrenceStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return BookingOccurrenceStatus.pending;
      case 'confirmed':
        return BookingOccurrenceStatus.confirmed;
      case 'completed':
        return BookingOccurrenceStatus.completed;
      case 'cancelled':
        return BookingOccurrenceStatus.cancelled;
      case 'skipped':
        return BookingOccurrenceStatus.skipped;
      default:
        return BookingOccurrenceStatus.pending;
    }
  }

  bool _timesOverlap(String start1, String end1, String start2, String end2) {
    final start1Minutes = _timeToMinutes(start1);
    final end1Minutes = _timeToMinutes(end1);
    final start2Minutes = _timeToMinutes(start2);
    final end2Minutes = _timeToMinutes(end2);
    
    return start1Minutes < end2Minutes && end1Minutes > start2Minutes;
  }

  int _timeToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  @override
  Future<Either<Failure, List<BookingOccurrence>>> getBookingsByDates(
    String seriesId,
    List<DateTime> dates,
  ) async {
    try {
      final dateStrings = dates.map((d) => d.toIso8601String().split('T')[0]).toList();
      
      final response = await _supabaseClient
          .from('bookings')
          .select('*')
          .eq('series_id', seriesId)
          .inFilter('date', dateStrings);

      final bookings = response.map<BookingOccurrence>((json) => BookingOccurrence(
        id: json['id'],
        userId: json['user_id'] ?? '',
        chefId: json['chef_id'] ?? '',
        seriesId: json['series_id'] ?? '',
        bookingId: json['id'],
        date: DateTime.parse(json['date']),
        startTime: json['start_time'],
        endTime: json['end_time'],
        numberOfGuests: json['number_of_guests'] ?? 0,
        status: _mapBookingStatus(json['status']),
        cancellationReason: json['cancellation_reason'],
        createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
        paymentStatus: json['payment_status'],
        stripePaymentIntentId: json['stripe_payment_intent_id'],
      )).toList();

      return Right(bookings);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Database error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}