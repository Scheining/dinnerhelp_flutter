import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/payment_repository.dart';

class SetupIntentResponse {
  final String clientSecret;
  final String customerId;
  final String setupIntentId;

  SetupIntentResponse({
    required this.clientSecret,
    required this.customerId,
    required this.setupIntentId,
  });
}

class CreateSetupIntent {
  final PaymentRepository repository;

  CreateSetupIntent(this.repository);

  Future<Either<Failure, SetupIntentResponse>> call() async {
    return await repository.createSetupIntent();
  }
}