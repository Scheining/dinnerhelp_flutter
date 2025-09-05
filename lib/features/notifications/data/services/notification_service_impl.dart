import 'package:dartz/dartz.dart';
import 'package:homechef/core/error/failures.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/services/notification_service.dart';
import '../models/booking_notification_data.dart';
import 'postmark_service.dart';
import 'onesignal_service.dart';

class NotificationServiceImpl implements NotificationService {
  final NotificationRepository _repository;
  final EmailService _emailService;
  final PushNotificationService _pushService;
  
  const NotificationServiceImpl({
    required NotificationRepository repository,
    required EmailService emailService,
    required PushNotificationService pushService,
  }) : _repository = repository,
       _emailService = emailService,
       _pushService = pushService;
  
  @override
  Future<Either<Failure, void>> sendBookingConfirmation(
    String bookingId,
    RecipientType recipientType,
  ) async {
    try {
      // Get booking details
      final bookingResult = await _getBookingData(bookingId);
      if (bookingResult.isLeft()) {
        return Left(bookingResult.fold((failure) => failure, (_) => 
            const ServerFailure('Unable to get booking data')));
      }
      
      final bookingData = bookingResult.getOrElse(() => 
          throw Exception('Booking data is null'));
      
      // Send notifications based on recipient type
      switch (recipientType) {
        case RecipientType.user:
          return await _sendUserBookingConfirmation(bookingData);
          
        case RecipientType.chef:
          return await _sendChefBookingConfirmation(bookingData);
          
        case RecipientType.both:
          final userResult = await _sendUserBookingConfirmation(bookingData);
          if (userResult.isLeft()) return userResult;
          
          return await _sendChefBookingConfirmation(bookingData);
      }
    } catch (e) {
      return Left(ServerFailure('Failed to send booking confirmation: $e'));
    }
  }
  
  @override
  Future<Either<Failure, void>> schedule24HourReminder(String bookingId) async {
    try {
      final bookingResult = await _getBookingData(bookingId);
      if (bookingResult.isLeft()) return bookingResult;
      
      final bookingData = bookingResult.getOrElse(() => 
          throw Exception('Booking data is null'));
      
      final reminderTime = bookingData.dateTime.subtract(
        const Duration(hours: 24),
      );
      
      // Only schedule if reminder time is in the future
      if (reminderTime.isBefore(DateTime.now())) {
        return const Right(null);
      }
      
      // Check user preferences
      final preferencesResult = await _repository.getUserPreferences(
        bookingData.userId,
      );
      if (preferencesResult.isLeft()) return preferencesResult;
      
      final preferences = preferencesResult.getOrElse(() => 
          throw Exception('Preferences is null'));
      
      if (!preferences.bookingReminders) {
        return const Right(null); // User has disabled reminders
      }
      
      // Create notification requests
      final notifications = <NotificationRequest>[];
      
      if (preferences.emailEnabled) {
        notifications.add(NotificationRequest(
          userId: bookingData.userId,
          bookingId: bookingId,
          type: NotificationType.bookingReminder24h,
          channel: NotificationChannel.email,
          title: preferences.languagePreference == 'da' 
              ? 'Påmindelse: Din madoplevelse i morgen!'
              : 'Reminder: Your dining experience tomorrow!',
          content: _buildReminderContent(bookingData, preferences),
          templateId: 'booking_reminder_24h',
          scheduledAt: reminderTime,
          data: bookingData.toNotificationData(),
        ));
      }
      
      if (preferences.pushEnabled) {
        notifications.add(NotificationRequest(
          userId: bookingData.userId,
          bookingId: bookingId,
          type: NotificationType.bookingReminder24h,
          channel: NotificationChannel.push,
          title: preferences.languagePreference == 'da'
              ? 'Madoplevelse i morgen'
              : 'Dining experience tomorrow',
          content: _buildReminderPushContent(bookingData, preferences),
          scheduledAt: reminderTime,
          data: bookingData.toNotificationData(),
        ));
      }
      
      // Create and schedule notifications
      for (final request in notifications) {
        final result = await _repository.createNotification(request);
        if (result.isLeft()) return result;
        
        final notification = result.getOrElse(() => 
            throw Exception('Notification is null'));
        
        await _repository.scheduleNotification(
          notification.id,
          reminderTime,
        );
      }
      
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to schedule 24h reminder: $e'));
    }
  }
  
