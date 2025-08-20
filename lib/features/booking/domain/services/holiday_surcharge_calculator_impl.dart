import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homechef/core/error/failures.dart';
import '../entities/danish_holidays.dart';
import 'holiday_surcharge_calculator.dart';

class HolidaySurchargeCalculatorImpl implements HolidaySurchargeCalculator {
  final SupabaseClient _supabaseClient;

  // Configuration constants
  static const int _defaultBankHolidaySurcharge = 15; // 15%
  static const int _defaultNewYearsEveSurcharge = 25; // 25%
  static const int _maxSurchargePercentage = 50; // Maximum 50% surcharge
  static const double _serviceFeeRate = 0.10; // 10% service fee
  static const double _taxRate = 0.25; // 25% Danish VAT

  HolidaySurchargeCalculatorImpl({
    required SupabaseClient supabaseClient,
  }) : _supabaseClient = supabaseClient;

  @override
  List<DanishHoliday> getDanishBankHolidays(int year) {
    return DanishHolidayCalendar.getHolidaysForYear(year);
  }

  @override
  Future<Either<Failure, HolidayCalculationResult>> calculateHolidaySurcharge({
    required DateTime date,
    required int baseAmount,
    required String chefId,
  }) async {
    try {
      // Check if date is a holiday
      final holiday = DanishHolidayCalendar.getHolidayForDate(date);
      
      if (holiday == null || !holiday.affectsSurcharge) {
        return Right(HolidayCalculationResult(
          date: date,
          holiday: holiday,
          hasSurcharge: false,
          surchargePercentage: 0,
          baseAmount: baseAmount,
          surchargeAmount: 0,
          totalAmount: baseAmount,
          explanation: 'No holiday surcharge applies',
        ));
      }

      // Get chef's surcharge settings
      final settingsResult = await getChefSurchargeSettings(chefId: chefId);
      if (settingsResult.isLeft()) {
        return settingsResult.fold((l) => Left(l), (r) => throw Exception());
      }

      final settings = settingsResult.getOrElse(() => throw Exception());

      // Check if chef has excluded this holiday
      if (settings.isHolidayExcluded(holiday.name)) {
        return Right(HolidayCalculationResult(
          date: date,
          holiday: holiday,
          hasSurcharge: false,
          surchargePercentage: 0,
          baseAmount: baseAmount,
          surchargeAmount: 0,
          totalAmount: baseAmount,
          explanation: 'Chef has waived holiday surcharge for ${holiday.name}',
        ));
      }

      // Calculate surcharge
      final surchargePercentage = settings.getSurchargeForHoliday(holiday.name);
      final surchargeAmount = (baseAmount * surchargePercentage / 100).round();
      final totalAmount = baseAmount + surchargeAmount;

      return Right(HolidayCalculationResult(
        date: date,
        holiday: holiday,
        hasSurcharge: true,
        surchargePercentage: surchargePercentage,
        baseAmount: baseAmount,
        surchargeAmount: surchargeAmount,
        totalAmount: totalAmount,
        explanation: _generateSurchargeExplanation(holiday, surchargePercentage),
      ));

    } catch (e) {
      return Left(HolidaySurchargeCalculationFailure('Failed to calculate holiday surcharge: $e'));
    }
  }

  @override
  Future<Either<Failure, HolidayCalculationResult>> applyNewYearsEveSurcharge({
    required int baseAmount,
    required String chefId,
  }) async {
    try {
      final newYearsEve = DateTime(DateTime.now().year, 12, 31);
      
      return await calculateHolidaySurcharge(
        date: newYearsEve,
        baseAmount: baseAmount,
        chefId: chefId,
      );

    } catch (e) {
      return Left(HolidaySurchargeCalculationFailure('Failed to apply New Year\'s Eve surcharge: $e'));
    }
  }

