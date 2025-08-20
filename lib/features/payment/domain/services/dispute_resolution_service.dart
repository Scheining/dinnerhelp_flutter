import 'package:dartz/dartz.dart';
import 'package:homechef/core/error/failures.dart';
import '../entities/dispute_case.dart';

abstract class DisputeResolutionService {
  /// Create a new dispute case
  Future<Either<Failure, DisputeCase>> createDispute({
    required String bookingId,
    required DisputeReason reason,
    required String description,
    required String userId,
    List<DisputeEvidence> evidence = const [],
  });

  /// Investigate dispute with chef interview
  Future<Either<Failure, DisputeInvestigationStep>> investigateWithChef({
    required String disputeId,
    required String investigatorId,
    required List<String> questions,
    Map<String, String> chefResponses = const {},
  });

  /// Calculate compensation based on dispute findings
  Future<Either<Failure, CompensationCalculation>> calculateCompensation({
    required String disputeId,
    required Map<String, dynamic> findings,
  });

  /// Process partial refund for a dispute
  Future<Either<Failure, Unit>> processPartialRefund({
    required String bookingId,
    required int amount, // in øre
    required String reason,
    required String processedBy,
  });

  /// Update chef rating based on dispute outcome
  Future<Either<Failure, Unit>> updateChefRating({
    required String chefId,
    required DisputeOutcome disputeOutcome,
  });

  /// Generate comprehensive dispute report
  Future<Either<Failure, DisputeReport>> generateDisputeReport({
    required String disputeId,
  });

  /// Get all active disputes for admin dashboard
  Future<Either<Failure, List<DisputeCase>>> getActiveDisputes({
    DisputeStatus? status,
    DisputePriority? priority,
    String? assignedTo,
  });

  /// Assign dispute to an investigator
  Future<Either<Failure, Unit>> assignDispute({
    required String disputeId,
    required String investigatorId,
  });

  /// Add evidence to existing dispute
  Future<Either<Failure, Unit>> addEvidence({
    required String disputeId,
    required DisputeEvidence evidence,
  });

  /// Resolve dispute with final outcome
  Future<Either<Failure, Unit>> resolveDispute({
    required String disputeId,
    required DisputeOutcome outcome,
    required String resolvedBy,
  });

  /// Escalate dispute to higher authority
  Future<Either<Failure, Unit>> escalateDispute({
    required String disputeId,
    required String reason,
    required String escalatedBy,
  });

  /// Get dispute metrics for analytics
  Future<Either<Failure, DisputeMetrics>> getDisputeMetrics({
    DateTime? startDate,
    DateTime? endDate,
    String? chefId,
  });
}

class CompensationCalculation {
  final int recommendedAmount; // in øre
  final CompensationType type;
  final String justification;
  final List<CompensationFactor> factors;
  final double confidenceScore; // 0.0 to 1.0

  const CompensationCalculation({
    required this.recommendedAmount,
    required this.type,
    required this.justification,
    required this.factors,
    required this.confidenceScore,
  });
}

enum CompensationType {
  noCompensation,
  partialRefund,
  fullRefund,
  serviceCredit,
  goodwillGesture,
  punitiveDamages,
}

class CompensationFactor {
  final String factor;
  final double weight; // 0.0 to 1.0
  final String description;
  final int impactAmount; // in øre

  const CompensationFactor({
    required this.factor,
    required this.weight,
    required this.description,
    required this.impactAmount,
  });
}

class DisputeReport {
  final String disputeId;
  final DateTime generatedAt;
  final DisputeCase dispute;
  final DisputeTimeline timeline;
  final List<DisputeInvestigationStep> investigationSteps;
  final CompensationCalculation? compensationCalculation;
  final List<String> keyFindings;
  final String summary;
  final List<String> recommendations;

  const DisputeReport({
    required this.disputeId,
    required this.generatedAt,
    required this.dispute,
    required this.timeline,
    required this.investigationSteps,
    this.compensationCalculation,
    required this.keyFindings,
    required this.summary,
    required this.recommendations,
  });
}

class DisputeTimeline {
  final DateTime disputeCreated;
  final DateTime? investigationStarted;
  final DateTime? evidenceGatheringCompleted;
  final DateTime? partyInterviewsCompleted;
  final DateTime? resolutionProposed;
  final DateTime? disputeResolved;
  final Duration? totalResolutionTime;

  const DisputeTimeline({
    required this.disputeCreated,
    this.investigationStarted,
    this.evidenceGatheringCompleted,
    this.partyInterviewsCompleted,
    this.resolutionProposed,
    this.disputeResolved,
    this.totalResolutionTime,
  });

  bool get isOverdue {
    if (disputeResolved != null) return false;
    
    final now = DateTime.now();
    final daysSinceCreated = now.difference(disputeCreated).inDays;
    
    return daysSinceCreated > 7; // Standard 7-day resolution target
  }
}