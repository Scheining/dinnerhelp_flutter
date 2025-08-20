import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:homechef/core/error/failures.dart';
import 'package:homechef/features/booking/domain/entities/recurrence_pattern.dart';
import 'package:homechef/features/booking/domain/entities/booking_request.dart';
import 'package:homechef/features/booking/domain/repositories/recurring_booking_repository.dart';
import 'package:homechef/features/booking/domain/repositories/booking_availability_repository.dart';
import 'package:homechef/features/booking/domain/services/booking_availability_service.dart';
import 'package:homechef/features/booking/domain/services/recurring_booking_service.dart';

import 'recurring_booking_service_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<RecurringBookingRepository>(),
  MockSpec<BookingAvailabilityRepository>(),
  MockSpec<BookingAvailabilityService>(),
])
void main() {
  late RecurringBookingService recurringBookingService;
  late MockRecurringBookingRepository mockRecurringRepository;
  late MockBookingAvailabilityRepository mockAvailabilityRepository;
  late MockBookingAvailabilityService mockAvailabilityService;

  setUp(() {
    mockRecurringRepository = MockRecurringBookingRepository();
    mockAvailabilityRepository = MockBookingAvailabilityRepository();
    mockAvailabilityService = MockBookingAvailabilityService();
    recurringBookingService = RecurringBookingService(
      mockRecurringRepository,
      mockAvailabilityRepository,
      mockAvailabilityService,
    );
  });

  group('RecurringBookingService', () {
    const String testChefId = 'chef-123';
    const String testUserId = 'user-456';
    final DateTime testStartDate = DateTime(2024, 12, 25);

    group('generateOccurrences', () {
      test('should generate weekly occurrences correctly', () async {
        // Arrange
        final pattern = RecurrencePattern(
          type: RecurrenceType.weekly,
          startDate: testStartDate,
          maxOccurrences: 4,
        );

        // Act
        final result = await recurringBookingService.generateOccurrences(
          pattern: pattern,
          startDate: testStartDate,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected success'),
          (occurrences) {
            expect(occurrences.length, 4);
            expect(occurrences[0], testStartDate);
            expect(occurrences[1], testStartDate.add(const Duration(days: 7)));
            expect(occurrences[2], testStartDate.add(const Duration(days: 14)));
            expect(occurrences[3], testStartDate.add(const Duration(days: 21)));
          },
        );
      });

      test('should generate bi-weekly occurrences correctly', () async {
        // Arrange
        final pattern = RecurrencePattern(
          type: RecurrenceType.biWeekly,
          startDate: testStartDate,
          maxOccurrences: 3,
        );

        // Act
        final result = await recurringBookingService.generateOccurrences(
          pattern: pattern,
          startDate: testStartDate,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected success'),
          (occurrences) {
            expect(occurrences.length, 3);
            expect(occurrences[0], testStartDate);
            expect(occurrences[1], testStartDate.add(const Duration(days: 14)));
            expect(occurrences[2], testStartDate.add(const Duration(days: 28)));
          },
        );
      });

      test('should generate monthly occurrences correctly', () async {
        // Arrange
        final pattern = RecurrencePattern(
          type: RecurrenceType.monthly,
          startDate: testStartDate,
          maxOccurrences: 3,
        );

        // Act
        final result = await recurringBookingService.generateOccurrences(
          pattern: pattern,
          startDate: testStartDate,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected success'),
          (occurrences) {
            expect(occurrences.length, 3);
            expect(occurrences[0], testStartDate);
            expect(occurrences[1], DateTime(2025, 1, 25)); // Next month
            expect(occurrences[2], DateTime(2025, 2, 25)); // Two months later
          },
        );
      });

      test('should return ValidationFailure for past start date', () async {
        // Arrange
        final pastDate = DateTime.now().subtract(const Duration(days: 2));
        final pattern = RecurrencePattern(
          type: RecurrenceType.weekly,
          startDate: pastDate,
        );

        // Act
        final result = await recurringBookingService.generateOccurrences(
          pattern: pattern,
          startDate: pastDate,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Expected failure'),
        );
      });

      test('should return BookingTooFarInAdvanceFailure for dates too far ahead', () async {
        // Arrange
        final farFutureDate = DateTime.now().add(const Duration(days: 365));
        final pattern = RecurrencePattern(
          type: RecurrenceType.weekly,
          startDate: testStartDate,
        );

        // Act
        final result = await recurringBookingService.generateOccurrences(
          pattern: pattern,
          startDate: testStartDate,
          endDate: farFutureDate,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<BookingTooFarInAdvanceFailure>()),
          (_) => fail('Expected failure'),
        );
      });

      test('should return InvalidRecurrencePatternFailure for too many occurrences', () async {
        // Arrange
        final pattern = RecurrencePattern(
          type: RecurrenceType.weekly,
          startDate: testStartDate,
          maxOccurrences: 150, // Too many
        );

        // Act
        final result = await recurringBookingService.generateOccurrences(
          pattern: pattern,
          startDate: testStartDate,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<InvalidRecurrencePatternFailure>()),
          (_) => fail('Expected failure'),
        );
      });
    });

    group('checkRecurringConflicts', () {
      test('should return empty list when no conflicts exist', () async {
        // Arrange
        final occurrences = [
          testStartDate,
          testStartDate.add(const Duration(days: 7)),
        ];

        when(mockAvailabilityService.checkBookingConflict(
          chefId: testChefId,
          date: any,
          startTime: '10:00',
          endTime: '13:00',
        )).thenAnswer((_) async => const Right(false));

        when(mockAvailabilityRepository.isChefAvailable(
          chefId: testChefId,
          startTime: any,
          endTime: any,
        )).thenAnswer((_) async => const Right(true));

        // Act
        final result = await recurringBookingService.checkRecurringConflicts(
          chefId: testChefId,
          occurrences: occurrences,
          startTime: '10:00',
          endTime: '13:00',
        );

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected success'),
          (conflicts) => expect(conflicts, isEmpty),
        );
      });

      test('should return conflicts when booking conflicts exist', () async {
        // Arrange
        final occurrences = [
          testStartDate,
          testStartDate.add(const Duration(days: 7)),
        ];

        when(mockAvailabilityService.checkBookingConflict(
          chefId: testChefId,
          date: testStartDate,
          startTime: '10:00',
          endTime: '13:00',
        )).thenAnswer((_) async => const Right(true)); // Conflict on first date

        when(mockAvailabilityService.checkBookingConflict(
          chefId: testChefId,
          date: testStartDate.add(const Duration(days: 7)),
          startTime: '10:00',
          endTime: '13:00',
        )).thenAnswer((_) async => const Right(false)); // No conflict on second date

        // Act
        final result = await recurringBookingService.checkRecurringConflicts(
          chefId: testChefId,
          occurrences: occurrences,
          startTime: '10:00',
          endTime: '13:00',
        );

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected success'),
          (conflicts) {
            expect(conflicts.length, 1);
            expect(conflicts.contains(testStartDate), true);
          },
        );
      });

      test('should return ValidationFailure for invalid time format', () async {
        // Arrange
        final occurrences = [testStartDate];

        // Act
        final result = await recurringBookingService.checkRecurringConflicts(
          chefId: testChefId,
          occurrences: occurrences,
          startTime: '25:00', // Invalid
          endTime: '13:00',
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Expected failure'),
        );
      });

      test('should return ValidationFailure for empty chef ID', () async {
        // Arrange
        final occurrences = [testStartDate];

        // Act
        final result = await recurringBookingService.checkRecurringConflicts(
          chefId: '', // Empty
          occurrences: occurrences,
          startTime: '10:00',
          endTime: '13:00',
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Expected failure'),
        );
      });
    });

    group('createRecurringSeries', () {
      test('should create recurring series successfully', () async {
        // Arrange
        final pattern = RecurrencePattern(
          type: RecurrenceType.weekly,
          startDate: testStartDate,
          maxOccurrences: 4,
        );

        final bookingRequest = BookingRequest(
          userId: testUserId,
          chefId: testChefId,
          date: testStartDate,
          startTime: '10:00',
          endTime: '13:00',
          numberOfGuests: 4,
          recurrencePattern: pattern,
        );

        const expectedSeriesId = 'series-123';

        when(mockAvailabilityService.validateRecurringBookingPattern(
          chefId: testChefId,
          pattern: pattern,
          startTime: '10:00',
          endTime: '13:00',
        )).thenAnswer((_) async => const Right(true));

        when(mockRecurringRepository.createRecurringSeries(
          bookingRequest: bookingRequest,
          pattern: pattern,
        )).thenAnswer((_) async => const Right(expectedSeriesId));

        // Act
        final result = await recurringBookingService.createRecurringSeries(
          bookingRequest: bookingRequest,
          pattern: pattern,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected success'),
          (seriesId) => expect(seriesId, expectedSeriesId),
        );
      });

      test('should return ValidationFailure for non-recurring booking request', () async {
        // Arrange
        final pattern = RecurrencePattern(
          type: RecurrenceType.weekly,
          startDate: testStartDate,
          maxOccurrences: 4,
        );

        final bookingRequest = BookingRequest(
          userId: testUserId,
          chefId: testChefId,
          date: testStartDate,
          startTime: '10:00',
          endTime: '13:00',
          numberOfGuests: 4,
          // No recurrence pattern - not recurring
        );

        // Act
        final result = await recurringBookingService.createRecurringSeries(
          bookingRequest: bookingRequest,
          pattern: pattern,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Expected failure'),
        );
      });

      test('should return failure when pattern validation fails', () async {
        // Arrange
        final pattern = RecurrencePattern(
          type: RecurrenceType.weekly,
          startDate: testStartDate,
          maxOccurrences: 4,
        );

        final bookingRequest = BookingRequest(
          userId: testUserId,
          chefId: testChefId,
          date: testStartDate,
          startTime: '10:00',
          endTime: '13:00',
          numberOfGuests: 4,
          recurrencePattern: pattern,
        );

        when(mockAvailabilityService.validateRecurringBookingPattern(
          chefId: testChefId,
          pattern: pattern,
          startTime: '10:00',
          endTime: '13:00',
        )).thenAnswer((_) async => const Right(false)); // Validation failed

        // Act
        final result = await recurringBookingService.createRecurringSeries(
          bookingRequest: bookingRequest,
          pattern: pattern,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<InvalidRecurrencePatternFailure>()),
          (_) => fail('Expected failure'),
        );
      });
    });

    group('cancelRecurringBooking', () {
      test('should cancel recurring booking successfully', () async {
        // Arrange
        const seriesId = 'series-123';
        const cancellationType = CancellationType.entireSeries;

        when(mockRecurringRepository.cancelRecurringSeries(
          seriesId: seriesId,
          cancellationType: cancellationType,
        )).thenAnswer((_) async => const Right(null));

        // Act
        final result = await recurringBookingService.cancelRecurringBooking(
          seriesId: seriesId,
          cancellationType: cancellationType,
        );

        // Assert
        expect(result.isRight(), true);
        verify(mockRecurringRepository.cancelRecurringSeries(
          seriesId: seriesId,
          cancellationType: cancellationType,
        )).called(1);
      });

      test('should return ValidationFailure for empty series ID', () async {
        // Act
        final result = await recurringBookingService.cancelRecurringBooking(
          seriesId: '', // Empty
          cancellationType: CancellationType.entireSeries,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Expected failure'),
        );
      });
    });

    group('modifyRecurringBooking', () {
      test('should modify recurring booking successfully', () async {
        // Arrange
        const seriesId = 'series-123';
        const modification = RecurringSeriesModification(
          startTime: '11:00',
          numberOfGuests: 6,
        );

        when(mockRecurringRepository.modifyRecurringSeries(
          seriesId: seriesId,
          modifications: modification,
        )).thenAnswer((_) async => const Right(null));

        // Act
        final result = await recurringBookingService.modifyRecurringBooking(
          seriesId: seriesId,
          modifications: modification,
        );

        // Assert
        expect(result.isRight(), true);
        verify(mockRecurringRepository.modifyRecurringSeries(
          seriesId: seriesId,
          modifications: modification,
        )).called(1);
      });

      test('should return ValidationFailure for invalid start time', () async {
        // Arrange
        const seriesId = 'series-123';
        const modification = RecurringSeriesModification(
          startTime: '25:00', // Invalid
        );

        // Act
        final result = await recurringBookingService.modifyRecurringBooking(
          seriesId: seriesId,
          modifications: modification,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Expected failure'),
        );
      });

      test('should return ValidationFailure for invalid number of guests', () async {
        // Arrange
        const seriesId = 'series-123';
        const modification = RecurringSeriesModification(
          numberOfGuests: 0, // Invalid
        );

        // Act
        final result = await recurringBookingService.modifyRecurringBooking(
          seriesId: seriesId,
          modifications: modification,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Expected failure'),
        );
      });

      test('should return BookingTooFarInAdvanceFailure for end date too far ahead', () async {
        // Arrange
        const seriesId = 'series-123';
        final farFutureDate = DateTime.now().add(const Duration(days: 365));
        final modification = RecurringSeriesModification(
          newEndDate: farFutureDate,
        );

        // Act
        final result = await recurringBookingService.modifyRecurringBooking(
          seriesId: seriesId,
          modifications: modification,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<BookingTooFarInAdvanceFailure>()),
          (_) => fail('Expected failure'),
        );
      });
    });

    group('validateRecurringPattern', () {
      test('should return true for valid pattern with no conflicts', () async {
        // Arrange
        final pattern = RecurrencePattern(
          type: RecurrenceType.weekly,
          startDate: testStartDate,
          maxOccurrences: 4,
        );

        when(mockAvailabilityService.checkBookingConflict(
          chefId: testChefId,
          date: any,
          startTime: '10:00',
          endTime: '13:00',
        )).thenAnswer((_) async => const Right(false));

        when(mockAvailabilityRepository.isChefAvailable(
          chefId: testChefId,
          startTime: any,
          endTime: any,
        )).thenAnswer((_) async => const Right(true));

        // Act
        final result = await recurringBookingService.validateRecurringPattern(
          chefId: testChefId,
          pattern: pattern,
          startTime: '10:00',
          endTime: '13:00',
        );

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected success'),
          (isValid) => expect(isValid, true),
        );
      });

      test('should return BookingConflictFailure when conflicts exist', () async {
        // Arrange
        final pattern = RecurrencePattern(
          type: RecurrenceType.weekly,
          startDate: testStartDate,
          maxOccurrences: 2,
        );

        when(mockAvailabilityService.checkBookingConflict(
          chefId: testChefId,
          date: testStartDate,
          startTime: '10:00',
          endTime: '13:00',
        )).thenAnswer((_) async => const Right(true)); // Conflict

        // Act
        final result = await recurringBookingService.validateRecurringPattern(
          chefId: testChefId,
          pattern: pattern,
          startTime: '10:00',
          endTime: '13:00',
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<BookingConflictFailure>()),
          (_) => fail('Expected failure'),
        );
      });

      test('should return ValidationFailure for empty chef ID', () async {
        // Arrange
        final pattern = RecurrencePattern(
          type: RecurrenceType.weekly,
          startDate: testStartDate,
          maxOccurrences: 4,
        );

        // Act
        final result = await recurringBookingService.validateRecurringPattern(
          chefId: '', // Empty
          pattern: pattern,
          startTime: '10:00',
          endTime: '13:00',
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Expected failure'),
        );
      });
    });

    group('getUserRecurringSeries', () {
      test('should return user recurring series', () async {
        // Arrange
        final expectedSeries = <RecurringBookingSeries>[];

        when(mockRecurringRepository.getUserRecurringSeries(
          userId: testUserId,
          activeOnly: true,
        )).thenAnswer((_) async => Right(expectedSeries));

        // Act
        final result = await recurringBookingService.getUserRecurringSeries(
          userId: testUserId,
          activeOnly: true,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected success'),
          (series) => expect(series, expectedSeries),
        );
      });

      test('should return ValidationFailure for empty user ID', () async {
        // Act
        final result = await recurringBookingService.getUserRecurringSeries(
          userId: '', // Empty
        );

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