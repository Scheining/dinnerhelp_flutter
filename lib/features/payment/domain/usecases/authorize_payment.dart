import 'package:dartz/dartz.dart';
import 'package:homechef/core/error/failures.dart';
import '../entities/payment_intent.dart';
import '../services/payment_service.dart';

class AuthorizePayment {
  final PaymentService _paymentService;

  const AuthorizePayment(this._paymentService);

  Future<Either<Failure, PaymentIntent>> call({
    required String paymentIntentId,
  }) async {
    if (paymentIntentId.isEmpty) {
      return const Left(ValidationFailure('Payment intent ID cannot be empty'));
    }

    return await _paymentService.authorizePayment(
      paymentIntentId: paymentIntentId,
    );
  }
}