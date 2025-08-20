import 'package:dartz/dartz.dart';
import 'dart:async';
import 'package:homechef/core/error/failures.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import 'postmark_service.dart';
import 'onesignal_service.dart';

abstract class NotificationScheduler {
  Future<Either<Failure, void>> start();
  Future<Either<Failure, void>> stop();
  Future<Either<Failure, void>> processQueue();
  Future<Either<Failure, void>> scheduleRecurringProcessing();
  bool get isRunning;
}

class NotificationSchedulerImpl implements NotificationScheduler {
  final NotificationRepository _repository;
  final EmailService _emailService;
  final PushNotificationService _pushService;
  Timer? _processingTimer;
  Timer? _recurringTimer;
  bool _isRunning = false;

  static const Duration _processingInterval = Duration(minutes: 1);
  static const Duration _recurringInterval = Duration(hours: 1);

  NotificationSchedulerImpl({
    required NotificationRepository repository,
    required EmailService emailService,
    required PushNotificationService pushService,
  }) : _repository = repository,
       _emailService = emailService,
       _pushService = pushService;

  @override
  bool get isRunning => _isRunning;

  @override
  Future<Either<Failure, void>> start() async {
    try {
      if (_isRunning) {
        return const Right(null); // Already running
      }

      _isRunning = true;

      // Start processing timer for immediate notifications
      _processingTimer = Timer.periodic(_processingInterval, (_) {
        _processQueueSafely();
      });

      // Start recurring processing timer
      _recurringTimer = Timer.periodic(_recurringInterval, (_) {
        _processRecurringSafely();
      });

      // Process queue immediately on start
      await processQueue();

      return const Right(null);
    } catch (e) {
      _isRunning = false;
      return Left(ServerFailure('Failed to start notification scheduler: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> stop() async {
    try {
      _isRunning = false;
      _processingTimer?.cancel();
      _recurringTimer?.cancel();
      _processingTimer = null;
      _recurringTimer = null;

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to stop notification scheduler: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> processQueue() async {
    try {
      final pendingResult = await _repository.getPendingNotifications();
      if (pendingResult.isLeft()) {
        return pendingResult;
      }

      final pendingNotifications = pendingResult.getOrElse(() => []);
      
      if (pendingNotifications.isEmpty) {
        return const Right(null);
      }

      // Process notifications in batches to avoid overwhelming external services
      const batchSize = 10;
      final batches = <List<NotificationEntity>>[];
      
      for (int i = 0; i < pendingNotifications.length; i += batchSize) {
        final end = (i + batchSize < pendingNotifications.length) 
            ? i + batchSize 
            : pendingNotifications.length;
        batches.add(pendingNotifications.sublist(i, end));
      }

      for (final batch in batches) {
        await _processBatch(batch);
        
        // Small delay between batches to respect rate limits
        await Future.delayed(const Duration(milliseconds: 500));
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to process notification queue: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> scheduleRecurringProcessing() async {
    try {
      // This would typically fetch all recurring booking series and schedule
      // notifications for upcoming occurrences
      
      // For now, this is a placeholder that would:
      // 1. Get all active recurring booking series
      // 2. For each series, check if notifications need to be scheduled for upcoming occurrences
      // 3. Create recurring notification records for future dates
      
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to schedule recurring processing: $e'));
    }
  }

  Future<void> _processBatch(List<NotificationEntity> notifications) async {
    final futures = notifications.map(_processNotification);
    await Future.wait(futures);
  }

  Future<void> _processNotification(NotificationEntity notification) async {
    try {
      // Check if scheduled time has arrived (if scheduled)
      if (notification.scheduledAt != null &&
          notification.scheduledAt!.isAfter(DateTime.now())) {
        return; // Not yet time to send
      }

      // Update status to processing
      await _repository.updateNotificationStatus(
        notification.id,
        NotificationStatus.processing,
      );

      // Process based on channel
      Either<Failure, void> result;
      
      switch (notification.channel) {
        case NotificationChannel.email:
          result = await _emailService.sendEmailNotification(notification);
          break;
          
        case NotificationChannel.push:
          result = await _pushService.sendPushNotification(notification);
          break;
          
        case NotificationChannel.inApp:
          // For in-app notifications, just mark as sent (already stored in DB)
          result = const Right(null);
          break;
          
        case NotificationChannel.sms:
          // SMS not implemented yet, mark as failed
          result = Left(ServerFailure('SMS notifications not yet implemented'));
          break;
      }

      // Update status based on result
      if (result.isRight()) {
        await _repository.updateNotificationStatus(
          notification.id,
          NotificationStatus.sent,
        );
      } else {
        final failure = result.fold((f) => f, (_) => null);
        await _repository.updateNotificationStatus(
          notification.id,
          NotificationStatus.failed,
          failureReason: failure?.message ?? 'Unknown error',
        );
      }
    } catch (e) {
      // Mark as failed if any unexpected error occurs
      await _repository.updateNotificationStatus(
        notification.id,
        NotificationStatus.failed,
        failureReason: 'Processing error: $e',
      );
    }
  }

  // Safe wrapper that catches exceptions to prevent timer cancellation
  void _processQueueSafely() {
    processQueue().catchError((error) {
      // Log error but don't stop the scheduler
      print('Error processing notification queue: $error');
    });
  }

  void _processRecurringSafely() {
    scheduleRecurringProcessing().catchError((error) {
      // Log error but don't stop the scheduler
      print('Error processing recurring notifications: $error');
    });
  }
}

// Extension for timezone-aware scheduling
extension TimezoneAware on DateTime {
  DateTime toUserTimezone(String timezone) {
    // Convert to user's timezone
    // For Danish users, this would typically be 'Europe/Copenhagen'
    // This is a simplified implementation - in production, use a proper timezone library
    
    if (timezone == 'Europe/Copenhagen') {
      // Copenhagen is UTC+1 (UTC+2 during DST)
      final isDST = _isDaylightSavingTime(this);
      final offset = isDST ? 2 : 1;
      return add(Duration(hours: offset));
    }
    
    return this; // Default to UTC
  }
  
  static bool _isDaylightSavingTime(DateTime date) {
    // Simplified DST calculation for Europe/Copenhagen
    // DST runs from last Sunday in March to last Sunday in October
    
    final year = date.year;
    
    // Last Sunday in March
    final marchLastSunday = _getLastSundayOfMonth(year, 3);
    
    // Last Sunday in October
    final octoberLastSunday = _getLastSundayOfMonth(year, 10);
    
    return date.isAfter(marchLastSunday) && date.isBefore(octoberLastSunday);
  }
  
  static DateTime _getLastSundayOfMonth(int year, int month) {
    // Get the last day of the month
    final lastDay = DateTime(year, month + 1, 0);
    
    // Find the last Sunday
    final daysToSubtract = lastDay.weekday % 7;
    return lastDay.subtract(Duration(days: daysToSubtract));
  }
}

// Utility for notification retry logic
class NotificationRetryPolicy {
  static const List<Duration> _retryDelays = [
    Duration(minutes: 5),   // First retry after 5 minutes
    Duration(minutes: 30),  // Second retry after 30 minutes
    Duration(hours: 2),     // Third retry after 2 hours
  ];

  static Duration? getRetryDelay(int retryCount) {
    if (retryCount >= _retryDelays.length) {
      return null; // No more retries
    }
    return _retryDelays[retryCount];
  }

  static DateTime? getNextRetryTime(DateTime failedAt, int retryCount) {
    final delay = getRetryDelay(retryCount);
    if (delay == null) return null;
    
    return failedAt.add(delay);
  }
}

// Background task scheduler for mobile platforms
abstract class BackgroundTaskScheduler {
  Future<Either<Failure, void>> schedulePeriodicTask(
    String taskId,
    Duration interval,
    Future<void> Function() task,
  );
  
  Future<Either<Failure, void>> cancelTask(String taskId);
}

// Platform-specific implementations would be created for iOS and Android
class MobileBackgroundTaskScheduler implements BackgroundTaskScheduler {
  final Map<String, Timer> _activeTasks = {};

  @override
  Future<Either<Failure, void>> schedulePeriodicTask(
    String taskId,
    Duration interval,
    Future<void> Function() task,
  ) async {
    try {
      // Cancel existing task if any
      await cancelTask(taskId);
      
      // In a real implementation, this would use platform-specific background task APIs
      // For now, use a simple timer (which won't work in background on mobile)
      final timer = Timer.periodic(interval, (_) {
        task().catchError((error) {
          print('Background task $taskId failed: $error');
        });
      });
      
      _activeTasks[taskId] = timer;
      
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to schedule background task: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelTask(String taskId) async {
    try {
      _activeTasks[taskId]?.cancel();
      _activeTasks.remove(taskId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to cancel background task: $e'));
    }
  }
}

// Notification analytics and monitoring
class NotificationAnalytics {
  final NotificationRepository _repository;
  
  NotificationAnalytics(this._repository);
  
  Future<Either<Failure, Map<String, dynamic>>> getDeliveryStats({
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      // This would query the notifications table for statistics
      // For now, return mock data
      
      return Right({
        'total_sent': 1250,
        'email_sent': 800,
        'push_sent': 400,
        'in_app_sent': 50,
        'delivery_rate': 0.95,
        'open_rate': 0.68, // Would come from email service
        'click_rate': 0.12, // Would come from email service
        'failed_notifications': 62,
        'most_common_failures': [
          {'reason': 'Invalid email address', 'count': 25},
          {'reason': 'Device token expired', 'count': 20},
          {'reason': 'Rate limit exceeded', 'count': 17},
        ],
      });
    } catch (e) {
      return Left(ServerFailure('Failed to get delivery stats: $e'));
    }
  }
  
  Future<Either<Failure, List<Map<String, dynamic>>>> getFailedNotifications({
    int limit = 50,
  }) async {
    try {
      // This would query failed notifications from the database
      return Right([]);
    } catch (e) {
      return Left(ServerFailure('Failed to get failed notifications: $e'));
    }
  }
}