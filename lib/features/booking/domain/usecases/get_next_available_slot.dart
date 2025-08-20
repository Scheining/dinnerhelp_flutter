import 'package:dartz/dartz.dart';
import 'package:homechef/core/error/failures.dart';
import '../entities/time_slot.dart';
import '../repositories/booking_availability_repository.dart';

class GetNextAvailableSlot {
  final BookingAvailabilityRepository repository;

  const GetNextAvailableSlot(this.repository);

  Future<Either<Failure, TimeSlot?>> call(GetNextAvailableSlotParams params) async {
    // Validate input parameters
    if (params.duration.inMinutes < 30) {
      return const Left(ValidationFailure('Minimum booking duration is 30 minutes'));
    }

    if (params.duration.inHours > 12) {
      return const Left(ValidationFailure('Maximum booking duration is 12 hours'));
    }

    // Don't search too far back in time
    if (params.afterDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return const Left(ValidationFailure('Cannot search for availability in the past'));
    }

    // Don't search more than 6 months in advance
    final maxSearchDate = DateTime.now().add(const Duration(days: 180));
    if (params.afterDate.isAfter(maxSearchDate)) {
      return const Left(ValidationFailure('Cannot search for availability more than 6 months in advance'));
    }

    return await repository.getNextAvailableSlot(
      chefId: params.chefId,
      afterDate: params.afterDate,
      duration: params.duration,
    );
  }
}

class GetNextAvailableSlotParams {
  final String chefId;
  final DateTime afterDate;
  final Duration duration;

  const GetNextAvailableSlotParams({
    required this.chefId,
    required this.afterDate,
    required this.duration,
  });
}