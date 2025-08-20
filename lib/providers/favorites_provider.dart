import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Provider to manage favorite chefs
final favoritesChefsProvider = StateNotifierProvider<FavoriteChefsNotifier, Set<String>>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return FavoriteChefsNotifier(supabase);
});

// Provider to check if a specific chef is favorited
final isChefFavoritedProvider = Provider.family<bool, String>((ref, chefId) {
  final favorites = ref.watch(favoritesChefsProvider);
  return favorites.contains(chefId);
});

// Provider to get list of favorite chef objects
final favoriteChefListProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final user = supabase.auth.currentUser;
  
  if (user == null) return [];
  
  // Watch the favorites state to trigger refresh
  ref.watch(favoritesChefsProvider);
  
  try {
    final response = await supabase
        .from('favorite_chefs')
        .select('''
          chef_id,
          chefs!inner (
            id,
            profile_image_url,
            title,
            postal_code,
            price_per_hour,
            cuisines,
            dietary_specialties,
            languages,
            years_experience,
            approved,
            profiles!inner (
              first_name,
              last_name
            )
          )
        ''')
        .eq('user_id', user.id);
    
    return List<Map<String, dynamic>>.from(response as List);
  } catch (e) {
    print('Error fetching favorite chefs: $e');
    return [];
  }
});

class FavoriteChefsNotifier extends StateNotifier<Set<String>> {
  final SupabaseClient _supabase;
  
  FavoriteChefsNotifier(this._supabase) : super({}) {
    _loadFavorites();
  }
  
  Future<void> _loadFavorites() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    
    try {
      final response = await _supabase
          .from('favorite_chefs')
          .select('chef_id')
          .eq('user_id', user.id);
      
      final favoriteIds = (response as List)
          .map((item) => item['chef_id'] as String)
          .toSet();
      
      state = favoriteIds;
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }
  
  Future<bool> toggleFavorite(String chefId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;
    
    try {
      if (state.contains(chefId)) {
        // Remove from favorites
        await _supabase
            .from('favorite_chefs')
            .delete()
            .eq('user_id', user.id)
            .eq('chef_id', chefId);
        
        state = {...state}..remove(chefId);
        return false; // Not favorited anymore
      } else {
        // Add to favorites
        await _supabase
            .from('favorite_chefs')
            .insert({
          'user_id': user.id,
          'chef_id': chefId,
        });
        
        state = {...state}..add(chefId);
        return true; // Now favorited
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      return state.contains(chefId);
    }
  }
  
  void refresh() {
    _loadFavorites();
  }
}