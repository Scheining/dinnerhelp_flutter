import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/payment_intent.dart';
import '../providers/payment_providers.dart';
import '../widgets/payment_method_selector.dart';
import '../widgets/payment_processing_screen.dart';

/// Complete payment flow integration example
/// 
/// This demonstrates the full DinnerHelp payment process:
/// 1. Calculate payment amount with fees
/// 2. Select payment method
/// 3. Create payment intent
/// 4. Authorize payment (reserve funds)
/// 5. Show success/authorized state
/// 
/// Payment capture happens after booking completion (separate flow)
class PaymentIntegrationExample extends HookConsumerWidget {
  final String bookingId;
  final int baseAmount; // in øre (Danish cents)
  final String chefStripeAccountId;
  final DateTime eventDate;

  const PaymentIntegrationExample({
    Key? key,
    required this.bookingId,
    required this.baseAmount,
    required this.chefStripeAccountId,
    required this.eventDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStep = useState(PaymentStep.calculation);
    final selectedPaymentMethod = useState<PaymentMethod?>(null);
    final paymentIntent = useState<PaymentIntent?>(null);
    
    final paymentFlowState = ref.watch(paymentFlowProvider);

    // Calculate payment amounts
    final calculation = ref.watch(calculatePaymentProvider(
      baseAmount: baseAmount,
      eventDate: eventDate,
    ));

    // Listen to payment flow state changes
    ref.listen<PaymentFlowState>(paymentFlowProvider, (previous, next) {
      switch (next) {
        case PaymentFlowPaymentIntentCreated(:final paymentIntent):
          currentStep.value = PaymentStep.authorization;
          this.paymentIntent.value = paymentIntent;
          break;
        case PaymentFlowPaymentAuthorized(:final paymentIntent):
          currentStep.value = PaymentStep.success;
          this.paymentIntent.value = paymentIntent;
          break;
        case PaymentFlowError():
          currentStep.value = PaymentStep.error;
          break;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _buildCurrentStep(
        context,
        ref,
        currentStep.value,
        calculation,
        selectedPaymentMethod,
        paymentIntent.value,
        paymentFlowState,
      ),
    );
  }

  Widget _buildCurrentStep(
    BuildContext context,
    WidgetRef ref,
    PaymentStep step,
    calculation,
    ValueNotifier<PaymentMethod?> selectedPaymentMethod,
    PaymentIntent? paymentIntent,
    PaymentFlowState paymentFlowState,
  ) {
    switch (step) {
      case PaymentStep.calculation:
        return _buildCalculationStep(context, calculation, selectedPaymentMethod);
      case PaymentStep.authorization:
      case PaymentStep.processing:
        return PaymentProcessingScreen(
          bookingId: bookingId,
          paymentIntent: paymentIntent,
          onSuccess: () => Navigator.of(context).pop(true),
          onCancel: () => Navigator.of(context).pop(false),
        );
      case PaymentStep.success:
        return _buildSuccessStep(context, paymentIntent!);
      case PaymentStep.error:
        return _buildErrorStep(context, ref, paymentFlowState);
    }
  }

  Widget _buildCalculationStep(
    BuildContext context,
    calculation,
    ValueNotifier<PaymentMethod?> selectedPaymentMethod,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payment breakdown card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Summary',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryRow('Base Amount', calculation.formattedBaseAmount),
                  _buildSummaryRow('Service Fee (15%)', calculation.formattedServiceFee),
                  _buildSummaryRow('VAT (25%)', calculation.formattedVatAmount),
                  if (calculation.hasHolidayCharges) ...[
                    const Divider(),
                    if (calculation.bankHolidayDate != null)
                      _buildSummaryRow(
                        'Holiday Surcharge',
                        '${calculation.bankHolidayExtraCharge}%',
                      ),
                    if (calculation.newYearEveDate != null)
                      _buildSummaryRow(
                        'New Year\'s Eve Surcharge',
                        '${calculation.newYearEveExtraCharge}%',
                      ),
                  ],
                  const Divider(thickness: 2),
                  _buildSummaryRow(
                    'Total Amount',
                    calculation.formattedTotalAmount,
                    isTotal: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Payment method selection
          PaymentMethodSelector(
            onPaymentMethodSelected: (method) {
              selectedPaymentMethod.value = method;
            },
            selectedPaymentMethod: selectedPaymentMethod.value,
          ),
          const SizedBox(height: 32),

          // Continue button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedPaymentMethod.value != null
                  ? () => _handlePayment(context, ref, calculation)
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Authorize Payment',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Payment security notice
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.security, color: Colors.blue.shade600, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your payment will be authorized (reserved) now and charged after your dining experience.',
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessStep(BuildContext context, PaymentIntent paymentIntent) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                size: 50,
                color: Colors.green.shade600,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Payment Authorized!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your payment has been authorized successfully. The final amount will be charged after your dining experience.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Continue to Booking'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorStep(
    BuildContext context,
    WidgetRef ref,
    PaymentFlowState state,
  ) {
    final errorMessage = state is PaymentFlowError ? state.message : 'An error occurred';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error,
                size: 50,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Payment Failed',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade700,
                  ),
            ),
            const SizedBox(height: 16),
            SelectableText.rich(
              TextSpan(
                text: errorMessage,
                style: TextStyle(color: Colors.red.shade600),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    ref.read(paymentFlowProvider.notifier).reset();
                    // Navigate back to calculation step
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Try Again'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handlePayment(BuildContext context, WidgetRef ref, calculation) async {
    try {
      // Create payment intent
      await ref.read(paymentFlowProvider.notifier).createPaymentIntent(
            bookingId: bookingId,
            baseAmount: baseAmount,
            chefStripeAccountId: chefStripeAccountId,
            eventDate: eventDate,
          );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

enum PaymentStep {
  calculation,
  authorization,
  processing,
  success,
  error,
}