  @override
  Future<Either<Failure, void>> schedule1HourReminder(String bookingId) async {
    try {
      final bookingResult = await _getBookingData(bookingId);
      if (bookingResult.isLeft()) return bookingResult;
      
      final bookingData = bookingResult.getOrElse(() => 
          throw Exception('Booking data is null'));
      
      final reminderTime = bookingData.dateTime.subtract(
        const Duration(hours: 1),
      );
      
      // Only schedule if reminder time is in the future
      if (reminderTime.isBefore(DateTime.now())) {
        return const Right(null);
      }
      
      // Check user preferences
      final preferencesResult = await _repository.getUserPreferences(
        bookingData.userId,
      );
      if (preferencesResult.isLeft()) return preferencesResult;
      
      final preferences = preferencesResult.getOrElse(() => 
          throw Exception('Preferences is null'));
      
      if (!preferences.bookingReminders) {
        return const Right(null);
      }
      
      // Create push notification for 1-hour reminder (more urgent)
      if (preferences.pushEnabled) {
        final request = NotificationRequest(
          userId: bookingData.userId,
          bookingId: bookingId,
          type: NotificationType.bookingReminder1h,
          channel: NotificationChannel.push,
          title: preferences.languagePreference == 'da'
              ? 'Din kok ankommer snart!'
              : 'Your chef is arriving soon!',
          content: preferences.languagePreference == 'da'
              ? 'Din madoplevelse med ${bookingData.chefName} starter om 1 time'
              : 'Your dining experience with ${bookingData.chefName} starts in 1 hour',
          scheduledAt: reminderTime,
          data: bookingData.toNotificationData(),
        );
        
        final result = await _repository.createNotification(request);
        if (result.isLeft()) return result;
        
        final notification = result.getOrElse(() => 
            throw Exception('Notification is null'));
        
        await _repository.scheduleNotification(
          notification.id,
          reminderTime,
        );
      }
      
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to schedule 1h reminder: $e'));
    }
  }
  
  @override
  Future<Either<Failure, void>> sendCompletionReview(String bookingId) async {
    try {
      final bookingResult = await _getBookingData(bookingId);
      if (bookingResult.isLeft()) return bookingResult;
      
      final bookingData = bookingResult.getOrElse(() => 
          throw Exception('Booking data is null'));
      
      // Wait 2 hours after booking completion to send review request
      final reviewTime = bookingData.dateTime.add(
        Duration(hours: bookingData.durationHours + 2),
      );
      
      final preferencesResult = await _repository.getUserPreferences(
        bookingData.userId,
      );
      if (preferencesResult.isLeft()) return preferencesResult;
      
      final preferences = preferencesResult.getOrElse(() => 
          throw Exception('Preferences is null'));
      
      final notifications = <NotificationRequest>[];
      
      // Email review request
      if (preferences.emailEnabled) {
        notifications.add(NotificationRequest(
          userId: bookingData.userId,
          bookingId: bookingId,
          type: NotificationType.bookingCompletion,
          channel: NotificationChannel.email,
          title: preferences.languagePreference == 'da'
              ? 'Hvordan var din madoplevelse?'
              : 'How was your dining experience?',
          content: _buildReviewContent(bookingData, preferences),
          templateId: 'booking_complete_review',
          scheduledAt: reviewTime,
          data: bookingData.toNotificationData(),
        ));
      }
      
      // Push notification for review
      if (preferences.pushEnabled) {
        notifications.add(NotificationRequest(
          userId: bookingData.userId,
          bookingId: bookingId,
          type: NotificationType.bookingCompletion,
          channel: NotificationChannel.push,
          title: preferences.languagePreference == 'da'
              ? 'Bedøm din oplevelse'
              : 'Rate your experience',
          content: preferences.languagePreference == 'da'
              ? 'Hvordan var din madoplevelse med ${bookingData.chefName}?'
              : 'How was your dining experience with ${bookingData.chefName}?',
          scheduledAt: reviewTime,
          data: bookingData.toNotificationData(),
        ));
      }
      
      // Create and schedule notifications
      for (final request in notifications) {
        final result = await _repository.createNotification(request);
        if (result.isLeft()) return result;
        
        final notification = result.getOrElse(() => 
            throw Exception('Notification is null'));
        
        await _repository.scheduleNotification(
          notification.id,
          reviewTime,
        );
      }
      
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to send completion review: $e'));
    }
  }
  
