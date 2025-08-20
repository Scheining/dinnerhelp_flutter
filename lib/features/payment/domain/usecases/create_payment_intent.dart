import 'package:dartz/dartz.dart';
import 'package:homechef/core/error/failures.dart';
import '../entities/payment_intent.dart';
import '../services/payment_service.dart';

class CreatePaymentIntent {
  final PaymentService _paymentService;

  const CreatePaymentIntent(this._paymentService);

  Future<Either<Failure, PaymentIntent>> call({
    required String bookingId,
    required int baseAmount,
    required String chefStripeAccountId,
    DateTime? eventDate,
  }) async {
    if (bookingId.isEmpty) {
      return const Left(ValidationFailure('Booking ID cannot be empty'));
    }

    if (baseAmount <= 0) {
      return const Left(ValidationFailure('Base amount must be greater than 0'));
    }

    if (chefStripeAccountId.isEmpty) {
      return const Left(ValidationFailure('Chef Stripe account ID cannot be empty'));
    }

    return await _paymentService.createPaymentIntent(
      bookingId: bookingId,
      baseAmount: baseAmount,
      chefStripeAccountId: chefStripeAccountId,
      eventDate: eventDate,
    );
  }
}