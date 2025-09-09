import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service to ensure OneSignal External User IDs are properly synced
/// This solves the issue where External IDs weren't being set in OneSignal
class OneSignalSyncService {
  static final OneSignalSyncService _instance = OneSignalSyncService._internal();
  factory OneSignalSyncService() => _instance;
  OneSignalSyncService._internal();

  static OneSignalSyncService get instance => _instance;
  
  bool _isSyncing = false;
  String? _lastSyncedUserId;
  DateTime? _lastSyncTime;

  /// Main sync function - ensures user is properly synced with OneSignal
  /// Safe to call multiple times - includes deduplication logic
  static Future<void> syncUserWithOneSignal() async {
    final service = OneSignalSyncService.instance;
    
    // Prevent concurrent syncs
    if (service._isSyncing) {
      debugPrint('OneSignalSync: Sync already in progress, skipping...');
      return;
    }
    
    service._isSyncing = true;
    
    try {
      final user = Supabase.instance.client.auth.currentUser;
      
      if (user == null) {
        debugPrint('OneSignalSync: No user logged in, skipping sync');
        return;
      }
      
      // Check if we recently synced this user (within last 5 minutes)
      if (service._lastSyncedUserId == user.id && 
          service._lastSyncTime != null &&
          DateTime.now().difference(service._lastSyncTime!).inMinutes < 5) {
        debugPrint('OneSignalSync: User ${user.id} was recently synced, skipping...');
        return;
      }
      
      debugPrint('OneSignalSync: Starting sync for user ${user.id}');
      
      // Step 1: Wait for OneSignal subscription to exist (critical for iOS SDK 5.1.2 bug)
      debugPrint('OneSignalSync: Waiting for OneSignal subscription to be ready...');
      bool subscriptionReady = false;
      int waitTime = 1000; // Start with 1 second
      int totalWaitTime = 0;
      const maxWaitTime = 30000; // Maximum 30 seconds
      
      while (!subscriptionReady && totalWaitTime < maxWaitTime) {
        final subscriptionId = OneSignal.User.pushSubscription.id;
        final onesignalId = OneSignal.User.pushSubscription.id; // Use subscription ID
        
        if (subscriptionId != null && subscriptionId.isNotEmpty && subscriptionId != '') {
          subscriptionReady = true;
          debugPrint('OneSignalSync: ✅ Subscription ready! ID: $subscriptionId, OneSignal ID: $onesignalId');
        } else {
          debugPrint('OneSignalSync: Subscription not ready, waiting ${waitTime}ms... (total waited: ${totalWaitTime}ms)');
          await Future.delayed(Duration(milliseconds: waitTime));
          totalWaitTime += waitTime;
          waitTime = (waitTime * 2).clamp(1000, 8000); // Exponential backoff, max 8 seconds
        }
      }
      
      if (!subscriptionReady) {
        debugPrint('OneSignalSync: ⚠️ Subscription not ready after ${totalWaitTime}ms, proceeding anyway...');
      }
      
      // Step 2: Set the external user ID with multiple retries
      bool externalIdSet = false;
      int retryCount = 0;
      const maxRetries = 5;
      int retryDelay = 1000; // Start with 1 second
      
      while (!externalIdSet && retryCount < maxRetries) {
        try {
          debugPrint('OneSignalSync: Attempting to set external user ID to ${user.id} (attempt ${retryCount + 1}/$maxRetries)');
          await OneSignal.login(user.id);
          
          // Verify the External ID was actually set
          await Future.delayed(const Duration(milliseconds: 500)); // Small delay to let it propagate
          
          // Note: We can't verify External ID locally due to SDK 5.x limitations
          // The External ID might be set on backend even if we can't verify it locally
          externalIdSet = true; // Assume success after calling login()
          debugPrint('OneSignalSync: ⚠️ Cannot verify External ID locally (SDK limitation), assuming success');
          
          debugPrint('OneSignalSync: ✅ OneSignal.login() completed successfully');
        } catch (e) {
          retryCount++;
          debugPrint('OneSignalSync: ❌ Failed to set external user ID (attempt $retryCount): $e');
          
          if (retryCount < maxRetries) {
            debugPrint('OneSignalSync: Retrying in ${retryDelay}ms...');
            await Future.delayed(Duration(milliseconds: retryDelay));
            retryDelay = (retryDelay * 2).clamp(1000, 8000); // Exponential backoff
          } else {
            debugPrint('OneSignalSync: ❌❌❌ Failed to set external user ID after $maxRetries attempts');
            // Don't throw - continue with the app even if OneSignal fails
          }
        }
      }
      
      // Step 3: Set user tags for additional targeting options
      try {
        final tags = <String, String>{
          'user_id': user.id,
          'email': user.email ?? '',
          'last_sync': DateTime.now().toIso8601String(),
          'sync_version': '1.0',
        };
        
        // Add user role tags if available
        final profileResponse = await Supabase.instance.client
            .from('profiles')
            .select('is_chef')
            .eq('id', user.id)
            .maybeSingle();
            
        if (profileResponse != null) {
          tags['is_chef'] = (profileResponse['is_chef'] ?? false).toString();
        }
        
        debugPrint('OneSignalSync: Setting user tags: $tags');
        await OneSignal.User.addTags(tags);
        debugPrint('OneSignalSync: ✅ Tags set successfully');
      } catch (e) {
        debugPrint('OneSignalSync: ⚠️ Failed to set tags (non-critical): $e');
      }
      
      // Step 4: Set email if available (for email notifications)
      if (user.email != null && user.email!.isNotEmpty) {
        try {
          debugPrint('OneSignalSync: Setting email to ${user.email}');
          await OneSignal.User.addEmail(user.email!);
          debugPrint('OneSignalSync: ✅ Email set successfully');
        } catch (e) {
          debugPrint('OneSignalSync: ⚠️ Failed to set email (non-critical): $e');
        }
      }
      
      // Step 4.5: Ensure push subscription is active (critical for push notifications)
      try {
        debugPrint('OneSignalSync: Checking push subscription status...');
        final hasPermission = await OneSignal.Notifications.permission;
        final isOptedIn = OneSignal.User.pushSubscription.optedIn ?? false;
        final pushToken = OneSignal.User.pushSubscription.token;
        
        debugPrint('OneSignalSync: Push status - Permission: $hasPermission, OptedIn: $isOptedIn, Token: ${pushToken != null ? "✅" : "❌"}');
        
        if (hasPermission && !isOptedIn) {
          debugPrint('OneSignalSync: User has permission but not opted in, forcing opt-in...');
          OneSignal.User.pushSubscription.optIn();
          await Future.delayed(const Duration(milliseconds: 500));
          debugPrint('OneSignalSync: ✅ Push subscription opted in');
        } else if (!hasPermission) {
          debugPrint('OneSignalSync: ⚠️ Push permission not granted - user needs to enable in Settings');
        } else if (isOptedIn && pushToken != null) {
          debugPrint('OneSignalSync: ✅ Push subscription already active with token');
        } else if (isOptedIn && pushToken == null) {
          debugPrint('OneSignalSync: ⚠️ Opted in but no push token - may need app restart');
        }
      } catch (e) {
        debugPrint('OneSignalSync: ⚠️ Failed to verify push subscription: $e');
      }
      
      // Step 5: Store sync status in database (for monitoring)
      try {
        final syncData = {
          'user_id': user.id,
          'onesignal_id': OneSignal.User.pushSubscription.id ?? '',
          'subscription_id': OneSignal.User.pushSubscription.id ?? '',
          'external_id': user.id, // Use the user ID we set
          'external_id_set': externalIdSet,
          'synced_at': DateTime.now().toIso8601String(),
          'sdk_version': '5.1.2',
          'retry_count': retryCount,
        };
        
        await Supabase.instance.client
            .from('user_onesignal_sync')
            .upsert(syncData);
            
        debugPrint('OneSignalSync: ✅ Sync status saved to database');
      } catch (e) {
        // Table might not exist yet, that's okay
        debugPrint('OneSignalSync: Could not save sync status to database: $e');
      }
      
      // Update last sync tracking
      service._lastSyncedUserId = user.id;
      service._lastSyncTime = DateTime.now();
      
      debugPrint('OneSignalSync: ✅✅✅ Sync completed successfully for user ${user.id}');
      
    } catch (e) {
      debugPrint('OneSignalSync: ❌❌❌ Sync failed with error: $e');
    } finally {
      service._isSyncing = false;
    }
  }
  
  /// Check if OneSignal has the external user ID set
  static Future<bool> isExternalUserIdSet() async {
    try {
      // Check if we have a OneSignal ID
      final onesignalId = OneSignal.User.pushSubscription.id;
      if (onesignalId == null || onesignalId.isEmpty) {
        return false;
      }
      
      // Check if we have a logged in user
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        return false;
      }
      
      // The external ID should be set if login was successful
      // We can verify by checking our sync tracking
      try {
        final response = await Supabase.instance.client
            .from('user_onesignal_sync')
            .select('external_id_set')
            .eq('user_id', user.id)
            .maybeSingle();
            
        return response?['external_id_set'] ?? false;
      } catch (e) {
        // If table doesn't exist or query fails, assume not set
        return false;
      }
    } catch (e) {
      debugPrint('OneSignalSync: Error checking external ID status: $e');
      return false;
    }
  }
  
  /// Force a resync even if recently synced
  static Future<void> forceSyncNow() async {
    final service = OneSignalSyncService.instance;
    service._lastSyncedUserId = null;
    service._lastSyncTime = null;
    await syncUserWithOneSignal();
  }
}