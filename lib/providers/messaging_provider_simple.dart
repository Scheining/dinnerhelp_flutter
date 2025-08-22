import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/conversation_simple.dart';

// Simple provider for testing
class SimpleUnifiedConversationsNotifier extends AsyncNotifier<List<UnifiedConversation>> {
  @override
  Future<List<UnifiedConversation>> build() async {
    print('SimpleUnifiedConversations: Building...');
    
    try {
      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;
      
      if (currentUser == null) {
        print('SimpleUnifiedConversations: No user');
        return [];
      }
      
      print('SimpleUnifiedConversations: User ID: ${currentUser.id}');
      
      // Simple direct query
      final response = await supabase
          .from('inquiries')
          .select()
          .eq('user_id', currentUser.id);
      
      print('SimpleUnifiedConversations: Raw response: $response');
      
      final conversations = <UnifiedConversation>[];
      
      for (final inquiry in (response as List)) {
        print('SimpleUnifiedConversations: Processing inquiry: ${inquiry['id']}');
        
        // Get chef profile separately
        final chefResponse = await supabase
            .from('profiles')
            .select('first_name, last_name')
            .eq('id', inquiry['chef_id'])
            .maybeSingle();
        
        print('SimpleUnifiedConversations: Chef data: $chefResponse');
        
        String chefName = 'Kok';
        if (chefResponse != null) {
          final firstName = chefResponse['first_name'] ?? '';
          final lastName = chefResponse['last_name'] ?? '';
          chefName = '$firstName $lastName'.trim();
          if (chefName.isEmpty) chefName = 'Kok';
        }
        
        conversations.add(UnifiedConversation(
          id: inquiry['id'],
          type: ConversationType.inquiry,
          inquiryId: inquiry['id'],
          chefId: inquiry['chef_id'],
          userId: inquiry['user_id'],
          otherPersonName: chefName,
          otherPersonImage: null,
          lastMessage: inquiry['last_message'],
          lastMessageAt: inquiry['last_message_at'] != null 
              ? DateTime.parse(inquiry['last_message_at'])
              : null,
        ));
      }
      
      print('SimpleUnifiedConversations: Total conversations: ${conversations.length}');
      
      return conversations;
    } catch (e) {
      print('SimpleUnifiedConversations: Error: $e');
      rethrow;
    }
  }
}

// Test provider
final simpleUnifiedConversationsProvider = AsyncNotifierProvider<
    SimpleUnifiedConversationsNotifier, List<UnifiedConversation>>(
  SimpleUnifiedConversationsNotifier.new,
);