import 'package:equatable/equatable.dart';
import 'package:homechef/models/chef.dart';

class ChefSearchResult extends Equatable {
  final Chef chef;
  final double? distance; // Distance in km from search location
  final double? matchScore; // Relevance score (0.0 to 1.0)
  final List<String> matchedCuisines; // Cuisines that matched the search
  final bool isAvailable; // Available at the searched time
  final String? nextAvailableSlot; // Next available time if not available now
  final List<String>? availableTimeSlots; // Available time slots
  final String? unavailabilityReason; // Reason why chef is not available

  const ChefSearchResult({
    required this.chef,
    this.distance,
    this.matchScore,
    this.matchedCuisines = const [],
    this.isAvailable = true,
    this.nextAvailableSlot,
    this.availableTimeSlots,
    this.unavailabilityReason,
  });
  
  String get distanceDisplay {
    if (distance == null) return '';
    if (distance! < 1) {
      return '${(distance! * 1000).round()}m away';
    }
    return '${distance!.toStringAsFixed(1)}km away';
  }

  @override
  List<Object?> get props => [
    chef,
    distance,
    matchScore,
    matchedCuisines,
    isAvailable,
    nextAvailableSlot,
    availableTimeSlots,
    unavailabilityReason,
  ];

  @override
  String toString() {
    return 'ChefSearchResult(chef: ${chef.name}, distance: $distance km, matchScore: $matchScore, isAvailable: $isAvailable)';
  }
}