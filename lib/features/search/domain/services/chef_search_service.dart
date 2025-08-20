import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import 'package:homechef/core/error/failures.dart';
import 'package:homechef/models/chef.dart';
import 'package:homechef/models/location_data.dart';
import '../../../booking/domain/services/booking_availability_service.dart';
import '../entities/search_filters.dart';
import '../entities/chef_search_result.dart';
import '../repositories/chef_search_repository.dart';

/// Service for searching and discovering chefs with availability checking
class ChefSearchService {
  final ChefSearchRepository _repository;
  final BookingAvailabilityService _availabilityService;

  const ChefSearchService(
    this._repository,
    this._availabilityService,
  );

  /// Search for available chefs based on criteria
  Future<Either<Failure, List<ChefSearchResult>>> searchAvailableChefs({
    DateTime? date,
    String? startTime,
    Duration? duration,
    int? numberOfGuests,
    SearchFilters? filters,
  }) async {
    try {
      // Get all chefs first
      final chefsResult = await _repository.getAllChefs();
      if (chefsResult.isLeft()) return chefsResult.fold((l) => Left(l), (r) => throw UnimplementedError());
      
      final chefs = chefsResult.fold((l) => throw UnimplementedError(), (r) => r);
      
      // Apply basic filters first
      List<Chef> filteredChefs = chefs;
      
      if (filters != null) {
        filteredChefs = await _applyBasicFilters(filteredChefs, filters);
      }
      
      // Check availability for each chef if date/time specified
      final List<ChefSearchResult> results = [];
      
      for (final chef in filteredChefs) {
        ChefSearchResult result;
        
        if (date != null && startTime != null && duration != null) {
          // Check specific availability
          result = await _checkChefAvailability(chef, date, startTime, duration, numberOfGuests);
        } else {
          // General availability
          result = ChefSearchResult(
            chef: chef,
            isAvailable: chef.isAvailable,
            distance: null, // Distance would be calculated based on location
          );
        }
        
        results.add(result);
      }
      
      // Filter by availability if required
      List<ChefSearchResult> finalResults = results;
      if (filters?.availableOnly == true) {
        finalResults = results.where((r) => r.isAvailable).toList();
      }
      
      // Apply sorting
      final sortBy = filters?.sortBy ?? 'rating';
      finalResults = _sortResults(finalResults, sortBy, filters?.sortAscending ?? false);
      
      return Right(finalResults);
    } catch (e) {
      return Left(ServerFailure('Failed to search chefs: $e'));
    }
  }

  /// Get available chefs for home screen sections
  Future<Either<Failure, List<ChefSearchResult>>> getAvailableChefsForHome({
    int limit = 10,
    LocationData? userLocation,
  }) async {
    try {
      final chefsResult = await _repository.getAvailableChefs();
      if (chefsResult.isLeft()) return chefsResult.fold((l) => Left(l), (r) => throw UnimplementedError());
      
      var chefs = chefsResult.fold((l) => throw UnimplementedError(), (r) => r);
      
      // Sort by distance if location available, otherwise by rating
      if (userLocation != null) {
        chefs = await sortByDistance(chefs, userLocation);
      } else {
        chefs.sort((a, b) => b.rating.compareTo(a.rating));
      }
      
      // Take limited results
      chefs = chefs.take(limit).toList();
      
      // Convert to search results
      final results = chefs.map((chef) => ChefSearchResult(
        chef: chef,
        isAvailable: chef.isAvailable,
        distance: null, // Distance would be calculated based on location
      )).toList();
      
      return Right(results);
    } catch (e) {
      return Left(ServerFailure('Failed to get available chefs: $e'));
    }
  }

  /// Filter chefs by availability for a specific date/time
  Future<Either<Failure, List<ChefSearchResult>>> filterByAvailability(
    List<Chef> chefs,
    DateTime date,
    String startTime,
    Duration duration,
  ) async {
    try {
      final List<ChefSearchResult> results = [];
      
      for (final chef in chefs) {
        final result = await _checkChefAvailability(chef, date, startTime, duration, null);
        results.add(result);
      }
      
      return Right(results);
    } catch (e) {
      return Left(ServerFailure('Failed to filter by availability: $e'));
    }
  }

