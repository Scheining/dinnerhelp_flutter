import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/payment_intent.dart';

part 'payment_intent_model.freezed.dart';
part 'payment_intent_model.g.dart';

@freezed
class PaymentIntentModel with _$PaymentIntentModel {
  const factory PaymentIntentModel({
    required String id,
    @JsonKey(name: 'booking_id') required String bookingId,
    @JsonKey(name: 'chef_stripe_account_id') required String chefStripeAccountId,
    required int amount,
    @JsonKey(name: 'service_fee_amount') required int serviceFeeAmount,
    @JsonKey(name: 'vat_amount') required int vatAmount,
    required String currency,
    @JsonKey(name: 'status') required String statusString,
    @JsonKey(name: 'capture_method') required String captureMethodString,
    @JsonKey(name: 'payment_method_id') String? paymentMethodId,
    @JsonKey(name: 'client_secret') String? clientSecret,
    @JsonKey(name: 'last_payment_error') String? lastPaymentError,
    @JsonKey(name: 'authorized_at') DateTime? authorizedAt,
    @JsonKey(name: 'captured_at') DateTime? capturedAt,
    @JsonKey(name: 'cancelled_at') DateTime? cancelledAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _PaymentIntentModel;

  factory PaymentIntentModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentIntentModelFromJson(json);

  const PaymentIntentModel._();

  PaymentIntent toDomain() {
    return PaymentIntent(
      id: id,
      bookingId: bookingId,
      chefStripeAccountId: chefStripeAccountId,
      amount: amount,
      serviceFeeAmount: serviceFeeAmount,
      vatAmount: vatAmount,
      currency: currency,
      status: _parseStatus(statusString),
      captureMethod: _parseCaptureMethod(captureMethodString),
      paymentMethodId: paymentMethodId,
      clientSecret: clientSecret,
      lastPaymentError: lastPaymentError,
      authorizedAt: authorizedAt,
      capturedAt: capturedAt,
      cancelledAt: cancelledAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  PaymentIntentStatus _parseStatus(String status) {
    switch (status) {
      case 'requires_payment_method':
        return PaymentIntentStatus.requiresPaymentMethod;
      case 'requires_confirmation':
        return PaymentIntentStatus.requiresConfirmation;
      case 'requires_action':
        return PaymentIntentStatus.requiresAction;
      case 'processing':
        return PaymentIntentStatus.processing;
      case 'requires_capture':
        return PaymentIntentStatus.requiresCapture;
      case 'succeeded':
        return PaymentIntentStatus.succeeded;
      case 'canceled':
        return PaymentIntentStatus.canceled;
      default:
        return PaymentIntentStatus.requiresPaymentMethod;
    }
  }

  PaymentIntentCaptureMethod _parseCaptureMethod(String method) {
    switch (method) {
      case 'automatic':
        return PaymentIntentCaptureMethod.automatic;
      case 'manual':
        return PaymentIntentCaptureMethod.manual;
      default:
        return PaymentIntentCaptureMethod.manual;
    }
  }
}