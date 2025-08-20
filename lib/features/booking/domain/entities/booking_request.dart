import 'package:equatable/equatable.dart';
import 'recurrence_pattern.dart';

class BookingRequest extends Equatable {
  final String userId;
  final String chefId;
  final DateTime date;
  final String startTime; // Format: "HH:MM"
  final String endTime; // Format: "HH:MM"
  final int numberOfGuests;
  final String? specialRequests;
  final String? menuId;
  final RecurrencePattern? recurrencePattern; // null for single booking

  const BookingRequest({
    required this.userId,
    required this.chefId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.numberOfGuests,
    this.specialRequests,
    this.menuId,
    this.recurrencePattern,
  });

  bool get isRecurring => recurrencePattern != null;
  bool get isSingleBooking => recurrencePattern == null;

  DateTime getStartDateTime() {
    final parts = startTime.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  DateTime getEndDateTime() {
    final parts = endTime.split(':');
    var endDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );

    // If end time is before start time, it goes to next day
    final startDateTime = getStartDateTime();
    if (endDateTime.isBefore(startDateTime)) {
      endDateTime = endDateTime.add(const Duration(days: 1));
    }

    return endDateTime;
  }

  Duration get duration => getEndDateTime().difference(getStartDateTime());

  List<DateTime> getBookingDates() {
    if (isSingleBooking) {
      return [date];
    }

    return recurrencePattern!.generateOccurrences(
      until: DateTime.now().add(const Duration(days: 180)), // Max 6 months
    );
  }

  List<BookingRequest> expandRecurringBookings() {
    if (isSingleBooking) {
      return [this];
    }

    final dates = getBookingDates();
    return dates.map((bookingDate) => BookingRequest(
      userId: userId,
      chefId: chefId,
      date: bookingDate,
      startTime: startTime,
      endTime: endTime,
      numberOfGuests: numberOfGuests,
      specialRequests: specialRequests,
      menuId: menuId,
      // Individual bookings don't have recurrence pattern
    )).toList();
  }

  @override
  List<Object?> get props => [
    userId,
    chefId,
    date,
    startTime,
    endTime,
    numberOfGuests,
    specialRequests,
    menuId,
    recurrencePattern,
  ];

  @override
  String toString() {
    final dateStr = date.toIso8601String().split('T')[0];
    final recurring = isRecurring ? ' (recurring: ${recurrencePattern!.type.name})' : '';
    return 'BookingRequest(chef: $chefId, date: $dateStr, time: $startTime-$endTime, guests: $numberOfGuests$recurring)';
  }
}