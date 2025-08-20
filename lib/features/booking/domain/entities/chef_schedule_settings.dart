import 'package:equatable/equatable.dart';

class ChefScheduleSettings extends Equatable {
  final String chefId;
  final int bufferTimeMinutes; // Buffer time between bookings in minutes
  final int maxBookingsPerDay; // Maximum bookings allowed per day
  final int minNoticeHours; // Minimum notice required in hours
  final bool allowSameDayBooking; // Whether same-day booking is allowed
  final bool autoAcceptBookings; // Whether to auto-accept bookings
  final int maxAdvanceBookingDays; // Maximum days in advance for booking (default 180 = 6 months)

  const ChefScheduleSettings({
    required this.chefId,
    this.bufferTimeMinutes = 60, // Default 1 hour buffer
    this.maxBookingsPerDay = 2, // Default max 2 bookings per day
    this.minNoticeHours = 24, // Default 24 hours notice
    this.allowSameDayBooking = false,
    this.autoAcceptBookings = false,
    this.maxAdvanceBookingDays = 180, // Default 6 months
  });

  Duration get bufferTime => Duration(minutes: bufferTimeMinutes);
  Duration get minNotice => Duration(hours: minNoticeHours);
  Duration get maxAdvanceBooking => Duration(days: maxAdvanceBookingDays);

  bool canBookOnDate(DateTime bookingDate, DateTime now) {
    final difference = bookingDate.difference(now);
    
    // Check if booking is too far in advance
    if (difference > maxAdvanceBooking) {
      return false;
    }
    
    // Check minimum notice requirement
    if (difference < minNotice) {
      return false;
    }
    
    // Check same-day booking policy
    if (!allowSameDayBooking && isSameDay(bookingDate, now)) {
      return false;
    }
    
    return true;
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  DateTime getEarliestBookingDate(DateTime now) {
    if (allowSameDayBooking) {
      return now.add(minNotice);
    } else {
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      final withMinNotice = now.add(minNotice);
      return withMinNotice.isAfter(tomorrow) ? withMinNotice : tomorrow;
    }
  }

  DateTime getLatestBookingDate(DateTime now) {
    return now.add(maxAdvanceBooking);
  }

  @override
  List<Object?> get props => [
    chefId,
    bufferTimeMinutes,
    maxBookingsPerDay,
    minNoticeHours,
    allowSameDayBooking,
    autoAcceptBookings,
    maxAdvanceBookingDays,
  ];

  @override
  String toString() {
    return 'ChefScheduleSettings(chef: $chefId, buffer: ${bufferTimeMinutes}min, maxBookings: $maxBookingsPerDay/day, minNotice: ${minNoticeHours}h)';
  }
}