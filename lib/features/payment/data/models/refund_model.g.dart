// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refund_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RefundModelImpl _$$RefundModelImplFromJson(Map<String, dynamic> json) =>
    _$RefundModelImpl(
      id: json['id'] as String,
      paymentIntentId: json['payment_intent_id'] as String,
      bookingId: json['booking_id'] as String,
      amount: (json['amount'] as num).toInt(),
      currency: json['currency'] as String,
      statusString: json['status'] as String,
      reasonString: json['reason'] as String,
      description: json['description'] as String?,
      failureReason: json['failure_reason'] as String?,
      processedAt: json['processed_at'] == null
          ? null
          : DateTime.parse(json['processed_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$RefundModelImplToJson(_$RefundModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'payment_intent_id': instance.paymentIntentId,
      'booking_id': instance.bookingId,
      'amount': instance.amount,
      'currency': instance.currency,
      'status': instance.statusString,
      'reason': instance.reasonString,
      'description': instance.description,
      'failure_reason': instance.failureReason,
      'processed_at': instance.processedAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
    };
