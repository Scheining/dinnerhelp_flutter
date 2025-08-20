import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homechef/core/error/failures.dart';
import '../entities/dispute_case.dart';
import '../entities/refund.dart';
import '../repositories/payment_repository.dart';
import '../../data/repositories/payment_repository_impl.dart';
import 'package:homechef/features/notifications/domain/services/notification_service.dart';
import 'dispute_resolution_service.dart';

class DisputeResolutionServiceImpl implements DisputeResolutionService {
  final SupabaseClient _supabaseClient;
  final PaymentRepository _paymentRepository;
  final NotificationService _notificationService;

  // Investigation configuration
  static const Map<DisputeReason, List<String>> _standardQuestions = {
    DisputeReason.serviceNotProvided: [
      'Did the chef arrive at the scheduled time?',
      'Was any communication made about the cancellation?',
      'Were you able to provide the service on the agreed date?',
      'What prevented you from completing the service?',
    ],
    DisputeReason.serviceQualityPoor: [
      'Can you describe what happened during the service?',
      'Were there any specific issues mentioned by the customer?',
      'What steps did you take to address any concerns during service?',
      'Do you have any evidence of the service quality (photos, etc.)?',
    ],
    DisputeReason.chefNoShow: [
      'Did you receive and confirm the booking?',
      'What prevented you from arriving at the scheduled time?',
      'Did you attempt to contact the customer about any delays?',
      'When did you first realize you would not be able to attend?',
    ],
    DisputeReason.foodSafetyConcern: [
      'Do you have current food safety certifications?',
      'Can you describe your food preparation process for this booking?',
      'Were you aware of any food allergies or dietary restrictions?',
      'What safety protocols do you follow in customer kitchens?',
    ],
  };

  DisputeResolutionServiceImpl({
    required SupabaseClient supabaseClient,
    required PaymentRepository paymentRepository,
    required NotificationService notificationService,
  })  : _supabaseClient = supabaseClient,
        _paymentRepository = paymentRepository,
        _notificationService = notificationService;

  @override
  Future<Either<Failure, DisputeCase>> createDispute({
    required String bookingId,
    required DisputeReason reason,
    required String description,
    required String userId,
    List<DisputeEvidence> evidence = const [],
  }) async {
    try {
      // Get booking details
      final bookingResponse = await _supabaseClient
          .from('bookings')
          .select('*')
          .eq('id', bookingId)
          .single();

      final chefId = bookingResponse['chef_id'] as String;

      // Create dispute case
      final dispute = DisputeCase(
        id: _generateDisputeId(),
        bookingId: bookingId,
        userId: userId,
        chefId: chefId,
        reason: reason,
        description: description,
        status: DisputeStatus.submitted,
        priority: reason.defaultPriority,
        evidence: evidence,
        createdAt: DateTime.now(),
      );

      // Save to database
      await _saveDisputeToDatabase(dispute);

      // Auto-assign based on priority and workload
      final investigatorId = await _assignInvestigator(dispute);
      if (investigatorId != null) {
        await assignDispute(disputeId: dispute.id, investigatorId: investigatorId);
      }

      // Send notifications
      await _notifyDisputeCreated(dispute);

      // Update booking status
      await _supabaseClient
          .from('bookings')
          .update({'status': 'disputed'})
          .eq('id', bookingId);

      return Right(dispute);

    } catch (e) {
      return Left(DisputeCreationFailure('Failed to create dispute: $e'));
    }
  }

