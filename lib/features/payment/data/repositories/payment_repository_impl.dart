import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homechef/core/error/failures.dart';
import '../../domain/entities/payment_intent.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/refund.dart';
import '../../domain/entities/dispute.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/usecases/create_setup_intent.dart';
import '../models/payment_intent_model.dart';
import '../models/payment_method_model.dart';
import '../models/refund_model.dart';
import '../models/dispute_model.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final SupabaseClient _supabaseClient;

  const PaymentRepositoryImpl({
    required SupabaseClient supabaseClient,
  }) : _supabaseClient = supabaseClient;

  @override
  Future<Either<Failure, PaymentIntent>> createPaymentIntent({
    required String bookingId,
    required int amount,
    required int serviceFeeAmount,
    required int vatAmount,
    required String chefStripeAccountId,
  }) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'create-payment-intent',
        body: {
          'booking_id': bookingId,
          'amount': amount,
          'service_fee_amount': serviceFeeAmount,
          'vat_amount': vatAmount,
          'chef_stripe_account_id': chefStripeAccountId,
        },
      );

      if (response.status != 200) {
        return Left(PaymentIntentCreationFailure(
          response.data?['error'] ?? 'Failed to create payment intent',
        ));
      }

      final paymentIntentModel = PaymentIntentModel.fromJson(response.data);
      return Right(paymentIntentModel.toDomain());
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(PaymentIntentCreationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaymentIntent>> authorizePayment({
    required String paymentIntentId,
  }) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'authorize-payment',
        body: {
          'payment_intent_id': paymentIntentId,
        },
      );

      if (response.status != 200) {
        return Left(PaymentAuthorizationFailure(
          response.data?['error'] ?? 'Payment authorization failed',
        ));
      }

      final paymentIntentModel = PaymentIntentModel.fromJson(response.data);
      return Right(paymentIntentModel.toDomain());
    } catch (e) {
      return Left(PaymentAuthorizationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaymentIntent>> capturePayment({
    required String bookingId,
    int? actualAmount,
  }) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'capture-payment',
        body: {
          'booking_id': bookingId,
          if (actualAmount != null) 'actual_amount': actualAmount,
        },
      );

      if (response.status != 200) {
        return Left(PaymentCaptureFailure(
          response.data?['error'] ?? 'Payment capture failed',
        ));
      }

      final paymentIntentModel = PaymentIntentModel.fromJson(response.data);
      return Right(paymentIntentModel.toDomain());
    } catch (e) {
      return Left(PaymentCaptureFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Refund>> refundPayment({
    required String bookingId,
    int? amount,
    required RefundReason reason,
    String? description,
  }) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'refund-payment',
        body: {
          'booking_id': bookingId,
          if (amount != null) 'amount': amount,
          'reason': reason.name,
          if (description != null) 'description': description,
        },
      );

      if (response.status != 200) {
        return Left(RefundFailure(
          response.data?['error'] ?? 'Refund processing failed',
        ));
      }

      final refundModel = RefundModel.fromJson(response.data);
      return Right(refundModel.toDomain());
    } catch (e) {
      return Left(RefundFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaymentIntent?>> getPaymentStatus({
    required String bookingId,
  }) async {
    try {
      final response = await _supabaseClient
          .from('payment_intents')
          .select()
          .eq('booking_id', bookingId)
          .maybeSingle();

      if (response == null) {
        return const Right(null);
      }

      final paymentIntentModel = PaymentIntentModel.fromJson(response);
      return Right(paymentIntentModel.toDomain());
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(PaymentNotFoundFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaymentIntent>> cancelPaymentIntent({
    required String paymentIntentId,
  }) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'cancel-payment-intent',
        body: {
          'payment_intent_id': paymentIntentId,
        },
      );

      if (response.status != 200) {
        return Left(PaymentFailure(
          response.data?['error'] ?? 'Failed to cancel payment intent',
        ));
      }

      final paymentIntentModel = PaymentIntentModel.fromJson(response.data);
      return Right(paymentIntentModel.toDomain());
    } catch (e) {
      return Left(PaymentFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Dispute>>> getDisputes({
    required String paymentIntentId,
  }) async {
    try {
      final response = await _supabaseClient
          .from('disputes')
          .select()
          .eq('payment_intent_id', paymentIntentId);

      final disputes = response
          .map((json) => DisputeModel.fromJson(json).toDomain())
          .toList();

      return Right(disputes);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(DisputeHandlingFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> validateStripeAccount({
    required String chefStripeAccountId,
  }) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'validate-stripe-account',
        body: {
          'stripe_account_id': chefStripeAccountId,
        },
      );

      if (response.status != 200) {
        return Left(StripeConnectAccountFailure(
          response.data?['error'] ?? 'Stripe account validation failed',
        ));
      }

      final isValid = response.data['valid'] as bool? ?? false;
      return Right(isValid);
    } catch (e) {
      return Left(StripeConnectAccountFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PaymentMethod>>> getSavedPaymentMethods() async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'list-payment-methods',
      );

      if (response.status != 200) {
        return Left(PaymentFailure(
          response.data?['error'] ?? 'Failed to get payment methods',
        ));
      }

      final List<dynamic> methodsJson = response.data['payment_methods'] ?? [];
      final paymentMethods = methodsJson
          .map((json) => PaymentMethodModel.fromJson(json).toDomain())
          .toList();

      return Right(paymentMethods);
    } catch (e) {
      return Left(PaymentFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SetupIntentResponse>> createSetupIntent() async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'create-setup-intent',
      );

      if (response.status != 200) {
        return Left(PaymentFailure(
          response.data?['error'] ?? 'Failed to create setup intent',
        ));
      }

      return Right(SetupIntentResponse(
        clientSecret: response.data['client_secret'],
        customerId: response.data['customer_id'],
        setupIntentId: response.data['setup_intent_id'],
      ));
    } catch (e) {
      return Left(PaymentFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaymentMethod>> savePaymentMethod({
    required String setupIntentId,
    String? nickname,
  }) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'save-payment-method',
        body: {
          'setup_intent_id': setupIntentId,
          if (nickname != null) 'nickname': nickname,
        },
      );

      if (response.status != 200) {
        return Left(PaymentFailure(
          response.data?['error'] ?? 'Failed to save payment method',
        ));
      }

      final paymentMethodModel = PaymentMethodModel.fromJson(response.data['payment_method']);
      return Right(paymentMethodModel.toDomain());
    } catch (e) {
      return Left(PaymentFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePaymentMethod(String paymentMethodId) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'delete-payment-method',
        body: {
          'payment_method_id': paymentMethodId,
        },
      );

      if (response.status != 200) {
        return Left(PaymentFailure(
          response.data?['error'] ?? 'Failed to delete payment method',
        ));
      }

      return const Right(null);
    } catch (e) {
      return Left(PaymentFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaymentMethod>> setDefaultPaymentMethod(String paymentMethodId) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'set-default-payment-method',
        body: {
          'payment_method_id': paymentMethodId,
        },
      );

      if (response.status != 200) {
        return Left(PaymentFailure(
          response.data?['error'] ?? 'Failed to set default payment method',
        ));
      }

      final paymentMethodModel = PaymentMethodModel.fromJson(response.data['payment_method']);
      return Right(paymentMethodModel.toDomain());
    } catch (e) {
      return Left(PaymentFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> handleWebhookEvent({
    required String event,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'handle-stripe-webhook',
        body: {
          'event': event,
          'data': data,
        },
      );

      if (response.status != 200) {
        return Left(PaymentWebhookFailure(
          response.data?['error'] ?? 'Webhook processing failed',
        ));
      }

      return const Right(null);
    } catch (e) {
      return Left(PaymentWebhookFailure(e.toString()));
    }
  }
}