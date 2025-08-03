import 'package:flutter/material.dart';
import 'package:homechef/models/user.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = User.getSampleUser();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Implement profile editing
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.colorScheme.primary,
                    child: user.profileImage != null
                        ? ClipOval(
                            child: Image.network(
                              user.profileImage!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Text(
                            user.name.split(' ').map((n) => n[0]).join().toUpperCase(),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Account Settings
            _buildSection(
              context,
              'Account',
              [
                _buildListTile(
                  context,
                  Icons.person_outline,
                  'Personal Information',
                  'Update your profile details',
                  () {
                    // TODO: Navigate to personal info screen
                  },
                ),
                _buildListTile(
                  context,
                  Icons.location_on_outlined,
                  'Addresses',
                  '${user.addresses.length} saved addresses',
                  () {
                    _showAddressesDialog(context, user.addresses);
                  },
                ),
                _buildListTile(
                  context,
                  Icons.credit_card_outlined,
                  'Payment Methods',
                  'Manage your payment options',
                  () {
                    // TODO: Navigate to payment methods
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Preferences
            _buildSection(
              context,
              'Preferences',
              [
                _buildListTile(
                  context,
                  Icons.language_outlined,
                  'Language',
                  user.preferredLanguage == 'da' ? 'Danish' : 'English',
                  () {
                    _showLanguageDialog(context);
                  },
                ),
                _buildListTile(
                  context,
                  Icons.restaurant_outlined,
                  'Dietary Preferences',
                  user.dietaryPreferences.join(', '),
                  () {
                    // TODO: Navigate to dietary preferences
                  },
                ),
                _buildListTile(
                  context,
                  Icons.notifications_outlined,
                  'Notifications',
                  'Manage notification settings',
                  () {
                    // TODO: Navigate to notification settings
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // App Info
            _buildSection(
              context,
              'Support',
              [
                _buildListTile(
                  context,
                  Icons.help_outline,
                  'Help & FAQ',
                  'Get help and find answers',
                  () {
                    // TODO: Navigate to help
                  },
                ),
                _buildListTile(
                  context,
                  Icons.chat_bubble_outline,
                  'Contact Support',
                  'Get in touch with our team',
                  () {
                    // TODO: Navigate to support chat
                  },
                ),
                _buildListTile(
                  context,
                  Icons.star_outline,
                  'Rate DinnerHelp',
                  'Share your experience',
                  () {
                    // TODO: Open app store rating
                  },
                ),
                _buildListTile(
                  context,
                  Icons.info_outline,
                  'About',
                  'Version 1.0.0',
                  () {
                    _showAboutDialog(context);
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
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
                ),
                child: const Text('Sign Out'),
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
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
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(children: children),
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
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: Colors.grey.shade600,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  void _showAddressesDialog(BuildContext context, List<String> addresses) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Saved Addresses'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: addresses.map((address) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(address)),
              ],
            ),
          )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              leading: const Text('🇺🇸'),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              title: const Text('Dansk'),
              leading: const Text('🇩🇰'),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'DinnerHelp',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.restaurant,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      children: const [
        Text('Connect with professional chefs for unforgettable dining experiences at home.'),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement sign out
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Signed out successfully')),
              );
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}