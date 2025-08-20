import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../domain/entities/refund.dart';
import '../providers/payment_providers.dart';

class RefundRequestDialog extends HookConsumerWidget {
  final String bookingId;
  final int maxRefundAmount; // in øre
  final bool allowPartialRefund;

  const RefundRequestDialog({
    Key? key,
    required this.bookingId,
    required this.maxRefundAmount,
    this.allowPartialRefund = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedReason = useState<RefundReason?>(null);
    final refundAmount = useState<int?>(null);
    final description = useTextEditingController();
    final isProcessing = useState(false);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Request Refund',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 24),
            
            // Refund amount section
            if (allowPartialRefund) ...[
              Text(
                'Refund Amount',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<int?>(
                      title: const Text('Full Refund'),
                      subtitle: Text(_formatAmount(maxRefundAmount)),
                      value: null,
                      groupValue: refundAmount.value,
                      onChanged: (value) => refundAmount.value = value,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              RadioListTile<int>(
                title: const Text('Partial Refund'),
                value: maxRefundAmount ~/ 2,
                groupValue: refundAmount.value,
                onChanged: (value) => refundAmount.value = value,
                contentPadding: EdgeInsets.zero,
              ),
              if (refundAmount.value != null) ...[
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _formatAmountInput(refundAmount.value!),
                  decoration: const InputDecoration(
                    labelText: 'Custom Amount (DKK)',
                    border: OutlineInputBorder(),
                    prefixText: 'kr ',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final amount = _parseAmount(value);
                    if (amount != null && amount <= maxRefundAmount) {
                      refundAmount.value = amount;
                    }
                  },
                ),
              ],
              const SizedBox(height: 24),
            ],

            // Reason section
            Text(
              'Reason for Refund',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 12),
            ...RefundReason.values.map(
              (reason) => RadioListTile<RefundReason>(
                title: Text(reason.displayName),
                value: reason,
                groupValue: selectedReason.value,
                onChanged: (value) => selectedReason.value = value,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 16),

            // Description section
            TextField(
              controller: description,
              decoration: const InputDecoration(
                labelText: 'Additional Details (Optional)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              maxLength: 500,
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isProcessing.value
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isProcessing.value ||
                            selectedReason.value == null
                        ? null
                        : () => _handleRefundRequest(
                              context,
                              ref,
                              selectedReason.value!,
                              refundAmount.value,
                              description.text.trim().isEmpty
                                  ? null
                                  : description.text.trim(),
                              isProcessing,
                            ),
                    child: isProcessing.value
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Submit Refund'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatAmount(int amountInOre) {
    final dkk = amountInOre / 100;
    return '${dkk.toStringAsFixed(2)} kr';
  }

  String _formatAmountInput(int amountInOre) {
    final dkk = amountInOre / 100;
    return dkk.toStringAsFixed(2);
  }

  int? _parseAmount(String input) {
    final cleanInput = input.replaceAll(RegExp(r'[^\d.]'), '');
    final amount = double.tryParse(cleanInput);
    if (amount == null) return null;
    return (amount * 100).round();
  }

  void _handleRefundRequest(
    BuildContext context,
    WidgetRef ref,
    RefundReason reason,
    int? amount,
    String? description,
    ValueNotifier<bool> isProcessing,
  ) async {
    isProcessing.value = true;

    try {
      final result = await ref.read(refundPaymentUseCaseProvider).call(
            bookingId: bookingId,
            amount: amount,
            reason: reason,
            description: description,
          );

      result.fold(
        (failure) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Refund failed: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (refund) {
          if (context.mounted) {
            Navigator.of(context).pop(refund);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Refund request submitted successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      );
    } finally {
      isProcessing.value = false;
    }
  }
}