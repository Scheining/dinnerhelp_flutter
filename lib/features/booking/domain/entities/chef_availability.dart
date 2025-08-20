import 'package:equatable/equatable.dart';

enum AvailabilityType {
  available,
  unavailable,
  busy,
}

class ChefAvailability extends Equatable {
  final String chefId;
  final DateTime date;
  final String? startTime; // Format: "HH:MM", null means all day
  final String? endTime; // Format: "HH:MM", null means all day
  final AvailabilityType type;
  final String? reason;
  final bool overridesWorkingHours; // If true, this overrides regular working hours

  const ChefAvailability({
    required this.chefId,
    required this.date,
    this.startTime,
    this.endTime,
    required this.type,
    this.reason,
    this.overridesWorkingHours = false,
  });

  bool get isAllDay => startTime == null && endTime == null;
  bool get isAvailable => type == AvailabilityType.available;
  bool get isUnavailable => type == AvailabilityType.unavailable;
  bool get isBusy => type == AvailabilityType.busy;

  DateTime? getStartDateTime() {
    if (startTime == null) return null;
    final parts = startTime!.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  DateTime? getEndDateTime() {
    if (endTime == null) return null;
    final parts = endTime!.split(':');
    var endDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );

    // If end time is before start time and we have a start time, it goes to next day
    if (startTime != null) {
      final startDateTime = getStartDateTime()!;
      if (endDateTime.isBefore(startDateTime)) {
        endDateTime = endDateTime.add(const Duration(days: 1));
      }
    }

    return endDateTime;
  }

  bool appliesToTime(DateTime time) {
    if (isAllDay) return time.year == date.year && time.month == date.month && time.day == date.day;
    
    final start = getStartDateTime();
    final end = getEndDateTime();
    
    if (start == null || end == null) return false;
    
    return time.isAfter(start) || time.isAtSameMomentAs(start) &&
           time.isBefore(end) || time.isAtSameMomentAs(end);
  }

  @override
  List<Object?> get props => [chefId, date, startTime, endTime, type, reason, overridesWorkingHours];

  @override
  String toString() {
    final timeStr = isAllDay ? 'all day' : '$startTime-$endTime';
    return 'ChefAvailability(chef: $chefId, date: ${date.toIso8601String().split('T')[0]}, time: $timeStr, type: $type)';
  }
}