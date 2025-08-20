import 'package:dartz/dartz.dart';
import 'package:homechef/core/error/failures.dart';
import '../entities/notification.dart';
import '../repositories/notification_repository.dart';

class GetNotificationPreferences {
  final NotificationRepository _repository;

  const GetNotificationPreferences(this._repository);

  Future<Either<Failure, NotificationPreferences>> call(String userId) async {
    return await _repository.getUserPreferences(userId);
  }
}

class UpdateNotificationPreferences {
  final NotificationRepository _repository;

  const UpdateNotificationPreferences(this._repository);

  Future<Either<Failure, NotificationPreferences>> call(
    String userId,
    NotificationPreferences preferences,
  ) async {
    return await _repository.updateUserPreferences(userId, preferences);
  }
}

class RegisterDeviceToken {
  final NotificationRepository _repository;

  const RegisterDeviceToken(this._repository);

  Future<Either<Failure, DeviceToken>> call(
    String userId,
    String token,
    String platform, {
    String? appVersion,
    String? deviceId,
  }) async {
    return await _repository.registerDeviceToken(
      userId,
      token,
      platform,
      appVersion: appVersion,
      deviceId: deviceId,
    );
  }
}

class DeregisterDeviceToken {
  final NotificationRepository _repository;

  const DeregisterDeviceToken(this._repository);

  Future<Either<Failure, void>> call(String token) async {
    return await _repository.deregisterDeviceToken(token);
  }
}

class GetUserNotifications {
  final NotificationRepository _repository;

  const GetUserNotifications(this._repository);

  Future<Either<Failure, List<NotificationEntity>>> call(
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    return await _repository.getUserNotifications(
      userId,
      limit: limit,
      offset: offset,
    );
  }
}

class MarkNotificationAsRead {
  final NotificationRepository _repository;

  const MarkNotificationAsRead(this._repository);

  Future<Either<Failure, void>> call(String notificationId) async {
    return await _repository.markAsRead(notificationId);
  }
}

class MarkAllNotificationsAsRead {
  final NotificationRepository _repository;

  const MarkAllNotificationsAsRead(this._repository);

  Future<Either<Failure, void>> call(String userId) async {
    return await _repository.markAllAsRead(userId);
  }
}