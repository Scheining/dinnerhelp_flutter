import 'package:flutter/material.dart';
import 'package:payment_card/payment_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/payment_method.dart';

class PaymentMethodCard extends StatelessWidget {
  final PaymentMethod paymentMethod;
  final VoidCallback? onDelete;
  final VoidCallback? onSetDefault;
  final bool isDeleting;
  final bool isSelected;
  final EdgeInsetsGeometry? margin;

  const PaymentMethodCard({
    Key? key,
    required this.paymentMethod,
    this.onDelete,
    this.onSetDefault,
    this.isDeleting = false,
    this.isSelected = false,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final isDarkMode = theme.brightness == Brightness.dark;
    final bool isExpiringSoon = _isExpiringSoon();
    
    return Container(
      margin: margin,
      height: 250,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Payment Card Visual
            PaymentCard(
              cardNetwork: _mapBrandToNetwork(paymentMethod.brand),
              holder: paymentMethod.holderName ?? '',
              cardNumber: '•••• •••• •••• ${paymentMethod.last4}',
              validity: '${paymentMethod.expMonth.toString().padLeft(2, '0')}/${paymentMethod.expYear.toString().substring(2)}',
              currency: Text(
                'DKK',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: _getCardBackgroundColor(paymentMethod.brand, isDarkMode),
              backgroundGradient: LinearGradient(
                colors: _getCardGradientColors(paymentMethod.brand, isDarkMode),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              backgroundImage: null,
              cardNumberStyles: isDarkMode 
                  ? CardNumberStyles.darkStyle4 
                  : CardNumberStyles.lightStyle1,
              cardIssuerIcon: CardIcon(
                icon: _getCardBrandIconData(paymentMethod.brand),
              ),
            ),
            
            // Overlay for default badge and actions
            Positioned(
              top: 20,
              right: 20,
              child: Row(
                children: [
                  if (paymentMethod.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        localizations.defaultCard,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Action buttons
            Positioned(
              bottom: 20,
              right: 20,
              child: Row(
                children: [
                  if (!isDeleting) ...[
                    if (!paymentMethod.isDefault && onSetDefault != null)
                      Material(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: onSetDefault,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                              color: isSelected 
                                  ? theme.colorScheme.primary 
                                  : Colors.black54,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    if (onDelete != null) ...[
                      const SizedBox(width: 8),
                      Material(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: onDelete,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.delete_outline,
                              color: theme.colorScheme.error,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ] else
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Expiring soon warning
            if (isExpiringSoon)
              Positioned(
                top: 20,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Udløber snart',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  CardNetwork _mapBrandToNetwork(String brand) {
    switch (brand.toLowerCase()) {
      case 'visa':
        return CardNetwork.visa;
      case 'mastercard':
        return CardNetwork.mastercard;
      case 'amex':
      case 'american_express':
        return CardNetwork.americanExpress;
      case 'discover':
        return CardNetwork.discover;
      case 'diners':
      case 'diners_club':
        return CardNetwork.other;
      case 'jcb':
        return CardNetwork.jcb;
      default:
        return CardNetwork.other;
    }
  }
  
  IconData _getCardBrandIconData(String brand) {
    switch (brand.toLowerCase()) {
      case 'visa':
      case 'mastercard':
      case 'amex':
      case 'american_express':
      case 'discover':
      case 'diners':
      case 'diners_club':
      case 'jcb':
      case 'unionpay':
        return Icons.credit_card;
      default:
        return Icons.credit_card;
    }
  }
  
  Color _getCardBackgroundColor(String brand, bool isDarkMode) {
    switch (brand.toLowerCase()) {
      case 'visa':
        return const Color(0xFF1A1F71);
      case 'mastercard':
        return const Color(0xFFEB001B);
      case 'amex':
      case 'american_express':
        return const Color(0xFF006FCF);
      case 'discover':
        return const Color(0xFFFF6000);
      case 'diners':
      case 'diners_club':
        return const Color(0xFF0079BE);
      case 'jcb':
        return const Color(0xFF003A70);
      case 'unionpay':
        return const Color(0xFF005BAC);
      default:
        return isDarkMode ? const Color(0xFF424242) : const Color(0xFF9E9E9E);
    }
  }
  
  List<Color> _getCardGradientColors(String brand, bool isDarkMode) {
    switch (brand.toLowerCase()) {
      case 'visa':
        return [const Color(0xFF1A1F71), const Color(0xFF4B6EDB)];
      case 'mastercard':
        return [const Color(0xFFEB001B), const Color(0xFFF79E1B)];
      case 'amex':
      case 'american_express':
        return [const Color(0xFF006FCF), const Color(0xFF4B9EE7)];
      case 'discover':
        return [const Color(0xFFFF6000), const Color(0xFFFFA366)];
      case 'diners':
      case 'diners_club':
        return [const Color(0xFF0079BE), const Color(0xFF4BA3D8)];
      case 'jcb':
        return [const Color(0xFF003A70), const Color(0xFF4B6BA3)];
      default:
        return isDarkMode 
            ? [const Color(0xFF424242), const Color(0xFF616161)]
            : [const Color(0xFF9E9E9E), const Color(0xFFBDBDBD)];
    }
  }

  bool _isExpiringSoon() {
    final now = DateTime.now();
    final expiry = DateTime(paymentMethod.expYear, paymentMethod.expMonth);
    final difference = expiry.difference(now).inDays;
    return difference < 60; // Warning if expiring within 2 months
  }
}