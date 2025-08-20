import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homechef/core/error/failures.dart';
import '../../domain/entities/chef_working_hours.dart';
import '../../domain/entities/chef_availability.dart';
import '../../domain/entities/chef_schedule_settings.dart';
import '../../domain/entities/chef_time_off.dart';
import '../../domain/repositories/chef_schedule_repository.dart';
import '../models/chef_working_hours_model.dart';
import '../models/chef_availability_model.dart';
import '../models/chef_schedule_settings_model.dart';
import '../models/chef_time_off_model.dart';

class ChefScheduleRepositoryImpl implements ChefScheduleRepository {
  final SupabaseClient _supabaseClient;

  ChefScheduleRepositoryImpl({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  @override
  Future<Either<Failure, ChefWorkingHours?>> getWorkingHours({
    required String chefId,
    required int dayOfWeek,
  }) async {
    try {
      final response = await _supabaseClient
          .from('chef_working_hours')
          .select('*')
          .eq('chef_id', chefId)
          .eq('day_of_week', dayOfWeek)
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) {
        return const Right(null);
      }

      final model = ChefWorkingHoursModel.fromJson(response);
      return Right(model.toDomain());
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Database error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ChefWorkingHours>>> getAllWorkingHours({
    required String chefId,
  }) async {
    try {
      final response = await _supabaseClient
          .from('chef_working_hours')
          .select('*')
          .eq('chef_id', chefId)
          .order('day_of_week');

      final workingHours = response
          .map((json) => ChefWorkingHoursModel.fromJson(json).toDomain())
          .toList();

      return Right(workingHours);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Database error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ChefAvailability>>> getSpecificAvailability({
    required String chefId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final startDateStr = startDate.toIso8601String().split('T')[0];
      final endDateStr = endDate.toIso8601String().split('T')[0];

      final response = await _supabaseClient
          .from('chef_availability')
          .select('*')
          .eq('chef_id', chefId)
          .gte('date', startDateStr)
          .lte('date', endDateStr);

      final availability = response
          .map((json) => ChefAvailabilityModel.fromJson(json).toDomain())
          .toList();

      return Right(availability);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Database error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ChefTimeOff>>> getTimeOffPeriods({
    required String chefId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final startDateStr = startDate.toIso8601String().split('T')[0];
      final endDateStr = endDate.toIso8601String().split('T')[0];

      final response = await _supabaseClient
          .from('chef_time_off')
          .select('*')
          .eq('chef_id', chefId)
          .eq('is_approved', true)
          .or('start_date.lte.$endDateStr,end_date.gte.$startDateStr');

      final timeOffPeriods = response
          .map((json) => ChefTimeOffModel.fromJson(json).toDomain())
          .toList();

      return Right(timeOffPeriods);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Database error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, ChefScheduleSettings>> getScheduleSettings({
    required String chefId,
  }) async {
    try {
      final response = await _supabaseClient
          .from('chef_schedule_settings')
          .select('*')
          .eq('chef_id', chefId)
          .maybeSingle();

      if (response == null) {
        // Return default settings if none exist
        return Right(ChefScheduleSettings(chefId: chefId));
      }

      final model = ChefScheduleSettingsModel.fromJson(response);
      return Right(model.toDomain());
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Database error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateWorkingHours({
    required String chefId,
    required List<ChefWorkingHours> workingHours,
  }) async {
    try {
      // Delete existing working hours for the chef
      await _supabaseClient
          .from('chef_working_hours')
          .delete()
          .eq('chef_id', chefId);

      // Insert new working hours
      if (workingHours.isNotEmpty) {
        final workingHoursData = workingHours
            .map((hours) => ChefWorkingHoursModel.fromDomain(hours).toJson())
            .toList();

        await _supabaseClient
            .from('chef_working_hours')
            .insert(workingHoursData);
      }

      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Database error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addTimeOff({
    required String chefId,
    required ChefTimeOff timeOff,
  }) async {
    try {
      final timeOffData = ChefTimeOffModel.fromDomain(timeOff).toJson();
      
      await _supabaseClient
          .from('chef_time_off')
          .insert(timeOffData);

      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Database error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateScheduleSettings({
    required String chefId,
    required ChefScheduleSettings settings,
  }) async {
    try {
      final settingsData = ChefScheduleSettingsModel.fromDomain(settings).toJson();
      
      await _supabaseClient
          .from('chef_schedule_settings')
          .upsert(settingsData);

      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Database error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addSpecificAvailability({
    required String chefId,
    required ChefAvailability availability,
  }) async {
    try {
      final availabilityData = ChefAvailabilityModel.fromDomain(availability).toJson();
      
      await _supabaseClient
          .from('chef_availability')
          .insert(availabilityData);

      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Database error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeTimeOff({
    required String chefId,
    required String timeOffId,
  }) async {
    try {
      await _supabaseClient
          .from('chef_time_off')
          .delete()
          .eq('id', timeOffId)
          .eq('chef_id', chefId);

      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Database error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isWorkingDay({
    required String chefId,
    required DateTime date,
  }) async {
    try {
      final dayOfWeek = date.weekday % 7;
      
      // Get working hours for this day
      final workingHoursResult = await getWorkingHours(
        chefId: chefId,
        dayOfWeek: dayOfWeek,
      );

      if (workingHoursResult.isLeft()) {
        return workingHoursResult.fold((failure) => Left(failure), (_) => throw UnimplementedError());
      }

      final workingHours = workingHoursResult.fold((_) => throw UnimplementedError(), (hours) => hours);
      if (workingHours == null || !workingHours.isActive) {
        return const Right(false);
      }

      // Check for time off
      final timeOffResult = await getTimeOffPeriods(
        chefId: chefId,
        startDate: date,
        endDate: date,
      );

      if (timeOffResult.isLeft()) {
        return timeOffResult.fold((failure) => Left(failure), (_) => throw UnimplementedError());
      }

      final timeOffPeriods = timeOffResult.fold((_) => throw UnimplementedError(), (periods) => periods);
      final hasTimeOff = timeOffPeriods.any((timeOff) => timeOff.includesDate(date));
      
      if (hasTimeOff) {
        return const Right(false);
      }

      // Check specific availability overrides
      final availabilityResult = await getSpecificAvailability(
        chefId: chefId,
        startDate: date,
        endDate: date,
      );

      if (availabilityResult.isLeft()) {
        return availabilityResult.fold((failure) => Left(failure), (_) => throw UnimplementedError());
      }

      final specificAvailability = availabilityResult.fold((_) => throw UnimplementedError(), (avail) => avail);
      
      // Check for all-day unavailability
      final allDayUnavailable = specificAvailability
          .where((avail) => avail.isAllDay && avail.isUnavailable)
          .isNotEmpty;

      if (allDayUnavailable) {
        return const Right(false);
      }

      return const Right(true);
    } catch (e) {
      return Left(ServerFailure('Failed to check working day: $e'));
    }
  }
}