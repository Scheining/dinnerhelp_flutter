import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/services/notification_service.dart';
import '../../domain/usecases/send_booking_confirmation.dart';
import '../../domain/usecases/manage_notification_preferences.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../data/services/notification_service_impl.dart' as impl;
import '../../data/services/postmark_service.dart';
import '../../data/services/onesignal_service.dart';
import 'package:homechef/core/error/failures.dart';

part 'notification_providers.g.dart';

// Repository providers
@riverpod
NotificationRepository notificationRepository(NotificationRepositoryRef ref) {
  final supabaseClient = Supabase.instance.client;
  return NotificationRepositoryImpl(supabaseClient);
}

// Service providers
@riverpod
EmailService emailService(EmailServiceRef ref) {
  // In production, these would come from environment variables
  return PostmarkService(
    apiToken: 'your-postmark-api-token',
    defaultFromEmail: 'noreply@dinnerhelp.dk',
    defaultFromName: 'DinnerHelp',
  );
}

@riverpod
PushNotificationService pushNotificationService(PushNotificationServiceRef ref) {
  // In production, these would come from environment variables
  return OneSignalService(
    appId: 'your-onesignal-app-id',
    apiKey: 'your-onesignal-api-key',
  );
}

@riverpod
NotificationService notificationService(NotificationServiceRef ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  final emailService = ref.watch(emailServiceProvider);
  final pushService = ref.watch(pushNotificationServiceProvider);
  
  return impl.NotificationServiceImpl(
    repository: repository,
    emailService: emailService,
    pushService: pushService,
  );
}

// Use case providers
@riverpod
SendBookingConfirmation sendBookingConfirmation(SendBookingConfirmationRef ref) {
  final service = ref.watch(notificationServiceProvider);
  return SendBookingConfirmation(service);
}

@riverpod
Schedule24HourReminder schedule24HourReminder(Schedule24HourReminderRef ref) {
  final service = ref.watch(notificationServiceProvider);
  return Schedule24HourReminder(service);
}

@riverpod
Schedule1HourReminder schedule1HourReminder(Schedule1HourReminderRef ref) {
  final service = ref.watch(notificationServiceProvider);
  return Schedule1HourReminder(service);
}

@riverpod
SendCompletionReview sendCompletionReview(SendCompletionReviewRef ref) {
  final service = ref.watch(notificationServiceProvider);
  return SendCompletionReview(service);
}

@riverpod
SendBookingModification sendBookingModification(SendBookingModificationRef ref) {
  final service = ref.watch(notificationServiceProvider);
  return SendBookingModification(service);
}

@riverpod
SendCancellationNotice sendCancellationNotice(SendCancellationNoticeRef ref) {
  final service = ref.watch(notificationServiceProvider);
  return SendCancellationNotice(service);
}

@riverpod
GetNotificationPreferences getNotificationPreferences(GetNotificationPreferencesRef ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return GetNotificationPreferences(repository);
}

@riverpod
UpdateNotificationPreferences updateNotificationPreferences(UpdateNotificationPreferencesRef ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return UpdateNotificationPreferences(repository);
}

@riverpod
GetUserNotifications getUserNotifications(GetUserNotificationsRef ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return GetUserNotifications(repository);
}

@riverpod
MarkNotificationAsRead markNotificationAsRead(MarkNotificationAsReadRef ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return MarkNotificationAsRead(repository);
}

@riverpod
RegisterDeviceToken registerDeviceToken(RegisterDeviceTokenRef ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return RegisterDeviceToken(repository);
}

// State management providers

@riverpod
class NotificationPreferencesNotifier extends _$NotificationPreferencesNotifier {
  @override
  FutureOr<NotificationPreferences?> build() {
    return null;
  }

  Future<void> loadPreferences(String userId) async {
    state = const AsyncValue.loading();
    
    final useCase = ref.read(getNotificationPreferencesProvider);
    final result = await useCase(userId);
    
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (preferences) => AsyncValue.data(preferences),
    );
  }

  Future<void> updatePreferences(String userId, NotificationPreferences preferences) async {
    final useCase = ref.read(updateNotificationPreferencesProvider);
    final result = await useCase(userId, preferences);
    
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (updatedPreferences) => state = AsyncValue.data(updatedPreferences),
    );
  }

  Future<void> toggleEmailNotifications(String userId) async {
    final currentPrefs = state.value;
    if (currentPrefs == null) return;
    
    final updatedPrefs = currentPrefs.copyWith(
      emailEnabled: !currentPrefs.emailEnabled,
    );
    
    await updatePreferences(userId, updatedPrefs);
  }

  Future<void> togglePushNotifications(String userId) async {
    final currentPrefs = state.value;
    if (currentPrefs == null) return;
    
    final updatedPrefs = currentPrefs.copyWith(
      pushEnabled: !currentPrefs.pushEnabled,
    );
    
    await updatePreferences(userId, updatedPrefs);
  }

  Future<void> toggleBookingReminders(String userId) async {
    final currentPrefs = state.value;
    if (currentPrefs == null) return;
    
    final updatedPrefs = currentPrefs.copyWith(
      bookingReminders: !currentPrefs.bookingReminders,
    );
    
    await updatePreferences(userId, updatedPrefs);
  }

  Future<void> updateLanguagePreference(String userId, String language) async {
    final currentPrefs = state.value;
    if (currentPrefs == null) return;
    
    final updatedPrefs = currentPrefs.copyWith(
      languagePreference: language,
    );
    
    await updatePreferences(userId, updatedPrefs);
  }
}

