import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/payment_method.dart';
import '../repositories/payment_repository.dart';

class SetDefaultPaymentMethod {
  final PaymentRepository repository;

  SetDefaultPaymentMethod(this.repository);

  Future<Either<Failure, PaymentMethod>> call(String paymentMethodId) async {
    return await repository.setDefaultPaymentMethod(paymentMethodId);
  }
}