  @override
  Future<Either<Failure, void>> sendBookingModification(
    String bookingId,
    Map<String, dynamic> changes,
  ) async {
    try {
      final bookingResult = await _getBookingData(bookingId);
      if (bookingResult.isLeft()) return bookingResult;
      
      final bookingData = bookingResult.getOrElse(() => 
          throw Exception('Booking data is null'));
      
      final preferencesResult = await _repository.getUserPreferences(
        bookingData.userId,
      );
      if (preferencesResult.isLeft()) return preferencesResult;
      
      final preferences = preferencesResult.getOrElse(() => 
          throw Exception('Preferences is null'));
      
      if (!preferences.bookingUpdates) {
        return const Right(null);
      }
      
      final notifications = <NotificationRequest>[];
      
      final changesText = _buildChangesText(changes, preferences);
      
      if (preferences.emailEnabled) {
        notifications.add(NotificationRequest(
          userId: bookingData.userId,
          bookingId: bookingId,
          type: NotificationType.bookingModified,
          channel: NotificationChannel.email,
          title: preferences.languagePreference == 'da'
              ? 'Din booking er blevet opdateret'
              : 'Your booking has been updated',
          content: changesText,
          templateId: 'booking_modified',
          data: {...bookingData.toNotificationData(), 'changes': changes},
        ));
      }
      
      if (preferences.pushEnabled) {
        notifications.add(NotificationRequest(
          userId: bookingData.userId,
          bookingId: bookingId,
          type: NotificationType.bookingModified,
          channel: NotificationChannel.push,
          title: preferences.languagePreference == 'da'
              ? 'Booking opdateret'
              : 'Booking updated',
          content: preferences.languagePreference == 'da'
              ? 'Din booking med ${bookingData.chefName} er blevet ændret'
              : 'Your booking with ${bookingData.chefName} has been modified',
          data: {...bookingData.toNotificationData(), 'changes': changes},
        ));
      }
      
      // Send notifications immediately
      for (final request in notifications) {
        await _repository.createNotification(request);
      }
      
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to send booking modification: $e'));
    }
  }
  
  @override
  Future<Either<Failure, void>> sendCancellationNotice(
    String bookingId,
    String reason,
  ) async {
    try {
      final bookingResult = await _getBookingData(bookingId);
      if (bookingResult.isLeft()) return bookingResult;
      
      final bookingData = bookingResult.getOrElse(() => 
          throw Exception('Booking data is null'));
      
      final preferencesResult = await _repository.getUserPreferences(
        bookingData.userId,
      );
      if (preferencesResult.isLeft()) return preferencesResult;
      
      final preferences = preferencesResult.getOrElse(() => 
          throw Exception('Preferences is null'));
      
      if (!preferences.bookingUpdates) {
        return const Right(null);
      }
      
      final notifications = <NotificationRequest>[];
      
      if (preferences.emailEnabled) {
        notifications.add(NotificationRequest(
          userId: bookingData.userId,
          bookingId: bookingId,
          type: NotificationType.bookingCancelled,
          channel: NotificationChannel.email,
          title: preferences.languagePreference == 'da'
              ? 'Din booking er blevet aflyst'
              : 'Your booking has been cancelled',
          content: _buildCancellationContent(
            bookingData, 
            reason, 
            preferences,
          ),
          templateId: 'booking_cancelled',
          data: {
            ...bookingData.toNotificationData(), 
            'cancellation_reason': reason,
          },
        ));
      }
      
      if (preferences.pushEnabled) {
        notifications.add(NotificationRequest(
          userId: bookingData.userId,
          bookingId: bookingId,
          type: NotificationType.bookingCancelled,
          channel: NotificationChannel.push,
          title: preferences.languagePreference == 'da'
              ? 'Booking aflyst'
              : 'Booking cancelled',
          content: preferences.languagePreference == 'da'
              ? 'Din booking med ${bookingData.chefName} er blevet aflyst'
              : 'Your booking with ${bookingData.chefName} has been cancelled',
          data: {
            ...bookingData.toNotificationData(), 
            'cancellation_reason': reason,
          },
        ));
      }
      
      // Send notifications immediately
      for (final request in notifications) {
        await _repository.createNotification(request);
      }
      
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to send cancellation notice: $e'));
    }
  }
  
