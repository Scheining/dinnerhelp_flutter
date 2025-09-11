import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:homechef/providers/theme_provider.dart';
import 'package:homechef/providers/auth_provider.dart';
import 'package:homechef/screens/favorite_chefs_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserAsync = ref.watch(currentUserProvider);
    final userProfileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: currentUserAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text('Fejl ved indlæsning af profil', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(error.toString(), style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        data: (currentUser) {
          if (currentUser == null) {
            // Not authenticated, should not happen due to route guard
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/auth/signin');
            });
            return const Center(child: CircularProgressIndicator());
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 100),
            child: Column(
              children: [
                // Profile Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: userProfileAsync.when(
                    loading: () => const Center(
                      child: SizedBox(
                        height: 100,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                    error: (_, __) => _buildProfileHeader(context, currentUser, null, ref),
                    data: (profile) => _buildProfileHeader(context, currentUser, profile, ref),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Account Settings
                _buildSection(
                  context,
                  'Konto',
                  [
                    _buildListTile(
                      context,
                      Icons.person_outline,
                      'Personlige oplysninger',
                      'Opdater dine profiloplysninger',
                      () {
                        context.go('/profile/personal-information');
                      },
                    ),
                    _buildListTile(
                      context,
                      Icons.location_on_outlined,
                      'Mine adresser',
                      'Administrer adresser hvor kokken kommer',
                      () {
                        context.go('/profile/service-addresses');
                      },
                    ),
                    _buildListTile(
                      context,
                      Icons.credit_card_outlined,
                      'Betalingsmetoder',
                      'Administrer dine betalingsmuligheder',
                      () {
                        context.go('/profile/payment-methods');
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Preferences
                _buildSection(
                  context,
                  'Præferencer',
                  [
                    _buildListTile(
                      context,
                      Icons.language_outlined,
                      'Sprog',
                      'Dansk',
                      () {
                        _showLanguageDialog(context);
                      },
                    ),
                    _buildListTile(
                      context,
                      Icons.notifications_outlined,
                      'Notifikationer',
                      'Administrer dine notifikationer',
                      () {
                        context.go('/profile/notifications');
                      },
                    ),
                    _buildListTile(
                      context,
                      Icons.palette_outlined,
                      'Tema',
                      ref.watch(themeModeProvider.notifier).getThemeModeText(),
                      () {
                        _showThemeDialog(context, ref);
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Security
                _buildSection(
                  context,
                  'Sikkerhed',
                  [
                    _buildListTile(
                      context,
                      Icons.fingerprint,
                      'Biometrisk sikkerhed',
                      'Face ID, Touch ID og betalingsbeskyttelse',
                      () {
                        context.go('/profile/biometric-settings');
                      },
                    ),
                    _buildListTile(
                      context,
                      Icons.lock_outline,
                      'Skift adgangskode',
                      'Opdater din adgangskode',
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Skift adgangskode kommer snart')),
                        );
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Booking History
                userProfileAsync.when(
                  data: (profile) {
                    final isChef = profile?['is_chef'] ?? false;
                    return _buildSection(
                      context,
                      isChef ? 'Kok indstillinger' : 'Booking historik',
                      [
                        if (isChef) ...[
                          _buildListTile(
                            context,
                            Icons.restaurant_menu,
                            'Min kok profil',
                            'Administrer din kok profil',
                            () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Kok profil kommer snart')),
                              );
                            },
                          ),
                          _buildListTile(
                            context,
                            Icons.calendar_month,
                            'Tilgængelighed',
                            'Administrer din kalender',
                            () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Kalender kommer snart')),
                              );
                            },
                          ),
                        ] else ...[
                          _buildListTile(
                            context,
                            Icons.history,
                            'Mine bookinger',
                            'Se tidligere og kommende bookinger',
                            () {
                              context.go('/bookings');
                            },
                          ),
                          _buildListTile(
                            context,
                            Icons.favorite_outline,
                            'Favorit kokke',
                            'Se dine gemte kokke',
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const FavoriteChefsScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                
                const SizedBox(height: 16),
                
                // Support
                _buildSection(
                  context,
                  'Support',
                  [
                    _buildListTile(
                      context,
                      Icons.help_outline,
                      'Hjælpecenter',
                      'Få hjælp og support',
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Hjælp kommer snart')),
                        );
                      },
                    ),
                    _buildListTile(
                      context,
                      Icons.chat_bubble_outline,
                      'Kontakt support',
                      'Send en email til vores support team',
                      () async {
                        final Uri emailUri = Uri(
                          scheme: 'mailto',
                          path: 'hello@dinnerhelp.dk',
                          query: Uri.encodeQueryComponent('subject=Support forespørgsel fra DinnerHelp app'),
                        );
                        
                        try {
                          if (await canLaunchUrl(emailUri)) {
                            await launchUrl(emailUri);
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Kunne ikke åbne email klient. Send venligst en email til hello@dinnerhelp.dk'),
                                  duration: Duration(seconds: 4),
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Email: hello@dinnerhelp.dk'),
                                duration: Duration(seconds: 4),
                              ),
                            );
                          }
                        }
                      },
                    ),
                    _buildListTile(
                      context,
                      Icons.star_outline,
                      'Bedøm DinnerHelp',
                      'Del din oplevelse',
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Bedømmelse kommer snart')),
                        );
                      },
                    ),
                    _buildListTile(
                      context,
                      Icons.info_outline,
                      'Om',
                      'Version 1.0.0',
                      () {
                        _showAboutDialog(context);
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Debug: Reset Onboarding (can be removed in production)
                if (const bool.fromEnvironment('dart.vm.product') == false)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('onboarding_complete', false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Onboarding nulstillet. Log ud og ind igen for at se det.'),
                            ),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: theme.brightness == Brightness.dark 
                            ? const Color(0xFF252325)
                            : Colors.transparent,
                      ),
                      child: const Text('Nulstil Onboarding (Debug)'),
                    ),
                  ),
                
                if (const bool.fromEnvironment('dart.vm.product') == false)
                  const SizedBox(height: 16),
                
                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      _showLogoutDialog(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: theme.brightness == Brightness.dark 
                          ? const Color(0xFF252325)
                          : Colors.transparent,
                    ),
                    child: const Text('Log ud'),
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, supabase.User user, Map<String, dynamic>? profile, WidgetRef ref) {
    final theme = Theme.of(context);
    
    // Extract user data
    final firstName = profile?['first_name'] ?? '';
    final lastName = profile?['last_name'] ?? '';
    final fullName = '$firstName $lastName'.trim();
    final displayName = fullName.isEmpty ? 'Bruger' : fullName;
    final email = user.email ?? 'Ingen email';
    final isChef = profile?['is_chef'] ?? false;
    final avatarUrl = profile?['profile-image-url'] as String?;
    
    // Get initials for avatar
    final initials = displayName.split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase())
        .take(2)
        .join();
    
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            GestureDetector(
              onTap: () => _showImagePicker(context, user.id, ref),
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.colorScheme.primary,
                    backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                    child: avatarUrl == null
                        ? Text(
                            initials.isEmpty ? 'U' : initials,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isChef)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.restaurant,
                  size: 16,
                  color: Colors.white,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          displayName,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        if (isChef) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Professionel kok',
              style: TextStyle(
                color: Colors.green.shade800,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          'Medlem siden ${_formatDate(profile?['created_at'] ?? user.createdAt)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'ukendt';
    
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'januar', 'februar', 'marts', 'april', 'maj', 'juni',
        'juli', 'august', 'september', 'oktober', 'november', 'december'
      ];
      return '${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return 'ukendt';
    }
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> items) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark 
                ? const Color(0xFF252325)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.brightness == Brightness.dark 
                  ? Colors.grey.shade800
                  : Colors.grey.shade200,
            ),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildListTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(
        icon,
        color: theme.colorScheme.primary,
      ),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 12,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vælg sprog'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Dansk'),
              leading: const Text('🇩🇰'),
              selected: true,
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              title: const Text('English'),
              leading: const Text('🇬🇧'),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.read(themeModeProvider);
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Vælg tema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('System'),
              secondary: const Icon(Icons.settings),
              value: ThemeMode.system,
              groupValue: currentThemeMode,
              onChanged: (value) async {
                if (value != null) {
                  await ref.read(themeModeProvider.notifier).setThemeMode(value);
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Lys'),
              secondary: const Icon(Icons.light_mode),
              value: ThemeMode.light,
              groupValue: currentThemeMode,
              onChanged: (value) async {
                if (value != null) {
                  await ref.read(themeModeProvider.notifier).setThemeMode(value);
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Mørk'),
              secondary: const Icon(Icons.dark_mode),
              value: ThemeMode.dark,
              groupValue: currentThemeMode,
              onChanged: (value) async {
                if (value != null) {
                  await ref.read(themeModeProvider.notifier).setThemeMode(value);
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Annuller'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'DinnerHelp',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: const DecorationImage(
            image: AssetImage('assets/images/round_logo_500x500.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
      children: const [
        Text('Forbind med professionelle kokke for uforglemmelige madoplevelser derhjemme.'),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log ud'),
        content: const Text('Er du sikker på, at du vil logge ud?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuller'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              // Sign out
              await ref.read(authNotifierProvider.notifier).signOut();
              
              // Navigate to sign in screen
              if (context.mounted) {
                context.go('/auth/signin');
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Log ud'),
          ),
        ],
      ),
    );
  }

  void _showImagePicker(BuildContext context, String userId, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (modalContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Vælg fra galleri'),
              onTap: () {
                Navigator.of(modalContext).pop();
                // Use a small delay to ensure modal is closed before picking
                Future.delayed(const Duration(milliseconds: 100), () {
                  _pickImage(context, ImageSource.gallery, userId, ref);
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tag et billede'),
              onTap: () {
                Navigator.of(modalContext).pop();
                // Use a small delay to ensure modal is closed before picking
                Future.delayed(const Duration(milliseconds: 100), () {
                  _pickImage(context, ImageSource.camera, userId, ref);
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Annuller'),
              onTap: () => Navigator.of(modalContext).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source, String userId, WidgetRef ref) async {
    final ImagePicker picker = ImagePicker();
    bool dialogShown = false;
    
    try {
      debugPrint('Starting image picker...');
      
      // Pick image with size limits
      // The PNG warning is harmless - iOS just can't compress PNGs but still returns the image
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,  // This only works for JPEG, but that's OK
      );
      
      debugPrint('Image picked: ${image?.path}');
      
      if (image == null) {
        debugPrint('Image is null, returning');
        return;
      }
      
      debugPrint('Context mounted: ${context.mounted}');
      
      // Check if context is still mounted
      if (!context.mounted) {
        debugPrint('Context not mounted after image picker, aborting');
        return;
      }
      
      // Show loading indicator
      debugPrint('Showing loading dialog...');
      dialogShown = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      debugPrint('Loading dialog shown, reading image file...');
      
      // Read the image file
      final bytes = await File(image.path).readAsBytes();
      debugPrint('Read ${bytes.length} bytes from image file');
      
      // Get the file extension from the original file
      final pathParts = image.path.split('.');
      String fileExtension = 'jpg'; // default
      if (pathParts.length > 1) {
        fileExtension = pathParts.last.toLowerCase();
        // Ensure it's a valid image extension
        if (!['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic', 'heif'].contains(fileExtension)) {
          fileExtension = 'jpg';
        }
      }
      
      // For HEIC/HEIF files on iOS, the image picker automatically converts to JPEG
      // So we should use jpg extension for those
      if (fileExtension == 'heic' || fileExtension == 'heif') {
        fileExtension = 'jpg';
      }
      
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      final filePath = 'profile-images/$fileName';
      
      final supabaseClient = supabase.Supabase.instance.client;
      
      // Check if user already has a profile image and delete it first
      final existingProfile = await supabaseClient
          .from('profiles')
          .select('profile-image-url')
          .eq('id', userId)
          .maybeSingle();
          
      if (existingProfile != null && existingProfile['profile-image-url'] != null) {
        final existingUrl = existingProfile['profile-image-url'] as String;
        // Extract the file path from the URL
        final uri = Uri.parse(existingUrl);
        final pathSegments = uri.pathSegments;
        if (pathSegments.length > 2 && pathSegments.contains('user-images')) {
          final existingPath = pathSegments.sublist(pathSegments.indexOf('user-images') + 1).join('/');
          try {
            // Try to delete the old image
            await supabaseClient.storage
                .from('user-images')
                .remove([existingPath]);
          } catch (e) {
            // Ignore deletion errors - old file might not exist
            debugPrint('Could not delete old profile image: $e');
          }
        }
      }
      
      // Debug logging
      debugPrint('Uploading image: $filePath');
      debugPrint('File size: ${bytes.length} bytes');
      debugPrint('Content type: image/$fileExtension');
      
      // Upload to user-images bucket in profile-images folder
      final response = await supabaseClient.storage
          .from('user-images')
          .uploadBinary(
            filePath, 
            bytes,
            fileOptions: supabase.FileOptions(
              contentType: 'image/$fileExtension',
              upsert: true, // Overwrite if exists
            ),
          );
      
      debugPrint('Upload response: $response');
      
      if (response.isNotEmpty) {
        // Get public URL
        final publicUrl = supabaseClient.storage
            .from('user-images')
            .getPublicUrl(filePath);
        
        debugPrint('Generated public URL: $publicUrl');
        
        // Update profile with new profile image URL
        await supabaseClient
            .from('profiles')
            .update({'profile-image-url': publicUrl})
            .eq('id', userId);
        
        debugPrint('Profile updated successfully');
        
        // Close loading dialog first before invalidating provider
        if (context.mounted && dialogShown) {
          debugPrint('Closing loading dialog...');
          // Use the root navigator to ensure we're popping the dialog
          Navigator.of(context, rootNavigator: true).pop();
          dialogShown = false;
          debugPrint('Loading dialog closed');
        }
        
        // Invalidate the user profile provider to refresh the data
        debugPrint('Invalidating user profile provider...');
        ref.invalidate(userProfileProvider);
        debugPrint('Provider invalidated');
        
        // Show success message after a small delay to ensure dialog is closed
        if (context.mounted) {
          await Future.delayed(const Duration(milliseconds: 100));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profilbillede opdateret'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      } else {
        debugPrint('Upload failed: Empty response');
        throw Exception('Upload returned empty response');
      }
    } catch (e, stack) {
      // Log detailed error information
      debugPrint('Error uploading profile image: $e');
      debugPrint('Stack trace: $stack');
      
      // Close loading dialog if open
      if (context.mounted && dialogShown) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      
      // Show error message to user
      if (context.mounted) {
        String errorMessage = 'Fejl ved upload af billede';
        
        // Try to extract a more specific error message
        if (e.toString().contains('decode')) {
          errorMessage = 'Kunne ikke læse billedet. Prøv et andet format.';
        } else if (e.toString().contains('size')) {
          errorMessage = 'Billedet er for stort. Prøv et mindre billede.';
        } else if (e.toString().contains('network')) {
          errorMessage = 'Netværksfejl. Tjek din internetforbindelse.';
        } else {
          errorMessage = 'Fejl: ${e.toString().split(':').last.trim()}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}