  @override
  Future<Either<Failure, DisputeInvestigationStep>> investigateWithChef({
    required String disputeId,
    required String investigatorId,
    required List<String> questions,
    Map<String, String> chefResponses = const {},
  }) async {
    try {
      final dispute = await _getDisputeById(disputeId);
      if (dispute == null) {
        return const Left(DisputeHandlingFailure('Dispute not found'));
      }

      // Create investigation step
      final step = DisputeInvestigationStep(
        id: _generateStepId(),
        action: InvestigationAction.chefInterview,
        description: 'Chef interview conducted with ${questions.length} questions',
        performedBy: investigatorId,
        performedAt: DateTime.now(),
        findings: {
          'questions': questions,
          'responses': chefResponses,
          'response_rate': chefResponses.length / questions.length,
        },
        notes: _generateInterviewNotes(questions, chefResponses),
      );

      // Save investigation step
      await _saveInvestigationStep(disputeId, step);

      // Update dispute status if needed
      await _updateDisputeStatus(disputeId, DisputeStatus.investigating);

      // Check if investigation is complete
      final isComplete = await _checkInvestigationComplete(disputeId);
      if (isComplete) {
        await _triggerResolutionProcess(disputeId);
      }

      return Right(step);

    } catch (e) {
      return Left(DisputeInvestigationFailure('Failed to conduct chef investigation: $e'));
    }
  }

