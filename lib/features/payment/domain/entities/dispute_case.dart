import 'package:equatable/equatable.dart';

class DisputeCase extends Equatable {
  final String id;
  final String bookingId;
  final String userId;
  final String chefId;
  final DisputeReason reason;
  final String description;
  final DisputeStatus status;
  final DisputePriority priority;
  final List<DisputeEvidence> evidence;
  final List<DisputeInvestigationStep> investigationSteps;
  final DisputeOutcome? outcome;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;
  final String? assignedTo; // Admin user ID

  const DisputeCase({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.chefId,
    required this.reason,
    required this.description,
    required this.status,
    required this.priority,
    this.evidence = const [],
    this.investigationSteps = const [],
    this.outcome,
    required this.createdAt,
    this.updatedAt,
    this.resolvedAt,
    this.assignedTo,
  });

  bool get isOpen => !status.isClosed;
  bool get isResolved => status.isResolved;
  bool get requiresAction => status.requiresAction;
  bool get isHighPriority => priority == DisputePriority.high;
  bool get hasEvidence => evidence.isNotEmpty;
  Duration? get timeToResolve => resolvedAt?.difference(createdAt);

  @override
  List<Object?> get props => [
    id,
    bookingId,
    userId,
    chefId,
    reason,
    description,
    status,
    priority,
    evidence,
    investigationSteps,
    outcome,
    createdAt,
    updatedAt,
    resolvedAt,
    assignedTo,
  ];
}

enum DisputeReason {
  serviceNotProvided,
  serviceQualityPoor,
  chefNoShow,
  foodSafetyConcern,
  unprofessionalBehavior,
  propertyDamage,
  wrongOrder,
  priceDispute,
  paymentIssue,
  communicationIssue,
  other,
}

enum DisputeStatus {
  submitted,
  underReview,
  pendingInformation,
  investigating,
  resolved,
  closed,
  escalated,
}

enum DisputePriority {
  low,
  medium,
  high,
  critical,
}

enum DisputeOutcomeType {
  userRefund,
  partialRefund,
  chefCompensation,
  noAction,
  warningIssued,
  accountSuspension,
  serviceCredit,
  rescheduling,
}

class DisputeEvidence extends Equatable {
  final String id;
  final EvidenceType type;
  final String title;
  final String? description;
  final String? fileUrl;
  final Map<String, dynamic>? metadata;
  final DateTime submittedAt;
  final String submittedBy; // User ID

  const DisputeEvidence({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    this.fileUrl,
    this.metadata,
    required this.submittedAt,
    required this.submittedBy,
  });

  @override
  List<Object?> get props => [
    id,
    type,
    title,
    description,
    fileUrl,
    metadata,
    submittedAt,
    submittedBy,
  ];
}

enum EvidenceType {
  photo,
  video,
  document,
  chatMessage,
  receipt,
  witness,
  other,
}

class DisputeInvestigationStep extends Equatable {
  final String id;
  final InvestigationAction action;
  final String description;
  final String performedBy;
  final DateTime performedAt;
  final Map<String, dynamic>? findings;
  final String? notes;

  const DisputeInvestigationStep({
    required this.id,
    required this.action,
    required this.description,
    required this.performedBy,
    required this.performedAt,
    this.findings,
    this.notes,
  });

  @override
  List<Object?> get props => [
    id,
    action,
    description,
    performedBy,
    performedAt,
    findings,
    notes,
  ];
}

enum InvestigationAction {
  evidenceReview,
  userInterview,
  chefInterview,
  siteVisit,
  documentVerification,
  paymentVerification,
  policyCheck,
  finalReview,
}

class DisputeOutcome extends Equatable {
  final DisputeOutcomeType type;
  final String resolution;
  final int? refundAmount; // in øre
  final int? compensationAmount; // in øre
  final String? serviceCredit;
  final List<String> actions; // Actions taken
  final String resolvedBy;
  final DateTime resolvedAt;
  final String? publicNotes; // Notes visible to user/chef
  final String? internalNotes; // Internal admin notes

  const DisputeOutcome({
    required this.type,
    required this.resolution,
    this.refundAmount,
    this.compensationAmount,
    this.serviceCredit,
    this.actions = const [],
    required this.resolvedBy,
    required this.resolvedAt,
    this.publicNotes,
    this.internalNotes,
  });

