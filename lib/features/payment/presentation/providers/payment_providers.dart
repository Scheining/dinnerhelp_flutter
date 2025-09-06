import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/payment_intent.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/refund.dart';
import '../../domain/entities/dispute.dart';
import '../../domain/entities/payment_calculation.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/services/payment_service.dart';
import '../../domain/services/payment_service_impl.dart';
import '../../domain/usecases/create_payment_intent.dart';
import '../../domain/usecases/authorize_payment.dart';
import '../../domain/usecases/capture_payment.dart';
import '../../domain/usecases/refund_payment.dart';
import '../../domain/usecases/calculate_payment_amount.dart';
import '../../domain/usecases/get_payment_status.dart';
import '../../domain/usecases/get_disputes.dart';
import '../../domain/usecases/create_setup_intent.dart';
import '../../domain/usecases/get_saved_payment_methods.dart';
import '../../domain/usecases/save_payment_method.dart';
import '../../domain/usecases/delete_payment_method.dart';
import '../../domain/usecases/set_default_payment_method.dart';
import '../../data/repositories/payment_repository_impl.dart';

part 'payment_providers.g.dart';

// Repository providers
@riverpod
PaymentRepository paymentRepository(PaymentRepositoryRef ref) {
  return PaymentRepositoryImpl(
    supabaseClient: Supabase.instance.client,
  );
}

// Service providers
@riverpod
PaymentService paymentService(PaymentServiceRef ref) {
  return PaymentServiceImpl(
    paymentRepository: ref.read(paymentRepositoryProvider),
  );
}

// Use case providers
@riverpod
CreatePaymentIntent createPaymentIntentUseCase(CreatePaymentIntentUseCaseRef ref) {
  return CreatePaymentIntent(ref.read(paymentServiceProvider));
}

@riverpod
AuthorizePayment authorizePaymentUseCase(AuthorizePaymentUseCaseRef ref) {
  return AuthorizePayment(ref.read(paymentServiceProvider));
}

@riverpod
CapturePayment capturePaymentUseCase(CapturePaymentUseCaseRef ref) {
  return CapturePayment(ref.read(paymentServiceProvider));
}

@riverpod
RefundPayment refundPaymentUseCase(RefundPaymentUseCaseRef ref) {
  return RefundPayment(ref.read(paymentServiceProvider));
}

@riverpod
CalculatePaymentAmount calculatePaymentAmountUseCase(CalculatePaymentAmountUseCaseRef ref) {
  return CalculatePaymentAmount(ref.read(paymentServiceProvider));
}

@riverpod
GetPaymentStatus getPaymentStatusUseCase(GetPaymentStatusUseCaseRef ref) {
  return GetPaymentStatus(ref.read(paymentServiceProvider));
}

@riverpod
GetDisputes getDisputesUseCase(GetDisputesUseCaseRef ref) {
  return GetDisputes(ref.read(paymentServiceProvider));
}

// Data providers
@riverpod
Future<List<PaymentMethod>> paymentMethods(PaymentMethodsRef ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return [];

  final result = await ref.read(paymentRepositoryProvider).getSavedPaymentMethods();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (methods) => methods,
  );
}

@riverpod
Future<PaymentIntent?> paymentStatus(
  PaymentStatusRef ref,
  String bookingId,
) async {
  final result = await ref.read(getPaymentStatusUseCaseProvider).call(
        bookingId: bookingId,
      );

  return result.fold(
    (failure) => throw Exception(failure.message),
    (paymentIntent) => paymentIntent,
  );
}

@riverpod
Future<List<Dispute>> disputes(
  DisputesRef ref,
  String paymentIntentId,
) async {
  final result = await ref.read(getDisputesUseCaseProvider).call(
        paymentIntentId: paymentIntentId,
      );

  return result.fold(
    (failure) => throw Exception(failure.message),
    (disputes) => disputes,
  );
}

@riverpod
PaymentCalculation calculatePayment(
  CalculatePaymentRef ref, {
  required int baseAmount,
  DateTime? eventDate,
  int? chefBankHolidayExtraCharge,
  int? chefNewYearEveExtraCharge,
}) {
  return ref.read(calculatePaymentAmountUseCaseProvider).call(
        baseAmount: baseAmount,
        eventDate: eventDate,
        chefBankHolidayExtraCharge: chefBankHolidayExtraCharge,
        chefNewYearEveExtraCharge: chefNewYearEveExtraCharge,
      );
}

// State management providers for payment flow
@riverpod
class PaymentFlow extends _$PaymentFlow {
  @override
  PaymentFlowState build() => const PaymentFlowState.initial();

  Future<void> createPaymentIntent({
    required String bookingId,
    required int baseAmount,
    required String chefStripeAccountId,
    DateTime? eventDate,
  }) async {
    state = const PaymentFlowState.loading();

    final result = await ref.read(createPaymentIntentUseCaseProvider).call(
          bookingId: bookingId,
          baseAmount: baseAmount,
          chefStripeAccountId: chefStripeAccountId,
          eventDate: eventDate,
        );

    state = result.fold(
      (failure) => PaymentFlowState.error(failure.message),
      (paymentIntent) => PaymentFlowState.paymentIntentCreated(paymentIntent),
    );
  }