  /// Sort chefs by distance from user location
  Future<List<Chef>> sortByDistance(List<Chef> chefs, LocationData userLocation) async {
    try {
      // Calculate distances
      final List<Chef> chefsWithDistance = [];
      
      for (final chef in chefs) {
        double distance = 0.0;
        
        // Try to calculate distance based on postal code or location
        try {
          // This is a simplified distance calculation
          // In a real app, you'd geocode the chef's postal code and calculate proper distance
          final chefPostalCode = chef.location;
          if (chefPostalCode.isNotEmpty && userLocation.position != null) {
            // For now, use existing distance or calculate a mock distance
            distance = chef.distanceKm;
            if (distance == 0.0) {
              // Mock distance calculation based on postal code similarity
              distance = _mockDistanceCalculation(userLocation.address ?? '', chefPostalCode);
            }
          }
        } catch (e) {
          // Use existing distance or default
          distance = chef.distanceKm;
        }
        
        // Create chef with updated distance
        final updatedChef = Chef(
          id: chef.id,
          name: chef.name,
          profileImage: chef.profileImage,
          headerImage: chef.headerImage,
          rating: chef.rating,
          reviewCount: chef.reviewCount,
          cuisineTypes: chef.cuisineTypes,
          hourlyRate: chef.hourlyRate,
          location: chef.location,
          bio: chef.bio,
          experienceYears: chef.experienceYears,
          languages: chef.languages,
          dietarySpecialties: chef.dietarySpecialties,
          isVerified: chef.isVerified,
          isAvailable: chef.isAvailable,
          distanceKm: distance ?? 0.0,
        );
        
        chefsWithDistance.add(updatedChef);
      }
      
      // Sort by distance
      chefsWithDistance.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      return chefsWithDistance;
    } catch (e) {
      // Return original list if distance calculation fails
      return chefs;
    }
  }

  /// Filter chefs by cuisine types
  List<Chef> filterByCuisine(List<Chef> chefs, List<String> cuisineTypes) {
    if (cuisineTypes.isEmpty) return chefs;
    
    return chefs.where((chef) {
      return chef.cuisineTypes.any((cuisine) => 
        cuisineTypes.any((filter) => 
          cuisine.toLowerCase().contains(filter.toLowerCase())
        )
      );
    }).toList();
  }

  /// Filter chefs by price range
  List<Chef> filterByPriceRange(List<Chef> chefs, double? minPrice, double? maxPrice) {
    return chefs.where((chef) {
      if (minPrice != null && chef.hourlyRate < minPrice) return false;
      if (maxPrice != null && chef.hourlyRate > maxPrice) return false;
      return true;
    }).toList();
  }

  /// Filter chefs by minimum rating
  List<Chef> filterByRating(List<Chef> chefs, double minRating) {
    return chefs.where((chef) => chef.rating >= minRating).toList();
  }

  /// Filter chefs by dietary specialties
  List<Chef> filterByDietarySpecialties(List<Chef> chefs, List<String> dietaryTypes) {
    if (dietaryTypes.isEmpty) return chefs;
    
    return chefs.where((chef) {
      return chef.dietarySpecialties.any((specialty) => 
        dietaryTypes.any((filter) => 
          specialty.toLowerCase().contains(filter.toLowerCase())
        )
      );
    }).toList();
  }

  // Private helper methods

  Future<List<Chef>> _applyBasicFilters(List<Chef> chefs, SearchFilters filters) async {
    List<Chef> filtered = chefs;
    
    // Text search
    if (filters.searchText?.isNotEmpty == true) {
      final searchText = filters.searchText!.toLowerCase();
      filtered = filtered.where((chef) {
        return chef.name.toLowerCase().contains(searchText) ||
               chef.cuisineTypes.any((c) => c.toLowerCase().contains(searchText)) ||
               chef.location.toLowerCase().contains(searchText) ||
               chef.bio.toLowerCase().contains(searchText);
      }).toList();
    }
    
    // Cuisine filter
    if (filters.cuisineTypes?.isNotEmpty == true) {
      filtered = filterByCuisine(filtered, filters.cuisineTypes!);
    }
    
    // Dietary specialties filter
    if (filters.dietarySpecialties?.isNotEmpty == true) {
      filtered = filterByDietarySpecialties(filtered, filters.dietarySpecialties!);
    }
    
    // Price range filter
    filtered = filterByPriceRange(filtered, filters.minPrice, filters.maxPrice);
    
    // Rating filter
    if (filters.minRating != null) {
      filtered = filterByRating(filtered, filters.minRating!);
    }
    
    // Verified only filter
    if (filters.verifiedOnly) {
      filtered = filtered.where((chef) => chef.isVerified).toList();
    }
    
    return filtered;
  }

