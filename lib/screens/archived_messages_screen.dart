import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homechef/providers/messaging_provider.dart';
import 'package:homechef/models/conversation_simple.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homechef/screens/chat_screen.dart';

// Provider for hidden conversations
final hiddenConversationsProvider = FutureProvider<List<UnifiedConversation>>((ref) async {
  return ref.read(unifiedConversationsNotifierProvider.notifier).getHiddenConversations();
});

class ArchivedMessagesScreen extends ConsumerWidget {
  const ArchivedMessagesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hiddenConversations = ref.watch(hiddenConversationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Slettede beskeder'),
        backgroundColor: theme.brightness == Brightness.dark 
            ? const Color(0xFF1A1A1A) 
            : Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
      ),
      body: hiddenConversations.when(
        data: (conversations) {
          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.archive_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ingen slettede beskeder',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Slettede beskeder vises her',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 7),
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              
              return Slidable(
                key: Key(conversation.id),
                endActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) async {
                        // Restore conversation
                        final success = await ref.read(
                          unifiedConversationsNotifierProvider.notifier
                        ).unhideConversation(
                          conversation.type == ConversationType.inquiry
                              ? conversation.inquiryId!
                              : conversation.bookingId!,
                          conversation.type,
                        );
                        
                        if (success) {
                          // Refresh both lists
                          ref.invalidate(hiddenConversationsProvider);
                          ref.invalidate(unifiedConversationsNotifierProvider);
                          
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Besked gendannet'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      },
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      icon: Icons.restore,
                      label: 'Gendan',
                    ),
                  ],
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      conversation.otherPersonName?.substring(0, 1).toUpperCase() ?? '?',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    conversation.otherPersonName ?? 'Ukendt',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    conversation.lastMessage ?? 'Ingen beskeder',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  trailing: conversation.lastMessageAt != null
                      ? Text(
                          _formatTime(conversation.lastMessageAt!),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        )
                      : null,
                  onTap: () async {
                    // Navigate to chat screen
                    final currentUser = Supabase.instance.client.auth.currentUser;
                    if (currentUser == null) return;
                    
                    final isChef = await ref
                        .read(unifiedConversationsNotifierProvider.notifier)
                        .isUserChef();
                    
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          chefId: isChef ? conversation.userId! : conversation.chefId!,
                          chefName: conversation.otherPersonName ?? '',
                          chefImage: conversation.otherPersonImage ?? '',
                          conversationType: conversation.type,
                          conversationId: conversation.type == ConversationType.booking 
                              ? conversation.bookingId 
                              : conversation.inquiryId,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Fejl ved indlæsning: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d siden';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}t siden';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m siden';
    } else {
      return 'Nu';
    }
  }
}