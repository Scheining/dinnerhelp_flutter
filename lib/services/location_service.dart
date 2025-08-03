import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/location_data.dart';
import '../exceptions/location_exceptions.dart';

class LocationService {
  static const Duration _defaultTimeout = Duration(seconds: 15);
  static const LocationSettings _defaultLocationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100, // Only notify if moved 100 meters
  );

  /// Check and request location permissions
  static Future<LocationPermission> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const DinnerHelpLocationServiceDisabledException(
        'Location services are disabled. Please enable location services in your device settings.',
      );
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const DinnerHelpLocationPermissionDeniedException(
          'Location permissions are denied. Please grant location access to use this feature.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const DinnerHelpLocationPermissionDeniedForeverException(
        'Location permissions are permanently denied. Please enable location access in app settings.',
      );
    }

    return permission;
  }

  /// Get the current position with timeout and error handling
  static Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
    Duration? timeout,
  }) async {
    await handleLocationPermission();

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: locationSettings ?? _defaultLocationSettings,
      ).timeout(
        timeout ?? _defaultTimeout,
        onTimeout: () => throw const DinnerHelpLocationTimeoutException(
          'Location request timed out. Please try again.',
        ),
      );
    } catch (e) {
      if (e is LocationException) rethrow;
      throw LocationException('Failed to get current location: ${e.toString()}');
    }
  }

  /// Get address from position coordinates
  static Future<String> getAddressFromPosition(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        return 'Unknown Location';
      }

      final place = placemarks.first;
      
      // Create a readable address
      final parts = <String>[];
      
      if (place.locality?.isNotEmpty == true) {
        parts.add(place.locality!);
      }
      
      if (place.administrativeArea?.isNotEmpty == true && 
          place.administrativeArea != place.locality) {
        parts.add(place.administrativeArea!);
      }
      
      if (place.country?.isNotEmpty == true) {
        parts.add(place.country!);
      }

      return parts.isNotEmpty ? parts.join(', ') : 'Unknown Location';
    } catch (e) {
      return 'Unknown Location';
    }
  }

  /// Get complete location data (position + address)
  static Future<LocationData> getCurrentLocationData({
    LocationSettings? locationSettings,
    Duration? timeout,
  }) async {
    final position = await getCurrentPosition(
      locationSettings: locationSettings,
      timeout: timeout,
    );
    
    final address = await getAddressFromPosition(position);
    
    return LocationData(
      position: position,
      address: address,
      timestamp: DateTime.now(),
    );
  }

  /// Get a stream of location updates
  static Stream<Position> getLocationStream({
    LocationSettings? locationSettings,
  }) async* {
    await handleLocationPermission();
    
    yield* Geolocator.getPositionStream(
      locationSettings: locationSettings ?? _defaultLocationSettings,
    );
  }

  /// Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Open app settings to manage permissions
  static Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Open location settings
  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Calculate distance between two coordinates in meters
  static double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Calculate bearing between two coordinates
  static double calculateBearing(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.bearingBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Get last known position (can be null)
  static Future<Position?> getLastKnownPosition() async {
    try {
      await handleLocationPermission();
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      return null;
    }
  }
}