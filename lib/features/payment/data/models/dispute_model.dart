import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/dispute.dart';

part 'dispute_model.freezed.dart';
part 'dispute_model.g.dart';

@freezed
class DisputeModel with _$DisputeModel {
  const factory DisputeModel({
    required String id,
    @JsonKey(name: 'payment_intent_id') required String paymentIntentId,
    @JsonKey(name: 'booking_id') required String bookingId,
    required int amount,
    required String currency,
    @JsonKey(name: 'status') required String statusString,
    @JsonKey(name: 'reason') required String reasonString,
    String? description,
    @JsonKey(name: 'evidence_details') String? evidenceDetails,
    @JsonKey(name: 'respond_by_date') DateTime? respondByDate,
    @JsonKey(name: 'resolved_at') DateTime? resolvedAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _DisputeModel;

  factory DisputeModel.fromJson(Map<String, dynamic> json) =>
      _$DisputeModelFromJson(json);

  const DisputeModel._();

  Dispute toDomain() {
    return Dispute(
      id: id,
      paymentIntentId: paymentIntentId,
      bookingId: bookingId,
      amount: amount,
      currency: currency,
      status: _parseStatus(statusString),
      reason: _parseReason(reasonString),
      description: description,
      evidenceDetails: evidenceDetails,
      respondByDate: respondByDate,
      resolvedAt: resolvedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  DisputeStatus _parseStatus(String status) {
    switch (status) {
      case 'needs_response':
        return DisputeStatus.needsResponse;
      case 'under_review':
        return DisputeStatus.underReview;
      case 'charge_refunded':
        return DisputeStatus.chargeRefunded;
      case 'lost':
        return DisputeStatus.lost;
      case 'won':
        return DisputeStatus.won;
      case 'accepted':
        return DisputeStatus.accepted;
      default:
        return DisputeStatus.needsResponse;
    }
  }

  DisputeReason _parseReason(String reason) {
    switch (reason) {
      case 'duplicate':
        return DisputeReason.duplicate;
      case 'fraudulent':
        return DisputeReason.fraudulent;
      case 'subscription_canceled':
        return DisputeReason.subscriptionCanceled;
      case 'product_unacceptable':
        return DisputeReason.productUnacceptable;
      case 'product_not_received':
        return DisputeReason.productNotReceived;
      case 'unrecognized':
        return DisputeReason.unrecognized;
      case 'credit_not_processed':
        return DisputeReason.creditNotProcessed;
      case 'general':
        return DisputeReason.general;
      case 'incorrect_account_details':
        return DisputeReason.incorrectAccountDetails;
      case 'insufficient_funds':
        return DisputeReason.insufficientFunds;
      case 'bank_cannot_process':
        return DisputeReason.bankCannotProcess;
      case 'debit_not_authorized':
        return DisputeReason.debitNotAuthorized;
      case 'customer_initiated':
        return DisputeReason.customerInitiated;
      default:
        return DisputeReason.general;
    }
  }
}