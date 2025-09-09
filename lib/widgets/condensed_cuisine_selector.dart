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

  // Use the same gradient colors as CategoryChip with transparency
  List<Color> _getGradientColors(String cuisineId) {
    switch (cuisineId) {
      case 'nordic':
        return [
          const Color(0xFF6B4226).withOpacity(0.4),
          const Color(0xFF8B5A3C).withOpacity(0.4)
        ]; // Brown gradient
      case 'italian':
        return [
          const Color(0xFF1B4A3A).withOpacity(0.4),
          const Color(0xFF2D6B4F).withOpacity(0.4)
        ]; // Dark green gradient
      case 'asian':
        return [
          const Color(0xFF1A4B6B).withOpacity(0.4),
          const Color(0xFF2980B9).withOpacity(0.4)
        ]; // Blue gradient
      case 'french':
        return [
          const Color(0xFF6B4A7C).withOpacity(0.4),
          const Color(0xFF8E44AD).withOpacity(0.4)
        ]; // Purple gradient
      case 'mediterranean':
        return [
          const Color(0xFF6B7A26).withOpacity(0.4),
          const Color(0xFF8D9A42).withOpacity(0.4)
        ]; // Olive gradient
      case 'seafood':
        return [
          const Color(0xFF2E8B8B).withOpacity(0.4),
          const Color(0xFF4ECDC4).withOpacity(0.4)
        ]; // Teal gradient
      case 'vegetarian':
        return [
          const Color(0xFF4A7C59).withOpacity(0.4),
          const Color(0xFF5D8E6A).withOpacity(0.4)
        ]; // Green gradient
      case 'danish':
        return [
          const Color(0xFF8B5A3C).withOpacity(0.4),
          const Color(0xFFA0724C).withOpacity(0.4)
        ]; // Light brown gradient
      default:
        return [
          const Color(0xFF6B4226).withOpacity(0.4),
          const Color(0xFF8B5A3C).withOpacity(0.4)
        ]; // Default brown
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: Colors.transparent, // Let parent container provide the background
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.transparent,
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
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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