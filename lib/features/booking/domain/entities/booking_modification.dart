import 'package:equatable/equatable.dart';

class BookingModificationRequest extends Equatable {
  final String bookingId;
  final String requestedBy; // userId
  final DateTime requestedAt;
  final List<BookingChange> changes;
  final String? reason;
  final bool isEmergencyRequest;
  final ModificationStatus status;
  final String? rejectionReason;
  final DateTime? respondedAt;
  final String? respondedBy;

  const BookingModificationRequest({
    required this.bookingId,
    required this.requestedBy,
    required this.requestedAt,
    required this.changes,
    this.reason,
    this.isEmergencyRequest = false,
    this.status = ModificationStatus.pending,
    this.rejectionReason,
    this.respondedAt,
    this.respondedBy,
  });

  bool get isPending => status == ModificationStatus.pending;
  bool get isApproved => status == ModificationStatus.approved;
  bool get isRejected => status == ModificationStatus.rejected;
  bool get hasTimeChange => changes.any((c) => c.type == ChangeType.dateTime);
  bool get hasGuestCountChange => changes.any((c) => c.type == ChangeType.guestCount);
  bool get hasDishesChange => changes.any((c) => c.type == ChangeType.dishes);

  BookingModificationRequest copyWith({
    ModificationStatus? status,
    String? rejectionReason,
    DateTime? respondedAt,
    String? respondedBy,
  }) {
    return BookingModificationRequest(
      bookingId: bookingId,
      requestedBy: requestedBy,
      requestedAt: requestedAt,
      changes: changes,
      reason: reason,
      isEmergencyRequest: isEmergencyRequest,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      respondedAt: respondedAt ?? this.respondedAt,
      respondedBy: respondedBy ?? this.respondedBy,
    );
  }

  @override
  List<Object?> get props => [
    bookingId,
    requestedBy,
    requestedAt,
    changes,
    reason,
    isEmergencyRequest,
    status,
    rejectionReason,
    respondedAt,
    respondedBy,
  ];
}

class BookingChange extends Equatable {
  final ChangeType type;
  final String fieldName;
  final dynamic oldValue;
  final dynamic newValue;
  final String description;
  final PriceImpact? priceImpact;

  const BookingChange({
    required this.type,
    required this.fieldName,
    required this.oldValue,
    required this.newValue,
    required this.description,
    this.priceImpact,
  });

  bool get hasAdditionalCost => priceImpact?.additionalCost != null && priceImpact!.additionalCost! > 0;
  bool get hasRefund => priceImpact?.refundAmount != null && priceImpact!.refundAmount! > 0;

  @override
  List<Object?> get props => [
    type,
    fieldName,
    oldValue,
    newValue,
    description,
    priceImpact,
  ];
}

enum ChangeType {
  dateTime,
  guestCount,
  dishes,
  specialRequests,
  address,
}

enum ModificationStatus {
  pending,
  approved,
  rejected,
  expired,
}

class PriceImpact extends Equatable {
  final int? additionalCost; // in øre
  final int? refundAmount; // in øre
  final String explanation;
  final List<PriceBreakdown> breakdown;

  const PriceImpact({
    this.additionalCost,
    this.refundAmount,
    required this.explanation,
    this.breakdown = const [],
  });

  int get netChange {
    final additional = additionalCost ?? 0;
    final refund = refundAmount ?? 0;
    return additional - refund;
  }

  bool get hasNetIncrease => netChange > 0;
  bool get hasNetDecrease => netChange < 0;
  bool get isNeutral => netChange == 0;

  @override
  List<Object?> get props => [additionalCost, refundAmount, explanation, breakdown];
}

class PriceBreakdown extends Equatable {
  final String item;
  final int amount; // in øre
  final String description;

  const PriceBreakdown({
    required this.item,
    required this.amount,
    required this.description,
  });

  @override
  List<Object> get props => [item, amount, description];
}

class ModificationValidationResult extends Equatable {
  final bool isValid;
  final List<String> violations;
  final ModificationDeadlineInfo deadlineInfo;
  final List<String> warnings;

  const ModificationValidationResult({
    required this.isValid,
    this.violations = const [],
    required this.deadlineInfo,
    this.warnings = const [],
  });

  bool get hasViolations => violations.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;
  bool get isWithinDeadline => deadlineInfo.isWithinDeadline;

  @override
  List<Object> get props => [isValid, violations, deadlineInfo, warnings];
}

class ModificationDeadlineInfo extends Equatable {
  final DateTime bookingDateTime;
  final DateTime modificationDeadline;
  final DateTime requestTime;
  final Duration timeUntilDeadline;
  final bool isWithinDeadline;
  final bool isEmergencyOverride;

  const ModificationDeadlineInfo({
    required this.bookingDateTime,
    required this.modificationDeadline,
    required this.requestTime,
    required this.timeUntilDeadline,
    required this.isWithinDeadline,
    this.isEmergencyOverride = false,
  });

  String get deadlineStatus {
    if (isEmergencyOverride) return 'Emergency Override';
    if (isWithinDeadline) return 'Within Deadline';
    return 'Past Deadline';
  }

  @override
  List<Object> get props => [
    bookingDateTime,
    modificationDeadline,
    requestTime,
    timeUntilDeadline,
    isWithinDeadline,
    isEmergencyOverride,
  ];
}