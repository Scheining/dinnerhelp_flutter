import 'package:flutter/material.dart';
import 'package:homechef/models/cuisine.dart';

class CondensedCuisineSelector extends StatelessWidget {
  final List<Cuisine> cuisines;
  final String? selectedCuisine;
  final Function(String?) onCuisineSelected;

  const CondensedCuisineSelector({
    super.key,
    required this.cuisines,
    required this.selectedCuisine,
    required this.onCuisineSelected,
  });

  // Use the same gradient colors as CategoryChip
  List<Color> _getGradientColors(String cuisineId) {
    switch (cuisineId) {
      case 'nordic':
        return [
          const Color(0xFF8D6E63),
          const Color(0xFFA1887F)
        ]; // Muted brown gradient
      case 'italian':
        return [
          const Color(0xFF558B6E),
          const Color(0xFF6FA287)
        ]; // Muted teal-green gradient
      case 'asian':
        return [
          const Color(0xFF5788A3),
          const Color(0xFF6FA3BD)
        ]; // Muted blue-teal gradient
      case 'french':
        return [
          const Color(0xFF7B68A6),
          const Color(0xFF9583BD)
        ]; // Muted purple gradient
      case 'mediterranean':
        return [
          const Color(0xFF829B6B),
          const Color(0xFF9BB185)
        ]; // Muted olive gradient
      case 'seafood':
        return [
          const Color(0xFF4FA5A5),
          const Color(0xFF6FBDBD)
        ]; // Teal gradient
      case 'vegetarian':
        return [
          const Color(0xFF6B9B7E),
          const Color(0xFF85B398)
        ]; // Muted sage green gradient
      case 'danish':
        return [
          const Color(0xFFAB8A71),
          const Color(0xFFC4A68B)
        ]; // Muted caramel gradient
      default:
        return [
          const Color(0xFF8D6E63),
          const Color(0xFFA1887F)
        ]; // Default muted brown
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      color: Colors.transparent, // Let parent container provide the background
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        itemCount: cuisines.length,
        itemBuilder: (context, index) {
          final cuisine = cuisines[index];
          final isSelected = selectedCuisine == cuisine.name;
          final gradientColors = _getGradientColors(cuisine.id);
          final cuisineName = Localizations.localeOf(context).languageCode == 'da' 
              ? cuisine.nameDa 
              : cuisine.nameEn;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                onCuisineSelected(isSelected ? null : cuisine.name);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 2)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      cuisine.icon,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      cuisineName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}