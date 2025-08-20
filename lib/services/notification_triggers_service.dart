import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service for triggering push notifications through OneSignal
class NotificationTriggersService {
  static final NotificationTriggersService _instance = NotificationTriggersService._internal();
  factory NotificationTriggersService() => _instance;
  NotificationTriggersService._internal();

  static NotificationTriggersService get instance => _instance;

  final String _oneSignalAppId = dotenv.env['ONESIGNAL_APP_ID'] ?? '';
  final String _oneSignalRestApiKey = dotenv.env['ONESIGNAL_REST_API_KEY'] ?? '';
  
  static const String _oneSignalApiUrl = 'https://onesignal.com/api/v1/notifications';

  /// Send a push notification to a specific user
  Future<bool> sendNotification({
    required String userId,
    required String title,
    required String message,
    Map<String, dynamic>? additionalData,
    String? imageUrl,
    List<Map<String, String>>? buttons,
    DateTime? sendAfter,
  }) async {
    try {
      final body = {
        'app_id': _oneSignalAppId,
        'include_external_user_ids': [userId],
        'headings': {'en': title, 'da': title},
        'contents': {'en': message, 'da': message},
        'data': additionalData ?? {},
      };

      // Add image if provided
      if (imageUrl != null) {
        body['big_picture'] = imageUrl;
        body['ios_attachments'] = {'id1': imageUrl};
      }

      // Add buttons if provided
      if (buttons != null && buttons.isNotEmpty) {
        body['buttons'] = buttons;
      }

      // Schedule notification if sendAfter is provided
      if (sendAfter != null) {
        body['send_after'] = sendAfter.toUtc().toIso8601String();
      }

      final response = await http.post(
        Uri.parse(_oneSignalApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $_oneSignalRestApiKey',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        debugPrint('Notification sent successfully: ${response.body}');
        return true;
      } else {
        debugPrint('Failed to send notification: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending notification: $e');
      return false;
    }
  }

  /// Send booking confirmation notification to user
  Future<bool> sendBookingConfirmationToUser({
    required String userId,
    required String chefName,
    required String bookingDate,
    required String bookingTime,
    required String bookingId,
  }) async {
    return await sendNotification(
      userId: userId,
      title: '🎉 Booking Bekræftet!',
      message: '$chefName har bekræftet din booking for $bookingDate kl. $bookingTime',
      additionalData: {
        'type': 'booking_confirmed',
        'booking_id': bookingId,
        'screen': 'booking_details',
      },
    );
  }

  /// Send 24-hour reminder notification
  Future<bool> schedule24HourReminder({
    required String userId,
    required String chefName,
    required String bookingTime,
    required String bookingId,
    required DateTime bookingDateTime,
  }) async {
    // Calculate 24 hours before booking
    final reminderTime = bookingDateTime.subtract(const Duration(hours: 24));
    
    // Only schedule if reminder time is in the future
    if (reminderTime.isAfter(DateTime.now())) {
      return await sendNotification(
        userId: userId,
        title: '⏰ Påmindelse: Booking i morgen',
        message: 'Din booking med $chefName er i morgen kl. $bookingTime',
        additionalData: {
          'type': 'booking_reminder',
          'booking_id': bookingId,
          'screen': 'booking_details',
        },
        sendAfter: reminderTime,
      );
    }
    return false;
  }

  /// Send rating request notification after booking completion
  Future<bool> sendRatingRequest({
    required String userId,
    required String chefName,
    required String bookingId,
    int delayMinutes = 15,
  }) async {
    // Schedule for 15 minutes after completion
    final sendTime = DateTime.now().add(Duration(minutes: delayMinutes));
    
    return await sendNotification(
      userId: userId,
      title: '⭐ Hvordan var din oplevelse?',
      message: 'Bedøm din oplevelse med $chefName og hjælp andre brugere',
      additionalData: {
        'type': 'rating_request',
        'booking_id': bookingId,
        'screen': 'rate_booking',
      },
      buttons: [
        {'id': 'rate_now', 'text': 'Bedøm Nu'},
        {'id': 'later', 'text': 'Senere'},
      ],
      sendAfter: sendTime,
    );
  }

  /// Send new message notification
  Future<bool> sendNewMessageNotification({
    required String userId,
    required String senderName,
    required String messagePreview,
    required String conversationId,
    String? senderImageUrl,
  }) async {
    return await sendNotification(
      userId: userId,
      title: '💬 Ny besked fra $senderName',
      message: messagePreview,
      additionalData: {
        'type': 'new_message',
        'conversation_id': conversationId,
        'screen': 'messages',
      },
      imageUrl: senderImageUrl,
    );
  }

  /// Send booking cancellation notification
  Future<bool> sendBookingCancellationNotification({
    required String userId,
    required String chefName,
    required String bookingDate,
    required String reason,
    required String bookingId,
  }) async {
    return await sendNotification(
      userId: userId,
      title: '❌ Booking Aflyst',
      message: 'Din booking med $chefName den $bookingDate er blevet aflyst. Årsag: $reason',
      additionalData: {
        'type': 'booking_cancelled',
        'booking_id': bookingId,
        'screen': 'bookings',
      },
    );
  }

  /// Send booking update notification
  Future<bool> sendBookingUpdateNotification({
    required String userId,
    required String chefName,
    required String updateMessage,
    required String bookingId,
  }) async {
    return await sendNotification(
      userId: userId,
      title: '📝 Booking Opdateret',
      message: 'Din booking med $chefName er blevet opdateret: $updateMessage',
      additionalData: {
        'type': 'booking_updated',
        'booking_id': bookingId,
        'screen': 'booking_details',
      },
    );
  }

  /// Send chef arrival notification
  Future<bool> sendChefArrivalNotification({
    required String userId,
    required String chefName,
    required String bookingId,
  }) async {
    return await sendNotification(
      userId: userId,
      title: '👨‍🍳 Kokken er ankommet!',
      message: '$chefName er ankommet og begynder at forberede din mad',
      additionalData: {
        'type': 'chef_arrived',
        'booking_id': bookingId,
        'screen': 'booking_details',
      },
    );
  }

  /// Send promotional notification
  Future<bool> sendPromotionalNotification({
    required List<String> userIds,
    required String title,
    required String message,
    String? imageUrl,
    String? actionUrl,
  }) async {
    try {
      final body = {
        'app_id': _oneSignalAppId,
        'include_external_user_ids': userIds,
        'headings': {'en': title, 'da': title},
        'contents': {'en': message, 'da': message},
        'data': {
          'type': 'promotional',
          'action_url': actionUrl ?? '',
        },
      };

      if (imageUrl != null) {
        body['big_picture'] = imageUrl;
        body['ios_attachments'] = {'id1': imageUrl};
      }

      final response = await http.post(
        Uri.parse(_oneSignalApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $_oneSignalRestApiKey',
        },
        body: json.encode(body),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error sending promotional notification: $e');
      return false;
    }
  }

  /// Cancel a scheduled notification
  Future<bool> cancelScheduledNotification(String notificationId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_oneSignalApiUrl/$notificationId?app_id=$_oneSignalAppId'),
        headers: {
          'Authorization': 'Basic $_oneSignalRestApiKey',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error canceling notification: $e');
      return false;
    }
  }
}