  bool get hasRefund => refundAmount != null && refundAmount! > 0;
  bool get hasCompensation => compensationAmount != null && compensationAmount! > 0;
  bool get hasServiceCredit => serviceCredit != null;

  @override
  List<Object?> get props => [
    type,
    resolution,
    refundAmount,
    compensationAmount,
    serviceCredit,
    actions,
    resolvedBy,
    resolvedAt,
    publicNotes,
    internalNotes,
  ];
}

class DisputeMetrics extends Equatable {
  final int totalDisputes;
  final int openDisputes;
  final int resolvedDisputes;
  final double averageResolutionTime; // in hours
  final Map<DisputeReason, int> disputesByReason;
  final Map<DisputeOutcomeType, int> outcomesByType;
  final double userSatisfactionScore;
  final double chefSatisfactionScore;

  const DisputeMetrics({
    required this.totalDisputes,
    required this.openDisputes,
    required this.resolvedDisputes,
    required this.averageResolutionTime,
    this.disputesByReason = const {},
    this.outcomesByType = const {},
    required this.userSatisfactionScore,
    required this.chefSatisfactionScore,
  });

  double get resolutionRate => totalDisputes > 0 ? resolvedDisputes / totalDisputes : 0;

  @override
  List<Object> get props => [
    totalDisputes,
    openDisputes,
    resolvedDisputes,
    averageResolutionTime,
    disputesByReason,
    outcomesByType,
    userSatisfactionScore,
    chefSatisfactionScore,
  ];
}

extension DisputeStatusExtension on DisputeStatus {
  bool get isClosed => [
    DisputeStatus.resolved,
    DisputeStatus.closed,
  ].contains(this);

  bool get isResolved => this == DisputeStatus.resolved;

  bool get requiresAction => [
    DisputeStatus.submitted,
    DisputeStatus.pendingInformation,
    DisputeStatus.escalated,
  ].contains(this);

  String get displayName {
    switch (this) {
      case DisputeStatus.submitted:
        return 'Submitted';
      case DisputeStatus.underReview:
        return 'Under Review';
      case DisputeStatus.pendingInformation:
        return 'Pending Information';
      case DisputeStatus.investigating:
        return 'Investigating';
      case DisputeStatus.resolved:
        return 'Resolved';
      case DisputeStatus.closed:
        return 'Closed';
      case DisputeStatus.escalated:
        return 'Escalated';
    }
  }
}

extension DisputeReasonExtension on DisputeReason {
  String get displayName {
    switch (this) {
      case DisputeReason.serviceNotProvided:
        return 'Service Not Provided';
      case DisputeReason.serviceQualityPoor:
        return 'Poor Service Quality';
      case DisputeReason.chefNoShow:
        return 'Chef No-Show';
      case DisputeReason.foodSafetyConcern:
        return 'Food Safety Concern';
      case DisputeReason.unprofessionalBehavior:
        return 'Unprofessional Behavior';
      case DisputeReason.propertyDamage:
        return 'Property Damage';
      case DisputeReason.wrongOrder:
        return 'Wrong Order';
      case DisputeReason.priceDispute:
        return 'Price Dispute';
      case DisputeReason.paymentIssue:
        return 'Payment Issue';
      case DisputeReason.communicationIssue:
        return 'Communication Issue';
      case DisputeReason.other:
        return 'Other';
    }
  }

  DisputePriority get defaultPriority {
    switch (this) {
      case DisputeReason.foodSafetyConcern:
      case DisputeReason.propertyDamage:
      case DisputeReason.chefNoShow:
        return DisputePriority.high;
      case DisputeReason.serviceQualityPoor:
      case DisputeReason.unprofessionalBehavior:
      case DisputeReason.serviceNotProvided:
        return DisputePriority.medium;
      default:
        return DisputePriority.low;
    }
  }
}

extension DisputePriorityExtension on DisputePriority {
  String get displayName {
    switch (this) {
      case DisputePriority.low:
        return 'Low';
      case DisputePriority.medium:
        return 'Medium';
      case DisputePriority.high:
        return 'High';
      case DisputePriority.critical:
        return 'Critical';
    }
  }

  Duration get maxResolutionTime {
    switch (this) {
      case DisputePriority.critical:
        return const Duration(hours: 4);
      case DisputePriority.high:
        return const Duration(hours: 24);
      case DisputePriority.medium:
        return const Duration(days: 3);
      case DisputePriority.low:
        return const Duration(days: 7);
    }
  }
}