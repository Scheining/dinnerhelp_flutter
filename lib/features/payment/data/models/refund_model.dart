import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/refund.dart';

part 'refund_model.freezed.dart';
part 'refund_model.g.dart';

@freezed
class RefundModel with _$RefundModel {
  const factory RefundModel({
    required String id,
    @JsonKey(name: 'payment_intent_id') required String paymentIntentId,
    @JsonKey(name: 'booking_id') required String bookingId,
    required int amount,
    required String currency,
    @JsonKey(name: 'status') required String statusString,
    @JsonKey(name: 'reason') required String reasonString,
    String? description,
    @JsonKey(name: 'failure_reason') String? failureReason,
    @JsonKey(name: 'processed_at') DateTime? processedAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _RefundModel;

  factory RefundModel.fromJson(Map<String, dynamic> json) =>
      _$RefundModelFromJson(json);

  const RefundModel._();

  Refund toDomain() {
    return Refund(
      id: id,
      paymentIntentId: paymentIntentId,
      bookingId: bookingId,
      amount: amount,
      currency: currency,
      status: _parseStatus(statusString),
      reason: _parseReason(reasonString),
      description: description,
      failureReason: failureReason,
      processedAt: processedAt,
      createdAt: createdAt,
    );
  }

  RefundStatus _parseStatus(String status) {
    switch (status) {
      case 'pending':
        return RefundStatus.pending;
      case 'succeeded':
        return RefundStatus.succeeded;
      case 'failed':
        return RefundStatus.failed;
      case 'canceled':
        return RefundStatus.canceled;
      case 'requires_action':
        return RefundStatus.requiresAction;
      default:
        return RefundStatus.pending;
    }
  }

  RefundReason _parseReason(String reason) {
    switch (reason) {
      case 'duplicate':
        return RefundReason.duplicate;
      case 'fraudulent':
        return RefundReason.fraudulent;
      case 'requested_by_customer':
        return RefundReason.requestedByCustomer;
      case 'chef_cancellation':
        return RefundReason.chefCancellation;
      case 'system_error':
        return RefundReason.systemError;
      case 'no_show':
        return RefundReason.noShow;
      case 'unsatisfactory':
        return RefundReason.unsatisfactory;
      default:
        return RefundReason.requestedByCustomer;
    }
  }
}