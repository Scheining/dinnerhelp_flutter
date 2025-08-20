// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_availability_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bookingAvailabilityRepositoryHash() =>
    r'11c964828789bb78266d6dc79c01eb955ec0072c';

/// See also [bookingAvailabilityRepository].
@ProviderFor(bookingAvailabilityRepository)
final bookingAvailabilityRepositoryProvider =
    AutoDisposeProvider<BookingAvailabilityRepository>.internal(
  bookingAvailabilityRepository,
  name: r'bookingAvailabilityRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bookingAvailabilityRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BookingAvailabilityRepositoryRef
    = AutoDisposeProviderRef<BookingAvailabilityRepository>;
String _$chefScheduleRepositoryHash() =>
    r'1b7e8d7719c28417a0cdbf11d7cd74b265d535b3';

/// See also [chefScheduleRepository].
@ProviderFor(chefScheduleRepository)
final chefScheduleRepositoryProvider =
    AutoDisposeProvider<ChefScheduleRepository>.internal(
  chefScheduleRepository,
  name: r'chefScheduleRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$chefScheduleRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ChefScheduleRepositoryRef
    = AutoDisposeProviderRef<ChefScheduleRepository>;
String _$chefScheduleServiceHash() =>
    r'2d22e7fa1f63fdf04e5bc3a47c15914faadacfb6';

/// See also [chefScheduleService].
@ProviderFor(chefScheduleService)
final chefScheduleServiceProvider =
    AutoDisposeProvider<ChefScheduleService>.internal(
  chefScheduleService,
  name: r'chefScheduleServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$chefScheduleServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ChefScheduleServiceRef = AutoDisposeProviderRef<ChefScheduleService>;
String _$bookingAvailabilityServiceHash() =>
    r'f14a4082ef50cd8a6c8d8a395a4de53327d958f1';

/// See also [bookingAvailabilityService].
@ProviderFor(bookingAvailabilityService)
final bookingAvailabilityServiceProvider =
    AutoDisposeProvider<BookingAvailabilityService>.internal(
  bookingAvailabilityService,
  name: r'bookingAvailabilityServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bookingAvailabilityServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BookingAvailabilityServiceRef
    = AutoDisposeProviderRef<BookingAvailabilityService>;
String _$availableTimeSlotsHash() =>
    r'9c85be16353892a4fc00732d887fc9a35848ea6e';

/// See also [AvailableTimeSlots].
@ProviderFor(AvailableTimeSlots)
final availableTimeSlotsProvider = AutoDisposeAsyncNotifierProvider<
    AvailableTimeSlots, List<TimeSlot>>.internal(
  AvailableTimeSlots.new,
  name: r'availableTimeSlotsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$availableTimeSlotsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AvailableTimeSlots = AutoDisposeAsyncNotifier<List<TimeSlot>>;
String _$bookingConflictCheckerHash() =>
    r'4948bbd6e40cf6f64fad34d96204daa26da13e78';

/// See also [BookingConflictChecker].
@ProviderFor(BookingConflictChecker)
final bookingConflictCheckerProvider =
    AutoDisposeAsyncNotifierProvider<BookingConflictChecker, bool>.internal(
  BookingConflictChecker.new,
  name: r'bookingConflictCheckerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bookingConflictCheckerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BookingConflictChecker = AutoDisposeAsyncNotifier<bool>;
String _$chefWeeklyScheduleHash() =>
    r'b662ac87a706acc5a8f3b3044456f6063209dd85';

/// See also [ChefWeeklySchedule].
@ProviderFor(ChefWeeklySchedule)
final chefWeeklyScheduleProvider = AutoDisposeAsyncNotifierProvider<
    ChefWeeklySchedule, List<TimeSlot>>.internal(
  ChefWeeklySchedule.new,
  name: r'chefWeeklyScheduleProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$chefWeeklyScheduleHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ChefWeeklySchedule = AutoDisposeAsyncNotifier<List<TimeSlot>>;
String _$nextAvailableSlotHash() => r'4ba05db926a2a63eca843f9ac0bfe63eaaa561f9';

/// See also [NextAvailableSlot].
@ProviderFor(NextAvailableSlot)
final nextAvailableSlotProvider =
    AutoDisposeAsyncNotifierProvider<NextAvailableSlot, TimeSlot?>.internal(
  NextAvailableSlot.new,
  name: r'nextAvailableSlotProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$nextAvailableSlotHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NextAvailableSlot = AutoDisposeAsyncNotifier<TimeSlot?>;
String _$bookingValidatorHash() => r'dabe6823821adf48674e9c6388889c8b3bfc7210';

/// See also [BookingValidator].
@ProviderFor(BookingValidator)
final bookingValidatorProvider =
    AutoDisposeAsyncNotifierProvider<BookingValidator, bool>.internal(
  BookingValidator.new,
  name: r'bookingValidatorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bookingValidatorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BookingValidator = AutoDisposeAsyncNotifier<bool>;
String _$bookingSelectionHash() => r'10997ccb8112bd838bef7aa3ad8d93fe472d63ca';

/// See also [BookingSelection].
@ProviderFor(BookingSelection)
final bookingSelectionProvider = AutoDisposeNotifierProvider<BookingSelection,
    BookingSelectionState>.internal(
  BookingSelection.new,
  name: r'bookingSelectionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bookingSelectionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BookingSelection = AutoDisposeNotifier<BookingSelectionState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
