// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationEntityImpl _$$NotificationEntityImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationEntityImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      bookingId: json['bookingId'] as String?,
      chefId: json['chefId'] as String?,
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      channel: $enumDecode(_$NotificationChannelEnumMap, json['channel']),
      status:
          $enumDecodeNullable(_$NotificationStatusEnumMap, json['status']) ??
              NotificationStatus.pending,
      title: json['title'] as String,
      content: json['content'] as String,
      data: json['data'] as Map<String, dynamic>? ?? const {},
      templateId: json['templateId'] as String?,
      scheduledAt: json['scheduledAt'] == null
          ? null
          : DateTime.parse(json['scheduledAt'] as String),
      sentAt: json['sentAt'] == null
          ? null
          : DateTime.parse(json['sentAt'] as String),
      deliveredAt: json['deliveredAt'] == null
          ? null
          : DateTime.parse(json['deliveredAt'] as String),
      failedAt: json['failedAt'] == null
          ? null
          : DateTime.parse(json['failedAt'] as String),
      failureReason: json['failureReason'] as String?,
      retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
      maxRetries: (json['maxRetries'] as num?)?.toInt() ?? 3,
      externalId: json['externalId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$NotificationEntityImplToJson(
        _$NotificationEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'bookingId': instance.bookingId,
      'chefId': instance.chefId,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'channel': _$NotificationChannelEnumMap[instance.channel]!,
      'status': _$NotificationStatusEnumMap[instance.status]!,
      'title': instance.title,
      'content': instance.content,
      'data': instance.data,
      'templateId': instance.templateId,
      'scheduledAt': instance.scheduledAt?.toIso8601String(),
      'sentAt': instance.sentAt?.toIso8601String(),
      'deliveredAt': instance.deliveredAt?.toIso8601String(),
      'failedAt': instance.failedAt?.toIso8601String(),
      'failureReason': instance.failureReason,
      'retryCount': instance.retryCount,
      'maxRetries': instance.maxRetries,
      'externalId': instance.externalId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$NotificationTypeEnumMap = {
  NotificationType.bookingConfirmation: 'bookingConfirmation',
  NotificationType.bookingReminder24h: 'bookingReminder24h',
  NotificationType.bookingReminder1h: 'bookingReminder1h',
  NotificationType.bookingCompletion: 'bookingCompletion',
  NotificationType.bookingModified: 'bookingModified',
  NotificationType.bookingCancelled: 'bookingCancelled',
  NotificationType.recurringBookingCreated: 'recurringBookingCreated',
  NotificationType.chefMessage: 'chefMessage',
  NotificationType.paymentSuccess: 'paymentSuccess',
  NotificationType.paymentFailed: 'paymentFailed',
};

const _$NotificationChannelEnumMap = {
  NotificationChannel.email: 'email',
  NotificationChannel.push: 'push',
  NotificationChannel.inApp: 'inApp',
  NotificationChannel.sms: 'sms',
};

const _$NotificationStatusEnumMap = {
  NotificationStatus.pending: 'pending',
  NotificationStatus.processing: 'processing',
  NotificationStatus.sent: 'sent',
  NotificationStatus.delivered: 'delivered',
  NotificationStatus.failed: 'failed',
  NotificationStatus.cancelled: 'cancelled',
};

_$NotificationPreferencesImpl _$$NotificationPreferencesImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationPreferencesImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      emailEnabled: json['emailEnabled'] as bool? ?? true,
      pushEnabled: json['pushEnabled'] as bool? ?? true,
      inAppEnabled: json['inAppEnabled'] as bool? ?? true,
      smsEnabled: json['smsEnabled'] as bool? ?? false,
      bookingConfirmations: json['bookingConfirmations'] as bool? ?? true,
      bookingReminders: json['bookingReminders'] as bool? ?? true,
      bookingUpdates: json['bookingUpdates'] as bool? ?? true,
      marketingEmails: json['marketingEmails'] as bool? ?? false,
      languagePreference: json['languagePreference'] as String? ?? 'da',
      timezone: json['timezone'] as String? ?? 'Europe/Copenhagen',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$NotificationPreferencesImplToJson(
        _$NotificationPreferencesImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'emailEnabled': instance.emailEnabled,
      'pushEnabled': instance.pushEnabled,
      'inAppEnabled': instance.inAppEnabled,
      'smsEnabled': instance.smsEnabled,
      'bookingConfirmations': instance.bookingConfirmations,
      'bookingReminders': instance.bookingReminders,
      'bookingUpdates': instance.bookingUpdates,
      'marketingEmails': instance.marketingEmails,
      'languagePreference': instance.languagePreference,
      'timezone': instance.timezone,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$DeviceTokenImpl _$$DeviceTokenImplFromJson(Map<String, dynamic> json) =>
    _$DeviceTokenImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      token: json['token'] as String,
      platform: json['platform'] as String,
      appVersion: json['appVersion'] as String?,
      deviceId: json['deviceId'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      lastUsedAt: DateTime.parse(json['lastUsedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$DeviceTokenImplToJson(_$DeviceTokenImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'token': instance.token,
      'platform': instance.platform,
      'appVersion': instance.appVersion,
      'deviceId': instance.deviceId,
      'isActive': instance.isActive,
      'lastUsedAt': instance.lastUsedAt.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

_$EmailTemplateImpl _$$EmailTemplateImplFromJson(Map<String, dynamic> json) =>
    _$EmailTemplateImpl(
      id: json['id'] as String,
      templateKey: json['templateKey'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      subjectDa: json['subjectDa'] as String,
      subjectEn: json['subjectEn'] as String,
      htmlContentDa: json['htmlContentDa'] as String,
      htmlContentEn: json['htmlContentEn'] as String,
      textContentDa: json['textContentDa'] as String?,
      textContentEn: json['textContentEn'] as String?,
      variables: (json['variables'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$EmailTemplateImplToJson(_$EmailTemplateImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'templateKey': instance.templateKey,
      'name': instance.name,
      'description': instance.description,
      'subjectDa': instance.subjectDa,
      'subjectEn': instance.subjectEn,
      'htmlContentDa': instance.htmlContentDa,
      'htmlContentEn': instance.htmlContentEn,
      'textContentDa': instance.textContentDa,
      'textContentEn': instance.textContentEn,
      'variables': instance.variables,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$NotificationRequestImpl _$$NotificationRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationRequestImpl(
      userId: json['userId'] as String,
      bookingId: json['bookingId'] as String?,
      chefId: json['chefId'] as String?,
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      channel: $enumDecode(_$NotificationChannelEnumMap, json['channel']),
      title: json['title'] as String,
      content: json['content'] as String,
      data: json['data'] as Map<String, dynamic>? ?? const {},
      templateId: json['templateId'] as String?,
      scheduledAt: json['scheduledAt'] == null
          ? null
          : DateTime.parse(json['scheduledAt'] as String),
    );

Map<String, dynamic> _$$NotificationRequestImplToJson(
        _$NotificationRequestImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'bookingId': instance.bookingId,
      'chefId': instance.chefId,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'channel': _$NotificationChannelEnumMap[instance.channel]!,
      'title': instance.title,
      'content': instance.content,
      'data': instance.data,
      'templateId': instance.templateId,
      'scheduledAt': instance.scheduledAt?.toIso8601String(),
    };