  Future<ChefSearchResult> _checkChefAvailability(
    Chef chef,
    DateTime date,
    String startTime,
    Duration duration,
    int? numberOfGuests,
  ) async {
    try {
      // Check if chef has basic availability
      if (!chef.isAvailable) {
        return ChefSearchResult(
          chef: chef,
          isAvailable: false,
          nextAvailableSlot: 'Chef is not currently accepting bookings',
          distance: null,
        );
      }
      
      // Check specific time slot availability
      final availabilityResult = await _availabilityService.getAvailableTimeSlots(
        chefId: chef.id,
        date: date,
        duration: duration,
        numberOfGuests: numberOfGuests ?? 2,
      );
      
      if (availabilityResult.isLeft()) {
        final failure = availabilityResult.fold((l) => l, (r) => throw UnimplementedError());
        return ChefSearchResult(
          chef: chef,
          isAvailable: false,
          nextAvailableSlot: failure.message,
          distance: null, // chef.distanceKm not available
        );
      }
      
      final timeSlots = availabilityResult.fold((l) => throw UnimplementedError(), (r) => r);
      
      // Check if requested time slot is available
      final requestedSlot = timeSlots.where((slot) {
        final slotTime = '${slot.startTime.hour.toString().padLeft(2, '0')}:${slot.startTime.minute.toString().padLeft(2, '0')}';
        return slotTime == startTime && slot.isAvailable;
      }).toList();
      
      if (requestedSlot.isEmpty) {
        // Find next available slot
        final nextSlot = timeSlots.where((slot) => slot.isAvailable).firstOrNull;
        String? nextAvailable;
        if (nextSlot != null) {
          nextAvailable = '${nextSlot.startTime.hour.toString().padLeft(2, '0')}:${nextSlot.startTime.minute.toString().padLeft(2, '0')}';
        }
        
        return ChefSearchResult(
          chef: chef,
          isAvailable: false,
          nextAvailableSlot: nextAvailable ?? 'Not available at requested time',
          distance: null, // chef.distanceKm not available
        );
      }
      
      // Get all available time slots for this date
      final availableSlots = timeSlots
          .where((slot) => slot.isAvailable)
          .map((slot) => '${slot.startTime.hour.toString().padLeft(2, '0')}:${slot.startTime.minute.toString().padLeft(2, '0')}')
          .toList();
      
      return ChefSearchResult(
        chef: chef,
        isAvailable: true,
        distance: null // chef.distanceKm not available,
      );
    } catch (e) {
      return ChefSearchResult(
        chef: chef,
        isAvailable: false,
        nextAvailableSlot: 'Unable to check availability',
        distance: null // chef.distanceKm not available,
      );
    }
  }

  List<ChefSearchResult> _sortResults(List<ChefSearchResult> results, String sortBy, bool ascending) {
    results.sort((a, b) {
      int comparison = 0;
      
      switch (sortBy) {
        case 'rating':
          comparison = a.chef.rating.compareTo(b.chef.rating);
          break;
        case 'distance':
          final aDistance = a.distance ?? double.infinity;
          final bDistance = b.distance ?? double.infinity;
          comparison = aDistance.compareTo(bDistance);
          break;
        case 'price':
          comparison = a.chef.hourlyRate.compareTo(b.chef.hourlyRate);
          break;
        case 'availability':
          // Available chefs first
          if (a.isAvailable && !b.isAvailable) return -1;
          if (!a.isAvailable && b.isAvailable) return 1;
          // Then by rating
          comparison = a.chef.rating.compareTo(b.chef.rating);
          break;
        default:
          comparison = a.chef.rating.compareTo(b.chef.rating);
      }
      
      return ascending ? comparison : -comparison;
    });
    
    return results;
  }

  double _mockDistanceCalculation(String userLocation, String chefLocation) {
    // Simple mock distance calculation based on string similarity
    // In a real app, you'd use proper geocoding and distance calculation
    final userLower = userLocation.toLowerCase();
    final chefLower = chefLocation.toLowerCase();
    
    if (userLower == chefLower) return 0.5;
    if (userLower.contains(chefLower) || chefLower.contains(userLower)) return 2.0;
    
    // Random distance between 1-15km for demo purposes
    return 1.0 + (chefLocation.hashCode % 140) / 10.0;
  }
}