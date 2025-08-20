import 'package:equatable/equatable.dart';

class TimeSlot extends Equatable {
  final DateTime startTime;
  final DateTime endTime;
  final bool isAvailable;
  final String? unavailabilityReason;

  const TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    this.unavailabilityReason,
  });

  Duration get duration => endTime.difference(startTime);

  bool overlaps(TimeSlot other) {
    return startTime.isBefore(other.endTime) && endTime.isAfter(other.startTime);
  }

  bool contains(DateTime time) {
    return time.isAfter(startTime) && time.isBefore(endTime);
  }

  @override
  List<Object?> get props => [startTime, endTime, isAvailable, unavailabilityReason];

  @override
  String toString() {
    return 'TimeSlot(start: $startTime, end: $endTime, available: $isAvailable)';
  }
}