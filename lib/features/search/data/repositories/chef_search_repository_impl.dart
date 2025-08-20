import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:homechef/core/error/failures.dart';
import 'package:homechef/models/chef.dart';
import 'package:homechef/data/repositories/chef_repository.dart';
import '../../domain/entities/search_filters.dart';
import '../../domain/repositories/chef_search_repository.dart';

class ChefSearchRepositoryImpl implements ChefSearchRepository {
  final ChefRepository _chefRepository;
  final SharedPreferences _prefs;
  
  static const String _recentSearchesKey = 'recent_searches';
  static const int _maxRecentSearches = 10;

  ChefSearchRepositoryImpl(this._chefRepository, this._prefs);

  @override
  Future<Either<Failure, List<Chef>>> getAllChefs() async {
    try {
      final chefs = await _chefRepository.getChefs();
      return Right(chefs);
    } catch (e) {
      return Left(ServerFailure('Failed to get chefs: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Chef>>> getAvailableChefs() async {
    try {
      final chefs = await _chefRepository.getAvailableChefs();
      return Right(chefs);
    } catch (e) {
      return Left(ServerFailure('Failed to get available chefs: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Chef>>> getChefsAvailableToday() async {
    try {
      // For now, return available chefs
      // In a real implementation, this would check actual availability for today
      final chefs = await _chefRepository.getAvailableChefs();
      
      // Filter to only include chefs that are actually available today
      // This is a simplified implementation
      final availableToday = chefs.where((chef) => chef.isAvailable).toList();
      
      return Right(availableToday);
    } catch (e) {
      return Left(ServerFailure('Failed to get chefs available today: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Chef>>> getChefsAvailableThisWeek() async {
    try {
      // For now, return available chefs
      // In a real implementation, this would check availability for the next 7 days
      final chefs = await _chefRepository.getAvailableChefs();
      return Right(chefs);
    } catch (e) {
      return Left(ServerFailure('Failed to get chefs available this week: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Chef>>> getTopRatedAvailableChefs() async {
    try {
      final chefs = await _chefRepository.getAvailableChefs();
      
      // Filter by high rating and sort
      final topRated = chefs
          .where((chef) => chef.rating >= 4.5 && chef.isAvailable)
          .toList();
      
      topRated.sort((a, b) => b.rating.compareTo(a.rating));
      
      return Right(topRated);
    } catch (e) {
      return Left(ServerFailure('Failed to get top rated available chefs: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Chef>>> searchChefs(String query) async {
    try {
      final chefs = await _chefRepository.getChefs();
      final queryLower = query.toLowerCase();
      
      final filtered = chefs.where((chef) {
        return chef.name.toLowerCase().contains(queryLower) ||
               chef.cuisineTypes.any((c) => c.toLowerCase().contains(queryLower)) ||
               chef.location.toLowerCase().contains(queryLower) ||
               chef.bio.toLowerCase().contains(queryLower) ||
               chef.dietarySpecialties.any((d) => d.toLowerCase().contains(queryLower));
      }).toList();
      
      return Right(filtered);
    } catch (e) {
      return Left(ServerFailure('Failed to search chefs: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Chef>>> getChefsByFilters(SearchFilters filters) async {
    try {
      final chefs = await _chefRepository.getChefs();
      
      List<Chef> filtered = chefs;
      
      // Apply text search
      if (filters.searchText?.isNotEmpty == true) {
        final query = filters.searchText!.toLowerCase();
        filtered = filtered.where((chef) {
          return chef.name.toLowerCase().contains(query) ||
                 chef.cuisineTypes.any((c) => c.toLowerCase().contains(query)) ||
                 chef.location.toLowerCase().contains(query) ||
                 chef.bio.toLowerCase().contains(query);
        }).toList();
      }
      
      // Apply cuisine filter
      if (filters.cuisineTypes?.isNotEmpty == true) {
        filtered = filtered.where((chef) {
          return chef.cuisineTypes.any((cuisine) => 
            filters.cuisineTypes!.any((filter) => 
              cuisine.toLowerCase().contains(filter.toLowerCase())
            )
          );
        }).toList();
      }
      
      // Apply dietary specialties filter
      if (filters.dietarySpecialties?.isNotEmpty == true) {
        filtered = filtered.where((chef) {
          return chef.dietarySpecialties.any((specialty) => 
            filters.dietarySpecialties!.any((filter) => 
              specialty.toLowerCase().contains(filter.toLowerCase())
            )
          );
        }).toList();
      }
      
      // Apply price range filter
      if (filters.minPrice != null) {
        filtered = filtered.where((chef) => chef.hourlyRate >= filters.minPrice!).toList();
      }
      if (filters.maxPrice != null) {
        filtered = filtered.where((chef) => chef.hourlyRate <= filters.maxPrice!).toList();
      }
      
      // Apply rating filter
      if (filters.minRating != null) {
        filtered = filtered.where((chef) => chef.rating >= filters.minRating!).toList();
      }
      
      // Apply availability filter
      if (filters.availableOnly) {
        filtered = filtered.where((chef) => chef.isAvailable).toList();
      }
      
      // Apply verified filter
      if (filters.verifiedOnly) {
        filtered = filtered.where((chef) => chef.isVerified).toList();
      }
      
      // Apply distance filter (if location data available)
      if (filters.maxDistanceKm != null) {
        filtered = filtered.where((chef) => chef.distanceKm <= filters.maxDistanceKm!).toList();
      }
      
      // Apply sorting
      switch (filters.sortBy) {
        case 'rating':
          filtered.sort((a, b) => filters.sortAscending 
              ? a.rating.compareTo(b.rating) 
              : b.rating.compareTo(a.rating));
          break;
        case 'distance':
          filtered.sort((a, b) => filters.sortAscending 
              ? a.distanceKm.compareTo(b.distanceKm) 
              : b.distanceKm.compareTo(a.distanceKm));
          break;
        case 'price':
          filtered.sort((a, b) => filters.sortAscending 
              ? a.hourlyRate.compareTo(b.hourlyRate) 
              : b.hourlyRate.compareTo(a.hourlyRate));
          break;
        default:
          filtered.sort((a, b) => b.rating.compareTo(a.rating));
      }
      
      return Right(filtered);
    } catch (e) {
      return Left(ServerFailure('Failed to get chefs by filters: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveSearchHistory(SearchFilters filters) async {
    try {
      // Only save meaningful searches
      if (!filters.hasFilters) {
        return const Right(null);
      }
      
      final recentSearches = await getRecentSearches();
      final searches = recentSearches.fold((l) => <SearchFilters>[], (r) => r);
      
      // Remove duplicate if exists
      searches.removeWhere((search) => _areFiltersEqual(search, filters));
      
      // Add new search at beginning
      searches.insert(0, filters);
      
      // Keep only recent searches
      if (searches.length > _maxRecentSearches) {
        searches.removeRange(_maxRecentSearches, searches.length);
      }
      
      // Save to preferences
      final searchesJson = searches.map((s) => _filtersToJson(s)).toList();
      await _prefs.setString(_recentSearchesKey, jsonEncode(searchesJson));
      
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to save search history: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SearchFilters>>> getRecentSearches() async {
    try {
      final searchesJson = _prefs.getString(_recentSearchesKey);
      if (searchesJson == null) {
        return const Right([]);
      }
      
      final List<dynamic> decoded = jsonDecode(searchesJson);
      final searches = decoded.map((json) => _filtersFromJson(json)).toList();
      
      return Right(searches);
    } catch (e) {
      return Left(CacheFailure('Failed to get recent searches: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearSearchHistory() async {
    try {
      await _prefs.remove(_recentSearchesKey);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to clear search history: $e'));
    }
  }

  // Helper methods for serialization
  Map<String, dynamic> _filtersToJson(SearchFilters filters) {
    return {
      'date': filters.date?.toIso8601String(),
      'startTime': filters.startTime,
      'duration': filters.duration?.inMinutes,
      'numberOfGuests': filters.numberOfGuests,
      'searchText': filters.searchText,
      'cuisineTypes': filters.cuisineTypes,
      'dietarySpecialties': filters.dietarySpecialties,
      'minPrice': filters.minPrice,
      'maxPrice': filters.maxPrice,
      'minRating': filters.minRating,
      'availableOnly': filters.availableOnly,
      'verifiedOnly': filters.verifiedOnly,
      'postalCode': filters.postalCode,
      'maxDistanceKm': filters.maxDistanceKm,
      'sortBy': filters.sortBy,
      'sortAscending': filters.sortAscending,
    };
  }

  SearchFilters _filtersFromJson(Map<String, dynamic> json) {
    return SearchFilters(
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      startTime: json['startTime'],
      duration: json['duration'] != null ? Duration(minutes: json['duration']) : null,
      numberOfGuests: json['numberOfGuests'],
      searchText: json['searchText'],
      cuisineTypes: json['cuisineTypes'] != null ? List<String>.from(json['cuisineTypes']) : null,
      dietarySpecialties: json['dietarySpecialties'] != null ? List<String>.from(json['dietarySpecialties']) : null,
      minPrice: json['minPrice'],
      maxPrice: json['maxPrice'],
      minRating: json['minRating'],
      availableOnly: json['availableOnly'] ?? false,
      verifiedOnly: json['verifiedOnly'] ?? false,
      postalCode: json['postalCode'],
      maxDistanceKm: json['maxDistanceKm'],
      sortBy: json['sortBy'] ?? 'rating',
      sortAscending: json['sortAscending'] ?? false,
    );
  }

  bool _areFiltersEqual(SearchFilters a, SearchFilters b) {
    return a.date == b.date &&
           a.startTime == b.startTime &&
           a.duration == b.duration &&
           a.numberOfGuests == b.numberOfGuests &&
           a.searchText == b.searchText &&
           _listEquals(a.cuisineTypes, b.cuisineTypes) &&
           _listEquals(a.dietarySpecialties, b.dietarySpecialties) &&
           a.minPrice == b.minPrice &&
           a.maxPrice == b.maxPrice &&
           a.minRating == b.minRating &&
           a.availableOnly == b.availableOnly &&
           a.verifiedOnly == b.verifiedOnly;
  }

  bool _listEquals(List<String>? a, List<String>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}