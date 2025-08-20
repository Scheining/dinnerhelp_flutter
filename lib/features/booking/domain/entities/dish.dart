import 'package:equatable/equatable.dart';

class Dish extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int preparationTimeMinutes;
  final List<String> allergens;
  final List<String> dietaryInfo; // e.g., ['vegan', 'gluten-free']
  final String? chefId;
  final bool isPopular;
  final int? servings;

  const Dish({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.preparationTimeMinutes,
    this.allergens = const [],
    this.dietaryInfo = const [],
    this.chefId,
    this.isPopular = false,
    this.servings,
  });

  Duration get preparationTime => Duration(minutes: preparationTimeMinutes);

  bool get isVegan => dietaryInfo.contains('vegan');
  bool get isVegetarian => dietaryInfo.contains('vegetarian') || isVegan;
  bool get isGlutenFree => dietaryInfo.contains('gluten-free');
  bool get isDairyFree => dietaryInfo.contains('dairy-free');

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    imageUrl,
    preparationTimeMinutes,
    allergens,
    dietaryInfo,
    chefId,
    isPopular,
    servings,
  ];

  @override
  String toString() {
    return 'Dish(id: $id, name: $name, preparationTime: ${preparationTimeMinutes}min)';
  }
}