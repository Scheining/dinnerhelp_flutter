import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homechef/models/chef.dart';
import 'package:homechef/widgets/rating_stars.dart';
import 'package:homechef/widgets/custom_button.dart';
import 'package:homechef/screens/booking_screen.dart';
import 'package:homechef/screens/chat_screen.dart';
import 'package:homechef/providers/favorites_provider.dart';
import 'package:homechef/core/utils/postal_code_mapper.dart';

class ChefProfileScreen extends ConsumerWidget {
  final Chef chef;

  const ChefProfileScreen({
    super.key,
    required this.chef,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? theme.scaffoldBackgroundColor
          : Colors.grey.shade50,
      body: Stack(
        children: [
          // Fixed header image background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.35,
            child: chef.headerImage.isNotEmpty
                ? Image.network(
                    chef.headerImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/logo_brand.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                : Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/logo_brand.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
          ),
          
          // Main scrollable content
          CustomScrollView(
            slivers: [
              // Transparent spacer to show header image
              SliverToBoxAdapter(
                child: SizedBox(height: screenHeight * 0.35 - 30),
              ),
              
              // Content in white card with rounded top
              SliverToBoxAdapter(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // White card with rounded top corners
                    Container(
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? Colors.grey.shade900
                            : Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              theme.brightness == Brightness.dark ? 0.3 : 0.1
                            ),
                            blurRadius: 20,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Spacing for the absolutely positioned profile and name/location
                          const SizedBox(height: 170), // Increased space for better separation
                          
                          // Rating or NEW badge - moved to the right
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: chef.reviewCount > 0
                                ? Row(
                                    children: [
                                      Icon(Icons.star, size: 16, color: Colors.amber.shade600),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${chef.rating.toStringAsFixed(1)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '(${chef.reviewCount} anmeldelser)',
                                        style: TextStyle(
                                          color: theme.brightness == Brightness.dark
                                              ? Colors.grey.shade400
                                              : Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
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
                                    ],
                                  ),
                          ),

                          const SizedBox(height: 24), // Increased spacing before bio section

                          // Bio section
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                              'Om kokken',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.grey.shade900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              chef.bio.isNotEmpty 
                                ? chef.bio 
                                : 'Velkommen, mit navn er ${chef.name}. Jeg arbejder jeg som professionel kok på restaurant Paté Paté i Kødbyen. Jeg er passioneret omkring madlavning og tror på, at mad skal være en oplevelse, der både smager godt og gør godt for kroppen.\n\nMin filosofi er enkel: Brug friske, sæsonbaserede råvarer, minimer madspild og udforsk kreative smagsoplevelser.',
                              style: TextStyle(
                                color: theme.brightness == Brightness.dark
                                    ? Colors.grey.shade300
                                    : Colors.grey.shade700,
                                fontSize: 14,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Info cards grid
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInfoCard(
                                    context,
                                    Icons.work_outline,
                                    'Erfaring',
                                    '${chef.experienceYears} år',
                                    Colors.blue.shade50,
                                    Colors.blue.shade700,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildInfoCard(
                                    context,
                                    Icons.restaurant_menu,
                                    'Retter',
                                    '50+',
                                    Colors.green.shade50,
                                    Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInfoCard(
                                    context,
                                    Icons.star,
                                    'Bedømmelse',
                                    chef.reviewCount > 0 ? chef.rating.toStringAsFixed(1) : 'NY',
                                    Colors.amber.shade50,
                                    Colors.amber.shade700,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildInfoCard(
                                    context,
                                    Icons.groups,
                                    'Gæster',
                                    '2-20',
                                    Colors.purple.shade50,
                                    Colors.purple.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Specialties
                      if (chef.cuisineTypes.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Specialer',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: theme.brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.grey.shade900,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: chef.cuisineTypes.map((cuisine) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primaryContainer.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: theme.colorScheme.primary.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      _translateCuisine(cuisine),
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Languages
                      if (chef.languages.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sprog',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: theme.brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.grey.shade900,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: chef.languages.map((language) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: theme.brightness == Brightness.dark
                                          ? Colors.grey.shade800
                                          : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _translateLanguage(language),
                                      style: TextStyle(
                                        color: theme.brightness == Brightness.dark
                                            ? Colors.grey.shade300
                                            : Colors.grey.shade700,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Price section
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary.withOpacity(0.05),
                              theme.colorScheme.primary.withOpacity(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pris fra',
                                  style: TextStyle(
                                    color: theme.brightness == Brightness.dark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${chef.hourlyRate.toStringAsFixed(0)} kr/time',
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              Icons.info_outline,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                      ),

                          // Spacing for bottom buttons - increased for better visibility
                          const SizedBox(height: 200),
                        ],
                      ),
                    ),
                    
                    // Profile avatar positioned on top and centered
                    Positioned(
                      left: 0,
                      right: 0,
                      top: -83, // Adjusted for larger image
                      child: Center(
                        child: Container(
                          width: 166, // Increased by another 15%
                          height: 166, // Increased by another 15%
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: chef.profileImage.isNotEmpty
                              ? Image.network(
                                  chef.profileImage,
                                  width: 166, // Increased by another 15%
                                  height: 166, // Increased by another 15%
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: theme.colorScheme.primary,
                                    child: const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : Container(
                                  color: theme.colorScheme.primary,
                                  child: const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.white,
                                  ),
                                ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Name and location centered below profile image
                    Positioned(
                      left: 24,
                      top: 100, // Added more space below the profile image
                      right: 24,
                      height: 60, // Height for name and location
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center, // Center aligned
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  chef.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              if (chef.isVerified)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Icon(
                                    Icons.verified,
                                    color: Colors.blue.shade600,
                                    size: 20,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6), // Increased spacing between name and location
                          // Location with icon centered (only show if location exists)
                          if (PostalCodeMapper.formatLocation(chef.location).isNotEmpty)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.location_on, size: 14, color: Colors.red.shade400),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    PostalCodeMapper.formatLocation(chef.location),
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
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
            
            // Fill remaining space with white background
            SliverFillRemaining(
              hasScrollBody: false,
              child: Container(
                color: Colors.white,
              ),
            ),
          ],
        ),
          
        // Fixed bottom buttons
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
              padding: EdgeInsets.fromLTRB(
                24,
                16,
                24,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? Colors.grey.shade900
                    : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      theme.brightness == Brightness.dark ? 0.3 : 0.05
                    ),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Book button
                  Expanded(
                    child: FilledButton(
                      onPressed: chef.isAvailable
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookingScreen(chef: chef),
                                ),
                              );
                            }
                          : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Book',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Message button
                  Expanded(
                    child: OutlinedButton(
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
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: theme.brightness == Brightness.dark
                              ? Colors.grey.shade700
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        'Send besked',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.brightness == Brightness.dark
                              ? Colors.grey.shade300
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ),
        
        // Sticky back button
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
        ),
        
        // Sticky favorite button
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          right: 16,
          child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Consumer(
                builder: (context, ref, child) {
                  final isFavorited = ref.watch(isChefFavoritedProvider(chef.id));
                  
                  return IconButton(
                    icon: Icon(
                      isFavorited ? Icons.favorite : Icons.favorite_border,
                      color: isFavorited ? Colors.red : Colors.black,
                    ),
                    onPressed: () async {
                      await ref.read(favoritesChefsProvider.notifier).toggleFavorite(chef.id);
                      
                      // Show feedback
                      final message = isFavorited
                          ? 'Fjernet fra favoritter'
                          : 'Tilføjet til favoritter';
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color backgroundColor,
    Color iconColor,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? backgroundColor.withOpacity(0.2)
            : backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: iconColor),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: theme.brightness == Brightness.dark
                  ? Colors.grey.shade400
                  : Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : Colors.grey.shade900,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _translateCuisine(String cuisine) {
    const map = {
      'italian': 'Italiensk',
      'french': 'Fransk',
      'asian': 'Asiatisk',
      'mediterranean': 'Middelhav',
      'american': 'Amerikansk',
      'mexican': 'Mexicansk',
      'indian': 'Indisk',
      'japanese': 'Japansk',
      'thai': 'Thai',
      'danish': 'Dansk',
      'spanish': 'Spansk',
      'greek': 'Græsk',
      'chinese': 'Kinesisk',
      'korean': 'Koreansk',
      'vietnamese': 'Vietnamesisk',
      'turkish': 'Tyrkisk',
    };

    final key = cuisine.toLowerCase();
    return map[key] ?? cuisine;
  }

  String _translateLanguage(String language) {
    const map = {
      'english': 'Engelsk',
      'danish': 'Dansk',
      'swedish': 'Svensk',
      'norwegian': 'Norsk',
      'german': 'Tysk',
      'french': 'Fransk',
      'spanish': 'Spansk',
      'italian': 'Italiensk',
      'polish': 'Polsk',
      'arabic': 'Arabisk',
      'turkish': 'Tyrkisk',
      'chinese': 'Kinesisk',
      'japanese': 'Japansk',
      'korean': 'Koreansk',
      'russian': 'Russisk',
      'portuguese': 'Portugisisk',
      'dutch': 'Hollandsk',
      'finnish': 'Finsk',
      'greek': 'Græsk',
      'hindi': 'Hindi',
      'urdu': 'Urdu',
      'thai': 'Thai',
      'vietnamese': 'Vietnamesisk',
    };

    final key = language.toLowerCase().trim();
    final translated = map[key];
    
    if (translated != null) {
      return translated;
    }
    
    // If not found in map, capitalize first letter
    if (language.isEmpty) return language;
    return language[0].toUpperCase() + language.substring(1).toLowerCase();
  }
}