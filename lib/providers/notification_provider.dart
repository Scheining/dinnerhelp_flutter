import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:homechef/services/onesignal_service.dart';
import 'package:homechef/providers/auth_provider.dart';

part 'notification_provider.g.dart';

@riverpod
class NotificationNotifier extends _$NotificationNotifier {
  @override
  Future<bool> build() async {
    // Listen to auth state changes
    ref.listen(currentUserProvider, (previous, next) {
      next.whenData((user) {
        if (user != null) {
          // Set external user ID when user logs in
          OneSignalService.instance.setExternalUserId(user.id);
          
          // Set user email for email notifications
          if (user.email != null) {
            OneSignalService.instance.setEmail(user.email!);
          }
          
          // Set basic user tags
          OneSignalService.instance.setTags({
            'user_id': user.id,
            'user_email': user.email ?? '',
            'app_version': '1.0.0',
          });
        } else {
          // Remove external user ID when user logs out
          OneSignalService.instance.removeExternalUserId();
        }
      });
    });
    
    return OneSignalService.instance.hasNotificationPermission();
  }

  /// Request notification permission
  Future<bool> requestPermission() async {
    final hasPermission = await OneSignalService.instance.requestPermission();
    state = AsyncValue.data(hasPermission);
    return hasPermission;
  }

  /// Set user tags for segmentation
  Future<void> setUserTags(Map<String, String> tags) async {
    await OneSignalService.instance.setTags(tags);
  }

  /// Set user preferences tags
  Future<void> setUserPreferences({
    List<String>? cuisinePreferences,
    List<String>? dietaryPreferences,
    String? location,
    bool? isChef,
  }) async {
    final tags = <String, String>{};
    
    if (cuisinePreferences != null) {
      tags['cuisine_preferences'] = cuisinePreferences.join(',');
    }
    
    if (dietaryPreferences != null) {
      tags['dietary_preferences'] = dietaryPreferences.join(',');
    }
    
    if (location != null) {
      tags['location'] = location;
    }
    
    if (isChef != null) {
      tags['is_chef'] = isChef.toString();
    }
    
    await OneSignalService.instance.setTags(tags);
  }

  /// Set booking-related tags
  Future<void> setBookingTags({
    required String bookingId,
    required String chefId,
    required String status,
  }) async {
    await OneSignalService.instance.setTags({
      'last_booking_id': bookingId,
      'last_chef_id': chefId,
      'last_booking_status': status,
    });
  }

  /// Get OneSignal subscription ID
  String? getSubscriptionId() {
    return OneSignalService.instance.getSubscriptionId();
  }

  /// Get OneSignal user ID
  String? getOneSignalId() {
    return OneSignalService.instance.getOneSignalId();
  }
}

/// Provider for notification service
final notificationProvider = NotifierProvider<NotificationNotifier, AsyncValue<bool>>(
  NotificationNotifier.new,
);

/// Provider to get notification permission status
final notificationPermissionProvider = Provider<bool>((ref) {
  return ref.watch(notificationProvider).value ?? false;
});

/// Provider to get OneSignal subscription ID
final oneSignalSubscriptionIdProvider = Provider<String?>((ref) {
  ref.watch(notificationProvider); // Ensure provider is built
  return OneSignalService.instance.getSubscriptionId();
});

/// Provider to get OneSignal user ID
final oneSignalUserIdProvider = Provider<String?>((ref) {
  ref.watch(notificationProvider); // Ensure provider is built
  return OneSignalService.instance.getOneSignalId();
});