import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homechef/models/chef.dart';
import 'package:homechef/models/booking.dart';
import 'package:homechef/widgets/custom_button.dart';
import 'package:homechef/providers/booking_provider.dart';
import 'package:homechef/services/dawa_address_service.dart';
import 'package:homechef/services/stripe_service.dart';
import 'package:homechef/services/chef_availability_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final Chef chef;
  final DateTime bookingDate;
  final TimeOfDay bookingTime;
  final int guestCount;
  final int hours;
  final String address;
  final DawaAddress? addressDetails;
  final String? specialRequests;
  final double totalAmount;

  const PaymentScreen({
    super.key,
    required this.chef,
    required this.bookingDate,
    required this.bookingTime,
    required this.guestCount,
    required this.hours,
    required this.address,
    this.addressDetails,
    this.specialRequests,
    required this.totalAmount,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  bool _isProcessing = false;
  bool _isCheckingAvailability = true;
  String? _availabilityError;
  final _stripeService = StripeService.instance;
  final _supabaseClient = Supabase.instance.client;
  final _availabilityService = ChefAvailabilityService();

  @override
  void initState() {
    super.initState();
    _checkInitialAvailability();
  }

  Future<void> _checkInitialAvailability() async {
    try {
      final availabilityCheck = await _availabilityService.checkAvailability(
        chefId: widget.chef.id,
        bookingDate: widget.bookingDate,
        startTime: widget.bookingTime,
        durationHours: widget.hours,
      );
      
      if (!availabilityCheck.isAvailable) {
        setState(() {
          _availabilityError = availabilityCheck.message;
        });
      }
    } catch (e) {
      setState(() {
        _availabilityError = 'Kunne ikke kontrollere tilgængelighed';
      });
    } finally {
      setState(() {
        _isCheckingAvailability = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Calculate amounts in øre (Danish cents)
    final baseAmount = (widget.chef.hourlyRate * widget.hours * 100).toInt();
    final serviceFeeAmount = (baseAmount * 0.1).toInt();
    final vatAmount = ((baseAmount + serviceFeeAmount) * 0.25).toInt();
    final totalAmountInOre = baseAmount + serviceFeeAmount + vatAmount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Betaling'),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: _isCheckingAvailability
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show availability error if exists
            if (_availabilityError != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade700,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Booking ikke mulig',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _availabilityError!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Booking Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                              '${widget.bookingDate.day}/${widget.bookingDate.month}/${widget.bookingDate.year} kl. ${widget.bookingTime.format(context)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              '${widget.guestCount} gæster • ${widget.hours} timer',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildPriceRow('Service (${widget.hours} timer)', '${(baseAmount / 100).toStringAsFixed(0)} kr'),
                  _buildPriceRow('Servicegebyr', '${(serviceFeeAmount / 100).toStringAsFixed(0)} kr'),
                  _buildPriceRow('Moms (25%)', '${(vatAmount / 100).toStringAsFixed(0)} kr'),
                  const Divider(),
                  _buildPriceRow(
                    'Total',
                    '${(totalAmountInOre / 100).toStringAsFixed(0)} kr',
                    isTotal: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Location Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Adresse',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.address,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (widget.specialRequests?.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.note,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Særlige ønsker',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.specialRequests!,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Payment Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sådan fungerer betalingen',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Du betaler sikkert med kort eller Apple/Google Pay\n'
                          '• Beløbet reserveres nu og trækkes efter service\n'
                          '• Fuld refundering ved aflysning 24+ timer før',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Security badges
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSecurityBadge(Icons.lock, 'Sikker betaling'),
                const SizedBox(width: 16),
                _buildSecurityBadge(Icons.verified_user, 'Stripe verificeret'),
                const SizedBox(width: 16),
                _buildSecurityBadge(Icons.security, 'SSL krypteret'),
              ],
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
          child: CustomButton(
            text: _isProcessing 
                ? 'Behandler...' 
                : _availabilityError != null
                    ? 'Booking ikke tilgængelig'
                    : 'Betal ${(totalAmountInOre / 100).toStringAsFixed(0)} kr',
            width: double.infinity,
            onPressed: _isProcessing || _availabilityError != null
                ? null 
                : () => _processPaymentWithStripe(
                    totalAmountInOre,
                    baseAmount,
                    serviceFeeAmount,
                    vatAmount,
                  ),
            icon: _isProcessing ? null : Icons.lock,
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityBadge(IconData icon, String label) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: Colors.grey.shade600,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Future<void> _processPaymentWithStripe(
    int totalAmountInOre,
    int baseAmount,
    int serviceFeeAmount,
    int vatAmount,
  ) async {
    setState(() => _isProcessing = true);

    String? bookingId;
    
    try {
      // Create booking date time
      final DateTime bookingDateTime = DateTime(
        widget.bookingDate.year,
        widget.bookingDate.month,
        widget.bookingDate.day,
        widget.bookingTime.hour,
        widget.bookingTime.minute,
      );

      // Check chef availability FIRST
      final availabilityCheck = await _availabilityService.checkAvailability(
        chefId: widget.chef.id,
        bookingDate: widget.bookingDate,
        startTime: widget.bookingTime,
        durationHours: widget.hours,
      );
      
      if (!availabilityCheck.isAvailable) {
        throw Exception(availabilityCheck.message ?? 'Kokken er ikke tilgængelig på det valgte tidspunkt');
      }

      // Generate a booking ID
      bookingId = const Uuid().v4();
      
      // Get current user
      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Check if chef has a Stripe account
      final chefResponse = await _supabaseClient
          .from('chefs')
          .select('stripe_account_id')
          .eq('id', widget.chef.id)
          .maybeSingle();
      
      final chefStripeAccountId = chefResponse?['stripe_account_id'];
      
      if (chefStripeAccountId == null || chefStripeAccountId.toString().isEmpty) {
        throw Exception('Kokken er ikke klar til at modtage betalinger endnu. Prøv igen senere.');
      }

      // Calculate end time
      final endTime = TimeOfDay(
        hour: (widget.bookingTime.hour + widget.hours) % 24,
        minute: widget.bookingTime.minute,
      );

      // First create the booking in database with pending payment status
      final bookingResponse = await _supabaseClient.from('bookings').insert({
        'id': bookingId,
        'user_id': user.id,
        'chef_id': widget.chef.id,
        'date': bookingDateTime.toIso8601String().split('T')[0],
        'start_time': '${widget.bookingTime.hour.toString().padLeft(2, '0')}:${widget.bookingTime.minute.toString().padLeft(2, '0')}:00',
        'end_time': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}:00',
        'status': 'pending',
        'number_of_guests': widget.guestCount,
        'total_amount': totalAmountInOre,
        'payment_status': 'pending',
        'address': widget.address,
        'notes': widget.specialRequests,
        'is_recurring': false,
        'platform_fee': serviceFeeAmount,
      }).select().single();

      // Create payment intent via Edge Function
      final clientSecret = await _stripeService.createPaymentIntent(
        bookingId: bookingId,
        amount: totalAmountInOre,
        serviceFeeAmount: serviceFeeAmount,
        vatAmount: vatAmount,
        chefId: widget.chef.id,
      );

      // Initialize payment sheet
      await _stripeService.initPaymentSheet(
        clientSecret: clientSecret,
        customerEmail: user.email ?? '',
        merchantDisplayName: 'DinnerHelp',
      );

      // Present payment sheet
      final paymentSuccess = await _stripeService.presentPaymentSheet();

      if (!paymentSuccess) {
        // If payment was cancelled, delete the booking
        if (bookingId != null) {
          await _supabaseClient.from('bookings').delete().eq('id', bookingId);
        }
        setState(() => _isProcessing = false);
        return;
      }

      // Payment successful, update the booking payment status
      await _supabaseClient.from('bookings').update({
        'payment_status': 'succeeded',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', bookingId);

      // Send booking confirmation emails
      try {
        // Get user profile for name
        final userProfile = await _supabaseClient
            .from('profiles')
            .select('first_name, last_name')
            .eq('id', user.id)
            .single();
        
        final userName = '${userProfile['first_name'] ?? ''} ${userProfile['last_name'] ?? ''}'.trim();
        
        // Send confirmation email to user
        await _supabaseClient.functions.invoke(
          'send-booking-confirmation',
          body: {
            'bookingId': bookingId,
            'userEmail': user.email,
            'userName': userName.isEmpty ? 'Kunde' : userName,
            'chefName': widget.chef.name,
            'bookingDate': widget.bookingDate.toIso8601String(),
            'bookingTime': widget.bookingTime.format(context),
            'guestCount': widget.guestCount,
            'address': widget.address,
            'totalAmount': totalAmountInOre / 100,
            'notes': widget.specialRequests,
          },
        );
        
        // Get chef email
        final chefProfile = await _supabaseClient
            .from('profiles')
            .select('email, first_name, last_name')
            .eq('id', widget.chef.id)
            .single();
        
        final chefEmail = chefProfile['email'];
        final chefFullName = '${chefProfile['first_name'] ?? ''} ${chefProfile['last_name'] ?? ''}'.trim();
        
        // Send notification email to chef
        if (chefEmail != null) {
          await _supabaseClient.functions.invoke(
            'send-chef-booking-notification',
            body: {
              'bookingId': bookingId,
              'chefEmail': chefEmail,
              'chefName': chefFullName.isEmpty ? widget.chef.name : chefFullName,
              'userName': userName.isEmpty ? 'Kunde' : userName,
              'bookingDate': widget.bookingDate.toIso8601String(),
              'bookingTime': widget.bookingTime.format(context),
              'guestCount': widget.guestCount,
              'address': widget.address,
              'totalAmount': totalAmountInOre / 100,
              'notes': widget.specialRequests,
            },
          );
        }
      } catch (emailError) {
        // Log error but don't fail the booking
        print('Failed to send confirmation emails: $emailError');
      }

      if (!mounted) return;

      // Navigate to success screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BookingSuccessScreen(
            bookingId: bookingId!,
            chefName: widget.chef.name,
            bookingDate: widget.bookingDate,
            bookingTime: widget.bookingTime,
            totalAmount: totalAmountInOre / 100,
          ),
        ),
      );
    } catch (error) {
      // If there was an error and booking was created, delete it
      if (bookingId != null) {
        try {
          await _supabaseClient.from('bookings').delete().eq('id', bookingId);
        } catch (deleteError) {
          debugPrint('Error deleting failed booking: $deleteError');
        }
      }
      
      setState(() => _isProcessing = false);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Betaling fejlede: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class BookingSuccessScreen extends StatelessWidget {
  final String bookingId;
  final String chefName;
  final DateTime bookingDate;
  final TimeOfDay bookingTime;
  final double totalAmount;

  const BookingSuccessScreen({
    super.key,
    required this.bookingId,
    required this.chefName,
    required this.bookingDate,
    required this.bookingTime,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 80,
                  color: Colors.green.shade600,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Booking bekræftet!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Din booking er blevet oprettet og afventer kokkens godkendelse',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Booking ID', bookingId.substring(0, 8).toUpperCase()),
                    const SizedBox(height: 12),
                    _buildDetailRow('Kok', chefName),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'Dato',
                      '${bookingDate.day}/${bookingDate.month}/${bookingDate.year}',
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow('Tid', bookingTime.format(context)),
                    const SizedBox(height: 12),
                    _buildDetailRow('Betalt', '${totalAmount.toStringAsFixed(0)} kr'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.email,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email bekræftelse sendt! 📧',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Vi har sendt booking detaljerne til din email adresse',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Gå til mine bookinger'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Tilbage til forsiden'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}