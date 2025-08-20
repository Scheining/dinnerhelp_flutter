// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_booking_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recurringBookingRepositoryHash() =>
    r'385d9c91c0e8b5eb68a3a77227924abab42db648';

/// See also [recurringBookingRepository].
@ProviderFor(recurringBookingRepository)
final recurringBookingRepositoryProvider =
    AutoDisposeProvider<RecurringBookingRepositoryImpl>.internal(
  recurringBookingRepository,
  name: r'recurringBookingRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recurringBookingRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecurringBookingRepositoryRef
    = AutoDisposeProviderRef<RecurringBookingRepositoryImpl>;
String _$recurringBookingServiceHash() =>
    r'171ac3ba7de1c887b85ad5b126a0f390ec713ad8';

/// See also [recurringBookingService].
@ProviderFor(recurringBookingService)
final recurringBookingServiceProvider =
    AutoDisposeProvider<RecurringBookingService>.internal(
  recurringBookingService,
  name: r'recurringBookingServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recurringBookingServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecurringBookingServiceRef
    = AutoDisposeProviderRef<RecurringBookingService>;
String _$recurringPatternValidatorHash() =>
    r'639d0f6026cb3648f2d6a7fa2ee4a909575e4d96';

/// See also [RecurringPatternValidator].
@ProviderFor(RecurringPatternValidator)
final recurringPatternValidatorProvider =
    AutoDisposeAsyncNotifierProvider<RecurringPatternValidator, bool>.internal(
  RecurringPatternValidator.new,
  name: r'recurringPatternValidatorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recurringPatternValidatorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RecurringPatternValidator = AutoDisposeAsyncNotifier<bool>;
String _$recurringBookingCreatorHash() =>
    r'3089c7a02a1772e88f93d170dc2df7e00109167b';

/// See also [RecurringBookingCreator].
@ProviderFor(RecurringBookingCreator)
final recurringBookingCreatorProvider = AutoDisposeAsyncNotifierProvider<
    RecurringBookingCreator, List<String>>.internal(
  RecurringBookingCreator.new,
  name: r'recurringBookingCreatorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recurringBookingCreatorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RecurringBookingCreator = AutoDisposeAsyncNotifier<List<String>>;
String _$recurringBookingManagerHash() =>
    r'edd7ad07d9e7bd7fcd81662f607ec517000b41be';

/// See also [RecurringBookingManager].
@ProviderFor(RecurringBookingManager)
final recurringBookingManagerProvider =
    AutoDisposeAsyncNotifierProvider<RecurringBookingManager, bool>.internal(
  RecurringBookingManager.new,
  name: r'recurringBookingManagerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recurringBookingManagerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RecurringBookingManager = AutoDisposeAsyncNotifier<bool>;
String _$recurringBookingCalculatorHash() =>
    r'1bfa5025666b2f7b73ddf316d7b9d2e1b0d60d01';

/// See also [RecurringBookingCalculator].
@ProviderFor(RecurringBookingCalculator)
final recurringBookingCalculatorProvider = AutoDisposeNotifierProvider<
    RecurringBookingCalculator, RecurringBookingCalculation>.internal(
  RecurringBookingCalculator.new,
  name: r'recurringBookingCalculatorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recurringBookingCalculatorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RecurringBookingCalculator
    = AutoDisposeNotifier<RecurringBookingCalculation>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