@riverpod
class UserNotificationsNotifier extends _$UserNotificationsNotifier {
  @override
  FutureOr<List<NotificationEntity>> build() {
    return [];
  }

  Future<void> loadNotifications(String userId, {bool refresh = false}) async {
    if (!refresh && state.hasValue && state.value!.isNotEmpty) {
      return; // Don't reload if we already have data
    }
    
    state = const AsyncValue.loading();
    
    final useCase = ref.read(getUserNotificationsProvider);
    final result = await useCase(userId);
    
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (notifications) => AsyncValue.data(notifications),
    );
  }

  Future<void> loadMoreNotifications(String userId, int offset) async {
    final useCase = ref.read(getUserNotificationsProvider);
    final result = await useCase(userId, offset: offset);
    
    result.fold(
      (failure) {
        // Handle error for pagination - don't replace state
      },
      (newNotifications) {
        final currentNotifications = state.value ?? [];
        state = AsyncValue.data([...currentNotifications, ...newNotifications]);
      },
    );
  }

  Future<void> markAsRead(String notificationId) async {
    final useCase = ref.read(markNotificationAsReadProvider);
    final result = await useCase(notificationId);
    
    result.fold(
      (failure) {
        // Handle error
      },
      (_) {
        // Update local state
        final currentNotifications = state.value ?? [];
        final updatedNotifications = currentNotifications.map((notification) {
          if (notification.id == notificationId) {
            final updatedData = {...notification.data, 'read': true};
            return notification.copyWith(data: updatedData);
          }
          return notification;
        }).toList();
        
        state = AsyncValue.data(updatedNotifications);
      },
    );
  }

  Future<void> markAllAsRead(String userId) async {
    final repository = ref.read(notificationRepositoryProvider);
    final result = await repository.markAllAsRead(userId);
    
    result.fold(
      (failure) {
        // Handle error
      },
      (_) {
        // Update local state
        final currentNotifications = state.value ?? [];
        final updatedNotifications = currentNotifications.map((notification) {
          final updatedData = {...notification.data, 'read': true};
          return notification.copyWith(data: updatedData);
        }).toList();
        
        state = AsyncValue.data(updatedNotifications);
      },
    );
  }

  int get unreadCount {
    final notifications = state.value ?? [];
    return notifications.where((notification) => 
      notification.channel == NotificationChannel.inApp &&
      !(notification.data['read'] as bool? ?? false)
    ).length;
  }
}

@riverpod
class BookingNotificationNotifier extends _$BookingNotificationNotifier {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> sendBookingConfirmation(
    String bookingId,
    {bool toUser = true, bool toChef = true}
  ) async {
    state = const AsyncValue.loading();
    
    final useCase = ref.read(sendBookingConfirmationProvider);
    
    RecipientType recipientType;
    if (toUser && toChef) {
      recipientType = RecipientType.both;
    } else if (toUser) {
      recipientType = RecipientType.user;
    } else if (toChef) {
      recipientType = RecipientType.chef;
    } else {
      state = AsyncValue.error(
        ValidationFailure('At least one recipient must be selected'),
        StackTrace.current,
      );
      return;
    }
    
    final result = await useCase(bookingId, recipientType);
    
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (_) => const AsyncValue.data(null),
    );
  }

  Future<void> scheduleBookingReminders(String bookingId) async {
    final schedule24h = ref.read(schedule24HourReminderProvider);
    final schedule1h = ref.read(schedule1HourReminderProvider);
    
    // Schedule both reminders
    final result24h = await schedule24h(bookingId);
    final result1h = await schedule1h(bookingId);
    
    // Handle any failures
    result24h.fold(
      (failure) => print('Failed to schedule 24h reminder: ${failure.message}'),
      (_) => print('24h reminder scheduled successfully'),
    );
    
    result1h.fold(
      (failure) => print('Failed to schedule 1h reminder: ${failure.message}'),
      (_) => print('1h reminder scheduled successfully'),
    );
  }

  Future<void> sendBookingModification(
    String bookingId,
    Map<String, dynamic> changes,
  ) async {
    final useCase = ref.read(sendBookingModificationProvider);
    final result = await useCase(bookingId, changes);
    
    result.fold(
      (failure) => print('Failed to send modification notice: ${failure.message}'),
      (_) => print('Modification notice sent successfully'),
    );
  }

  Future<void> sendCancellationNotice(
    String bookingId,
    String reason,
  ) async {
    final useCase = ref.read(sendCancellationNoticeProvider);
    final result = await useCase(bookingId, reason);
    
    result.fold(
      (failure) => print('Failed to send cancellation notice: ${failure.message}'),
      (_) => print('Cancellation notice sent successfully'),
    );
  }
}

// Helper provider for checking notification permissions
@riverpod
Future<bool> hasNotificationPermission(HasNotificationPermissionRef ref) async {
  // This would integrate with platform-specific permission checking
  // For now, return true as a placeholder
  return true;
}

// Provider for device token registration
@riverpod
class DeviceTokenNotifier extends _$DeviceTokenNotifier {
  @override
  FutureOr<DeviceToken?> build() {
    return null;
  }

  Future<void> registerToken(
    String userId,
    String token,
    String platform, {
    String? appVersion,
    String? deviceId,
  }) async {
    state = const AsyncValue.loading();
    
    final useCase = ref.read(registerDeviceTokenProvider);
    final result = await useCase(
      userId,
      token,
      platform,
      appVersion: appVersion,
      deviceId: deviceId,
    );
    
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (deviceToken) => AsyncValue.data(deviceToken),
    );
  }
}