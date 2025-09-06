import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/payment_method.dart';
import '../repositories/payment_repository.dart';

class GetSavedPaymentMethods {
  final PaymentRepository repository;

  GetSavedPaymentMethods(this.repository);

  Future<Either<Failure, List<PaymentMethod>>> call() async {
    return await repository.getSavedPaymentMethods();
  }
}