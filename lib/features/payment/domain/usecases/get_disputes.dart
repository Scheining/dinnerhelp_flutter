import 'package:dartz/dartz.dart';
import 'package:homechef/core/error/failures.dart';
import '../entities/dispute.dart';
import '../services/payment_service.dart';

class GetDisputes {
  final PaymentService _paymentService;

  const GetDisputes(this._paymentService);

  Future<Either<Failure, List<Dispute>>> call({
    required String paymentIntentId,
  }) async {
    if (paymentIntentId.isEmpty) {
      return const Left(ValidationFailure('Payment intent ID cannot be empty'));
    }

    return await _paymentService.getDisputes(
      paymentIntentId: paymentIntentId,
    );
  }
}