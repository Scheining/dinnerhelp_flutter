import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/conversation_simple.dart';

// Provider for inquiry messages (pre-booking)
class InquiryMessagesNotifier extends FamilyAsyncNotifier<List<InquiryMessage>, String> {
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
          .order('created_at', ascending: true)  // Changed to ascending
          .limit(50);

      final messages = (response as List)
          .map((json) => InquiryMessage.fromJson(json))
          .toList();

      state = AsyncValue.data(messages);  // Removed reversed
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
          // Sort messages to ensure oldest first
          final messages = data.map((json) => InquiryMessage.fromJson(json)).toList();
          messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          state = AsyncValue.data(messages);
        });
  }

  Future<bool> sendMessage(String content) async {
    try {
      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;
      
      if (currentUser == null) return false;

      // arg is the inquiryId parameter passed to the provider
      
      // Insert the message
      await supabase.from('inquiry_messages').insert({
        'inquiry_id': arg,
        'sender_id': currentUser.id,
        'content': content,
      });

      // Update the inquiry's last message
      await supabase.from('inquiries').update({
        'last_message': content,
        'last_message_at': DateTime.now().toIso8601String(),
      }).eq('id', arg);

      // Reload messages to show the new one
      await _loadMessages(arg);

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
class BookingMessagesNotifier extends FamilyAsyncNotifier<List<Map<String, dynamic>>, String> {
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

      final messages = (response as List).cast<Map<String, dynamic>>();
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

      // arg is the bookingId parameter passed to the provider
      
      await supabase.from('chat_messages').insert({
        'booking_id': arg,
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
class UnifiedConversationsNotifier extends AsyncNotifier<List<UnifiedConversation>> {
  StreamSubscription? _inquiriesSubscription;
  StreamSubscription? _bookingChatsSubscription;
  StreamSubscription? _visibilitySubscription;

  @override
  Future<List<UnifiedConversation>> build() async {
    print('DEBUG: UnifiedConversationsNotifier.build() called');
    
    ref.onDispose(() {
      _inquiriesSubscription?.cancel();
      _bookingChatsSubscription?.cancel();
      _visibilitySubscription?.cancel();
    });

    final conversations = await _loadAllConversations();
    _subscribeToChanges();
    
    print('DEBUG: UnifiedConversationsNotifier.build() returning ${conversations.length} conversations');
    return conversations;
  }

  Future<List<UnifiedConversation>> _loadAllConversations() async {
    try {
      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;
      
      if (currentUser == null) {
        print('DEBUG: No current user');
        return [];
      }
      
      print('DEBUG: Loading conversations for user: ${currentUser.id}');

      // Check if user is a chef
      final profileResponse = await supabase
          .from('profiles')
          .select('is_chef')
          .eq('id', currentUser.id)
          .single();

      final isChef = profileResponse['is_chef'] ?? false;

      // Load inquiries - explicitly select columns to avoid auto-joins
      // Also include archive status for display purposes
      final inquiriesQuery = supabase
          .from('inquiries')
          .select('id, user_id, chef_id, last_message, last_message_at, created_at, updated_at, is_archived, is_deleted');
      
      // Apply filter based on whether user is chef or not
      if (isChef) {
        inquiriesQuery.eq('chef_id', currentUser.id);
      } else {
        inquiriesQuery.eq('user_id', currentUser.id);
      }
      
      // Filter out deleted AND archived conversations
      final inquiriesResponse = await inquiriesQuery
          .eq('is_deleted', false)
          .eq('is_archived', false)
          .order('last_message_at', ascending: false);
      
      // Get hidden conversations for this user
      final hiddenConversationsResponse = await supabase
          .from('conversation_visibility')
          .select('conversation_id, conversation_type, last_hidden_message_at')
          .eq('user_id', currentUser.id);
      
      final hiddenConversations = <String, DateTime>{};
      for (final hidden in (hiddenConversationsResponse as List)) {
        final key = '${hidden['conversation_type']}_${hidden['conversation_id']}';
        hiddenConversations[key] = DateTime.parse(hidden['last_hidden_message_at']);
      }
      
      print('DEBUG: Inquiries query executed');
      print('DEBUG: Inquiries response: $inquiriesResponse');
      print('DEBUG: Number of inquiries: ${(inquiriesResponse as List).length}');

      // Load booking chats - simpler query
      final bookingChatsQuery = supabase
          .from('chat_messages')
          .select('''
            *,
            bookings!inner(
              id,
              date,
              status,
              chef_id,
              user_id
            )
          ''')
          .or('sender_id.eq.${currentUser.id},receiver_id.eq.${currentUser.id}')
          .order('created_at', ascending: false);

      final bookingChatsResponse = await bookingChatsQuery;

      // Group booking messages by booking_id to get latest message per booking
      final bookingMessagesMap = <String, Map<String, dynamic>>{};
      for (final message in (bookingChatsResponse as List)) {
        // Skip archived or deleted messages
        if (message['is_archived'] == true || message['is_deleted'] == true) {
          continue;
        }
        
        final bookingId = message['booking_id'];
        if (!bookingMessagesMap.containsKey(bookingId) || 
            DateTime.parse(message['created_at']).isAfter(
              DateTime.parse(bookingMessagesMap[bookingId]!['created_at']))) {
          bookingMessagesMap[bookingId] = message;
        }
      }

      // Convert to unified conversations
      final conversations = <UnifiedConversation>[];

      // Fetch chef and user data separately for each inquiry
      final inquiryIds = (inquiriesResponse as List).map((i) => i['id']).toList();
      final chefIds = (inquiriesResponse as List).map((i) => i['chef_id']).where((id) => id != null).toList();
      final userIds = (inquiriesResponse as List).map((i) => i['user_id']).where((id) => id != null).toList();
      
      // Fetch all chef data
      Map<String, dynamic> chefDataMap = {};
      if (chefIds.isNotEmpty) {
        final chefsResponse = await supabase
            .from('chefs')
            .select('''
              id,
              profile_image_url,
              profiles (
                first_name,
                last_name
              )
            ''')
            .inFilter('id', chefIds);
        
        for (final chef in (chefsResponse as List)) {
          chefDataMap[chef['id']] = chef;
        }
      }
      
      // Fetch all user profile data
      Map<String, dynamic> userDataMap = {};
      if (userIds.isNotEmpty) {
        final usersResponse = await supabase
            .from('profiles')
            .select('id, first_name, last_name, "profile-image-url"')
            .inFilter('id', userIds);
        
        for (final user in (usersResponse as List)) {
          userDataMap[user['id']] = user;
        }
      }
      
      // Add inquiries
      for (final inquiry in (inquiriesResponse as List)) {
        // Skip if this inquiry is hidden by the user
        final hideKey = 'inquiry_${inquiry['id']}';
        if (hiddenConversations.containsKey(hideKey)) {
          print('DEBUG: Skipping hidden inquiry: ${inquiry['id']}');
          continue;
        }
        
        print('DEBUG: Full inquiry data: $inquiry');
        
        // Get chef and user data from the maps
        final chefData = chefDataMap[inquiry['chef_id']];
        final chefProfile = chefData?['profiles'] as Map<String, dynamic>?;
        final userData = userDataMap[inquiry['user_id']];
        
        print('DEBUG: Chef data: $chefData');
        print('DEBUG: Chef profile: $chefProfile');
        print('DEBUG: User data: $userData');
        
        String otherPersonName;
        String? otherPersonImage;
        
        if (isChef) {
          // If current user is chef, show user info
          otherPersonName = '${userData?['first_name'] ?? ''} ${userData?['last_name'] ?? ''}'.trim();
          if (otherPersonName.isEmpty) otherPersonName = 'Bruger';
          otherPersonImage = userData?['profile-image-url'];
        } else {
          // If current user is regular user, show chef info
          otherPersonName = '${chefProfile?['first_name'] ?? ''} ${chefProfile?['last_name'] ?? ''}'.trim();
          if (otherPersonName.isEmpty) otherPersonName = 'Kok';
          // Use chef's profile_image_url from chefs table
          otherPersonImage = chefData?['profile_image_url'];
        }
        
        print('DEBUG: Final otherPersonName: $otherPersonName');
        print('DEBUG: Final otherPersonImage: $otherPersonImage');
        
        conversations.add(UnifiedConversation(
          id: inquiry['id'],
          type: ConversationType.inquiry,
          inquiryId: inquiry['id'],
          chefId: inquiry['chef_id'],
          userId: inquiry['user_id'],
          otherPersonName: otherPersonName,
          otherPersonImage: otherPersonImage,
          lastMessage: inquiry['last_message'],
          lastMessageAt: inquiry['last_message_at'] != null 
              ? (inquiry['last_message_at'] is String 
                  ? DateTime.parse(inquiry['last_message_at'])
                  : inquiry['last_message_at'] as DateTime)
              : null,
          isArchived: inquiry['is_archived'] ?? false,
        ));
      }

      // Fetch chef and user data for bookings
      final bookingChefIds = bookingMessagesMap.values
          .map((m) => (m['bookings'] as Map<String, dynamic>)['chef_id'])
          .where((id) => id != null)
          .toSet()
          .toList();
      final bookingUserIds = bookingMessagesMap.values
          .map((m) => (m['bookings'] as Map<String, dynamic>)['user_id'])
          .where((id) => id != null)
          .toSet()
          .toList();
      
      // Fetch booking chef data (merge with existing if needed)
      if (bookingChefIds.isNotEmpty) {
        final chefsResponse = await supabase
            .from('chefs')
            .select('''
              id,
              profile_image_url,
              profiles (
                first_name,
                last_name
              )
            ''')
            .inFilter('id', bookingChefIds);
        
        for (final chef in (chefsResponse as List)) {
          chefDataMap[chef['id']] = chef;
        }
      }
      
      // Fetch booking user data (merge with existing if needed)
      if (bookingUserIds.isNotEmpty) {
        final usersResponse = await supabase
            .from('profiles')
            .select('id, first_name, last_name, "profile-image-url"')
            .inFilter('id', bookingUserIds);
        
        for (final user in (usersResponse as List)) {
          userDataMap[user['id']] = user;
        }
      }
      
      // Add booking chats
      for (final message in bookingMessagesMap.values) {
        // Skip if this booking chat is hidden by the user
        final hideKey = 'booking_${message['booking_id']}';
        if (hiddenConversations.containsKey(hideKey)) {
          print('DEBUG: Skipping hidden booking: ${message['booking_id']}');
          continue;
        }
        
        final booking = message['bookings'] as Map<String, dynamic>;
        final chefData = chefDataMap[booking['chef_id']];
        final chefProfile = chefData?['profiles'] as Map<String, dynamic>?;
        final userData = userDataMap[booking['user_id']];
        
        String otherPersonName;
        String? otherPersonImage;
        
        if (isChef) {
          // If current user is chef, show user info
          otherPersonName = '${userData?['first_name'] ?? ''} ${userData?['last_name'] ?? ''}'.trim();
          if (otherPersonName.isEmpty) otherPersonName = 'Bruger';
          otherPersonImage = userData?['profile-image-url'];
        } else {
          // If current user is regular user, show chef info
          otherPersonName = '${chefProfile?['first_name'] ?? ''} ${chefProfile?['last_name'] ?? ''}'.trim();
          if (otherPersonName.isEmpty) otherPersonName = 'Kok';
          // Use chef's profile_image_url from chefs table
          otherPersonImage = chefData?['profile_image_url'];
        }
        
        conversations.add(UnifiedConversation(
          id: message['booking_id'],
          type: ConversationType.booking,
          bookingId: message['booking_id'],
          chefId: booking['chef_id'],
          userId: booking['user_id'],
          otherPersonName: otherPersonName,
          otherPersonImage: otherPersonImage,
          lastMessage: message['content'],
          lastMessageAt: message['created_at'] is String 
              ? DateTime.parse(message['created_at'])
              : message['created_at'] as DateTime,
          bookingStatus: booking['status'],
          bookingDate: booking['date'] is String 
              ? DateTime.parse(booking['date'])
              : booking['date'] as DateTime,
        ));
      }

      // Sort all conversations by last message time
      conversations.sort((a, b) {
        final aTime = a.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });

      print('DEBUG: Final conversations count: ${conversations.length}');
      for (var conv in conversations) {
        print('DEBUG: Conversation - Name: ${conv.otherPersonName}, Message: ${conv.lastMessage}');
      }
      
      return conversations;
    } catch (e) {
      print('DEBUG: Error in _loadAllConversations: $e');
      print('DEBUG: Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<void> _refreshConversations() async {
    try {
      final conversations = await _loadAllConversations();
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
            _refreshConversations();
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
            _refreshConversations();
          }
        });
    
    // Subscribe to conversation visibility changes (for auto-unhide)
    _visibilitySubscription = supabase
        .from('conversation_visibility')
        .stream(primaryKey: ['id'])
        .eq('user_id', currentUser.id)
        .listen((data) {
          // Refresh when visibility changes (e.g., auto-unhide on new message)
          _refreshConversations();
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

  // Archive a conversation (inquiry or booking chat)
  Future<bool> archiveConversation(String conversationId, ConversationType type) async {
    try {
      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;
      
      if (currentUser == null) return false;

      if (type == ConversationType.inquiry) {
        // Archive inquiry using database function
        final result = await supabase.rpc(
          'archive_inquiry_conversation',
          params: {
            'p_inquiry_id': conversationId,
            'p_user_id': currentUser.id,
          },
        );
        
        // Refresh conversations after archiving
        await _refreshConversations();
        return true;
      } else {
        // Archive booking chat using database function
        final result = await supabase.rpc(
          'archive_booking_chat',
          params: {
            'p_booking_id': conversationId,
            'p_user_id': currentUser.id,
          },
        );
        
        // Refresh conversations after archiving
        await _refreshConversations();
        return true;
      }
    } catch (e, stackTrace) {
      print('ERROR archiving conversation: $e');
      print('Stack trace: $stackTrace');
      print('ConversationId: $conversationId');
      print('Type: $type');
      print('CurrentUser: ${Supabase.instance.client.auth.currentUser?.id}');
      return false;
    }
  }

  // Unarchive a conversation
  Future<bool> unarchiveConversation(String conversationId, ConversationType type) async {
    try {
      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;
      
      if (currentUser == null) return false;

      if (type == ConversationType.inquiry) {
        // Unarchive inquiry using database function
        final result = await supabase.rpc(
          'unarchive_inquiry_conversation',
          params: {
            'p_inquiry_id': conversationId,
            'p_user_id': currentUser.id,
          },
        );
        
        // Refresh conversations after unarchiving
        await _refreshConversations();
        return true;
      } else {
        // For booking chats, update the archived status
        await supabase
            .from('chat_messages')
            .update({
              'is_archived': false,
              'archived_at': null,
            })
            .eq('booking_id', conversationId)
            .or('sender_id.eq.${currentUser.id},receiver_id.eq.${currentUser.id}');
        
        // Refresh conversations
        await _refreshConversations();
        return true;
      }
    } catch (e, stackTrace) {
      print('ERROR unarchiving conversation: $e');
      print('Stack trace: $stackTrace');
      print('ConversationId: $conversationId');
      print('Type: $type');
      return false;
    }
  }

  // Hide conversation for current user (Facebook/Airbnb style delete)
  Future<bool> deleteConversation(String conversationId, ConversationType type) async {
    try {
      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;
      
      if (currentUser == null) return false;

      // Use the new hide function that only hides for current user
      // This allows the conversation to reappear if new messages arrive
      final result = await supabase.rpc(
        'hide_conversation_for_user',
        params: {
          'p_conversation_id': conversationId,
          'p_conversation_type': type == ConversationType.inquiry ? 'inquiry' : 'booking',
          'p_user_id': currentUser.id,
        },
      );
      
      // Refresh conversations after hiding
      await _refreshConversations();
      return true;
    } catch (e, stackTrace) {
      print('ERROR hiding conversation: $e');
      print('Stack trace: $stackTrace');
      print('ConversationId: $conversationId');
      print('Type: $type');
      print('CurrentUser: ${Supabase.instance.client.auth.currentUser?.id}');
      return false;
    }
  }

  // Get all hidden/deleted conversations for the current user
  Future<List<UnifiedConversation>> getHiddenConversations() async {
    try {
      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;
      
      if (currentUser == null) return [];

      // Get all hidden conversations for this user
      final hiddenResponse = await supabase
          .from('conversation_visibility')
          .select('conversation_id, conversation_type')
          .eq('user_id', currentUser.id);

      if ((hiddenResponse as List).isEmpty) return [];

      final conversations = <UnifiedConversation>[];
      
      // Get inquiry conversations
      final inquiryIds = (hiddenResponse as List)
          .where((h) => h['conversation_type'] == 'inquiry')
          .map((h) => h['conversation_id'])
          .toList();
      
      if (inquiryIds.isNotEmpty) {
        final inquiriesResponse = await supabase
            .from('inquiries')
            .select('*, profiles!user_id(*), chefs!chef_id(*, profiles(*))')
            .inFilter('id', inquiryIds);
        
        for (final inquiry in (inquiriesResponse as List)) {
          // Extract user and chef data similar to main load function
          final userData = inquiry['profiles'] as Map<String, dynamic>?;
          final chefData = inquiry['chefs'] as Map<String, dynamic>?;
          final chefProfile = chefData?['profiles'] as Map<String, dynamic>?;
          
          final isChef = await isUserChef();
          String otherPersonName;
          String? otherPersonImage;
          
          if (isChef) {
            otherPersonName = '${userData?['first_name'] ?? ''} ${userData?['last_name'] ?? ''}'.trim();
            if (otherPersonName.isEmpty) otherPersonName = 'Bruger';
            otherPersonImage = userData?['profile-image-url'];
          } else {
            otherPersonName = '${chefProfile?['first_name'] ?? ''} ${chefProfile?['last_name'] ?? ''}'.trim();
            if (otherPersonName.isEmpty) otherPersonName = 'Kok';
            otherPersonImage = chefData?['profile_image_url'];
          }
          
          conversations.add(UnifiedConversation(
            id: inquiry['id'],
            type: ConversationType.inquiry,
            inquiryId: inquiry['id'],
            chefId: inquiry['chef_id'],
            userId: inquiry['user_id'],
            otherPersonName: otherPersonName,
            otherPersonImage: otherPersonImage,
            lastMessage: inquiry['last_message'],
            lastMessageAt: inquiry['last_message_at'] != null 
                ? DateTime.parse(inquiry['last_message_at'])
                : null,
          ));
        }
      }
      
      // Get booking conversations
      final bookingIds = (hiddenResponse as List)
          .where((h) => h['conversation_type'] == 'booking')
          .map((h) => h['conversation_id'])
          .toList();
      
      if (bookingIds.isNotEmpty) {
        final bookingsResponse = await supabase
            .from('bookings')
            .select('*, profiles!user_id(*), chefs!chef_id(*, profiles(*))')
            .inFilter('id', bookingIds);
        
        for (final booking in (bookingsResponse as List)) {
          // Get last message for this booking
          final lastMessageResponse = await supabase
              .from('chat_messages')
              .select('content, created_at')
              .eq('booking_id', booking['id'])
              .order('created_at', ascending: false)
              .limit(1)
              .maybeSingle();
          
          final userData = booking['profiles'] as Map<String, dynamic>?;
          final chefData = booking['chefs'] as Map<String, dynamic>?;
          final chefProfile = chefData?['profiles'] as Map<String, dynamic>?;
          
          final isChef = await isUserChef();
          String otherPersonName;
          String? otherPersonImage;
          
          if (isChef) {
            otherPersonName = '${userData?['first_name'] ?? ''} ${userData?['last_name'] ?? ''}'.trim();
            if (otherPersonName.isEmpty) otherPersonName = 'Bruger';
            otherPersonImage = userData?['profile-image-url'];
          } else {
            otherPersonName = '${chefProfile?['first_name'] ?? ''} ${chefProfile?['last_name'] ?? ''}'.trim();
            if (otherPersonName.isEmpty) otherPersonName = 'Kok';
            otherPersonImage = chefData?['profile_image_url'];
          }
          
          conversations.add(UnifiedConversation(
            id: booking['id'],
            type: ConversationType.booking,
            bookingId: booking['id'],
            chefId: booking['chef_id'],
            userId: booking['user_id'],
            otherPersonName: otherPersonName,
            otherPersonImage: otherPersonImage,
            lastMessage: lastMessageResponse?['content'],
            lastMessageAt: lastMessageResponse?['created_at'] != null 
                ? DateTime.parse(lastMessageResponse!['created_at'])
                : null,
            bookingStatus: booking['status'],
            bookingDate: DateTime.parse(booking['date']),
          ));
        }
      }
      
      // Sort by last message time
      conversations.sort((a, b) {
        final aTime = a.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });
      
      return conversations;
    } catch (e) {
      print('ERROR loading hidden conversations: $e');
      return [];
    }
  }

  // Unhide/restore a conversation
  Future<bool> unhideConversation(String conversationId, ConversationType type) async {
    try {
      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;
      
      if (currentUser == null) return false;

      // Delete the visibility record to unhide the conversation
      await supabase
          .from('conversation_visibility')
          .delete()
          .eq('user_id', currentUser.id)
          .eq('conversation_id', conversationId)
          .eq('conversation_type', type == ConversationType.inquiry ? 'inquiry' : 'booking');
      
      // Refresh conversations
      await _refreshConversations();
      return true;
    } catch (e) {
      print('ERROR unhiding conversation: $e');
      return false;
    }
  }

  // Check if current user is a chef
  Future<bool> isUserChef() async {
    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) return false;
    
    final profileResponse = await supabase
        .from('profiles')
        .select('is_chef')
        .eq('id', currentUser.id)
        .maybeSingle();
    
    return profileResponse?['is_chef'] == true;
  }
}

// Provider definitions using manual provider approach
final inquiryMessagesNotifierProvider = AsyncNotifierProvider.family<
    InquiryMessagesNotifier, List<InquiryMessage>, String>(
  InquiryMessagesNotifier.new,
);

final bookingMessagesNotifierProvider = AsyncNotifierProvider.family<
    BookingMessagesNotifier, List<Map<String, dynamic>>, String>(
  BookingMessagesNotifier.new,
);

final unifiedConversationsNotifierProvider = AsyncNotifierProvider<
    UnifiedConversationsNotifier, List<UnifiedConversation>>(
  UnifiedConversationsNotifier.new,
);