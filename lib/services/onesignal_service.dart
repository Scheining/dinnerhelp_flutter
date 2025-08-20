import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class OneSignalService {
  static final OneSignalService _instance = OneSignalService._internal();
  factory OneSignalService() => _instance;
  OneSignalService._internal();

  static OneSignalService get instance => _instance;

  /// Initialize OneSignal with the provided App ID
  Future<void> initialize(String appId) async {
    try {
      // Enable verbose logging for debugging (remove in production)
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      
      // Initialize OneSignal
      OneSignal.initialize(appId);
      
      debugPrint('OneSignal initialized successfully');
      
      // Set up notification listeners
      _setupNotificationListeners();
      
    } catch (e) {
      debugPrint('OneSignal initialization failed: $e');
    }
  }

  /// Request permission for push notifications
  Future<bool> requestPermission() async {
    try {
      return await OneSignal.Notifications.requestPermission(true);
    } catch (e) {
      debugPrint('OneSignal permission request failed: $e');
      return false;
    }
  }

  /// Set external user ID for user identification
  Future<void> setExternalUserId(String externalUserId) async {
    try {
      await OneSignal.login(externalUserId);
      debugPrint('OneSignal external user ID set: $externalUserId');
    } catch (e) {
      debugPrint('OneSignal set external user ID failed: $e');
    }
  }

  /// Remove external user ID (logout)
  Future<void> removeExternalUserId() async {
    try {
      await OneSignal.logout();
      debugPrint('OneSignal external user ID removed');
    } catch (e) {
      debugPrint('OneSignal remove external user ID failed: $e');
    }
  }

  /// Add email subscription
  Future<void> setEmail(String email) async {
    try {
      await OneSignal.User.addEmail(email);
      debugPrint('OneSignal email set: $email');
    } catch (e) {
      debugPrint('OneSignal set email failed: $e');
    }
  }

  /// Add SMS subscription
  Future<void> setSms(String phoneNumber) async {
    try {
      await OneSignal.User.addSms(phoneNumber);
      debugPrint('OneSignal SMS set: $phoneNumber');
    } catch (e) {
      debugPrint('OneSignal set SMS failed: $e');
    }
  }

  /// Add tags for user segmentation
  Future<void> setTags(Map<String, String> tags) async {
    try {
      await OneSignal.User.addTags(tags);
      debugPrint('OneSignal tags set: $tags');
    } catch (e) {
      debugPrint('OneSignal set tags failed: $e');
    }
  }

  /// Add a single tag
  Future<void> setTag(String key, String value) async {
    try {
      await OneSignal.User.addTagWithKey(key, value);
      debugPrint('OneSignal tag set: $key = $value');
    } catch (e) {
      debugPrint('OneSignal set tag failed: $e');
    }
  }

  /// Remove tags
  Future<void> removeTags(List<String> keys) async {
    try {
      await OneSignal.User.removeTags(keys);
      debugPrint('OneSignal tags removed: $keys');
    } catch (e) {
      debugPrint('OneSignal remove tags failed: $e');
    }
  }

  /// Get the OneSignal subscription ID
  String? getSubscriptionId() {
    try {
      return OneSignal.User.pushSubscription.id;
    } catch (e) {
      debugPrint('OneSignal get subscription ID failed: $e');
      return null;
    }
  }

  /// Get the OneSignal user ID
  String? getOneSignalId() {
    try {
      return OneSignal.User.onesignalId;
    } catch (e) {
      debugPrint('OneSignal get user ID failed: $e');
      return null;
    }
  }

  /// Check if user has granted notification permission
  bool hasNotificationPermission() {
    try {
      return OneSignal.User.pushSubscription.optedIn;
    } catch (e) {
      debugPrint('OneSignal check permission failed: $e');
      return false;
    }
  }

  /// Set up notification event listeners
  void _setupNotificationListeners() {
    // Notification click listener
    OneSignal.Notifications.addClickListener((event) {
      debugPrint('OneSignal notification clicked: ${event.notification.notificationId}');
      _handleNotificationClick(event);
    });

    // Notification foreground listener
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      debugPrint('OneSignal notification will display in foreground: ${event.notification.notificationId}');
      // You can modify the notification here before it's displayed
      event.preventDefault(); // Remove this if you want to display the notification
    });

    // Permission observer
    OneSignal.Notifications.addPermissionObserver((state) {
      debugPrint('OneSignal permission changed: $state');
    });

    // User state observer
    OneSignal.User.addObserver((state) {
      debugPrint('OneSignal user state changed: ${state.current.onesignalId}');
    });

    // Push subscription observer
    OneSignal.User.pushSubscription.addObserver((state) {
      debugPrint('OneSignal push subscription changed: ${state.current.optedIn}');
    });
  }

  /// Handle notification click events
  void _handleNotificationClick(OSNotificationClickEvent event) {
    final notification = event.notification;
    final additionalData = notification.additionalData;
    
    debugPrint('Notification clicked with data: $additionalData');
    
    // Handle different notification types based on additional data
    if (additionalData != null) {
      final type = additionalData['type'] as String?;
      final id = additionalData['id'] as String?;
      
      switch (type) {
        case 'booking':
          _navigateToBooking(id);
          break;
        case 'message':
          _navigateToMessages(id);
          break;
        case 'chef_profile':
          _navigateToChefProfile(id);
          break;
        default:
          _navigateToHome();
          break;
      }
    } else {
      _navigateToHome();
    }
  }

  /// Navigation helpers (these would integrate with your router)
  void _navigateToBooking(String? bookingId) {
    debugPrint('Navigate to booking: $bookingId');
    // TODO: Implement navigation to booking screen
    // Example: router.go('/bookings/$bookingId');
  }

  void _navigateToMessages(String? messageId) {
    debugPrint('Navigate to messages: $messageId');
    // TODO: Implement navigation to messages screen
    // Example: router.go('/messages');
  }

  void _navigateToChefProfile(String? chefId) {
    debugPrint('Navigate to chef profile: $chefId');
    // TODO: Implement navigation to chef profile screen
    // Example: router.go('/chef/$chefId');
  }

  void _navigateToHome() {
    debugPrint('Navigate to home');
    // TODO: Implement navigation to home screen
    // Example: router.go('/');
  }
}