import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homechef/core/error/failures.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final SupabaseClient _supabaseClient;

  const NotificationRepositoryImpl(this._supabaseClient);

  @override
  Future<Either<Failure, NotificationEntity>> createNotification(
    NotificationRequest request,
  ) async {
    try {
      final data = {
        'user_id': request.userId,
        if (request.bookingId != null) 'booking_id': request.bookingId,
        if (request.chefId != null) 'chef_id': request.chefId,
        'type': request.type.name,
        'channel': request.channel.name,
        'title': request.title,
        'content': request.content,
        'data': request.data,
        if (request.templateId != null) 'template_id': request.templateId,
        if (request.scheduledAt != null) 
          'scheduled_at': request.scheduledAt!.toIso8601String(),
      };

      final response = await _supabaseClient
          .from('notifications')
          .insert(data)
          .select()
          .single();

      final notification = NotificationModel.fromJson(response).toDomain();
      
      // If scheduled, add to queue
      if (request.scheduledAt != null) {
        await _supabaseClient.from('notification_queue').insert({
          'notification_id': notification.id,
          'scheduled_for': request.scheduledAt!.toIso8601String(),
        });
      }

      return Right(notification);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Failed to create notification: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<NotificationEntity>>> getUserNotifications(
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _supabaseClient
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final notifications = response
          .map((json) => NotificationModel.fromJson(json).toDomain())
          .toList();

      return Right(notifications);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Failed to get notifications: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, NotificationEntity>> updateNotificationStatus(
    String notificationId,
    NotificationStatus status, {
    String? failureReason,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': status.name,
        'updated_at': DateTime.now().toIso8601String(),
      };

      switch (status) {
        case NotificationStatus.sent:
          updateData['sent_at'] = DateTime.now().toIso8601String();
          break;
        case NotificationStatus.delivered:
          updateData['delivered_at'] = DateTime.now().toIso8601String();
          break;
        case NotificationStatus.failed:
          updateData['failed_at'] = DateTime.now().toIso8601String();
          if (failureReason != null) {
            updateData['failure_reason'] = failureReason;
          }
          // Increment retry count
          final currentNotification = await _supabaseClient
              .from('notifications')
              .select('retry_count')
              .eq('id', notificationId)
              .single();
          updateData['retry_count'] = (currentNotification['retry_count'] as int) + 1;
          break;
        default:
          break;
      }

      final response = await _supabaseClient
          .from('notifications')
          .update(updateData)
          .eq('id', notificationId)
          .select()
          .single();

      final notification = NotificationModel.fromJson(response).toDomain();
      return Right(notification);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Failed to update notification: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, NotificationPreferences>> getUserPreferences(
    String userId,
  ) async {
    try {
      final response = await _supabaseClient
          .from('notification_preferences')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        // Create default preferences if they don't exist
        final defaultPrefs = {
          'user_id': userId,
          'email_enabled': true,
          'push_enabled': true,
          'in_app_enabled': true,
          'sms_enabled': false,
          'booking_confirmations': true,
          'booking_reminders': true,
          'booking_updates': true,
          'marketing_emails': false,
          'language_preference': 'da',
          'timezone': 'Europe/Copenhagen',
        };

        final newResponse = await _supabaseClient
            .from('notification_preferences')
            .insert(defaultPrefs)
            .select()
            .single();

        final preferences = NotificationPreferencesModel.fromJson(newResponse)
            .toDomain();
        return Right(preferences);
      }

      final preferences = NotificationPreferencesModel.fromJson(response)
          .toDomain();
      return Right(preferences);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Failed to get preferences: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, NotificationPreferences>> updateUserPreferences(
    String userId,
    NotificationPreferences preferences,
  ) async {
    try {
      final updateData = {
        'email_enabled': preferences.emailEnabled,
        'push_enabled': preferences.pushEnabled,
        'in_app_enabled': preferences.inAppEnabled,
        'sms_enabled': preferences.smsEnabled,
        'booking_confirmations': preferences.bookingConfirmations,
        'booking_reminders': preferences.bookingReminders,
        'booking_updates': preferences.bookingUpdates,
        'marketing_emails': preferences.marketingEmails,
        'language_preference': preferences.languagePreference,
        'timezone': preferences.timezone,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabaseClient
          .from('notification_preferences')
          .update(updateData)
          .eq('user_id', userId)
          .select()
          .single();

      final updatedPreferences = NotificationPreferencesModel.fromJson(response)
          .toDomain();
      return Right(updatedPreferences);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Failed to update preferences: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> scheduleNotification(
    String notificationId,
    DateTime scheduledFor,
  ) async {
    try {
      await _supabaseClient.from('notification_queue').insert({
        'notification_id': notificationId,
        'scheduled_for': scheduledFor.toIso8601String(),
      });

      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Failed to schedule notification: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<NotificationEntity>>> getPendingNotifications() async {
    try {
      // Get notifications that are:
      // 1. Pending status
      // 2. Either not scheduled or scheduled time has passed
      // 3. Retry count is less than max retries
      final response = await _supabaseClient
          .from('notifications')
          .select()
          .eq('status', 'pending')
          .or('scheduled_at.is.null,scheduled_at.lte.${DateTime.now().toIso8601String()}')
          .filter('retry_count', 'lt', 'max_retries')
          .order('created_at', ascending: true);

      final notifications = response
          .map((json) => NotificationModel.fromJson(json).toDomain())
          .toList();

      return Right(notifications);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Failed to get pending notifications: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      await _supabaseClient
          .from('notifications')
          .update({
            'data': {'read': true},
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', notificationId);

      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Failed to mark as read: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead(String userId) async {
    try {
      await _supabaseClient
          .from('notifications')
          .update({
            'data': {'read': true},
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('channel', 'in_app');

      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Failed to mark all as read: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, DeviceToken>> registerDeviceToken(
    String userId,
    String token,
    String platform, {
    String? appVersion,
    String? deviceId,
  }) async {
    try {
      // First, deactivate any existing tokens for this device
      if (deviceId != null) {
        await _supabaseClient
            .from('device_tokens')
            .update({'is_active': false})
            .eq('user_id', userId)
            .eq('device_id', deviceId);
      }

      final data = {
        'user_id': userId,
        'token': token,
        'platform': platform,
        if (appVersion != null) 'app_version': appVersion,
        if (deviceId != null) 'device_id': deviceId,
        'is_active': true,
        'last_used_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabaseClient
          .from('device_tokens')
          .upsert(data, onConflict: 'token,user_id')
          .select()
          .single();

      final deviceToken = DeviceTokenModel.fromJson(response).toDomain();
      return Right(deviceToken);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Failed to register device token: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deregisterDeviceToken(String token) async {
    try {
      await _supabaseClient
          .from('device_tokens')
          .update({'is_active': false})
          .eq('token', token);

      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Failed to deregister device token: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<DeviceToken>>> getUserDeviceTokens(
    String userId,
  ) async {
    try {
      final response = await _supabaseClient
          .from('device_tokens')
          .select()
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('last_used_at', ascending: false);

      final deviceTokens = response
          .map((json) => DeviceTokenModel.fromJson(json).toDomain())
          .toList();

      return Right(deviceTokens);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Failed to get device tokens: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, EmailTemplate>> getEmailTemplate(
    String templateKey,
  ) async {
    try {
      final response = await _supabaseClient
          .from('email_templates')
          .select()
          .eq('template_key', templateKey)
          .eq('is_active', true)
          .single();

      final template = EmailTemplateModel.fromJson(response).toDomain();
      return Right(template);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Failed to get email template: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<RecurringNotification>>> getRecurringNotifications(
    String bookingSeriesId,
  ) async {
    try {
      final response = await _supabaseClient
          .from('recurring_booking_notifications')
          .select()
          .eq('booking_series_id', bookingSeriesId)
          .order('occurrence_date', ascending: true);

      final notifications = response
          .map((json) => RecurringNotification.fromJson(json))
          .toList();

      return Right(notifications);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Failed to get recurring notifications: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, RecurringNotification>> createRecurringNotification(
    RecurringNotification notification,
  ) async {
    try {
      final data = notification.toJson();
      data.remove('id'); // Let database generate ID
      data.remove('created_at'); // Let database set timestamp

      final response = await _supabaseClient
          .from('recurring_booking_notifications')
          .insert(data)
          .select()
          .single();

      final createdNotification = RecurringNotification.fromJson(response);
      return Right(createdNotification);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Failed to create recurring notification: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markRecurringNotificationSent(
    String notificationId,
  ) async {
    try {
      await _supabaseClient
          .from('recurring_booking_notifications')
          .update({
            'is_sent': true,
            'sent_at': DateTime.now().toIso8601String(),
          })
          .eq('id', notificationId);

      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(ServerFailure('Failed to mark recurring notification as sent: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}