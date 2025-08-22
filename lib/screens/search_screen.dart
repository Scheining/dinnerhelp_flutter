import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homechef/models/chef.dart';
import 'package:homechef/models/cuisine.dart';
import 'package:homechef/widgets/chef_card.dart';
import 'package:homechef/widgets/category_chip.dart';
import 'package:homechef/widgets/condensed_cuisine_selector.dart';
import 'package:homechef/screens/chef_profile_screen.dart';
import 'package:homechef/features/search/presentation/providers/search_providers.dart';
import 'package:homechef/features/search/domain/entities/search_filters.dart' as search_entities;
import 'package:homechef/features/search/domain/entities/chef_search_result.dart';
import 'package:homechef/features/search/presentation/widgets/stepped_date_time_selector.dart';
import 'package:homechef/features/search/presentation/widgets/advanced_filters_sheet.dart';
import 'package:homechef/providers/location_providers.dart';
import 'package:homechef/providers/favorites_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Cuisine> _cuisines = Cuisine.getAllCuisines();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _cuisineKey = GlobalKey();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _updateSearchText(String text) {
    ref.read(searchFiltersProvider.notifier).updateSearchText(
      text.isEmpty ? null : text,
    );
  }

  void _updateCuisineFilter(String? cuisine) {
    final currentFilters = ref.read(searchFiltersProvider);
    final currentCuisines = currentFilters.cuisineTypes ?? [];
    
    List<String>? newCuisines;
    if (cuisine != null) {
      if (currentCuisines.contains(cuisine)) {
        newCuisines = currentCuisines.where((c) => c != cuisine).toList();
        if (newCuisines.isEmpty) newCuisines = null;
      } else {
        newCuisines = [...currentCuisines, cuisine];
      }
    }
    
    ref.read(searchFiltersProvider.notifier).updateCuisineTypes(newCuisines);
  }

  void _showDateTimePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SteppedDateTimeSelector(),
    );
  }

  void _showAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AdvancedFiltersSheet(),
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentFilters = ref.watch(searchFiltersProvider);
    final searchResultsAsync = ref.watch(searchResultsProvider);
    final hasActiveSearch = ref.watch(hasActiveSearchProvider);
    final searchSummary = ref.watch(searchSummaryProvider);

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark 
          ? theme.scaffoldBackgroundColor 
          : Colors.grey.shade50,
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
                // App Bar
                SliverAppBar(
                  pinned: true,
                  floating: false,
                  toolbarHeight: 60,
                  backgroundColor: theme.brightness == Brightness.dark 
                      ? theme.appBarTheme.backgroundColor 
                      : Colors.white,
                  surfaceTintColor: Colors.transparent,
                  scrolledUnderElevation: 0,
                  elevation: 0,
                  forceElevated: false,
                  title: Text(
                    'Find kokke',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.brightness == Brightness.dark 
                          ? Colors.white 
                          : Colors.black,
                    ),
                  ),
                  centerTitle: false,
                  actions: [
                    IconButton(
                      icon: Icon(
                        Icons.schedule,
                        color: currentFilters.hasAvailabilityFilters 
                            ? theme.colorScheme.primary 
                            : theme.brightness == Brightness.dark 
                                ? Colors.white 
                                : Colors.black,
                      ),
                      onPressed: _showDateTimePicker,
                      tooltip: 'Select date & time',
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.tune,
                        color: hasActiveSearch 
                            ? theme.colorScheme.primary 
                            : theme.brightness == Brightness.dark 
                                ? Colors.white 
                                : Colors.black,
                      ),
                      onPressed: _showAdvancedFilters,
                      tooltip: 'More filters',
                    ),
                  ],
                ),

                // Search Bar
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Søg kokke, køkkener eller lokationer...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                          letterSpacing: 0.3,
                        ),
                        prefixIcon: Container(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.search_rounded,
                            color: _searchController.text.isNotEmpty 
                                ? theme.colorScheme.primary 
                                : Colors.grey.shade500,
                            size: 24,
                          ),
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? Container(
                                margin: const EdgeInsets.only(right: 8),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () {
                                      _searchController.clear();
                                      _updateSearchText('');
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.close_rounded,
                                        color: Colors.grey.shade600,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : null,
                        filled: true,
                        fillColor: theme.brightness == Brightness.light 
                            ? Colors.white 
                            : theme.colorScheme.surface,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: theme.brightness == Brightness.light
                                ? Colors.grey.shade200
                                : theme.colorScheme.outline.withOpacity(0.1),
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: theme.brightness == Brightness.light
                                ? Colors.grey.shade200
                                : theme.colorScheme.outline.withOpacity(0.1),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: _updateSearchText,
                    ),
                  ),
                ),

                // Filter summary
                if (currentFilters.hasAvailabilityFilters || hasActiveSearch)
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _showDateTimePicker,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.outline.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    currentFilters.hasAvailabilityFilters ? Icons.event : Icons.tune,
                                    size: 16,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    currentFilters.hasAvailabilityFilters 
                                      ? _getAvailabilityTextDanish(currentFilters)
                                      : searchSummary,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      if (currentFilters.hasAvailabilityFilters) {
                                        ref.read(searchFiltersProvider.notifier).updateDate(null);
                                        ref.read(searchFiltersProvider.notifier).updateStartTime(null);
                                        ref.read(searchFiltersProvider.notifier).updateDuration(null);
                                        ref.read(searchFiltersProvider.notifier).updateNumberOfGuests(null);
                                      } else {
                                        ref.read(searchFiltersProvider.notifier).clearFilters();
                                        _searchController.clear();
                                      }
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Ryd',
                                          style: TextStyle(
                                            color: theme.colorScheme.primary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.close,
                                          size: 14,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Cuisine selector with key for tracking
                SliverToBoxAdapter(
                  child: SizedBox(
                    key: _cuisineKey,
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: _cuisines.length,
                      itemBuilder: (context, index) {
                        final cuisine = _cuisines[index];
                        final isSelected = currentFilters.cuisineTypes?.contains(cuisine.name) ?? false;
                        return CategoryChip(
                          cuisine: cuisine,
                          isSelected: isSelected,
                          onTap: () => _updateCuisineFilter(cuisine.name),
                        );
                      },
                    ),
                  ),
                ),

                // Search Results
                searchResultsAsync.when(
                  data: (results) {
                    if (results.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
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
                                'Ingen kokke fundet',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.brightness == Brightness.dark 
                                      ? Colors.grey.shade400 
                                      : Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Prøv at justere din søgning eller filtre',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.brightness == Brightness.dark 
                                      ? Colors.grey.shade500 
                                      : Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == 0) {
                            // Results count header
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      '${results.length} kokke fundet',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.brightness == Brightness.dark 
                                            ? Colors.grey.shade400 
                                            : Colors.grey.shade600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: DropdownButton<String>(
                                      value: currentFilters.sortBy,
                                      underline: const SizedBox(),
                                      isExpanded: false,
                                      isDense: true,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.primary,
                                      ),
                                      items: const [
                                        DropdownMenuItem(value: 'rating', child: Text('Bedømmelse')),
                                        DropdownMenuItem(value: 'distance', child: Text('Afstand')),
                                        DropdownMenuItem(value: 'price', child: Text('Pris')),
                                        DropdownMenuItem(value: 'availability', child: Text('Tilgængelig')),
                                      ],
                                      onChanged: (value) {
                                        if (value != null) {
                                          ref.read(searchFiltersProvider.notifier).updateSorting(value, false);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          
                          final result = results[index - 1];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: _AvailabilityChefCard(
                              result: result,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChefProfileScreen(chef: result.chef),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        childCount: results.length + 1,
                      ),
                    );
                  },
                  loading: () => const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, stack) => SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 80,
                              color: Colors.red.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Fejl ved indlæsning af kokke',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.red.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              error.toString(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton(
                              onPressed: () {
                                ref.invalidate(searchResultsProvider);
                              },
                              child: const Text('Prøv igen'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom padding for navigation
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          ),
          
          // Animated condensed cuisine selector overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 60, // Position right below the app bar
            left: 0,
            right: 0,
            child: _buildAnimatedCuisineSelector(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCuisineSelector() {
    final currentFilters = ref.watch(searchFiltersProvider);
    
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
        ),
        child: CondensedCuisineSelector(
          cuisines: _cuisines,
          selectedCuisine: currentFilters.cuisineTypes?.isNotEmpty == true 
              ? currentFilters.cuisineTypes!.first 
              : null,
          onCuisineSelected: _updateCuisineFilter,
        ),
      ),
    );
  }

  String _getAvailabilityTextDanish(search_entities.SearchFilters filters) {
    final List<String> parts = [];
    
    if (filters.date != null) {
      final date = filters.date!;
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));
      
      if (date.day == today.day && date.month == today.month && date.year == today.year) {
        parts.add('I dag');
      } else if (date.day == tomorrow.day && date.month == tomorrow.month && date.year == tomorrow.year) {
        parts.add('I morgen');
      } else {
        parts.add('${date.day}/${date.month}/${date.year}');
      }
    }
    
    if (filters.startTime != null) {
      parts.add('kl. ${filters.startTime}');
    }
    
    if (filters.duration != null) {
      final hours = filters.duration!.inHours;
      final minutes = filters.duration!.inMinutes % 60;
      if (hours > 0 && minutes > 0) {
        parts.add('i ${hours}t ${minutes}m');
      } else if (hours > 0) {
        parts.add('i ${hours}t');
      } else {
        parts.add('i ${minutes}m');
      }
    }
    
    if (filters.numberOfGuests != null) {
      parts.add('${filters.numberOfGuests} ${filters.numberOfGuests == 1 ? "person" : "personer"}');
    }
    
    return parts.isEmpty ? 'Tilpasset tidspunkt' : parts.join(' ');
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
      width: double.infinity, // Full width for search page
      child: Card(
        color: theme.brightness == Brightness.dark 
            ? const Color(0xFF252325) 
            : Colors.white,
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
                    child: result.chef.headerImage.isNotEmpty && 
                           !result.chef.headerImage.contains('forms.app')
                        ? Image.network(
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
                          )
                        : Container(
                            width: double.infinity,
                            height: 180,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/logo_brand.png'),
                                fit: BoxFit.cover,
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
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(37),
                        child: result.chef.profileImage.isNotEmpty && 
                               !result.chef.profileImage.contains('forms.app')
                            ? Image.network(
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
                              )
                            : Container(
                                width: 74,
                                height: 74,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.person, size: 30, color: Colors.white),
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
                      color: theme.brightness == Brightness.dark
                          ? const Color(0xFF79CBC2)
                          : theme.colorScheme.primary,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 4), // Reduced space after price
              
              // Chef info
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 8),
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
                                  : Colors.black87,
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
                              ? Colors.grey.shade300 
                              : Colors.grey.shade700,
                          height: 1.3,
                        ),
                        maxLines: 4, // Increased to show more bio text
                        overflow: TextOverflow.ellipsis,
                      ),
                    
                    const SizedBox(height: 12),
                    
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
                                  : null,
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
                          color: theme.brightness == Brightness.dark 
                              ? Colors.grey.shade500 
                              : Colors.grey.shade500,
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
            ],
          ),
        ),
      ),
    );
  }
}
