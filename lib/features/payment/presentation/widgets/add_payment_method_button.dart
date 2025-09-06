import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:homechef/services/stripe_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../l10n/app_localizations.dart';

class AddPaymentMethodButton extends HookConsumerWidget {
  final VoidCallback? onMethodAdded;
  final bool isLarge;

  const AddPaymentMethodButton({
    Key? key,
    this.onMethodAdded,
    this.isLarge = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    if (isLarge) {
      return SizedBox(
        width: 200,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: isLoading.value
              ? null
              : () => _addPaymentMethod(context, ref, isLoading),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          icon: isLoading.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.add_card, size: 20),
          label: Text(
            isLoading.value ? localizations.adding : localizations.addCard,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: isLoading.value
          ? null
          : () => _addPaymentMethod(context, ref, isLoading),
      style: OutlinedButton.styleFrom(
        foregroundColor: theme.colorScheme.primary,
        side: BorderSide(
          color: theme.colorScheme.primary,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      icon: isLoading.value
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            )
          : const Icon(Icons.add, size: 18),
      label: Text(
        isLoading.value ? localizations.adding : localizations.addCard,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  Future<void> _addPaymentMethod(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<bool> isLoading,
  ) async {
    final localizations = AppLocalizations.of(context)!;
    isLoading.value = true;

    try {
      // Get current user
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Show nickname dialog first
      final nickname = await showDialog<String>(
        context: context,
        builder: (context) => _NicknameDialog(),
      );

      // Create SetupIntent
      final stripeService = StripeService.instance;
      final setupIntentData = await stripeService.createSetupIntent();
      
      if (setupIntentData == null || setupIntentData['client_secret'] == null) {
        throw Exception('Failed to create setup intent');
      }

      // Get user email
      final userEmail = user.email;

      // Initialize payment sheet for setup
      await stripeService.initSetupPaymentSheet(
        clientSecret: setupIntentData['client_secret'],
        merchantDisplayName: 'DinnerHelp',
        customerEmail: userEmail,
      );

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      // Save payment method with nickname
      final saved = await stripeService.savePaymentMethod(
        setupIntentId: setupIntentData['setup_intent_id'],
        nickname: nickname,
      );

      if (saved) {
        if (!context.mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.cardAddedSuccessfully),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        onMethodAdded?.call();
      } else {
        throw Exception('Failed to save payment method');
      }
    } on StripeException catch (e) {
      if (e.error.code != FailureCode.Canceled && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.error.localizedMessage ?? localizations.paymentSetupFailed}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fejl: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
}

class _NicknameDialog extends StatefulWidget {
  @override
  __NicknameDialogState createState() => __NicknameDialogState();
}

class __NicknameDialogState extends State<_NicknameDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    
    return AlertDialog(
      title: Text(localizations.cardNickname),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.giveCardNickname,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'e.g., ${localizations.personalCard}, ${localizations.workCard}',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            textCapitalization: TextCapitalization.words,
            maxLength: 30,
          ),
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(localizations.skip),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(localizations.save),
        ),
      ],
    );
  }
}