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

  final List<Map<String, String>> _dietaryOptions = [
    {'en': 'Vegetarian', 'da': 'Vegetarisk'},
    {'en': 'Vegan', 'da': 'Vegansk'},
    {'en': 'Gluten-Free', 'da': 'Glutenfri'},
    {'en': 'Dairy-Free', 'da': 'Mælkefri'},
    {'en': 'Keto', 'da': 'Keto'},
    {'en': 'Paleo', 'da': 'Paleo'},
    {'en': 'Pescatarian', 'da': 'Pescetarisk'},
    {'en': 'Halal', 'da': 'Halal'},
    {'en': 'Kosher', 'da': 'Kosher'},
    {'en': 'Low-Carb', 'da': 'Lavt kulhydrat'},
    {'en': 'Organic', 'da': 'Økologisk'},
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
    final isDark = theme.brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF252325) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Enhanced Handle bar with grip indicators
            Container(
              margin: const EdgeInsets.only(top: 8),
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),

            // Enhanced Header with back button
            Container(
              padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
              child: Row(
                children: [
                  // Back button
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark 
                            ? Colors.grey.shade800.withOpacity(0.5)
                            : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 20,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    locale == 'da' ? 'Avancerede filtre' : 'Advanced Filters',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
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
                    icon: const Icon(Icons.clear_all, size: 20),
                    label: Text(locale == 'da' ? 'Ryd alt' : 'Clear All'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            Divider(
              height: 1,
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            ),

            // Content with proper top margin
            Flexible(
              child: SingleChildScrollView(
                controller: controller,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cuisine Types Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark 
                            ? Colors.grey.shade900.withOpacity(0.5)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark 
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.restaurant_menu,
                                size: 20,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                locale == 'da' ? 'Køkkentyper' : 'Cuisine Types',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: cuisines.map((cuisine) {
                              final isSelected = _selectedCuisines.contains(cuisine.name);
                              final cuisineName = locale == 'da' ? cuisine.nameDa : cuisine.nameEn;
                              return FilterChip(
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(cuisine.icon, size: 16),
                                    const SizedBox(width: 4),
                                    Text(cuisineName),
                                  ],
                                ),
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
                                backgroundColor: isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade100,
                                selectedColor: theme.colorScheme.primaryContainer,
                                checkmarkColor: theme.colorScheme.primary,
                                labelStyle: TextStyle(
                                  color: isSelected 
                                      ? theme.colorScheme.onPrimaryContainer
                                      : (isDark ? Colors.white70 : Colors.black87),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Dietary Specialties Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark 
                            ? Colors.grey.shade900.withOpacity(0.5)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark 
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.eco,
                                size: 20,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                locale == 'da' ? 'Kostspecialiteter' : 'Dietary Specialties',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _dietaryOptions.map((dietary) {
                              final dietaryEn = dietary['en']!;
                              final dietaryDa = dietary['da']!;
                              final isSelected = _selectedDietarySpecialties.contains(dietaryEn);
                              return FilterChip(
                                label: Text(locale == 'da' ? dietaryDa : dietaryEn),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedDietarySpecialties.add(dietaryEn);
                                    } else {
                                      _selectedDietarySpecialties.remove(dietaryEn);
                                    }
                                  });
                                },
                                backgroundColor: isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade100,
                                selectedColor: theme.colorScheme.primaryContainer,
                                checkmarkColor: theme.colorScheme.primary,
                                labelStyle: TextStyle(
                                  color: isSelected 
                                      ? theme.colorScheme.onPrimaryContainer
                                      : (isDark ? Colors.white70 : Colors.black87),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Price Range Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark 
                            ? Colors.grey.shade900.withOpacity(0.5)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark 
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.payments,
                                size: 20,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                locale == 'da' 
                                    ? 'Prisinterval (DKK pr. time)' 
                                    : 'Price Range (DKK per hour)',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          RangeSlider(
                            values: RangeValues(_minPrice, _maxPrice),
                            min: 200,
                            max: 1000,
                            divisions: 16,
                            labels: RangeLabels(
                              '${_minPrice.round()}',
                              '${_maxPrice.round()}',
                            ),
                            activeColor: theme.colorScheme.primary,
                            inactiveColor: isDark 
                                ? Colors.grey.shade700
                                : Colors.grey.shade300,
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
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${_minPrice.round()} DKK',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward,
                                size: 16,
                                color: isDark ? Colors.white54 : Colors.grey.shade600,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${_maxPrice.round()} DKK',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Minimum Rating Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark 
                            ? Colors.grey.shade900.withOpacity(0.5)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark 
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 20,
                                color: Colors.amber.shade600,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                locale == 'da' ? 'Minimum vurdering' : 'Minimum Rating',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Slider(
                                  value: _minRating,
                                  min: 0.0,
                                  max: 5.0,
                                  divisions: 10,
                                  label: _minRating == 0 
                                      ? (locale == 'da' ? 'Alle' : 'Any')
                                      : '${_minRating.toStringAsFixed(1)}+',
                                  activeColor: Colors.amber.shade600,
                                  inactiveColor: isDark 
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade300,
                                  onChanged: (value) {
                                    setState(() {
                                      _minRating = value;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50.withOpacity(isDark ? 0.1 : 1),
                                  border: Border.all(
                                    color: Colors.amber.shade600.withOpacity(0.3),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ...List.generate(
                                      5,
                                      (index) => Icon(
                                        index < _minRating.floor()
                                            ? Icons.star
                                            : (index < _minRating.ceil() && _minRating % 1 != 0
                                                ? Icons.star_half
                                                : Icons.star_border),
                                        size: 16,
                                        color: Colors.amber.shade600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _minRating == 0 
                                          ? (locale == 'da' ? 'Alle' : 'Any')
                                          : '${_minRating.toStringAsFixed(1)}+',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Quick Filters Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark 
                            ? Colors.grey.shade900.withOpacity(0.5)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark 
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.filter_alt,
                                size: 20,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                locale == 'da' ? 'Hurtige filtre' : 'Quick Filters',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          Container(
                            decoration: BoxDecoration(
                              color: isDark 
                                  ? Colors.grey.shade800.withOpacity(0.5)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SwitchListTile(
                              title: Text(
                                locale == 'da' ? 'Kun ledige' : 'Available Only',
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              subtitle: Text(
                                locale == 'da' 
                                    ? 'Vis kun kokke der tager imod bookinger'
                                    : 'Show only chefs currently taking bookings',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white60 : Colors.grey.shade600,
                                ),
                              ),
                              value: _availableOnly,
                              activeColor: theme.colorScheme.primary,
                              onChanged: (value) {
                                setState(() {
                                  _availableOnly = value;
                                });
                              },
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Container(
                            decoration: BoxDecoration(
                              color: isDark 
                                  ? Colors.grey.shade800.withOpacity(0.5)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SwitchListTile(
                              title: Text(
                                locale == 'da' ? 'Kun verificerede kokke' : 'Verified Chefs Only',
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              subtitle: Text(
                                locale == 'da' 
                                    ? 'Vis kun verificerede professionelle kokke'
                                    : 'Show only verified professional chefs',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white60 : Colors.grey.shade600,
                                ),
                              ),
                              value: _verifiedOnly,
                              activeColor: theme.colorScheme.primary,
                              onChanged: (value) {
                                setState(() {
                                  _verifiedOnly = value;
                                });
                              },
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Sorting Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark 
                            ? Colors.grey.shade900.withOpacity(0.5)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark 
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.sort,
                                size: 20,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                locale == 'da' ? 'Sorter resultater' : 'Sort Results',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          DropdownButtonFormField<String>(
                            value: _sortBy,
                            dropdownColor: isDark ? const Color(0xFF252325) : Colors.white,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            decoration: InputDecoration(
                              labelText: locale == 'da' ? 'Sorter efter' : 'Sort by',
                              labelStyle: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                              filled: true,
                              fillColor: isDark 
                                  ? Colors.grey.shade800.withOpacity(0.5)
                                  : Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: isDark 
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: isDark 
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade300,
                                ),
                              ),
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'rating',
                                child: Text(locale == 'da' ? 'Vurdering' : 'Rating'),
                              ),
                              DropdownMenuItem(
                                value: 'distance',
                                child: Text(locale == 'da' ? 'Afstand' : 'Distance'),
                              ),
                              DropdownMenuItem(
                                value: 'price',
                                child: Text(locale == 'da' ? 'Pris' : 'Price'),
                              ),
                              DropdownMenuItem(
                                value: 'availability',
                                child: Text(locale == 'da' ? 'Tilgængelighed' : 'Availability'),
                              ),
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
                          
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                locale == 'da' ? 'Rækkefølge:' : 'Order:',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white70 : Colors.black54,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: isDark 
                                      ? Colors.grey.shade800.withOpacity(0.3)
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark 
                                        ? Colors.grey.shade700.withOpacity(0.5)
                                        : Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _sortAscending = false;
                                          });
                                        },
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: !_sortAscending
                                                ? theme.colorScheme.primary
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.arrow_downward,
                                                size: 16,
                                                color: !_sortAscending
                                                    ? Colors.white
                                                    : (isDark ? Colors.white70 : Colors.black54),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                locale == 'da' ? 'Høj til lav' : 'High to Low',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: !_sortAscending
                                                      ? FontWeight.w600
                                                      : FontWeight.w500,
                                                  color: !_sortAscending
                                                      ? Colors.white
                                                      : (isDark ? Colors.white70 : Colors.black54),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _sortAscending = true;
                                          });
                                        },
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _sortAscending
                                                ? theme.colorScheme.primary
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.arrow_upward,
                                                size: 16,
                                                color: _sortAscending
                                                    ? Colors.white
                                                    : (isDark ? Colors.white70 : Colors.black54),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                locale == 'da' ? 'Lav til høj' : 'Low to High',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: _sortAscending
                                                      ? FontWeight.w600
                                                      : FontWeight.w500,
                                                  color: _sortAscending
                                                      ? Colors.white
                                                      : (isDark ? Colors.white70 : Colors.black54),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Enhanced Bottom actions with gradient
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [
                          const Color(0xFF252325),
                          const Color(0xFF1A1A1A),
                        ]
                      : [
                          Colors.grey.shade50,
                          Colors.white,
                        ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: isDark 
                                ? Colors.grey.shade800.withOpacity(0.5)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark 
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.close,
                                size: 20,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                locale == 'da' ? 'Annuller' : 'Cancel',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white70 : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
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
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.check,
                                size: 20,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                locale == 'da' ? 'Anvend filtre' : 'Apply Filters',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}