  Future<void> authorizePayment(String paymentIntentId) async {
    state = const PaymentFlowState.processing();

    final result = await ref.read(authorizePaymentUseCaseProvider).call(
          paymentIntentId: paymentIntentId,
        );

    state = result.fold(
      (failure) => PaymentFlowState.error(failure.message),
      (paymentIntent) => PaymentFlowState.paymentAuthorized(paymentIntent),
    );
  }

  Future<void> capturePayment({
    required String bookingId,
    int? actualAmount,
  }) async {
    state = const PaymentFlowState.processing();

    final result = await ref.read(capturePaymentUseCaseProvider).call(
          bookingId: bookingId,
          actualAmount: actualAmount,
        );

    state = result.fold(
      (failure) => PaymentFlowState.error(failure.message),
      (paymentIntent) => PaymentFlowState.paymentCaptured(paymentIntent),
    );
  }

  void reset() {
    state = const PaymentFlowState.initial();
  }
}

// Payment flow state
sealed class PaymentFlowState {
  const PaymentFlowState();

  const factory PaymentFlowState.initial() = PaymentFlowInitial;
  const factory PaymentFlowState.loading() = PaymentFlowLoading;
  const factory PaymentFlowState.processing() = PaymentFlowProcessing;
  const factory PaymentFlowState.paymentIntentCreated(PaymentIntent paymentIntent) = PaymentFlowPaymentIntentCreated;
  const factory PaymentFlowState.paymentAuthorized(PaymentIntent paymentIntent) = PaymentFlowPaymentAuthorized;
  const factory PaymentFlowState.paymentCaptured(PaymentIntent paymentIntent) = PaymentFlowPaymentCaptured;
  const factory PaymentFlowState.error(String message) = PaymentFlowError;
}

class PaymentFlowInitial extends PaymentFlowState {
  const PaymentFlowInitial();
}

class PaymentFlowLoading extends PaymentFlowState {
  const PaymentFlowLoading();
}

class PaymentFlowProcessing extends PaymentFlowState {
  const PaymentFlowProcessing();
}

class PaymentFlowPaymentIntentCreated extends PaymentFlowState {
  final PaymentIntent paymentIntent;
  const PaymentFlowPaymentIntentCreated(this.paymentIntent);
}

class PaymentFlowPaymentAuthorized extends PaymentFlowState {
  final PaymentIntent paymentIntent;
  const PaymentFlowPaymentAuthorized(this.paymentIntent);
}

class PaymentFlowPaymentCaptured extends PaymentFlowState {
  final PaymentIntent paymentIntent;
  const PaymentFlowPaymentCaptured(this.paymentIntent);
}

class PaymentFlowError extends PaymentFlowState {
  final String message;
  const PaymentFlowError(this.message);
}

// Payment Method Management Providers

@riverpod
Future<List<PaymentMethod>> savedPaymentMethods(SavedPaymentMethodsRef ref) async {
  final repository = ref.read(paymentRepositoryProvider);
  final result = await repository.getSavedPaymentMethods();
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (methods) => methods,
  );
}

@riverpod
Future<SetupIntentResponse> createSetupIntent(CreateSetupIntentRef ref) async {
  final repository = ref.read(paymentRepositoryProvider);
  final result = await repository.createSetupIntent();
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (response) => response,
  );
}

@riverpod
Future<PaymentMethod> savePaymentMethod(
  SavePaymentMethodRef ref, {
  required String setupIntentId,
  String? nickname,
}) async {
  final repository = ref.read(paymentRepositoryProvider);
  final result = await repository.savePaymentMethod(
    setupIntentId: setupIntentId,
    nickname: nickname,
  );
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (method) => method,
  );
}

@riverpod
Future<Either<Failure, void>> deletePaymentMethod(
  DeletePaymentMethodRef ref,
  String paymentMethodId,
) async {
  final repository = ref.read(paymentRepositoryProvider);
  return await repository.deletePaymentMethod(paymentMethodId);
}

@riverpod
Future<Either<Failure, PaymentMethod>> setDefaultPaymentMethod(
  SetDefaultPaymentMethodRef ref,
  String paymentMethodId,
) async {
  final repository = ref.read(paymentRepositoryProvider);
  return await repository.setDefaultPaymentMethod(paymentMethodId);
}

// Use case providers for payment methods
@riverpod
GetSavedPaymentMethods getSavedPaymentMethodsUseCase(GetSavedPaymentMethodsUseCaseRef ref) {
  return GetSavedPaymentMethods(ref.read(paymentRepositoryProvider));
}

@riverpod
CreateSetupIntent createSetupIntentUseCase(CreateSetupIntentUseCaseRef ref) {
  return CreateSetupIntent(ref.read(paymentRepositoryProvider));
}

@riverpod
SavePaymentMethod savePaymentMethodUseCase(SavePaymentMethodUseCaseRef ref) {
  return SavePaymentMethod(ref.read(paymentRepositoryProvider));
}

@riverpod
DeletePaymentMethod deletePaymentMethodUseCase(DeletePaymentMethodUseCaseRef ref) {
  return DeletePaymentMethod(ref.read(paymentRepositoryProvider));
}

@riverpod
SetDefaultPaymentMethod setDefaultPaymentMethodUseCase(SetDefaultPaymentMethodUseCaseRef ref) {
  return SetDefaultPaymentMethod(ref.read(paymentRepositoryProvider));
}