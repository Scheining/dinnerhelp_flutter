import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/payment_method.dart';

part 'payment_method_model.freezed.dart';
part 'payment_method_model.g.dart';

@freezed
class PaymentMethodModel with _$PaymentMethodModel {
  const factory PaymentMethodModel({
    @JsonKey(name: 'stripe_payment_method_id') required String id,
    @JsonKey(name: 'type') required String typeString,
    @JsonKey(name: 'last4') required String last4,
    @JsonKey(name: 'brand') required String brand,
    @JsonKey(name: 'exp_month') required int expMonth,
    @JsonKey(name: 'exp_year') required int expYear,
    @JsonKey(name: 'holder_name') String? holderName,
    @JsonKey(name: 'is_default') required bool isDefault,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _PaymentMethodModel;

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodModelFromJson(json);

  const PaymentMethodModel._();

  PaymentMethod toDomain() {
    return PaymentMethod(
      id: id,
      type: _parseType(typeString),
      last4: last4,
      brand: brand,
      expMonth: expMonth,
      expYear: expYear,
      holderName: holderName,
      isDefault: isDefault,
      createdAt: createdAt,
    );
  }

  PaymentMethodType _parseType(String type) {
    switch (type.toLowerCase()) {
      case 'card':
        return PaymentMethodType.card;
      case 'mobilepay':
        return PaymentMethodType.mobilePay;
      case 'bank_transfer':
        return PaymentMethodType.bankTransfer;
      case 'apple_pay':
        return PaymentMethodType.applePay;
      case 'google_pay':
        return PaymentMethodType.googlePay;
      default:
        return PaymentMethodType.card;
    }
  }
}