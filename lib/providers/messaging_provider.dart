import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/conversation.dart';
import '../providers/auth_provider.dart';

part 'messaging_provider.g.dart';

// Provider for inquiry messages (pre-booking)
@riverpod
class InquiryMessagesNotifier extends _$InquiryMessagesNotifier {
  StreamSubscription? _messagesSubscription;

  @override
  Future<List<InquiryMessage>> build(String inquiryId) async {
    ref.onDispose(() {
      _messagesSubscription?.cancel();
    });

    await _loadMessages(inquiryId);
    _subscribeToMessages(inquiryId);
    
    return state.value ?? [];
  }

  Future<void> _loadMessages(String inquiryId) async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('inquiry_messages')
          .select()
          .eq('inquiry_id', inquiryId)
          .order('created_at', ascending: false)
          .limit(50);

      final messages = (response as List)
          .map((json) => InquiryMessage.fromJson(json))
          .toList();

      state = AsyncValue.data(messages.reversed.toList());
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  void _subscribeToMessages(String inquiryId) {
    final supabase = Supabase.instance.client;
    
    _messagesSubscription = supabase
        .from('inquiry_messages')
        .stream(primaryKey: ['id'])
        .eq('inquiry_id', inquiryId)
        .order('created_at')
        .listen((data) {
          final messages = data.map((json) => InquiryMessage.fromJson(json)).toList();
          state = AsyncValue.data(messages);
        });
  }

