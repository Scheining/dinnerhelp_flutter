// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dispute_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DisputeModelImpl _$$DisputeModelImplFromJson(Map<String, dynamic> json) =>
    _$DisputeModelImpl(
      id: json['id'] as String,
      paymentIntentId: json['payment_intent_id'] as String,
      bookingId: json['booking_id'] as String,
      amount: (json['amount'] as num).toInt(),
      currency: json['currency'] as String,
      statusString: json['status'] as String,
      reasonString: json['reason'] as String,
      description: json['description'] as String?,
      evidenceDetails: json['evidence_details'] as String?,
      respondByDate: json['respond_by_date'] == null
          ? null
          : DateTime.parse(json['respond_by_date'] as String),
      resolvedAt: json['resolved_at'] == null
          ? null
          : DateTime.parse(json['resolved_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$DisputeModelImplToJson(_$DisputeModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'payment_intent_id': instance.paymentIntentId,
      'booking_id': instance.bookingId,
      'amount': instance.amount,
      'currency': instance.currency,
      'status': instance.statusString,
      'reason': instance.reasonString,
      'description': instance.description,
      'evidence_details': instance.evidenceDetails,
      'respond_by_date': instance.respondByDate?.toIso8601String(),
      'resolved_at': instance.resolvedAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
