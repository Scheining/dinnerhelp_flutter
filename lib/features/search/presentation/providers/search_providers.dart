import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:homechef/data/repositories/chef_repository.dart';
import 'package:homechef/models/chef.dart';
import 'package:homechef/models/location_data.dart';
import '../../../../providers/chef_provider.dart';
import '../../../../providers/location_providers.dart';
import '../../../booking/domain/services/booking_availability_service.dart';
import '../../../booking/presentation/providers/booking_availability_providers.dart';
import '../../data/repositories/chef_search_repository_impl.dart';
import '../../domain/entities/search_filters.dart' as domain;
import '../../domain/entities/chef_search_result.dart';
import '../../domain/repositories/chef_search_repository.dart';
import '../../domain/services/chef_search_service.dart';

part 'search_providers.g.dart';

// Repository and service providers
@riverpod
Future<SharedPreferences> sharedPreferences(SharedPreferencesRef ref) async {
  return await SharedPreferences.getInstance();
}

@riverpod
Future<ChefSearchRepository> chefSearchRepository(ChefSearchRepositoryRef ref) async {
  final chefRepository = ref.watch(chefRepositoryProvider);
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return ChefSearchRepositoryImpl(chefRepository, prefs);
}

@riverpod
Future<ChefSearchService> chefSearchService(ChefSearchServiceRef ref) async {
  final repository = await ref.watch(chefSearchRepositoryProvider.future);
  final availabilityService = ref.watch(bookingAvailabilityServiceProvider);
  return ChefSearchService(repository, availabilityService);
}

// Search state management
@riverpod
class SearchFilters extends _$SearchFilters {
  @override
  domain.SearchFilters build() {
    return const domain.SearchFilters();
  }

  void updateFilters(domain.SearchFilters newFilters) {
    state = newFilters;
  }

  void updateDate(DateTime? date) {
    state = state.copyWith(date: date);
  }

  void updateStartTime(String? startTime) {
    state = state.copyWith(startTime: startTime);
  }

  void updateDuration(Duration? duration) {
    state = state.copyWith(duration: duration);
  }

  void updateNumberOfGuests(int? numberOfGuests) {
    state = state.copyWith(numberOfGuests: numberOfGuests);
  }

  void updateSearchText(String? searchText) {
    state = state.copyWith(searchText: searchText);
  }

  void updateCuisineTypes(List<String>? cuisineTypes) {
    state = state.copyWith(cuisineTypes: cuisineTypes);
  }

  void updateDietarySpecialties(List<String>? dietarySpecialties) {
    state = state.copyWith(dietarySpecialties: dietarySpecialties);
  }

  void updatePriceRange(double? minPrice, double? maxPrice) {
    state = state.copyWith(minPrice: minPrice, maxPrice: maxPrice);
  }

  void updateMinRating(double? minRating) {
    state = state.copyWith(minRating: minRating);
  }

  void updateAvailableOnly(bool availableOnly) {
    state = state.copyWith(availableOnly: availableOnly);
  }

  void updateVerifiedOnly(bool verifiedOnly) {
    state = state.copyWith(verifiedOnly: verifiedOnly);
  }

  void updateSorting(String sortBy, bool sortAscending) {
    state = state.copyWith(sortBy: sortBy, sortAscending: sortAscending);
  }

  void clearFilters() {
    state = const domain.SearchFilters();
  }
}

// Search results providers
@riverpod
Future<List<ChefSearchResult>> availableChefSearch(
  AvailableChefSearchRef ref,
) async {
  final service = await ref.watch(chefSearchServiceProvider.future);
  final filters = ref.watch(searchFiltersProvider);
  final userLocation = ref.watch(locationNotifierProvider).value;

  if (filters.hasAvailabilityFilters) {
    // Search with specific availability criteria
    final result = await service.searchAvailableChefs(
      date: filters.date,
      startTime: filters.startTime,
      duration: filters.duration,
      numberOfGuests: filters.numberOfGuests,
      filters: filters,
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (results) => results,
    );
  } else {
    // General search
    final result = await service.getAvailableChefsForHome(
      userLocation: userLocation,
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (results) => results,
    );
  }
}

