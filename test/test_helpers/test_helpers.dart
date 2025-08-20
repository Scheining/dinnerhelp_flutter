import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// Test utilities and helpers for DinnerHelp testing

/// Test helper class for setting up test environment
class TestHelpers {
  static late GetIt testGetIt;

  /// Initialize test environment with mock dependencies
  static Future<void> setupTestEnvironment() async {
    testGetIt = GetIt.instance;
    await testGetIt.reset();
    
    // Register mock dependencies
    await _registerMockCoreDependencies();
    await _registerMockServices();
    await _registerMockRepositories();
  }

  /// Clean up test environment
  static Future<void> tearDownTestEnvironment() async {
    await testGetIt.reset();
  }

  static Future<void> _registerMockCoreDependencies() async {
    // Mock Supabase client
    final mockSupabaseClient = MockSupabaseClient();
    testGetIt.registerSingleton<SupabaseClient>(mockSupabaseClient);

    // Mock HTTP client
    final mockHttpClient = MockHttpClient();
    testGetIt.registerSingleton<http.Client>(mockHttpClient);

    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    testGetIt.registerSingleton<SharedPreferences>(sharedPreferences);
  }

  static Future<void> _registerMockServices() async {
    // Register mock services as needed for tests
    // This will be expanded based on specific test requirements
  }

  static Future<void> _registerMockRepositories() async {
    // Register mock repositories as needed for tests
    // This will be expanded based on specific test requirements
  }
}

/// Custom widget tester for DinnerHelp app
class DinnerHelpWidgetTester {
  final WidgetTester tester;
  late ProviderContainer container;

  DinnerHelpWidgetTester(this.tester);

  /// Pump widget with provider scope and necessary dependencies
  Future<void> pumpWidget(
    Widget widget, {
    List<Override>? overrides,
    Locale? locale,
  }) async {
    container = ProviderContainer(
      overrides: overrides ?? [],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: locale ?? const Locale('en'),
          home: widget,
        ),
      ),
    );
  }

  /// Wait for animations and async operations to complete
  Future<void> pumpAndSettle([Duration duration = const Duration(milliseconds: 100)]) async {
    await tester.pumpAndSettle(duration);
  }

  /// Dispose the provider container
  void dispose() {
    container.dispose();
  }
}

/// Extension for easier widget testing
extension WidgetTesterExtension on WidgetTester {
  DinnerHelpWidgetTester get dinnerHelp => DinnerHelpWidgetTester(this);
}

