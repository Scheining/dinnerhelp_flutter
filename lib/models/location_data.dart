import 'package:geolocator/geolocator.dart';

class LocationData {
  final Position position;
  final String address;
  final DateTime timestamp;

  const LocationData({
    required this.position,
    required this.address,
    required this.timestamp,
  });

  double get latitude => position.latitude;
  double get longitude => position.longitude;
  double get accuracy => position.accuracy;

  // Calculate distance to another location in meters
  double distanceTo(double latitude, double longitude) {
    return Geolocator.distanceBetween(
      this.latitude,
      this.longitude,
      latitude,
      longitude,
    );
  }

  // Check if location is within a certain radius (in meters)
  bool isWithinRadius(double latitude, double longitude, double radiusMeters) {
    return distanceTo(latitude, longitude) <= radiusMeters;
  }

  @override
  String toString() {
    return 'LocationData(address: $address, lat: ${latitude.toStringAsFixed(4)}, lng: ${longitude.toStringAsFixed(4)})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationData &&
        other.address == address &&
        other.position.latitude == position.latitude &&
        other.position.longitude == position.longitude;
  }

  @override
  int get hashCode {
    return Object.hash(address, position.latitude, position.longitude);
  }
}