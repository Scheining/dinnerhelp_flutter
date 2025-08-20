import 'package:dartz/dartz.dart';
import 'package:homechef/core/error/failures.dart';
import '../entities/payment_calculation.dart';
import '../entities/payment_intent.dart';
import '../entities/refund.dart';
import '../entities/dispute.dart';
import '../repositories/payment_repository.dart';
import 'payment_service.dart';

class PaymentServiceImpl implements PaymentService {
  final PaymentRepository _paymentRepository;

  const PaymentServiceImpl({
    required PaymentRepository paymentRepository,
  }) : _paymentRepository = paymentRepository;

  @override
  Future<Either<Failure, PaymentIntent>> createPaymentIntent({
    required String bookingId,
    required int baseAmount,
    required String chefStripeAccountId,
    DateTime? eventDate,
  }) async {
    try {
      // Validate Stripe Connect account first
      final accountValidation = await validateStripeAccount(
        chefStripeAccountId: chefStripeAccountId,
      );
      
      if (accountValidation.isLeft()) {
        return accountValidation.fold(
          (failure) => Left(failure),
          (_) => const Left(StripeConnectAccountFailure()),
        );
      }

      // Calculate fees and total amount
      final calculation = calculateServiceFee(
        baseAmount: baseAmount,
        eventDate: eventDate,
      );

      return await _paymentRepository.createPaymentIntent(
        bookingId: bookingId,
        amount: calculation.totalAmount,
        serviceFeeAmount: calculation.serviceFeeAmount,
        vatAmount: calculation.vatAmount,
        chefStripeAccountId: chefStripeAccountId,
      );
    } catch (e) {
      return const Left(PaymentIntentCreationFailure());
    }
  }

  @override
  Future<Either<Failure, PaymentIntent>> authorizePayment({
    required String paymentIntentId,
  }) async {
    return await _paymentRepository.authorizePayment(
      paymentIntentId: paymentIntentId,
    );
  }

  @override
  Future<Either<Failure, PaymentIntent>> capturePayment({
    required String bookingId,
    int? actualAmount,
  }) async {
    return await _paymentRepository.capturePayment(
      bookingId: bookingId,
      actualAmount: actualAmount,
    );
  }

  @override
  Future<Either<Failure, Refund>> refundPayment({
    required String bookingId,
    int? amount,
    required RefundReason reason,
    String? description,
  }) async {
    return await _paymentRepository.refundPayment(
      bookingId: bookingId,
      amount: amount,
      reason: reason,
      description: description,
    );
  }

  @override
  PaymentCalculation calculateServiceFee({
    required int baseAmount,
    DateTime? eventDate,
    int? chefBankHolidayExtraCharge,
    int? chefNewYearEveExtraCharge,
  }) {
    // DinnerHelp service fee: 15%
    const serviceFeePercentage = 0.15;
    
    // Danish VAT: 25%
    const vatPercentage = 0.25;

    int adjustedBaseAmount = baseAmount;
    DateTime? bankHolidayDate;
    DateTime? newYearEveDate;

    // Apply holiday surcharges if applicable
    if (eventDate != null) {
      final isHoliday = _isHoliday(eventDate);
      final isNewYearEve = _isNewYearEve(eventDate);

      if (isHoliday && chefBankHolidayExtraCharge != null && chefBankHolidayExtraCharge > 0) {
        final extraCharge = (baseAmount * chefBankHolidayExtraCharge / 100).round();
        adjustedBaseAmount += extraCharge;
        bankHolidayDate = eventDate;
      }

      if (isNewYearEve && chefNewYearEveExtraCharge != null && chefNewYearEveExtraCharge > 0) {
        final extraCharge = (baseAmount * chefNewYearEveExtraCharge / 100).round();
        adjustedBaseAmount += extraCharge;
        newYearEveDate = eventDate;
      }
    }

    // Calculate service fee (DinnerHelp takes 15% from chef)
    final serviceFeeAmount = (adjustedBaseAmount * serviceFeePercentage).round();
    
    // Calculate VAT on the full amount (base + service fee)
    final preVatAmount = adjustedBaseAmount;
    final vatAmount = (preVatAmount * vatPercentage).round();
    
    // Total amount customer pays (base + VAT, service fee deducted from chef)
    final totalAmount = adjustedBaseAmount + vatAmount;
    
    // Chef receives base amount minus service fee and VAT
    final chefPayoutAmount = adjustedBaseAmount - serviceFeeAmount;
    
    // Stripe processing fees (estimated 1.4% + 1.8 DKK per transaction)
    final stripeFeeAmount = ((totalAmount * 0.014) + 180).round();

    return PaymentCalculation(
      baseAmount: baseAmount,
      serviceFeeAmount: serviceFeeAmount,
      vatAmount: vatAmount,
      stripeFeeAmount: stripeFeeAmount,
      totalAmount: totalAmount,
      chefPayoutAmount: chefPayoutAmount,
      serviceFeePercentage: serviceFeePercentage,
      vatPercentage: vatPercentage,
      currency: 'DKK',
      bankHolidayDate: bankHolidayDate,
      bankHolidayExtraCharge: chefBankHolidayExtraCharge,
      newYearEveDate: newYearEveDate,
      newYearEveExtraCharge: chefNewYearEveExtraCharge,
    );
  }

  @override
  Future<Either<Failure, PaymentIntent?>> getPaymentStatus({
    required String bookingId,
  }) async {
    return await _paymentRepository.getPaymentStatus(bookingId: bookingId);
  }

  @override
  Future<Either<Failure, PaymentIntent>> autoCapture({
    required String bookingId,
  }) async {
    // This would typically be called 24 hours after booking completion
    // or by a scheduled job/webhook
    return await _paymentRepository.capturePayment(
      bookingId: bookingId,
    );
  }

  @override
  Future<Either<Failure, PaymentIntent>> cancelPaymentIntent({
    required String paymentIntentId,
  }) async {
    return await _paymentRepository.cancelPaymentIntent(
      paymentIntentId: paymentIntentId,
    );
  }

  @override
  Future<Either<Failure, List<Dispute>>> getDisputes({
    required String paymentIntentId,
  }) async {
    return await _paymentRepository.getDisputes(
      paymentIntentId: paymentIntentId,
    );
  }

  @override
  Future<Either<Failure, bool>> validateStripeAccount({
    required String chefStripeAccountId,
  }) async {
    return await _paymentRepository.validateStripeAccount(
      chefStripeAccountId: chefStripeAccountId,
    );
  }

  /// Checks if a date is a Danish bank holiday
  bool _isHoliday(DateTime date) {
    // Danish public holidays (simplified - would need more comprehensive implementation)
    final year = date.year;
    
    // Fixed holidays
    final fixedHolidays = [
      DateTime(year, 1, 1),  // New Year's Day
      DateTime(year, 12, 24), // Christmas Eve
      DateTime(year, 12, 25), // Christmas Day
      DateTime(year, 12, 26), // Boxing Day
      DateTime(year, 12, 31), // New Year's Eve
    ];

    // Check if the date matches any fixed holiday
    for (final holiday in fixedHolidays) {
      if (date.year == holiday.year && 
          date.month == holiday.month && 
          date.day == holiday.day) {
        return true;
      }
    }

    // Could add Easter calculation here for variable holidays
    return false;
  }

  /// Checks if a date is New Year's Eve
  bool _isNewYearEve(DateTime date) {
    return date.month == 12 && date.day == 31;
  }
}