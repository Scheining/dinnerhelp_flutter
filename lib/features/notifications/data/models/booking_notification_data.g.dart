// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_notification_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BookingNotificationDataImpl _$$BookingNotificationDataImplFromJson(
        Map<String, dynamic> json) =>
    _$BookingNotificationDataImpl(
      bookingId: json['bookingId'] as String,
      userId: json['userId'] as String,
      chefId: json['chefId'] as String,
      chefName: json['chefName'] as String,
      userName: json['userName'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      guestCount: (json['guestCount'] as num).toInt(),
      address: json['address'] as String,
      durationHours: (json['durationHours'] as num).toInt(),
      userEmail: json['userEmail'] as String?,
      userPhone: json['userPhone'] as String?,
      chefEmail: json['chefEmail'] as String?,
      chefPhone: json['chefPhone'] as String?,
      notes: json['notes'] as String?,
      totalAmount: (json['totalAmount'] as num?)?.toDouble(),
      paymentStatus: json['paymentStatus'] as String?,
      dishNames: (json['dishNames'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$BookingNotificationDataImplToJson(
        _$BookingNotificationDataImpl instance) =>
    <String, dynamic>{
      'bookingId': instance.bookingId,
      'userId': instance.userId,
      'chefId': instance.chefId,
      'chefName': instance.chefName,
      'userName': instance.userName,
      'dateTime': instance.dateTime.toIso8601String(),
      'guestCount': instance.guestCount,
      'address': instance.address,
      'durationHours': instance.durationHours,
      'userEmail': instance.userEmail,
      'userPhone': instance.userPhone,
      'chefEmail': instance.chefEmail,
      'chefPhone': instance.chefPhone,
      'notes': instance.notes,
      'totalAmount': instance.totalAmount,
      'paymentStatus': instance.paymentStatus,
      'dishNames': instance.dishNames,
      'additionalData': instance.additionalData,
    };

_$NotificationTemplateImpl _$$NotificationTemplateImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationTemplateImpl(
      key: json['key'] as String,
      nameDa: json['nameDa'] as String,
      nameEn: json['nameEn'] as String,
      subjectDa: json['subjectDa'] as String,
      subjectEn: json['subjectEn'] as String,
      contentDa: json['contentDa'] as String,
      contentEn: json['contentEn'] as String,
      htmlContentDa: json['htmlContentDa'] as String?,
      htmlContentEn: json['htmlContentEn'] as String?,
      requiredVariables: (json['requiredVariables'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      defaultValues: (json['defaultValues'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
    );

Map<String, dynamic> _$$NotificationTemplateImplToJson(
        _$NotificationTemplateImpl instance) =>
    <String, dynamic>{
      'key': instance.key,
      'nameDa': instance.nameDa,
      'nameEn': instance.nameEn,
      'subjectDa': instance.subjectDa,
      'subjectEn': instance.subjectEn,
      'contentDa': instance.contentDa,
      'contentEn': instance.contentEn,
      'htmlContentDa': instance.htmlContentDa,
      'htmlContentEn': instance.htmlContentEn,
      'requiredVariables': instance.requiredVariables,
      'defaultValues': instance.defaultValues,
    };
