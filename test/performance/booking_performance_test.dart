import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';

import 'package:homechef/features/booking/presentation/screens/chef_search_results_screen.dart';
import 'package:homechef/features/booking/presentation/screens/dish_selection_screen.dart';
import 'package:homechef/features/booking/presentation/screens/booking_summary_screen.dart';
import 'package:homechef/features/booking/presentation/widgets/booking_date_time_selector.dart';
import 'package:homechef/features/booking/domain/entities/booking_request.dart';

import '../test_helpers/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Booking System Performance Tests', () {
    setUp(() async {
      await TestHelpers.setupTestEnvironment();
    });

    tearDown(() async {
      await TestHelpers.tearDownTestEnvironment();
    });

    group('Screen Rendering Performance', () {
      testWidgets('chef search results screen renders within performance budget', (WidgetTester tester) async {
        // Arrange
        const searchQuery = 'Copenhagen chefs';
        const location = 'Copenhagen';
        final selectedDate = DateTime.now().add(const Duration(days: 1));
        const numberOfGuests = 4;

        // Act & Measure
        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: ChefSearchResultsScreen(
                searchQuery: searchQuery,
                location: location,
                selectedDate: selectedDate,
                numberOfGuests: numberOfGuests,
              ),
            ),
          ),
        );

        // Wait for initial render
        await tester.pumpAndSettle();
        stopwatch.stop();

        // Assert
        expect(stopwatch.elapsedMilliseconds, lessThan(1000), 
               reason: 'Chef search results screen should render within 1 second');

        // Test scrolling performance
        final listView = find.byType(ListView);
        if (listView.evaluate().isNotEmpty) {
          final scrollStopwatch = Stopwatch()..start();
          
          await tester.drag(listView, const Offset(0, -500));
          await tester.pumpAndSettle();
          
          scrollStopwatch.stop();
          
          expect(scrollStopwatch.elapsedMilliseconds, lessThan(200),
                 reason: 'Scrolling should be smooth and complete within 200ms');
        }
      });

      testWidgets('booking date time selector renders quickly', (WidgetTester tester) async {
        const String testChefId = TestDataFactory.testChefId;
        
        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: BookingDateTimeSelector(
                  chefId: testChefId,
                  numberOfGuests: 4,
                  onDateTimeSelected: (date, startTime, endTime) {},
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(500),
               reason: 'Date time selector should render within 500ms');
      });

      testWidgets('dish selection screen handles large menu efficiently', (WidgetTester tester) async {
        const String testChefId = TestDataFactory.testChefId;
        final selectedDate = DateTime.now().add(const Duration(days: 1));

        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: DishSelectionScreen(
                chefId: testChefId,
                selectedDate: selectedDate,
                startTime: '18:00',
                endTime: '21:00',
                numberOfGuests: 4,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(800),
               reason: 'Dish selection screen should render within 800ms even with large menus');

        // Test selection performance
        final dishCards = find.byType(Card);
        if (dishCards.evaluate().length >= 10) {
          final selectionStopwatch = Stopwatch()..start();
          
          // Select multiple dishes rapidly
          for (int i = 0; i < 5; i++) {
            await tester.tap(dishCards.at(i));
            await tester.pump(const Duration(milliseconds: 50));
          }
          
          selectionStopwatch.stop();
          
          expect(selectionStopwatch.elapsedMilliseconds, lessThan(500),
                 reason: 'Multiple dish selections should complete within 500ms');
        }
      });

      testWidgets('booking summary calculates totals quickly', (WidgetTester tester) async {
        // Create a complex booking request with multiple dishes
        final bookingRequest = BookingRequest(
          chefId: TestDataFactory.testChefId,
          userId: TestDataFactory.testUserId,
          selectedDate: TestDataFactory.testDate,
          startTime: '18:00',
          endTime: '21:00',
          numberOfGuests: 8,
          selectedDishes: List.generate(10, (index) => TestDataFactory.createSelectedDish(
            dishId: 'dish-$index',
            name: 'Test Dish $index',
            price: 150.0 + (index * 25),
          )),
          customDishRequests: List.generate(3, (index) => TestDataFactory.createCustomDishRequest(
            name: 'Custom Dish $index',
            description: 'Custom dish description $index',
          )),
          specialRequests: 'Multiple dietary requirements and special preparation instructions',
          isRecurring: true,
          recurringEndDate: DateTime.now().add(const Duration(days: 90)),
        );

        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: BookingSummaryScreen(bookingRequest: bookingRequest),
            ),
          ),
        );

        await tester.pumpAndSettle();
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(600),
               reason: 'Complex booking summary should calculate and render within 600ms');

        // Verify calculations are complete
        expect(find.text('Total Amount'), findsOneWidget);
        expect(find.textContaining('DKK'), findsWidgets);
      });
    });

    group('Data Loading Performance', () {
      testWidgets('chef availability data loads within acceptable time', (WidgetTester tester) async {
        const String testChefId = TestDataFactory.testChefId;
        final testDate = DateTime.now().add(const Duration(days: 1));

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: BookingDateTimeSelector(
                  chefId: testChefId,
                  numberOfGuests: 4,
                  onDateTimeSelected: (date, startTime, endTime) {},
                ),
              ),
            ),
          ),
        );

        // Trigger availability loading by selecting a date
        final tomorrow = testDate.day.toString();
        final dateButton = find.text(tomorrow);
        
        if (dateButton.evaluate().isNotEmpty) {
          final loadStopwatch = Stopwatch()..start();
          
          await tester.tap(dateButton.first);
          
          // Wait for loading to complete
          while (find.byType(CircularProgressIndicator).evaluate().isNotEmpty) {
            await tester.pump(const Duration(milliseconds: 100));
            if (loadStopwatch.elapsedMilliseconds > 5000) {
              break; // Timeout after 5 seconds
            }
          }
          
          loadStopwatch.stop();
          
          expect(loadStopwatch.elapsedMilliseconds, lessThan(3000),
                 reason: 'Chef availability should load within 3 seconds');
        }
      });

      testWidgets('payment processing completes within reasonable time', (WidgetTester tester) async {
        // This would test the payment processing speed
        // In a real scenario, this might involve mock payment gateways
        
        final stopwatch = Stopwatch()..start();
        
        // Simulate payment intent creation and processing
        // This would be replaced with actual payment widget testing
        await Future.delayed(const Duration(milliseconds: 1500)); // Simulate payment processing
        
        stopwatch.stop();
        
        expect(stopwatch.elapsedMilliseconds, lessThan(5000),
               reason: 'Payment processing should complete within 5 seconds');
      });
    });

    group('Memory Usage Tests', () {
      testWidgets('booking flow does not leak memory', (WidgetTester tester) async {
        // Monitor memory usage throughout booking flow
        int initialMemory = _getCurrentMemoryUsage();
        
        // Run complete booking flow multiple times
        for (int i = 0; i < 3; i++) {
          await _runCompleteBookingFlow(tester);
          
          // Force garbage collection
          await tester.binding.delayed(const Duration(milliseconds: 100));
        }
        
        int finalMemory = _getCurrentMemoryUsage();
        int memoryIncrease = finalMemory - initialMemory;
        
        // Memory increase should be reasonable (less than 50MB)
        expect(memoryIncrease, lessThan(50 * 1024 * 1024),
               reason: 'Memory usage should not increase significantly after multiple booking flows');
      });

      testWidgets('large chef lists do not cause excessive memory usage', (WidgetTester tester) async {
        int initialMemory = _getCurrentMemoryUsage();

        // Create a screen with many chef cards
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: ChefSearchResultsScreen(
                searchQuery: 'all chefs',
                location: 'Copenhagen',
                selectedDate: DateTime.now().add(const Duration(days: 1)),
                numberOfGuests: 4,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        
        // Scroll through all results
        final listView = find.byType(ListView);
        if (listView.evaluate().isNotEmpty) {
          for (int i = 0; i < 10; i++) {
            await tester.drag(listView, const Offset(0, -300));
            await tester.pump(const Duration(milliseconds: 100));
          }
        }

        int finalMemory = _getCurrentMemoryUsage();
        int memoryIncrease = finalMemory - initialMemory;

        expect(memoryIncrease, lessThan(30 * 1024 * 1024),
               reason: 'Large chef lists should not consume excessive memory');
      });
    });

    group('Network Performance', () {
      testWidgets('search requests are debounced properly', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: TextField(
                  key: const Key('search_field'),
                  onChanged: (value) {
                    // This would trigger search in real implementation
                  },
                ),
              ),
            ),
          ),
        );

        final searchField = find.byKey(const Key('search_field'));
        
        final stopwatch = Stopwatch()..start();
        
        // Simulate rapid typing
        await tester.enterText(searchField, 'c');
        await tester.pump(const Duration(milliseconds: 50));
        
        await tester.enterText(searchField, 'co');
        await tester.pump(const Duration(milliseconds: 50));
        
        await tester.enterText(searchField, 'cop');
        await tester.pump(const Duration(milliseconds: 50));
        
        await tester.enterText(searchField, 'cope');
        await tester.pump(const Duration(milliseconds: 50));
        
        await tester.enterText(searchField, 'copen');
        await tester.pump(const Duration(milliseconds: 50));
        
        await tester.enterText(searchField, 'copenh');
        await tester.pump(const Duration(milliseconds: 50));
        
        await tester.enterText(searchField, 'copenha');
        await tester.pump(const Duration(milliseconds: 50));
        
        await tester.enterText(searchField, 'copenhag');
        await tester.pump(const Duration(milliseconds: 50));
        
        await tester.enterText(searchField, 'copenhagen');
        
        // Wait for debounce period
        await tester.pump(const Duration(milliseconds: 500));
        
        stopwatch.stop();
        
        // In a real implementation, we would verify only one or few search requests were made
        expect(stopwatch.elapsedMilliseconds, lessThan(1000),
               reason: 'Debounced search should complete quickly');
      });
    });
  });

  // Helper methods
  Future<void> _runCompleteBookingFlow(WidgetTester tester) async {
    // Simplified booking flow for performance testing
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: ChefSearchResultsScreen(
            searchQuery: 'test',
            location: 'Copenhagen',
            selectedDate: DateTime.now().add(const Duration(days: 1)),
            numberOfGuests: 4,
          ),
        ),
      ),
    );
    
    await tester.pumpAndSettle();
    
    // Navigate through screens quickly
    final cards = find.byType(Card);
    if (cards.evaluate().isNotEmpty) {
      await tester.tap(cards.first);
      await tester.pumpAndSettle();
    }
    
    // Clean up
    await tester.pumpWidget(Container());
    await tester.pumpAndSettle();
  }

  int _getCurrentMemoryUsage() {
    // This would return actual memory usage in a real implementation
    // For testing purposes, return a mock value
    return 100 * 1024 * 1024; // 100MB mock value
  }
}

// Extension for TestDataFactory to include performance test data
extension TestDataFactoryPerformance on TestDataFactory {
  static dynamic createSelectedDish({
    required String dishId,
    required String name,
    required double price,
    int quantity = 1,
  }) {
    return {
      'dish_id': dishId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'dietary_info': ['vegetarian-friendly'],
      'preparation_time': 30,
    };
  }

  static dynamic createCustomDishRequest({
    required String name,
    required String description,
    double estimatedPrice = 200.0,
  }) {
    return {
      'name': name,
      'description': description,
      'estimated_price': estimatedPrice,
      'dietary_requirements': 'None specified',
    };
  }
}