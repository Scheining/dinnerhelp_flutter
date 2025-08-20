import '../entities/payment_calculation.dart';
import '../services/payment_service.dart';

class CalculatePaymentAmount {
  final PaymentService _paymentService;

  const CalculatePaymentAmount(this._paymentService);

  PaymentCalculation call({
    required int baseAmount,
    DateTime? eventDate,
    int? chefBankHolidayExtraCharge,
    int? chefNewYearEveExtraCharge,
  }) {
    return _paymentService.calculateServiceFee(
      baseAmount: baseAmount,
      eventDate: eventDate,
      chefBankHolidayExtraCharge: chefBankHolidayExtraCharge,
      chefNewYearEveExtraCharge: chefNewYearEveExtraCharge,
    );
  }
}