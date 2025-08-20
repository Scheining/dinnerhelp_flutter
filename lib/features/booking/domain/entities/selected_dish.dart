import 'package:equatable/equatable.dart';
import 'dish.dart';

class SelectedDish extends Equatable {
  final Dish dish;
  final int quantity;
  final String? specialInstructions;

  const SelectedDish({
    required this.dish,
    this.quantity = 1,
    this.specialInstructions,
  });

  int get totalPreparationTimeMinutes => dish.preparationTimeMinutes * quantity;
  Duration get totalPreparationTime => Duration(minutes: totalPreparationTimeMinutes);

  SelectedDish copyWith({
    Dish? dish,
    int? quantity,
    String? specialInstructions,
  }) {
    return SelectedDish(
      dish: dish ?? this.dish,
      quantity: quantity ?? this.quantity,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }

  @override
  List<Object?> get props => [dish, quantity, specialInstructions];

  @override
  String toString() {
    return 'SelectedDish(dish: ${dish.name}, quantity: $quantity)';
  }
}