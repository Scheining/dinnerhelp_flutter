import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:homechef/features/booking/domain/entities/time_slot.dart';
import 'package:homechef/features/booking/domain/entities/chef_availability.dart';
import 'package:homechef/features/booking/domain/entities/chef_working_hours.dart';
import 'package:homechef/features/booking/domain/services/booking_availability_service.dart';
import 'package:homechef/features/booking/domain/services/chef_schedule_service.dart';
import 'package:homechef/features/booking/domain/services/chef_unavailability_handler.dart';
import 'package:homechef/core/error/failures.dart';

import '../../test_helpers/test_helpers.dart';
import 'booking_availability_service_test.mocks.dart';

@GenerateMocks([ChefScheduleService, ChefUnavailabilityHandler])
void main() {
  late BookingAvailabilityService service;
  late MockChefScheduleService mockScheduleService;
  late MockChefUnavailabilityHandler mockUnavailabilityHandler;

  setUp(() {
    mockScheduleService = MockChefScheduleService();
    mockUnavailabilityHandler = MockChefUnavailabilityHandler();
    service = BookingAvailabilityService(
      scheduleService: mockScheduleService,
      unavailabilityHandler: mockUnavailabilityHandler,
    );
  });

  group('BookingAvailabilityService', () {
    const String testChefId = TestDataFactory.testChefId;
    final DateTime testDate = TestDataFactory.testDate;

    group('getAvailableTimeSlots', () {
      test('should return available time slots when chef is available', () async {
        // Arrange
        final workingHours = ChefWorkingHours(
          id: 'wh-1',
          chefId: testChefId,
          dayOfWeek: testDate.weekday,
          startTime: '17:00',
          endTime: '23:00',
          isAvailable: true,
        );

        final availability = ChefAvailability(
          id: 'av-1',
          chefId: testChefId,
          date: testDate,
          startTime: '17:00',
          endTime: '23:00',
          isAvailable: true,
          createdAt: DateTime.now(),
        );

        when(mockScheduleService.getWorkingHoursForDay(testChefId, testDate))
            .thenAnswer((_) async => Right([workingHours]));
        
        when(mockScheduleService.getAvailabilityForDate(testChefId, testDate))
            .thenAnswer((_) async => Right([availability]));

        when(mockUnavailabilityHandler.filterAvailableSlots(
          any, any, testDate, 3,
        )).thenAnswer((_) async => Right([
          TimeSlot(
            startTime: DateTime(2024, 8, 15, 18, 0),
            endTime: DateTime(2024, 8, 15, 21, 0),
            isAvailable: true,
            chefId: testChefId,
          ),
          TimeSlot(
            startTime: DateTime(2024, 8, 15, 19, 0),
            endTime: DateTime(2024, 8, 15, 22, 0),
            isAvailable: true,
            chefId: testChefId,
          ),
        ]));

        // Act
        final result = await service.getAvailableTimeSlots(
          chefId: testChefId,
          date: testDate,
          durationHours: 3,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (slots) {
            expect(slots, hasLength(2));
            expect(slots.first.startTime.hour, 18);
            expect(slots.first.endTime.hour, 21);
            expect(slots.first.isAvailable, true);
          },
        );

        verify(mockScheduleService.getWorkingHoursForDay(testChefId, testDate)).called(1);
        verify(mockScheduleService.getAvailabilityForDate(testChefId, testDate)).called(1);
      });

      test('should return empty list when chef has no working hours', () async {
        // Arrange
        when(mockScheduleService.getWorkingHoursForDay(testChefId, testDate))
            .thenAnswer((_) async => const Right([]));

        // Act
        final result = await service.getAvailableTimeSlots(
          chefId: testChefId,
          date: testDate,
          durationHours: 3,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (slots) => expect(slots, isEmpty),
        );
      });

      test('should return failure when schedule service fails', () async {
        // Arrange
        when(mockScheduleService.getWorkingHoursForDay(testChefId, testDate))
            .thenAnswer((_) async => const Left(ServerFailure('Database error')));

        // Act
        final result = await service.getAvailableTimeSlots(
          chefId: testChefId,
          date: testDate,
          durationHours: 3,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (slots) => fail('Expected failure but got success'),
        );
      });

      test('should handle minimum duration constraint', () async {
        // Arrange
        when(mockScheduleService.getWorkingHoursForDay(testChefId, testDate))
            .thenAnswer((_) async => const Right([]));

        // Act
        final result = await service.getAvailableTimeSlots(
          chefId: testChefId,
          date: testDate,
          durationHours: 0, // Invalid duration
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (slots) => fail('Expected validation failure but got success'),
        );
      });
    });

    group('isChefAvailable', () {
      test('should return true when chef is available for the time slot', () async {
        // Arrange
        final startTime = DateTime(2024, 8, 15, 18, 0);
        final endTime = DateTime(2024, 8, 15, 21, 0);

        when(mockUnavailabilityHandler.isSlotAvailable(
          testChefId, startTime, endTime,
        )).thenAnswer((_) async => const Right(true));

        // Act
        final result = await service.isChefAvailable(
          chefId: testChefId,
          startTime: startTime,
          endTime: endTime,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (isAvailable) => expect(isAvailable, true),
        );
      });

      test('should return false when chef is not available', () async {
        // Arrange
        final startTime = DateTime(2024, 8, 15, 18, 0);
        final endTime = DateTime(2024, 8, 15, 21, 0);

        when(mockUnavailabilityHandler.isSlotAvailable(
          testChefId, startTime, endTime,
        )).thenAnswer((_) async => const Right(false));

        // Act
        final result = await service.isChefAvailable(
          chefId: testChefId,
          startTime: startTime,
          endTime: endTime,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (isAvailable) => expect(isAvailable, false),
        );
      });

      test('should validate time slot chronology', () async {
        // Arrange
        final startTime = DateTime(2024, 8, 15, 21, 0);
        final endTime = DateTime(2024, 8, 15, 18, 0); // End before start

        // Act
        final result = await service.isChefAvailable(
          chefId: testChefId,
          startTime: startTime,
          endTime: endTime,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (isAvailable) => fail('Expected validation failure but got success'),
        );
      });
    });

    group('getNextAvailableSlot', () {
      test('should return next available slot for chef', () async {
        // Arrange
        final fromTime = DateTime(2024, 8, 15, 16, 0);
        final expectedSlot = TimeSlot(
          startTime: DateTime(2024, 8, 15, 18, 0),
          endTime: DateTime(2024, 8, 15, 21, 0),
          isAvailable: true,
          chefId: testChefId,
        );

        when(mockUnavailabilityHandler.findNextAvailableSlot(
          testChefId, fromTime, 3,
        )).thenAnswer((_) async => Right(expectedSlot));

        // Act
        final result = await service.getNextAvailableSlot(
          chefId: testChefId,
          fromTime: fromTime,
          durationHours: 3,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (slot) {
            expect(slot.startTime.hour, 18);
            expect(slot.endTime.hour, 21);
            expect(slot.chefId, testChefId);
          },
        );
      });

      test('should return failure when no slots available', () async {
        // Arrange
        final fromTime = DateTime(2024, 8, 15, 16, 0);

        when(mockUnavailabilityHandler.findNextAvailableSlot(
          testChefId, fromTime, 3,
        )).thenAnswer((_) async => const Left(NotFoundFailure('No available slots')));

        // Act
        final result = await service.getNextAvailableSlot(
          chefId: testChefId,
          fromTime: fromTime,
          durationHours: 3,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<NotFoundFailure>()),
          (slot) => fail('Expected failure but got success'),
        );
      });
    });

    group('hasBookingConflict', () {
      test('should detect booking conflict', () async {
        // Arrange
        final startTime = DateTime(2024, 8, 15, 18, 0);
        final endTime = DateTime(2024, 8, 15, 21, 0);

        when(mockUnavailabilityHandler.hasConflictingBooking(
          testChefId, startTime, endTime,
        )).thenAnswer((_) async => const Right(true));

        // Act
        final result = await service.hasBookingConflict(
          chefId: testChefId,
          startTime: startTime,
          endTime: endTime,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (hasConflict) => expect(hasConflict, true),
        );
      });

      test('should return false when no conflict exists', () async {
        // Arrange
        final startTime = DateTime(2024, 8, 15, 18, 0);
        final endTime = DateTime(2024, 8, 15, 21, 0);

        when(mockUnavailabilityHandler.hasConflictingBooking(
          testChefId, startTime, endTime,
        )).thenAnswer((_) async => const Right(false));

        // Act
        final result = await service.hasBookingConflict(
          chefId: testChefId,
          startTime: startTime,
          endTime: endTime,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (hasConflict) => expect(hasConflict, false),
        );
      });
    });

    group('edge cases and error handling', () {
      test('should handle null chef id', () async {
        // Act
        final result = await service.getAvailableTimeSlots(
          chefId: '',
          date: testDate,
          durationHours: 3,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (slots) => fail('Expected validation failure but got success'),
        );
      });

      test('should handle past dates gracefully', () async {
        // Arrange
        final pastDate = DateTime(2020, 1, 1);

        // Act
        final result = await service.getAvailableTimeSlots(
          chefId: testChefId,
          date: pastDate,
          durationHours: 3,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (slots) => fail('Expected validation failure but got success'),
        );
      });

      test('should handle excessive duration requests', () async {
        // Act
        final result = await service.getAvailableTimeSlots(
          chefId: testChefId,
          date: testDate,
          durationHours: 25, // More than 24 hours
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (slots) => fail('Expected validation failure but got success'),
        );
      });
    });
  });
}