import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:equatable/equatable.dart';

part 'payment_intent.freezed.dart';

@freezed
class PaymentIntent with _$PaymentIntent {
  const factory PaymentIntent({
    required String id,
    required String bookingId,
    required String chefStripeAccountId,
    required int amount, // in øre (Danish cents)
    required int serviceFeeAmount,
    required int vatAmount,
    required String currency,
    required PaymentIntentStatus status,
    required PaymentIntentCaptureMethod captureMethod,
    String? paymentMethodId,
    String? clientSecret,
    String? lastPaymentError,
    DateTime? authorizedAt,
    DateTime? capturedAt,
    DateTime? cancelledAt,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _PaymentIntent;
}

enum PaymentIntentStatus {
  requiresPaymentMethod,
  requiresConfirmation,
  requiresAction,
  processing,
  requiresCapture,
  succeeded,
  canceled,
}

enum PaymentIntentCaptureMethod {
  automatic,
  manual,
}

extension PaymentIntentStatusExtension on PaymentIntentStatus {
  String get displayName {
    switch (this) {
      case PaymentIntentStatus.requiresPaymentMethod:
        return 'Requires Payment Method';
      case PaymentIntentStatus.requiresConfirmation:
        return 'Requires Confirmation';
      case PaymentIntentStatus.requiresAction:
        return 'Requires Action';
      case PaymentIntentStatus.processing:
        return 'Processing';
      case PaymentIntentStatus.requiresCapture:
        return 'Authorized';
      case PaymentIntentStatus.succeeded:
        return 'Succeeded';
      case PaymentIntentStatus.canceled:
        return 'Canceled';
    }
  }

  bool get isSuccessful => this == PaymentIntentStatus.succeeded;
  bool get isAuthorized => this == PaymentIntentStatus.requiresCapture;
  bool get isProcessing => this == PaymentIntentStatus.processing;
  bool get requiresUserAction => [
    PaymentIntentStatus.requiresPaymentMethod,
    PaymentIntentStatus.requiresConfirmation,
    PaymentIntentStatus.requiresAction,
  ].contains(this);
}