  @override
  Future<Either<Failure, void>> handleRecurringNotifications(
    String seriesId,
  ) async {
    try {
      // Get recurring notification settings for this series
      final recurringResult = await _repository.getRecurringNotifications(
        seriesId,
      );
      if (recurringResult.isLeft()) return recurringResult;
      
      final recurringNotifications = recurringResult.getOrElse(() => []);
      
      // Process each pending recurring notification
      for (final recurring in recurringNotifications) {
        if (recurring.isSent) continue;
        
        // Check if it's time to send this notification (24h before occurrence)
        final notificationTime = recurring.occurrenceDate.subtract(
          const Duration(hours: 24),
        );
        
        if (notificationTime.isBefore(DateTime.now()) &&
            notificationTime.isAfter(
              DateTime.now().subtract(const Duration(hours: 1)),
            )) {
          // Send the notification
          if (recurring.bookingId != null) {
            switch (recurring.notificationType) {
              case NotificationType.bookingReminder24h:
                await schedule24HourReminder(recurring.bookingId!);
                break;
              case NotificationType.bookingConfirmation:
                await sendBookingConfirmation(
                  recurring.bookingId!,
                  RecipientType.user,
                );
                break;
              default:
                break;
            }
            
            // Mark as sent
            await _repository.markRecurringNotificationSent(recurring.id);
          }
        }
      }
      
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to handle recurring notifications: $e'));
    }
  }
  
  @override
  Future<Either<Failure, void>> sendInAppMessage(
    String bookingId,
    String fromUserId,
    String toUserId,
    String message,
  ) async {
    try {
      // Get recipient preferences
      final preferencesResult = await _repository.getUserPreferences(toUserId);
      if (preferencesResult.isLeft()) return preferencesResult;
      
      final preferences = preferencesResult.getOrElse(() => 
          throw Exception('Preferences is null'));
      
      // Send push notification for new message if enabled
      if (preferences.pushEnabled) {
        final request = NotificationRequest(
          userId: toUserId,
          bookingId: bookingId,
          type: NotificationType.chefMessage,
          channel: NotificationChannel.push,
          title: preferences.languagePreference == 'da'
              ? 'Ny besked'
              : 'New message',
          content: preferences.languagePreference == 'da'
              ? 'Du har modtaget en ny besked om din booking'
              : 'You have received a new message about your booking',
          data: {
            'booking_id': bookingId,
            'from_user_id': fromUserId,
            'message_preview': message.length > 50 
                ? '${message.substring(0, 50)}...'
                : message,
          },
        );
        
        await _repository.createNotification(request);
      }
      
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to send in-app message: $e'));
    }
  }
  
  @override
  Future<Either<Failure, void>> processNotificationQueue() async {
    try {
      final pendingResult = await _repository.getPendingNotifications();
      if (pendingResult.isLeft()) return pendingResult;
      
      final pendingNotifications = pendingResult.getOrElse(() => []);
      
      for (final notification in pendingNotifications) {
        // Check if scheduled time has arrived
        if (notification.scheduledAt != null &&
            notification.scheduledAt!.isAfter(DateTime.now())) {
          continue; // Not yet time to send
        }
        
        // Update status to processing
        await _repository.updateNotificationStatus(
          notification.id,
          NotificationStatus.processing,
        );
        
        // Process based on channel
        switch (notification.channel) {
          case NotificationChannel.email:
            await _processEmailNotification(notification);
            break;
          case NotificationChannel.push:
            await _processPushNotification(notification);
            break;
          case NotificationChannel.inApp:
            await _processInAppNotification(notification);
            break;
          case NotificationChannel.sms:
            await _processSmsNotification(notification);
            break;
        }
      }
      
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to process notification queue: $e'));
    }
  }
  
  @override
  Future<Either<Failure, void>> retryFailedNotifications() async {
    try {
      final pendingResult = await _repository.getPendingNotifications();
      if (pendingResult.isLeft()) return pendingResult;
      
      final failedNotifications = pendingResult
          .getOrElse(() => [])
          .where((n) => n.status == NotificationStatus.failed && 
                       n.retryCount < n.maxRetries)
          .toList();
      
      for (final notification in failedNotifications) {
        // Reset status to pending for retry
        await _repository.updateNotificationStatus(
          notification.id,
          NotificationStatus.pending,
        );
      }
      
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to retry failed notifications: $e'));
    }
  }
  
  // Private helper methods
  
