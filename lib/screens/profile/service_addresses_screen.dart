import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homechef/widgets/custom_button.dart';

class ServiceAddressesScreen extends ConsumerStatefulWidget {
  const ServiceAddressesScreen({super.key});

  @override
  ConsumerState<ServiceAddressesScreen> createState() => _ServiceAddressesScreenState();
}

class _ServiceAddressesScreenState extends ConsumerState<ServiceAddressesScreen> {
  List<Map<String, dynamic>> _addresses = [];
  bool _isLoading = true;
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final userId = _supabase.auth.currentUser?.id;
      
      if (userId != null) {
        final response = await _supabase
            .from('service_addresses')
            .select()
            .eq('user_id', userId)
            .order('is_default', ascending: false)
            .order('created_at', ascending: false);

        setState(() {
          _addresses = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fejl ved indlæsning af adresser: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveAddress({
    String? addressId,
    required String label,
    required String address,
    required String city,
    required String postalCode,
    required bool isDefault,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      if (addressId != null) {
        // Update existing address
        await _supabase
            .from('service_addresses')
            .update({
              'label': label,
              'address': address,
              'city': city,
              'postal_code': postalCode,
              'is_default': isDefault,
            })
            .eq('id', addressId);
      } else {
        // Insert new address
        await _supabase
            .from('service_addresses')
            .insert({
              'user_id': userId,
              'label': label,
              'address': address,
              'city': city,
              'postal_code': postalCode,
              'is_default': isDefault,
            });
      }

      // Reload addresses
      await _loadAddresses();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fejl ved gemning: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteAddress(String addressId) async {
    try {
      await _supabase
          .from('service_addresses')
          .delete()
          .eq('id', addressId);

      // Reload addresses
      await _loadAddresses();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Adresse slettet'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fejl ved sletning: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _setAsDefault(String addressId) async {
    try {
      await _supabase
          .from('service_addresses')
          .update({'is_default': true})
          .eq('id', addressId);

      // Reload addresses
      await _loadAddresses();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fejl ved opdatering: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddEditDialog({Map<String, dynamic>? address}) {
    final isEdit = address != null;
    final labelController = TextEditingController(text: address?['label'] ?? '');
    final addressController = TextEditingController(text: address?['address'] ?? '');
    final cityController = TextEditingController(text: address?['city'] ?? '');
    final postalCodeController = TextEditingController(text: address?['postal_code'] ?? '');
    bool isDefault = address?['is_default'] ?? false;
    final addressId = address?['id'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Rediger adresse' : 'Tilføj adresse'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: labelController,
                  decoration: const InputDecoration(
                    labelText: 'Navn (f.eks. Hjem, Sommerhus, Arbejde)',
                    prefixIcon: Icon(Icons.label_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Adresse',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: cityController,
                        decoration: const InputDecoration(
                          labelText: 'By',
                          prefixIcon: Icon(Icons.location_city),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: postalCodeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Postnr.',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Brug som standardadresse'),
                  value: isDefault,
                  onChanged: (value) {
                    setDialogState(() {
                      isDefault = value ?? false;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuller'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (labelController.text.isEmpty || 
                    addressController.text.isEmpty || 
                    cityController.text.isEmpty || 
                    postalCodeController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Udfyld venligst alle felter'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                
                Navigator.of(context).pop();
                
                await _saveAddress(
                  addressId: addressId,
                  label: labelController.text,
                  address: addressController.text,
                  city: cityController.text,
                  postalCode: postalCodeController.text,
                  isDefault: isDefault,
                );
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEdit ? 'Adresse opdateret' : 'Adresse tilføjet'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Gem'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteAddress(String addressId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Slet adresse'),
        content: const Text('Er du sikker på, at du vil slette denne adresse?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuller'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteAddress(addressId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Slet'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mine adresser'),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _addresses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off_outlined,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ingen adresser gemt',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tilføj en adresse hvor kokken kan komme og lave mad',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Tilføj adresse',
                        onPressed: () => _showAddEditDialog(),
                        icon: Icons.add_location_alt,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _addresses.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _addresses.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: CustomButton(
                          text: 'Tilføj ny adresse',
                          onPressed: () => _showAddEditDialog(),
                          icon: Icons.add_location_alt,
                          width: double.infinity,
                        ),
                      );
                    }

                    final address = _addresses[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: address['is_default']
                              ? theme.colorScheme.primary
                              : Colors.grey.shade300,
                          child: Icon(
                            Icons.location_on,
                            color: address['is_default']
                                ? Colors.white
                                : Colors.grey.shade600,
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              address['label'],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (address['is_default']) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Standard',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(
                          '${address['address']}\n${address['postal_code']} ${address['city']}',
                        ),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showAddEditDialog(address: address);
                            } else if (value == 'delete') {
                              _confirmDeleteAddress(address['id']);
                            } else if (value == 'default') {
                              _setAsDefault(address['id']);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: ListTile(
                                leading: Icon(Icons.edit),
                                title: Text('Rediger'),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            if (!address['is_default'])
                              const PopupMenuItem(
                                value: 'default',
                                child: ListTile(
                                  leading: Icon(Icons.star_outline),
                                  title: Text('Sæt som standard'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: ListTile(
                                leading: Icon(Icons.delete, color: Colors.red),
                                title: Text('Slet', style: TextStyle(color: Colors.red)),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}