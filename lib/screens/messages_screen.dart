import 'package:flutter/material.dart';
import 'package:homechef/models/message.dart';
import 'package:homechef/screens/chat_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Sample chat data
    final chats = [
      Chat(
        id: 'chat_1',
        chefId: '1',
        chefName: 'Lars Nielsen',
        chefImage: 'https://pixabay.com/get/g24a62bc118f3af91b1e93be58966f8e74118b4d1f413f7c2959623342bff7e50a316adc41c3ff570aad063e55e463a5cc6ffa293d5df12b97a4d093a0a5b20a4_1280.jpg',
        userId: 'user1',
        messages: ChatMessage.getSampleMessages('chat_1'),
        lastActivity: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      Chat(
        id: 'chat_2',
        chefId: '3',
        chefName: 'Hiroshi Tanaka',
        chefImage: 'https://pixabay.com/get/g4ae9d08f517456e145051a27a85e3f32dead358dd08125bf035b5516db999960571e19e3c4f062f968dc9de14bd10b48c625a1d3c05a5315f9280e50a7d9f435_1280.jpg',
        userId: 'user1',
        messages: [
          ChatMessage(
            id: '1',
            chatId: 'chat_2',
            senderId: 'chef3',
            senderName: 'Hiroshi Tanaka',
            content: 'Thank you for your interest in my sushi experience! I\'d be happy to prepare an authentic Japanese dinner for your group.',
            timestamp: DateTime.now().subtract(const Duration(hours: 3)),
            isFromUser: false,
            isRead: false,
          ),
        ],
        lastActivity: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Messages',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: chats.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No messages yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start a conversation with a chef',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return _buildChatTile(context, chat);
              },
            ),
    );
  }

  Widget _buildChatTile(BuildContext context, Chat chat) {
    final theme = Theme.of(context);
    final lastMessage = chat.lastMessage;
    final unreadCount = chat.unreadCount;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(chat.chefImage),
            onBackgroundImageError: (error, stackTrace) {},
            child: const Icon(Icons.person),
          ),
          if (unreadCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Text(
                  unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      title: Text(
        chat.chefName,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle: lastMessage != null
          ? Text(
              lastMessage.content,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: lastMessage != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formatTime(lastMessage.timestamp),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: unreadCount > 0 
                        ? theme.colorScheme.primary 
                        : Colors.grey.shade500,
                    fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                if (lastMessage.isFromUser && lastMessage.isRead)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Icon(
                      Icons.done_all,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                  ),
              ],
            )
          : null,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chefId: chat.chefId,
              chefName: chat.chefName,
              chefImage: chat.chefImage,
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d';
      } else {
        return '${dateTime.day}/${dateTime.month}';
      }
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}