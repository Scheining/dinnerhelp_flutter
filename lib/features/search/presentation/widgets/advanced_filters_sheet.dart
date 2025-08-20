import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homechef/models/cuisine.dart';
import '../providers/search_providers.dart';

class AdvancedFiltersSheet extends ConsumerStatefulWidget {
  const AdvancedFiltersSheet({super.key});

  @override
  ConsumerState<AdvancedFiltersSheet> createState() => _AdvancedFiltersSheetState();
}

class _AdvancedFiltersSheetState extends ConsumerState<AdvancedFiltersSheet> {
  // Local state for filters
  List<String> _selectedCuisines = [];
  List<String> _selectedDietarySpecialties = [];
  double _minPrice = 200.0;
  double _maxPrice = 600.0;
  double _minRating = 0.0;
  bool _availableOnly = false;
  bool _verifiedOnly = false;
  String _sortBy = 'rating';
  bool _sortAscending = false;

  final List<String> _dietaryOptions = [
    'Vegetarian',
    'Vegan',
    'Gluten-Free',
    'Dairy-Free',
    'Keto',
    'Paleo',
    'Pescatarian',
    'Halal',
    'Kosher',
    'Low-Carb',
    'Organic',
  ];

  @override
  void initState() {
    super.initState();
    final currentFilters = ref.read(searchFiltersProvider);
    
    _selectedCuisines = currentFilters.cuisineTypes ?? [];
    _selectedDietarySpecialties = currentFilters.dietarySpecialties ?? [];
    _minPrice = currentFilters.minPrice ?? 200.0;
    _maxPrice = currentFilters.maxPrice ?? 600.0;
    _minRating = currentFilters.minRating ?? 0.0;
    _availableOnly = currentFilters.availableOnly;
    _verifiedOnly = currentFilters.verifiedOnly;
    _sortBy = currentFilters.sortBy;
    _sortAscending = currentFilters.sortAscending;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cuisines = Cuisine.getAllCuisines();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text(
                  'Advanced Filters',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedCuisines.clear();
                      _selectedDietarySpecialties.clear();
                      _minPrice = 200.0;
                      _maxPrice = 600.0;
                      _minRating = 0.0;
                      _availableOnly = false;
                      _verifiedOnly = false;
                      _sortBy = 'rating';
                      _sortAscending = false;
                    });
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cuisine Types
                  Text(
                    'Cuisine Types',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: cuisines.map((cuisine) {
                      final isSelected = _selectedCuisines.contains(cuisine.name);
                      return FilterChip(
                        label: Text(cuisine.name),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedCuisines.add(cuisine.name);
                            } else {
                              _selectedCuisines.remove(cuisine.name);
                            }
                          });
                        },
                        backgroundColor: Colors.grey.shade100,
                        selectedColor: theme.colorScheme.primaryContainer,
                        checkmarkColor: theme.colorScheme.primary,
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),

                  // Dietary Specialties
                  Text(
                    'Dietary Specialties',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _dietaryOptions.map((dietary) {
                      final isSelected = _selectedDietarySpecialties.contains(dietary);
                      return FilterChip(
                        label: Text(dietary),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedDietarySpecialties.add(dietary);
                            } else {
                              _selectedDietarySpecialties.remove(dietary);
                            }
                          });
                        },
                        backgroundColor: Colors.grey.shade100,
                        selectedColor: theme.colorScheme.primaryContainer,
                        checkmarkColor: theme.colorScheme.primary,
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),

                  // Price Range
                  Text(
                    'Price Range (DKK per hour)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  RangeSlider(
                    values: RangeValues(_minPrice, _maxPrice),
                    min: 200,
                    max: 1000,
                    divisions: 16,
                    labels: RangeLabels(
                      '${_minPrice.round()}',
                      '${_maxPrice.round()}',
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        _minPrice = values.start;
                        _maxPrice = values.end;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_minPrice.round()} DKK',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        '${_maxPrice.round()} DKK',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Minimum Rating
                  Text(
                    'Minimum Rating',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _minRating,
                          min: 0.0,
                          max: 5.0,
                          divisions: 10,
                          label: _minRating == 0 ? 'Any' : '${_minRating.toStringAsFixed(1)}+',
                          onChanged: (value) {
                            setState(() {
                              _minRating = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _minRating == 0 ? 'Any' : '${_minRating.toStringAsFixed(1)}+',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Quick Filters
                  Text(
                    'Quick Filters',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  SwitchListTile(
                    title: const Text('Available Only'),
                    subtitle: const Text('Show only chefs currently taking bookings'),
                    value: _availableOnly,
                    onChanged: (value) {
                      setState(() {
                        _availableOnly = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  
                  SwitchListTile(
                    title: const Text('Verified Chefs Only'),
                    subtitle: const Text('Show only verified professional chefs'),
                    value: _verifiedOnly,
                    onChanged: (value) {
                      setState(() {
                        _verifiedOnly = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),

                  const SizedBox(height: 32),

                  // Sorting
                  Text(
                    'Sort Results',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  DropdownButtonFormField<String>(
                    value: _sortBy,
                    decoration: InputDecoration(
                      labelText: 'Sort by',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'rating', child: Text('Rating')),
                      DropdownMenuItem(value: 'distance', child: Text('Distance')),
                      DropdownMenuItem(value: 'price', child: Text('Price')),
                      DropdownMenuItem(value: 'availability', child: Text('Availability')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _sortBy = value;
                        });
                      }
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Text(
                        'Order:',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment<bool>(
                              value: false,
                              label: Text('High to Low'),
                              icon: Icon(Icons.arrow_downward, size: 16),
                            ),
                            ButtonSegment<bool>(
                              value: true,
                              label: Text('Low to High'),
                              icon: Icon(Icons.arrow_upward, size: 16),
                            ),
                          ],
                          selected: {_sortAscending},
                          onSelectionChanged: (Set<bool> newSelection) {
                            setState(() {
                              _sortAscending = newSelection.first;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Bottom actions
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Apply all filters
                      final notifier = ref.read(searchFiltersProvider.notifier);
                      
                      notifier.updateCuisineTypes(
                        _selectedCuisines.isEmpty ? null : _selectedCuisines,
                      );
                      notifier.updateDietarySpecialties(
                        _selectedDietarySpecialties.isEmpty ? null : _selectedDietarySpecialties,
                      );
                      notifier.updatePriceRange(
                        _minPrice == 200.0 ? null : _minPrice,
                        _maxPrice == 600.0 ? null : _maxPrice,
                      );
                      notifier.updateMinRating(
                        _minRating == 0.0 ? null : _minRating,
                      );
                      notifier.updateAvailableOnly(_availableOnly);
                      notifier.updateVerifiedOnly(_verifiedOnly);
                      notifier.updateSorting(_sortBy, _sortAscending);
                      
                      Navigator.pop(context);
                    },
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}