import 'package:dartz/dartz.dart';
import 'package:homechef/core/error/failures.dart';
import '../entities/booking_modification.dart';

abstract class BookingModificationService {
  /// Validate modification request against business rules
  Future<Either<Failure, ModificationValidationResult>> validateModificationRequest({
    required String bookingId,
    required List<BookingChange> changes,
    required DateTime requestTime,
  });

  /// Process date/time change for a booking
  Future<Either<Failure, BookingModificationRequest>> processDateTimeChange({
    required String bookingId,
    required DateTime newDateTime,
    required String? newTimeSlot,
    required String requestedBy,
    String? reason,
  });

  /// Process dish/menu changes for a booking
  Future<Either<Failure, BookingModificationRequest>> processDishesChange({
    required String bookingId,
    required List<String> newDishIds,
    required String requestedBy,
    String? reason,
  });

  /// Process guest count change for a booking
  Future<Either<Failure, BookingModificationRequest>> processGuestCountChange({
    required String bookingId,
    required int newGuestCount,
    required String requestedBy,
    String? reason,
  });

  /// Calculate the 24-hour deadline for modifications
  DateTime calculate24HourDeadline(DateTime bookingDateTime);

  /// Handle late modification requests (past 24-hour deadline)
  Future<Either<Failure, LateModificationResult>> handleLateModificationRequest({
    required String bookingId,
    required List<BookingChange> changes,
    required String requestedBy,
    String? emergencyReason,
  });

  /// Approve or reject a modification request (for chefs/admins)
  Future<Either<Failure, Unit>> respondToModificationRequest({
    required String requestId,
    required bool approved,
    required String respondedBy,
    String? rejectionReason,
  });

  /// Get all pending modification requests for a user/chef
  Future<Either<Failure, List<BookingModificationRequest>>> getPendingModifications({
    required String userId,
    bool isChef = false,
  });

  /// Calculate price impact of modifications
  Future<Either<Failure, PriceImpact>> calculatePriceImpact({
    required String bookingId,
    required List<BookingChange> changes,
  });

  /// Process approved modification request
  Future<Either<Failure, ModificationProcessResult>> processApprovedModification({
    required String requestId,
  });

  /// Cancel modification request
  Future<Either<Failure, Unit>> cancelModificationRequest({
    required String requestId,
    required String cancelledBy,
    String? reason,
  });
}

class LateModificationResult {
  final bool allowed;
  final String reason;
  final int additionalFee; // in øre
  final List<String> conditions;
  final bool requiresChefApproval;
  final bool requiresAdminApproval;

  const LateModificationResult({
    required this.allowed,
    required this.reason,
    this.additionalFee = 0,
    this.conditions = const [],
    this.requiresChefApproval = true,
    this.requiresAdminApproval = false,
  });
}

class ModificationProcessResult {
  final String requestId;
  final String bookingId;
  final bool success;
  final List<String> processedChanges;
  final PriceImpact? priceImpact;
  final String? paymentIntentId; // If additional payment required
  final String? refundId; // If refund processed
  final DateTime processedAt;
  final String? errorMessage;

  const ModificationProcessResult({
    required this.requestId,
    required this.bookingId,
    required this.success,
    this.processedChanges = const [],
    this.priceImpact,
    this.paymentIntentId,
    this.refundId,
    required this.processedAt,
    this.errorMessage,
  });

  bool get hasAdditionalPayment => paymentIntentId != null;
  bool get hasRefund => refundId != null;
}