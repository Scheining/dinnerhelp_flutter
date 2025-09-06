import 'package:dartz/dartz.dart';
import 'package:homechef/core/error/failures.dart';
import '../entities/payment_intent.dart';
import '../entities/payment_method.dart';
import '../entities/refund.dart';
import '../entities/dispute.dart';
import '../usecases/create_setup_intent.dart';

abstract class PaymentRepository {
  /// Creates a payment intent via Supabase Edge Function
  Future<Either<Failure, PaymentIntent>> createPaymentIntent({
    required String bookingId,
    required int amount,
    required int serviceFeeAmount,
    required int vatAmount,
    required String chefStripeAccountId,
  });

  /// Authorizes a payment (reserves funds)
  Future<Either<Failure, PaymentIntent>> authorizePayment({
    required String paymentIntentId,
  });

  /// Captures an authorized payment
  Future<Either<Failure, PaymentIntent>> capturePayment({
    required String bookingId,
    int? actualAmount,
  });

  /// Processes a refund
  Future<Either<Failure, Refund>> refundPayment({
    required String bookingId,
    int? amount,
    required RefundReason reason,
    String? description,
  });

  /// Gets payment status for a booking
  Future<Either<Failure, PaymentIntent?>> getPaymentStatus({
    required String bookingId,
  });

  /// Cancels a payment intent
  Future<Either<Failure, PaymentIntent>> cancelPaymentIntent({
    required String paymentIntentId,
  });

  /// Gets disputes for a payment
  Future<Either<Failure, List<Dispute>>> getDisputes({
    required String paymentIntentId,
  });

  /// Validates Stripe Connect account
  Future<Either<Failure, bool>> validateStripeAccount({
    required String chefStripeAccountId,
  });

  /// Gets saved payment methods for the current user
  Future<Either<Failure, List<PaymentMethod>>> getSavedPaymentMethods();

  /// Creates a SetupIntent for saving a payment method
  Future<Either<Failure, SetupIntentResponse>> createSetupIntent();

  /// Saves a payment method after successful SetupIntent
  Future<Either<Failure, PaymentMethod>> savePaymentMethod({
    required String setupIntentId,
    String? nickname,
  });

  /// Deletes a saved payment method
  Future<Either<Failure, void>> deletePaymentMethod(String paymentMethodId);
  
  /// Sets a payment method as default
  Future<Either<Failure, PaymentMethod>> setDefaultPaymentMethod(String paymentMethodId);

  /// Handles Stripe webhook events
  Future<Either<Failure, void>> handleWebhookEvent({
    required String event,
    required Map<String, dynamic> data,
  });
}