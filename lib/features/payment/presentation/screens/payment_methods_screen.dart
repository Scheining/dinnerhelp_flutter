import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:homechef/services/stripe_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/payment_method.dart';
import '../providers/payment_providers.dart';
import '../widgets/payment_method_card.dart';
import '../widgets/add_payment_method_button.dart';

class PaymentMethodsScreen extends HookConsumerWidget {
  const PaymentMethodsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final paymentMethodsAsync = ref.watch(savedPaymentMethodsProvider);
    final isDeleting = useState(false);
    final selectedForDefault = useState<String?>(null);

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? theme.colorScheme.surface
          : theme.colorScheme.surfaceContainerLow,
      appBar: AppBar(
        title: Text(localizations.paymentMethods),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: paymentMethodsAsync.when(
        data: (paymentMethods) {
          if (paymentMethods.isEmpty) {
            return _buildEmptyState(context, ref);
          }
          
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(savedPaymentMethodsProvider);
            },
            color: Theme.of(context).colorScheme.primary,
            child: Column(
              children: [
                // Header with add button
                Container(
                  color: theme.brightness == Brightness.dark
                      ? theme.colorScheme.surfaceContainerHigh
                      : theme.colorScheme.surface,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations.savedCards,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            localizations.cardsSaved(paymentMethods.length),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      AddPaymentMethodButton(
                        onMethodAdded: () {
                          ref.invalidate(savedPaymentMethodsProvider);
                        },
                      ),
                    ],
                  ),
                ),
                
                // Cards list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                      top: 14,
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    itemCount: paymentMethods.length,
                    itemBuilder: (context, index) {
                      final method = paymentMethods[index];
                      return PaymentMethodCard(
                        paymentMethod: method,
                        isDeleting: isDeleting.value,
                        isSelected: selectedForDefault.value == method.id,
                        onDelete: () => _deletePaymentMethod(
                          context,
                          ref,
                          method,
                          isDeleting,
                        ),
                        onSetDefault: method.isDefault
                            ? null
                            : () => _setDefaultPaymentMethod(
                                context,
                                ref,
                                method,
                                selectedForDefault,
                              ),
                        margin: const EdgeInsets.only(bottom: 12),
                      );
                    },
                  ),
                ),
                
                // Security footer
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark
                        ? theme.colorScheme.surfaceContainerHigh
                        : theme.colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.1),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 16,
                        color: theme.colorScheme.primary.withOpacity(0.7),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          localizations.yourPaymentInfoSecure,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                SelectableText.rich(
                  TextSpan(
                    text: localizations.errorLoadingPaymentMethods(error.toString()),
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: () => ref.invalidate(savedPaymentMethodsProvider),
                  child: Text(localizations.retry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.1),
                    theme.colorScheme.primary.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.credit_card_outlined,
                size: 64,
                color: theme.colorScheme.primary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              localizations.noPaymentMethods,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              localizations.addCardToMakeBookingFaster,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            AddPaymentMethodButton(
              isLarge: true,
              onMethodAdded: () {
                ref.invalidate(savedPaymentMethodsProvider);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deletePaymentMethod(
    BuildContext context,
    WidgetRef ref,
    PaymentMethod method,
    ValueNotifier<bool> isDeleting,
  ) async {
    final localizations = AppLocalizations.of(context)!;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.removeCard),
        content: Text(
          localizations.areYouSureRemoveCard(method.last4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(localizations.remove),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      isDeleting.value = true;
      
      try {
        final result = await ref.read(deletePaymentMethodProvider(method.id).future);
        
        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localizations.failedToRemoveCard(failure.message)),
                backgroundColor: Colors.red,
              ),
            );
          },
          (_) {
            ref.invalidate(savedPaymentMethodsProvider);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localizations.cardRemovedSuccessfully),
                backgroundColor: Colors.green,
              ),
            );
          },
        );
      } finally {
        isDeleting.value = false;
      }
    }
  }

  Future<void> _setDefaultPaymentMethod(
    BuildContext context,
    WidgetRef ref,
    PaymentMethod method,
    ValueNotifier<String?> selectedForDefault,
  ) async {
    final localizations = AppLocalizations.of(context)!;
    selectedForDefault.value = method.id;
    
    try {
      final result = await ref.read(setDefaultPaymentMethodProvider(method.id).future);
      
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.failedToSetDefault(failure.message)),
              backgroundColor: Colors.red,
            ),
          );
        },
        (_) {
          ref.invalidate(savedPaymentMethodsProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.defaultPaymentMethodUpdated),
              backgroundColor: Colors.green,
            ),
          );
        },
      );
    } finally {
      selectedForDefault.value = null;
    }
  }
}