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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : Theme.of(context).colorScheme.surfaceContainerHighest,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: cuisines.length,
        itemBuilder: (context, index) {
          final cuisine = cuisines[index];
          final isSelected = selectedCuisine == cuisine.name;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SizedBox(
              height: 38, // Constrain height to prevent overflow
              child: FilterChip(
                selected: isSelected,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      cuisine.icon,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      cuisine.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                onSelected: (selected) {
                  onCuisineSelected(selected ? cuisine.name : null);
                },
                backgroundColor: Colors.grey.shade200,
                selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                checkmarkColor: Theme.of(context).primaryColor,
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          );
        },
      ),
    );
  }
}