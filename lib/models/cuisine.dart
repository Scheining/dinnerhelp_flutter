import 'package:flutter/material.dart';

class Cuisine {
  final String id;
  final String name;
  final String nameEn;
  final String nameDa;
  final IconData icon;
  final Color color;

  const Cuisine({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.nameDa,
    required this.icon,
    required this.color,
  });

  static List<Cuisine> getAllCuisines() {
    return [
      const Cuisine(
        id: 'nordic',
        name: 'Nordic',
        nameEn: 'Nordic',
        nameDa: 'Nordisk',
        icon: Icons.restaurant_menu,
        color: Colors.blue,
      ),
      const Cuisine(
        id: 'italian',
        name: 'Italian',
        nameEn: 'Italian',
        nameDa: 'Italiensk',
        icon: Icons.local_pizza,
        color: Colors.red,
      ),
      const Cuisine(
        id: 'asian',
        name: 'Asian',
        nameEn: 'Asian',
        nameDa: 'Asiatisk',
        icon: Icons.ramen_dining,
        color: Colors.orange,
      ),
      const Cuisine(
        id: 'french',
        name: 'French',
        nameEn: 'French',
        nameDa: 'Fransk',
        icon: Icons.bakery_dining,
        color: Colors.purple,
      ),
      const Cuisine(
        id: 'mediterranean',
        name: 'Mediterranean',
        nameEn: 'Mediterranean',
        nameDa: 'Middelhavs',
        icon: Icons.local_florist,
        color: Colors.green,
      ),
      const Cuisine(
        id: 'seafood',
        name: 'Seafood',
        nameEn: 'Seafood',
        nameDa: 'Fisk & Skaldyr',
        icon: Icons.phishing,
        color: Colors.teal,
      ),
      const Cuisine(
        id: 'vegetarian',
        name: 'Vegetarian',
        nameEn: 'Vegetarian',
        nameDa: 'Vegetarisk',
        icon: Icons.eco,
        color: Colors.lightGreen,
      ),
      const Cuisine(
        id: 'danish',
        name: 'Danish',
        nameEn: 'Danish',
        nameDa: 'Dansk',
        icon: Icons.local_dining,
        color: Colors.indigo,
      ),
    ];
  }
}