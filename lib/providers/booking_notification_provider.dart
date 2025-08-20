import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homechef/services/notification_triggers_service.dart';
import 'package:homechef/providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for handling booking-related notifications
final bookingNotificationProvider = Provider((ref) => BookingNotificationService(ref));

class BookingNotificationService {
  final Ref _ref;
  final _notificationService = NotificationTriggersService.instance;
  final _supabase = Supabase.instance.client;
  
  BookingNotificationService(this._ref);

  /// Handle booking confirmation - uses Supabase function to trigger notifications
  Future<void> handleBookingConfirmation({
    required String bookingId,
    required String userId,
    required String chefName,
    required DateTime bookingDateTime,
  }) async {
    try {
      // Call Supabase function to trigger notifications
      final response = await _supabase.rpc('trigger_booking_notification', params: {
        'p_booking_id': bookingId,
        'p_notification_type': 'booking_confirmed',
        'p_additional_data': {
          'chef_name': chefName,
          'booking_datetime': bookingDateTime.toIso8601String(),
        }
      });
      
      print('Booking confirmation notification triggered: $response');
      
      // Also send via OneSignal directly for immediate delivery
      final bookingDate = '${bookingDateTime.day}/${bookingDateTime.month}/${bookingDateTime.year}';
      final bookingTime = '${bookingDateTime.hour.toString().padLeft(2, '0')}:${bookingDateTime.minute.toString().padLeft(2, '0')}';
      
      await _notificationService.sendBookingConfirmationToUser(
        userId: userId,
        chefName: chefName,
        bookingDate: bookingDate,
        bookingTime: bookingTime,
        bookingId: bookingId,
      );
    } catch (e) {
      print('Error handling booking confirmation notification: $e');
    }
  }

  /// Handle booking completion - schedules rating request
  Future<void> handleBookingCompletion({
    required String bookingId,
    required String userId,
    required String chefName,
  }) async {
    try {
      // Call Supabase function to trigger rating request
      final response = await _supabase.rpc('trigger_booking_notification', params: {
        'p_booking_id': bookingId,
        'p_notification_type': 'booking_completed',
        'p_additional_data': {
          'chef_name': chefName,
        }
      });
      
      print('Rating request notification scheduled: $response');
    } catch (e) {
      print('Error handling booking completion notification: $e');
    }
  }

  /// Handle new message notification
  Future<void> handleNewMessage({
    required String recipientId,
    required String senderName,
    required String messagePreview,
    required String conversationId,
    String? senderImageUrl,
  }) async {
    try {
      // Don't send notification if user is currently in the chat
      // This should be checked based on app state
      
      await _notificationService.sendNewMessageNotification(
        userId: recipientId,
        senderName: senderName,
        messagePreview: messagePreview.length > 100 
          ? '${messagePreview.substring(0, 100)}...'
          : messagePreview,
        conversationId: conversationId,
        senderImageUrl: senderImageUrl,
      );
    } catch (e) {
      print('Error sending message notification: $e');
    }
  }

  /// Handle booking cancellation
  Future<void> handleBookingCancellation({
    required String bookingId,
    required String userId,
    required String chefName,
    required String bookingDate,
    required String reason,
  }) async {
    try {
      await _notificationService.sendBookingCancellationNotification(
        userId: userId,
        chefName: chefName,
        bookingDate: bookingDate,
        reason: reason,
        bookingId: bookingId,
      );
    } catch (e) {
      print('Error sending cancellation notification: $e');
    }
  }

  /// Handle booking update
  Future<void> handleBookingUpdate({
    required String bookingId,
    required String userId,
    required String chefName,
    required String updateMessage,
  }) async {
    try {
      await _notificationService.sendBookingUpdateNotification(
        userId: userId,
        chefName: chefName,
        updateMessage: updateMessage,
        bookingId: bookingId,
      );
    } catch (e) {
      print('Error sending update notification: $e');
    }
  }

