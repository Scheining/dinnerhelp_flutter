import 'package:equatable/equatable.dart';

class ChefAlternative extends Equatable {
  final String chefId;
  final String chefName;
  final String profileImageUrl;
  final double rating;
  final int reviewCount;
  final double hourlyRate;
  final double distanceKm;
  final List<String> cuisines;
  final List<String> availableSlots; // Available time slots on the requested date
  final AlternativeMatchScore matchScore;
  final String? unavailabilityReason;

  const ChefAlternative({
    required this.chefId,
    required this.chefName,
    required this.profileImageUrl,
    required this.rating,
    required this.reviewCount,
    required this.hourlyRate,
    required this.distanceKm,
    required this.cuisines,
    required this.availableSlots,
    required this.matchScore,
    this.unavailabilityReason,
  });

  bool get isHighMatch => matchScore.overallScore >= 0.8;
  bool get isGoodMatch => matchScore.overallScore >= 0.6;
  bool get hasAvailableSlots => availableSlots.isNotEmpty;

  @override
  List<Object?> get props => [
    chefId,
    chefName,
    profileImageUrl,
    rating,
    reviewCount,
    hourlyRate,
    distanceKm,
    cuisines,
    availableSlots,
    matchScore,
    unavailabilityReason,
  ];
}

class AlternativeMatchScore extends Equatable {
  final double cuisineMatch; // 0.0 to 1.0
  final double locationMatch; // Based on distance
  final double priceMatch; // Based on price difference
  final double ratingMatch; // Based on chef rating
  final double availabilityMatch; // Based on available slots
  final double overallScore; // Weighted average

  const AlternativeMatchScore({
    required this.cuisineMatch,
    required this.locationMatch,
    required this.priceMatch,
    required this.ratingMatch,
    required this.availabilityMatch,
    required this.overallScore,
  });

  factory AlternativeMatchScore.calculate({
    required double cuisineMatch,
    required double locationMatch,
    required double priceMatch,
    required double ratingMatch,
    required double availabilityMatch,
  }) {
    // Weighted calculation
    const weights = {
      'cuisine': 0.25,
      'location': 0.20,
      'price': 0.15,
      'rating': 0.20,
      'availability': 0.20,
    };

    final overallScore = (cuisineMatch * weights['cuisine']!) +
        (locationMatch * weights['location']!) +
        (priceMatch * weights['price']!) +
        (ratingMatch * weights['rating']!) +
        (availabilityMatch * weights['availability']!);

    return AlternativeMatchScore(
      cuisineMatch: cuisineMatch,
      locationMatch: locationMatch,
      priceMatch: priceMatch,
      ratingMatch: ratingMatch,
      availabilityMatch: availabilityMatch,
      overallScore: overallScore,
    );
  }

  String get matchGrade {
    if (overallScore >= 0.9) return 'Excellent';
    if (overallScore >= 0.8) return 'Very Good';
    if (overallScore >= 0.7) return 'Good';
    if (overallScore >= 0.6) return 'Fair';
    return 'Poor';
  }

  @override
  List<Object> get props => [
    cuisineMatch,
    locationMatch,
    priceMatch,
    ratingMatch,
    availabilityMatch,
    overallScore,
  ];
}

class UnavailabilityReason extends Equatable {
  final UnavailabilityType type;
  final String description;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isEmergency;

  const UnavailabilityReason({
    required this.type,
    required this.description,
    this.startDate,
    this.endDate,
    this.isEmergency = false,
  });

  @override
  List<Object?> get props => [type, description, startDate, endDate, isEmergency];
}

enum UnavailabilityType {
  illness,
  familyEmergency,
  equipmentFailure,
  doubleBooking,
  personalReasons,
  travelDelay,
  weatherConditions,
  kitchenUnavailable,
  other,
}

extension UnavailabilityTypeExtension on UnavailabilityType {
  String get displayName {
    switch (this) {
      case UnavailabilityType.illness:
        return 'Illness';
      case UnavailabilityType.familyEmergency:
        return 'Family Emergency';
      case UnavailabilityType.equipmentFailure:
        return 'Equipment Failure';
      case UnavailabilityType.doubleBooking:
        return 'Double Booking';
      case UnavailabilityType.personalReasons:
        return 'Personal Reasons';
      case UnavailabilityType.travelDelay:
        return 'Travel Delay';
      case UnavailabilityType.weatherConditions:
        return 'Weather Conditions';
      case UnavailabilityType.kitchenUnavailable:
        return 'Kitchen Unavailable';
      case UnavailabilityType.other:
        return 'Other';
    }
  }

  bool get isEmergency => [
    UnavailabilityType.illness,
    UnavailabilityType.familyEmergency,
    UnavailabilityType.equipmentFailure,
    UnavailabilityType.weatherConditions,
  ].contains(this);
}