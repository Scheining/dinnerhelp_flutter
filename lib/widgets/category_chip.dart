import 'package:flutter/material.dart';
import 'package:homechef/models/cuisine.dart';

class CategoryChip extends StatelessWidget {
  final Cuisine cuisine;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.cuisine,
    required this.isSelected,
    required this.onTap,
  });

  // Define gradient colors for each cuisine type
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
    final theme = Theme.of(context);
    final gradientColors = _getGradientColors(cuisine.id);

    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, 3),
                    blurRadius: 10,
                    spreadRadius: 0,
                  ),
                ],
                border: isSelected
                    ? Border.all(color: Colors.white, width: 2.5)
                    : null,
              ),
              child: Center(
                child: Icon(
                  cuisine.icon,
                  size: 26,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 70,
              child: Text(
                Localizations.localeOf(context).languageCode == 'da' 
                    ? cuisine.nameDa 
                    : cuisine.nameEn,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
        ),
      ),
    );
  }
}