  @override
  Future<Either<Failure, CompensationCalculation>> calculateCompensation({
    required String disputeId,
    required Map<String, dynamic> findings,
  }) async {
    try {
      final dispute = await _getDisputeById(disputeId);
      if (dispute == null) {
        return const Left(DisputeHandlingFailure('Dispute not found'));
      }

      final bookingAmount = await _getBookingAmount(dispute.bookingId);
      final factors = <CompensationFactor>[];
      int totalCompensation = 0;
      CompensationType type = CompensationType.noCompensation;
      String justification = '';

      // Analyze findings and calculate compensation
      switch (dispute.reason) {
        case DisputeReason.serviceNotProvided:
          type = CompensationType.fullRefund;
          totalCompensation = bookingAmount;
          justification = 'Service was not provided, customer entitled to full refund';
          factors.add(CompensationFactor(
            factor: 'Service not delivered',
            weight: 1.0,
            description: 'Complete failure to provide agreed service',
            impactAmount: bookingAmount,
          ));
          break;

        case DisputeReason.chefNoShow:
          type = CompensationType.fullRefund;
          totalCompensation = bookingAmount;
          // Add inconvenience compensation
          final inconvenienceAmount = (bookingAmount * 0.25).round();
          totalCompensation += inconvenienceAmount;
          justification = 'Chef no-show warrants full refund plus inconvenience compensation';
          factors.addAll([
            CompensationFactor(
              factor: 'No-show incident',
              weight: 1.0,
              description: 'Chef failed to attend scheduled booking',
              impactAmount: bookingAmount,
            ),
            CompensationFactor(
              factor: 'Customer inconvenience',
              weight: 0.25,
              description: 'Additional compensation for disruption',
              impactAmount: inconvenienceAmount,
            ),
          ]);
          break;

        case DisputeReason.serviceQualityPoor:
          final qualityScore = _assessQualityFromFindings(findings);
          if (qualityScore < 0.3) {
            type = CompensationType.fullRefund;
            totalCompensation = bookingAmount;
            justification = 'Service quality was significantly below standards';
          } else if (qualityScore < 0.6) {
            type = CompensationType.partialRefund;
            totalCompensation = (bookingAmount * 0.5).round();
            justification = 'Service quality issues warrant partial refund';
          } else {
            type = CompensationType.serviceCredit;
            totalCompensation = (bookingAmount * 0.2).round();
            justification = 'Minor quality issues addressed with service credit';
          }
          factors.add(CompensationFactor(
            factor: 'Service quality assessment',
            weight: qualityScore,
            description: 'Based on evidence and customer feedback',
            impactAmount: totalCompensation,
          ));
          break;

        case DisputeReason.foodSafetyConcern:
          type = CompensationType.fullRefund;
          totalCompensation = bookingAmount;
          // Add additional compensation for safety concern
          final safetyCompensation = (bookingAmount * 0.5).round();
          totalCompensation += safetyCompensation;
          justification = 'Food safety concerns require full refund and additional compensation';
          factors.addAll([
            CompensationFactor(
              factor: 'Food safety violation',
              weight: 1.0,
              description: 'Serious safety concerns identified',
              impactAmount: bookingAmount,
            ),
            CompensationFactor(
              factor: 'Health risk compensation',
              weight: 0.5,
              description: 'Additional compensation for potential health risks',
              impactAmount: safetyCompensation,
            ),
          ]);
          break;

        case DisputeReason.unprofessionalBehavior:
          final behaviorSeverity = _assessBehaviorSeverity(findings);
          if (behaviorSeverity > 0.7) {
            type = CompensationType.fullRefund;
            totalCompensation = bookingAmount;
            justification = 'Serious unprofessional behavior warrants full refund';
          } else {
            type = CompensationType.partialRefund;
            totalCompensation = (bookingAmount * behaviorSeverity).round();
            justification = 'Unprofessional behavior compensated proportionally';
          }
          factors.add(CompensationFactor(
            factor: 'Behavior assessment',
            weight: behaviorSeverity,
            description: 'Based on incident severity and impact',
            impactAmount: totalCompensation,
          ));
          break;

        default:
          type = CompensationType.goodwillGesture;
          totalCompensation = (bookingAmount * 0.1).round();
          justification = 'Goodwill gesture for customer experience';
          factors.add(CompensationFactor(
            factor: 'Goodwill gesture',
            weight: 0.1,
            description: 'Small compensation for inconvenience',
            impactAmount: totalCompensation,
          ));
          break;
      }

      // Calculate confidence score based on evidence quality
      final confidenceScore = _calculateConfidenceScore(dispute, findings);

      final calculation = CompensationCalculation(
        recommendedAmount: totalCompensation,
        type: type,
        justification: justification,
        factors: factors,
        confidenceScore: confidenceScore,
      );

      // Save calculation to dispute
      await _saveCompensationCalculation(disputeId, calculation);

      return Right(calculation);

    } catch (e) {
      return Left(CompensationCalculationFailure('Failed to calculate compensation: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> processPartialRefund({
    required String bookingId,
    required int amount,
    required String reason,
    required String processedBy,
  }) async {
    try {
      // Get payment information
      final bookingResponse = await _supabaseClient
          .from('bookings')
          .select('stripe_payment_intent_id, total_amount')
          .eq('id', bookingId)
          .single();

      final paymentIntentId = bookingResponse['stripe_payment_intent_id'] as String?;
      if (paymentIntentId == null) {
        return const Left(PaymentNotFoundFailure('No payment found for booking'));
      }

      // Process refund through payment service
      final refundResult = await _paymentRepository.refundPayment(
        bookingId: bookingId,
        amount: amount,
        reason: RefundReason.requestedByCustomer,
        description: reason,
      );

      if (refundResult.isLeft()) {
        return refundResult.fold((l) => Left(l), (r) => throw Exception());
      }

      // Update booking with refund information
      await _supabaseClient
          .from('bookings')
          .update({
            'refund_amount': amount,
            'refund_reason': reason,
            'refund_processed_by': processedBy,
            'refund_processed_at': DateTime.now().toIso8601String(),
            'payment_status': amount == bookingResponse['total_amount'] 
                ? 'refunded' 
                : 'partially_refunded',
          })
          .eq('id', bookingId);

      return const Right(unit);

    } catch (e) {
      return Left(RefundFailure('Failed to process partial refund: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateChefRating({
    required String chefId,
    required DisputeOutcome disputeOutcome,
  }) async {
    try {
      // Get current chef rating
      final chefResponse = await _supabaseClient
          .from('chefs')
          .select('average_rating, total_reviews, rating_breakdown')
          .eq('id', chefId)
          .single();

      double currentRating = (chefResponse['average_rating'] ?? 0.0).toDouble();
      int totalReviews = chefResponse['total_reviews'] ?? 0;
      Map<String, dynamic> ratingBreakdown = chefResponse['rating_breakdown'] ?? {};

      // Calculate rating impact based on dispute outcome
      double ratingImpact = 0.0;
      switch (disputeOutcome.type) {
        case DisputeOutcomeType.userRefund:
        case DisputeOutcomeType.partialRefund:
          ratingImpact = -0.5; // Moderate negative impact
          break;
        case DisputeOutcomeType.chefCompensation:
          ratingImpact = 0.0; // No impact if chef was right
          break;
        case DisputeOutcomeType.noAction:
          ratingImpact = 0.0; // No impact for unfounded disputes
          break;
        case DisputeOutcomeType.warningIssued:
          ratingImpact = -0.2; // Minor negative impact
          break;
        case DisputeOutcomeType.accountSuspension:
          ratingImpact = -1.0; // Major negative impact
          break;
        default:
          ratingImpact = -0.3; // Default moderate impact
          break;
      }

      // Only apply negative impact (disputes shouldn't improve ratings)
      if (ratingImpact < 0) {
        // Weighted average with dispute impact
        final newRating = ((currentRating * totalReviews) + ratingImpact) / (totalReviews + 1);
        
        await _supabaseClient
            .from('chefs')
            .update({
              'average_rating': newRating.clamp(1.0, 5.0),
              'dispute_count': 
                  (ratingBreakdown['disputes'] ?? 0) + 1,
              'last_rating_update': DateTime.now().toIso8601String(),
            })
            .eq('id', chefId);
      }

      // Record the rating change in chef history
      await _supabaseClient
          .from('chef_rating_history')
          .insert({
            'chef_id': chefId,
            'change_type': 'dispute_resolution',
            'rating_change': ratingImpact,
            'dispute_outcome': disputeOutcome.type.name,
            'created_at': DateTime.now().toIso8601String(),
          });

      return const Right(unit);

    } catch (e) {
      return Left(ServerFailure('Failed to update chef rating: $e'));
    }
  }

  @override
  Future<Either<Failure, DisputeReport>> generateDisputeReport({
    required String disputeId,
  }) async {
    try {
      final dispute = await _getDisputeById(disputeId);
      if (dispute == null) {
        return const Left(DisputeHandlingFailure('Dispute not found'));
      }

      // Get all investigation steps
      final investigationSteps = await _getInvestigationSteps(disputeId);

      // Get compensation calculation if available
      final compensationCalculation = await _getCompensationCalculation(disputeId);

      // Generate timeline
      final timeline = _generateTimeline(dispute, investigationSteps);

      // Generate key findings
      final keyFindings = _extractKeyFindings(dispute, investigationSteps);

      // Generate summary
      final summary = _generateSummary(dispute, keyFindings, compensationCalculation);

      // Generate recommendations
      final recommendations = _generateRecommendations(dispute, investigationSteps, compensationCalculation);

      final report = DisputeReport(
        disputeId: disputeId,
        generatedAt: DateTime.now(),
        dispute: dispute,
        timeline: timeline,
        investigationSteps: investigationSteps,
        compensationCalculation: compensationCalculation,
        keyFindings: keyFindings,
        summary: summary,
        recommendations: recommendations,
      );

      // Save report to database
      await _saveDisputeReport(report);

      return Right(report);

    } catch (e) {
      return Left(ServerFailure('Failed to generate dispute report: $e'));
    }
  }

  @override
  Future<Either<Failure, List<DisputeCase>>> getActiveDisputes({
    DisputeStatus? status,
    DisputePriority? priority,
    String? assignedTo,
  }) async {
    try {
      var query = _supabaseClient.from('disputes').select('*');

      if (status != null) {
        query = query.eq('status', status.name);
      }

      if (priority != null) {
        query = query.eq('priority', priority.name);
      }

      if (assignedTo != null) {
        query = query.eq('assigned_to', assignedTo);
      }

      final response = await query.order('created_at', ascending: false);

      final disputes = <DisputeCase>[];
      for (final data in response) {
        final dispute = await _convertDataToDispute(data);
        if (dispute != null) disputes.add(dispute);
      }

      return Right(disputes);

    } catch (e) {
      return const Left(ServerFailure('Failed to get active disputes'));
    }
  }

  @override
  Future<Either<Failure, Unit>> assignDispute({
    required String disputeId,
    required String investigatorId,
  }) async {
    try {
      await _supabaseClient
          .from('disputes')
          .update({
            'assigned_to': investigatorId,
            'status': DisputeStatus.underReview.name,
            'assigned_at': DateTime.now().toIso8601String(),
          })
          .eq('id', disputeId);

      // Notify investigator
      await _supabaseClient.from('notifications').insert({
        'user_id': investigatorId,
        'title': 'New Dispute Assignment',
        'message': 'You have been assigned a new dispute case',
        'type': 'dispute_assignment',
        'data': {'dispute_id': disputeId},
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });

      return const Right(unit);

    } catch (e) {
      return Left(ServerFailure('Failed to assign dispute: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> addEvidence({
    required String disputeId,
    required DisputeEvidence evidence,
  }) async {
    try {
      await _supabaseClient
          .from('dispute_evidence')
          .insert({
            'dispute_id': disputeId,
            'type': evidence.type.name,
            'title': evidence.title,
            'description': evidence.description,
            'file_url': evidence.fileUrl,
            'metadata': evidence.metadata,
            'submitted_by': evidence.submittedBy,
            'submitted_at': evidence.submittedAt.toIso8601String(),
          });

      return const Right(unit);

    } catch (e) {
      return Left(ServerFailure('Failed to add evidence: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> resolveDispute({
    required String disputeId,
    required DisputeOutcome outcome,
    required String resolvedBy,
  }) async {
    try {
      // Update dispute status
      await _supabaseClient
          .from('disputes')
          .update({
            'status': DisputeStatus.resolved.name,
            'resolved_by': resolvedBy,
            'resolved_at': DateTime.now().toIso8601String(),
            'outcome_type': outcome.type.name,
            'resolution': outcome.resolution,
          })
          .eq('id', disputeId);

      // Save outcome details
      await _supabaseClient
          .from('dispute_outcomes')
          .insert({
            'dispute_id': disputeId,
            'type': outcome.type.name,
            'resolution': outcome.resolution,
            'refund_amount': outcome.refundAmount,
            'compensation_amount': outcome.compensationAmount,
            'service_credit': outcome.serviceCredit,
            'actions': outcome.actions,
            'resolved_by': outcome.resolvedBy,
            'resolved_at': outcome.resolvedAt.toIso8601String(),
            'public_notes': outcome.publicNotes,
            'internal_notes': outcome.internalNotes,
          });

      // Process any financial outcomes
      if (outcome.hasRefund) {
        await processPartialRefund(
          bookingId: (await _getDisputeById(disputeId))!.bookingId,
          amount: outcome.refundAmount!,
          reason: outcome.resolution,
          processedBy: resolvedBy,
        );
      }

      // Update chef rating if applicable
      final dispute = await _getDisputeById(disputeId);
      if (dispute != null) {
        await updateChefRating(chefId: dispute.chefId, disputeOutcome: outcome);
      }

      // Send notifications
      await _notifyDisputeResolved(disputeId, outcome);

      return const Right(unit);

    } catch (e) {
      return Left(DisputeHandlingFailure('Failed to resolve dispute: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> escalateDispute({
    required String disputeId,
    required String reason,
    required String escalatedBy,
  }) async {
    try {
      await _supabaseClient
          .from('disputes')
          .update({
            'status': DisputeStatus.escalated.name,
            'escalated_by': escalatedBy,
            'escalated_at': DateTime.now().toIso8601String(),
            'escalation_reason': reason,
            'priority': DisputePriority.high.name,
          })
          .eq('id', disputeId);

      // Notify senior staff
      await _notifyDisputeEscalated(disputeId, reason);

      return const Right(unit);

    } catch (e) {
      return Left(DisputeHandlingFailure('Failed to escalate dispute: $e'));
    }
  }

  @override
  Future<Either<Failure, DisputeMetrics>> getDisputeMetrics({
    DateTime? startDate,
    DateTime? endDate,
    String? chefId,
  }) async {
    try {
      // This would implement comprehensive metrics calculation
      // Placeholder implementation
      return const Right(DisputeMetrics(
        totalDisputes: 0,
        openDisputes: 0,
        resolvedDisputes: 0,
        averageResolutionTime: 0,
        userSatisfactionScore: 0,
        chefSatisfactionScore: 0,
      ));

    } catch (e) {
      return Left(ServerFailure('Failed to calculate dispute metrics: $e'));
    }
  }

  // Private helper methods

  String _generateDisputeId() {
    return 'dispute_${DateTime.now().millisecondsSinceEpoch}';
  }

  String _generateStepId() {
    return 'step_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _saveDisputeToDatabase(DisputeCase dispute) async {
    await _supabaseClient.from('disputes').insert({
      'id': dispute.id,
      'booking_id': dispute.bookingId,
      'user_id': dispute.userId,
      'chef_id': dispute.chefId,
      'reason': dispute.reason.name,
      'description': dispute.description,
      'status': dispute.status.name,
      'priority': dispute.priority.name,
      'created_at': dispute.createdAt.toIso8601String(),
    });
  }

  Future<String?> _assignInvestigator(DisputeCase dispute) async {
    // This would implement automatic assignment based on workload and expertise
    return null; // Placeholder
  }

  Future<void> _notifyDisputeCreated(DisputeCase dispute) async {
    // Send notifications to relevant parties
    await _supabaseClient.from('notifications').insert({
      'user_id': dispute.userId,
      'title': 'Dispute Submitted',
      'message': 'Your dispute has been submitted and will be reviewed',
      'type': 'dispute_created',
      'data': {'dispute_id': dispute.id},
      'is_read': false,
      'created_at': DateTime.now().toIso8601String(),
    });

    await _supabaseClient.from('notifications').insert({
      'user_id': dispute.chefId,
      'title': 'Dispute Filed',
      'message': 'A dispute has been filed regarding your booking',
      'type': 'dispute_against_chef',
      'data': {'dispute_id': dispute.id},
      'is_read': false,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<DisputeCase?> _getDisputeById(String disputeId) async {
    try {
      final response = await _supabaseClient
          .from('disputes')
          .select('*')
          .eq('id', disputeId)
          .single();

      return await _convertDataToDispute(response);
    } catch (e) {
      return null;
    }
  }

  Future<DisputeCase?> _convertDataToDispute(Map<String, dynamic> data) async {
    // Convert database data to DisputeCase object
    // Implementation would depend on exact database schema
    return null; // Placeholder
  }

  Future<void> _saveInvestigationStep(String disputeId, DisputeInvestigationStep step) async {
    await _supabaseClient.from('dispute_investigation_steps').insert({
      'dispute_id': disputeId,
      'id': step.id,
      'action': step.action.name,
      'description': step.description,
      'performed_by': step.performedBy,
      'performed_at': step.performedAt.toIso8601String(),
      'findings': step.findings,
      'notes': step.notes,
    });
  }

  Future<void> _updateDisputeStatus(String disputeId, DisputeStatus status) async {
    await _supabaseClient
        .from('disputes')
        .update({
          'status': status.name,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', disputeId);
  }

  Future<bool> _checkInvestigationComplete(String disputeId) async {
    // Check if all required investigation steps are complete
    return false; // Placeholder
  }

  Future<void> _triggerResolutionProcess(String disputeId) async {
    // Automatically trigger resolution calculation when investigation is complete
  }

  String _generateInterviewNotes(List<String> questions, Map<String, String> responses) {
    final notes = StringBuffer();
    notes.writeln('Chef Interview Summary:');
    notes.writeln('Questions Asked: ${questions.length}');
    notes.writeln('Responses Received: ${responses.length}');
    notes.writeln('Response Rate: ${(responses.length / questions.length * 100).toStringAsFixed(1)}%');
    
    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];
      final response = responses[question] ?? 'No response';
      notes.writeln('Q${i + 1}: $question');
      notes.writeln('A${i + 1}: $response');
      notes.writeln('');
    }
    
    return notes.toString();
  }

  Future<int> _getBookingAmount(String bookingId) async {
    final response = await _supabaseClient
        .from('bookings')
        .select('total_amount')
        .eq('id', bookingId)
        .single();

    return (response['total_amount'] as num).toInt();
  }

  double _assessQualityFromFindings(Map<String, dynamic> findings) {
    // Analyze findings to assess service quality
    // This would be a complex algorithm considering various factors
    return 0.5; // Placeholder
  }

  double _assessBehaviorSeverity(Map<String, dynamic> findings) {
    // Assess severity of unprofessional behavior
    return 0.3; // Placeholder
  }

  double _calculateConfidenceScore(DisputeCase dispute, Map<String, dynamic> findings) {
    // Calculate confidence based on evidence quality and completeness
    double score = 0.5; // Base score
    
    if (dispute.evidence.isNotEmpty) score += 0.2;
    if (findings.isNotEmpty) score += 0.2;
    if (dispute.investigationSteps.isNotEmpty) score += 0.1;
    
    return score.clamp(0.0, 1.0);
  }

  Future<void> _saveCompensationCalculation(String disputeId, CompensationCalculation calculation) async {
    await _supabaseClient.from('dispute_compensation_calculations').insert({
      'dispute_id': disputeId,
      'recommended_amount': calculation.recommendedAmount,
      'type': calculation.type.name,
      'justification': calculation.justification,
      'confidence_score': calculation.confidenceScore,
      'factors': calculation.factors.map((f) => {
        'factor': f.factor,
        'weight': f.weight,
        'description': f.description,
        'impact_amount': f.impactAmount,
      }).toList(),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<DisputeInvestigationStep>> _getInvestigationSteps(String disputeId) async {
    // Get all investigation steps for a dispute
    return []; // Placeholder
  }

  Future<CompensationCalculation?> _getCompensationCalculation(String disputeId) async {
    // Get compensation calculation for a dispute
    return null; // Placeholder
  }

  DisputeTimeline _generateTimeline(DisputeCase dispute, List<DisputeInvestigationStep> steps) {
    return DisputeTimeline(
      disputeCreated: dispute.createdAt,
      investigationStarted: steps.isNotEmpty ? steps.first.performedAt : null,
      disputeResolved: dispute.resolvedAt,
      totalResolutionTime: dispute.resolvedAt?.difference(dispute.createdAt),
    );
  }

  List<String> _extractKeyFindings(DisputeCase dispute, List<DisputeInvestigationStep> steps) {
    // Extract key findings from investigation steps
    return []; // Placeholder
  }

  String _generateSummary(DisputeCase dispute, List<String> keyFindings, CompensationCalculation? calculation) {
    // Generate executive summary of the dispute
    return 'Dispute summary placeholder'; // Placeholder
  }

  List<String> _generateRecommendations(DisputeCase dispute, List<DisputeInvestigationStep> steps, CompensationCalculation? calculation) {
    // Generate recommendations based on investigation
    return []; // Placeholder
  }

  Future<void> _saveDisputeReport(DisputeReport report) async {
    await _supabaseClient.from('dispute_reports').insert({
      'dispute_id': report.disputeId,
      'generated_at': report.generatedAt.toIso8601String(),
      'key_findings': report.keyFindings,
      'summary': report.summary,
      'recommendations': report.recommendations,
    });
  }

  Future<void> _notifyDisputeResolved(String disputeId, DisputeOutcome outcome) async {
    // Send notifications about dispute resolution
  }

  Future<void> _notifyDisputeEscalated(String disputeId, String reason) async {
    // Send notifications about dispute escalation
  }
}