  Future<Either<Failure, BookingNotificationData>> _getBookingData(
    String bookingId,
  ) async {
    // This would typically call a booking repository/service
    // For now, return a mock implementation
    try {
      // Mock booking data - in real implementation, this would fetch from database
      return Right(BookingNotificationData(
        bookingId: bookingId,
        userId: 'user-123',
        chefId: 'chef-456',
        chefName: 'John Doe',
        userName: 'Jane Smith',
        dateTime: DateTime.now().add(const Duration(days: 1)),
        guestCount: 4,
        address: 'København, Denmark',
        durationHours: 3,
      ));
    } catch (e) {
      return Left(ServerFailure('Failed to get booking data: $e'));
    }
  }
  
  Future<Either<Failure, void>> _sendUserBookingConfirmation(
    BookingNotificationData bookingData,
  ) async {
    final preferencesResult = await _repository.getUserPreferences(
      bookingData.userId,
    );
    if (preferencesResult.isLeft()) return preferencesResult;
    
    final preferences = preferencesResult.getOrElse(() => 
        throw Exception('Preferences is null'));
    
    final notifications = <NotificationRequest>[];
    
    if (preferences.emailEnabled && preferences.bookingConfirmations) {
      notifications.add(NotificationRequest(
        userId: bookingData.userId,
        bookingId: bookingData.bookingId,
        type: NotificationType.bookingConfirmation,
        channel: NotificationChannel.email,
        title: preferences.languagePreference == 'da'
            ? 'Din booking er bekræftet!'
            : 'Your booking is confirmed!',
        content: _buildConfirmationContent(bookingData, preferences),
        templateId: 'booking_confirmation_user',
        data: bookingData.toNotificationData(),
      ));
    }
    
    if (preferences.pushEnabled && preferences.bookingConfirmations) {
      notifications.add(NotificationRequest(
        userId: bookingData.userId,
        bookingId: bookingData.bookingId,
        type: NotificationType.bookingConfirmation,
        channel: NotificationChannel.push,
        title: preferences.languagePreference == 'da'
            ? 'Booking bekræftet!'
            : 'Booking confirmed!',
        content: preferences.languagePreference == 'da'
            ? 'Din madoplevelse med ${bookingData.chefName} er bekræftet'
            : 'Your dining experience with ${bookingData.chefName} is confirmed',
        data: bookingData.toNotificationData(),
      ));
    }
    
    // Send notifications immediately
    for (final request in notifications) {
      await _repository.createNotification(request);
    }
    
    return const Right(null);
  }
  
  Future<Either<Failure, void>> _sendChefBookingConfirmation(
    BookingNotificationData bookingData,
  ) async {
    // Get chef's user ID and preferences
    // This would typically involve fetching chef details
    
    final notifications = <NotificationRequest>[];
    
    // For now, assume chef wants email notifications in Danish
    notifications.add(NotificationRequest(
      userId: bookingData.chefId,
      bookingId: bookingData.bookingId,
      type: NotificationType.bookingConfirmation,
      channel: NotificationChannel.email,
      title: 'Ny booking bekræftet!',
      content: _buildChefConfirmationContent(bookingData),
      templateId: 'booking_confirmation_chef',
      data: bookingData.toNotificationData(),
    ));
    
    // Send notifications immediately
    for (final request in notifications) {
      await _repository.createNotification(request);
    }
    
    return const Right(null);
  }
  
  String _buildConfirmationContent(
    BookingNotificationData data,
    NotificationPreferences preferences,
  ) {
    if (preferences.languagePreference == 'da') {
      return 'Din booking med ${data.chefName} er bekræftet for ${data.dateTime.day}/${data.dateTime.month} kl. ${data.dateTime.hour}:${data.dateTime.minute.toString().padLeft(2, '0')}.';
    } else {
      return 'Your booking with ${data.chefName} is confirmed for ${data.dateTime.day}/${data.dateTime.month} at ${data.dateTime.hour}:${data.dateTime.minute.toString().padLeft(2, '0')}.';
    }
  }
  
  String _buildChefConfirmationContent(BookingNotificationData data) {
    return 'Du har fået en ny booking fra ${data.userName} for ${data.dateTime.day}/${data.dateTime.month} kl. ${data.dateTime.hour}:${data.dateTime.minute.toString().padLeft(2, '0')}.';
  }
  
  String _buildReminderContent(
    BookingNotificationData data,
    NotificationPreferences preferences,
  ) {
    if (preferences.languagePreference == 'da') {
      return 'Påmindelse: Din madoplevelse med ${data.chefName} er i morgen kl. ${data.dateTime.hour}:${data.dateTime.minute.toString().padLeft(2, '0')}.';
    } else {
      return 'Reminder: Your dining experience with ${data.chefName} is tomorrow at ${data.dateTime.hour}:${data.dateTime.minute.toString().padLeft(2, '0')}.';
    }
  }
  
