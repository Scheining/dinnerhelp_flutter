import 'package:flutter/material.dart';
import 'package:homechef/models/chef.dart';
import 'package:homechef/models/cuisine.dart';
import 'package:homechef/widgets/chef_card.dart';
import 'package:homechef/widgets/category_chip.dart';
import 'package:homechef/screens/chef_profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Chef> _allChefs = Chef.getSampleChefs();
  final List<Cuisine> _cuisines = Cuisine.getAllCuisines();
  
  List<Chef> _filteredChefs = [];
  String? _selectedCuisine;
  double _maxPrice = 500.0;
  bool _verifiedOnly = false;
  bool _availableOnly = false;
  String _sortBy = 'rating'; // 'rating', 'distance', 'price'

  @override
  void initState() {
    super.initState();
    _filteredChefs = List.from(_allChefs);
  }

  void _applyFilters() {
    setState(() {
      _filteredChefs = _allChefs.where((chef) {
        // Search text filter
        final searchText = _searchController.text.toLowerCase();
        final nameMatch = chef.name.toLowerCase().contains(searchText);
        final cuisineMatch = chef.cuisineTypes.any((cuisine) => 
            cuisine.toLowerCase().contains(searchText));
        final locationMatch = chef.location.toLowerCase().contains(searchText);
        
        if (searchText.isNotEmpty && !nameMatch && !cuisineMatch && !locationMatch) {
          return false;
        }

        // Cuisine filter
        if (_selectedCuisine != null && 
            !chef.cuisineTypes.contains(_selectedCuisine)) {
          return false;
        }

        // Price filter
        if (chef.hourlyRate > _maxPrice) return false;

        // Verified filter
        if (_verifiedOnly && !chef.isVerified) return false;

        // Available filter
        if (_availableOnly && !chef.isAvailable) return false;

        return true;
      }).toList();

      // Apply sorting
      _filteredChefs.sort((a, b) {
        switch (_sortBy) {
          case 'rating':
            return b.rating.compareTo(a.rating);
          case 'distance':
            return a.distanceKm.compareTo(b.distanceKm);
          case 'price':
            return a.hourlyRate.compareTo(b.hourlyRate);
          default:
            return 0;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Find Chefs',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search chefs, cuisines, or locations...',
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade600,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilters();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.primary),
                ),
              ),
              onChanged: (value) => _applyFilters(),
            ),
          ),
          
          // Cuisine Filters
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _cuisines.length,
              itemBuilder: (context, index) {
                final cuisine = _cuisines[index];
                return CategoryChip(
                  cuisine: cuisine,
                  isSelected: _selectedCuisine == cuisine.name,
                  onTap: () {
                    setState(() {
                      _selectedCuisine = _selectedCuisine == cuisine.name ? null : cuisine.name;
                    });
                    _applyFilters();
                  },
                );
              },
            ),
          ),
          
          // Sort & Filter Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${_filteredChefs.length} chefs found',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const Spacer(),
                DropdownButton<String>(
                  value: _sortBy,
                  underline: const SizedBox(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'rating', child: Text('Sort by Rating')),
                    DropdownMenuItem(value: 'distance', child: Text('Sort by Distance')),
                    DropdownMenuItem(value: 'price', child: Text('Sort by Price')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value ?? 'rating';
                    });
                    _applyFilters();
                  },
                ),
              ],
            ),
          ),
          
          // Results
          Expanded(
            child: _filteredChefs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No chefs found',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: _filteredChefs.length,
                    itemBuilder: (context, index) {
                      final chef = _filteredChefs[index];
                      return ChefCard(
                        chef: chef,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChefProfileScreen(chef: chef),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setModalState(() {
                        _selectedCuisine = null;
                        _maxPrice = 500.0;
                        _verifiedOnly = false;
                        _availableOnly = false;
                      });
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              Text(
                'Maximum Price per Hour',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Slider(
                value: _maxPrice,
                min: 200,
                max: 600,
                divisions: 8,
                label: '${_maxPrice.round()} DKK',
                onChanged: (value) {
                  setModalState(() {
                    _maxPrice = value;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              CheckboxListTile(
                title: const Text('Verified Chefs Only'),
                value: _verifiedOnly,
                onChanged: (value) {
                  setModalState(() {
                    _verifiedOnly = value ?? false;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              
              CheckboxListTile(
                title: const Text('Available Only'),
                value: _availableOnly,
                onChanged: (value) {
                  setModalState(() {
                    _availableOnly = value ?? false;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              
              const SizedBox(height: 24),
              
              Row(
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
                        setState(() {}); // Update parent state
                        _applyFilters();
                        Navigator.pop(context);
                      },
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}