import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/repositories/payment_repository.dart';
import '../domain/services/payment_service.dart';
import '../domain/services/payment_service_impl.dart';
import '../domain/usecases/create_payment_intent.dart';
import '../domain/usecases/authorize_payment.dart';
import '../domain/usecases/capture_payment.dart';
import '../domain/usecases/refund_payment.dart';
import '../domain/usecases/calculate_payment_amount.dart';
import '../domain/usecases/get_payment_status.dart';
import '../domain/usecases/get_disputes.dart';
import '../data/repositories/payment_repository_impl.dart';

void initPaymentDependencies() {
  final getIt = GetIt.instance;

  // Repository
  getIt.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(
      supabaseClient: Supabase.instance.client,
    ),
  );

  // Service
  getIt.registerLazySingleton<PaymentService>(
    () => PaymentServiceImpl(
      paymentRepository: getIt<PaymentRepository>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton(() => CreatePaymentIntent(getIt<PaymentService>()));
  getIt.registerLazySingleton(() => AuthorizePayment(getIt<PaymentService>()));
  getIt.registerLazySingleton(() => CapturePayment(getIt<PaymentService>()));
  getIt.registerLazySingleton(() => RefundPayment(getIt<PaymentService>()));
  getIt.registerLazySingleton(() => CalculatePaymentAmount(getIt<PaymentService>()));
  getIt.registerLazySingleton(() => GetPaymentStatus(getIt<PaymentService>()));
  getIt.registerLazySingleton(() => GetDisputes(getIt<PaymentService>()));
}

/// Call this in your main.dart after Supabase initialization
/// 
/// Example:
/// ```dart
/// await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
/// initPaymentDependencies();
/// ```
void setupPaymentDependencies() {
  initPaymentDependencies();
}