import 'package:equatable/equatable.dart';
import '../repositories/recurring_booking_repository.dart';

class BookingOccurrence extends Equatable {
  final String id;
  final String userId;
  final String chefId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final int numberOfGuests;
  final String? specialRequests;
  final String? menuId;
  final String? seriesId;
  final String bookingId;
  final DateTime createdAt;
  final BookingOccurrenceStatus status;
  final String? cancellationReason;
  final String? paymentStatus;
  final String? stripePaymentIntentId;

  const BookingOccurrence({
    required this.id,
    required this.userId,
    required this.chefId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.numberOfGuests,
    this.specialRequests,
    this.menuId,
    this.seriesId,
    required this.bookingId,
    required this.createdAt,
    required this.status,
    this.cancellationReason,
    this.paymentStatus,
    this.stripePaymentIntentId,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        chefId,
        date,
        startTime,
        endTime,
        numberOfGuests,
        specialRequests,
        menuId,
        seriesId,
        bookingId,
        createdAt,
        status,
        cancellationReason,
        paymentStatus,
        stripePaymentIntentId,
      ];
}