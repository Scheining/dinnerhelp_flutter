import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homechef/models/dish.dart';
import 'package:homechef/providers/auth_provider.dart';

// Provider for newest dishes
final newestDishesProvider = FutureProvider<List<Dish>>((ref) async {
  final supabaseClient = ref.watch(supabaseClientProvider);
  final currentUser = ref.watch(currentUserProvider).value;
  
  try {
    // Get newest dishes with chef information
    final response = await supabaseClient
        .from('dishes')
        .select('''
          *,
          chefs(
            id,
            profiles(
              first_name,
              last_name
            )
          )
        ''')
        .eq('is_active', true)
        .order('created_at', ascending: false)
        .limit(10);

    final dishes = <Dish>[];
    
    for (final dishData in response as List) {
      // Get favorite status if user is logged in
      bool isFavorited = false;
      if (currentUser != null) {
        final favoriteResponse = await supabaseClient
            .from('user_favorite_dishes')
            .select()
            .eq('user_id', currentUser.id)
            .eq('dish_id', dishData['id'])
            .maybeSingle();
        
        isFavorited = favoriteResponse != null;
      }
      
      // Extract chef name
      String? chefName;
      if (dishData['chefs'] != null && dishData['chefs']['profiles'] != null) {
        final profile = dishData['chefs']['profiles'];
        chefName = '${profile['first_name']} ${profile['last_name']}';
      }
      
      dishes.add(Dish.fromJson({
        ...dishData,
        'chef_name': chefName,
        'is_favorited': isFavorited,
      }));
    }
    
    return dishes;
  } catch (e) {
    // Error fetching newest dishes: $e
    return [];
  }
});

// Provider for most popular (favorited) dishes
final popularDishesProvider = FutureProvider<List<Dish>>((ref) async {
  final supabaseClient = ref.watch(supabaseClientProvider);
  final currentUser = ref.watch(currentUserProvider).value;
  
  try {
    // Get dishes with favorite count using the database function
    final response = await supabaseClient.rpc('get_popular_dishes', params: {
      'limit_count': 10,
      'p_user_id': currentUser?.id,
    });
    
    return (response as List).map((json) => Dish.fromJson(json)).toList();
  } catch (e) {
    // Error fetching popular dishes: $e
    return [];
  }
});

// Provider for most ordered dishes
final mostOrderedDishesProvider = FutureProvider<List<Dish>>((ref) async {
  final supabaseClient = ref.watch(supabaseClientProvider);
  final currentUser = ref.watch(currentUserProvider).value;
  
  try {
    // Get dishes with order count using the database function
    final response = await supabaseClient.rpc('get_most_ordered_dishes', params: {
      'limit_count': 10,
      'p_user_id': currentUser?.id,
    });
    
    return (response as List).map((json) => Dish.fromJson(json)).toList();
  } catch (e) {
    // Error fetching most ordered dishes: $e
    return [];
  }
});

// Provider to toggle favorite status
final toggleDishFavoriteProvider = Provider((ref) {
  return (String dishId) async {
    final supabaseClient = ref.read(supabaseClientProvider);
    final currentUser = ref.read(currentUserProvider).value;
    
    if (currentUser == null) {
      throw Exception('User must be logged in to favorite dishes');
    }
    
    try {
      // Check if already favorited
      final existingFavorite = await supabaseClient
          .from('user_favorite_dishes')
          .select()
          .eq('user_id', currentUser.id)
          .eq('dish_id', dishId)
          .maybeSingle();
      
      if (existingFavorite != null) {
        // Remove favorite
        await supabaseClient
            .from('user_favorite_dishes')
            .delete()
            .eq('user_id', currentUser.id)
            .eq('dish_id', dishId);
        return false;
      } else {
        // Add favorite
        await supabaseClient
            .from('user_favorite_dishes')
            .insert({
              'user_id': currentUser.id,
              'dish_id': dishId,
            });
        return true;
      }
    } catch (e) {
      // Error toggling dish favorite: $e
      rethrow;
    }
  };
});