import 'package:dartz/dartz.dart';
import 'package:homechef/core/error/failures.dart';
import '../entities/payment_intent.dart';
import '../services/payment_service.dart';

class GetPaymentStatus {
  final PaymentService _paymentService;

  const GetPaymentStatus(this._paymentService);

  Future<Either<Failure, PaymentIntent?>> call({
    required String bookingId,
  }) async {
    if (bookingId.isEmpty) {
      return const Left(ValidationFailure('Booking ID cannot be empty'));
    }

    return await _paymentService.getPaymentStatus(
      bookingId: bookingId,
    );
  }
}