/// Mock classes for testing
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockHttpClient extends Mock implements http.Client {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockSupabaseStorage extends Mock implements SupabaseStorageClient {}
class MockPostgrestClient extends Mock implements PostgrestClient {}

/// Test data factories
class TestDataFactory {
  static const String testChefId = 'test-chef-123';
  static const String testUserId = 'test-user-123';
  static const String testBookingId = 'test-booking-123';

  static DateTime get testDate => DateTime(2024, 8, 15, 18, 0);
  static DateTime get testStartTime => DateTime(2024, 8, 15, 18, 0);
  static DateTime get testEndTime => DateTime(2024, 8, 15, 21, 0);

  /// Create test booking request
  static Map<String, dynamic> createBookingRequest({
    String? chefId,
    String? userId,
    DateTime? date,
    String? startTime,
    String? endTime,
    int guests = 4,
  }) {
    return {
      'chef_id': chefId ?? testChefId,
      'user_id': userId ?? testUserId,
      'date': (date ?? testDate).toIso8601String().split('T')[0],
      'start_time': startTime ?? '18:00',
      'end_time': endTime ?? '21:00',
      'number_of_guests': guests,
      'status': 'pending',
    };
  }

  /// Create test chef data
  static Map<String, dynamic> createChefData({
    String? id,
    String? firstName,
    String? lastName,
    bool isActive = true,
    int pricePerHour = 400,
  }) {
    return {
      'id': id ?? testChefId,
      'first_name': firstName ?? 'Test',
      'last_name': lastName ?? 'Chef',
      'is_active': isActive,
      'price_per_hour': pricePerHour,
      'years_experience': 5,
      'certified_chef': true,
      'bio': 'Test chef bio',
      'cuisines': ['Danish', 'European'],
      'dietary_specialties': ['Vegetarian'],
    };
  }

  /// Create test booking data
  static Map<String, dynamic> createBookingData({
    String? id,
    String? chefId,
    String? userId,
    String status = 'pending',
  }) {
    return {
      'id': id ?? testBookingId,
      'chef_id': chefId ?? testChefId,
      'user_id': userId ?? testUserId,
      'date': testDate.toIso8601String().split('T')[0],
      'start_time': '18:00',
      'end_time': '21:00',
      'number_of_guests': 4,
      'status': status,
      'total_amount': 1200,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Create test chef availability data
  static Map<String, dynamic> createAvailabilityData({
    String? chefId,
    DateTime? date,
    String? startTime,
    String? endTime,
    bool isAvailable = true,
  }) {
    return {
      'chef_id': chefId ?? testChefId,
      'date': (date ?? testDate).toIso8601String().split('T')[0],
      'start_time': startTime ?? '18:00',
      'end_time': endTime ?? '23:00',
      'is_available': isAvailable,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  /// Create test chef working hours data
  static Map<String, dynamic> createWorkingHoursData({
    String? chefId,
    int dayOfWeek = 1, // Monday
    String startTime = '17:00',
    String endTime = '23:00',
  }) {
    return {
      'chef_id': chefId ?? testChefId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'is_available': true,
    };
  }

  /// Create test notification data
  static Map<String, dynamic> createNotificationData({
    String? id,
    String? userId,
    String title = 'Test Notification',
    String body = 'Test notification body',
    String type = 'booking',
  }) {
    return {
      'id': id ?? 'test-notification-123',
      'user_id': userId ?? testUserId,
      'title': title,
      'body': body,
      'type': type,
      'read': false,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  /// Create test payment intent data
  static Map<String, dynamic> createPaymentIntentData({
    String? id,
    String? bookingId,
    int amount = 1200,
    String currency = 'DKK',
    String status = 'requires_payment_method',
  }) {
    return {
      'id': id ?? 'pi_test_123',
      'booking_id': bookingId ?? testBookingId,
      'amount': amount,
      'currency': currency,
      'status': status,
      'client_secret': 'pi_test_123_secret_456',
      'created_at': DateTime.now().toIso8601String(),
    };
  }
}

/// Custom matchers for testing
class CustomMatchers {
  /// Matcher for checking if a date is today
  static Matcher isToday() => _IsToday();
  
  /// Matcher for checking if a time slot is valid
  static Matcher isValidTimeSlot() => _IsValidTimeSlot();
  
  /// Matcher for checking if a booking request is valid
  static Matcher isValidBookingRequest() => _IsValidBookingRequest();
}

class _IsToday extends Matcher {
  @override
  bool matches(Object? item, Map matchState) {
    if (item is DateTime) {
      final now = DateTime.now();
      return item.year == now.year &&
          item.month == now.month &&
          item.day == now.day;
    }
    return false;
  }

  @override
  Description describe(Description description) {
    return description.add('is today');
  }
}

class _IsValidTimeSlot extends Matcher {
  @override
  bool matches(Object? item, Map matchState) {
    if (item is Map<String, dynamic>) {
      return item.containsKey('start_time') &&
          item.containsKey('end_time') &&
          item['start_time'] is String &&
          item['end_time'] is String;
    }
    return false;
  }

  @override
  Description describe(Description description) {
    return description.add('is a valid time slot');
  }
}

class _IsValidBookingRequest extends Matcher {
  @override
  bool matches(Object? item, Map matchState) {
    if (item is Map<String, dynamic>) {
      final requiredFields = ['chef_id', 'user_id', 'date', 'start_time', 'end_time', 'number_of_guests'];
      return requiredFields.every((field) => item.containsKey(field));
    }
    return false;
  }

  @override
  Description describe(Description description) {
    return description.add('is a valid booking request');
  }
}