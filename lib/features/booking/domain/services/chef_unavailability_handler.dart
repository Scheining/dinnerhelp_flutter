import 'package:dartz/dartz.dart';
import 'package:homechef/core/error/failures.dart';
import '../entities/chef_alternative.dart';
import '../entities/booking_request.dart';
import 'package:homechef/models/chef.dart';
import 'package:homechef/models/booking.dart';

abstract class ChefUnavailabilityHandler {
  /// Handle chef unavailability after booking confirmation
  Future<Either<Failure, UnavailabilityResolution>> handleChefUnavailability({
    required String bookingId,
    required UnavailabilityReason reason,
  });

  /// Find alternative chefs for a booking
  Future<Either<Failure, List<ChefAlternative>>> findAlternativeChefs({
    required BookingRequest originalBooking,
    required double maxDistanceKm,
    int maxAlternatives = 5,
  });

  /// Suggest rescheduling options with the same chef
  Future<Either<Failure, List<ReschedulingOption>>> suggestRescheduling({
    required String bookingId,
    required List<DateTime> preferredDates,
  });

  /// Notify affected parties about the resolution
  Future<Either<Failure, Unit>> notifyAffectedParties({
    required String bookingId,
    required UnavailabilityResolution solution,
  });

  /// Process emergency cancellation
  Future<Either<Failure, EmergencyCancellationResult>> processEmergencyCancellation({
    required String bookingId,
    required UnavailabilityReason reason,
  });
}

class UnavailabilityResolution {
  final String bookingId;
  final ResolutionType type;
  final String? alternativeChefId;
  final DateTime? newDateTime;
  final String? newTimeSlot;
  final int? refundAmount; // in øre
  final int? compensationAmount; // in øre
  final String description;
  final bool requiresUserApproval;
  final DateTime resolvedAt;

  const UnavailabilityResolution({
    required this.bookingId,
    required this.type,
    this.alternativeChefId,
    this.newDateTime,
    this.newTimeSlot,
    this.refundAmount,
    this.compensationAmount,
    required this.description,
    this.requiresUserApproval = false,
    required this.resolvedAt,
  });
}

enum ResolutionType {
  alternativeChef,
  reschedule,
  fullRefund,
  partialRefundWithCredit,
  emergency,
}

class ReschedulingOption {
  final DateTime dateTime;
  final String timeSlot;
  final bool isAvailable;
  final double probabilityScore; // 0.0 to 1.0
  final String? notes;
  final int? priceDifference; // in øre

  const ReschedulingOption({
    required this.dateTime,
    required this.timeSlot,
    required this.isAvailable,
    required this.probabilityScore,
    this.notes,
    this.priceDifference,
  });
}

class EmergencyCancellationResult {
  final String bookingId;
  final bool cancelled;
  final int refundAmount; // in øre
  final int compensationAmount; // in øre
  final String reason;
  final List<String> actionsNotified; // List of parties notified
  final DateTime processedAt;

  const EmergencyCancellationResult({
    required this.bookingId,
    required this.cancelled,
    required this.refundAmount,
    required this.compensationAmount,
    required this.reason,
    required this.actionsNotified,
    required this.processedAt,
  });
}