import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'package:homechef/models/chef.dart';
import 'package:homechef/models/cuisine.dart';
import 'package:homechef/models/carousel_item.dart';
import 'package:homechef/services/carousel_service.dart';
import 'package:homechef/widgets/chef_card.dart';
import 'package:homechef/widgets/category_chip.dart';
import 'package:homechef/widgets/image_carousel.dart';
import 'package:homechef/widgets/featured_chef_card.dart';
import 'package:homechef/screens/chef_profile_screen.dart';
import 'package:homechef/widgets/condensed_cuisine_selector.dart';
import 'package:homechef/widgets/location_selector.dart';
import 'package:homechef/providers/location_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final List<Chef> _chefs = Chef.getSampleChefs();
  final List<Cuisine> _cuisines = Cuisine.getAllCuisines();
  String? _selectedCuisine;
  Future<List<CarouselItem>>? _carouselItemsFuture;
  final ScrollController _scrollController = ScrollController();
  bool _showCondensedCuisines = false;
  final GlobalKey _cuisineKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _carouselItemsFuture = CarouselService.fetchCarouselItemsFromStorage();
    _scrollController.addListener(_onScroll);
    // Request location on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestInitialLocation();
    });
  }

  void _requestInitialLocation() async {
    try {
      // Check if we can access location without showing UI disruption
      final canAccess = ref.read(canAccessLocationProvider);
      if (canAccess) {
        ref.read(locationNotifierProvider.notifier).getCurrentLocation();
      }
    } catch (e) {
      // Silently handle initial location request failures
      // User can manually request location later
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_cuisineKey.currentContext != null) {
      final RenderBox? renderBox = _cuisineKey.currentContext!.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        
        // Show condensed cuisines when the main cuisine section is scrolled out of view
        setState(() {
          _showCondensedCuisines = position.dy < -renderBox.size.height;
        });
      }
    }
  }

  List<Chef> get _filteredChefs {
    final userLocation = ref.watch(currentPositionProvider);
    
    var chefs = _selectedCuisine == null 
        ? _chefs 
        : _chefs.where((chef) => chef.cuisineTypes.contains(_selectedCuisine)).toList();
    
    // Sort by distance if user location is available
    if (userLocation != null) {
      chefs.sort((a, b) {
        // For now, we'll use sample coordinates for chefs
        // In a real app, chefs would have actual lat/lng coordinates
        final distanceA = _calculateChefDistance(userLocation, a);
        final distanceB = _calculateChefDistance(userLocation, b);
        return distanceA.compareTo(distanceB);
      });
    }
    
    return chefs;
  }

  double _calculateChefDistance(position, Chef chef) {
    // Sample chef locations (in a real app, these would be stored in the Chef model)
    final chefLocations = {
      'Chef Marcus Nielsen': {'lat': 57.0488, 'lng': 9.9217}, // Aalborg area
      'Chef Isabella Romano': {'lat': 57.0560, 'lng': 9.9152}, 
      'Chef Hiroshi Tanaka': {'lat': 57.0420, 'lng': 9.9354},
      'Chef Elena Rodriguez': {'lat': 57.0500, 'lng': 9.9100},
      'Chef Jean-Pierre Dubois': {'lat': 57.0450, 'lng': 9.9280},
      'Chef Sofia Andersson': {'lat': 57.0520, 'lng': 9.9180},
    };

    final chefCoords = chefLocations[chef.name];
    if (chefCoords == null) {
      return double.infinity; // Unknown location, sort to end
    }

    // Use the LocationService to calculate distance
    return _calculateDistance(
      position.latitude,
      position.longitude,
      chefCoords['lat']!,
      chefCoords['lng']!,
    );
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    // Simple distance calculation (you could import geolocator for this)
    const double earthRadius = 6371000; // meters
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final availableChefs = _chefs.where((chef) => chef.isAvailable).toList();
    final popularChefs = _chefs.where((chef) => chef.rating >= 4.8).toList();

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Sticky header with location selector
              SliverAppBar(
                pinned: true,
                floating: false,
                expandedHeight: 60 + (_showCondensedCuisines ? 50 : 0),
                collapsedHeight: 60 + (_showCondensedCuisines ? 50 : 0),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: _showCondensedCuisines ? 2 : 0,
                flexibleSpace: SafeArea(
                  child: Column(
                    children: [
                      // Location selector row
                      Container(
                        height: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            const Expanded(child: LocationSelector()),
                            const SizedBox(width: 12),
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade800,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.notifications_outlined,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                                Positioned(
                                  right: -4,
                                  top: -4,
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Text(
                                        '2',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Condensed cuisine selector (animated)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: _showCondensedCuisines ? 50 : 0,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _showCondensedCuisines ? 1.0 : 0.0,
                          child: CondensedCuisineSelector(
                            cuisines: _cuisines,
                            selectedCuisine: _selectedCuisine,
                            onCuisineSelected: (cuisine) {
                              setState(() {
                                _selectedCuisine = cuisine;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Main cuisine selector
              SliverToBoxAdapter(
                child: SizedBox(
                  key: _cuisineKey,
                  height: 120,
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
                            _selectedCuisine = _selectedCuisine == cuisine.name
                                ? null
                                : cuisine.name;
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(
            child: FutureBuilder<List<CarouselItem>>(
              future: _carouselItemsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: 200,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Container(
                    height: 200,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.grey.shade600,
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Failed to load carousel',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Using sample data',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final carouselItems = snapshot.data ?? [];

                if (carouselItems.isEmpty) {
                  return Container(
                    height: 200,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        'No carousel items available',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                }

                return ImageCarousel(
                  items: carouselItems,
                  height: 200,
                  bucketName: 'marketing',
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Featured Chefs',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: Navigate to all chefs screen
                    },
                    child: Text(
                      'See all',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: availableChefs.length,
                itemBuilder: (context, index) {
                  final chef = availableChefs[index];
                  return FeaturedChefCard(
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
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Chefs Near You',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: Navigate to all available chefs screen
                    },
                    child: Text(
                      'See all',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: availableChefs.length,
                itemBuilder: (context, index) {
                  final chef = availableChefs[index];
                  return ChefCard(
                    chef: chef,
                    isCompact: true,
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
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Popular Chefs in Your Region',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final chef = popularChefs[index];
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
            }, childCount: popularChefs.length),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ],
      ),
    );
  }
}
