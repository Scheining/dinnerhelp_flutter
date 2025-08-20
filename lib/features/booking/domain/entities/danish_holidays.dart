import 'package:equatable/equatable.dart';

class DanishHoliday extends Equatable {
  final String name;
  final DateTime date;
  final HolidayType type;
  final bool isPublicHoliday;
  final bool affectsSurcharge;
  final String description;

  const DanishHoliday({
    required this.name,
    required this.date,
    required this.type,
    required this.isPublicHoliday,
    required this.affectsSurcharge,
    required this.description,
  });

  @override
  List<Object> get props => [name, date, type, isPublicHoliday, affectsSurcharge, description];
}

enum HolidayType {
  fixed,
  movable,
  special,
}

class HolidaySurchargeSettings extends Equatable {
  final String chefId;
  final int bankHolidayExtraCharge; // Percentage 0-100
  final int newYearsEveExtraCharge; // Percentage 0-100
  final List<String> excludedHolidays; // Holiday names chef doesn't charge extra for
  final DateTime updatedAt;

  const HolidaySurchargeSettings({
    required this.chefId,
    required this.bankHolidayExtraCharge,
    required this.newYearsEveExtraCharge,
    this.excludedHolidays = const [],
    required this.updatedAt,
  });

  bool isHolidayExcluded(String holidayName) => excludedHolidays.contains(holidayName);

  int getSurchargeForHoliday(String holidayName) {
    if (isHolidayExcluded(holidayName)) return 0;
    
    if (holidayName == 'New Year\'s Eve') {
      return newYearsEveExtraCharge;
    }
    
    return bankHolidayExtraCharge;
  }

  @override
  List<Object> get props => [
    chefId,
    bankHolidayExtraCharge,
    newYearsEveExtraCharge,
    excludedHolidays,
    updatedAt,
  ];
}

class HolidayCalculationResult extends Equatable {
  final DateTime date;
  final DanishHoliday? holiday;
  final bool hasSurcharge;
  final int surchargePercentage;
  final int baseAmount; // in øre
  final int surchargeAmount; // in øre
  final int totalAmount; // in øre
  final String explanation;

  const HolidayCalculationResult({
    required this.date,
    this.holiday,
    required this.hasSurcharge,
    required this.surchargePercentage,
    required this.baseAmount,
    required this.surchargeAmount,
    required this.totalAmount,
    required this.explanation,
  });

  bool get isHoliday => holiday != null;

  @override
  List<Object?> get props => [
    date,
    holiday,
    hasSurcharge,
    surchargePercentage,
    baseAmount,
    surchargeAmount,
    totalAmount,
    explanation,
  ];
}

/// Danish holiday calendar with both fixed and movable holidays
class DanishHolidayCalendar {
  static List<DanishHoliday> getHolidaysForYear(int year) {
    final holidays = <DanishHoliday>[];
    
    // Fixed holidays
    holidays.addAll(_getFixedHolidays(year));
    
    // Movable holidays (Easter-based)
    holidays.addAll(_getMovableHolidays(year));
    
    // Special holidays
    holidays.addAll(_getSpecialHolidays(year));
    
    // Sort by date
    holidays.sort((a, b) => a.date.compareTo(b.date));
    
    return holidays;
  }

  static List<DanishHoliday> _getFixedHolidays(int year) {
    return [
      DanishHoliday(
        name: 'New Year\'s Day',
        date: DateTime(year, 1, 1),
        type: HolidayType.fixed,
        isPublicHoliday: true,
        affectsSurcharge: true,
        description: 'Nytårsdag',
      ),
      DanishHoliday(
        name: 'New Year\'s Eve',
        date: DateTime(year, 12, 31),
        type: HolidayType.special,
        isPublicHoliday: false,
        affectsSurcharge: true,
        description: 'Nytårsaften - special evening with higher demand',
      ),
      DanishHoliday(
        name: 'Christmas Eve',
        date: DateTime(year, 12, 24),
        type: HolidayType.fixed,
        isPublicHoliday: true,
        affectsSurcharge: true,
        description: 'Juleaften',
      ),
      DanishHoliday(
        name: 'Christmas Day',
        date: DateTime(year, 12, 25),
        type: HolidayType.fixed,
        isPublicHoliday: true,
        affectsSurcharge: true,
        description: 'Juledag',
      ),
      DanishHoliday(
        name: 'Boxing Day',
        date: DateTime(year, 12, 26),
        type: HolidayType.fixed,
        isPublicHoliday: true,
        affectsSurcharge: true,
        description: '2. Juledag',
      ),
      DanishHoliday(
        name: 'Constitution Day',
        date: DateTime(year, 6, 5),
        type: HolidayType.fixed,
        isPublicHoliday: true,
        affectsSurcharge: true,
        description: 'Grundlovsdag',
      ),
    ];
  }