  String _buildReminderPushContent(
    BookingNotificationData data,
    NotificationPreferences preferences,
  ) {
    if (preferences.languagePreference == 'da') {
      return 'I morgen kl. ${data.dateTime.hour}:${data.dateTime.minute.toString().padLeft(2, '0')} med ${data.chefName}';
    } else {
      return 'Tomorrow at ${data.dateTime.hour}:${data.dateTime.minute.toString().padLeft(2, '0')} with ${data.chefName}';
    }
  }
  
  String _buildReviewContent(
    BookingNotificationData data,
    NotificationPreferences preferences,
  ) {
    if (preferences.languagePreference == 'da') {
      return 'Hvordan var din madoplevelse med ${data.chefName}? Vi ville være taknemmelige for din feedback.';
    } else {
      return 'How was your dining experience with ${data.chefName}? We would appreciate your feedback.';
    }
  }
  
  String _buildChangesText(
    Map<String, dynamic> changes,
    NotificationPreferences preferences,
  ) {
    // Build a human-readable description of changes
    final changesText = StringBuffer();
    
    if (preferences.languagePreference == 'da') {
      changesText.write('Følgende ændringer er blevet foretaget til din booking:\n');
    } else {
      changesText.write('The following changes have been made to your booking:\n');
    }
    
    changes.forEach((key, value) {
      if (preferences.languagePreference == 'da') {
        changesText.write('• ${_translateFieldToDanish(key)}: $value\n');
      } else {
        changesText.write('• ${_translateFieldToEnglish(key)}: $value\n');
      }
    });
    
    return changesText.toString();
  }
  
  String _buildCancellationContent(
    BookingNotificationData data,
    String reason,
    NotificationPreferences preferences,
  ) {
    if (preferences.languagePreference == 'da') {
      return 'Din booking med ${data.chefName} er desværre blevet aflyst. Årsag: $reason';
    } else {
      return 'Your booking with ${data.chefName} has unfortunately been cancelled. Reason: $reason';
    }
  }
  
  String _translateFieldToDanish(String field) {
    switch (field.toLowerCase()) {
      case 'date':
      case 'datetime':
        return 'Dato';
      case 'time':
        return 'Tid';
      case 'guestcount':
      case 'guests':
        return 'Antal personer';
      case 'address':
        return 'Adresse';
      case 'price':
        return 'Pris';
      default:
        return field;
    }
  }
  
  String _translateFieldToEnglish(String field) {
    switch (field.toLowerCase()) {
      case 'date':
      case 'datetime':
        return 'Date';
      case 'time':
        return 'Time';
      case 'guestcount':
      case 'guests':
        return 'Number of guests';
      case 'address':
        return 'Address';
      case 'price':
        return 'Price';
      default:
        return field;
    }
  }
  
  // These methods would integrate with actual services (Postmark, OneSignal, etc.)
  Future<void> _processEmailNotification(NotificationEntity notification) async {
    final result = await _emailService.sendEmailNotification(notification);
    
    result.fold(
      (failure) async {
        await _repository.updateNotificationStatus(
          notification.id,
          NotificationStatus.failed,
          failureReason: failure.message,
        );
      },
      (_) async {
        await _repository.updateNotificationStatus(
          notification.id,
          NotificationStatus.sent,
        );
      },
    );
  }
  
  Future<void> _processPushNotification(NotificationEntity notification) async {
    final result = await _pushService.sendPushNotification(notification);
    
    result.fold(
      (failure) async {
        await _repository.updateNotificationStatus(
          notification.id,
          NotificationStatus.failed,
          failureReason: failure.message,
        );
      },
      (_) async {
        await _repository.updateNotificationStatus(
          notification.id,
          NotificationStatus.sent,
        );
      },
    );
  }
  
  Future<void> _processInAppNotification(NotificationEntity notification) async {
    // For in-app notifications, just mark as sent since they're stored in DB
    await _repository.updateNotificationStatus(
      notification.id,
      NotificationStatus.sent,
    );
  }
  
  Future<void> _processSmsNotification(NotificationEntity notification) async {
    // SMS not implemented yet
    await _repository.updateNotificationStatus(
      notification.id,
      NotificationStatus.failed,
      failureReason: 'SMS notifications not implemented',
    );
  }
}