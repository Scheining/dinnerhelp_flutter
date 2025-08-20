import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_filters.freezed.dart';

@freezed
class SearchFilters with _$SearchFilters {
  const factory SearchFilters({
    // Date and time filters
    DateTime? date,
    String? startTime,
    Duration? duration,
    int? numberOfGuests,
    
    // Text search
    String? searchText,
    
    // Category filters
    List<String>? cuisineTypes,
    List<String>? dietarySpecialties,
    
    // Price filters
    double? minPrice,
    double? maxPrice,
    
    // Rating filter
    double? minRating,
    
    // Availability filters
    @Default(false) bool availableOnly,
    @Default(false) bool verifiedOnly,
    
    // Location filters
    String? postalCode,
    double? maxDistanceKm,
    
    // Sorting
    @Default('rating') String sortBy, // 'rating', 'distance', 'price', 'availability'
    @Default(false) bool sortAscending,
  }) = _SearchFilters;
  
  const SearchFilters._();
  
  /// Check if any filters are applied
  bool get hasFilters => 
    date != null ||
    startTime != null ||
    duration != null ||
    numberOfGuests != null ||
    (searchText?.isNotEmpty ?? false) ||
    (cuisineTypes?.isNotEmpty ?? false) ||
    (dietarySpecialties?.isNotEmpty ?? false) ||
    minPrice != null ||
    maxPrice != null ||
    minRating != null ||
    availableOnly ||
    verifiedOnly ||
    postalCode != null ||
    maxDistanceKm != null;
    
  /// Check if availability-related filters are applied
  bool get hasAvailabilityFilters =>
    date != null ||
    startTime != null ||
    duration != null ||
    numberOfGuests != null;
}