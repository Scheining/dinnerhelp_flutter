import 'package:dartz/dartz.dart';
import 'package:homechef/core/error/failures.dart';
import '../entities/notification.dart';
import '../services/notification_service.dart';

class SendBookingConfirmation {
  final NotificationService _notificationService;

  const SendBookingConfirmation(this._notificationService);

  Future<Either<Failure, void>> call(
    String bookingId,
    RecipientType recipientType,
  ) async {
    return await _notificationService.sendBookingConfirmation(
      bookingId,
      recipientType,
    );
  }
}

class Schedule24HourReminder {
  final NotificationService _notificationService;

  const Schedule24HourReminder(this._notificationService);

  Future<Either<Failure, void>> call(String bookingId) async {
    return await _notificationService.schedule24HourReminder(bookingId);
  }
}

class Schedule1HourReminder {
  final NotificationService _notificationService;

  const Schedule1HourReminder(this._notificationService);

  Future<Either<Failure, void>> call(String bookingId) async {
    return await _notificationService.schedule1HourReminder(bookingId);
  }
}

class SendCompletionReview {
  final NotificationService _notificationService;

  const SendCompletionReview(this._notificationService);

  Future<Either<Failure, void>> call(String bookingId) async {
    return await _notificationService.sendCompletionReview(bookingId);
  }
}

class SendBookingModification {
  final NotificationService _notificationService;

  const SendBookingModification(this._notificationService);

  Future<Either<Failure, void>> call(
    String bookingId,
    Map<String, dynamic> changes,
  ) async {
    return await _notificationService.sendBookingModification(
      bookingId,
      changes,
    );
  }
}

class SendCancellationNotice {
  final NotificationService _notificationService;

  const SendCancellationNotice(this._notificationService);

  Future<Either<Failure, void>> call(
    String bookingId,
    String reason,
  ) async {
    return await _notificationService.sendCancellationNotice(
      bookingId,
      reason,
    );
  }
}

class HandleRecurringNotifications {
  final NotificationService _notificationService;

  const HandleRecurringNotifications(this._notificationService);

  Future<Either<Failure, void>> call(String seriesId) async {
    return await _notificationService.handleRecurringNotifications(seriesId);
  }
}

class SendInAppMessage {
  final NotificationService _notificationService;

  const SendInAppMessage(this._notificationService);

  Future<Either<Failure, void>> call(
    String bookingId,
    String fromUserId,
    String toUserId,
    String message,
  ) async {
    return await _notificationService.sendInAppMessage(
      bookingId,
      fromUserId,
      toUserId,
      message,
    );
  }
}