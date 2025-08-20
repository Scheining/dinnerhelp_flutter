import 'package:freezed_annotation/freezed_annotation.dart';

part 'dispute.freezed.dart';

@freezed
class Dispute with _$Dispute {
  const factory Dispute({
    required String id,
    required String paymentIntentId,
    required String bookingId,
    required int amount, // in øre
    required String currency,
    required DisputeStatus status,
    required DisputeReason reason,
    String? description,
    String? evidenceDetails,
    DateTime? respondByDate,
    DateTime? resolvedAt,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Dispute;
}

enum DisputeStatus {
  needsResponse,
  underReview,
  chargeRefunded,
  lost,
  won,
  accepted,
}

enum DisputeReason {
  duplicate,
  fraudulent,
  subscriptionCanceled,
  productUnacceptable,
  productNotReceived,
  unrecognized,
  creditNotProcessed,
  general,
  incorrectAccountDetails,
  insufficientFunds,
  bankCannotProcess,
  debitNotAuthorized,
  customerInitiated,
}

extension DisputeStatusExtension on DisputeStatus {
  String get displayName {
    switch (this) {
      case DisputeStatus.needsResponse:
        return 'Needs Response';
      case DisputeStatus.underReview:
        return 'Under Review';
      case DisputeStatus.chargeRefunded:
        return 'Refunded';
      case DisputeStatus.lost:
        return 'Lost';
      case DisputeStatus.won:
        return 'Won';
      case DisputeStatus.accepted:
        return 'Accepted';
    }
  }

  bool get requiresAction => [
    DisputeStatus.needsResponse,
  ].contains(this);

  bool get isResolved => [
    DisputeStatus.chargeRefunded,
    DisputeStatus.lost,
    DisputeStatus.won,
    DisputeStatus.accepted,
  ].contains(this);
}

extension DisputeReasonExtension on DisputeReason {
  String get displayName {
    switch (this) {
      case DisputeReason.duplicate:
        return 'Duplicate Charge';
      case DisputeReason.fraudulent:
        return 'Fraudulent';
      case DisputeReason.subscriptionCanceled:
        return 'Subscription Canceled';
      case DisputeReason.productUnacceptable:
        return 'Service Unacceptable';
      case DisputeReason.productNotReceived:
        return 'Service Not Received';
      case DisputeReason.unrecognized:
        return 'Unrecognized Charge';
      case DisputeReason.creditNotProcessed:
        return 'Credit Not Processed';
      case DisputeReason.general:
        return 'General Inquiry';
      case DisputeReason.incorrectAccountDetails:
        return 'Incorrect Account Details';
      case DisputeReason.insufficientFunds:
        return 'Insufficient Funds';
      case DisputeReason.bankCannotProcess:
        return 'Bank Cannot Process';
      case DisputeReason.debitNotAuthorized:
        return 'Debit Not Authorized';
      case DisputeReason.customerInitiated:
        return 'Customer Initiated';
    }
  }
}