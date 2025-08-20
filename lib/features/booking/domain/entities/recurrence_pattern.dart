import 'package:equatable/equatable.dart';

enum RecurrenceType {
  weekly,
  biWeekly,
  every3Weeks,
  monthly,
}

extension RecurrenceTypeExtension on RecurrenceType {
  String get name {
    switch (this) {
      case RecurrenceType.weekly:
        return 'weekly';
      case RecurrenceType.biWeekly:
        return 'bi_weekly';
      case RecurrenceType.every3Weeks:
        return 'every_3_weeks';
      case RecurrenceType.monthly:
        return 'monthly';
    }
  }

  static RecurrenceType fromString(String value) {
    switch (value) {
      case 'weekly':
        return RecurrenceType.weekly;
      case 'bi_weekly':
        return RecurrenceType.biWeekly;
      case 'every_3_weeks':
        return RecurrenceType.every3Weeks;
      case 'monthly':
        return RecurrenceType.monthly;
      default:
        throw ArgumentError('Invalid recurrence type: $value');
    }
  }

  Duration get interval {
    switch (this) {
      case RecurrenceType.weekly:
        return const Duration(days: 7);
      case RecurrenceType.biWeekly:
        return const Duration(days: 14);
      case RecurrenceType.every3Weeks:
        return const Duration(days: 21);
      case RecurrenceType.monthly:
        return const Duration(days: 30); // Approximation
    }
  }
}

class RecurrencePattern extends Equatable {
  final RecurrenceType type;
  final int intervalValue;
  final DateTime startDate;
  final DateTime? endDate;
  final int? maxOccurrences;

  const RecurrencePattern({
    required this.type,
    this.intervalValue = 1,
    required this.startDate,
    this.endDate,
    this.maxOccurrences,
  });

  bool get hasEndDate => endDate != null;
  bool get hasMaxOccurrences => maxOccurrences != null;

  DateTime calculateNextOccurrence(DateTime currentDate) {
    switch (type) {
      case RecurrenceType.weekly:
        return currentDate.add(Duration(days: 7 * intervalValue));
      case RecurrenceType.biWeekly:
        return currentDate.add(Duration(days: 14 * intervalValue));
      case RecurrenceType.every3Weeks:
        return currentDate.add(Duration(days: 21 * intervalValue));
      case RecurrenceType.monthly:
        return DateTime(
          currentDate.year,
          currentDate.month + intervalValue,
          currentDate.day,
          currentDate.hour,
          currentDate.minute,
          currentDate.second,
        );
    }
  }

  List<DateTime> generateOccurrences({DateTime? until}) {
    final occurrences = <DateTime>[];
    var currentDate = startDate;
    final effectiveEndDate = until ?? endDate ?? startDate.add(const Duration(days: 180)); // 6 months max

    int count = 0;
    while (currentDate.isBefore(effectiveEndDate) || currentDate.isAtSameMomentAs(effectiveEndDate)) {
      if (maxOccurrences != null && count >= maxOccurrences!) {
        break;
      }

      occurrences.add(currentDate);
      currentDate = calculateNextOccurrence(currentDate);
      count++;

      // Safety check to prevent infinite loops
      if (count > 1000) {
        break;
      }
    }

    return occurrences;
  }

  @override
  List<Object?> get props => [type, intervalValue, startDate, endDate, maxOccurrences];

  @override
  String toString() {
    return 'RecurrencePattern(type: $type, interval: $intervalValue, start: $startDate, end: $endDate, maxOccurrences: $maxOccurrences)';
  }
}