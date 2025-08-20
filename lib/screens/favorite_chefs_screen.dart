import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homechef/providers/favorites_provider.dart';
import 'package:homechef/models/chef.dart';
import 'package:homechef/screens/chef_profile_screen.dart';
import 'package:homechef/core/utils/postal_code_mapper.dart';

class FavoriteChefsScreen extends ConsumerWidget {
  const FavoriteChefsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final favoriteChefs = ref.watch(favoriteChefListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favorit kokke',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: favoriteChefs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text('Fejl ved indlæsning af favoritter', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(error.toString(), style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        data: (favorites) {
          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_outline,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ingen favorit kokke endnu',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start med at tilføje nogle kokke til dine favoritter',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final favorite = favorites[index];
              final chefData = favorite['chefs'] as Map<String, dynamic>;
              final profileData = chefData['profiles'] as Map<String, dynamic>?;
              
              final chefName = profileData != null 
                  ? '${profileData['first_name'] ?? ''} ${profileData['last_name'] ?? ''}'.trim()
                  : 'Ukendt kok';
              
              final chefId = chefData['id'] ?? '';
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: chefData['profile_image_url'] != null
                          ? Image.network(
                              chefData['profile_image_url'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: theme.colorScheme.primaryContainer,
                                child: Icon(
                                  Icons.person,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            )
                          : Container(
                              color: theme.colorScheme.primaryContainer,
                              child: Icon(
                                Icons.person,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                    ),
                  ),
                  title: Text(
                    chefName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        chefData['title'] ?? 'Professionel kok',
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        children: [
                          if (PostalCodeMapper.formatLocation(chefData['postal_code']).isNotEmpty)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text(
                                  PostalCodeMapper.formatLocation(chefData['postal_code']),
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${chefData['price_per_hour'] ?? 0} kr/time',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () async {
                      // Show confirmation dialog
                      final shouldRemove = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Fjern fra favoritter'),
                          content: Text('Vil du fjerne $chefName fra dine favoritter?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Annuller'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text(
                                'Fjern',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                      
                      if (shouldRemove == true) {
                        await ref.read(favoritesChefsProvider.notifier).toggleFavorite(chefId);
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$chefName fjernet fra favoritter'),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
                  ),
                  onTap: () {
                    // Create a Chef object from the data
                    final chef = Chef(
                      id: chefId,
                      name: chefName,
                      profileImage: chefData['profile_image_url'] ?? '',
                      headerImage: chefData['profile_image_url'] ?? '',
                      bio: chefData['title'] ?? '',
                      cuisineTypes: List<String>.from(chefData['cuisines'] ?? []),
                      languages: List<String>.from(chefData['languages'] ?? []),
                      dietarySpecialties: List<String>.from(chefData['dietary_specialties'] ?? []),
                      location: PostalCodeMapper.formatLocation(chefData['postal_code']),
                      distanceKm: 0,
                      rating: 0,
                      reviewCount: 0,
                      hourlyRate: (chefData['price_per_hour'] ?? 0).toDouble(),
                      experienceYears: chefData['years_experience'] ?? 0,
                      isAvailable: true,
                      isVerified: chefData['approved'] ?? false,
                    );
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChefProfileScreen(chef: chef),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}