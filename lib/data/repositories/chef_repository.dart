import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homechef/models/chef.dart';
import 'package:homechef/core/utils/postal_code_mapper.dart';

class ChefRepository {
  final SupabaseClient _supabaseClient;

  ChefRepository({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;
      
  String _getChefName(Map<String, dynamic> chefData) {
    final firstName = chefData['profiles']?['first_name'] ?? '';
    final lastName = chefData['profiles']?['last_name'] ?? '';
    final fullName = '$firstName $lastName'.trim();
    
    // If no name from profiles, try to use title or return a default
    if (fullName.isEmpty) {
      return chefData['title'] ?? 'Chef ${chefData['id'].toString().substring(0, 8)}';
    }
    return fullName;
  }

  Future<List<Chef>> getChefs({int limit = 50, int offset = 0}) async {
    try {
      // Single optimized query using the view
      final response = await _supabaseClient
          .from('chef_listings')
          .select('*')
          .order('avg_rating', ascending: false)
          .range(offset, offset + limit - 1);

      final List<Chef> chefs = [];
      
      for (final chefData in response) {
        // Build chef name from profile data
        final firstName = chefData['first_name'] ?? '';
        final lastName = chefData['last_name'] ?? '';
        final fullName = '$firstName $lastName'.trim();
        final name = fullName.isEmpty ? (chefData['title'] ?? 'Chef') : fullName;
        
        // Get location from postal code
        String location = PostalCodeMapper.formatLocation(chefData['postal_code']);

        chefs.add(Chef(
          id: chefData['id'],
          name: name,
          profileImage: chefData['profile_image_url'] ?? '',
          headerImage: chefData['profile_background_url'] ?? '',
          rating: (chefData['avg_rating'] ?? 0).toDouble(),
          reviewCount: chefData['review_count'] ?? 0,
          cuisineTypes: List<String>.from(chefData['cuisines'] ?? []),
          hourlyRate: ((chefData['price_per_hour'] ?? chefData['hourly_rate'] ?? 0) * 1.25).toDouble(),
          location: location,
          bio: chefData['bio'] ?? '',
          experienceYears: chefData['years_experience'] ?? 0,
          languages: List<String>.from(chefData['languages'] ?? []),
          dietarySpecialties: List<String>.from(chefData['dietary_specialties'] ?? []),
          isVerified: chefData['certified_chef'] ?? false,
          isAvailable: chefData['is_active'] ?? false,
          distanceKm: 0.0,
        ));
      }

      return chefs;
    } catch (e) {
      print('Error fetching chefs: $e');
      rethrow;
    }
  }

  Future<List<Chef>> getFeaturedChefs() async {
    // Get chefs with high ratings
    final chefs = await getChefs();
    
    // Sort by rating
    chefs.sort((a, b) => b.rating.compareTo(a.rating));
    
    // If no chefs have ratings (all are 0), shuffle to show random chefs
    if (chefs.isEmpty || chefs.every((chef) => chef.rating == 0)) {
      chefs.shuffle();
      return chefs.take(10).toList();
    }
    
    // Return top rated chefs
    return chefs.take(10).toList();
  }

  Future<List<Chef>> getAvailableChefs() async {
    // Already filtered by is_active in getChefs()
    return getChefs();
  }

  Future<List<Chef>> getPopularChefs() async {
    // Get chefs with rating >= 4.8
    final chefs = await getChefs();
    final popularChefs = chefs.where((chef) => chef.rating >= 4.8).toList();
    
    // If no highly rated chefs, return random selection
    if (popularChefs.isEmpty) {
      final randomChefs = List<Chef>.from(chefs);
      randomChefs.shuffle();
      return randomChefs.take(8).toList();
    }
    
    return popularChefs;
  }

  Future<Chef?> getChefById(String id) async {
    try {
      // Use the optimized view for single chef query
      final response = await _supabaseClient
          .from('chef_listings')
          .select('*')
          .eq('id', id)
          .maybeSingle();
          
      if (response == null) return null;

      // Build chef name from profile data
      final firstName = response['first_name'] ?? '';
      final lastName = response['last_name'] ?? '';
      final fullName = '$firstName $lastName'.trim();
      final name = fullName.isEmpty ? (response['title'] ?? 'Chef') : fullName;
      
      // Get location from postal code with city name
      String location = PostalCodeMapper.formatLocation(response['postal_code']);

      return Chef(
        id: response['id'],
        name: name,
        profileImage: response['profile_image_url'] ?? '',
        headerImage: response['profile_background_url'] ?? '',
        rating: (response['avg_rating'] ?? 0).toDouble(),
        reviewCount: response['review_count'] ?? 0,
        cuisineTypes: List<String>.from(response['cuisines'] ?? []),
        hourlyRate: ((response['price_per_hour'] ?? response['hourly_rate'] ?? 0) * 1.25).toDouble(),
        location: location,
        bio: response['bio'] ?? '',
        experienceYears: response['years_experience'] ?? 0,
        languages: List<String>.from(response['languages'] ?? []),
        dietarySpecialties: List<String>.from(response['dietary_specialties'] ?? []),
        isVerified: response['certified_chef'] ?? false,
        isAvailable: response['is_active'] ?? false,
        distanceKm: 0.0,
      );
    } catch (e) {
      print('Error fetching chef by id: $e');
      rethrow;
    }
  }
}