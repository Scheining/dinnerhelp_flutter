import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homechef/core/error/failures.dart';
import '../../domain/entities/time_slot.dart';
import '../../domain/entities/booking_request.dart';
import '../../domain/repositories/booking_availability_repository.dart';

class BookingAvailabilityRepositoryImpl implements BookingAvailabilityRepository {
  final SupabaseClient _supabaseClient;

  BookingAvailabilityRepositoryImpl({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  @override
  Future<Either<Failure, List<TimeSlot>>> getAvailableTimeSlots({
    required String chefId,
    required DateTime date,
    required Duration duration,
    required int numberOfGuests,
  }) async {
    try {
      // This is a simplified implementation
      // In a real app, this would:
      // 1. Get chef's working hours for the day
      // 2. Get existing bookings for the day
      // 3. Get time off periods
      // 4. Get specific availability overrides
      // 5. Calculate buffer times between bookings
      // 6. Generate available slots

      final dateStr = date.toIso8601String().split('T')[0];
      
      // Get existing bookings for the day
      final existingBookingsResponse = await _supabaseClient
          .from('bookings')
          .select('start_time, end_time')
          .eq('chef_id', chefId)
          .eq('date', dateStr)
          .inFilter('status', ['pending', 'accepted', 'confirmed', 'in_progress']);

      // Get chef's working hours for this day of week
      final dayOfWeek = date.weekday % 7;
      final workingHoursResponse = await _supabaseClient
          .from('chef_working_hours')
          .select('start_time, end_time')
          .eq('chef_id', chefId)
          .eq('day_of_week', dayOfWeek)
          .eq('is_active', true)
          .maybeSingle();

      if (workingHoursResponse == null) {
        return const Right([]); // Chef not working this day
      }

      // Generate time slots based on working hours
      final timeSlots = _generateTimeSlots(
        date: date,
        workingHours: workingHoursResponse,
        existingBookings: existingBookingsResponse,
        duration: duration,
      );

      return Right(timeSlots);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Database error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> checkBookingConflict({
    required String chefId,
    required DateTime date,
    required String startTime,
    required String endTime,
    String? excludeBookingId,
  }) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      
      var query = _supabaseClient
          .from('bookings')
          .select('id')
          .eq('chef_id', chefId)
          .eq('date', dateStr)
          .inFilter('status', ['pending', 'accepted', 'confirmed', 'in_progress']);

      if (excludeBookingId != null) {
        query = query.neq('id', excludeBookingId);
      }

      final existingBookings = await query;

      // Check for time conflicts
      for (final booking in existingBookings) {
        final bookingStartTime = booking['start_time'] as String;
        final bookingEndTime = booking['end_time'] as String;
        
        if (_timesOverlap(startTime, endTime, bookingStartTime, bookingEndTime)) {
          return const Right(true); // Conflict found
        }
      }

      return const Right(false); // No conflict
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Database error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> validateBookingRequest({
    required BookingRequest bookingRequest,
  }) async {
    // Check basic validation
    if (bookingRequest.numberOfGuests <= 0) {
      return const Left(ValidationFailure('Number of guests must be greater than 0'));
    }

    if (bookingRequest.date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return const Left(ValidationFailure('Cannot book for past dates'));
    }

    // Check for conflicts
    final conflictResult = await checkBookingConflict(
      chefId: bookingRequest.chefId,
      date: bookingRequest.date,
      startTime: bookingRequest.startTime,
      endTime: bookingRequest.endTime,
    );

    return conflictResult.fold(
      (failure) => Left(failure),
      (hasConflict) => hasConflict 
          ? const Left(BookingConflictFailure())
          : const Right(true),
    );
  }

  @override
  Future<Either<Failure, List<TimeSlot>>> getChefScheduleForWeek({
    required String chefId,
    required DateTime weekStart,
  }) async {
    try {
      final weekEnd = weekStart.add(const Duration(days: 7));
      final timeSlots = <TimeSlot>[];

      // Get schedule for each day of the week
      for (int i = 0; i < 7; i++) {
        final currentDate = weekStart.add(Duration(days: i));
        final slotsResult = await getAvailableTimeSlots(
          chefId: chefId,
          date: currentDate,
          duration: const Duration(hours: 1), // Default duration for display
          numberOfGuests: 4, // Default guest count
        );

        slotsResult.fold(
          (failure) {}, // Skip days with errors
          (slots) => timeSlots.addAll(slots),
        );
      }

      return Right(timeSlots);
    } catch (e) {
      return Left(ServerFailure('Failed to get weekly schedule: $e'));
    }
  }

  @override
  Future<Either<Failure, TimeSlot?>> getNextAvailableSlot({
    required String chefId,
    required DateTime afterDate,
    required Duration duration,
  }) async {
    try {
      // Search up to 30 days ahead
      final maxSearchDate = afterDate.add(const Duration(days: 30));
      var currentDate = afterDate;

      while (currentDate.isBefore(maxSearchDate)) {
        final slotsResult = await getAvailableTimeSlots(
          chefId: chefId,
          date: currentDate,
          duration: duration,
          numberOfGuests: 4, // Default
        );

        if (slotsResult.isRight()) {
          final slots = slotsResult.fold((_) => <TimeSlot>[], (s) => s);
          final availableSlots = slots.where((slot) => slot.isAvailable).toList();
          
          if (availableSlots.isNotEmpty) {
            return Right(availableSlots.first);
          }
        }

        currentDate = currentDate.add(const Duration(days: 1));
      }

      return const Right(null); // No available slot found
    } catch (e) {
      return Left(ServerFailure('Failed to find next available slot: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isChefAvailable({
    required String chefId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      final date = DateTime(startTime.year, startTime.month, startTime.day);
      final conflictResult = await checkBookingConflict(
        chefId: chefId,
        date: date,
        startTime: '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
        endTime: '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
      );

      return conflictResult.fold(
        (failure) => Left(failure),
        (hasConflict) => Right(!hasConflict),
      );
    } catch (e) {
      return Left(ServerFailure('Failed to check chef availability: $e'));
    }
  }

  // Private helper methods

  List<TimeSlot> _generateTimeSlots({
    required DateTime date,
    required Map<String, dynamic> workingHours,
    required List<Map<String, dynamic>> existingBookings,
    required Duration duration,
  }) {
    final slots = <TimeSlot>[];
    
    final startTime = workingHours['start_time'] as String;
    final endTime = workingHours['end_time'] as String;
    
    final workStart = _parseTimeForDate(date, startTime);
    final workEnd = _parseTimeForDate(date, endTime);
    
    // Generate slots in 30-minute intervals
    const slotInterval = Duration(minutes: 30);
    var currentTime = workStart;
    
    while (currentTime.add(duration).isBefore(workEnd) || 
           currentTime.add(duration).isAtSameMomentAs(workEnd)) {
      
      final slotEnd = currentTime.add(duration);
      final slotStartTimeStr = '${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}';
      final slotEndTimeStr = '${slotEnd.hour.toString().padLeft(2, '0')}:${slotEnd.minute.toString().padLeft(2, '0')}';
      
      // Check if this slot conflicts with existing bookings
      bool isAvailable = true;
      String? unavailabilityReason;
      
      for (final booking in existingBookings) {
        if (_timesOverlap(
          slotStartTimeStr, 
          slotEndTimeStr, 
          booking['start_time'] as String, 
          booking['end_time'] as String,
        )) {
          isAvailable = false;
          unavailabilityReason = 'Existing booking';
          break;
        }
      }
      
      slots.add(TimeSlot(
        startTime: currentTime,
        endTime: slotEnd,
        isAvailable: isAvailable,
        unavailabilityReason: unavailabilityReason,
      ));
      
      currentTime = currentTime.add(slotInterval);
    }
    
    return slots;
  }

  DateTime _parseTimeForDate(DateTime date, String time) {
    final parts = time.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
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
}