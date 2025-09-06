import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/payment_method.dart';
import '../providers/payment_providers.dart';

class PaymentMethodSelector extends HookConsumerWidget {
  final Function(PaymentMethod) onPaymentMethodSelected;
  final PaymentMethod? selectedPaymentMethod;

  const PaymentMethodSelector({
    Key? key,
    required this.onPaymentMethodSelected,
    this.selectedPaymentMethod,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final paymentMethodsState = ref.watch(paymentMethodsProvider);
    final showAddMethodForm = useState(false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        paymentMethodsState.when(
          data: (methods) => Column(
            children: [
              if (methods.isEmpty) ...[
                _buildEmptyState(context, () {
                  showAddMethodForm.value = true;
                }),
              ] else ...[
                ...methods.map(
                  (method) => _buildPaymentMethodTile(
                    context,
                    method,
                    selectedPaymentMethod?.id == method.id,
                    () => onPaymentMethodSelected(method),
                  ),
                ),
                const SizedBox(height: 12),
                _buildAddMethodButton(context, () {
                  showAddMethodForm.value = true;
                }),
              ],
            ],
          ),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) => _buildErrorState(
            context,
            error.toString(),
            () => ref.refresh(paymentMethodsProvider),
          ),
        ),
        if (showAddMethodForm.value) ...[
          const SizedBox(height: 16),
          _buildAddPaymentMethodForm(
            context,
            ref,
            () => showAddMethodForm.value = false,
          ),
        ],
      ],
    );
  }

  Widget _buildPaymentMethodTile(
    BuildContext context,
    PaymentMethod method,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: _buildPaymentMethodIcon(method),
        title: Text(_buildPaymentMethodTitle(method)),
        subtitle: method.holderName != null
            ? Text(method.holderName!)
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (method.isDefault)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  localizations.defaultCard,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                      ),
                ),
              ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodIcon(PaymentMethod method) {
    IconData iconData;
    Color iconColor = Colors.grey.shade600;

    switch (method.type) {
      case PaymentMethodType.card:
        iconData = Icons.credit_card;
        break;
      case PaymentMethodType.mobilePay:
        iconData = Icons.phone_android;
        iconColor = const Color(0xFF3F51B5);
        break;
      case PaymentMethodType.bankTransfer:
        iconData = Icons.account_balance;
        break;
      case PaymentMethodType.applePay:
        iconData = Icons.phone_iphone;
        iconColor = Colors.black;
        break;
      case PaymentMethodType.googlePay:
        iconData = Icons.google;
        iconColor = const Color(0xFF4285F4);
        break;
    }

    return Icon(iconData, color: iconColor);
  }

  String _buildPaymentMethodTitle(PaymentMethod method) {
    switch (method.type) {
      case PaymentMethodType.card:
        return '${method.brand.toUpperCase()} •••• ${method.last4}';
      default:
        return method.type.displayName;
    }
  }

  Widget _buildEmptyState(BuildContext context, VoidCallback onAddMethod) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.payment,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No payment methods added',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a payment method to continue with your booking',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onAddMethod,
            icon: const Icon(Icons.add),
            label: const Text('Add Payment Method'),
          ),
        ],
      ),
    );
  }

  Widget _buildAddMethodButton(BuildContext context, VoidCallback onPressed) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add),
      label: const Text('Add New Payment Method'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
      ),
    );
  }

  Widget _buildAddPaymentMethodForm(
    BuildContext context,
    WidgetRef ref,
    VoidCallback onCancel,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add Payment Method',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              IconButton(
                onPressed: onCancel,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // This would integrate with Stripe's CardFormField
          // For now, showing placeholder
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('Stripe Card Form Integration'),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Handle save payment method
                    onCancel();
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    String error,
    VoidCallback onRetry,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade400,
            size: 32,
          ),
          const SizedBox(height: 8),
          SelectableText.rich(
            TextSpan(
              text: 'Failed to load payment methods: $error',
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}