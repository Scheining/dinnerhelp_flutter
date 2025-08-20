import 'package:equatable/equatable.dart';

class CustomDishRequest extends Equatable {
  final String name;
  final String description;
  final int estimatedPreparationTimeMinutes;
  final List<String> allergens;
  final List<String> dietaryRequirements;
  final String? additionalNotes;

  const CustomDishRequest({
    required this.name,
    required this.description,
    this.estimatedPreparationTimeMinutes = 60, // Default 1 hour
    this.allergens = const [],
    this.dietaryRequirements = const [],
    this.additionalNotes,
  });

  Duration get estimatedPreparationTime => Duration(minutes: estimatedPreparationTimeMinutes);

  @override
  List<Object?> get props => [
    name,
    description,
    estimatedPreparationTimeMinutes,
    allergens,
    dietaryRequirements,
    additionalNotes,
  ];

  @override
  String toString() {
    return 'CustomDishRequest(name: $name, estimatedTime: ${estimatedPreparationTimeMinutes}min)';
  }
}