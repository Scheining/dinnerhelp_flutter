import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:homechef/providers/notification_provider.dart';
import 'package:homechef/providers/booking_provider.dart';
import 'package:homechef/providers/messaging_provider.dart';
import 'package:homechef/providers/auth_provider.dart';
import 'package:homechef/screens/chat_screen.dart';
import 'package:homechef/screens/archived_messages_screen.dart';
import 'package:homechef/models/conversation_simple.dart';
import 'package:intl/intl.dart';

// Notification item model
class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.data,
  });
}

// Chat message model
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });
}

// Mock providers - replace with actual implementation
final notificationsProvider = Provider<List<NotificationItem>>((ref) {
  return [];
});

final messagesProvider = Provider<List<ChatMessage>>((ref) {
  return [];
});

final markAllNotificationsAsReadProvider = Provider<Function()>((ref) {
  return () {};
});

final markAllMessagesAsReadProvider = Provider<Function()>((ref) {
  return () {};
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider);
  return notifications.where((n) => !n.isRead).length;
});

final unreadMessagesCountProvider = Provider<int>((ref) {
  final messages = ref.watch(messagesProvider);
  return messages.where((m) => !m.isRead).length;
});

class NotificationsScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;
  
  const NotificationsScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2, 
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _tabController.addListener(() {
      if (mounted) {
        setState(() {}); // Rebuild to show/hide archive icon
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark 
          ? theme.scaffoldBackgroundColor 
          : Colors.grey.shade50,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: false,
              pinned: true,
              snap: false,
              expandedHeight: 90.0,
              backgroundColor: theme.brightness == Brightness.dark 
                  ? theme.appBarTheme.backgroundColor 
                  : Colors.white,
              elevation: 0,
              collapsedHeight: kToolbarHeight,
              title: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: 1.0,
                child: Text(
                  widget.initialTabIndex == 1 ? 'Beskeder' : 'Notifikationer',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.brightness == Brightness.dark 
                        ? Colors.white 
                        : Colors.black,
                  ),
                ),
              ),
              centerTitle: false,
              actions: [
                // Archive icon - only show in Messages tab
                if (_tabController.index == 1)
                  IconButton(
                    icon: Icon(Icons.archive_outlined, 
                      color: theme.brightness == Brightness.dark ? Colors.white : Colors.black),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ArchivedMessagesScreen(),
                        ),
                      );
                    },
                    tooltip: 'Slettede beskeder',
                  ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: theme.brightness == Brightness.dark ? Colors.white : Colors.black),
                  onSelected: (value) {
                    if (value == 'mark_all_read') {
                      if (_tabController.index == 0) {
                        ref.read(markAllNotificationsAsReadProvider)();
                      } else {
                        ref.read(markAllMessagesAsReadProvider)();
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'mark_all_read',
                      child: Text('Markér alle som læst'),
                    ),
                  ],
                ),
              ],
              flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final bool isCollapsed = constraints.biggest.height <= kToolbarHeight + 48;
                  return FlexibleSpaceBar(
                    centerTitle: false,
                    titlePadding: EdgeInsets.only(
                      left: 20,
                      bottom: isCollapsed ? 48 : 16,
                    ),
                    title: null,
                    background: Container(
                      color: theme.brightness == Brightness.dark 
                          ? theme.appBarTheme.backgroundColor 
                          : Colors.white,
                    ),
                  );
                },
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  color: theme.brightness == Brightness.dark 
                      ? theme.appBarTheme.backgroundColor 
                      : Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Notifikationer'),
                            const SizedBox(width: 8),
                            Consumer(
                              builder: (context, ref, child) {
                                final unreadCount = ref.watch(unreadNotificationsCountProvider);
                                if (unreadCount > 0) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          unreadCount > 99 ? '99+' : unreadCount.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                              },
                            ),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Beskeder'),
                            const SizedBox(width: 8),
                            Consumer(
                              builder: (context, ref, child) {
                                final unreadCount = ref.watch(unreadMessagesCountProvider);
                                if (unreadCount > 0) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          unreadCount > 99 ? '99+' : unreadCount.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                    labelColor: theme.colorScheme.primary,
                    unselectedLabelColor: theme.brightness == Brightness.dark 
                        ? Colors.grey.shade400 
                        : Colors.grey.shade600,
                    indicatorColor: theme.colorScheme.primary,
                    indicatorWeight: 3,
                    dividerColor: Colors.transparent,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Notifications Tab
            Consumer(
            builder: (context, ref, child) {
              final notifications = ref.watch(notificationsProvider);
              
              if (notifications.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Ingen notifikationer',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Du vil modtage notifikationer her',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 7),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return Slidable(
                        key: Key(notification.id),
                        endActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                // Delete notification
                                _deleteNotification(notification.id);
                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Slet',
                            ),
                          ],
                        ),
                        child: _NotificationTile(
                          notification: notification,
                          onTap: () async {
                            if (!notification.isRead) {
                              // Mark notification as read - would normally update Supabase
                              await Future.delayed(const Duration(milliseconds: 500));
                            }
                            // Handle notification tap - navigate to relevant screen
                            _handleNotificationTap(context, notification);
                          },
                        ),
                      );
                    },
                  );
            },
          ),
          
          // Messages Tab
          Consumer(
            builder: (context, ref, child) {
              final conversationsAsync = ref.watch(unifiedConversationsNotifierProvider);
              
              return conversationsAsync.when(
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
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Ingen beskeder',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Dine beskeder vil blive vist her',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade500,
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
                              onPressed: (context) {
                                // Delete conversation (hides it from view)
                                // Determine the correct ID based on conversation type
                                final conversationId = conversation.type == ConversationType.inquiry
                                    ? conversation.inquiryId!
                                    : conversation.bookingId!;
                                _deleteMessage(conversationId, conversation);
                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Slet',
                            ),
                          ],
                        ),
                        child: _ConversationTile(
                          conversation: conversation,
                          onTap: () async {
                            // Navigate to chat screen based on conversation type
                            if (conversation.type == ConversationType.inquiry) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    chefId: conversation.chefId!,
                                    chefName: conversation.otherPersonName ?? 'Kok',
                                    chefImage: conversation.otherPersonImage ?? '',
                                    conversationType: ConversationType.inquiry,
                                    conversationId: conversation.inquiryId,
                                  ),
                                ),
                              );
                            } else {
                              // For booking conversations, pass the booking ID
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    chefId: conversation.chefId!,
                                    chefName: conversation.otherPersonName ?? 'Kok',
                                    chefImage: conversation.otherPersonImage ?? '',
                                    conversationType: ConversationType.booking,
                                    conversationId: conversation.bookingId,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
          ],
        ),
      ),
    );
  }

  void _handleNotificationTap(BuildContext context, NotificationItem notification) {
    // Navigate based on notification type
    if (notification.data != null && notification.data!['bookingId'] != null) {
      // Set the selected booking ID and navigate to bookings screen
      ref.read(selectedBookingIdProvider.notifier).state = notification.data!['bookingId'];
      context.go('/bookings');
    }
  }

  void _handleMessageTap(BuildContext context, ChatMessage message) {
    // Show message dialog
    showDialog(
      context: context,
      builder: (context) => _MessageDetailDialog(message: message),
    );
  }
  
  void _handleBookingConversation(BuildContext context, UnifiedConversation conversation) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Navigate to chat screen for booking conversations as well
    // They use the same chat infrastructure
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          chefId: conversation.chefId!,
          chefName: conversation.otherPersonName ?? 'Ukendt',
          chefImage: conversation.otherPersonImage ?? '',
        ),
      ),
    );
  }
  
  void _archiveNotification(String notificationId) async {
    // Mock implementation - would normally update Supabase
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notifikation arkiveret'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
  
  void _deleteNotification(String notificationId) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Slet notifikation'),
        content: const Text('Er du sikker på, at du vil slette denne notifikation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuller'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Slet'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      // Mock implementation - would normally update Supabase
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notifikation slettet'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
  
  void _archiveMessage(String conversationId, UnifiedConversation conversation) async {
    // Use the real provider method to archive the conversation
    final success = await ref
        .read(unifiedConversationsNotifierProvider.notifier)
        .archiveConversation(conversationId, conversation.type);
    
    if (mounted) {
      if (success) {
        // Force refresh the conversations list to remove archived item
        ref.invalidate(unifiedConversationsNotifierProvider);
        
        // Show success message with undo option
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Besked arkiveret'),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Fortryd',
              onPressed: () async {
                // Undo the archive action
                await ref
                    .read(unifiedConversationsNotifierProvider.notifier)
                    .unarchiveConversation(conversationId, conversation.type);
                // Refresh list after undo
                ref.invalidate(unifiedConversationsNotifierProvider);
              },
            ),
          ),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kunne ikke arkivere besked'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _deleteMessage(String conversationId, UnifiedConversation conversation) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fjern besked'),
        content: const Text('Beskeden fjernes fra din liste. Den vises igen hvis du modtager et nyt svar.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuller'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Fjern'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      // Use the real provider method to delete the conversation
      final success = await ref
          .read(unifiedConversationsNotifierProvider.notifier)
          .deleteConversation(conversationId, conversation.type);
      
      if (mounted) {
        if (success) {
          // Force refresh the conversations list to remove deleted item
          ref.invalidate(unifiedConversationsNotifierProvider);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Besked fjernet'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kunne ikke fjerne besked'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationItem notification;
  final Function() onTap;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('d MMM');
    
    final now = DateTime.now();
    final isToday = notification.createdAt.day == now.day &&
        notification.createdAt.month == now.month &&
        notification.createdAt.year == now.year;
    
    final timeText = isToday
        ? timeFormat.format(notification.createdAt)
        : dateFormat.format(notification.createdAt);

    return InkWell(
      onTap: onTap,
      child: Container(
        color: notification.isRead ? null : theme.colorScheme.primary.withOpacity(0.05),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getNotificationColor(notification.type).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getNotificationIcon(notification.type),
                color: _getNotificationColor(notification.type),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getNotificationTitle(notification.type),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.brightness == Brightness.dark 
                          ? Colors.grey.shade300 
                          : Colors.grey.shade700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.brightness == Brightness.dark 
                          ? Colors.grey.shade500 
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'booking_confirmation':
        return Icons.check_circle_outline;
      case 'booking_cancelled':
        return Icons.cancel_outlined;
      case 'booking_reminder':
        return Icons.access_time;
      case 'payment_success':
        return Icons.payment;
      case 'new_review':
        return Icons.star_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'booking_confirmation':
        return Colors.green;
      case 'booking_cancelled':
        return Colors.red;
      case 'booking_reminder':
        return Colors.orange;
      case 'payment_success':
        return Colors.blue;
      case 'new_review':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  String _getNotificationTitle(String type) {
    switch (type) {
      case 'booking_confirmation':
        return 'Booking bekræftet';
      case 'booking_cancelled':
        return 'Booking annulleret';
      case 'booking_reminder':
        return 'Booking påmindelse';
      case 'payment_success':
        return 'Betaling gennemført';
      case 'new_review':
        return 'Ny anmeldelse';
      default:
        return 'Notifikation';
    }
  }
}

class _ConversationTile extends StatelessWidget {
  final UnifiedConversation conversation;
  final Function() onTap;

  const _ConversationTile({
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('d MMM');
    
    final now = DateTime.now();
    final lastMessageTime = conversation.lastMessageAt ?? DateTime.now();
    final isToday = lastMessageTime.day == now.day &&
        lastMessageTime.month == now.month &&
        lastMessageTime.year == now.year;
    
    final timeText = isToday
        ? timeFormat.format(lastMessageTime)
        : dateFormat.format(lastMessageTime);

    return InkWell(
      onTap: onTap,
      child: Container(
        color: (conversation.unreadCount > 0) ? theme.colorScheme.primary.withOpacity(0.05) : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: conversation.otherPersonImage?.isNotEmpty == true
                      ? NetworkImage(conversation.otherPersonImage!)
                      : null,
                  backgroundColor: theme.colorScheme.primary,
                  child: conversation.otherPersonImage?.isEmpty ?? true
                      ? Text(
                          conversation.otherPersonName?.isNotEmpty == true 
                              ? conversation.otherPersonName![0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                // Type indicator badge
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: conversation.type == ConversationType.booking
                          ? Colors.orange
                          : theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.scaffoldBackgroundColor,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      conversation.type == ConversationType.booking
                          ? Icons.calendar_today
                          : Icons.chat_bubble_outline,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.otherPersonName ?? 'Ukendt',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: (conversation.unreadCount > 0) ? FontWeight.bold : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        timeText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (conversation.type == ConversationType.booking && conversation.bookingStatus != null) ...[
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getBookingStatusColor(conversation.bookingStatus!),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Expanded(
                        child: Text(
                          conversation.lastMessage ?? 'Start en samtale',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade700,
                            fontWeight: (conversation.unreadCount > 0) ? FontWeight.w500 : FontWeight.normal,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (conversation.unreadCount > 0)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  conversation.unreadCount > 99 ? '99+' : conversation.unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
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

class _MessageTile extends StatelessWidget {
  final ChatMessage message;
  final Function() onTap;

  const _MessageTile({
    required this.message,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('d MMM');
    
    final now = DateTime.now();
    final isToday = message.timestamp.day == now.day &&
        message.timestamp.month == now.month &&
        message.timestamp.year == now.year;
    
    final timeText = isToday
        ? timeFormat.format(message.timestamp)
        : dateFormat.format(message.timestamp);

    return InkWell(
      onTap: onTap,
      child: Container(
        color: message.isRead ? null : theme.colorScheme.primary.withOpacity(0.05),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                message.senderName.isNotEmpty 
                    ? message.senderName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message.senderName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: message.isRead ? FontWeight.normal : FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        timeText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                      fontWeight: message.isRead ? FontWeight.normal : FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (!message.isRead)
              Container(
                margin: const EdgeInsets.only(left: 8),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MessageDetailDialog extends ConsumerWidget {
  final ChatMessage message;

  const _MessageDetailDialog({required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('d MMM yyyy, HH:mm');
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    message.senderName.isNotEmpty 
                        ? message.senderName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.senderName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateFormat.format(message.timestamp),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(
                message.message,
                style: theme.textTheme.bodyLarge,
              ),
            ),
            // TODO: Add booking-related actions if needed
            if (false) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // TODO: Navigate to bookings screen if needed
                    // ref.read(selectedBookingIdProvider.notifier).state = message.bookingId;
                    // context.go('/bookings');
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Vis booking'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}