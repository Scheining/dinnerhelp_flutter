import 'package:dartz/dartz.dart';
import 'package:homechef/core/error/failures.dart';
import '../entities/notification.dart';

abstract class NotificationRepository {
  Future<Either<Failure, NotificationEntity>> createNotification(
    NotificationRequest request,
  );
  
  Future<Either<Failure, List<NotificationEntity>>> getUserNotifications(
    String userId, {
    int limit = 50,
    int offset = 0,
  });
  
  Future<Either<Failure, NotificationEntity>> updateNotificationStatus(
    String notificationId,
    NotificationStatus status, {
    String? failureReason,
  });
  
  Future<Either<Failure, NotificationPreferences>> getUserPreferences(
    String userId,
  );
  
  Future<Either<Failure, NotificationPreferences>> updateUserPreferences(
    String userId,
    NotificationPreferences preferences,
  );
  
  Future<Either<Failure, void>> scheduleNotification(
    String notificationId,
    DateTime scheduledFor,
  );
  
  Future<Either<Failure, List<NotificationEntity>>> getPendingNotifications();
  
  Future<Either<Failure, void>> markAsRead(String notificationId);
  
  Future<Either<Failure, void>> markAllAsRead(String userId);
  
  Future<Either<Failure, DeviceToken>> registerDeviceToken(
    String userId,
    String token,
    String platform, {
    String? appVersion,
    String? deviceId,
  });
  
  Future<Either<Failure, void>> deregisterDeviceToken(String token);
  
  Future<Either<Failure, List<DeviceToken>>> getUserDeviceTokens(
    String userId,
  );
  
  Future<Either<Failure, EmailTemplate>> getEmailTemplate(
    String templateKey,
  );
  
  Future<Either<Failure, List<RecurringNotification>>> 
      getRecurringNotifications(String bookingSeriesId);
      
  Future<Either<Failure, RecurringNotification>> createRecurringNotification(
    RecurringNotification notification,
  );
  
  Future<Either<Failure, void>> markRecurringNotificationSent(
    String notificationId,
  );
}