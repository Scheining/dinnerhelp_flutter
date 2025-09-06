import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/payment_method.dart';
import '../repositories/payment_repository.dart';

class SavePaymentMethodParams {
  final String setupIntentId;
  final String? nickname;

  SavePaymentMethodParams({
    required this.setupIntentId,
    this.nickname,
  });
}

class SavePaymentMethod {
  final PaymentRepository repository;

  SavePaymentMethod(this.repository);

  Future<Either<Failure, PaymentMethod>> call(SavePaymentMethodParams params) async {
    return await repository.savePaymentMethod(
      setupIntentId: params.setupIntentId,
      nickname: params.nickname,
    );
  }
}