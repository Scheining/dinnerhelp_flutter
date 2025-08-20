import 'package:dartz/dartz.dart';
import 'package:homechef/core/error/failures.dart';
import '../entities/chef_working_hours.dart';
import '../entities/chef_availability.dart';
import '../entities/chef_schedule_settings.dart';
import '../entities/chef_time_off.dart';

abstract class ChefScheduleRepository {
  /// Get chef's working hours for a specific day of the week
  Future<Either<Failure, ChefWorkingHours?>> getWorkingHours({
    required String chefId,
    required int dayOfWeek,
  });

  /// Get all working hours for a chef
  Future<Either<Failure, List<ChefWorkingHours>>> getAllWorkingHours({
    required String chefId,
  });

  /// Get chef's specific availability overrides for a date range
  Future<Either<Failure, List<ChefAvailability>>> getSpecificAvailability({
    required String chefId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get chef's time off periods within a date range
  Future<Either<Failure, List<ChefTimeOff>>> getTimeOffPeriods({
    required String chefId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get chef's schedule settings (buffer time, max bookings, etc.)
  Future<Either<Failure, ChefScheduleSettings>> getScheduleSettings({
    required String chefId,
  });

  /// Update chef's working hours
  Future<Either<Failure, void>> updateWorkingHours({
    required String chefId,
    required List<ChefWorkingHours> workingHours,
  });

  /// Add time off period for chef
  Future<Either<Failure, void>> addTimeOff({
    required String chefId,
    required ChefTimeOff timeOff,
  });

  /// Update chef's schedule settings
  Future<Either<Failure, void>> updateScheduleSettings({
    required String chefId,
    required ChefScheduleSettings settings,
  });

  /// Add specific availability override
  Future<Either<Failure, void>> addSpecificAvailability({
    required String chefId,
    required ChefAvailability availability,
  });

  /// Remove time off period
  Future<Either<Failure, void>> removeTimeOff({
    required String chefId,
    required String timeOffId,
  });

  /// Check if chef is working on a specific date
  Future<Either<Failure, bool>> isWorkingDay({
    required String chefId,
    required DateTime date,
  });
}