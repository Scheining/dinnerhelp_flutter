import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// Core services
import 'package:homechef/services/location_service.dart';

// Booking feature dependencies
import 'package:homechef/features/booking/data/repositories/booking_availability_repository_impl.dart';
import 'package:homechef/features/booking/data/repositories/chef_schedule_repository_impl.dart';
import 'package:homechef/features/booking/data/repositories/recurring_booking_repository_impl.dart';
import 'package:homechef/features/booking/domain/repositories/booking_availability_repository.dart';
import 'package:homechef/features/booking/domain/repositories/chef_schedule_repository.dart';
import 'package:homechef/features/booking/domain/repositories/recurring_booking_repository.dart';
import 'package:homechef/features/booking/domain/services/booking_availability_service.dart';
import 'package:homechef/features/booking/domain/services/chef_schedule_service.dart';
import 'package:homechef/features/booking/domain/services/recurring_booking_service.dart';
import 'package:homechef/features/booking/domain/services/chef_unavailability_handler.dart';
import 'package:homechef/features/booking/domain/services/chef_unavailability_handler_impl.dart';
import 'package:homechef/features/booking/domain/services/recurring_booking_conflict_resolver.dart';
import 'package:homechef/features/booking/domain/services/recurring_booking_conflict_resolver_impl.dart';
import 'package:homechef/features/booking/domain/services/booking_modification_service.dart';
import 'package:homechef/features/booking/domain/services/booking_modification_service_impl.dart';
import 'package:homechef/features/booking/domain/services/holiday_surcharge_calculator.dart';
import 'package:homechef/features/booking/domain/services/holiday_surcharge_calculator_impl.dart';
import 'package:homechef/features/booking/domain/usecases/get_available_time_slots.dart';
import 'package:homechef/features/booking/domain/usecases/check_booking_conflict.dart';
import 'package:homechef/features/booking/domain/usecases/get_chef_schedule_for_week.dart';
import 'package:homechef/features/booking/domain/usecases/validate_recurring_booking_pattern.dart';
import 'package:homechef/features/booking/domain/usecases/get_next_available_slot.dart';
import 'package:homechef/features/booking/domain/usecases/get_chef_schedule_settings.dart';

// Payment feature dependencies
import 'package:homechef/features/payment/data/repositories/payment_repository_impl.dart';
import 'package:homechef/features/payment/domain/repositories/payment_repository.dart';
import 'package:homechef/features/payment/domain/services/payment_service.dart';
import 'package:homechef/features/payment/domain/services/payment_service_impl.dart';
import 'package:homechef/features/payment/domain/services/dispute_resolution_service.dart';
import 'package:homechef/features/payment/domain/services/dispute_resolution_service_impl.dart';
import 'package:homechef/features/payment/domain/usecases/create_payment_intent.dart';
import 'package:homechef/features/payment/domain/usecases/authorize_payment.dart';
import 'package:homechef/features/payment/domain/usecases/capture_payment.dart';
import 'package:homechef/features/payment/domain/usecases/refund_payment.dart';
import 'package:homechef/features/payment/domain/usecases/calculate_payment_amount.dart';
import 'package:homechef/features/payment/domain/usecases/get_payment_status.dart';
import 'package:homechef/features/payment/domain/usecases/get_disputes.dart';

// Notifications feature dependencies
import 'package:homechef/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:homechef/features/notifications/data/services/notification_service_impl.dart' as data_impl;
import 'package:homechef/features/notifications/data/services/onesignal_service.dart';
import 'package:homechef/features/notifications/data/services/postmark_service.dart';
import 'package:homechef/features/notifications/data/services/notification_scheduler.dart';
import 'package:homechef/features/notifications/domain/repositories/notification_repository.dart';
import 'package:homechef/features/notifications/domain/services/notification_service.dart';
import 'package:homechef/features/notifications/domain/usecases/send_booking_confirmation.dart';
import 'package:homechef/features/notifications/domain/usecases/manage_notification_preferences.dart';

// Search feature dependencies
import 'package:homechef/features/search/data/repositories/chef_search_repository_impl.dart';
import 'package:homechef/features/search/domain/repositories/chef_search_repository.dart';
import 'package:homechef/features/search/domain/services/chef_search_service.dart';

// Data repositories
import 'package:homechef/data/repositories/chef_repository.dart';

final getIt = GetIt.instance;

