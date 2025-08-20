import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homechef/models/chef.dart';
import 'package:homechef/data/repositories/chef_repository.dart';

// Supabase client provider
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Chef repository provider
final chefRepositoryProvider = Provider<ChefRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return ChefRepository(supabaseClient: supabaseClient);
});

// All chefs provider
final chefsProvider = FutureProvider<List<Chef>>((ref) async {
  final repository = ref.watch(chefRepositoryProvider);
  return repository.getChefs();
});

// Featured chefs provider
final featuredChefsProvider = FutureProvider<List<Chef>>((ref) async {
  final repository = ref.watch(chefRepositoryProvider);
  return repository.getFeaturedChefs();
});

// Available chefs provider
final availableChefsProvider = FutureProvider<List<Chef>>((ref) async {
  final repository = ref.watch(chefRepositoryProvider);
  return repository.getAvailableChefs();
});

// Popular chefs provider
final popularChefsProvider = FutureProvider<List<Chef>>((ref) async {
  final repository = ref.watch(chefRepositoryProvider);
  return repository.getPopularChefs();
});

// Single chef provider
final chefByIdProvider = FutureProvider.family<Chef?, String>((ref, id) async {
  final repository = ref.watch(chefRepositoryProvider);
  return repository.getChefById(id);
});

// Filtered chefs by cuisine provider
final chefsByCuisineProvider = Provider.family<AsyncValue<List<Chef>>, String?>((ref, cuisine) {
  final chefsAsync = ref.watch(chefsProvider);
  
  return chefsAsync.when(
    data: (chefs) {
      if (cuisine == null) return AsyncValue.data(chefs);
      final filtered = chefs.where((chef) => 
        chef.cuisineTypes.any((c) => c.toLowerCase() == cuisine.toLowerCase())
      ).toList();
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});