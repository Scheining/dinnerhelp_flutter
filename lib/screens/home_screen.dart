import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homechef/core/localization/app_localizations_extension.dart';
import 'package:homechef/core/constants/spacing.dart';
import 'package:homechef/models/chef.dart';
import 'package:homechef/models/cuisine.dart';
import 'package:homechef/models/carousel_item.dart';
import 'package:homechef/services/carousel_service.dart';
import 'package:homechef/widgets/category_chip.dart';
import 'package:homechef/widgets/image_carousel.dart';
import 'package:homechef/widgets/featured_chef_card.dart';
import 'package:homechef/widgets/dish_card.dart';
import 'package:homechef/screens/chef_profile_screen.dart';
import 'package:homechef/screens/notifications_screen.dart';
import 'package:homechef/widgets/condensed_cuisine_selector.dart';
import 'package:homechef/widgets/location_selector.dart';
import 'package:homechef/providers/location_providers.dart';
import 'package:homechef/providers/chef_provider.dart';
import 'package:homechef/providers/dish_provider.dart';
import 'package:homechef/features/search/presentation/providers/search_providers.dart';
import 'package:homechef/features/search/domain/entities/chef_search_result.dart';
import 'package:homechef/providers/favorites_provider.dart';
import 'package:homechef/providers/notification_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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

  List<Chef> _filterChefsByCuisine(List<Chef> chefs) {
    if (_selectedCuisine == null) return chefs;
    return chefs.where((chef) => 
      chef.cuisineTypes.any((c) => c.toLowerCase() == _selectedCuisine!.toLowerCase())
    ).toList();
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final featuredChefsAsync = ref.watch(featuredChefsProvider);

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
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).appBarTheme.backgroundColor
                    : Colors.white,
                surfaceTintColor: Colors.transparent,
                scrolledUnderElevation: 0,
                elevation: 0,
                forceElevated: false,
                title: Row(
                  children: [
                    const Expanded(child: LocationSelector()),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        // Navigate to notifications screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationsScreen(),
                          ),
                        );
                      },
                      child: Stack(
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
                          Consumer(
                            builder: (context, ref, child) {
                              final unreadCountAsync = ref.watch(totalUnreadCountProvider);
                              return unreadCountAsync.when(
                                data: (count) {
                                  if (count > 0) {
                                    return Positioned(
                                      right: -4,
                                      top: -4,
                                      child: Container(
                                        width: 16,
                                        height: 16,
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            count > 9 ? '9+' : count.toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                                loading: () => const SizedBox.shrink(),
                                error: (error, stack) => const SizedBox.shrink(),
                              );
                            },
                          ),
                        ],
                      ),
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
                    context.l10n.featuredChefs,
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
            child: featuredChefsAsync.when(
              data: (chefs) {
                final filteredChefs = _filterChefsByCuisine(chefs);
                if (filteredChefs.isEmpty) {
                  return Container(
                    height: 200,
                    padding: AppSpacing.sectionPadding,
                    child: Center(
                      child: Text(
                        'Ingen udvalgte kokke tilgængelige',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  );
                }
                return SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: AppSpacing.sectionPadding,
                    itemCount: filteredChefs.length,
                    itemBuilder: (context, index) {
                      final chef = filteredChefs[index];
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
                );
              },
              loading: () => Container(
                height: 200,
                padding: AppSpacing.sectionPadding,
                child: const Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => Container(
                height: 200,
                padding: AppSpacing.sectionPadding,
                child: Center(
                  child: Text(
                    'Failed to load featured chefs',
                    style: TextStyle(color: Colors.red.shade400),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: AppSpacing.betweenSectionsLarge)),
          
          // Available Now Section
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.sectionPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Ledige nu',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      // Navigate to search with "available now" filter
                      // TODO: Implement navigation
                    },
                    child: Text(
                      'Se alle',
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
            child: _AvailabilitySection(
              provider: availableNowChefsProvider,
              filterCuisine: _selectedCuisine,
              emptyMessage: 'No chefs available right now',
              height: 420, // Made cards longer
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: AppSpacing.betweenSectionsLarge)),
          
          // Available This Week Section
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.sectionPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Ledige denne uge',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      // Navigate to search with "this week" filter
                      // TODO: Implement navigation
                    },
                    child: Text(
                      'Se alle',
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
            child: _AvailabilitySection(
              provider: availableThisWeekChefsProvider,
              filterCuisine: _selectedCuisine,
              emptyMessage: 'No chefs available this week',
              height: 420, // Made cards longer
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: AppSpacing.betweenSectionsLarge)),
          // Top Rated Available Section
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.sectionPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Topbedømte ledige kokke',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      // Navigate to search with "top rated available" filter
                      // TODO: Implement navigation
                    },
                    child: Text(
                      'Se alle',
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
            child: _AvailabilitySection(
              provider: topRatedAvailableChefsProvider,
              filterCuisine: _selectedCuisine,
              emptyMessage: 'No top rated chefs available',
              height: 420, // Made cards longer
            ),
          ),
          
          // Dish sections divider
          SliverToBoxAdapter(child: SizedBox(height: AppSpacing.betweenSectionsLarge)),
          
          // Newest dishes section
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.sectionPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nyeste retter',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: Navigate to all dishes screen
                    },
                    child: Text(
                      'Se alle',
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
            child: ref.watch(newestDishesProvider).when(
              data: (dishes) {
                if (dishes.isEmpty) {
                  return Container(
                    height: 280,
                    padding: AppSpacing.sectionPadding,
                    child: Center(
                      child: Text(
                        'Ingen retter tilgængelige',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  );
                }
                return SizedBox(
                  height: 320,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: AppSpacing.sectionPadding,
                    itemCount: dishes.length,
                    itemBuilder: (context, index) {
                      final dish = dishes[index];
                      return DishCard(
                        dish: dish,
                        onTap: () {
                          // TODO: Navigate to dish details
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => Container(
                height: 280,
                padding: AppSpacing.sectionPadding,
                child: const Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => Container(
                height: 280,
                padding: AppSpacing.sectionPadding,
                child: Center(
                  child: Text(
                    'Kunne ikke indlæse retter',
                    style: TextStyle(color: Colors.red.shade400),
                  ),
                ),
              ),
            ),
          ),
          
          // Popular dishes section
          SliverToBoxAdapter(child: SizedBox(height: AppSpacing.betweenSectionsLarge)),
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.sectionPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Populære retter',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: Navigate to all dishes screen with popular filter
                    },
                    child: Text(
                      'Se alle',
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
            child: ref.watch(popularDishesProvider).when(
              data: (dishes) {
                if (dishes.isEmpty) {
                  return Container(
                    height: 280,
                    padding: AppSpacing.sectionPadding,
                    child: Center(
                      child: Text(
                        'Ingen populære retter endnu',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  );
                }
                return SizedBox(
                  height: 320,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: AppSpacing.sectionPadding,
                    itemCount: dishes.length,
                    itemBuilder: (context, index) {
                      final dish = dishes[index];
                      return DishCard(
                        dish: dish,
                        onTap: () {
                          // TODO: Navigate to dish details
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => Container(
                height: 280,
                padding: AppSpacing.sectionPadding,
                child: const Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => Container(
                height: 280,
                padding: AppSpacing.sectionPadding,
                child: Center(
                  child: Text(
                    'Kunne ikke indlæse populære retter',
                    style: TextStyle(color: Colors.red.shade400),
                  ),
                ),
              ),
            ),
          ),
          
          // Most ordered dishes section
          SliverToBoxAdapter(child: SizedBox(height: AppSpacing.betweenSectionsLarge)),
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.sectionPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mest bestilte retter',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: Navigate to all dishes screen with most ordered filter
                    },
                    child: Text(
                      'Se alle',
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
            child: ref.watch(mostOrderedDishesProvider).when(
              data: (dishes) {
                if (dishes.isEmpty) {
                  return Container(
                    height: 280,
                    padding: AppSpacing.sectionPadding,
                    child: Center(
                      child: Text(
                        'Ingen bestilte retter endnu',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  );
                }
                return SizedBox(
                  height: 320,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: AppSpacing.sectionPadding,
                    itemCount: dishes.length,
                    itemBuilder: (context, index) {
                      final dish = dishes[index];
                      return DishCard(
                        dish: dish,
                        onTap: () {
                          // TODO: Navigate to dish details
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => Container(
                height: 280,
                padding: AppSpacing.sectionPadding,
                child: const Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => Container(
                height: 280,
                padding: AppSpacing.sectionPadding,
                child: Center(
                  child: Text(
                    'Kunne ikke indlæse mest bestilte retter',
                    style: TextStyle(color: Colors.red.shade400),
                  ),
                ),
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom navigation padding
              ],
            ),
          ),
          
          // Animated condensed cuisine selector overlay (directly attached to app bar)
          Positioned(
            top: MediaQuery.of(context).padding.top + 59.5, // Slight overlap to prevent gap
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
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).appBarTheme.backgroundColor
              : Colors.white,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).appBarTheme.backgroundColor ?? const Color(0xFF282D2E)
                  : Colors.white,
              width: 1,
            ),
          ),
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
    );
  }
}

class _AvailabilitySection extends ConsumerWidget {
  final ProviderListenable<AsyncValue<List<ChefSearchResult>>> provider;
  final String? filterCuisine;
  final String emptyMessage;
  final double height;

  const _AvailabilitySection({
    required this.provider,
    required this.filterCuisine,
    required this.emptyMessage,
    required this.height,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(provider);

    return resultsAsync.when(
      data: (results) {
        // Apply cuisine filter
        List<ChefSearchResult> filteredResults = results;
        if (filterCuisine != null) {
          filteredResults = results.where((result) => 
            result.chef.cuisineTypes.any((c) => c.toLowerCase() == filterCuisine!.toLowerCase())
          ).toList();
        }

        if (filteredResults.isEmpty) {
          return Container(
            height: height,
            padding: AppSpacing.sectionPadding,
            child: Center(
              child: Text(
                emptyMessage,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          );
        }

        return SizedBox(
          height: height,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: AppSpacing.sectionPadding,
            itemCount: filteredResults.length,
            itemBuilder: (context, index) {
              final result = filteredResults[index];
              return _AvailabilityChefCard(
                result: result,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChefProfileScreen(chef: result.chef),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
      loading: () => Container(
        height: height,
        padding: AppSpacing.sectionPadding,
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Container(
        height: height,
        padding: AppSpacing.sectionPadding,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Failed to load chefs',
                style: TextStyle(color: Colors.red.shade400),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {
                  // TODO: Implement retry logic
                  // The provider needs to be properly typed for refresh
                },
                child: const Text('Prøv igen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvailabilityChefCard extends ConsumerWidget {
  final ChefSearchResult result;
  final VoidCallback onTap;

  const _AvailabilityChefCard({
    required this.result,
    required this.onTap,
  });

  String _translateCuisine(String cuisine) {
    // Handle case-insensitive matching
    final cuisineLower = cuisine.toLowerCase();
    final Map<String, String> translations = {
      'italian': 'Italiensk',
      'french': 'Fransk',
      'asian': 'Asiatisk',
      'japanese': 'Japansk',
      'chinese': 'Kinesisk',
      'thai': 'Thai',
      'indian': 'Indisk',
      'mexican': 'Mexicansk',
      'spanish': 'Spansk',
      'greek': 'Græsk',
      'mediterranean': 'Middelhavs',
      'nordic': 'Nordisk',
      'danish': 'Dansk',
      'american': 'Amerikansk',
      'bbq': 'BBQ',
      'seafood': 'Fisk & Skaldyr',
      'vegetarian': 'Vegetarisk',
      'vegan': 'Vegansk',
      'fusion': 'Fusion',
      'middle eastern': 'Mellemøstlig',
      'korean': 'Koreansk',
      'vietnamese': 'Vietnamesisk',
      'ethiopian': 'Etiopisk',
      'caribbean': 'Caribisk',
      'german': 'Tysk',
      'british': 'Britisk',
      'sushi': 'Sushi',
      'pizza': 'Pizza',
      'pasta': 'Pasta',
      'brunch': 'Brunch',
      'desserts': 'Desserter',
      'healthy': 'Sundt',
      'comfort food': 'Comfort mad',
      'fast food': 'Fast food',
      'fine dining': 'Fine dining',
      'street food': 'Street food',
      'tapas': 'Tapas',
    };
    return translations[cuisineLower] ?? cuisine;
  }

  Color _getCuisineColor(String cuisine) {
    // Handle case-insensitive matching
    final cuisineLower = cuisine.toLowerCase();
    
    // Match colors from the top cuisine selector gradients
    final Map<String, Color> colors = {
      // Italian - Dark green
      'italian': const Color(0xFF2D6B4F),
      // French - Purple  
      'french': const Color(0xFF8E44AD),
      // Asian cuisines - Blue
      'asian': const Color(0xFF2980B9),
      'japanese': const Color(0xFF2980B9),
      'chinese': const Color(0xFF2980B9),
      'thai': const Color(0xFF2980B9),
      'indian': const Color(0xFF2980B9),
      'korean': const Color(0xFF2980B9),
      'vietnamese': const Color(0xFF2980B9),
      // Mediterranean - Olive
      'mediterranean': const Color(0xFF8D9A42),
      'greek': const Color(0xFF8D9A42),
      'spanish': const Color(0xFF8D9A42),
      'mexican': const Color(0xFF8D9A42),
      // Nordic - Brown
      'nordic': const Color(0xFF8B5A3C),
      // Danish - Light brown
      'danish': const Color(0xFFA0724C),
      // Seafood - Teal
      'seafood': const Color(0xFF4ECDC4),
      // Vegetarian/Vegan - Green
      'vegetarian': const Color(0xFF5D8E6A),
      'vegan': const Color(0xFF5D8E6A),
      'healthy': const Color(0xFF5D8E6A),
      // American/BBQ - Brown
      'american': const Color(0xFF8B5A3C),
      'bbq': const Color(0xFF8B5A3C),
      'comfort food': const Color(0xFF8B5A3C),
      // Middle Eastern - Brown
      'middle eastern': const Color(0xFF8B5A3C),
      // Fusion - Purple
      'fusion': const Color(0xFF8E44AD),
      // Others
      'sushi': const Color(0xFF2980B9), // Blue like Asian
      'pizza': const Color(0xFF2D6B4F), // Green like Italian
      'pasta': const Color(0xFF2D6B4F), // Green like Italian
      'brunch': const Color(0xFFA0724C), // Light brown
      'desserts': const Color(0xFF8E44AD), // Purple
      'tapas': const Color(0xFF8D9A42), // Olive like Spanish
    };
    
    return colors[cuisineLower] ?? const Color(0xFF8B5A3C); // Default brown
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isFavorited = ref.watch(isChefFavoritedProvider(result.chef.id));

    return Container(
      width: 330, // Increased by 50%
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chef header image with availability indicator
              Stack(
                clipBehavior: Clip.none, // Allow profile image to overflow
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      result.chef.headerImage,
                      width: double.infinity,
                      height: 180, // Increased by 50%
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: double.infinity,
                        height: 180, // Increased by 50%
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/logo_brand.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Top right controls - availability and favorite
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Row(
                      children: [
                        // Availability indicator
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: result.isAvailable 
                                ? Colors.green.shade600
                                : Colors.orange.shade600,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            result.isAvailable ? 'Ledig' : 'Optaget',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Favorite button
                        Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () async {
                              final notifier = ref.read(favoritesChefsProvider.notifier);
                              await notifier.toggleFavorite(result.chef.id);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              child: Icon(
                                isFavorited ? Icons.favorite : Icons.favorite_border,
                                color: isFavorited ? Colors.red : Colors.grey.shade600,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Chef profile image
                  Positioned(
                    bottom: -40, // Adjusted for larger card
                    left: 18, // Moved slightly right for larger card
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(37),
                        child: Image.network(
                          result.chef.profileImage,
                          width: 74, // Adjusted for larger card
                          height: 74, // Adjusted for larger card
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 74, // Adjusted for larger card
                            height: 74, // Adjusted for larger card
                            color: Theme.of(context).colorScheme.primary,
                            child: const Icon(Icons.person, size: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              // Price positioned to align with bottom of profile image
              Padding(
                padding: const EdgeInsets.only(top: 32, right: 20), // Adjusted padding
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${result.chef.hourlyRate.toInt()} DKK/time',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 4), // Reduced space after price
              
              // Chef info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12), // Increased side padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      // Name and verification
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              result.chef.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.brightness == Brightness.dark 
                                    ? Colors.white 
                                    : theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (result.chef.isVerified)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Icon(
                                Icons.verified,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Bio preview
                      if (result.chef.bio.isNotEmpty)
                        Text(
                          result.chef.bio,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.brightness == Brightness.dark 
                                ? Colors.grey.shade400  // Light gray for dark mode
                                : Colors.grey.shade700,  // Dark gray for light mode
                            height: 1.3,
                          ),
                          maxLines: 4, // Increased to show more bio text
                          overflow: TextOverflow.ellipsis,
                        ),
                      
                      const Spacer(),
                      
                      const SizedBox(height: 8), // Added spacing before bottom row
                      
                      // Bottom row with rating/badge and cuisines
                      Row(
                        children: [
                          if (result.chef.reviewCount > 0) ...[
                            Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber.shade600,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              result.chef.rating.toStringAsFixed(1),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.brightness == Brightness.dark 
                                    ? Colors.white 
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                          ] else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50), // Material green
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'NY',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          
                          const SizedBox(width: 12), // Increased spacing
                          
                          // Cuisine types as badges
                          Expanded(
                            child: Wrap(
                              spacing: 6,
                              children: result.chef.cuisineTypes.take(2).map((cuisine) {
                                // Translate cuisine to Danish
                                final danishCuisine = _translateCuisine(cuisine);
                                // Get color for the original English cuisine name
                                final color = _getCuisineColor(cuisine);
                                
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    danishCuisine,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      
                      // Distance or availability info
                      if (result.distance != null && result.distance! > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          result.distanceDisplay,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ] else if (result.availableTimeSlots?.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Ledig kl. ${result.availableTimeSlots!.take(2).join(', ')}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.green.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
