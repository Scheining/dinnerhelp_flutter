import 'package:dartz/dartz.dart';
import 'package:homechef/core/error/failures.dart';
import '../entities/danish_holidays.dart';

abstract class HolidaySurchargeCalculator {
  /// Get all Danish bank holidays for a specific year
  List<DanishHoliday> getDanishBankHolidays(int year);

  /// Calculate holiday surcharge for a booking date
  Future<Either<Failure, HolidayCalculationResult>> calculateHolidaySurcharge({
    required DateTime date,
    required int baseAmount, // in øre
    required String chefId,
  });

  /// Apply New Year's Eve surcharge specifically
  Future<Either<Failure, HolidayCalculationResult>> applyNewYearsEveSurcharge({
    required int baseAmount, // in øre
    required String chefId,
  });

  /// Display surcharge notice for a specific date
  Future<Either<Failure, SurchargeNotice>> displaySurchargeNotice({
    required DateTime date,
    required String chefId,
  });

  /// Validate chef's surcharge settings
  Future<Either<Failure, Unit>> validateSurchargeSettings({
    required String chefId,
    required HolidaySurchargeSettings settings,
  });

  /// Get chef's current surcharge settings
  Future<Either<Failure, HolidaySurchargeSettings>> getChefSurchargeSettings({
    required String chefId,
  });

  /// Update chef's surcharge settings
  Future<Either<Failure, Unit>> updateChefSurchargeSettings({
    required String chefId,
    required HolidaySurchargeSettings settings,
  });

  /// Check if a date is a holiday requiring surcharge
  bool isHolidayDate(DateTime date);

  /// Get holiday information for a specific date
  DanishHoliday? getHolidayForDate(DateTime date);

  /// Calculate total booking cost including holiday surcharges
  Future<Either<Failure, BookingCostBreakdown>> calculateTotalBookingCost({
    required String chefId,
    required DateTime date,
    required int baseAmount,
    required int numberOfGuests,
    required Duration duration,
  });

  /// Get upcoming holidays that might affect bookings
  Future<Either<Failure, List<UpcomingHolidayInfo>>> getUpcomingHolidays({
    required DateTime startDate,
    int daysAhead = 90,
  });
}

class SurchargeNotice {
  final DateTime date;
  final DanishHoliday? holiday;
  final bool hasSurcharge;
  final int surchargePercentage;
  final String message;
  final SurchargeNoticeType type;
  final String? additionalInfo;

  const SurchargeNotice({
    required this.date,
    this.holiday,
    required this.hasSurcharge,
    required this.surchargePercentage,
    required this.message,
    required this.type,
    this.additionalInfo,
  });
}

enum SurchargeNoticeType {
  info,
  warning,
  critical,
}

class BookingCostBreakdown {
  final int baseAmount; // in øre
  final int holidaySurcharge; // in øre
  final int serviceFee; // in øre
  final int tax; // in øre
  final int totalAmount; // in øre
  final List<CostLineItem> breakdown;
  final String explanation;

  const BookingCostBreakdown({
    required this.baseAmount,
    required this.holidaySurcharge,
    required this.serviceFee,
    required this.tax,
    required this.totalAmount,
    required this.breakdown,
    required this.explanation,
  });

  bool get hasHolidaySurcharge => holidaySurcharge > 0;
  double get totalAmountInDKK => totalAmount / 100.0;
  double get holidaySurchargeInDKK => holidaySurcharge / 100.0;
}

class CostLineItem {
  final String item;
  final int amount; // in øre
  final String description;
  final bool isHolidayRelated;

  const CostLineItem({
    required this.item,
    required this.amount,
    required this.description,
    this.isHolidayRelated = false,
  });

  double get amountInDKK => amount / 100.0;
}

class UpcomingHolidayInfo {
  final DanishHoliday holiday;
  final int daysUntil;
  final bool affectsBookings;
  final String impactDescription;

  const UpcomingHolidayInfo({
    required this.holiday,
    required this.daysUntil,
    required this.affectsBookings,
    required this.impactDescription,
  });

  bool get isWithinWeek => daysUntil <= 7;
  bool get isWithinMonth => daysUntil <= 30;
}