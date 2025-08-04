import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'package:homechef/core/localization/app_localizations_extension.dart';
import 'package:homechef/core/constants/spacing.dart';
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
  double _scrollOffset = 0.0;
  final GlobalKey _cuisineKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _carouselItemsFuture = CarouselService.fetchCarouselItemsFromStorage();
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
    _scrollController.dispose();
    super.dispose();
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
          NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              if (notification is ScrollUpdateNotification) {
                setState(() {
                  _scrollOffset = notification.metrics.pixels;
                });
              }
              return false;
            },
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
              // Sticky app bar with location selector
              SliverAppBar(
                pinned: true,
                floating: false,
                toolbarHeight: 60,
                backgroundColor: Theme.of(context).brightness == Brightness.light
                    ? Colors.white
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                surfaceTintColor: Colors.transparent,
                scrolledUnderElevation: 0,
                elevation: 0,
                forceElevated: false,
                title: Row(
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
                            color: Theme.of(context).brightness == Brightness.light
                                ? Colors.grey.shade200
                                : Colors.grey.shade800,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.notifications_outlined,
                            color: Theme.of(context).colorScheme.primary,
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
              
              // Add spacing between location bar and cuisine selector
              SliverToBoxAdapter(child: SizedBox(height: 16)),
              
              // Main cuisine selector (scrolls normally)
              SliverToBoxAdapter(
                child: SizedBox(
                  key: _cuisineKey,
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: AppSpacing.sectionPadding,
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
          SliverToBoxAdapter(child: SizedBox(height: AppSpacing.betweenSectionsLarge)),
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.sectionPadding,
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
                      context.l10n.seeAll,
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
          SliverToBoxAdapter(child: SizedBox(height: AppSpacing.betweenSectionsSmall)),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: AppSpacing.sectionPadding,
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
          SliverToBoxAdapter(child: SizedBox(height: AppSpacing.betweenSectionsLarge)),
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.sectionPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      context.l10n.availableChefsNearYou,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      // TODO: Navigate to all available chefs screen
                    },
                    child: Text(
                      context.l10n.seeAll,
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
          SliverToBoxAdapter(child: SizedBox(height: AppSpacing.betweenSectionsMedium)),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 285,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: AppSpacing.sectionPadding,
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
          SliverToBoxAdapter(child: SizedBox(height: AppSpacing.betweenSectionsLarge)),
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.sectionPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      context.l10n.popularChefsInRegion,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      // TODO: Navigate to all popular chefs screen
                    },
                    child: Text(
                      context.l10n.seeAll,
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
          SliverToBoxAdapter(child: SizedBox(height: AppSpacing.betweenSectionsMedium)),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 285,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: AppSpacing.sectionPadding,
                itemCount: popularChefs.length,
                itemBuilder: (context, index) {
                  final chef = popularChefs[index];
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
          const SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom navigation padding
              ],
            ),
          ),
          
          // Animated condensed cuisine selector overlay (directly attached to app bar)
          Positioned(
            top: MediaQuery.of(context).padding.top + 59, // Position right below the app bar
            left: 0,
            right: 0,
            child: _buildAnimatedCuisineSelector(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAnimatedCuisineSelector() {
    // Calculate the actual position of the cuisine selector
    double progress = 0.0;
    
    if (_cuisineKey.currentContext != null) {
      final RenderBox? renderBox = _cuisineKey.currentContext!.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        final appBarHeight = 60 + MediaQuery.of(context).padding.top;
        
        // Start showing when the cuisine selector is about to go under the app bar
        final triggerPoint = appBarHeight;
        
        if (position.dy < triggerPoint) {
          // Calculate progress based on how much the selector has scrolled under
          progress = ((triggerPoint - position.dy) / 50).clamp(0.0, 1.0);
        }
      }
    }
    
    if (progress == 0) {
      return const SizedBox.shrink();
    }
    
    return Transform.translate(
      offset: Offset(0, -50 * (1 - progress)), // Slide down from top
      child: Opacity(
        opacity: progress,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
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
    );
  }
}


