import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:equatable/equatable.dart';

part 'payment_method.freezed.dart';

@freezed
class PaymentMethod with _$PaymentMethod {
  const factory PaymentMethod({
    required String id,
    required PaymentMethodType type,
    required String last4,
    required String brand,
    required int expMonth,
    required int expYear,
    String? holderName,
    required bool isDefault,
    required DateTime createdAt,
  }) = _PaymentMethod;
}

enum PaymentMethodType {
  card,
  mobilePay,
  bankTransfer,
  applePay,
  googlePay,
}

extension PaymentMethodTypeExtension on PaymentMethodType {
  String get displayName {
    switch (this) {
      case PaymentMethodType.card:
        return 'Credit/Debit Card';
      case PaymentMethodType.mobilePay:
        return 'MobilePay';
      case PaymentMethodType.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethodType.applePay:
        return 'Apple Pay';
      case PaymentMethodType.googlePay:
        return 'Google Pay';
    }
  }

  String get iconPath {
    switch (this) {
      case PaymentMethodType.card:
        return 'assets/icons/card.svg';
      case PaymentMethodType.mobilePay:
        return 'assets/icons/mobilepay.svg';
      case PaymentMethodType.bankTransfer:
        return 'assets/icons/bank.svg';
      case PaymentMethodType.applePay:
        return 'assets/icons/apple_pay.svg';
      case PaymentMethodType.googlePay:
        return 'assets/icons/google_pay.svg';
    }
  }
}