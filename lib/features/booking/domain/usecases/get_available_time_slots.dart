import 'package:dartz/dartz.dart';
import 'package:homechef/core/error/failures.dart';
import '../entities/time_slot.dart';
import '../repositories/booking_availability_repository.dart';

class GetAvailableTimeSlots {
  final BookingAvailabilityRepository repository;

  const GetAvailableTimeSlots(this.repository);

  Future<Either<Failure, List<TimeSlot>>> call(GetAvailableTimeSlotsParams params) async {
    // Validate input parameters
    if (params.date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return const Left(ValidationFailure('Cannot get availability for past dates'));
    }

    if (params.duration.inMinutes < 30) {
      return const Left(ValidationFailure('Minimum booking duration is 30 minutes'));
    }

    if (params.numberOfGuests <= 0) {
      return const Left(ValidationFailure('Number of guests must be greater than 0'));
    }

    if (params.numberOfGuests > 50) {
      return const Left(ValidationFailure('Maximum number of guests is 50'));
    }

    // Check if booking is too far in advance (6 months max)
    final maxAdvanceDate = DateTime.now().add(const Duration(days: 180));
    if (params.date.isAfter(maxAdvanceDate)) {
      return const Left(BookingTooFarInAdvanceFailure());
    }

    return await repository.getAvailableTimeSlots(
      chefId: params.chefId,
      date: params.date,
      duration: params.duration,
      numberOfGuests: params.numberOfGuests,
    );
  }
}

class GetAvailableTimeSlotsParams {
  final String chefId;
  final DateTime date;
  final Duration duration;
  final int numberOfGuests;

  const GetAvailableTimeSlotsParams({
    required this.chefId,
    required this.date,
    required this.duration,
    required this.numberOfGuests,
  });
}