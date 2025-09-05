import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homechef/models/chef.dart';
import 'package:homechef/models/booking.dart';
import 'package:homechef/widgets/custom_button.dart';
import 'package:homechef/providers/booking_provider.dart';
import 'package:homechef/core/localization/app_localizations_extension.dart';
import 'package:homechef/services/location_service.dart';
import 'package:homechef/widgets/address_autocomplete_field.dart';
import 'package:homechef/services/dawa_address_service.dart';
import 'package:homechef/screens/booking_review_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final Chef chef;

  const BookingScreen({
    super.key,
    required this.chef,
  });

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _guestCount = 2;
  int _hours = 2; // Minimum 2 hours
  String _selectedAddress = '';
  DawaAddress? _selectedAddressDetails;
  String _specialRequests = '';
  List<Map<String, dynamic>> _savedAddresses = [];
  bool _isLoadingAddresses = false;
  bool _useCustomAddress = false;
  Map<String, dynamic>? _selectedSavedAddress;
  final _supabase = Supabase.instance.client;
  
  double get _basePrice => widget.chef.hourlyRate * _hours;
  double get _serviceFee => _basePrice * 0.1;
  double get _tax => (_basePrice + _serviceFee) * 0.25;
  double get _totalPrice => _basePrice + _serviceFee + _tax;

  @override
  void initState() {
    super.initState();
    _loadSavedAddresses();
  }

  Future<void> _loadSavedAddresses() async {
    setState(() {
      _isLoadingAddresses = true;
    });

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        final response = await _supabase
            .from('service_addresses')
            .select()
            .eq('user_id', userId)
            .order('is_default', ascending: false)
            .order('created_at', ascending: false);

        setState(() {
          _savedAddresses = List<Map<String, dynamic>>.from(response);
          // Select default address if available
          if (_savedAddresses.isNotEmpty && _savedAddresses[0]['is_default'] == true) {
            _selectedSavedAddress = _savedAddresses[0];
            _selectedAddress = '${_savedAddresses[0]['address']}, ${_savedAddresses[0]['postal_code']} ${_savedAddresses[0]['city']}';
            _useCustomAddress = false;
          }
        });
      }
    } catch (e) {
      print('Error loading addresses: $e');
    } finally {
      setState(() {
        _isLoadingAddresses = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.bookChef),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chef Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.chef.profileImage,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 60,
                        height: 60,
                        color: theme.colorScheme.primary,
                        child: Icon(
                          Icons.person,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.chef.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          widget.chef.cuisineTypes.join(' • '),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          context.l10n.dkkPerHour(widget.chef.hourlyRate.toInt()),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Duration (hours)
            Text(
              'Varighed',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  const Text('Timer'),
                  const Spacer(),
                  IconButton(
                    onPressed: _hours > 2 ? () => setState(() => _hours--) : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text(
                    _hours.toString(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _hours++),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Date Selection
            Text(
              'Vælg dato og tid',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    context,
                    'Dato',
                    _selectedDate != null 
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : 'Vælg dato',
                    Icons.calendar_today,
                    () => _selectDate(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    context,
                    'Tid',
                    _selectedTime != null 
                        ? _selectedTime!.format(context)
                        : 'Vælg tid',
                    Icons.access_time,
                    () => _selectTime(),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Guest Count
            Text(
              'Antal personer',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.people,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  const Text('Personer'),
                  const Spacer(),
                  IconButton(
                    onPressed: _guestCount > 1 ? () => setState(() => _guestCount--) : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text(
                    _guestCount.toString(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: _guestCount < 12 ? () => setState(() => _guestCount++) : null,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Address with autocomplete
            Text(
              'Leveringsadresse',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            // Show saved addresses if available
            if (_savedAddresses.isNotEmpty) ...[
              // Address selector
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // Saved addresses dropdown
                    if (!_useCustomAddress) ...[
                      DropdownButtonFormField<Map<String, dynamic>>(
                        value: _selectedSavedAddress,
                        decoration: const InputDecoration(
                          labelText: 'Vælg gemt adresse',
                          prefixIcon: Icon(Icons.location_on),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        isExpanded: true,
                        selectedItemBuilder: (BuildContext context) {
                          return _savedAddresses.map<Widget>((address) {
                            return Container(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      address['label'],
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (address['is_default'] == true) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Standard',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.green.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }).toList();
                        },
                        items: _savedAddresses.map((address) {
                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: address,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          address['label'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (address['is_default'] == true) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade100,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            'Standard',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.green.shade800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${address['address']}, ${address['postal_code']} ${address['city']}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSavedAddress = value;
                            if (value != null) {
                              _selectedAddress = '${value['address']}, ${value['postal_code']} ${value['city']}';
                              _selectedAddressDetails = null; // Clear custom address details
                            }
                          });
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.add_location_alt),
                        title: const Text('Brug anden adresse'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          setState(() {
                            _useCustomAddress = true;
                            _selectedSavedAddress = null;
                            _selectedAddress = '';
                          });
                        },
                      ),
                    ],
                    
                    // Custom address input
                    if (_useCustomAddress) ...[
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            AddressAutocompleteField(
                              initialValue: _selectedAddress,
                              labelText: 'Indtast adresse',
                              hintText: 'Skriv adresse her...',
                              onAddressSelected: (address) {
                                setState(() {
                                  _selectedAddress = address.fullAddress;
                                  _selectedAddressDetails = address;
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _useCustomAddress = false;
                                  if (_savedAddresses.isNotEmpty) {
                                    _selectedSavedAddress = _savedAddresses[0];
                                    _selectedAddress = '${_savedAddresses[0]['address']}, ${_savedAddresses[0]['postal_code']} ${_savedAddresses[0]['city']}';
                                  }
                                  _selectedAddressDetails = null;
                                });
                              },
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Tilbage til gemte adresser'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ] else ...[
              // No saved addresses - show normal input
              AddressAutocompleteField(
                initialValue: _selectedAddress,
                labelText: 'Adresse',
                hintText: 'Indtast adresse...',
                onAddressSelected: (address) {
                  setState(() {
                    _selectedAddress = address.fullAddress;
                    _selectedAddressDetails = address;
                  });
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tip: Gem dine adresser i din profil for hurtigere booking',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Special Requests
            Text(
              'Særlige ønsker (valgfrit)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                hintText: 'Evt. kostbegrænsninger, præferencer eller særlige ønsker...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.primary),
                ),
              ),
              maxLines: 3,
              onChanged: (value) => _specialRequests = value,
            ),
            
            const SizedBox(height: 32),
            
            // Price Breakdown
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Prisberegning',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPriceRow('Service (${_hours} timer)', '${_basePrice.toStringAsFixed(0)} kr'),
                  
                  _buildPriceRow('Servicegebyr', '${_serviceFee.toStringAsFixed(0)} kr'),
                  _buildPriceRow('Moms (25%)', '${_tax.toStringAsFixed(0)} kr'),
                  const Divider(),
                  _buildPriceRow(
                    'Total',
                    '${_totalPrice.toStringAsFixed(0)} kr',
                    isTotal: true,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_canBooking())
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _getValidationMessage(),
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 12,
                    ),
                  ),
                ),
              CustomButton(
                text: 'Næste: Gennemgå booking',
                width: double.infinity,
                onPressed: _canBooking() ? _confirmBooking : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String value, IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount, {bool isTotal = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)
                : theme.textTheme.bodyMedium,
          ),
          Text(
            amount,
            style: isTotal
                ? theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  )
                : theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  bool _canBooking() {
    return _selectedDate != null && 
           _selectedTime != null && 
           _selectedAddress.isNotEmpty;
  }

  String _getValidationMessage() {
    if (_selectedDate == null) {
      return 'Vælg venligst en dato';
    }
    if (_selectedTime == null) {
      return 'Vælg venligst et tidspunkt';
    }
    if (_selectedAddress.isEmpty) {
      return 'Indtast venligst en adresse';
    }
    return '';
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 18, minute: 0),
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  Future<void> _confirmBooking() async {
    if (!_canBooking()) return;

    // Navigate to review screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingReviewScreen(
          chef: widget.chef,
          bookingDate: _selectedDate!,
          bookingTime: _selectedTime!,
          guestCount: _guestCount,
          hours: _hours,
          address: _selectedAddress,
          addressDetails: _selectedAddressDetails,
          specialRequests: _specialRequests.isNotEmpty ? _specialRequests : null,
          basePrice: _basePrice,
          serviceFee: _serviceFee,
          tax: _tax,
          totalPrice: _totalPrice,
        ),
      ),
    );
  }

  Future<void> _showAddressOptions() async {
    final theme = Theme.of(context);
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.my_location, color: theme.colorScheme.primary),
                title: const Text('Use current location'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _useCurrentLocation();
                },
              ),
              ListTile(
                leading: Icon(Icons.edit_location_alt, color: theme.colorScheme.primary),
                title: const Text('Enter address manually'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _enterAddressManually();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _useCurrentLocation() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Getting location...'),
            ],
          ),
        ),
      );
      final data = await LocationService.getCurrentLocationData();
      if (!mounted) return;
      Navigator.of(context).pop();
      setState(() {
        _selectedAddress = data.address;
      });
    } catch (e) {
      if (mounted) {
        Navigator.of(context).maybePop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to get location: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _enterAddressManually() async {
    final controller = TextEditingController(text: _selectedAddress);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter service address'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Street, number, postal code, city',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() {
        _selectedAddress = result;
      });
    }
  }
}