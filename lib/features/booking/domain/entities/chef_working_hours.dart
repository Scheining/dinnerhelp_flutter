import 'package:equatable/equatable.dart';

class ChefWorkingHours extends Equatable {
  final String chefId;
  final int dayOfWeek; // 0 = Sunday, 1 = Monday, ..., 6 = Saturday
  final String startTime; // Format: "HH:MM"
  final String endTime; // Format: "HH:MM"
  final bool isActive;

  const ChefWorkingHours({
    required this.chefId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.isActive = true,
  });

  DateTime getStartTimeForDate(DateTime date) {
    final parts = startTime.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  DateTime getEndTimeForDate(DateTime date) {
    final parts = endTime.split(':');
    var endDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );

    // If end time is before start time, it means it goes to next day
    final startDateTime = getStartTimeForDate(date);
    if (endDateTime.isBefore(startDateTime)) {
      endDateTime = endDateTime.add(const Duration(days: 1));
    }

    return endDateTime;
  }

  bool isWorkingDay(DateTime date) {
    return isActive && date.weekday % 7 == dayOfWeek;
  }

  Duration get workingDuration {
    final start = DateTime(2024, 1, 1, int.parse(startTime.split(':')[0]), int.parse(startTime.split(':')[1]));
    final end = DateTime(2024, 1, 1, int.parse(endTime.split(':')[0]), int.parse(endTime.split(':')[1]));
    
    if (end.isBefore(start)) {
      // Next day
      return end.add(const Duration(days: 1)).difference(start);
    }
    return end.difference(start);
  }

  @override
  List<Object?> get props => [chefId, dayOfWeek, startTime, endTime, isActive];

  @override
  String toString() {
    final days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return 'ChefWorkingHours(chef: $chefId, ${days[dayOfWeek]}: $startTime-$endTime, active: $isActive)';
  }
}