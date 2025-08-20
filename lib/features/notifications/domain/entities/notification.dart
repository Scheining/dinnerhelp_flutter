import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:equatable/equatable.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

enum NotificationType {
  bookingConfirmation,
  bookingReminder24h,
  bookingReminder1h,
  bookingCompletion,
  bookingModified,
  bookingCancelled,
  recurringBookingCreated,
  chefMessage,
  paymentSuccess,
  paymentFailed,
}

enum NotificationStatus {
  pending,
  processing,
  sent,
  delivered,
  failed,
  cancelled,
}

enum NotificationChannel {
  email,
  push,
  inApp,
  sms,
}

@freezed
class NotificationEntity with _$NotificationEntity {
  const factory NotificationEntity({
    required String id,
    required String userId,
    String? bookingId,
    String? chefId,
    required NotificationType type,
    required NotificationChannel channel,
    @Default(NotificationStatus.pending) NotificationStatus status,
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
  }) = _NotificationEntity;

  factory NotificationEntity.fromJson(Map<String, dynamic> json) =>
      _$NotificationEntityFromJson(json);
}

@freezed
class NotificationPreferences with _$NotificationPreferences {
  const factory NotificationPreferences({
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
  }) = _NotificationPreferences;

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesFromJson(json);
}

@freezed
class DeviceToken with _$DeviceToken {
  const factory DeviceToken({
    required String id,
    required String userId,
    required String token,
    required String platform,
    String? appVersion,
    String? deviceId,
    @Default(true) bool isActive,
    required DateTime lastUsedAt,
    required DateTime createdAt,
  }) = _DeviceToken;

  factory DeviceToken.fromJson(Map<String, dynamic> json) =>
      _$DeviceTokenFromJson(json);
}

@freezed
class EmailTemplate with _$EmailTemplate {
  const factory EmailTemplate({
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
  }) = _EmailTemplate;

  factory EmailTemplate.fromJson(Map<String, dynamic> json) =>
      _$EmailTemplateFromJson(json);
}

@freezed
class NotificationRequest with _$NotificationRequest {
  const factory NotificationRequest({
    required String userId,
    String? bookingId,
    String? chefId,
    required NotificationType type,
    required NotificationChannel channel,
    required String title,
    required String content,
    @Default({}) Map<String, dynamic> data,
    String? templateId,
    DateTime? scheduledAt,
  }) = _NotificationRequest;

  factory NotificationRequest.fromJson(Map<String, dynamic> json) =>
      _$NotificationRequestFromJson(json);
}

class RecurringNotification extends Equatable {
  final String id;
  final String bookingSeriesId;
  final String? bookingId;
  final DateTime occurrenceDate;
  final NotificationType notificationType;
  final bool isSent;
  final DateTime? sentAt;
  final DateTime createdAt;

  const RecurringNotification({
    required this.id,
    required this.bookingSeriesId,
    this.bookingId,
    required this.occurrenceDate,
    required this.notificationType,
    required this.isSent,
    this.sentAt,
    required this.createdAt,
  });

  factory RecurringNotification.fromJson(Map<String, dynamic> json) =>
      RecurringNotification(
        id: json['id'] as String,
        bookingSeriesId: json['booking_series_id'] as String,
        bookingId: json['booking_id'] as String?,
        occurrenceDate: DateTime.parse(json['occurrence_date'] as String),
        notificationType: NotificationType.values.firstWhere(
          (e) => e.name == json['notification_type'],
        ),
        isSent: json['is_sent'] as bool,
        sentAt: json['sent_at'] != null
            ? DateTime.parse(json['sent_at'] as String)
            : null,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'booking_series_id': bookingSeriesId,
        'booking_id': bookingId,
        'occurrence_date': occurrenceDate.toIso8601String().split('T')[0],
        'notification_type': notificationType.name,
        'is_sent': isSent,
        'sent_at': sentAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        bookingSeriesId,
        bookingId,
        occurrenceDate,
        notificationType,
        isSent,
        sentAt,
        createdAt,
      ];
}