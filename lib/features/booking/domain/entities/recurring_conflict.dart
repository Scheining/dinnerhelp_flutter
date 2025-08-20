import 'package:equatable/equatable.dart';
import 'chef_time_off.dart';

class RecurringBookingConflict extends Equatable {
  final String seriesId;
  final String chefId;
  final String userId;
  final List<ConflictOccurrence> conflictedOccurrences;
  final ConflictCause cause;
  final DateTime detectedAt;
  final ConflictResolutionStatus status;
  final List<ResolutionOption> availableOptions;
  final String? selectedResolution;
  final DateTime? resolvedAt;

  const RecurringBookingConflict({
    required this.seriesId,
    required this.chefId,
    required this.userId,
    required this.conflictedOccurrences,
    required this.cause,
    required this.detectedAt,
    this.status = ConflictResolutionStatus.pending,
    this.availableOptions = const [],
    this.selectedResolution,
    this.resolvedAt,
  });

  int get affectedBookingsCount => conflictedOccurrences.length;
  bool get hasMultipleConflicts => affectedBookingsCount > 1;
  bool get isResolved => status == ConflictResolutionStatus.resolved;
  bool get requiresUserDecision => status == ConflictResolutionStatus.awaitingUserDecision;

  Duration get conflictDuration {
    if (conflictedOccurrences.isEmpty) return Duration.zero;
    
    final dates = conflictedOccurrences.map((o) => o.bookingDate).toList();
    dates.sort();
    
    return dates.last.difference(dates.first);
  }

  @override
  List<Object?> get props => [
    seriesId,
    chefId,
    userId,
    conflictedOccurrences,
    cause,
    detectedAt,
    status,
    availableOptions,
    selectedResolution,
    resolvedAt,
  ];
}

class ConflictOccurrence extends Equatable {
  final String bookingId;
  final DateTime bookingDate;
  final String timeSlot; // e.g., "18:00-21:00"
  final ConflictType conflictType;
  final String conflictDescription;
  final DateTime? originalCreatedAt;

  const ConflictOccurrence({
    required this.bookingId,
    required this.bookingDate,
    required this.timeSlot,
    required this.conflictType,
    required this.conflictDescription,
    this.originalCreatedAt,
  });

  bool get isFutureBooking => bookingDate.isAfter(DateTime.now());
  bool get isUpcoming => bookingDate.difference(DateTime.now()).inDays <= 7;

  @override
  List<Object?> get props => [
    bookingId,
    bookingDate,
    timeSlot,
    conflictType,
    conflictDescription,
    originalCreatedAt,
  ];
}

enum ConflictType {
  timeOff,
  doubleBooking,
  unavailableHours,
  holidayRestriction,
  maintenanceWindow,
  personalUnavailability,
}

enum ConflictCause {
  chefTimeOff,
  chefScheduleChange,
  holidayScheduleUpdate,
  emergencyUnavailability,
  systemMaintenance,
  doubleBookingDetected,
}

enum ConflictResolutionStatus {
  pending,
  awaitingUserDecision,
  awaitingChefDecision,
  resolved,
  cancelled,
  disputed,
}

class ResolutionOption extends Equatable {
  final String id;
  final ResolutionType type;
  final String title;
  final String description;
  final Map<String, dynamic> parameters;
  final ResolutionImpact impact;
  final bool requiresPaymentAdjustment;
  final bool requiresUserApproval;
  final bool requiresChefApproval;

  const ResolutionOption({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.parameters = const {},
    required this.impact,
    this.requiresPaymentAdjustment = false,
    this.requiresUserApproval = false,
    this.requiresChefApproval = false,
  });

  @override
  List<Object> get props => [
    id,
    type,
    title,
    description,
    parameters,
    impact,
    requiresPaymentAdjustment,
    requiresUserApproval,
    requiresChefApproval,
  ];
}

enum ResolutionType {
  cancel,
  reschedule,
  findAlternativeChef,
  splitSeries,
  pauseSeries,
  endSeries,
  skipConflicted,
}

class ResolutionImpact extends Equatable {
  final int affectedBookings;
  final int cancelledBookings;
  final int rescheduledBookings;
  final int? refundAmount; // in øre
  final int? additionalCost; // in øre
  final List<String> consequenceDescription;
  final UserImpactLevel userImpactLevel;
  final ChefImpactLevel chefImpactLevel;

  const ResolutionImpact({
    required this.affectedBookings,
    this.cancelledBookings = 0,
    this.rescheduledBookings = 0,
    this.refundAmount,
    this.additionalCost,
    this.consequenceDescription = const [],
    required this.userImpactLevel,
    required this.chefImpactLevel,
  });

  bool get hasFinancialImpact => refundAmount != null || additionalCost != null;
  bool get isHighImpact => userImpactLevel == UserImpactLevel.high || chefImpactLevel == ChefImpactLevel.high;

  @override
  List<Object?> get props => [
    affectedBookings,
    cancelledBookings,
    rescheduledBookings,
    refundAmount,
    additionalCost,
    consequenceDescription,
    userImpactLevel,
    chefImpactLevel,
  ];
}

enum UserImpactLevel {
  low,    // Minor inconvenience, easy to resolve
  medium, // Some disruption, requires decision
  high,   // Major disruption, significant impact
}

enum ChefImpactLevel {
  low,    // Little to no impact on chef
  medium, // Some schedule adjustments needed
  high,   // Major schedule changes required
}

class ConflictResolutionResult extends Equatable {
  final String conflictId;
  final ResolutionType resolutionType;
  final bool success;
  final List<String> processedBookings;
  final List<String> cancelledBookings;
  final List<RescheduledBookingInfo> rescheduledBookings;
  final int? totalRefund; // in øre
  final int? totalAdditionalCost; // in øre
  final String? errorMessage;
  final DateTime resolvedAt;

  const ConflictResolutionResult({
    required this.conflictId,
    required this.resolutionType,
    required this.success,
    this.processedBookings = const [],
    this.cancelledBookings = const [],
    this.rescheduledBookings = const [],
    this.totalRefund,
    this.totalAdditionalCost,
    this.errorMessage,
    required this.resolvedAt,
  });

  bool get hasRefunds => totalRefund != null && totalRefund! > 0;
  bool get hasAdditionalCosts => totalAdditionalCost != null && totalAdditionalCost! > 0;

  @override
  List<Object?> get props => [
    conflictId,
    resolutionType,
    success,
    processedBookings,
    cancelledBookings,
    rescheduledBookings,
    totalRefund,
    totalAdditionalCost,
    errorMessage,
    resolvedAt,
  ];
}

class RescheduledBookingInfo extends Equatable {
  final String originalBookingId;
  final DateTime originalDate;
  final DateTime newDate;
  final String? newTimeSlot;
  final String? alternativeChefId;
  final int? priceDifference; // in øre

  const RescheduledBookingInfo({
    required this.originalBookingId,
    required this.originalDate,
    required this.newDate,
    this.newTimeSlot,
    this.alternativeChefId,
    this.priceDifference,
  });

  bool get hasChefChange => alternativeChefId != null;
  bool get hasPriceChange => priceDifference != null && priceDifference != 0;

  @override
  List<Object?> get props => [
    originalBookingId,
    originalDate,
    newDate,
    newTimeSlot,
    alternativeChefId,
    priceDifference,
  ];
}