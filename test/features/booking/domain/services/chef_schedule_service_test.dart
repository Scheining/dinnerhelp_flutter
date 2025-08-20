import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:homechef/core/error/failures.dart';
import 'package:homechef/features/booking/domain/entities/chef_working_hours.dart';
import 'package:homechef/features/booking/domain/entities/chef_schedule_settings.dart';
import 'package:homechef/features/booking/domain/entities/chef_time_off.dart';
import 'package:homechef/features/booking/domain/entities/chef_availability.dart';
import 'package:homechef/features/booking/domain/repositories/chef_schedule_repository.dart';
import 'package:homechef/features/booking/domain/services/chef_schedule_service.dart';

import 'chef_schedule_service_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ChefScheduleRepository>(),
])
void main() {
  late ChefScheduleService chefScheduleService;
  late MockChefScheduleRepository mockRepository;

  setUp(() {
    mockRepository = MockChefScheduleRepository();
    chefScheduleService = ChefScheduleService(mockRepository);
  });

  group('ChefScheduleService', () {
    const String testChefId = 'chef-123';
    final DateTime testDate = DateTime(2024, 12, 25); // Wednesday

    group('getWorkingHours', () {
      test('should return working hours for valid input', () async {
        // Arrange
        final workingHours = ChefWorkingHours(
          chefId: testChefId,
          dayOfWeek: 3, // Wednesday
          startTime: '09:00',
          endTime: '17:00',
        );

        when(mockRepository.getWorkingHours(
          chefId: testChefId,
          dayOfWeek: 3,
        )).thenAnswer((_) async => Right(workingHours));

        // Act
        final result = await chefScheduleService.getWorkingHours(testChefId, 3);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected success'),
          (hours) => expect(hours, workingHours),
        );
        verify(mockRepository.getWorkingHours(
          chefId: testChefId,
          dayOfWeek: 3,
        )).called(1);
      });

      test('should return ValidationFailure for empty chef ID', () async {
        // Act
        final result = await chefScheduleService.getWorkingHours('', 3);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Expected failure'),
        );
        verifyNever(mockRepository.getWorkingHours(
          chefId: anyNamed('chefId'),
          dayOfWeek: anyNamed('dayOfWeek'),
        ));
      });

      test('should return ValidationFailure for invalid day of week', () async {
        // Act
        final result = await chefScheduleService.getWorkingHours(testChefId, 7);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Expected failure'),
        );
      });

      test('should return null when no working hours exist', () async {
        // Arrange
        when(mockRepository.getWorkingHours(
          chefId: testChefId,
          dayOfWeek: 3,
        )).thenAnswer((_) async => const Right(null));

        // Act
        final result = await chefScheduleService.getWorkingHours(testChefId, 3);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected success'),
          (hours) => expect(hours, null),
        );
      });
    });

    group('getAllWorkingHours', () {
      test('should return all working hours for chef', () async {
        // Arrange
        final workingHoursList = [
          ChefWorkingHours(
            chefId: testChefId,
            dayOfWeek: 1, // Monday
            startTime: '09:00',
            endTime: '17:00',
          ),
          ChefWorkingHours(
            chefId: testChefId,
            dayOfWeek: 2, // Tuesday
            startTime: '10:00',
            endTime: '18:00',
          ),
        ];

        when(mockRepository.getAllWorkingHours(chefId: testChefId))
            .thenAnswer((_) async => Right(workingHoursList));

        // Act
        final result = await chefScheduleService.getAllWorkingHours(testChefId);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected success'),
          (hours) => expect(hours, workingHoursList),
        );
      });

      test('should return ValidationFailure for empty chef ID', () async {
        // Act
        final result = await chefScheduleService.getAllWorkingHours('');

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Expected failure'),
        );
      });
    });

    group('getTimeOffPeriods', () {
      test('should return time off periods within date range', () async {
        // Arrange
        final startDate = DateTime(2024, 12, 20);
        final endDate = DateTime(2024, 12, 30);
        final timeOffPeriods = [
          ChefTimeOff(
            chefId: testChefId,
            startDate: DateTime(2024, 12, 24),
            endDate: DateTime(2024, 12, 26),
            type: TimeOffType.holiday,
          ),
        ];

        when(mockRepository.getTimeOffPeriods(
          chefId: testChefId,
          startDate: startDate,
          endDate: endDate,
        )).thenAnswer((_) async => Right(timeOffPeriods));

        // Act
        final result = await chefScheduleService.getTimeOffPeriods(
          testChefId,
          startDate,
          endDate,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected success'),
          (periods) => expect(periods, timeOffPeriods),
        );
      });

      test('should return ValidationFailure when end date is before start date', () async {
        // Arrange
        final startDate = DateTime(2024, 12, 30);
        final endDate = DateTime(2024, 12, 20);

        // Act
        final result = await chefScheduleService.getTimeOffPeriods(
          testChefId,
          startDate,
          endDate,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Expected failure'),
        );
      });

      test('should return ValidationFailure for date range exceeding 1 year', () async {
        // Arrange
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2025, 2, 1); // More than 1 year

        // Act
        final result = await chefScheduleService.getTimeOffPeriods(
          testChefId,
          startDate,
          endDate,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Expected failure'),
        );
      });
    });

    group('getScheduleSettings', () {
      test('should return schedule settings for chef', () async {
        // Arrange
        final settings = ChefScheduleSettings(
          chefId: testChefId,
          bufferTimeMinutes: 90,
          maxBookingsPerDay: 3,
        );

        when(mockRepository.getScheduleSettings(chefId: testChefId))
            .thenAnswer((_) async => Right(settings));

        // Act
        final result = await chefScheduleService.getScheduleSettings(testChefId);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected success'),
          (returnedSettings) => expect(returnedSettings, settings),
        );
      });

      test('should return ValidationFailure for empty chef ID', () async {
        // Act
        final result = await chefScheduleService.getScheduleSettings('');

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Expected failure'),
        );
      });
    });

    group('calculateBufferTime', () {
      test('should return buffer time from schedule settings', () async {
        // Arrange
        final settings = ChefScheduleSettings(
          chefId: testChefId,
          bufferTimeMinutes: 90,
        );

        when(mockRepository.getScheduleSettings(chefId: testChefId))
            .thenAnswer((_) async => Right(settings));

        // Act
        final result = await chefScheduleService.calculateBufferTime(testChefId);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected success'),
          (duration) => expect(duration, const Duration(minutes: 90)),
        );
      });
    });

    group('getMaxBookingsPerDay', () {
      test('should return max bookings per day from settings', () async {
        // Arrange
        final settings = ChefScheduleSettings(
          chefId: testChefId,
          maxBookingsPerDay: 5,
        );

        when(mockRepository.getScheduleSettings(chefId: testChefId))
            .thenAnswer((_) async => Right(settings));

        // Act
        final result = await chefScheduleService.getMaxBookingsPerDay(testChefId);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected success'),
          (maxBookings) => expect(maxBookings, 5),
        );
      });
    });

    group('isWorkingDay', () {
      test('should return true when chef is working and no time off', () async {
        // Arrange
        final workingHours = ChefWorkingHours(
          chefId: testChefId,
          dayOfWeek: testDate.weekday % 7,
          startTime: '09:00',
          endTime: '17:00',
          isActive: true,
        );

        when(mockRepository.getWorkingHours(
          chefId: testChefId,
          dayOfWeek: testDate.weekday % 7,
        )).thenAnswer((_) async => Right(workingHours));
        
        when(mockRepository.getTimeOffPeriods(
          chefId: testChefId,
          startDate: testDate,
          endDate: testDate,
        )).thenAnswer((_) async => const Right([]));
        
        when(mockRepository.getSpecificAvailability(
          chefId: testChefId,
          startDate: any,
          endDate: any,
        )).thenAnswer((_) async => const Right([]));

        // Act
        final result = await chefScheduleService.isWorkingDay(testChefId, testDate);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected success'),
          (isWorking) => expect(isWorking, true),
        );
      });

      test('should return false when chef has no working hours for the day', () async {
        // Arrange
        when(mockRepository.getWorkingHours(
          chefId: testChefId,
          dayOfWeek: testDate.weekday % 7,
        )).thenAnswer((_) async => const Right(null));

        // Act
        final result = await chefScheduleService.isWorkingDay(testChefId, testDate);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected success'),
          (isWorking) => expect(isWorking, false),
        );
      });

      test('should return false when chef has time off', () async {
        // Arrange
        final workingHours = ChefWorkingHours(
          chefId: testChefId,
          dayOfWeek: testDate.weekday % 7,
          startTime: '09:00',
          endTime: '17:00',
          isActive: true,
        );

        final timeOff = ChefTimeOff(
          chefId: testChefId,
          startDate: testDate,
          endDate: testDate,
          type: TimeOffType.vacation,
        );

        when(mockRepository.getWorkingHours(
          chefId: testChefId,
          dayOfWeek: testDate.weekday % 7,
        )).thenAnswer((_) async => Right(workingHours));
        
        when(mockRepository.getTimeOffPeriods(
          chefId: testChefId,
          startDate: testDate,
          endDate: testDate,
        )).thenAnswer((_) async => Right([timeOff]));

        // Act
        final result = await chefScheduleService.isWorkingDay(testChefId, testDate);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected success'),
          (isWorking) => expect(isWorking, false),
        );
      });

      test('should return false when chef has all-day unavailability override', () async {
        // Arrange
        final workingHours = ChefWorkingHours(
          chefId: testChefId,
          dayOfWeek: testDate.weekday % 7,
          startTime: '09:00',
          endTime: '17:00',
          isActive: true,
        );

        final unavailability = ChefAvailability(
          chefId: testChefId,
          date: testDate,
          type: AvailabilityType.unavailable,
        );

        when(mockRepository.getWorkingHours(
          chefId: testChefId,
          dayOfWeek: testDate.weekday % 7,
        )).thenAnswer((_) async => Right(workingHours));
        
        when(mockRepository.getTimeOffPeriods(
          chefId: testChefId,
          startDate: testDate,
          endDate: testDate,
        )).thenAnswer((_) async => const Right([]));
        
        when(mockRepository.getSpecificAvailability(
          chefId: testChefId,
          startDate: any,
          endDate: any,
        )).thenAnswer((_) async => Right([unavailability]));

        // Act
        final result = await chefScheduleService.isWorkingDay(testChefId, testDate);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected success'),
          (isWorking) => expect(isWorking, false),
        );
      });
    });

    group('updateWorkingHours', () {
      test('should update working hours successfully', () async {
        // Arrange
        final workingHours = [
          ChefWorkingHours(
            chefId: testChefId,
            dayOfWeek: 1,
            startTime: '09:00',
            endTime: '17:00',
          ),
        ];

        when(mockRepository.updateWorkingHours(
          chefId: testChefId,
          workingHours: workingHours,
        )).thenAnswer((_) async => const Right(null));

        // Act
        final result = await chefScheduleService.updateWorkingHours(
          testChefId,
          workingHours,
        );

        // Assert
        expect(result.isRight(), true);
        verify(mockRepository.updateWorkingHours(
          chefId: testChefId,
          workingHours: workingHours,
        )).called(1);
      });

      test('should return ValidationFailure for mismatched chef ID', () async {
        // Arrange
        final workingHours = [
          ChefWorkingHours(
            chefId: 'different-chef-id',
            dayOfWeek: 1,
            startTime: '09:00',
            endTime: '17:00',
          ),
        ];

        // Act
        final result = await chefScheduleService.updateWorkingHours(
          testChefId,
          workingHours,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Expected failure'),
        );
      });

      test('should return ValidationFailure for invalid time format', () async {
        // Arrange
        final workingHours = [
          ChefWorkingHours(
            chefId: testChefId,
            dayOfWeek: 1,
            startTime: '25:00', // Invalid
            endTime: '17:00',
          ),
        ];

        // Act
        final result = await chefScheduleService.updateWorkingHours(
          testChefId,
          workingHours,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Expected failure'),
        );
      });
    });

    group('addTimeOff', () {
      test('should add time off successfully', () async {
        // Arrange
        final timeOff = ChefTimeOff(
          chefId: testChefId,
          startDate: DateTime(2024, 12, 24),
          endDate: DateTime(2024, 12, 26),
          type: TimeOffType.vacation,
        );

        when(mockRepository.addTimeOff(
          chefId: testChefId,
          timeOff: timeOff,
        )).thenAnswer((_) async => const Right(null));

        // Act
        final result = await chefScheduleService.addTimeOff(testChefId, timeOff);

        // Assert
        expect(result.isRight(), true);
        verify(mockRepository.addTimeOff(
          chefId: testChefId,
          timeOff: timeOff,
        )).called(1);
      });

      test('should return ValidationFailure for mismatched chef ID', () async {
        // Arrange
        final timeOff = ChefTimeOff(
          chefId: 'different-chef-id',
          startDate: DateTime(2024, 12, 24),
          endDate: DateTime(2024, 12, 26),
          type: TimeOffType.vacation,
        );

        // Act
        final result = await chefScheduleService.addTimeOff(testChefId, timeOff);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Expected failure'),
        );
      });

      test('should return ValidationFailure when end date is before start date', () async {
        // Arrange
        final timeOff = ChefTimeOff(
          chefId: testChefId,
          startDate: DateTime(2024, 12, 26),
          endDate: DateTime(2024, 12, 24), // Before start date
          type: TimeOffType.vacation,
        );

        // Act
        final result = await chefScheduleService.addTimeOff(testChefId, timeOff);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Expected failure'),
        );
      });
    });
  });
}