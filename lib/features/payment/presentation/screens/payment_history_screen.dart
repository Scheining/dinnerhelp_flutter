import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../domain/entities/payment_intent.dart';
import '../../domain/entities/refund.dart';
import '../../domain/entities/dispute.dart';
import '../providers/payment_providers.dart';
import '../widgets/refund_request_dialog.dart';

class PaymentHistoryScreen extends ConsumerWidget {
  final String? bookingId;

  const PaymentHistoryScreen({
    Key? key,
    this.bookingId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(bookingId != null ? 'Payment Details' : 'Payment History'),
        elevation: 0,
      ),
      body: bookingId != null
          ? _buildSinglePaymentView(context, ref, bookingId!)
          : _buildPaymentHistoryList(context, ref),
    );
  }

  Widget _buildSinglePaymentView(
    BuildContext context,
    WidgetRef ref,
    String bookingId,
  ) {
    final paymentStatus = ref.watch(paymentStatusProvider(bookingId));

    return paymentStatus.when(
      data: (paymentIntent) => paymentIntent != null
          ? _buildPaymentDetailsView(context, ref, paymentIntent)
          : _buildNoPaymentView(context),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorView(context, error.toString()),
    );
  }

  Widget _buildPaymentDetailsView(
    BuildContext context,
    WidgetRef ref,
    PaymentIntent paymentIntent,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPaymentStatusCard(context, paymentIntent),
          const SizedBox(height: 16),
          _buildPaymentBreakdownCard(context, paymentIntent),
          const SizedBox(height: 16),
          _buildPaymentTimelineCard(context, paymentIntent),
          const SizedBox(height: 16),
          _buildActionsCard(context, ref, paymentIntent),
          const SizedBox(height: 16),
          _buildDisputesSection(context, ref, paymentIntent),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusCard(BuildContext context, PaymentIntent paymentIntent) {
    Color statusColor = Colors.orange;
    IconData statusIcon = Icons.schedule;

    switch (paymentIntent.status) {
      case PaymentIntentStatus.succeeded:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case PaymentIntentStatus.requiresCapture:
        statusColor = Colors.blue;
        statusIcon = Icons.schedule;
        break;
      case PaymentIntentStatus.canceled:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(statusIcon, color: statusColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    paymentIntent.status.displayName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatAmount(paymentIntent.amount),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentBreakdownCard(BuildContext context, PaymentIntent paymentIntent) {
    final baseAmount = paymentIntent.amount - paymentIntent.serviceFeeAmount - paymentIntent.vatAmount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            _buildBreakdownRow('Base Amount', baseAmount),
            _buildBreakdownRow('Service Fee (15%)', paymentIntent.serviceFeeAmount),
            _buildBreakdownRow('VAT (25%)', paymentIntent.vatAmount),
            const Divider(),
            _buildBreakdownRow(
              'Total',
              paymentIntent.amount,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(String label, int amount, {bool isTotal = false}) {
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
            _formatAmount(amount),
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTimelineCard(BuildContext context, PaymentIntent paymentIntent) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Timeline',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            _buildTimelineItem(
              'Payment Created',
              paymentIntent.createdAt,
              Icons.add_circle_outline,
              true,
            ),
            if (paymentIntent.authorizedAt != null)
              _buildTimelineItem(
                'Payment Authorized',
                paymentIntent.authorizedAt!,
                Icons.check_circle_outline,
                true,
              ),
            if (paymentIntent.capturedAt != null)
              _buildTimelineItem(
                'Payment Captured',
                paymentIntent.capturedAt!,
                Icons.monetization_on_outlined,
                true,
              ),
            if (paymentIntent.cancelledAt != null)
              _buildTimelineItem(
                'Payment Cancelled',
                paymentIntent.cancelledAt!,
                Icons.cancel_outlined,
                true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    DateTime dateTime,
    IconData icon,
    bool isCompleted,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: isCompleted ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  _formatDateTime(dateTime),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard(
    BuildContext context,
    WidgetRef ref,
    PaymentIntent paymentIntent,
  ) {
    final canRefund = paymentIntent.status == PaymentIntentStatus.succeeded ||
        paymentIntent.status == PaymentIntentStatus.requiresCapture;

    if (!canRefund) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showRefundDialog(
                  context,
                  paymentIntent.bookingId,
                  paymentIntent.amount,
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Request Refund'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisputesSection(
    BuildContext context,
    WidgetRef ref,
    PaymentIntent paymentIntent,
  ) {
    final disputes = ref.watch(disputesProvider(paymentIntent.id));

    return disputes.when(
      data: (disputeList) => disputeList.isEmpty
          ? const SizedBox.shrink()
          : Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Disputes',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 16),
                    ...disputeList.map(
                      (dispute) => _buildDisputeItem(context, dispute),
                    ),
                  ],
                ),
              ),
            ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildDisputeItem(BuildContext context, Dispute dispute) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.orange.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dispute.reason.displayName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  dispute.status.displayName,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(_formatAmount(dispute.amount)),
        ],
      ),
    );
  }

  Widget _buildPaymentHistoryList(BuildContext context, WidgetRef ref) {
    // This would fetch all payments for the user
    return const Center(
      child: Text('Payment history not yet implemented'),
    );
  }

  Widget _buildNoPaymentView(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.payment, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No payment found for this booking',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          SelectableText.rich(
            TextSpan(
              text: 'Error loading payment details: $error',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showRefundDialog(BuildContext context, String bookingId, int maxAmount) {
    showDialog<Refund>(
      context: context,
      builder: (context) => RefundRequestDialog(
        bookingId: bookingId,
        maxRefundAmount: maxAmount,
      ),
    ).then((refund) {
      if (refund != null) {
        // Refresh payment status after refund
        // ref.refresh(paymentStatusProvider(bookingId));
      }
    });
  }

  String _formatAmount(int amountInOre) {
    final dkk = amountInOre / 100;
    return '${dkk.toStringAsFixed(2)} kr';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}