import 'package:dartz/dartz.dart';
import 'package:homechef/core/error/failures.dart';
import '../entities/time_slot.dart';
import '../entities/booking_request.dart';

abstract class BookingAvailabilityRepository {
  /// Get available time slots for a chef on a specific date
  Future<Either<Failure, List<TimeSlot>>> getAvailableTimeSlots({
    required String chefId,
    required DateTime date,
    required Duration duration,
    required int numberOfGuests,
  });

  /// Check if a booking conflicts with existing bookings
  Future<Either<Failure, bool>> checkBookingConflict({
    required String chefId,
    required DateTime date,
    required String startTime,
    required String endTime,
    String? excludeBookingId,
  });

  /// Validate if a booking request is valid for the chef
  Future<Either<Failure, bool>> validateBookingRequest({
    required BookingRequest bookingRequest,
  });

  /// Get chef's schedule for a specific week
  Future<Either<Failure, List<TimeSlot>>> getChefScheduleForWeek({
    required String chefId,
    required DateTime weekStart,
  });

  /// Find the next available time slot after a given date
  Future<Either<Failure, TimeSlot?>> getNextAvailableSlot({
    required String chefId,
    required DateTime afterDate,
    required Duration duration,
  });

  /// Check if chef is available at a specific time
  Future<Either<Failure, bool>> isChefAvailable({
    required String chefId,
    required DateTime startTime,
    required DateTime endTime,
  });
}