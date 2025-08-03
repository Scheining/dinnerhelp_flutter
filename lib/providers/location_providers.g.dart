// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$hasLocationPermissionHash() =>
    r'67ee9e0e71623bbdc74bef9be395158eb8639039';

/// See also [hasLocationPermission].
@ProviderFor(hasLocationPermission)
final hasLocationPermissionProvider = AutoDisposeProvider<bool>.internal(
  hasLocationPermission,
  name: r'hasLocationPermissionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasLocationPermissionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HasLocationPermissionRef = AutoDisposeProviderRef<bool>;
String _$isLocationServiceEnabledHash() =>
    r'85c286b89dbe9ff7b03f537de4b52abbfbc5d784';

/// See also [isLocationServiceEnabled].
@ProviderFor(isLocationServiceEnabled)
final isLocationServiceEnabledProvider = AutoDisposeProvider<bool>.internal(
  isLocationServiceEnabled,
  name: r'isLocationServiceEnabledProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isLocationServiceEnabledHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsLocationServiceEnabledRef = AutoDisposeProviderRef<bool>;
String _$canAccessLocationHash() => r'cdd68ad152394d58b5e81d6f32bdea161cd659af';

/// See also [canAccessLocation].
@ProviderFor(canAccessLocation)
final canAccessLocationProvider = AutoDisposeProvider<bool>.internal(
  canAccessLocation,
  name: r'canAccessLocationProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$canAccessLocationHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CanAccessLocationRef = AutoDisposeProviderRef<bool>;
String _$currentLocationAddressHash() =>
    r'04f5e8015f101f6727fdc53040e01981b4e21691';

/// See also [currentLocationAddress].
@ProviderFor(currentLocationAddress)
final currentLocationAddressProvider = AutoDisposeProvider<String?>.internal(
  currentLocationAddress,
  name: r'currentLocationAddressProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentLocationAddressHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentLocationAddressRef = AutoDisposeProviderRef<String?>;
String _$currentPositionHash() => r'e75665bddfb00d275540741ddb4a843eb8e4f0fe';

/// See also [currentPosition].
@ProviderFor(currentPosition)
final currentPositionProvider = AutoDisposeProvider<Position?>.internal(
  currentPosition,
  name: r'currentPositionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentPositionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentPositionRef = AutoDisposeProviderRef<Position?>;
String _$locationNotifierHash() => r'1589241da0e9cf667226b62eba3b32c974a230a9';

/// See also [LocationNotifier].
@ProviderFor(LocationNotifier)
final locationNotifierProvider = AutoDisposeNotifierProvider<LocationNotifier,
    AsyncValue<LocationData?>>.internal(
  LocationNotifier.new,
  name: r'locationNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$locationNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LocationNotifier = AutoDisposeNotifier<AsyncValue<LocationData?>>;
String _$locationPermissionStatusHash() =>
    r'b9d5546e8e26e4013a7fa1cb21fe819515f4f8c7';

/// See also [LocationPermissionStatus].
@ProviderFor(LocationPermissionStatus)
final locationPermissionStatusProvider = AutoDisposeAsyncNotifierProvider<
    LocationPermissionStatus, LocationPermission>.internal(
  LocationPermissionStatus.new,
  name: r'locationPermissionStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$locationPermissionStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LocationPermissionStatus
    = AutoDisposeAsyncNotifier<LocationPermission>;
String _$locationServiceStatusHash() =>
    r'a8854de590125666e03620adf418db0c5ea1d9ff';

/// See also [LocationServiceStatus].
@ProviderFor(LocationServiceStatus)
final locationServiceStatusProvider =
    AutoDisposeAsyncNotifierProvider<LocationServiceStatus, bool>.internal(
  LocationServiceStatus.new,
  name: r'locationServiceStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$locationServiceStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LocationServiceStatus = AutoDisposeAsyncNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