/// Initialize all dependencies for the DinnerHelp application
/// This follows the Clean Architecture dependency rule:
/// - Presentation depends on Domain
/// - Domain depends on Data abstractions
/// - Data implements Domain abstractions
Future<void> initializeDependencies() async {
  // Core services - foundational dependencies
  await _registerCoreServices();
  
  // Feature services - business logic layer
  await _registerFeatureServices();
  
  // Repositories - data access layer
  await _registerRepositories();
  
  // Use cases - application business rules
  await _registerUseCases();
}

/// Register core application services
Future<void> _registerCoreServices() async {
  // Supabase client - singleton for database operations
  getIt.registerLazySingleton<SupabaseClient>(
    () => Supabase.instance.client,
  );

  // HTTP client - for external API calls
  getIt.registerLazySingleton<http.Client>(
    () => http.Client(),
  );

  // Shared preferences - for local storage
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Location service - for location-based features
  getIt.registerLazySingleton<LocationService>(
    () => LocationService(),
  );
}

/// Register feature-specific services
Future<void> _registerFeatureServices() async {
  // Register dependencies first
  getIt.registerLazySingleton<HolidaySurchargeCalculator>(
    () => HolidaySurchargeCalculatorImpl(
      supabaseClient: getIt<SupabaseClient>(),
    ),
  );

  getIt.registerLazySingleton<ChefScheduleService>(
    () => ChefScheduleService(
      getIt<ChefScheduleRepository>(),
    ),
  );
  
  getIt.registerLazySingleton<ChefUnavailabilityHandler>(
    () => ChefUnavailabilityHandlerImpl(
      supabaseClient: getIt<SupabaseClient>(),
      scheduleRepository: getIt<ChefScheduleRepository>(),
      availabilityRepository: getIt<BookingAvailabilityRepository>(),
      chefRepository: getIt<ChefRepository>(),
      searchService: getIt<ChefSearchService>(),
      notificationService: getIt<NotificationService>(),
      paymentService: getIt<PaymentService>(),
    ),
  );

  // Booking feature services
  getIt.registerLazySingleton<BookingAvailabilityService>(
    () => BookingAvailabilityService(
      getIt<BookingAvailabilityRepository>(),
      getIt<ChefScheduleRepository>(),
      getIt<ChefScheduleService>(),
    ),
  );

  // Register services that others depend on first
  
  getIt.registerLazySingleton<RecurringBookingService>(
    () => RecurringBookingService(
      getIt<RecurringBookingRepository>(),
      getIt<BookingAvailabilityRepository>(),
      getIt<BookingAvailabilityService>(),
    ),
  );

  getIt.registerLazySingleton<BookingModificationService>(
    () => BookingModificationServiceImpl(
      supabaseClient: getIt<SupabaseClient>(),
      scheduleRepository: getIt<ChefScheduleRepository>(),
      paymentService: getIt<PaymentService>(),
      notificationService: getIt<NotificationService>(),
    ),
  );

  // Payment feature services
  getIt.registerLazySingleton<PaymentService>(
    () => PaymentServiceImpl(
      paymentRepository: getIt<PaymentRepository>(),
    ),
  );

  getIt.registerLazySingleton<DisputeResolutionService>(
    () => DisputeResolutionServiceImpl(
      supabaseClient: getIt<SupabaseClient>(),
      paymentRepository: getIt<PaymentRepository>(),
      notificationService: getIt<NotificationService>(),
    ),
  );

  // Notification feature services
  getIt.registerLazySingleton<OneSignalService>(
    () => OneSignalService(
      appId: 'YOUR_ONESIGNAL_APP_ID', // TODO: Load from environment
      apiKey: 'YOUR_ONESIGNAL_API_KEY', // TODO: Load from environment
    ),
  );

  getIt.registerLazySingleton<PostmarkService>(
    () => PostmarkService(
      apiToken: 'YOUR_POSTMARK_API_TOKEN', // TODO: Load from environment
      defaultFromEmail: 'noreply@dinnerhelp.dk', // TODO: Load from environment
      defaultFromName: 'DinnerHelp', // TODO: Load from environment
      httpClient: getIt<http.Client>(),
    ),
  );

  // Register NotificationRepository before NotificationScheduler to avoid circular dependency
  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      getIt<SupabaseClient>(),
    ),
  );

  getIt.registerLazySingleton<NotificationScheduler>(
    () => NotificationSchedulerImpl(
      repository: getIt<NotificationRepository>(),
      emailService: getIt<PostmarkService>(),
      pushService: getIt<OneSignalService>(),
    ),
  );

  getIt.registerLazySingleton<NotificationService>(
    () => data_impl.NotificationServiceImpl(
      repository: getIt<NotificationRepository>(),
      emailService: getIt<PostmarkService>(),
      pushService: getIt<OneSignalService>(),
    ),
  );

  // Search feature services
  getIt.registerLazySingleton<ChefSearchService>(
    () => ChefSearchService(
      getIt<ChefSearchRepository>(),
      getIt<BookingAvailabilityService>(),
    ),
  );
}

