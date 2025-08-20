import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/notification.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

@freezed
class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    required String id,
    required String userId,
    String? bookingId,
    String? chefId,
    required String type,
    required String channel,
    @Default('pending') String status,
    required String title,
    required String content,
    @Default({}) Map<String, dynamic> data,
    String? templateId,
    DateTime? scheduledAt,
    DateTime? sentAt,
    DateTime? deliveredAt,
    DateTime? failedAt,
    String? failureReason,
    @Default(0) int retryCount,
    @Default(3) int maxRetries,
    String? externalId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
}

extension NotificationModelExtension on NotificationModel {
  NotificationEntity toDomain() {
    return NotificationEntity(
      id: id,
      userId: userId,
      bookingId: bookingId,
      chefId: chefId,
      type: NotificationType.values.firstWhere((e) => e.name == type),
      channel: NotificationChannel.values.firstWhere((e) => e.name == channel),
      status: NotificationStatus.values.firstWhere((e) => e.name == status),
      title: title,
      content: content,
      data: data,
      templateId: templateId,
      scheduledAt: scheduledAt,
      sentAt: sentAt,
      deliveredAt: deliveredAt,
      failedAt: failedAt,
      failureReason: failureReason,
      retryCount: retryCount,
      maxRetries: maxRetries,
      externalId: externalId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static NotificationModel fromDomain(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      userId: entity.userId,
      bookingId: entity.bookingId,
      chefId: entity.chefId,
      type: entity.type.name,
      channel: entity.channel.name,
      status: entity.status.name,
      title: entity.title,
      content: entity.content,
      data: entity.data,
      templateId: entity.templateId,
      scheduledAt: entity.scheduledAt,
      sentAt: entity.sentAt,
      deliveredAt: entity.deliveredAt,
      failedAt: entity.failedAt,
      failureReason: entity.failureReason,
      retryCount: entity.retryCount,
      maxRetries: entity.maxRetries,
      externalId: entity.externalId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

@freezed
class NotificationPreferencesModel with _$NotificationPreferencesModel {
  const factory NotificationPreferencesModel({
    required String id,
    required String userId,
    @Default(true) bool emailEnabled,
    @Default(true) bool pushEnabled,
    @Default(true) bool inAppEnabled,
    @Default(false) bool smsEnabled,
    @Default(true) bool bookingConfirmations,
    @Default(true) bool bookingReminders,
    @Default(true) bool bookingUpdates,
    @Default(false) bool marketingEmails,
    @Default('da') String languagePreference,
    @Default('Europe/Copenhagen') String timezone,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _NotificationPreferencesModel;

  factory NotificationPreferencesModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesModelFromJson(json);
}

extension NotificationPreferencesModelExtension on NotificationPreferencesModel {
  NotificationPreferences toDomain() {
    return NotificationPreferences(
      id: id,
      userId: userId,
      emailEnabled: emailEnabled,
      pushEnabled: pushEnabled,
      inAppEnabled: inAppEnabled,
      smsEnabled: smsEnabled,
      bookingConfirmations: bookingConfirmations,
      bookingReminders: bookingReminders,
      bookingUpdates: bookingUpdates,
      marketingEmails: marketingEmails,
      languagePreference: languagePreference,
      timezone: timezone,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static NotificationPreferencesModel fromDomain(NotificationPreferences entity) {
    return NotificationPreferencesModel(
      id: entity.id,
      userId: entity.userId,
      emailEnabled: entity.emailEnabled,
      pushEnabled: entity.pushEnabled,
      inAppEnabled: entity.inAppEnabled,
      smsEnabled: entity.smsEnabled,
      bookingConfirmations: entity.bookingConfirmations,
      bookingReminders: entity.bookingReminders,
      bookingUpdates: entity.bookingUpdates,
      marketingEmails: entity.marketingEmails,
      languagePreference: entity.languagePreference,
      timezone: entity.timezone,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

@freezed
class DeviceTokenModel with _$DeviceTokenModel {
  const factory DeviceTokenModel({
    required String id,
    required String userId,
    required String token,
    required String platform,
    String? appVersion,
    String? deviceId,
    @Default(true) bool isActive,
    required DateTime lastUsedAt,
    required DateTime createdAt,
  }) = _DeviceTokenModel;

  factory DeviceTokenModel.fromJson(Map<String, dynamic> json) =>
      _$DeviceTokenModelFromJson(json);
}

extension DeviceTokenModelExtension on DeviceTokenModel {
  DeviceToken toDomain() {
    return DeviceToken(
      id: id,
      userId: userId,
      token: token,
      platform: platform,
      appVersion: appVersion,
      deviceId: deviceId,
      isActive: isActive,
      lastUsedAt: lastUsedAt,
      createdAt: createdAt,
    );
  }

  static DeviceTokenModel fromDomain(DeviceToken entity) {
    return DeviceTokenModel(
      id: entity.id,
      userId: entity.userId,
      token: entity.token,
      platform: entity.platform,
      appVersion: entity.appVersion,
      deviceId: entity.deviceId,
      isActive: entity.isActive,
      lastUsedAt: entity.lastUsedAt,
      createdAt: entity.createdAt,
    );
  }
}

@freezed
class EmailTemplateModel with _$EmailTemplateModel {
  const factory EmailTemplateModel({
    required String id,
    required String templateKey,
    required String name,
    String? description,
    required String subjectDa,
    required String subjectEn,
    required String htmlContentDa,
    required String htmlContentEn,
    String? textContentDa,
    String? textContentEn,
    @Default([]) List<String> variables,
    @Default(true) bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _EmailTemplateModel;

  factory EmailTemplateModel.fromJson(Map<String, dynamic> json) =>
      _$EmailTemplateModelFromJson(json);
}

extension EmailTemplateModelExtension on EmailTemplateModel {
  EmailTemplate toDomain() {
    return EmailTemplate(
      id: id,
      templateKey: templateKey,
      name: name,
      description: description,
      subjectDa: subjectDa,
      subjectEn: subjectEn,
      htmlContentDa: htmlContentDa,
      htmlContentEn: htmlContentEn,
      textContentDa: textContentDa,
      textContentEn: textContentEn,
      variables: variables,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static EmailTemplateModel fromDomain(EmailTemplate entity) {
    return EmailTemplateModel(
      id: entity.id,
      templateKey: entity.templateKey,
      name: entity.name,
      description: entity.description,
      subjectDa: entity.subjectDa,
      subjectEn: entity.subjectEn,
      htmlContentDa: entity.htmlContentDa,
      htmlContentEn: entity.htmlContentEn,
      textContentDa: entity.textContentDa,
      textContentEn: entity.textContentEn,
      variables: entity.variables,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}