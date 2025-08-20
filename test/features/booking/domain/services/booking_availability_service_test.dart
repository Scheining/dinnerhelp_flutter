import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:homechef/core/error/failures.dart';
import 'package:homechef/features/booking/domain/entities/time_slot.dart';
import 'package:homechef/features/booking/domain/entities/chef_schedule_settings.dart';
import 'package:homechef/features/booking/domain/entities/chef_working_hours.dart';
import 'package:homechef/features/booking/domain/repositories/booking_availability_repository.dart';
import 'package:homechef/features/booking/domain/repositories/chef_schedule_repository.dart';
import 'package:homechef/features/booking/domain/services/chef_schedule_service.dart';
import 'package:homechef/features/booking/domain/services/booking_availability_service.dart';

import 'booking_availability_service_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<BookingAvailabilityRepository>(),
  MockSpec<ChefScheduleRepository>(),
  MockSpec<ChefScheduleService>(),
])
void main() {
  late BookingAvailabilityService bookingAvailabilityService;
  late MockBookingAvailabilityRepository mockBookingRepository;
  late MockChefScheduleRepository mockScheduleRepository;
  late MockChefScheduleService mockScheduleService;

  setUp(() {
    mockBookingRepository = MockBookingAvailabilityRepository();
    mockScheduleRepository = MockChefScheduleRepository();
    mockScheduleService = MockChefScheduleService();
    bookingAvailabilityService = BookingAvailabilityService(
      mockBookingRepository,
      mockScheduleRepository,
      mockScheduleService,
    );
  });

  group('BookingAvailabilityService', () {
    const String testChefId = 'chef-123';
    final DateTime testDate = DateTime(2024, 12, 25, 10, 0);
    const Duration testDuration = Duration(hours: 3);
    const int testNumberOfGuests = 4;

    group('getAvailableTimeSlots', () {
      test('should return available time slots when all conditions are met', () async {
        // Arrange
        final expectedTimeSlots = [
          TimeSlot(
            startTime: DateTime(2024, 12, 25, 10, 0),
            endTime: DateTime(2024, 12, 25, 13, 0),
            isAvailable: true,
          ),
          TimeSlot(
            startTime: DateTime(2024, 12, 25, 14, 0),
            endTime: DateTime(2024, 12, 25, 17, 0),
            isAvailable: true,
          ),
        ];

        final chefScheduleSettings = ChefScheduleSettings(
          chefId: testChefId,
          bufferTimeMinutes: 60,
          maxBookingsPerDay: 3,
          minNoticeHours: 24,
        );

        final workingHours = ChefWorkingHours(
          chefId: testChefId,
          dayOfWeek: testDate.weekday % 7,
          startTime: '09:00',
          endTime: '18:00',
        );

        when(mockScheduleService.getScheduleSettings(testChefId))
            .thenAnswer((_) async => Right(chefScheduleSettings));
        when(mockScheduleService.isWorkingDay(testChefId, testDate))
            .thenAnswer((_) async => const Right(true));
        when(mockScheduleService.getWorkingHours(testChefId, testDate.weekday % 7))
            .thenAnswer((_) async => Right(workingHours));
        when(mockScheduleService.getTimeOffPeriods(testChefId, testDate, testDate))
            .thenAnswer((_) async => const Right([]));
        when(mockScheduleService.getSpecificAvailability(testChefId, testDate))
            .thenAnswer((_) async => const Right([]));

        // Act
        final result = await bookingAvailabilityService.getAvailableTimeSlots(
          chefId: testChefId,
          date: testDate,
          duration: testDuration,
          numberOfGuests: testNumberOfGuests,
        );

        // Assert
        expect(result.isRight(), true);
        verify(mockScheduleService.getScheduleSettings(testChefId)).called(1);
        verify(mockScheduleService.isWorkingDay(testChefId, testDate)).called(1);
      });

      test('should return ValidationFailure for invalid duration', () async {
        // Act
        final result = await bookingAvailabilityService.getAvailableTimeSlots(
          chefId: testChefId,
          date: testDate,
          duration: const Duration(minutes: 15), // Too short
          numberOfGuests: testNumberOfGuests,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Expected failure'),
        );
      });

      test('should return ValidationFailure for invalid number of guests', () async {
        // Act
        final result = await bookingAvailabilityService.getAvailableTimeSlots(
          chefId: testChefId,
          date: testDate,
          duration: testDuration,
          numberOfGuests: 0, // Invalid
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Expected failure'),
        );
      });

      test('should return ValidationFailure for past date', () async {
        // Arrange
        final pastDate = DateTime.now().subtract(const Duration(days: 2));

        // Act
        final result = await bookingAvailabilityService.getAvailableTimeSlots(
          chefId: testChefId,
          date: pastDate,
          duration: testDuration,
          numberOfGuests: testNumberOfGuests,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Expected failure'),
        );
      });

      test('should return ChefUnavailableFailure when chef is not working', () async {
        // Arrange
        final chefScheduleSettings = ChefScheduleSettings(chefId: testChefId);

        when(mockScheduleService.getScheduleSettings(testChefId))
            .thenAnswer((_) async => Right(chefScheduleSettings));
        when(mockScheduleService.isWorkingDay(testChefId, testDate))
            .thenAnswer((_) async => const Right(false));

        // Act
        final result = await bookingAvailabilityService.getAvailableTimeSlots(
          chefId: testChefId,
          date: testDate,
          duration: testDuration,
          numberOfGuests: testNumberOfGuests,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ChefUnavailableFailure>()),
          (_) => fail('Expected failure'),
        );
      });
    });

    group('checkBookingConflict', () {
      test('should return false when no conflict exists', () async {
        // Arrange
        when(mockBookingRepository.checkBookingConflict(
          chefId: testChefId,
          date: testDate,
          startTime: '10:00',
          endTime: '13:00',
        )).thenAnswer((_) async => const Right(false));

        // Act
        final result = await bookingAvailabilityService.checkBookingConflict(
          chefId: testChefId,
          date: testDate,
          startTime: '10:00',
          endTime: '13:00',
        );

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected success'),
          (hasConflict) => expect(hasConflict, false),
        );
      });

      test('should return true when conflict exists', () async {
        // Arrange
        when(mockBookingRepository.checkBookingConflict(
          chefId: testChefId,
          date: testDate,
          startTime: '10:00',
          endTime: '13:00',
        )).thenAnswer((_) async => const Right(true));

        // Act
        final result = await bookingAvailabilityService.checkBookingConflict(
          chefId: testChefId,
          date: testDate,
          startTime: '10:00',
          endTime: '13:00',
        );

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected success'),
          (hasConflict) => expect(hasConflict, true),
        );
      });

      test('should return ValidationFailure for invalid time format', () async {
        // Act
        final result = await bookingAvailabilityService.checkBookingConflict(
          chefId: testChefId,
          date: testDate,
          startTime: '25:00', // Invalid hour
          endTime: '13:00',
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Expected failure'),
        );
      });

      test('should return ValidationFailure when end time is before start time', () async {
        // Act
        final result = await bookingAvailabilityService.checkBookingConflict(
          chefId: testChefId,
          date: testDate,
          startTime: '15:00',
          endTime: '13:00', // Before start time
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Expected failure'),
        );
      });
    });

    group('getChefScheduleForWeek', () {
      test('should return weekly schedule starting from Monday', () async {
        // Arrange
        final weekStart = DateTime(2024, 12, 23); // A Monday
        final expectedSchedule = [
          TimeSlot(
            startTime: DateTime(2024, 12, 23, 9, 0),
            endTime: DateTime(2024, 12, 23, 10, 0),
            isAvailable: true,
          ),
        ];

        when(mockBookingRepository.getChefScheduleForWeek(
          chefId: testChefId,
          weekStart: weekStart,
        )).thenAnswer((_) async => Right(expectedSchedule));

        // Act
        final result = await bookingAvailabilityService.getChefScheduleForWeek(
          chefId: testChefId,
          weekStart: weekStart,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected success'),
          (schedule) => expect(schedule, expectedSchedule),
        );
      });

      test('should adjust non-Monday date to Monday', () async {
        // Arrange
        final tuesdayDate = DateTime(2024, 12, 24); // A Tuesday
        final expectedMonday = DateTime(2024, 12, 23); // Previous Monday
        
        when(mockBookingRepository.getChefScheduleForWeek(
          chefId: testChefId,
          weekStart: expectedMonday,
        )).thenAnswer((_) async => const Right([]));

        // Act
        await bookingAvailabilityService.getChefScheduleForWeek(
          chefId: testChefId,
          weekStart: tuesdayDate,
        );

        // Assert
        verify(mockBookingRepository.getChefScheduleForWeek(
          chefId: testChefId,
          weekStart: expectedMonday,
        )).called(1);
      });
    });

    group('getNextAvailableSlot', () {
      test('should return next available slot', () async {
        // Arrange
        final afterDate = DateTime(2024, 12, 25);
        final expectedSlot = TimeSlot(
          startTime: DateTime(2024, 12, 26, 10, 0),
          endTime: DateTime(2024, 12, 26, 13, 0),
          isAvailable: true,
        );

        when(mockBookingRepository.getNextAvailableSlot(
          chefId: testChefId,
          afterDate: afterDate,
          duration: testDuration,
        )).thenAnswer((_) async => Right(expectedSlot));

        // Act
        final result = await bookingAvailabilityService.getNextAvailableSlot(
          chefId: testChefId,
          afterDate: afterDate,
          duration: testDuration,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected success'),
          (slot) => expect(slot, expectedSlot),
        );
      });

      test('should return null when no slot is available', () async {
        // Arrange
        final afterDate = DateTime(2024, 12, 25);

        when(mockBookingRepository.getNextAvailableSlot(
          chefId: testChefId,
          afterDate: afterDate,
          duration: testDuration,
        )).thenAnswer((_) async => const Right(null));

        // Act
        final result = await bookingAvailabilityService.getNextAvailableSlot(
          chefId: testChefId,
          afterDate: afterDate,
          duration: testDuration,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected success'),
          (slot) => expect(slot, null),
        );
      });
    });
  });
}