  @override
  Future<Either<Failure, SurchargeNotice>> displaySurchargeNotice({
    required DateTime date,
    required String chefId,
  }) async {
    try {
      final holiday = DanishHolidayCalendar.getHolidayForDate(date);
      
      if (holiday == null || !holiday.affectsSurcharge) {
        return Right(SurchargeNotice(
          date: date,
          holiday: holiday,
          hasSurcharge: false,
          surchargePercentage: 0,
          message: 'No holiday surcharge applies for this date',
          type: SurchargeNoticeType.info,
        ));
      }

      // Get chef's surcharge settings
      final settingsResult = await getChefSurchargeSettings(chefId: chefId);
      if (settingsResult.isLeft()) {
        return settingsResult.fold((l) => Left(l), (r) => throw Exception());
      }

      final settings = settingsResult.getOrElse(() => throw Exception());
      
      if (settings.isHolidayExcluded(holiday.name)) {
        return Right(SurchargeNotice(
          date: date,
          holiday: holiday,
          hasSurcharge: false,
          surchargePercentage: 0,
          message: 'This chef has waived the holiday surcharge for ${holiday.name}',
          type: SurchargeNoticeType.info,
          additionalInfo: 'Enjoy standard pricing on this holiday!',
        ));
      }

      final surchargePercentage = settings.getSurchargeForHoliday(holiday.name);
      final noticeType = _determineSurchargeNoticeType(surchargePercentage);
      
      return Right(SurchargeNotice(
        date: date,
        holiday: holiday,
        hasSurcharge: true,
        surchargePercentage: surchargePercentage,
        message: _generateSurchargeNoticeMessage(holiday, surchargePercentage),
        type: noticeType,
        additionalInfo: _generateAdditionalInfo(holiday, surchargePercentage),
      ));

    } catch (e) {
      return Left(HolidaySurchargeCalculationFailure('Failed to generate surcharge notice: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> validateSurchargeSettings({
    required String chefId,
    required HolidaySurchargeSettings settings,
  }) async {
    try {
      final violations = <String>[];

      // Validate surcharge percentages
      if (settings.bankHolidayExtraCharge < 0 || settings.bankHolidayExtraCharge > _maxSurchargePercentage) {
        violations.add('Bank holiday surcharge must be between 0% and $_maxSurchargePercentage%');
      }

      if (settings.newYearsEveExtraCharge < 0 || settings.newYearsEveExtraCharge > _maxSurchargePercentage) {
        violations.add('New Year\'s Eve surcharge must be between 0% and $_maxSurchargePercentage%');
      }

      // Validate excluded holidays
      final currentYear = DateTime.now().year;
      final validHolidays = getDanishBankHolidays(currentYear).map((h) => h.name).toSet();
      
      for (final excludedHoliday in settings.excludedHolidays) {
        if (!validHolidays.contains(excludedHoliday)) {
          violations.add('Invalid holiday name in exclusions: $excludedHoliday');
        }
      }

      // Business rule validations
      if (settings.newYearsEveExtraCharge < settings.bankHolidayExtraCharge) {
        violations.add('New Year\'s Eve surcharge should not be less than regular holiday surcharge');
      }

      if (violations.isNotEmpty) {
        return Left(SurchargeSettingsFailure(violations.join(', ')));
      }

      return const Right(unit);

    } catch (e) {
      return Left(SurchargeSettingsFailure('Failed to validate surcharge settings: $e'));
    }
  }

  @override
  Future<Either<Failure, HolidaySurchargeSettings>> getChefSurchargeSettings({
    required String chefId,
  }) async {
    try {
      final response = await _supabaseClient
          .from('chefs')
          .select('bank_holiday_extra_charge, new_years_eve_extra_charge')
          .eq('id', chefId)
          .single();

      // Get excluded holidays if they exist
      final excludedResponse = await _supabaseClient
          .from('chef_holiday_exclusions')
          .select('holiday_name')
          .eq('chef_id', chefId);

      final excludedHolidays = excludedResponse
          .map<String>((row) => row['holiday_name'] as String)
          .toList();

      final settings = HolidaySurchargeSettings(
        chefId: chefId,
        bankHolidayExtraCharge: response['bank_holiday_extra_charge'] ?? _defaultBankHolidaySurcharge,
        newYearsEveExtraCharge: response['new_years_eve_extra_charge'] ?? _defaultNewYearsEveSurcharge,
        excludedHolidays: excludedHolidays,
        updatedAt: DateTime.now(), // Would be actual update timestamp from database
      );

      return Right(settings);

    } catch (e) {
      // Return default settings if not found
      final defaultSettings = HolidaySurchargeSettings(
        chefId: chefId,
        bankHolidayExtraCharge: _defaultBankHolidaySurcharge,
        newYearsEveExtraCharge: _defaultNewYearsEveSurcharge,
        updatedAt: DateTime.now(),
      );

      return Right(defaultSettings);
    }
  }

  @override
  Future<Either<Failure, Unit>> updateChefSurchargeSettings({
    required String chefId,
    required HolidaySurchargeSettings settings,
  }) async {
    try {
      // Validate settings first
      final validationResult = await validateSurchargeSettings(
        chefId: chefId,
        settings: settings,
      );

      if (validationResult.isLeft()) {
        return validationResult.fold((l) => Left(l), (r) => throw Exception());
      }

      // Update chef table
      await _supabaseClient
          .from('chefs')
          .update({
            'bank_holiday_extra_charge': settings.bankHolidayExtraCharge,
            'new_years_eve_extra_charge': settings.newYearsEveExtraCharge,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', chefId);

      // Update excluded holidays
      // First, delete existing exclusions
      await _supabaseClient
          .from('chef_holiday_exclusions')
          .delete()
          .eq('chef_id', chefId);

      // Insert new exclusions
      if (settings.excludedHolidays.isNotEmpty) {
        final exclusions = settings.excludedHolidays
            .map((holiday) => {
                  'chef_id': chefId,
                  'holiday_name': holiday,
                  'created_at': DateTime.now().toIso8601String(),
                })
            .toList();

        await _supabaseClient
            .from('chef_holiday_exclusions')
            .insert(exclusions);
      }

      return const Right(unit);

    } catch (e) {
      return Left(SurchargeSettingsFailure('Failed to update surcharge settings: $e'));
    }
  }

  @override
  bool isHolidayDate(DateTime date) {
    final holiday = DanishHolidayCalendar.getHolidayForDate(date);
    return holiday != null && holiday.affectsSurcharge;
  }

  @override
  DanishHoliday? getHolidayForDate(DateTime date) {
    return DanishHolidayCalendar.getHolidayForDate(date);
  }

  @override
  Future<Either<Failure, BookingCostBreakdown>> calculateTotalBookingCost({
    required String chefId,
    required DateTime date,
    required int baseAmount,
    required int numberOfGuests,
    required Duration duration,
  }) async {
    try {
      final breakdown = <CostLineItem>[];
      
      // Base cost
      breakdown.add(CostLineItem(
        item: 'Base Service Fee',
        amount: baseAmount,
        description: 'Chef service for ${duration.inHours} hours, $numberOfGuests guests',
      ));

      int totalAmount = baseAmount;

      // Calculate holiday surcharge
      final surchargeResult = await calculateHolidaySurcharge(
        date: date,
        baseAmount: baseAmount,
        chefId: chefId,
      );

      int holidaySurcharge = 0;
      if (surchargeResult.isRight()) {
        final calculation = surchargeResult.getOrElse(() => throw Exception());
        if (calculation.hasSurcharge) {
          holidaySurcharge = calculation.surchargeAmount;
          totalAmount += holidaySurcharge;
          
          breakdown.add(CostLineItem(
            item: 'Holiday Surcharge',
            amount: holidaySurcharge,
            description: '${calculation.surchargePercentage}% surcharge for ${calculation.holiday?.name ?? 'holiday'}',
            isHolidayRelated: true,
          ));
        }
      }

      // Calculate service fee (on base amount + surcharge)
      final serviceFee = (totalAmount * _serviceFeeRate).round();
      totalAmount += serviceFee;
      
      breakdown.add(CostLineItem(
        item: 'Service Fee',
        amount: serviceFee,
        description: '${(_serviceFeeRate * 100).toStringAsFixed(0)}% platform service fee',
      ));

      // Calculate tax (Danish VAT)
      final tax = (totalAmount * _taxRate).round();
      totalAmount += tax;
      
      breakdown.add(CostLineItem(
        item: 'VAT',
        amount: tax,
        description: '${(_taxRate * 100).toStringAsFixed(0)}% Danish VAT',
      ));

      final explanation = _generateCostExplanation(
        holidaySurcharge > 0,
        surchargeResult.fold(
          (l) => null,
          (r) => r.holiday?.name,
        ),
      );

      return Right(BookingCostBreakdown(
        baseAmount: baseAmount,
        holidaySurcharge: holidaySurcharge,
        serviceFee: serviceFee,
        tax: tax,
        totalAmount: totalAmount,
        breakdown: breakdown,
        explanation: explanation,
      ));

    } catch (e) {
      return Left(ServiceFeeCalculationFailure('Failed to calculate total booking cost: $e'));
    }
  }

  @override
  Future<Either<Failure, List<UpcomingHolidayInfo>>> getUpcomingHolidays({
    required DateTime startDate,
    int daysAhead = 90,
  }) async {
    try {
      final endDate = startDate.add(Duration(days: daysAhead));
      final holidays = DanishHolidayCalendar.getHolidaysInRange(startDate, endDate);
      
      final upcomingHolidays = <UpcomingHolidayInfo>[];
      
      for (final holiday in holidays) {
        if (holiday.date.isAfter(startDate)) {
          final daysUntil = holiday.date.difference(startDate).inDays;
          
          upcomingHolidays.add(UpcomingHolidayInfo(
            holiday: holiday,
            daysUntil: daysUntil,
            affectsBookings: holiday.affectsSurcharge,
            impactDescription: _generateHolidayImpactDescription(holiday),
          ));
        }
      }

      // Sort by date
      upcomingHolidays.sort((a, b) => a.daysUntil.compareTo(b.daysUntil));

      return Right(upcomingHolidays);

    } catch (e) {
      return Left(ServerFailure('Failed to get upcoming holidays: $e'));
    }
  }

  // Private helper methods

  String _generateSurchargeExplanation(DanishHoliday holiday, int surchargePercentage) {
    return '$surchargePercentage% holiday surcharge applies for ${holiday.name} (${holiday.description})';
  }

  SurchargeNoticeType _determineSurchargeNoticeType(int surchargePercentage) {
    if (surchargePercentage >= 30) return SurchargeNoticeType.critical;
    if (surchargePercentage >= 15) return SurchargeNoticeType.warning;
    return SurchargeNoticeType.info;
  }

  String _generateSurchargeNoticeMessage(DanishHoliday holiday, int surchargePercentage) {
    switch (surchargePercentage) {
      case 0:
        return 'No additional charges for ${holiday.name}';
      case int percentage when percentage <= 10:
        return 'Small holiday surcharge of $percentage% applies for ${holiday.name}';
      case int percentage when percentage <= 20:
        return 'Holiday surcharge of $percentage% applies for ${holiday.name}';
      default:
        return 'Higher demand pricing: $surchargePercentage% surcharge for ${holiday.name}';
    }
  }

  String? _generateAdditionalInfo(DanishHoliday holiday, int surchargePercentage) {
    if (surchargePercentage >= 25) {
      return 'Higher rates reflect increased demand and limited chef availability during major holidays.';
    }
    
    if (holiday.name == 'New Year\'s Eve') {
      return 'New Year\'s Eve is our busiest night with premium pricing.';
    }
    
    if (surchargePercentage > 0) {
      return 'Holiday surcharges help ensure chef availability during peak times.';
    }
    
    return null;
  }

  String _generateCostExplanation(bool hasHolidaySurcharge, String? holidayName) {
    final parts = <String>[];
    
    parts.add('Total includes base service fee, platform fee, and Danish VAT');
    
    if (hasHolidaySurcharge && holidayName != null) {
      parts.add('Holiday surcharge applies due to $holidayName');
    }
    
    return parts.join('. ') + '.';
  }

  String _generateHolidayImpactDescription(DanishHoliday holiday) {
    if (!holiday.affectsSurcharge) {
      return 'No impact on booking prices';
    }
    
    if (holiday.name == 'New Year\'s Eve') {
      return 'Highest demand night - book early and expect premium pricing';
    }
    
    if (holiday.isPublicHoliday) {
      return 'Public holiday - increased demand and pricing';
    }
    
    return 'May affect chef availability and pricing';
  }
}