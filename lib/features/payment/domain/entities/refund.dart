import 'package:freezed_annotation/freezed_annotation.dart';

part 'refund.freezed.dart';

@freezed
class Refund with _$Refund {
  const factory Refund({
    required String id,
    required String paymentIntentId,
    required String bookingId,
    required int amount, // in øre
    required String currency,
    required RefundStatus status,
    required RefundReason reason,
    String? description,
    String? failureReason,
    DateTime? processedAt,
    required DateTime createdAt,
  }) = _Refund;
}

enum RefundStatus {
  pending,
  succeeded,
  failed,
  canceled,
  requiresAction,
}

enum RefundReason {
  duplicate,
  fraudulent,
  requestedByCustomer,
  chefCancellation,
  systemError,
  noShow,
  unsatisfactory,
}

extension RefundReasonExtension on RefundReason {
  String get displayName {
    switch (this) {
      case RefundReason.duplicate:
        return 'Duplicate Payment';
      case RefundReason.fraudulent:
        return 'Fraudulent';
      case RefundReason.requestedByCustomer:
        return 'Customer Request';
      case RefundReason.chefCancellation:
        return 'Chef Cancellation';
      case RefundReason.systemError:
        return 'System Error';
      case RefundReason.noShow:
        return 'No Show';
      case RefundReason.unsatisfactory:
        return 'Unsatisfactory Service';
    }
  }

  bool get isChargeable {
    return [
      RefundReason.duplicate,
      RefundReason.fraudulent,
      RefundReason.systemError,
      RefundReason.chefCancellation,
    ].contains(this);
  }
}

extension RefundStatusExtension on RefundStatus {
  String get displayName {
    switch (this) {
      case RefundStatus.pending:
        return 'Processing';
      case RefundStatus.succeeded:
        return 'Refunded';
      case RefundStatus.failed:
        return 'Failed';
      case RefundStatus.canceled:
        return 'Canceled';
      case RefundStatus.requiresAction:
        return 'Action Required';
    }
  }

  bool get isCompleted => [
    RefundStatus.succeeded,
    RefundStatus.failed,
    RefundStatus.canceled,
  ].contains(this);
}