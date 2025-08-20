import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_calculation.freezed.dart';

@freezed
class PaymentCalculation with _$PaymentCalculation {
  const factory PaymentCalculation({
    required int baseAmount, // in øre
    required int serviceFeeAmount,
    required int vatAmount,
    required int stripeFeeAmount,
    required int totalAmount,
    required int chefPayoutAmount,
    required double serviceFeePercentage,
    required double vatPercentage,
    required String currency,
    DateTime? bankHolidayDate,
    int? bankHolidayExtraCharge,
    DateTime? newYearEveDate,
    int? newYearEveExtraCharge,
  }) = _PaymentCalculation;

  const PaymentCalculation._();

  /// Total amount user pays (including all fees)
  int get customerTotal => totalAmount;

  /// Amount chef receives after platform fees
  int get chefReceives => chefPayoutAmount;

  /// Platform revenue from this transaction
  int get platformRevenue => serviceFeeAmount;

  /// Format amount in DKK for display
  String formatAmount(int amount) {
    final dkk = amount / 100;
    return '${dkk.toStringAsFixed(2)} kr';
  }

  /// Format base amount
  String get formattedBaseAmount => formatAmount(baseAmount);

  /// Format service fee
  String get formattedServiceFee => formatAmount(serviceFeeAmount);

  /// Format VAT amount
  String get formattedVatAmount => formatAmount(vatAmount);

  /// Format total amount
  String get formattedTotalAmount => formatAmount(totalAmount);

  /// Format chef payout
  String get formattedChefPayout => formatAmount(chefPayoutAmount);

  /// Check if this is a holiday booking
  bool get hasHolidayCharges =>
      bankHolidayDate != null || newYearEveDate != null;
}