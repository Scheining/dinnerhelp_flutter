import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/payment_repository.dart';

class DeletePaymentMethod {
  final PaymentRepository repository;

  DeletePaymentMethod(this.repository);

  Future<Either<Failure, void>> call(String paymentMethodId) async {
    return await repository.deletePaymentMethod(paymentMethodId);
  }
}