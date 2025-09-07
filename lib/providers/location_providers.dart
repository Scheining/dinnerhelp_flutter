import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/location_data.dart';
import '../services/location_service.dart';
import '../exceptions/location_exceptions.dart';

part 'location_providers.g.dart';

@riverpod
class LocationNotifier extends _$LocationNotifier {
  @override
  AsyncValue<LocationData?> build() {
    // Try to get last known location on initialization
    _tryGetLastKnownLocation();
    return const AsyncValue.data(null);
  }

  /// Get current location with full permission handling
  Future<void> getCurrentLocation() async {
    state = const AsyncValue.loading();
    
    try {
      final locationData = await LocationService.getCurrentLocationData();
      state = AsyncValue.data(locationData);
    } on DinnerHelpLocationServiceDisabledException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } on DinnerHelpLocationPermissionDeniedException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } on DinnerHelpLocationPermissionDeniedForeverException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } on DinnerHelpLocationTimeoutException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } catch (e) {
      state = AsyncValue.error(
        LocationException('Failed to get location: ${e.toString()}'),
        StackTrace.current,
      );
    }
  }

  /// Request location permission and get location
  Future<void> requestLocationPermission() async {
    try {
      await LocationService.handleLocationPermission();
      await getCurrentLocation();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Refresh current location
  Future<void> refreshLocation() async {
    await getCurrentLocation();
  }

  /// Clear location data
  void clearLocation() {
    state = const AsyncValue.data(null);
  }

  /// Set location manually with an address
  Future<void> setManualLocation(String address) async {
    state = const AsyncValue.loading();
    
    try {
      // For now, we'll just set the address without coordinates
      // In the future, this could use a geocoding service
      final locationData = LocationData(
        position: Position(
          latitude: 55.6761, // Default to Copenhagen coordinates
          longitude: 12.5683,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        ),
        address: address,
        timestamp: DateTime.now(),
      );
      
      state = AsyncValue.data(locationData);
    } catch (e) {
      state = AsyncValue.error(
        LocationException('Failed to set location: ${e.toString()}'),
        StackTrace.current,
      );
    }
  }

  /// Try to get last known location without triggering loading state
  Future<void> _tryGetLastKnownLocation() async {
    try {
      final lastPosition = await LocationService.getLastKnownPosition();
      if (lastPosition != null) {
        final address = await LocationService.getAddressFromPosition(lastPosition);
        final locationData = LocationData(
          position: lastPosition,
          address: address,
          timestamp: DateTime.now(),
        );
        // Only update if we don't have current location data
        if (state.value == null) {
          state = AsyncValue.data(locationData);
        }
      }
    } catch (e) {
      // Silently ignore errors for last known location
    }
  }
}

@riverpod
class LocationPermissionStatus extends _$LocationPermissionStatus {
  @override
  Future<LocationPermission> build() async {
    return await Geolocator.checkPermission();
  }

  /// Check current permission status
  Future<void> checkPermission() async {
    state = const AsyncValue.loading();
    try {
      final permission = await Geolocator.checkPermission();
      state = AsyncValue.data(permission);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Request location permission
  Future<LocationPermission> requestPermission() async {
    try {
      final permission = await Geolocator.requestPermission();
      state = AsyncValue.data(permission);
      return permission;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
}

@riverpod
class LocationServiceStatus extends _$LocationServiceStatus {
  @override
  Future<bool> build() async {
    return await LocationService.isLocationServiceEnabled();
  }

  /// Check if location services are enabled
  Future<void> checkServiceStatus() async {
    state = const AsyncValue.loading();
    try {
      final isEnabled = await LocationService.isLocationServiceEnabled();
      state = AsyncValue.data(isEnabled);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// Computed providers for common location queries

@riverpod
bool hasLocationPermission(HasLocationPermissionRef ref) {
  final permissionStatus = ref.watch(locationPermissionStatusProvider);
  return permissionStatus.when(
    data: (permission) => 
        permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always,
    loading: () => false,
    error: (_, __) => false,
  );
}

@riverpod
bool isLocationServiceEnabled(IsLocationServiceEnabledRef ref) {
  final serviceStatus = ref.watch(locationServiceStatusProvider);
  return serviceStatus.when(
    data: (isEnabled) => isEnabled,
    loading: () => false,
    error: (_, __) => false,
  );
}

@riverpod
bool canAccessLocation(CanAccessLocationRef ref) {
  final hasPermission = ref.watch(hasLocationPermissionProvider);
  final serviceEnabled = ref.watch(isLocationServiceEnabledProvider);
  return hasPermission && serviceEnabled;
}

@riverpod
String? currentLocationAddress(CurrentLocationAddressRef ref) {
  final locationState = ref.watch(locationNotifierProvider);
  return locationState.when(
    data: (location) => location?.address,
    loading: () => null,
    error: (_, __) => null,
  );
}

@riverpod
Position? currentPosition(CurrentPositionRef ref) {
  final locationState = ref.watch(locationNotifierProvider);
  return locationState.when(
    data: (location) => location?.position,
    loading: () => null,
    error: (_, __) => null,
  );
}