import 'dart:async';
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

// All chefs provider with caching (30 minutes)
final chefsProvider = FutureProvider.autoDispose<List<Chef>>((ref) async {
  // Keep data alive for 30 minutes after last use
  ref.keepAlive();
  
  // Refresh every 30 minutes
  final timer = Timer(const Duration(minutes: 30), () {
    ref.invalidateSelf();
  });
  ref.onDispose(() => timer.cancel());
  
  final repository = ref.watch(chefRepositoryProvider);
  return repository.getChefs(limit: 50);  // Load first 50 chefs
});

// Featured chefs provider with caching
final featuredChefsProvider = FutureProvider.autoDispose<List<Chef>>((ref) async {
  ref.keepAlive();
  
  final timer = Timer(const Duration(minutes: 30), () {
    ref.invalidateSelf();
  });
  ref.onDispose(() => timer.cancel());
  
  final repository = ref.watch(chefRepositoryProvider);
  return repository.getFeaturedChefs();
});

// Available chefs provider with caching
final availableChefsProvider = FutureProvider.autoDispose<List<Chef>>((ref) async {
  ref.keepAlive();
  
  final timer = Timer(const Duration(minutes: 30), () {
    ref.invalidateSelf();
  });
  ref.onDispose(() => timer.cancel());
  
  final repository = ref.watch(chefRepositoryProvider);
  return repository.getAvailableChefs();
});

// Popular chefs provider with caching
final popularChefsProvider = FutureProvider.autoDispose<List<Chef>>((ref) async {
  ref.keepAlive();
  
  final timer = Timer(const Duration(minutes: 30), () {
    ref.invalidateSelf();
  });
  ref.onDispose(() => timer.cancel());
  
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