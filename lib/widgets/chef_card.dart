import 'package:flutter/material.dart';
import 'package:homechef/models/chef.dart';
import 'package:homechef/widgets/rating_stars.dart';
import 'package:homechef/core/utils/postal_code_mapper.dart';

class ChefCard extends StatelessWidget {
  final Chef chef;
  final VoidCallback? onTap;
  final bool isCompact;

  const ChefCard({
    super.key,
    required this.chef,
    this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompactCard(context);
    }
    return _buildFullCard(context);
  }

  Widget _buildCompactCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: theme.brightness == Brightness.dark ? const Color(0xFF252325) : Colors.white,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Main content in a column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header image
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Image.network(
                      chef.headerImage,
                      width: double.infinity,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: double.infinity,
                        height: 120,
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        child: Icon(
                          Icons.restaurant,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  // Content area
                  Padding(
                    padding: const EdgeInsets.all(16).copyWith(top: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chef.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.brightness == Brightness.dark 
                                ? Colors.white 
                                : const Color(0xFF292E31),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        chef.reviewCount > 0
                          ? Row(
                              children: [
                                RatingStars(rating: chef.rating, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '${chef.rating} (${chef.reviewCount})',
                                  style: TextStyle(
                                    color: theme.brightness == Brightness.dark 
                                        ? Colors.grey.shade400 
                                        : Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            )
                          : Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'NY',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        const SizedBox(height: 8),
                        if (PostalCodeMapper.formatLocation(chef.location).isNotEmpty)
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: theme.brightness == Brightness.dark 
                                    ? Colors.grey.shade400 
                                    : Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  PostalCodeMapper.formatLocation(chef.location),
                                  style: TextStyle(
                                    color: theme.brightness == Brightness.dark 
                                        ? Colors.grey.shade400 
                                        : Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.attach_money,
                              size: 14,
                              color: const Color(0xFF79CBC2),
                            ),
                            Text(
                              '${chef.hourlyRate.toStringAsFixed(0)} kr/time',
                              style: const TextStyle(
                                color: Color(0xFF79CBC2),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Overlaid profile photo - now in the main Stack so it can overlay everything
              Positioned(
                top: 85, // Position it to overlay on the white content area
                left: 16,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: chef.profileImage.isNotEmpty
                        ? CircleAvatar(
                            radius: 35,
                            backgroundImage: NetworkImage(chef.profileImage),
                            backgroundColor: const Color(0xFF79CBC2),
                            onBackgroundImageError: (error, stackTrace) {},
                          )
                        : const CircleAvatar(
                            radius: 35,
                            backgroundColor: Color(0xFF79CBC2),
                            child: Icon(Icons.person, size: 35, color: Colors.white),
                          ),
                    ),
                    if (chef.isVerified)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.brightness == Brightness.dark ? theme.colorScheme.surface : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header image with overlaid profile photo
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.network(
                    chef.headerImage,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: double.infinity,
                      height: 180,
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.restaurant,
                        size: 60,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                // Overlaid profile photo
                Positioned(
                  bottom: -25,
                  left: 20,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: chef.profileImage.isNotEmpty
                          ? CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(chef.profileImage),
                              backgroundColor: const Color(0xFF79CBC2),
                              onBackgroundImageError: (error, stackTrace) {},
                            )
                          : const CircleAvatar(
                              radius: 30,
                              backgroundColor: Color(0xFF79CBC2),
                              child: Icon(Icons.person, size: 30, color: Colors.white),
                            ),
                      ),
                      if (chef.isVerified)
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Availability status
                if (!chef.isAvailable)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Busy',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Content area
            Padding(
              padding: const EdgeInsets.all(20).copyWith(top: 35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chef.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: theme.brightness == Brightness.dark 
                          ? Colors.white 
                          : const Color(0xFF292E31),
                    ),
                  ),
                  const SizedBox(height: 8),
                  chef.reviewCount > 0
                    ? Row(
                        children: [
                          RatingStars(rating: chef.rating, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            '${chef.rating} (${chef.reviewCount} anmeldelser)',
                            style: TextStyle(
                              color: theme.brightness == Brightness.dark 
                                  ? Colors.grey.shade400 
                                  : Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'NY',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  const SizedBox(height: 8),
                  Text(
                    chef.cuisineTypes.join(' • '),
                    style: const TextStyle(
                      color: Color(0xFF79CBC2),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (PostalCodeMapper.formatLocation(chef.location).isNotEmpty) ...[
                        Icon(
                          Icons.location_on,
                          size: 18,
                          color: theme.brightness == Brightness.dark 
                              ? Colors.grey.shade400 
                              : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${PostalCodeMapper.formatLocation(chef.location)} • ${chef.distanceKm.toStringAsFixed(1)} km away',
                          style: TextStyle(
                            color: theme.brightness == Brightness.dark 
                                ? Colors.grey.shade400 
                                : Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                      ],
                      Icon(
                        Icons.attach_money,
                        size: 18,
                        color: const Color(0xFF79CBC2),
                      ),
                      Text(
                        '${chef.hourlyRate.toStringAsFixed(0)} kr/time',
                        style: const TextStyle(
                          color: Color(0xFF79CBC2),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
}