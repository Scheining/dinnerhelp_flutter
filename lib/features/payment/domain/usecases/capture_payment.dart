import 'package:dartz/dartz.dart';
import 'package:homechef/core/error/failures.dart';
import '../entities/payment_intent.dart';
import '../services/payment_service.dart';

class CapturePayment {
  final PaymentService _paymentService;

  const CapturePayment(this._paymentService);

  Future<Either<Failure, PaymentIntent>> call({
    required String bookingId,
    int? actualAmount,
  }) async {
    if (bookingId.isEmpty) {
      return const Left(ValidationFailure('Booking ID cannot be empty'));
    }

    if (actualAmount != null && actualAmount <= 0) {
      return const Left(ValidationFailure('Actual amount must be greater than 0'));
    }

    return await _paymentService.capturePayment(
      bookingId: bookingId,
      actualAmount: actualAmount,
    );
  }
}