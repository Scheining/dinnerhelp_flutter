import 'package:equatable/equatable.dart';

enum TimeOffType {
  vacation,
  holiday,
  sickLeave,
  personalTime,
  maintenance,
}

class ChefTimeOff extends Equatable {
  final String chefId;
  final DateTime startDate;
  final DateTime endDate;
  final TimeOffType type;
  final String? reason;
  final bool isRecurring; // For holidays that repeat yearly
  final bool isApproved;

  const ChefTimeOff({
    required this.chefId,
    required this.startDate,
    required this.endDate,
    required this.type,
    this.reason,
    this.isRecurring = false,
    this.isApproved = true,
  });

  bool get isMultiDay => !isSameDay(startDate, endDate);
  bool get isSingleDay => isSameDay(startDate, endDate);

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  bool includesDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final startOnly = DateTime(startDate.year, startDate.month, startDate.day);
    final endOnly = DateTime(endDate.year, endDate.month, endDate.day);

    return (dateOnly.isAfter(startOnly) || dateOnly.isAtSameMomentAs(startOnly)) &&
           (dateOnly.isBefore(endOnly) || dateOnly.isAtSameMomentAs(endOnly));
  }

  bool overlapsWith(DateTime start, DateTime end) {
    return startDate.isBefore(end) && endDate.isAfter(start);
  }

  Duration get duration => endDate.difference(startDate);

  List<DateTime> getDatesInPeriod() {
    final dates = <DateTime>[];
    var currentDate = DateTime(startDate.year, startDate.month, startDate.day);
    final lastDate = DateTime(endDate.year, endDate.month, endDate.day);

    while (currentDate.isBefore(lastDate) || currentDate.isAtSameMomentAs(lastDate)) {
      dates.add(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return dates;
  }

  // For recurring holidays, generate occurrences for a given year
  ChefTimeOff? generateForYear(int year) {
    if (!isRecurring) return null;

    final newStartDate = DateTime(
      year,
      startDate.month,
      startDate.day,
      startDate.hour,
      startDate.minute,
      startDate.second,
    );

    final newEndDate = DateTime(
      year,
      endDate.month,
      endDate.day,
      endDate.hour,
      endDate.minute,
      endDate.second,
    );

    return ChefTimeOff(
      chefId: chefId,
      startDate: newStartDate,
      endDate: newEndDate,
      type: type,
      reason: reason,
      isRecurring: isRecurring,
      isApproved: isApproved,
    );
  }

  @override
  List<Object?> get props => [chefId, startDate, endDate, type, reason, isRecurring, isApproved];

  @override
  String toString() {
    final startStr = startDate.toIso8601String().split('T')[0];
    final endStr = endDate.toIso8601String().split('T')[0];
    return 'ChefTimeOff(chef: $chefId, $startStr to $endStr, type: $type, recurring: $isRecurring)';
  }
}