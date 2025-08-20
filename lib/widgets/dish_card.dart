import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homechef/models/dish.dart';
import 'package:homechef/providers/dish_provider.dart';
import 'package:homechef/providers/auth_provider.dart';

class DishCard extends ConsumerWidget {
  final Dish dish;
  final VoidCallback? onTap;

  const DishCard({
    super.key,
    required this.dish,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(currentUserProvider).value;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with favorite button
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: dish.imageUrl != null
                      ? Image.network(
                          dish.imageUrl!,
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              height: 160,
                              color: Colors.grey.shade200,
                              child: Icon(
                                Icons.restaurant,
                                size: 40,
                                color: Colors.grey.shade400,
                              ),
                            );
                          },
                        )
                      : Container(
                          width: double.infinity,
                          height: 160,
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.restaurant,
                            size: 40,
                            color: Colors.grey.shade400,
                          ),
                        ),
                ),
                // Favorite button
                if (currentUser != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          dish.isFavorited ? Icons.favorite : Icons.favorite_border,
                          color: dish.isFavorited ? Colors.red : Colors.grey.shade600,
                          size: 20,
                        ),
                        onPressed: () async {
                          try {
                            await ref.read(toggleDishFavoriteProvider)(dish.id);
                            // Refresh the providers
                            ref.invalidate(newestDishesProvider);
                            ref.invalidate(popularDishesProvider);
                            ref.invalidate(mostOrderedDishesProvider);
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Kunne ikke opdatere favorit: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ),
                // Preparation time badge
                if (dish.preparationTime > 0)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.schedule,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${dish.preparationTime} min',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    dish.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Description
                  Text(
                    dish.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Chef name
                  if (dish.chefName != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            dish.chefName!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  // Dietary info badges
                  if (dish.dietaryInfo.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: dish.dietaryInfo.take(3).map((info) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getDietaryColor(info).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getDietaryColor(info).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            info,
                            style: TextStyle(
                              color: _getDietaryColor(info),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  // Stats row
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (dish.favoriteCount != null && dish.favoriteCount! > 0) ...[
                        Icon(
                          Icons.favorite,
                          size: 14,
                          color: Colors.red.shade400,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${dish.favoriteCount}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (dish.orderCount != null && dish.orderCount! > 0) ...[
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 14,
                          color: Colors.blue.shade400,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${dish.orderCount} bestilt',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDietaryColor(String dietary) {
    switch (dietary.toLowerCase()) {
      case 'vegetarisk':
      case 'vegetarian':
        return Colors.green;
      case 'vegansk':
      case 'vegan':
        return Colors.green.shade700;
      case 'glutenfri':
      case 'gluten-free':
        return Colors.orange;
      case 'laktosefri':
      case 'lactose-free':
        return Colors.blue;
      case 'keto':
        return Colors.purple;
      case 'paleo':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }
}