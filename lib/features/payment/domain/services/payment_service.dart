import 'package:dartz/dartz.dart';
import 'package:homechef/core/error/failures.dart';
import '../entities/payment_calculation.dart';
import '../entities/payment_intent.dart';
import '../entities/refund.dart';
import '../entities/dispute.dart';

abstract class PaymentService {
  /// Creates a payment intent for a booking
  /// [bookingId] - The booking to create payment for
  /// [baseAmount] - Base amount in øre before fees
  /// [chefStripeAccountId] - Chef's Stripe Connect account ID
  Future<Either<Failure, PaymentIntent>> createPaymentIntent({
    required String bookingId,
    required int baseAmount,
    required String chefStripeAccountId,
    DateTime? eventDate,
  });

  /// Authorizes payment (reserves funds without capture)
  /// [paymentIntentId] - The payment intent to authorize
  Future<Either<Failure, PaymentIntent>> authorizePayment({
    required String paymentIntentId,
  });

  /// Captures an authorized payment
  /// [bookingId] - The booking to capture payment for
  /// [actualAmount] - Actual amount to capture (may differ from authorized)
  Future<Either<Failure, PaymentIntent>> capturePayment({
    required String bookingId,
    int? actualAmount,
  });

  /// Processes a refund for a payment
  /// [bookingId] - The booking to refund
  /// [amount] - Amount to refund in øre (null for full refund)
  /// [reason] - Reason for the refund
  /// [description] - Optional description
  Future<Either<Failure, Refund>> refundPayment({
    required String bookingId,
    int? amount,
    required RefundReason reason,
    String? description,
  });

  /// Calculates service fee and total amounts
  /// [baseAmount] - Base amount in øre
  /// [eventDate] - Date of the event (for holiday surcharges)
  /// [chefBankHolidayExtraCharge] - Chef's bank holiday extra charge %
  /// [chefNewYearEveExtraCharge] - Chef's New Year's Eve extra charge %
  PaymentCalculation calculateServiceFee({
    required int baseAmount,
    DateTime? eventDate,
    int? chefBankHolidayExtraCharge,
    int? chefNewYearEveExtraCharge,
  });

  /// Gets payment status for a booking
  /// [bookingId] - The booking to check payment status for
  Future<Either<Failure, PaymentIntent?>> getPaymentStatus({
    required String bookingId,
  });

  /// Handles automatic capture after 24 hours
  /// Called by scheduled job or webhook
  /// [bookingId] - The booking to auto-capture
  Future<Either<Failure, PaymentIntent>> autoCapture({
    required String bookingId,
  });

  /// Cancels a payment intent before authorization
  /// [paymentIntentId] - The payment intent to cancel
  Future<Either<Failure, PaymentIntent>> cancelPaymentIntent({
    required String paymentIntentId,
  });

  /// Gets dispute information for a payment
  /// [paymentIntentId] - The payment intent to check disputes for
  Future<Either<Failure, List<Dispute>>> getDisputes({
    required String paymentIntentId,
  });

  /// Validates chef's Stripe Connect account status
  /// [chefStripeAccountId] - Chef's Stripe account ID
  Future<Either<Failure, bool>> validateStripeAccount({
    required String chefStripeAccountId,
  });
}