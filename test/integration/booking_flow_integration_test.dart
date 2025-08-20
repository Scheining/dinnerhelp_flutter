import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';

import 'package:homechef/main.dart' as app;
import 'package:homechef/features/booking/domain/entities/time_slot.dart';
import 'package:homechef/features/booking/domain/entities/dish.dart';
import 'package:homechef/features/booking/domain/entities/selected_dish.dart';
import 'package:homechef/features/booking/domain/entities/booking_request.dart';
import 'package:homechef/features/payment/domain/entities/payment_intent.dart';
import 'package:homechef/models/chef.dart';

import '../test_helpers/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Complete Booking Flow Integration Tests', () {
    setUp(() async {
      await TestHelpers.setupTestEnvironment();
    });

    tearDown(() async {
      await TestHelpers.tearDownTestEnvironment();
    });

    testWidgets('complete booking flow from chef search to payment', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Step 1: Navigate to search screen
      await tester.tap(find.byIcon(Icons.search_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Find Your Perfect Chef'), findsOneWidget);

      // Step 2: Enter search criteria
      await tester.enterText(find.byType(TextField).first, 'Copenhagen');
      await tester.tap(find.byKey(const Key('guest_count_selector')));
      await tester.pumpAndSettle();
      
      // Select 4 guests
      await tester.tap(find.text('4').last);
      await tester.pumpAndSettle();

      // Select date (tomorrow)
      await tester.tap(find.byKey(const Key('date_selector')));
      await tester.pumpAndSettle();
      
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      await tester.tap(find.text(tomorrow.day.toString()).first);
      await tester.pumpAndSettle();

      // Step 3: Perform search
      await tester.tap(find.byKey(const Key('search_button')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should navigate to search results
      expect(find.text('Available Chefs'), findsOneWidget);
      expect(find.byType(Card), findsWidgets); // Chef cards

      // Step 4: Select a chef
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      // Should navigate to chef profile
      expect(find.text('Book Chef'), findsOneWidget);

      // Step 5: Book the chef
      await tester.tap(find.text('Book Chef'));
      await tester.pumpAndSettle();

      // Should navigate to booking date/time selection
      expect(find.text('Select Date and Time'), findsOneWidget);

      // Step 6: Select date and time
      // Date should already be selected from search
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Select first available time slot
      final timeSlotButtons = find.textContaining(' - ');
      if (timeSlotButtons.evaluate().isNotEmpty) {
        await tester.tap(timeSlotButtons.first);
        await tester.pumpAndSettle();
      }

      // Confirm selection
      await tester.tap(find.byKey(const Key('confirm_datetime_button')));
      await tester.pumpAndSettle();

      // Step 7: Dish selection
      expect(find.text('Select Dishes'), findsOneWidget);

      // Select some dishes
      final dishCards = find.byType(Card);
      if (dishCards.evaluate().length >= 2) {
        await tester.tap(dishCards.first);
        await tester.pumpAndSettle();
        
        await tester.tap(dishCards.at(1));
        await tester.pumpAndSettle();
      }

      // Add a custom dish request
      await tester.tap(find.byKey(const Key('add_custom_dish_button')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('custom_dish_name')),
        'Special Danish Dessert',
      );
      await tester.enterText(
        find.byKey(const Key('custom_dish_description')),
        'A traditional Danish dessert with seasonal ingredients',
      );

      await tester.tap(find.byKey(const Key('add_custom_dish_confirm')));
      await tester.pumpAndSettle();

      // Proceed to summary
      await tester.tap(find.byKey(const Key('proceed_to_summary_button')));
      await tester.pumpAndSettle();

      // Step 8: Booking summary
      expect(find.text('Booking Summary'), findsOneWidget);
      expect(find.text('Special Danish Dessert'), findsOneWidget);

      // Verify pricing information
      expect(find.textContaining('DKK'), findsWidgets);
      expect(find.text('Total Amount'), findsOneWidget);

      // Add special requests
      await tester.tap(find.byKey(const Key('special_requests_field')));
      await tester.enterText(
        find.byKey(const Key('special_requests_field')),
        'Please prepare dishes suitable for vegetarians',
      );

      // Confirm booking details
      await tester.tap(find.byKey(const Key('confirm_booking_button')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Step 9: Payment processing
      expect(find.text('Payment'), findsOneWidget);

      // Should show payment amount
      expect(find.textContaining('DKK'), findsWidgets);

      // Mock successful payment processing
      // In a real integration test, this would interact with actual payment UI
      await tester.tap(find.byKey(const Key('process_payment_button')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Step 10: Booking confirmation
      expect(find.text('Booking Confirmed!'), findsOneWidget);
      expect(find.textContaining('Booking ID:'), findsOneWidget);

      // Navigate to bookings to verify
      await tester.tap(find.text('View Bookings'));
      await tester.pumpAndSettle();

      // Should be on bookings screen with new booking
      expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);
      expect(find.text('Upcoming'), findsOneWidget);
    });

    testWidgets('booking flow handles chef unavailability gracefully', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to search
      await tester.tap(find.byIcon(Icons.search_outlined));
      await tester.pumpAndSettle();

      // Search for chefs
      await tester.enterText(find.byType(TextField).first, 'Copenhagen');
      await tester.tap(find.byKey(const Key('search_button')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Select a chef
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      // Try to book
      await tester.tap(find.text('Book Chef'));
      await tester.pumpAndSettle();

      // If no time slots available, should show appropriate message
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      if (find.text('No available slots').evaluate().isNotEmpty) {
        expect(find.text('No available slots'), findsOneWidget);
        
        // Should offer alternative suggestions
        expect(find.text('Suggest Alternative Times'), findsOneWidget);
        
        await tester.tap(find.text('Suggest Alternative Times'));
        await tester.pumpAndSettle();
        
        // Should show chef unavailable dialog with alternatives
        expect(find.byKey(const Key('chef_unavailable_dialog')), findsOneWidget);
        expect(find.text('Alternative Time Slots'), findsOneWidget);
      }
    });

    testWidgets('booking flow handles payment failures', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate through booking flow up to payment
      await _navigateToPaymentScreen(tester);

      // Simulate payment failure
      await tester.tap(find.byKey(const Key('simulate_payment_failure')));
      await tester.tap(find.byKey(const Key('process_payment_button')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should show payment failure message
      expect(find.text('Payment Failed'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
      expect(find.text('Use Different Payment Method'), findsOneWidget);

      // Try again with different payment method
      await tester.tap(find.text('Use Different Payment Method'));
      await tester.pumpAndSettle();

      expect(find.text('Select Payment Method'), findsOneWidget);
    });

    testWidgets('booking flow supports recurring bookings', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate through initial booking flow
      await _navigateToDateTimeSelection(tester);

      // Enable recurring booking
      await tester.tap(find.byKey(const Key('recurring_booking_toggle')));
      await tester.pumpAndSettle();

      // Select recurring pattern
      await tester.tap(find.byKey(const Key('recurring_pattern_selector')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Weekly'));
      await tester.pumpAndSettle();

      // Set end date for recurring series
      await tester.tap(find.byKey(const Key('recurring_end_date')));
      await tester.pumpAndSettle();

      final futureDate = DateTime.now().add(const Duration(days: 30));
      await tester.tap(find.text(futureDate.day.toString()).last);
      await tester.pumpAndSettle();

      // Continue with booking
      await tester.tap(find.byKey(const Key('confirm_recurring_button')));
      await tester.pumpAndSettle();

      // Should proceed to dish selection with recurring info
      expect(find.text('Recurring Booking'), findsOneWidget);
      expect(find.text('Weekly'), findsOneWidget);
    });

    testWidgets('booking modification flow works correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to existing booking
      await tester.tap(find.byIcon(Icons.calendar_today_outlined));
      await tester.pumpAndSettle();

      // Tap on existing booking
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      // Should show booking details
      expect(find.text('Booking Details'), findsOneWidget);

      // Request modification
      await tester.tap(find.byKey(const Key('modify_booking_button')));
      await tester.pumpAndSettle();

      // Should show modification options
      expect(find.text('Modify Booking'), findsOneWidget);
      expect(find.text('Change Date/Time'), findsOneWidget);
      expect(find.text('Change Dishes'), findsOneWidget);
      expect(find.text('Change Guest Count'), findsOneWidget);

      // Modify guest count
      await tester.tap(find.text('Change Guest Count'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('guest_increment')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('confirm_modification')));
      await tester.pumpAndSettle();

      // Should show modification confirmation
      expect(find.text('Modification Requested'), findsOneWidget);
      expect(find.text('Chef will be notified'), findsOneWidget);
    });
  });

  // Helper methods for complex navigation flows
  Future<void> _navigateToPaymentScreen(WidgetTester tester) async {
    // Navigate through search -> chef selection -> date/time -> dishes -> summary -> payment
    await tester.tap(find.byIcon(Icons.search_outlined));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Copenhagen');
    await tester.tap(find.byKey(const Key('search_button')));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await tester.tap(find.byType(Card).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Book Chef'));
    await tester.pumpAndSettle();

    // Select date/time
    final timeSlotButtons = find.textContaining(' - ');
    if (timeSlotButtons.evaluate().isNotEmpty) {
      await tester.tap(timeSlotButtons.first);
      await tester.pumpAndSettle();
    }

    await tester.tap(find.byKey(const Key('confirm_datetime_button')));
    await tester.pumpAndSettle();

    // Select dishes
    final dishCards = find.byType(Card);
    if (dishCards.evaluate().isNotEmpty) {
      await tester.tap(dishCards.first);
      await tester.pumpAndSettle();
    }

    await tester.tap(find.byKey(const Key('proceed_to_summary_button')));
    await tester.pumpAndSettle();

    // Confirm booking
    await tester.tap(find.byKey(const Key('confirm_booking_button')));
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  Future<void> _navigateToDateTimeSelection(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.search_outlined));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Copenhagen');
    await tester.tap(find.byKey(const Key('search_button')));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await tester.tap(find.byType(Card).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Book Chef'));
    await tester.pumpAndSettle();
  }
}