  /// Handle chef arrival
  Future<void> handleChefArrival({
    required String bookingId,
    required String userId,
    required String chefName,
  }) async {
    try {
      await _notificationService.sendChefArrivalNotification(
        userId: userId,
        chefName: chefName,
        bookingId: bookingId,
      );
    } catch (e) {
      print('Error sending arrival notification: $e');
    }
  }
}

/// Stream provider for listening to booking status changes
final bookingStatusStreamProvider = StreamProvider.family<Map<String, dynamic>?, String>((ref, bookingId) {
  final supabase = Supabase.instance.client;
  
  return supabase
    .from('bookings')
    .stream(primaryKey: ['id'])
    .eq('id', bookingId)
    .map((data) => data.isNotEmpty ? data.first : null)
    .asyncMap((booking) async {
      if (booking != null) {
        final previousStatus = ref.read(bookingStatusCacheProvider(bookingId));
        final currentStatus = booking['status'] as String;
        
        // If status changed to confirmed, send notification
        if (previousStatus != 'confirmed' && currentStatus == 'confirmed') {
          // Get chef details
          final chefData = await supabase
            .from('chefs')
            .select('profiles!inner(first_name, last_name)')
            .eq('id', booking['chef_id'])
            .single();
          
          final chefName = '${chefData['profiles']['first_name']} ${chefData['profiles']['last_name']}';
          final bookingDateTime = DateTime.parse('${booking['date']}T${booking['start_time']}');
          
          await ref.read(bookingNotificationProvider).handleBookingConfirmation(
            bookingId: bookingId,
            userId: booking['user_id'],
            chefName: chefName,
            bookingDateTime: bookingDateTime,
          );
        }
        
        // If status changed to completed, schedule rating request
        if (previousStatus != 'completed' && currentStatus == 'completed') {
          final chefData = await supabase
            .from('chefs')
            .select('profiles!inner(first_name, last_name)')
            .eq('id', booking['chef_id'])
            .single();
          
          final chefName = '${chefData['profiles']['first_name']} ${chefData['profiles']['last_name']}';
          
          await ref.read(bookingNotificationProvider).handleBookingCompletion(
            bookingId: bookingId,
            userId: booking['user_id'],
            chefName: chefName,
          );
        }
        
        // Update cache
        ref.read(bookingStatusCacheProvider(bookingId).notifier).state = currentStatus;
      }
      
      return booking;
    });
});

/// Cache provider for tracking booking status
final bookingStatusCacheProvider = StateProvider.family<String?, String>((ref, bookingId) => null);

/// Stream provider for listening to new messages
final messageNotificationStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final currentUser = ref.watch(currentUserProvider).value;
  if (currentUser == null) return const Stream.empty();
  
  final supabase = Supabase.instance.client;
  
  return supabase
    .from('chat_messages')
    .stream(primaryKey: ['id'])
    .order('created_at', ascending: false)
    .map((messages) {
      // Filter for messages where current user is recipient
      return messages.where((msg) {
        // Logic to determine if current user should receive notification
        // This depends on your chat structure
        return msg['recipient_id'] == currentUser.id;
      }).toList();
    })
    .asyncMap((messages) async {
      for (final message in messages) {
        // Check if message is new (created in last few seconds)
        final createdAt = DateTime.parse(message['created_at']);
        if (DateTime.now().difference(createdAt).inSeconds < 5) {
          // Get sender details
          final senderData = await supabase
            .from('profiles')
            .select('first_name, last_name, avatar_url')
            .eq('id', message['sender_id'])
            .single();
          
          final senderName = '${senderData['first_name']} ${senderData['last_name']}';
          
          await ref.read(bookingNotificationProvider).handleNewMessage(
            recipientId: currentUser.id,
            senderName: senderName,
            messagePreview: message['message'],
            conversationId: message['booking_id'],
            senderImageUrl: senderData['avatar_url'],
          );
        }
      }
      
      return messages;
    });
});