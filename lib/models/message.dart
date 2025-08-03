class ChatMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isFromUser;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    required this.isFromUser,
    required this.isRead,
  });

  static List<ChatMessage> getSampleMessages(String chatId) {
    return [
      ChatMessage(
        id: '1',
        chatId: chatId,
        senderId: 'chef1',
        senderName: 'Lars Nielsen',
        content: 'Hi! Thank you for your booking request. I\'d be happy to cook for you and your guests.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isFromUser: false,
        isRead: true,
      ),
      ChatMessage(
        id: '2',
        chatId: chatId,
        senderId: 'user1',
        senderName: 'You',
        content: 'Great! I\'m looking forward to trying your Nordic cuisine. Do you have any vegetarian options?',
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
        isFromUser: true,
        isRead: true,
      ),
      ChatMessage(
        id: '3',
        chatId: chatId,
        senderId: 'chef1',
        senderName: 'Lars Nielsen',
        content: 'Absolutely! I can prepare a beautiful vegetarian tasting menu featuring seasonal Danish vegetables, wild mushrooms, and locally sourced ingredients.',
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        isFromUser: false,
        isRead: true,
      ),
      ChatMessage(
        id: '4',
        chatId: chatId,
        senderId: 'user1',
        senderName: 'You',
        content: 'That sounds perfect! What time would you arrive for the dinner service?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        isFromUser: true,
        isRead: true,
      ),
      ChatMessage(
        id: '5',
        chatId: chatId,
        senderId: 'chef1',
        senderName: 'Lars Nielsen',
        content: 'I usually arrive 2 hours before service to prep and set up. For a 7 PM dinner, I\'d arrive around 5 PM. Does that work for you?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        isFromUser: false,
        isRead: false,
      ),
    ];
  }
}

class Chat {
  final String id;
  final String chefId;
  final String chefName;
  final String chefImage;
  final String userId;
  final List<ChatMessage> messages;
  final DateTime lastActivity;

  const Chat({
    required this.id,
    required this.chefId,
    required this.chefName,
    required this.chefImage,
    required this.userId,
    required this.messages,
    required this.lastActivity,
  });

  ChatMessage? get lastMessage => messages.isNotEmpty ? messages.last : null;
  int get unreadCount => messages.where((msg) => !msg.isFromUser && !msg.isRead).length;
}