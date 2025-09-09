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

  // Define gradient colors for each cuisine type with transparency
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
                color: Colors.transparent,
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
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
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