  Future<bool> sendMessage(String content) async {
    try {
      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;
      
      if (currentUser == null) return false;

      final inquiryId = arg;
      
      await supabase.from('inquiry_messages').insert({
        'inquiry_id': inquiryId,
        'sender_id': currentUser.id,
        'content': content,
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> markMessagesAsRead(List<String> messageIds) async {
    if (messageIds.isEmpty) return;
    
    try {
      final supabase = Supabase.instance.client;
      await supabase
          .from('inquiry_messages')
          .update({'is_read': true})
          .inFilter('id', messageIds);
    } catch (e) {
      // Handle error silently
    }
  }
}

// Provider for booking messages (post-booking)
@riverpod
class BookingMessagesNotifier extends _$BookingMessagesNotifier {
  StreamSubscription? _messagesSubscription;

  @override
  Future<List<Map<String, dynamic>>> build(String bookingId) async {
    ref.onDispose(() {
      _messagesSubscription?.cancel();
    });

    await _loadMessages(bookingId);
    _subscribeToMessages(bookingId);
    
    return state.value ?? [];
  }

  Future<void> _loadMessages(String bookingId) async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('chat_messages')
          .select()
          .eq('booking_id', bookingId)
          .order('created_at', ascending: false)
          .limit(50);

      final messages = response as List;
      state = AsyncValue.data(messages.reversed.toList());
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  void _subscribeToMessages(String bookingId) {
    final supabase = Supabase.instance.client;
    
    _messagesSubscription = supabase
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('booking_id', bookingId)
        .order('created_at')
        .listen((data) {
          state = AsyncValue.data(data);
        });
  }

  Future<bool> sendMessage(String content, String receiverId) async {
    try {
      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;
      
      if (currentUser == null) return false;

      final bookingId = arg;
      
      await supabase.from('chat_messages').insert({
        'booking_id': bookingId,
        'sender_id': currentUser.id,
        'receiver_id': receiverId,
        'content': content,
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> markMessagesAsRead(List<String> messageIds) async {
    if (messageIds.isEmpty) return;
    
    try {
      final supabase = Supabase.instance.client;
      await supabase
          .from('chat_messages')
          .update({'is_read': true})
          .inFilter('id', messageIds);
    } catch (e) {
      // Handle error silently
    }
  }
}

// Unified conversations provider (shows both inquiries and booking chats)
@riverpod
class UnifiedConversationsNotifier extends _$UnifiedConversationsNotifier {
  StreamSubscription? _inquiriesSubscription;
  StreamSubscription? _bookingChatsSubscription;

  @override
  Future<List<UnifiedConversation>> build() async {
    ref.onDispose(() {
      _inquiriesSubscription?.cancel();
      _bookingChatsSubscription?.cancel();
    });

    await _loadAllConversations();
    _subscribeToChanges();
    
    return state.value ?? [];
  }

  Future<void> _loadAllConversations() async {
    try {
      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;
      
      if (currentUser == null) {
        state = const AsyncValue.data([]);
        return;
      }

      // Check if user is a chef
      final profileResponse = await supabase
          .from('profiles')
          .select('is_chef')
          .eq('id', currentUser.id)
          .single();

      final isChef = profileResponse['is_chef'] ?? false;

      // Load inquiries
      final inquiriesResponse = await supabase
          .from('inquiries')
          .select('''
            *,
            chefs!inner(
              id,
              name,
              profile_image
            ),
            profiles!inquiries_user_id_fkey(
              id,
              first_name,
              last_name,
              profile_image_url
            )
          ''')
          .or(isChef 
              ? 'chef_id.eq.${currentUser.id}'
              : 'user_id.eq.${currentUser.id}')
          .order('last_message_at', ascending: false);

      // Load booking chats
      final bookingChatsQuery = supabase
          .from('chat_messages')
          .select('''
            *,
            bookings!inner(
              id,
              date,
              status,
              chef_id,
              user_id,
              chefs!inner(
                id,
                name,
                profile_image
              ),
              profiles!bookings_user_id_fkey(
                id,
                first_name,
                last_name,
                profile_image_url
              )
            )
          ''')
          .or('sender_id.eq.${currentUser.id},receiver_id.eq.${currentUser.id}')
          .order('created_at', ascending: false);

      final bookingChatsResponse = await bookingChatsQuery;

      // Group booking messages by booking_id to get latest message per booking
      final bookingMessagesMap = <String, Map<String, dynamic>>{};
      for (final message in (bookingChatsResponse as List)) {
        final bookingId = message['booking_id'];
        if (!bookingMessagesMap.containsKey(bookingId) || 
            DateTime.parse(message['created_at']).isAfter(
              DateTime.parse(bookingMessagesMap[bookingId]!['created_at']))) {
          bookingMessagesMap[bookingId] = message;
        }
      }

      // Convert to unified conversations
      final conversations = <UnifiedConversation>[];

      // Add inquiries
      for (final inquiry in (inquiriesResponse as List)) {
        final chef = inquiry['chefs'] as Map<String, dynamic>;
        final user = inquiry['profiles'] as Map<String, dynamic>;
        
        conversations.add(UnifiedConversation(
          id: inquiry['id'],
          type: ConversationType.inquiry,
          otherPersonName: isChef 
              ? '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim()
              : chef['name'],
          otherPersonImage: isChef 
              ? user['profile_image_url']
              : chef['profile_image'],
          lastMessage: inquiry['last_message'],
          lastMessageAt: inquiry['last_message_at'] != null 
              ? DateTime.parse(inquiry['last_message_at']) 
              : null,
        ));
      }

      // Add booking chats
      for (final message in bookingMessagesMap.values) {
        final booking = message['bookings'] as Map<String, dynamic>;
        final chef = booking['chefs'] as Map<String, dynamic>;
        final user = booking['profiles'] as Map<String, dynamic>;
        
        conversations.add(UnifiedConversation(
          id: message['booking_id'],
          type: ConversationType.booking,
          bookingId: message['booking_id'],
          otherPersonName: isChef 
              ? '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim()
              : chef['name'],
          otherPersonImage: isChef 
              ? user['profile_image_url']
              : chef['profile_image'],
          lastMessage: message['content'],
          lastMessageAt: DateTime.parse(message['created_at']),
          bookingStatus: booking['status'],
          bookingDate: DateTime.parse(booking['date']),
        ));
      }

      // Sort all conversations by last message time
      conversations.sort((a, b) {
        final aTime = a.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });

      state = AsyncValue.data(conversations);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  void _subscribeToChanges() {
    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;
    
    if (currentUser == null) return;

    // Subscribe to inquiries
    _inquiriesSubscription = supabase
        .from('inquiries')
        .stream(primaryKey: ['id'])
        .listen((data) {
          // Filter in memory since .or() is not available on streams
          final filtered = data.where((row) => 
            row['user_id'] == currentUser.id || 
            row['chef_id'] == currentUser.id
          ).toList();
          if (filtered.isNotEmpty) {
            _loadAllConversations();
          }
        });

    // Subscribe to booking chats
    _bookingChatsSubscription = supabase
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .listen((data) {
          // Filter in memory since .or() is not available on streams
          final filtered = data.where((row) => 
            row['sender_id'] == currentUser.id || 
            row['receiver_id'] == currentUser.id
          ).toList();
          if (filtered.isNotEmpty) {
            _loadAllConversations();
          }
        });
  }

  Future<String?> getOrCreateInquiry(String chefId) async {
    try {
      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;
      
      if (currentUser == null) return null;

      // Check if inquiry already exists
      final existingResponse = await supabase
          .from('inquiries')
          .select('id')
          .eq('user_id', currentUser.id)
          .eq('chef_id', chefId)
          .maybeSingle();

      if (existingResponse != null) {
        return existingResponse['id'];
      }

      // Create new inquiry
      final newInquiry = await supabase
          .from('inquiries')
          .insert({
            'user_id': currentUser.id,
            'chef_id': chefId,
          })
          .select('id')
          .single();

      return newInquiry['id'];
    } catch (e) {
      return null;
    }
  }
}