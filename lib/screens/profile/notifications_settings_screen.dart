import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationsSettingsScreen extends ConsumerStatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  ConsumerState<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends ConsumerState<NotificationsSettingsScreen> {
  // Notification preferences
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  
  // Notification types
  bool _bookingUpdates = true;
  bool _messages = true;
  bool _promotions = true;
  bool _reminders = true;
  bool _newsletter = false;
  
  bool _isLoading = false;
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        final response = await _supabase
            .from('profiles')
            .select('notification_preferences')
            .eq('id', userId)
            .single();

        if (response['notification_preferences'] != null) {
          final prefs = response['notification_preferences'] as Map<String, dynamic>;
          setState(() {
            _pushNotifications = prefs['push_enabled'] ?? true;
            _emailNotifications = prefs['email_enabled'] ?? true;
            _smsNotifications = prefs['sms_enabled'] ?? false;
            _bookingUpdates = prefs['booking_updates'] ?? true;
            _messages = prefs['messages'] ?? true;
            _reminders = prefs['reminders'] ?? true;
            _promotions = prefs['promotions'] ?? true;
            _newsletter = prefs['newsletter'] ?? false;
          });
        }
      }
    } catch (e) {
      // Use default values on error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _savePreferences() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        final preferences = {
          'push_enabled': _pushNotifications,
          'email_enabled': _emailNotifications,
          'sms_enabled': _smsNotifications,
          'booking_updates': _bookingUpdates,
          'messages': _messages,
          'reminders': _reminders,
          'promotions': _promotions,
          'newsletter': _newsletter,
        };

        await _supabase
            .from('profiles')
            .update({
              'notification_preferences': preferences,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', userId);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notifikationsindstillinger gemt'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fejl ved gemning: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikationer'),
        backgroundColor: theme.colorScheme.surface,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _savePreferences,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Gem'),
          ),
        ],
      ),
      body: ListView(
        children: [
          // Notification Channels
          _buildSection(
            title: 'Notifikationskanaler',
            subtitle: 'Vælg hvordan du vil modtage notifikationer',
            children: [
              SwitchListTile(
                title: const Text('Push-notifikationer'),
                subtitle: const Text('Modtag notifikationer på din telefon'),
                secondary: const Icon(Icons.phone_iphone),
                value: _pushNotifications,
                onChanged: (value) {
                  setState(() {
                    _pushNotifications = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Email-notifikationer'),
                subtitle: const Text('Modtag notifikationer på email'),
                secondary: const Icon(Icons.email_outlined),
                value: _emailNotifications,
                onChanged: (value) {
                  setState(() {
                    _emailNotifications = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('SMS-notifikationer'),
                subtitle: const Text('Modtag notifikationer via SMS'),
                secondary: const Icon(Icons.sms_outlined),
                value: _smsNotifications,
                onChanged: (value) {
                  setState(() {
                    _smsNotifications = value;
                  });
                },
              ),
            ],
          ),
          
          const Divider(height: 32),
          
          // Notification Types
          _buildSection(
            title: 'Notifikationstyper',
            subtitle: 'Vælg hvilke opdateringer du vil modtage',
            children: [
              SwitchListTile(
                title: const Text('Booking opdateringer'),
                subtitle: const Text('Nye bookinger, aflysninger, ændringer'),
                secondary: const Icon(Icons.calendar_today_outlined),
                value: _bookingUpdates,
                onChanged: (_pushNotifications || _emailNotifications || _smsNotifications)
                    ? (value) {
                        setState(() {
                          _bookingUpdates = value;
                        });
                      }
                    : null,
              ),
              SwitchListTile(
                title: const Text('Beskeder'),
                subtitle: const Text('Nye beskeder fra kokke eller kunder'),
                secondary: const Icon(Icons.message_outlined),
                value: _messages,
                onChanged: (_pushNotifications || _emailNotifications || _smsNotifications)
                    ? (value) {
                        setState(() {
                          _messages = value;
                        });
                      }
                    : null,
              ),
              SwitchListTile(
                title: const Text('Påmindelser'),
                subtitle: const Text('Påmindelser om kommende bookinger'),
                secondary: const Icon(Icons.notifications_active_outlined),
                value: _reminders,
                onChanged: (_pushNotifications || _emailNotifications || _smsNotifications)
                    ? (value) {
                        setState(() {
                          _reminders = value;
                        });
                      }
                    : null,
              ),
            ],
          ),
          
          const Divider(height: 32),
          
          // Marketing
          _buildSection(
            title: 'Marketing',
            subtitle: 'Tilbud og nyheder fra DinnerHelp',
            children: [
              SwitchListTile(
                title: const Text('Tilbud og kampagner'),
                subtitle: const Text('Særlige tilbud og rabatter'),
                secondary: const Icon(Icons.local_offer_outlined),
                value: _promotions,
                onChanged: (_emailNotifications)
                    ? (value) {
                        setState(() {
                          _promotions = value;
                        });
                      }
                    : null,
              ),
              SwitchListTile(
                title: const Text('Nyhedsbrev'),
                subtitle: const Text('Månedligt nyhedsbrev med tips og nyheder'),
                secondary: const Icon(Icons.newspaper_outlined),
                value: _newsletter,
                onChanged: (_emailNotifications)
                    ? (value) {
                        setState(() {
                          _newsletter = value;
                        });
                      }
                    : null,
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Info Box
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Vigtige notifikationer',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Nogle notifikationer som sikkerhedsadvarsler og vigtige kontoopdateringer kan ikke slås fra.',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        ...children,
      ],
    );
  }
}