  static List<DanishHoliday> _getMovableHolidays(int year) {
    final easter = _calculateEaster(year);
    
    return [
      // Maundy Thursday (Thursday before Easter)
      DanishHoliday(
        name: 'Maundy Thursday',
        date: easter.subtract(const Duration(days: 3)),
        type: HolidayType.movable,
        isPublicHoliday: true,
        affectsSurcharge: true,
        description: 'Skærtorsdag',
      ),
      // Good Friday (Friday before Easter)
      DanishHoliday(
        name: 'Good Friday',
        date: easter.subtract(const Duration(days: 2)),
        type: HolidayType.movable,
        isPublicHoliday: true,
        affectsSurcharge: true,
        description: 'Langfredag',
      ),
      // Easter Sunday
      DanishHoliday(
        name: 'Easter Sunday',
        date: easter,
        type: HolidayType.movable,
        isPublicHoliday: true,
        affectsSurcharge: true,
        description: 'Påskedag',
      ),
      // Easter Monday
      DanishHoliday(
        name: 'Easter Monday',
        date: easter.add(const Duration(days: 1)),
        type: HolidayType.movable,
        isPublicHoliday: true,
        affectsSurcharge: true,
        description: '2. Påskedag',
      ),
      // Store Bededag (4th Friday after Easter)
      DanishHoliday(
        name: 'Store Bededag',
        date: easter.add(const Duration(days: 26)),
        type: HolidayType.movable,
        isPublicHoliday: true,
        affectsSurcharge: true,
        description: 'Store Bededag - Great Prayer Day',
      ),
      // Ascension Day (39 days after Easter)
      DanishHoliday(
        name: 'Ascension Day',
        date: easter.add(const Duration(days: 39)),
        type: HolidayType.movable,
        isPublicHoliday: true,
        affectsSurcharge: true,
        description: 'Kristi Himmelfartsdag',
      ),
      // Whit Sunday (49 days after Easter)
      DanishHoliday(
        name: 'Whit Sunday',
        date: easter.add(const Duration(days: 49)),
        type: HolidayType.movable,
        isPublicHoliday: true,
        affectsSurcharge: true,
        description: 'Pinsedag',
      ),
      // Whit Monday (50 days after Easter)
      DanishHoliday(
        name: 'Whit Monday',
        date: easter.add(const Duration(days: 50)),
        type: HolidayType.movable,
        isPublicHoliday: true,
        affectsSurcharge: true,
        description: '2. Pinsedag',
      ),
    ];
  }

  static List<DanishHoliday> _getSpecialHolidays(int year) {
    return [
      // Add any special one-time holidays or observances here
      // For example, royal birthdays, special commemorations, etc.
    ];
  }

  /// Calculate Easter Sunday for a given year using the algorithm
  static DateTime _calculateEaster(int year) {
    int a = year % 19;
    int b = year ~/ 100;
    int c = year % 100;
    int d = b ~/ 4;
    int e = b % 4;
    int f = (b + 8) ~/ 25;
    int g = (b - f + 1) ~/ 3;
    int h = (19 * a + b - d - g + 15) % 30;
    int i = c ~/ 4;
    int k = c % 4;
    int l = (32 + 2 * e + 2 * i - h - k) % 7;
    int m = (a + 11 * h + 22 * l) ~/ 451;
    int month = (h + l - 7 * m + 114) ~/ 31;
    int day = ((h + l - 7 * m + 114) % 31) + 1;
    
    return DateTime(year, month, day);
  }

  /// Check if a given date is a Danish holiday
  static DanishHoliday? getHolidayForDate(DateTime date) {
    final holidays = getHolidaysForYear(date.year);
    
    for (final holiday in holidays) {
      if (holiday.date.year == date.year &&
          holiday.date.month == date.month &&
          holiday.date.day == date.day) {
        return holiday;
      }
    }
    
    return null;
  }

  /// Get all holidays in a date range
  static List<DanishHoliday> getHolidaysInRange(DateTime start, DateTime end) {
    final holidays = <DanishHoliday>[];
    
    for (int year = start.year; year <= end.year; year++) {
      final yearHolidays = getHolidaysForYear(year);
      
      for (final holiday in yearHolidays) {
        if (holiday.date.isAfter(start.subtract(const Duration(days: 1))) &&
            holiday.date.isBefore(end.add(const Duration(days: 1)))) {
          holidays.add(holiday);
        }
      }
    }
    
    return holidays;
  }
}