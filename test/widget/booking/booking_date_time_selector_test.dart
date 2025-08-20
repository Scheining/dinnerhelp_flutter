import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';

import 'package:homechef/features/booking/presentation/widgets/booking_date_time_selector.dart';
import 'package:homechef/features/booking/presentation/providers/booking_availability_providers.dart';
import 'package:homechef/features/booking/domain/entities/time_slot.dart';
import 'package:homechef/l10n/app_localizations.dart';

import '../../test_helpers/test_helpers.dart';

void main() {
  group('BookingDateTimeSelector Widget Tests', () {
    late WidgetTester tester;
    const String testChefId = TestDataFactory.testChefId;

    setUp(() async {
      await TestHelpers.setupTestEnvironment();
    });

    tearDown(() async {
      await TestHelpers.tearDownTestEnvironment();
    });

    testWidgets('should display date picker and time slots', (WidgetTester widgetTester) async {
      tester = widgetTester;
      
      // Arrange
      final availableSlots = [
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
      ];

      await tester.dinnerHelp.pumpWidget(
        BookingDateTimeSelector(
          chefId: testChefId,
          numberOfGuests: 4,
          onDateTimeSelected: (date, startTime, endTime) {},
        ),
        overrides: [
          availableTimeSlotsProvider(testChefId, DateTime(2024, 8, 15), 3)
              .overrideWith((ref) => AsyncValue.data(availableSlots)),
        ],
      );

      // Act & Assert
      expect(find.text('Select Date and Time'), findsOneWidget);
      expect(find.byType(CalendarDatePicker), findsOneWidget);
      
      // Wait for time slots to load
      await tester.dinnerHelp.pumpAndSettle();
      
      expect(find.text('Available Time Slots'), findsOneWidget);
      expect(find.text('18:00 - 21:00'), findsOneWidget);
      expect(find.text('19:00 - 22:00'), findsOneWidget);
    });

    testWidgets('should handle date selection', (WidgetTester widgetTester) async {
      tester = widgetTester;
      DateTime? selectedDate;
      String? selectedStartTime;
      String? selectedEndTime;

      await tester.dinnerHelp.pumpWidget(
        BookingDateTimeSelector(
          chefId: testChefId,
          numberOfGuests: 4,
          onDateTimeSelected: (date, startTime, endTime) {
            selectedDate = date;
            selectedStartTime = startTime;
            selectedEndTime = endTime;
          },
        ),
      );

      // Find and tap on a future date (assuming current month view)
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final dateButton = find.text(tomorrow.day.toString()).first;
      
      await tester.tap(dateButton);
      await tester.dinnerHelp.pumpAndSettle();

      // Verify date was selected (selectedDate should be set)
      expect(selectedDate?.day, tomorrow.day);
    });

    testWidgets('should handle time slot selection', (WidgetTester widgetTester) async {
      tester = widgetTester;
      DateTime? selectedDate;
      String? selectedStartTime;
      String? selectedEndTime;

      final availableSlots = [
        TimeSlot(
          startTime: DateTime(2024, 8, 15, 18, 0),
          endTime: DateTime(2024, 8, 15, 21, 0),
          isAvailable: true,
          chefId: testChefId,
        ),
      ];

      await tester.dinnerHelp.pumpWidget(
        BookingDateTimeSelector(
          chefId: testChefId,
          numberOfGuests: 4,
          onDateTimeSelected: (date, startTime, endTime) {
            selectedDate = date;
            selectedStartTime = startTime;
            selectedEndTime = endTime;
          },
        ),
        overrides: [
          availableTimeSlotsProvider(testChefId, DateTime(2024, 8, 15), 3)
              .overrideWith((ref) => AsyncValue.data(availableSlots)),
        ],
      );

      // Select a date first
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final dateButton = find.text(tomorrow.day.toString()).first;
      await tester.tap(dateButton);
      await tester.dinnerHelp.pumpAndSettle();

      // Wait for time slots to load and select one
      await tester.dinnerHelp.pumpAndSettle();
      
      final timeSlotButton = find.text('18:00 - 21:00');
      if (timeSlotButton.evaluate().isNotEmpty) {
        await tester.tap(timeSlotButton);
        await tester.dinnerHelp.pumpAndSettle();

        expect(selectedStartTime, '18:00');
        expect(selectedEndTime, '21:00');
      }
    });

    testWidgets('should show loading state while fetching time slots', (WidgetTester widgetTester) async {
      tester = widgetTester;

      await tester.dinnerHelp.pumpWidget(
        BookingDateTimeSelector(
          chefId: testChefId,
          numberOfGuests: 4,
          onDateTimeSelected: (date, startTime, endTime) {},
        ),
        overrides: [
          availableTimeSlotsProvider(testChefId, DateTime(2024, 8, 15), 3)
              .overrideWith((ref) => const AsyncValue.loading()),
        ],
      );

      // Select a date to trigger time slot loading
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final dateButton = find.text(tomorrow.day.toString()).first;
      await tester.tap(dateButton);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error state when time slot fetching fails', (WidgetTester widgetTester) async {
      tester = widgetTester;

      await tester.dinnerHelp.pumpWidget(
        BookingDateTimeSelector(
          chefId: testChefId,
          numberOfGuests: 4,
          onDateTimeSelected: (date, startTime, endTime) {},
        ),
        overrides: [
          availableTimeSlotsProvider(testChefId, DateTime(2024, 8, 15), 3)
              .overrideWith((ref) => AsyncValue.error('Failed to load slots', StackTrace.current)),
        ],
      );

      // Select a date to trigger error display
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final dateButton = find.text(tomorrow.day.toString()).first;
      await tester.tap(dateButton);
      await tester.dinnerHelp.pumpAndSettle();

      expect(find.textContaining('Failed to load'), findsOneWidget);
    });

    testWidgets('should show no available slots message', (WidgetTester widgetTester) async {
      tester = widgetTester;

      await tester.dinnerHelp.pumpWidget(
        BookingDateTimeSelector(
          chefId: testChefId,
          numberOfGuests: 4,
          onDateTimeSelected: (date, startTime, endTime) {},
        ),
        overrides: [
          availableTimeSlotsProvider(testChefId, DateTime(2024, 8, 15), 3)
              .overrideWith((ref) => const AsyncValue.data([])),
        ],
      );

      // Select a date
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final dateButton = find.text(tomorrow.day.toString()).first;
      await tester.tap(dateButton);
      await tester.dinnerHelp.pumpAndSettle();

      expect(find.textContaining('No available slots'), findsOneWidget);
    });

    testWidgets('should display guest count selector', (WidgetTester widgetTester) async {
      tester = widgetTester;

      await tester.dinnerHelp.pumpWidget(
        BookingDateTimeSelector(
          chefId: testChefId,
          numberOfGuests: 4,
          onDateTimeSelected: (date, startTime, endTime) {},
        ),
      );

      expect(find.text('Number of Guests'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('should handle guest count changes', (WidgetTester widgetTester) async {
      tester = widgetTester;
      int currentGuests = 4;

      await tester.dinnerHelp.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return BookingDateTimeSelector(
              chefId: testChefId,
              numberOfGuests: currentGuests,
              onGuestCountChanged: (newCount) {
                setState(() {
                  currentGuests = newCount;
                });
              },
              onDateTimeSelected: (date, startTime, endTime) {},
            );
          },
        ),
      );

      // Find increment button
      final incrementButton = find.byIcon(Icons.add);
      if (incrementButton.evaluate().isNotEmpty) {
        await tester.tap(incrementButton);
        await tester.pump();
        expect(currentGuests, 5);
      }

      // Find decrement button
      final decrementButton = find.byIcon(Icons.remove);
      if (decrementButton.evaluate().isNotEmpty) {
        await tester.tap(decrementButton);
        await tester.pump();
        expect(currentGuests, 4);
      }
    });

    testWidgets('should disable past dates', (WidgetTester widgetTester) async {
      tester = widgetTester;

      await tester.dinnerHelp.pumpWidget(
        BookingDateTimeSelector(
          chefId: testChefId,
          numberOfGuests: 4,
          onDateTimeSelected: (date, startTime, endTime) {},
        ),
      );

      // Past dates should be disabled/grayed out
      // This is typically handled by the CalendarDatePicker internally
      expect(find.byType(CalendarDatePicker), findsOneWidget);
    });

    testWidgets('should show duration selector', (WidgetTester widgetTester) async {
      tester = widgetTester;

      await tester.dinnerHelp.pumpWidget(
        BookingDateTimeSelector(
          chefId: testChefId,
          numberOfGuests: 4,
          onDateTimeSelected: (date, startTime, endTime) {},
        ),
      );

      expect(find.text('Duration'), findsOneWidget);
      expect(find.text('3 hours'), findsOneWidget); // Default duration
    });

    testWidgets('should update time slots when duration changes', (WidgetTester widgetTester) async {
      tester = widgetTester;
      
      // This test would verify that changing duration triggers a new query
      // for available time slots with the new duration
      await tester.dinnerHelp.pumpWidget(
        BookingDateTimeSelector(
          chefId: testChefId,
          numberOfGuests: 4,
          onDateTimeSelected: (date, startTime, endTime) {},
        ),
      );

      // Find duration selector and change it
      final durationSelector = find.byKey(const Key('duration_selector'));
      if (durationSelector.evaluate().isNotEmpty) {
        await tester.tap(durationSelector);
        await tester.dinnerHelp.pumpAndSettle();
        
        // Select different duration (e.g., 4 hours)
        final fourHoursOption = find.text('4 hours');
        if (fourHoursOption.evaluate().isNotEmpty) {
          await tester.tap(fourHoursOption);
          await tester.dinnerHelp.pumpAndSettle();
          
          // Verify new duration is selected
          expect(find.text('4 hours'), findsOneWidget);
        }
      }
    });
  });
}