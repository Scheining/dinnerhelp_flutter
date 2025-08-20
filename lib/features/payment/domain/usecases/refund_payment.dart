import 'package:dartz/dartz.dart';
import 'package:homechef/core/error/failures.dart';
import '../entities/refund.dart';
import '../services/payment_service.dart';

class RefundPayment {
  final PaymentService _paymentService;

  const RefundPayment(this._paymentService);

  Future<Either<Failure, Refund>> call({
    required String bookingId,
    int? amount,
    required RefundReason reason,
    String? description,
  }) async {
    if (bookingId.isEmpty) {
      return const Left(ValidationFailure('Booking ID cannot be empty'));
    }

    if (amount != null && amount <= 0) {
      return const Left(ValidationFailure('Refund amount must be greater than 0'));
    }

    return await _paymentService.refundPayment(
      bookingId: bookingId,
      amount: amount,
      reason: reason,
      description: description,
    );
  }
}