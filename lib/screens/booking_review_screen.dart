import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homechef/models/chef.dart';
import 'package:homechef/widgets/custom_button.dart';
import 'package:homechef/providers/booking_provider.dart';
import 'package:homechef/screens/payment_screen.dart';
import 'package:homechef/services/dawa_address_service.dart';

class BookingReviewScreen extends ConsumerStatefulWidget {
  final Chef chef;
  final DateTime bookingDate;
  final TimeOfDay bookingTime;
  final int guestCount;
  final int hours;
  final String address;
  final DawaAddress? addressDetails;
  final String? specialRequests;
  final double basePrice;
  final double serviceFee;
  final double tax;
  final double totalPrice;

  const BookingReviewScreen({
    super.key,
    required this.chef,
    required this.bookingDate,
    required this.bookingTime,
    required this.guestCount,
    required this.hours,
    required this.address,
    this.addressDetails,
    this.specialRequests,
    required this.basePrice,
    required this.serviceFee,
    required this.tax,
    required this.totalPrice,
  });

  @override
  ConsumerState<BookingReviewScreen> createState() => _BookingReviewScreenState();
}

class _BookingReviewScreenState extends ConsumerState<BookingReviewScreen> {
  bool _agreedToTerms = false;
  bool _agreedToCancellationPolicy = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gennemgå booking'),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bookingdetaljer',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    Icons.person,
                    'Kok',
                    widget.chef.name,
                    theme,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.calendar_today,
                    'Dato',
                    '${widget.bookingDate.day}/${widget.bookingDate.month}/${widget.bookingDate.year}',
                    theme,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.access_time,
                    'Tid',
                    widget.bookingTime.format(context),
                    theme,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.timer,
                    'Varighed',
                    '${widget.hours} timer',
                    theme,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.people,
                    'Antal personer',
                    '${widget.guestCount} personer',
                    theme,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Delivery Address
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
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Leveringsadresse',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.address,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            if (widget.specialRequests != null && widget.specialRequests!.isNotEmpty) ...[
              const SizedBox(height: 24),
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
                    Row(
                      children: [
                        Icon(
                          Icons.note,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Særlige ønsker',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.specialRequests!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

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
                    'Prisdetaljer',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPriceRow('Kokkens pris (${widget.hours} timer)', '${widget.basePrice.toStringAsFixed(0)} kr'),
                  _buildPriceRow('Servicegebyr', '${widget.serviceFee.toStringAsFixed(0)} kr'),
                  _buildPriceRow('Moms (25%)', '${widget.tax.toStringAsFixed(0)} kr'),
                  const Divider(height: 24),
                  _buildPriceRow(
                    'Total',
                    '${widget.totalPrice.toStringAsFixed(0)} kr',
                    isTotal: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Terms and Conditions
            Container(
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
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Vigtig information',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• Bookingen er først bekræftet når kokken accepterer\n'
                    '• Du vil modtage en notifikation når kokken svarer\n'
                    '• Betaling sker først når kokken har accepteret\n'
                    '• Gratis afbestilling op til 48 timer før',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.blue.shade700,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Agreement Checkboxes
            CheckboxListTile(
              value: _agreedToTerms,
              onChanged: (value) => setState(() => _agreedToTerms = value ?? false),
              title: Text(
                'Jeg accepterer vilkår og betingelser',
                style: theme.textTheme.bodyMedium,
              ),
              subtitle: Text(
                'Læs vores vilkår og betingelser',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),

            CheckboxListTile(
              value: _agreedToCancellationPolicy,
              onChanged: (value) => setState(() => _agreedToCancellationPolicy = value ?? false),
              title: Text(
                'Jeg forstår afbestillingspolitikken',
                style: theme.textTheme.bodyMedium,
              ),
              subtitle: Text(
                'Gratis afbestilling op til 48 timer før bookingen',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total at betale',
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    '${widget.totalPrice.toStringAsFixed(0)} kr',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Fortsæt til betaling',
                width: double.infinity,
                onPressed: (_agreedToTerms && _agreedToCancellationPolicy) 
                    ? () => _proceedToPayment() 
                    : null,
                icon: Icons.payment,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
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

  void _proceedToPayment() {
    // Navigate to payment screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          chef: widget.chef,
          bookingDate: widget.bookingDate,
          bookingTime: widget.bookingTime,
          guestCount: widget.guestCount,
          hours: widget.hours,
          address: widget.address,
          addressDetails: widget.addressDetails,
          specialRequests: widget.specialRequests,
          totalAmount: widget.totalPrice,
        ),
      ),
    );
  }
}