import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../domain/entities/payment_intent.dart';

class PaymentProcessingScreen extends HookConsumerWidget {
  final String bookingId;
  final PaymentIntent? paymentIntent;
  final VoidCallback onSuccess;
  final VoidCallback onCancel;

  const PaymentProcessingScreen({
    Key? key,
    required this.bookingId,
    this.paymentIntent,
    required this.onSuccess,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animationController = useAnimationController(
      duration: const Duration(seconds: 2),
    );

    useEffect(() {
      animationController.repeat();
      return () => animationController.dispose();
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Processing Payment'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatusIcon(context, paymentIntent?.status, animationController),
            const SizedBox(height: 32),
            _buildStatusTitle(context, paymentIntent?.status),
            const SizedBox(height: 16),
            _buildStatusDescription(context, paymentIntent?.status),
            const SizedBox(height: 32),
            _buildPaymentDetails(context, paymentIntent),
            const Spacer(),
            _buildActionButtons(context, paymentIntent?.status),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(
    BuildContext context,
    PaymentIntentStatus? status,
    AnimationController animationController,
  ) {
    if (status == null || status.isProcessing) {
      return AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          return Transform.rotate(
            angle: animationController.value * 2 * 3.14159,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 3,
                ),
              ),
              child: Icon(
                Icons.credit_card,
                size: 40,
                color: Theme.of(context).primaryColor,
              ),
            ),
          );
        },
      );
    }

    if (status.isSuccessful) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.green.shade100,
        ),
        child: Icon(
          Icons.check_circle,
          size: 50,
          color: Colors.green.shade600,
        ),
      );
    }

    if (status.isAuthorized) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.orange.shade100,
        ),
        child: Icon(
          Icons.schedule,
          size: 50,
          color: Colors.orange.shade600,
        ),
      );
    }

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.red.shade100,
      ),
      child: Icon(
        Icons.error,
        size: 50,
        color: Colors.red.shade600,
      ),
    );
  }

  Widget _buildStatusTitle(BuildContext context, PaymentIntentStatus? status) {
    String title = 'Processing Payment...';

    if (status != null) {
      switch (status) {
        case PaymentIntentStatus.succeeded:
          title = 'Payment Successful!';
          break;
        case PaymentIntentStatus.requiresCapture:
          title = 'Payment Authorized';
          break;
        case PaymentIntentStatus.canceled:
          title = 'Payment Cancelled';
          break;
        case PaymentIntentStatus.requiresAction:
          title = 'Action Required';
          break;
        default:
          title = 'Processing Payment...';
      }
    }

    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildStatusDescription(BuildContext context, PaymentIntentStatus? status) {
    String description = 'Please wait while we process your payment securely.';

    if (status != null) {
      switch (status) {
        case PaymentIntentStatus.succeeded:
          description = 'Your payment has been processed successfully. You will receive a confirmation email shortly.';
          break;
        case PaymentIntentStatus.requiresCapture:
          description = 'Your payment has been authorized. The final amount will be charged after your dining experience.';
          break;
        case PaymentIntentStatus.canceled:
          description = 'Your payment has been cancelled. No charges were made to your account.';
          break;
        case PaymentIntentStatus.requiresAction:
          description = 'Additional authentication is required to complete your payment.';
          break;
        default:
          description = 'Please wait while we process your payment securely.';
      }
    }

    return Text(
      description,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey.shade600,
          ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildPaymentDetails(BuildContext context, PaymentIntent? paymentIntent) {
    if (paymentIntent == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Details',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Amount', _formatAmount(paymentIntent.amount)),
          _buildDetailRow('Service Fee', _formatAmount(paymentIntent.serviceFeeAmount)),
          _buildDetailRow('VAT', _formatAmount(paymentIntent.vatAmount)),
          const Divider(),
          _buildDetailRow(
            'Total',
            _formatAmount(paymentIntent.amount),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, PaymentIntentStatus? status) {
    if (status == null || status.isProcessing) {
      return ElevatedButton(
        onPressed: onCancel,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          backgroundColor: Colors.grey,
        ),
        child: const Text('Cancel'),
      );
    }

    if (status.isSuccessful || status.isAuthorized) {
      return ElevatedButton(
        onPressed: onSuccess,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
        ),
        child: const Text('Continue'),
      );
    }

    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            // Retry payment
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
          child: const Text('Retry Payment'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: onCancel,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  String _formatAmount(int amountInOre) {
    final dkk = amountInOre / 100;
    return '${dkk.toStringAsFixed(2)} kr';
  }
}