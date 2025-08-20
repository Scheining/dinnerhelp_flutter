import 'package:dartz/dartz.dart';
import 'package:homechef/core/error/failures.dart';
import 'package:homechef/models/chef.dart';
import '../entities/search_filters.dart';

abstract class ChefSearchRepository {
  /// Get all chefs
  Future<Either<Failure, List<Chef>>> getAllChefs();
  
  /// Get chefs that are currently available
  Future<Either<Failure, List<Chef>>> getAvailableChefs();
  
  /// Get chefs available today
  Future<Either<Failure, List<Chef>>> getChefsAvailableToday();
  
  /// Get chefs available this week
  Future<Either<Failure, List<Chef>>> getChefsAvailableThisWeek();
  
  /// Get top rated available chefs
  Future<Either<Failure, List<Chef>>> getTopRatedAvailableChefs();
  
  /// Search chefs with text query
  Future<Either<Failure, List<Chef>>> searchChefs(String query);
  
  /// Get chefs by specific filters
  Future<Either<Failure, List<Chef>>> getChefsByFilters(SearchFilters filters);
  
  /// Save search filters for user
  Future<Either<Failure, void>> saveSearchHistory(SearchFilters filters);
  
  /// Get user's recent searches
  Future<Either<Failure, List<SearchFilters>>> getRecentSearches();
  
  /// Clear search history
  Future<Either<Failure, void>> clearSearchHistory();
}