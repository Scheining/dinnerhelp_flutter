import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/notification.dart';
import '../providers/notification_providers.dart';

class NotificationPreferencesPage extends ConsumerStatefulWidget {
  final String userId;

  const NotificationPreferencesPage({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  ConsumerState<NotificationPreferencesPage> createState() =>
      _NotificationPreferencesPageState();
}

class _NotificationPreferencesPageState
    extends ConsumerState<NotificationPreferencesPage> {
  @override
  void initState() {
    super.initState();
    // Load preferences on page init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(notificationPreferencesNotifierProvider.notifier)
          .loadPreferences(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final preferencesState = ref.watch(notificationPreferencesNotifierProvider);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.notificationPreferences),
        elevation: 0,
      ),
      body: preferencesState.when(
        data: (preferences) {
          if (preferences == null) {
            return const Center(
              child: Text('No preferences found'),
            );
          }
          
          return _buildPreferencesForm(context, preferences);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load preferences',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref
                    .read(notificationPreferencesNotifierProvider.notifier)
                    .loadPreferences(widget.userId),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreferencesForm(
    BuildContext context,
    NotificationPreferences preferences,
  ) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Channel preferences section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notification Channels',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose how you want to receive notifications',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  
                  // Email notifications
                  SwitchListTile(
                    title: const Text('Email Notifications'),
                    subtitle: const Text('Receive notifications via email'),
                    value: preferences.emailEnabled,
                    onChanged: (value) => ref
                        .read(notificationPreferencesNotifierProvider.notifier)
                        .toggleEmailNotifications(widget.userId),
                  ),
                  
                  // Push notifications
                  SwitchListTile(
                    title: const Text('Push Notifications'),
                    subtitle: const Text('Receive push notifications on your device'),
                    value: preferences.pushEnabled,
                    onChanged: (value) => ref
                        .read(notificationPreferencesNotifierProvider.notifier)
                        .togglePushNotifications(widget.userId),
                  ),
                  
                  // In-app notifications
                  SwitchListTile(
                    title: const Text('In-App Notifications'),
                    subtitle: const Text('Show notifications within the app'),
                    value: preferences.inAppEnabled,
                    onChanged: (value) async {
                      final currentPrefs = preferences;
                      final updatedPrefs = currentPrefs.copyWith(
                        inAppEnabled: value,
                      );
                      await ref
                          .read(notificationPreferencesNotifierProvider.notifier)
                          .updatePreferences(widget.userId, updatedPrefs);
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Content preferences section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notification Types',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose what types of notifications you want to receive',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  
                  // Booking confirmations
                  SwitchListTile(
                    title: const Text('Booking Confirmations'),
                    subtitle: const Text('When your booking is confirmed'),
                    value: preferences.bookingConfirmations,
                    onChanged: (value) async {
                      final updatedPrefs = preferences.copyWith(
                        bookingConfirmations: value,
                      );
                      await ref
                          .read(notificationPreferencesNotifierProvider.notifier)
                          .updatePreferences(widget.userId, updatedPrefs);
                    },
                  ),
                  
                  // Booking reminders
                  SwitchListTile(
                    title: const Text('Booking Reminders'),
                    subtitle: const Text('Reminders before your booking'),
                    value: preferences.bookingReminders,
                    onChanged: (value) => ref
                        .read(notificationPreferencesNotifierProvider.notifier)
                        .toggleBookingReminders(widget.userId),
                  ),
                  
                  // Booking updates
                  SwitchListTile(
                    title: const Text('Booking Updates'),
                    subtitle: const Text('Changes to your bookings'),
                    value: preferences.bookingUpdates,
                    onChanged: (value) async {
                      final updatedPrefs = preferences.copyWith(
                        bookingUpdates: value,
                      );
                      await ref
                          .read(notificationPreferencesNotifierProvider.notifier)
                          .updatePreferences(widget.userId, updatedPrefs);
                    },
                  ),
                  
                  // Marketing emails
                  SwitchListTile(
                    title: const Text('Marketing Emails'),
                    subtitle: const Text('Promotional content and updates'),
                    value: preferences.marketingEmails,
                    onChanged: (value) async {
                      final updatedPrefs = preferences.copyWith(
                        marketingEmails: value,
                      );
                      await ref
                          .read(notificationPreferencesNotifierProvider.notifier)
                          .updatePreferences(widget.userId, updatedPrefs);
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Language preference section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Language Preference',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose your preferred language for notifications',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    value: preferences.languagePreference,
                    decoration: const InputDecoration(
                      labelText: 'Language',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'da',
                        child: Text('Dansk'),
                      ),
                      DropdownMenuItem(
                        value: 'en',
                        child: Text('English'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        ref
                            .read(notificationPreferencesNotifierProvider.notifier)
                            .updateLanguagePreference(widget.userId, value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Timezone section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Timezone',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your current timezone setting',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.dividerColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          preferences.timezone,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Preferences updated successfully'),
                  ),
                );
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('Save Preferences'),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget for displaying notification history
class NotificationHistoryPage extends ConsumerStatefulWidget {
  final String userId;

  const NotificationHistoryPage({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  ConsumerState<NotificationHistoryPage> createState() =>
      _NotificationHistoryPageState();
}

class _NotificationHistoryPageState
    extends ConsumerState<NotificationHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(userNotificationsNotifierProvider.notifier)
          .loadNotifications(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationsState = ref.watch(userNotificationsNotifierProvider);
    final unreadCount = ref
        .read(userNotificationsNotifierProvider.notifier)
        .unreadCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () => ref
                  .read(userNotificationsNotifierProvider.notifier)
                  .markAllAsRead(widget.userId),
              child: const Text('Mark All Read'),
            ),
        ],
      ),
      body: notificationsState.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref
                .read(userNotificationsNotifierProvider.notifier)
                .loadNotifications(widget.userId, refresh: true),
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationTile(notification);
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load notifications',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref
                    .read(userNotificationsNotifierProvider.notifier)
                    .loadNotifications(widget.userId),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationTile(NotificationEntity notification) {
    final isRead = notification.data['read'] as bool? ?? false;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: _buildNotificationIcon(notification.type),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.content),
            const SizedBox(height: 4),
            Text(
              _formatDateTime(notification.createdAt),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        trailing: isRead 
            ? null 
            : const Icon(
                Icons.circle,
                size: 12,
                color: Colors.blue,
              ),
        onTap: () {
          if (!isRead) {
            ref
                .read(userNotificationsNotifierProvider.notifier)
                .markAsRead(notification.id);
          }
          
          // Navigate to relevant screen based on notification type
          _handleNotificationTap(notification);
        },
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationType type) {
    IconData iconData;
    Color color;

    switch (type) {
      case NotificationType.bookingConfirmation:
        iconData = Icons.check_circle;
        color = Colors.green;
        break;
      case NotificationType.bookingReminder24h:
      case NotificationType.bookingReminder1h:
        iconData = Icons.schedule;
        color = Colors.orange;
        break;
      case NotificationType.bookingCompletion:
        iconData = Icons.star;
        color = Colors.amber;
        break;
      case NotificationType.bookingModified:
        iconData = Icons.edit;
        color = Colors.blue;
        break;
      case NotificationType.bookingCancelled:
        iconData = Icons.cancel;
        color = Colors.red;
        break;
      case NotificationType.chefMessage:
        iconData = Icons.message;
        color = Colors.purple;
        break;
      case NotificationType.paymentSuccess:
        iconData = Icons.payment;
        color = Colors.green;
        break;
      case NotificationType.paymentFailed:
        iconData = Icons.payment;
        color = Colors.red;
        break;
      default:
        iconData = Icons.notifications;
        color = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(
        iconData,
        color: color,
        size: 20,
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  void _handleNotificationTap(NotificationEntity notification) {
    // Navigate to relevant screen based on notification data
    final bookingId = notification.bookingId;
    
    if (bookingId != null) {
      // Navigate to booking details
      // Navigator.of(context).push(...)
    }
    
    // Handle other navigation based on notification type
  }
}