import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homechef/models/conversation_simple.dart';
import 'package:homechef/providers/messaging_provider.dart';
import 'package:homechef/providers/messaging_provider_simple.dart';
import 'package:homechef/providers/auth_provider.dart';
import 'package:homechef/screens/chat_screen.dart';
import 'package:intl/intl.dart';

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('DEBUG MessagesScreen: build() called');
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    print('DEBUG MessagesScreen: About to watch provider...');
    final conversationsAsync = ref.watch(unifiedConversationsNotifierProvider);
    
    print('DEBUG MessagesScreen: Provider watched, state: ${conversationsAsync.runtimeType}');
    print('DEBUG MessagesScreen: hasValue: ${conversationsAsync.hasValue}, hasError: ${conversationsAsync.hasError}, isLoading: ${conversationsAsync.isLoading}');
    
    conversationsAsync.when(
      data: (data) {
        print('DEBUG MessagesScreen: Got data with ${data.length} conversations');
        return null;
      },
      loading: () {
        print('DEBUG MessagesScreen: Loading...');
        return null;
      },
      error: (e, s) {
        print('DEBUG MessagesScreen: Error: $e');
        print('DEBUG MessagesScreen: Stack: $s');
        return null;
      },
    );
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Beskeder',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: conversationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Kunne ikke indlæse beskeder',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(unifiedConversationsNotifierProvider),
                child: const Text('Prøv igen'),
              ),
            ],
          ),
        ),
        data: (conversations) {
          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ingen beskeder endnu',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start en samtale med en kok',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              return _buildConversationTile(context, ref, conversation, isDark);
            },
          );
        },
      ),
    );
  }

  Widget _buildConversationTile(
    BuildContext context,
    WidgetRef ref,
    UnifiedConversation conversation,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    
    // Determine icon and subtitle based on conversation type
    IconData typeIcon;
    String subtitle;
    Color? statusColor;
    
    if (conversation.type == ConversationType.booking) {
      typeIcon = Icons.calendar_today;
      final status = conversation.bookingStatus ?? 'pending';
      subtitle = _getBookingStatusText(status);
      statusColor = _getBookingStatusColor(status);
      
      if (conversation.bookingDate != null) {
        subtitle += ' • ${DateFormat('d. MMM', 'da_DK').format(conversation.bookingDate!)}';
      }
    } else {
      typeIcon = Icons.chat_bubble_outline;
      subtitle = conversation.lastMessage ?? 'Start en samtale';
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: conversation.otherPersonImage?.isNotEmpty == true
                ? NetworkImage(conversation.otherPersonImage!)
                : null,
            child: conversation.otherPersonImage?.isEmpty ?? true
                ? const Icon(Icons.person, size: 28)
                : null,
          ),
          // Type indicator badge
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: conversation.type == ConversationType.booking
                    ? theme.colorScheme.primary
                    : Colors.grey.shade600,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? Colors.black : Colors.white,
                  width: 2,
                ),
              ),
              child: Icon(
                typeIcon,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
          // Unread indicator
          if (conversation.unreadCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  conversation.unreadCount > 99 
                      ? '99+' 
                      : conversation.unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              conversation.otherPersonName ?? 'Ukendt',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: conversation.unreadCount > 0 
                    ? FontWeight.bold 
                    : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (conversation.lastMessageAt != null)
            Text(
              _formatTime(conversation.lastMessageAt!),
              style: theme.textTheme.bodySmall?.copyWith(
                color: conversation.unreadCount > 0
                    ? theme.colorScheme.primary
                    : (isDark ? Colors.grey.shade500 : Colors.grey.shade600),
              ),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              if (statusColor != null) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: conversation.unreadCount > 0
                        ? (isDark ? Colors.white : Colors.black87)
                        : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                    fontWeight: conversation.unreadCount > 0
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
      onTap: () async {
        // Get current user to determine correct navigation
        final currentUser = ref.read(currentUserProvider).value;
        
        // Navigate to appropriate chat screen based on type
        if (conversation.type == ConversationType.inquiry) {
          // Determine the chef ID based on whether current user is chef or not
          final isCurrentUserChef = conversation.chefId == currentUser?.id;
          final targetChefId = isCurrentUserChef ? conversation.chefId! : conversation.chefId!;
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                chefId: targetChefId,
                chefName: conversation.otherPersonName ?? 'Kok',
                chefImage: conversation.otherPersonImage ?? '',
              ),
            ),
          );
        } else {
          // For booking chats, navigate to booking chat screen
          // TODO: Create BookingChatScreen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Booking chat kommer snart'),
            ),
          );
        }
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Nu';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} t';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} d';
    } else {
      return DateFormat('d/M').format(dateTime);
    }
  }

  String _getBookingStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Afventer svar';
      case 'accepted':
        return 'Accepteret';
      case 'confirmed':
        return 'Bekræftet';
      case 'in_progress':
        return 'I gang';
      case 'completed':
        return 'Afsluttet';
      case 'cancelled':
        return 'Annulleret';
      case 'disputed':
        return 'Under tvist';
      case 'refunded':
        return 'Refunderet';
      default:
        return status;
    }
  }

  Color _getBookingStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
      case 'confirmed':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.grey;
      case 'cancelled':
      case 'disputed':
      case 'refunded':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}