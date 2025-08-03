import 'package:flutter/material.dart';
import 'package:homechef/models/chef.dart';
import 'package:homechef/widgets/rating_stars.dart';
import 'package:homechef/widgets/custom_button.dart';
import 'package:homechef/screens/booking_screen.dart';
import 'package:homechef/screens/chat_screen.dart';

class ChefProfileScreen extends StatelessWidget {
  final Chef chef;

  const ChefProfileScreen({
    super.key,
    required this.chef,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: theme.colorScheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    chef.headerImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: theme.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.restaurant,
                        size: 80,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black38,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          chef.profileImage,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 80,
                            height: 80,
                            color: theme.colorScheme.primaryContainer,
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  chef.name,
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (chef.isVerified)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Icon(
                                      Icons.verified,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                RatingStars(rating: chef.rating),
                                const SizedBox(width: 8),
                                Text(
                                  '${chef.rating} (${chef.reviewCount} reviews)',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${chef.location} • ${chef.distanceKm.toStringAsFixed(1)} km away',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Cuisines
                  Text(
                    'Specialties',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: chef.cuisineTypes.map((cuisine) => Chip(
                      label: Text(
                        cuisine,
                        style: theme.textTheme.labelSmall,
                      ),
                      backgroundColor: theme.colorScheme.primaryContainer,
                      side: BorderSide.none,
                    )).toList(),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Bio
                  Text(
                    'About',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    chef.bio,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Details
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          context,
                          Icons.work_outline,
                          'Experience',
                          '${chef.experienceYears} years',
                        ),
                        const Divider(),
                        _buildDetailRow(
                          context,
                          Icons.language,
                          'Languages',
                          chef.languages.join(', '),
                        ),
                        const Divider(),
                        _buildDetailRow(
                          context,
                          Icons.restaurant_menu,
                          'Dietary Options',
                          chef.dietarySpecialties.join(', '),
                        ),
                        const Divider(),
                        _buildDetailRow(
                          context,
                          Icons.euro,
                          'Hourly Rate',
                          '${chef.hourlyRate.toStringAsFixed(0)} DKK',
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Book Now',
                          variant: ButtonVariant.primary,
                          icon: Icons.calendar_today,
                          onPressed: chef.isAvailable ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingScreen(chef: chef),
                              ),
                            );
                          } : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      CustomButton(
                        text: 'Message',
                        variant: ButtonVariant.outline,
                        icon: Icons.chat_bubble_outline,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                chefId: chef.id,
                                chefName: chef.name,
                                chefImage: chef.profileImage,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  
                  if (!chef.isAvailable)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Chef is currently busy. Send a message to check availability.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}