/// Register repository implementations
Future<void> _registerRepositories() async {
  // Booking repositories
  getIt.registerLazySingleton<BookingAvailabilityRepository>(
    () => BookingAvailabilityRepositoryImpl(
      supabaseClient: getIt<SupabaseClient>(),
    ),
  );

  getIt.registerLazySingleton<ChefScheduleRepository>(
    () => ChefScheduleRepositoryImpl(
      supabaseClient: getIt<SupabaseClient>(),
    ),
  );

  getIt.registerLazySingleton<RecurringBookingRepository>(
    () => RecurringBookingRepositoryImpl(
      supabaseClient: getIt<SupabaseClient>(),
    ),
  );

  // Payment repositories
  getIt.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(
      supabaseClient: getIt<SupabaseClient>(),
    ),
  );

  // Notification repository is registered in _registerServices() to avoid circular dependency

  // Core data repositories
  getIt.registerLazySingleton<ChefRepository>(
    () => ChefRepository(
      supabaseClient: getIt<SupabaseClient>(),
    ),
  );

  // Search repositories
  getIt.registerLazySingleton<ChefSearchRepository>(
    () => ChefSearchRepositoryImpl(
      getIt<ChefRepository>(),
      getIt<SharedPreferences>(),
    ),
  );
}

/// Register use cases - application business rules
Future<void> _registerUseCases() async {
  // Booking use cases
  getIt.registerLazySingleton<GetAvailableTimeSlots>(
    () => GetAvailableTimeSlots(
      getIt<BookingAvailabilityRepository>(),
    ),
  );

  getIt.registerLazySingleton<CheckBookingConflict>(
    () => CheckBookingConflict(
      getIt<BookingAvailabilityRepository>(),
    ),
  );

  getIt.registerLazySingleton<GetChefScheduleForWeek>(
    () => GetChefScheduleForWeek(
      getIt<BookingAvailabilityRepository>(),
    ),
  );

  getIt.registerLazySingleton<ValidateRecurringBookingPattern>(
    () => ValidateRecurringBookingPattern(
      getIt<RecurringBookingRepository>(),
    ),
  );

  getIt.registerLazySingleton<GetNextAvailableSlot>(
    () => GetNextAvailableSlot(
      getIt<BookingAvailabilityRepository>(),
    ),
  );

  getIt.registerLazySingleton<GetChefScheduleSettings>(
    () => GetChefScheduleSettings(
      getIt<ChefScheduleRepository>(),
    ),
  );

  // Payment use cases
  getIt.registerLazySingleton<CreatePaymentIntent>(
    () => CreatePaymentIntent(
      getIt<PaymentService>(),
    ),
  );

  getIt.registerLazySingleton<AuthorizePayment>(
    () => AuthorizePayment(
      getIt<PaymentService>(),
    ),
  );

  getIt.registerLazySingleton<CapturePayment>(
    () => CapturePayment(
      getIt<PaymentService>(),
    ),
  );

  getIt.registerLazySingleton<RefundPayment>(
    () => RefundPayment(
      getIt<PaymentService>(),
    ),
  );

  getIt.registerLazySingleton<CalculatePaymentAmount>(
    () => CalculatePaymentAmount(
      getIt<PaymentService>(),
    ),
  );

  getIt.registerLazySingleton<GetPaymentStatus>(
    () => GetPaymentStatus(
      getIt<PaymentService>(),
    ),
  );

  getIt.registerLazySingleton<GetDisputes>(
    () => GetDisputes(
      getIt<PaymentService>(),
    ),
  );

  // Notification use cases
  getIt.registerLazySingleton<SendBookingConfirmation>(
    () => SendBookingConfirmation(
      getIt<NotificationService>(),
    ),
  );

  // Register notification preference use cases
  getIt.registerLazySingleton<GetNotificationPreferences>(
    () => GetNotificationPreferences(
      getIt<NotificationRepository>(),
    ),
  );

  getIt.registerLazySingleton<UpdateNotificationPreferences>(
    () => UpdateNotificationPreferences(
      getIt<NotificationRepository>(),
    ),
  );
}

/// Clean up all registered dependencies
/// Call this when the app is being disposed
Future<void> disposeDependencies() async {
  await getIt.reset();
}