// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_method_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentMethodModelImpl _$$PaymentMethodModelImplFromJson(
        Map<String, dynamic> json) =>
    _$PaymentMethodModelImpl(
      id: json['stripe_payment_method_id'] as String,
      typeString: json['type'] as String,
      last4: json['last4'] as String,
      brand: json['brand'] as String,
      expMonth: (json['exp_month'] as num).toInt(),
      expYear: (json['exp_year'] as num).toInt(),
      holderName: json['holder_name'] as String?,
      isDefault: json['is_default'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$PaymentMethodModelImplToJson(
        _$PaymentMethodModelImpl instance) =>
    <String, dynamic>{
      'stripe_payment_method_id': instance.id,
      'type': instance.typeString,
      'last4': instance.last4,
      'brand': instance.brand,
      'exp_month': instance.expMonth,
      'exp_year': instance.expYear,
      'holder_name': instance.holderName,
      'is_default': instance.isDefault,
      'created_at': instance.createdAt.toIso8601String(),
    };
