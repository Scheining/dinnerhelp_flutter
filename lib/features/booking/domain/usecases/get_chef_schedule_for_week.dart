import 'package:dartz/dartz.dart';
import 'package:homechef/core/error/failures.dart';
import '../entities/time_slot.dart';
import '../repositories/booking_availability_repository.dart';

class GetChefScheduleForWeek {
  final BookingAvailabilityRepository repository;

  const GetChefScheduleForWeek(this.repository);

  Future<Either<Failure, List<TimeSlot>>> call(GetChefScheduleForWeekParams params) async {
    // Validate that the provided date is actually a Monday (start of week)
    if (params.weekStart.weekday != DateTime.monday) {
      return const Left(ValidationFailure('Week start must be a Monday'));
    }

    // Validate that we're not requesting too far in the past
    final oneMonthAgo = DateTime.now().subtract(const Duration(days: 30));
    if (params.weekStart.isBefore(oneMonthAgo)) {
      return const Left(ValidationFailure('Cannot get schedule for more than 1 month in the past'));
    }

    // Validate that we're not requesting too far in the future
    final sixMonthsFromNow = DateTime.now().add(const Duration(days: 180));
    if (params.weekStart.isAfter(sixMonthsFromNow)) {
      return const Left(ValidationFailure('Cannot get schedule for more than 6 months in advance'));
    }

    return await repository.getChefScheduleForWeek(
      chefId: params.chefId,
      weekStart: params.weekStart,
    );
  }
}

class GetChefScheduleForWeekParams {
  final String chefId;
  final DateTime weekStart; // Should be a Monday

  const GetChefScheduleForWeekParams({
    required this.chefId,
    required this.weekStart,
  });

  /// Helper method to get Monday of the week for any date
  static DateTime getMondayOfWeek(DateTime date) {
    final daysFromMonday = (date.weekday - DateTime.monday) % 7;
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: daysFromMonday));
  }
}