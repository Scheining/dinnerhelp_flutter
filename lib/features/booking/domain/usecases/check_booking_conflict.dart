import 'package:dartz/dartz.dart';
import 'package:homechef/core/error/failures.dart';
import '../repositories/booking_availability_repository.dart';

class CheckBookingConflict {
  final BookingAvailabilityRepository repository;

  const CheckBookingConflict(this.repository);

  Future<Either<Failure, bool>> call(CheckBookingConflictParams params) async {
    // Validate time format
    if (!_isValidTimeFormat(params.startTime) || !_isValidTimeFormat(params.endTime)) {
      return const Left(ValidationFailure('Invalid time format. Use HH:MM format'));
    }

    // Validate time range
    if (!_isValidTimeRange(params.startTime, params.endTime)) {
      return const Left(ValidationFailure('End time must be after start time'));
    }

    // Validate date
    if (params.date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return const Left(ValidationFailure('Cannot check conflict for past dates'));
    }

    return await repository.checkBookingConflict(
      chefId: params.chefId,
      date: params.date,
      startTime: params.startTime,
      endTime: params.endTime,
      excludeBookingId: params.excludeBookingId,
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

class CheckBookingConflictParams {
  final String chefId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String? excludeBookingId;

  const CheckBookingConflictParams({
    required this.chefId,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.excludeBookingId,
  });
}