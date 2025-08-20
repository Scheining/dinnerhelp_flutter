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

  Future<List<Chef>> getChefs() async {
    try {
      // First fetch chefs
      final chefsResponse = await _supabaseClient
          .from('chefs')
          .select('*')
          .eq('approved', true)
          .eq('is_active', true);
      
      // Then fetch profiles separately
      final List<dynamic> response = [];
      for (final chef in chefsResponse) {
        final profileResponse = await _supabaseClient
            .from('profiles')
            .select('first_name, last_name, email')
            .eq('id', chef['id'])
            .maybeSingle();
        
        final chefWithProfile = {...chef};
        chefWithProfile['profiles'] = profileResponse;
        response.add(chefWithProfile);
      }

      final List<dynamic> chefsData = response as List<dynamic>;
      final List<Chef> chefs = [];

      for (final chefData in chefsData) {
        // Get ratings for this chef
        final ratingsResponse = await _supabaseClient
            .from('chef_ratings')
            .select('rating')
            .eq('chef_id', chefData['id'])
            .eq('status', 'approved');

        double averageRating = 0.0;
        int reviewCount = 0;

        if (ratingsResponse != null && ratingsResponse is List) {
          reviewCount = ratingsResponse.length;
          if (reviewCount > 0) {
            final totalRating = ratingsResponse
                .map((r) => r['rating'] as int)
                .reduce((a, b) => a + b);
            averageRating = totalRating / reviewCount;
          }
        }

        // Get location from postal code with city name
        String location = PostalCodeMapper.formatLocation(chefData['postal_code']);

        chefs.add(Chef(
          id: chefData['id'],
          name: _getChefName(chefData),
          profileImage: chefData['profile_image_url'] ?? '',
          headerImage: chefData['profile_background_url'] ?? '',
          rating: averageRating,
          reviewCount: reviewCount,
          cuisineTypes: List<String>.from(chefData['cuisines'] ?? []),
          hourlyRate: (chefData['price_per_hour'] ?? chefData['hourly_rate'] ?? 0).toDouble(),
          location: location,
          bio: chefData['bio'] ?? chefData['about'] ?? '',
          experienceYears: chefData['years_experience'] ?? 0,
          languages: List<String>.from(chefData['languages'] ?? []),
          dietarySpecialties: List<String>.from(chefData['dietary_specialties'] ?? []),
          isVerified: chefData['certified_chef'] ?? false,
          isAvailable: chefData['is_active'] ?? false,
          distanceKm: 0.0, // Will be calculated based on user location
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
    chefs.sort((a, b) => b.rating.compareTo(a.rating));
    return chefs.take(10).toList();
  }

  Future<List<Chef>> getAvailableChefs() async {
    // Already filtered by is_active in getChefs()
    return getChefs();
  }

  Future<List<Chef>> getPopularChefs() async {
    // Get chefs with rating >= 4.8
    final chefs = await getChefs();
    return chefs.where((chef) => chef.rating >= 4.8).toList();
  }

  Future<Chef?> getChefById(String id) async {
    try {
      final chefResponse = await _supabaseClient
          .from('chefs')
          .select('*')
          .eq('id', id)
          .single();
          
      final profileResponse = await _supabaseClient
          .from('profiles')
          .select('first_name, last_name, email')
          .eq('id', id)
          .maybeSingle();
          
      final response = {...chefResponse};
      response['profiles'] = profileResponse;

      if (response == null) return null;

      // Get ratings
      final ratingsResponse = await _supabaseClient
          .from('chef_ratings')
          .select('rating')
          .eq('chef_id', id)
          .eq('status', 'approved');

      double averageRating = 0.0;
      int reviewCount = 0;

      if (ratingsResponse != null && ratingsResponse is List) {
        reviewCount = ratingsResponse.length;
        if (reviewCount > 0) {
          final totalRating = ratingsResponse
              .map((r) => r['rating'] as int)
              .reduce((a, b) => a + b);
          averageRating = totalRating / reviewCount;
        }
      }

      // Get location from postal code with city name
      String location = PostalCodeMapper.formatLocation(response['postal_code']);

      return Chef(
        id: response['id'],
        name: _getChefName(response),
        profileImage: response['profile_image_url'] ?? '',
        headerImage: response['profile_background_url'] ?? '',
        rating: averageRating,
        reviewCount: reviewCount,
        cuisineTypes: List<String>.from(response['cuisines'] ?? []),
        hourlyRate: (response['price_per_hour'] ?? response['hourly_rate'] ?? 0).toDouble(),
        location: location,
        bio: response['bio'] ?? response['about'] ?? '',
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