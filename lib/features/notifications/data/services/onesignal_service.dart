import 'package:dartz/dartz.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:homechef/core/error/failures.dart';
import '../../domain/entities/notification.dart';

abstract class PushNotificationService {
  Future<Either<Failure, void>> initialize();
  Future<Either<Failure, String?>> getDeviceToken();
  Future<Either<Failure, void>> registerDevice(String userId, String token);
  Future<Either<Failure, void>> unregisterDevice(String token);
  Future<Either<Failure, void>> sendPushNotification(NotificationEntity notification);
  Future<Either<Failure, void>> sendToUser(String userId, String title, String message, Map<String, dynamic>? data);
  Future<Either<Failure, void>> sendToMultipleUsers(List<String> userIds, String title, String message, Map<String, dynamic>? data);
}

class OneSignalService implements PushNotificationService {
  static const String _baseUrl = 'https://onesignal.com/api/v1';
  final String _appId;
  final String _apiKey;
  final http.Client _httpClient;
  
  OneSignalService({
    required String appId,
    required String apiKey,
    http.Client? httpClient,
  }) : _appId = appId,
       _apiKey = apiKey,
       _httpClient = httpClient ?? http.Client();

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      // Initialize OneSignal SDK
      // In a real implementation, this would call OneSignal.shared.setAppId(_appId)
      // and set up notification handlers
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to initialize OneSignal: $e'));
    }
  }

  @override
  Future<Either<Failure, String?>> getDeviceToken() async {
    try {
      // In a real implementation, this would call OneSignal.shared.getDeviceState()
      // and return the player ID
      return const Right('mock-device-token');
    } catch (e) {
      return Left(ServerFailure('Failed to get device token: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> registerDevice(String userId, String token) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/players'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $_apiKey',
        },
        body: json.encode({
          'app_id': _appId,
          'identifier': token,
          'external_user_id': userId,
          'device_type': _getDeviceType(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return const Right(null);
      } else {
        return Left(ServerFailure('Failed to register device: ${response.body}'));
      }
    } catch (e) {
      return Left(ServerFailure('Failed to register device: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> unregisterDevice(String token) async {
    try {
      // In OneSignal, we typically just mark the device as inactive
      final response = await _httpClient.put(
        Uri.parse('$_baseUrl/players/$token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $_apiKey',
        },
        body: json.encode({
          'app_id': _appId,
          'session_count': 0,
          'active': false,
        }),
      );

      if (response.statusCode == 200) {
        return const Right(null);
      } else {
        return Left(ServerFailure('Failed to unregister device: ${response.body}'));
      }
    } catch (e) {
      return Left(ServerFailure('Failed to unregister device: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendPushNotification(NotificationEntity notification) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $_apiKey',
        },
        body: json.encode({
          'app_id': _appId,
          'filters': [
            {
              'field': 'external_user_id',
              'relation': '=',
              'value': notification.userId,
            }
          ],
          'headings': {
            'en': notification.title,
            'da': notification.title,
          },
          'contents': {
            'en': notification.content,
            'da': notification.content,
          },
          'data': notification.data,
          'url': _buildDeepLinkUrl(notification),
          'ios_badgeType': 'Increase',
          'ios_badgeCount': 1,
          'android_accent_color': 'FF2E7D32',
          'small_icon': 'ic_stat_dinnerhelp',
          'large_icon': 'ic_notification_large',
        }),
      );

      if (response.statusCode == 200) {
        return const Right(null);
      } else {
        return Left(ServerFailure('Failed to send push notification: ${response.body}'));
      }
    } catch (e) {
      return Left(ServerFailure('Failed to send push notification: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendToUser(
    String userId, 
    String title, 
    String message, 
    Map<String, dynamic>? data,
  ) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $_apiKey',
        },
        body: json.encode({
          'app_id': _appId,
          'filters': [
            {
              'field': 'external_user_id',
              'relation': '=',
              'value': userId,
            }
          ],
          'headings': {
            'en': title,
            'da': title,
          },
          'contents': {
            'en': message,
            'da': message,
          },
          'data': data ?? {},
          'ios_badgeType': 'Increase',
          'ios_badgeCount': 1,
          'android_accent_color': 'FF2E7D32',
          'small_icon': 'ic_stat_dinnerhelp',
        }),
      );

      if (response.statusCode == 200) {
        return const Right(null);
      } else {
        return Left(ServerFailure('Failed to send notification to user: ${response.body}'));
      }
    } catch (e) {
      return Left(ServerFailure('Failed to send notification to user: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendToMultipleUsers(
    List<String> userIds, 
    String title, 
    String message, 
    Map<String, dynamic>? data,
  ) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $_apiKey',
        },
        body: json.encode({
          'app_id': _appId,
          'filters': userIds.map((userId) => {
            'field': 'external_user_id',
            'relation': '=',
            'value': userId,
          }).toList(),
          'headings': {
            'en': title,
            'da': title,
          },
          'contents': {
            'en': message,
            'da': message,
          },
          'data': data ?? {},
          'ios_badgeType': 'Increase',
          'ios_badgeCount': 1,
          'android_accent_color': 'FF2E7D32',
          'small_icon': 'ic_stat_dinnerhelp',
        }),
      );

      if (response.statusCode == 200) {
        return const Right(null);
      } else {
        return Left(ServerFailure('Failed to send notification to users: ${response.body}'));
      }
    } catch (e) {
      return Left(ServerFailure('Failed to send notification to users: $e'));
    }
  }

  int _getDeviceType() {
    // Return device type based on platform
    // 0 = iOS, 1 = Android, 5 = Web
    // This would be determined by Platform.isIOS, Platform.isAndroid, etc.
    return 1; // Default to Android for now
  }

  String? _buildDeepLinkUrl(NotificationEntity notification) {
    if (notification.bookingId != null) {
      return 'dinnerhelp://booking/${notification.bookingId}';
    }
    
    switch (notification.type) {
      case NotificationType.chefMessage:
        return 'dinnerhelp://chat/${notification.bookingId ?? ''}';
      case NotificationType.bookingConfirmation:
      case NotificationType.bookingReminder24h:
      case NotificationType.bookingReminder1h:
      case NotificationType.bookingCompletion:
      case NotificationType.bookingModified:
      case NotificationType.bookingCancelled:
        return 'dinnerhelp://booking/${notification.bookingId ?? ''}';
      default:
        return 'dinnerhelp://home';
    }
  }
}

// Mock implementation for testing and development
class MockPushNotificationService implements PushNotificationService {
  final List<NotificationEntity> _sentNotifications = [];
  
  List<NotificationEntity> get sentNotifications => List.unmodifiable(_sentNotifications);
  
  void clearSentNotifications() {
    _sentNotifications.clear();
  }

  @override
  Future<Either<Failure, void>> initialize() async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, String?>> getDeviceToken() async {
    return const Right('mock-device-token-123');
  }

  @override
  Future<Either<Failure, void>> registerDevice(String userId, String token) async {
    // Mock registration
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> unregisterDevice(String token) async {
    // Mock unregistration
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> sendPushNotification(NotificationEntity notification) async {
    _sentNotifications.add(notification);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> sendToUser(
    String userId, 
    String title, 
    String message, 
    Map<String, dynamic>? data,
  ) async {
    _sentNotifications.add(NotificationEntity(
      id: 'mock-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      type: NotificationType.chefMessage,
      channel: NotificationChannel.push,
      title: title,
      content: message,
      data: data ?? {},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> sendToMultipleUsers(
    List<String> userIds, 
    String title, 
    String message, 
    Map<String, dynamic>? data,
  ) async {
    for (final userId in userIds) {
      await sendToUser(userId, title, message, data);
    }
    return const Right(null);
  }
}