@riverpod
Future<List<ChefSearchResult>> searchResults(
  SearchResultsRef ref,
) async {
  final service = await ref.watch(chefSearchServiceProvider.future);
  final filters = ref.watch(searchFiltersProvider);

  // Save search to history if it has meaningful filters
  if (filters.hasFilters) {
    final repository = await ref.watch(chefSearchRepositoryProvider.future);
    await repository.saveSearchHistory(filters);
  }

  final result = await service.searchAvailableChefs(
    date: filters.date,
    startTime: filters.startTime,
    duration: filters.duration,
    numberOfGuests: filters.numberOfGuests,
    filters: filters,
  );

  return result.fold(
    (failure) => throw Exception(failure.message),
    (results) => results,
  );
}

// Home screen chef sections
@riverpod
Future<List<ChefSearchResult>> availableNowChefs(
  AvailableNowChefsRef ref,
) async {
  final service = await ref.watch(chefSearchServiceProvider.future);
  final userLocation = ref.watch(locationNotifierProvider).value;
  final today = DateTime.now();

  final result = await service.searchAvailableChefs(
    date: today,
    filters: const domain.SearchFilters(availableOnly: true),
  );

  return result.fold(
    (failure) => throw Exception(failure.message),
    (results) => results.take(10).toList(),
  );
}

@riverpod
Future<List<ChefSearchResult>> availableThisWeekChefs(
  AvailableThisWeekChefsRef ref,
) async {
  final repository = await ref.watch(chefSearchRepositoryProvider.future);
  final userLocation = ref.watch(locationNotifierProvider).value;

  final result = await repository.getChefsAvailableThisWeek();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (chefs) => chefs.map((chef) => ChefSearchResult(
      chef: chef,
      isAvailable: chef.isAvailable,
      distance: chef.distanceKm,
    )).take(10).toList(),
  );
}

@riverpod
Future<List<ChefSearchResult>> topRatedAvailableChefs(
  TopRatedAvailableChefsRef ref,
) async {
  final repository = await ref.watch(chefSearchRepositoryProvider.future);

  final result = await repository.getTopRatedAvailableChefs();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (chefs) => chefs.map((chef) => ChefSearchResult(
      chef: chef,
      isAvailable: chef.isAvailable,
      distance: chef.distanceKm,
    )).take(10).toList(),
  );
}

// Recent searches
@riverpod
Future<List<domain.SearchFilters>> recentSearches(RecentSearchesRef ref) async {
  final repository = await ref.watch(chefSearchRepositoryProvider.future);
  final result = await repository.getRecentSearches();
  
  return result.fold(
    (failure) => <domain.SearchFilters>[],
    (searches) => searches,
  );
}

// Quick search providers for common scenarios
@riverpod
Future<List<ChefSearchResult>> quickSearchByTime(
  QuickSearchByTimeRef ref,
  DateTime date,
  String startTime,
  Duration duration,
) async {
  final service = await ref.watch(chefSearchServiceProvider.future);
  
  final result = await service.searchAvailableChefs(
    date: date,
    startTime: startTime,
    duration: duration,
    numberOfGuests: 2, // Default
    filters: const domain.SearchFilters(availableOnly: true),
  );

  return result.fold(
    (failure) => throw Exception(failure.message),
    (results) => results,
  );
}

@riverpod
Future<List<ChefSearchResult>> quickSearchByCuisine(
  QuickSearchByCuisineRef ref,
  String cuisine,
) async {
  final service = await ref.watch(chefSearchServiceProvider.future);
  
  final filters = domain.SearchFilters(
    cuisineTypes: [cuisine],
    availableOnly: true,
    sortBy: 'rating',
  );
  
  final result = await service.searchAvailableChefs(filters: filters);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (results) => results,
  );
}

// Computed providers
@riverpod
bool hasActiveSearch(HasActiveSearchRef ref) {
  final filters = ref.watch(searchFiltersProvider);
  return filters.hasFilters;
}

@riverpod
String searchSummary(SearchSummaryRef ref) {
  final filters = ref.watch(searchFiltersProvider);
  
  if (!filters.hasFilters) return 'All chefs';
  
  final List<String> parts = [];
  
  if (filters.date != null) {
    final date = filters.date!;
    final today = DateTime.now();
    if (date.day == today.day && date.month == today.month && date.year == today.year) {
      parts.add('Today');
    } else {
      parts.add('${date.day}/${date.month}');
    }
  }
  
  if (filters.startTime != null) {
    parts.add('at ${filters.startTime}');
  }
  
  if (filters.cuisineTypes?.isNotEmpty == true) {
    parts.add(filters.cuisineTypes!.first);
  }
  
  if (filters.availableOnly) {
    parts.add('Available');
  }
  
  if (parts.isEmpty) return 'Filtered results';
  
  return parts.join(' • ');
}