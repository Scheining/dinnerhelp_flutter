// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_intent_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentIntentModelImpl _$$PaymentIntentModelImplFromJson(
        Map<String, dynamic> json) =>
    _$PaymentIntentModelImpl(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      chefStripeAccountId: json['chef_stripe_account_id'] as String,
      amount: (json['amount'] as num).toInt(),
      serviceFeeAmount: (json['service_fee_amount'] as num).toInt(),
      vatAmount: (json['vat_amount'] as num).toInt(),
      currency: json['currency'] as String,
      statusString: json['status'] as String,
      captureMethodString: json['capture_method'] as String,
      paymentMethodId: json['payment_method_id'] as String?,
      clientSecret: json['client_secret'] as String?,
      lastPaymentError: json['last_payment_error'] as String?,
      authorizedAt: json['authorized_at'] == null
          ? null
          : DateTime.parse(json['authorized_at'] as String),
      capturedAt: json['captured_at'] == null
          ? null
          : DateTime.parse(json['captured_at'] as String),
      cancelledAt: json['cancelled_at'] == null
          ? null
          : DateTime.parse(json['cancelled_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$PaymentIntentModelImplToJson(
        _$PaymentIntentModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'booking_id': instance.bookingId,
      'chef_stripe_account_id': instance.chefStripeAccountId,
      'amount': instance.amount,
      'service_fee_amount': instance.serviceFeeAmount,
      'vat_amount': instance.vatAmount,
      'currency': instance.currency,
      'status': instance.statusString,
      'capture_method': instance.captureMethodString,
      'payment_method_id': instance.paymentMethodId,
      'client_secret': instance.clientSecret,
      'last_payment_error': instance.lastPaymentError,
      'authorized_at': instance.authorizedAt?.toIso8601String(),
      'captured_at': instance.capturedAt?.toIso8601String(),
      'cancelled_at': instance.cancelledAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
