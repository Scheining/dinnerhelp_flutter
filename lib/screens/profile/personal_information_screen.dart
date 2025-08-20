import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homechef/providers/auth_provider.dart';
import 'package:homechef/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homechef/widgets/custom_button.dart';

class PersonalInformationScreen extends ConsumerStatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  ConsumerState<PersonalInformationScreen> createState() => _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends ConsumerState<PersonalInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _loadUserData();
  }

  void _loadUserData() async {
    final userProfile = ref.read(userProfileProvider);
    userProfile.when(
      data: (profile) {
        if (profile != null) {
          setState(() {
            _firstNameController.text = profile['first_name'] ?? '';
            _lastNameController.text = profile['last_name'] ?? '';
            _emailController.text = profile['email'] ?? '';
            _phoneController.text = profile['phone_number'] ?? '';
          });
        }
      },
      loading: () {},
      error: (_, __) {},
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      
      if (userId != null) {
        await supabase.from('profiles').update({
          'first_name': _firstNameController.text.trim(),
          'last_name': _lastNameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone_number': _phoneController.text.trim(),
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', userId);

        // Refresh the user profile provider
        ref.invalidate(userProfileProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Oplysninger opdateret!'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _isEditing = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fejl ved opdatering: ${e.toString()}'),
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
        title: const Text('Personlige oplysninger'),
        backgroundColor: theme.colorScheme.surface,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Image Section
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: theme.colorScheme.primary,
                      child: Text(
                        '${_firstNameController.text.isNotEmpty ? _firstNameController.text[0].toUpperCase() : ''}${_lastNameController.text.isNotEmpty ? _lastNameController.text[0].toUpperCase() : ''}',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    if (_isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            onPressed: () {
                              // TODO: Implement image upload
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Billedupload kommer snart')),
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // First Name
              TextFormField(
                controller: _firstNameController,
                enabled: _isEditing,
                style: TextStyle(
                  color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  labelText: 'Fornavn',
                  labelStyle: TextStyle(
                    color: theme.brightness == Brightness.dark 
                        ? theme.colorScheme.primary 
                        : null,
                  ),
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: theme.brightness == Brightness.dark 
                        ? theme.colorScheme.primary 
                        : null,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: _isEditing 
                      ? (theme.brightness == Brightness.dark ? theme.colorScheme.surface : Colors.white)
                      : (theme.brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade100),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Indtast venligst dit fornavn';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Last Name
              TextFormField(
                controller: _lastNameController,
                enabled: _isEditing,
                style: TextStyle(
                  color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  labelText: 'Efternavn',
                  labelStyle: TextStyle(
                    color: theme.brightness == Brightness.dark 
                        ? theme.colorScheme.primary 
                        : null,
                  ),
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: theme.brightness == Brightness.dark 
                        ? theme.colorScheme.primary 
                        : null,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: _isEditing 
                      ? (theme.brightness == Brightness.dark ? theme.colorScheme.surface : Colors.white)
                      : (theme.brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade100),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Indtast venligst dit efternavn';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Email
              TextFormField(
                controller: _emailController,
                enabled: _isEditing,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(
                  color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(
                    color: theme.brightness == Brightness.dark 
                        ? theme.colorScheme.primary 
                        : null,
                  ),
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: theme.brightness == Brightness.dark 
                        ? theme.colorScheme.primary 
                        : null,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: _isEditing 
                      ? (theme.brightness == Brightness.dark ? theme.colorScheme.surface : Colors.white)
                      : (theme.brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade100),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Indtast venligst din email';
                  }
                  if (!value.contains('@')) {
                    return 'Indtast en gyldig email';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Phone
              TextFormField(
                controller: _phoneController,
                enabled: _isEditing,
                keyboardType: TextInputType.phone,
                style: TextStyle(
                  color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  labelText: 'Telefonnummer',
                  labelStyle: TextStyle(
                    color: theme.brightness == Brightness.dark 
                        ? theme.colorScheme.primary 
                        : null,
                  ),
                  prefixIcon: Icon(
                    Icons.phone_outlined,
                    color: theme.brightness == Brightness.dark 
                        ? theme.colorScheme.primary 
                        : null,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: _isEditing 
                      ? (theme.brightness == Brightness.dark ? theme.colorScheme.surface : Colors.white)
                      : (theme.brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade100),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final cleaned = value.replaceAll(RegExp(r'[^\d+]'), '');
                    if (cleaned.length < 8) {
                      return 'Indtast et gyldigt telefonnummer';
                    }
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 32),
              
              // Action Buttons
              if (_isEditing) ...[
                CustomButton(
                  text: _isLoading ? 'Gemmer...' : 'Gem ændringer',
                  onPressed: _isLoading ? null : _saveChanges,
                  width: double.infinity,
                  icon: Icons.save,
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          setState(() {
                            _isEditing = false;
                            _loadUserData(); // Reload original data
                          });
                        },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Annuller'),
                ),
              ],
              
              const SizedBox(height: 32),
              
              // Additional Info Section
              if (!_isEditing) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark
                        ? Colors.blue.shade900.withOpacity(0.3)
                        : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.brightness == Brightness.dark
                          ? Colors.blue.shade700
                          : Colors.blue.shade200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline, 
                            color: theme.brightness == Brightness.dark
                                ? Colors.blue.shade300
                                : Colors.blue.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Kontooplysninger',
                            style: TextStyle(
                              color: theme.brightness == Brightness.dark
                                  ? Colors.blue.shade300
                                  : Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Din email bruges til at logge ind og modtage vigtige beskeder om dine bookinger.',
                        style: TextStyle(
                          color: theme.brightness == Brightness.dark
                              ? Colors.blue.shade300
                              : Colors.blue.shade700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Dit telefonnummer bruges til at kontakte dig i forbindelse med bookinger.',
                        style: TextStyle(
                          color: theme.brightness == Brightness.dark
                              ? Colors.blue.shade300
                              : Colors.blue.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}