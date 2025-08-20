import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:homechef/providers/notification_provider.dart';
import 'package:homechef/providers/booking_provider.dart';
import 'package:intl/intl.dart';

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
      backgroundColor: Colors.grey.shade50,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: false,
              pinned: true,
              snap: false,
              expandedHeight: 90.0,
              backgroundColor: Colors.white,
              elevation: 0,
              collapsedHeight: kToolbarHeight,
              title: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: 1.0,
                child: Text(
                  widget.initialTabIndex == 1 ? 'Beskeder' : 'Notifikationer',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              centerTitle: false,
              actions: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.black),
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
                      color: Colors.white,
                    ),
                  );
                },
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  color: Colors.white,
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
                                return unreadCount.when(
                                  data: (count) {
                                    if (count > 0) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          count > 99 ? '99+' : count.toString(),
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
                                  loading: () => const SizedBox.shrink(),
                                  error: (error, stack) => const SizedBox.shrink(),
                                );
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
                                return unreadCount.when(
                                  data: (count) {
                                    if (count > 0) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          count > 99 ? '99+' : count.toString(),
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
                                  loading: () => const SizedBox.shrink(),
                                  error: (error, stack) => const SizedBox.shrink(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                    labelColor: theme.colorScheme.primary,
                    unselectedLabelColor: Colors.grey.shade600,
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
              final notificationsAsync = ref.watch(notificationsProvider);
              
              return notificationsAsync.when(
                data: (notifications) {
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
                                // Archive notification
                                _archiveNotification(notification.id);
                              },
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              icon: Icons.archive,
                              label: 'Arkivér',
                            ),
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
                              await ref.read(markNotificationAsReadProvider)(notification.id);
                            }
                            // Handle notification tap - navigate to relevant screen
                            _handleNotificationTap(context, notification);
                          },
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Fejl ved indlæsning',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.red.shade600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () {
                          ref.invalidate(notificationsProvider);
                        },
                        child: const Text('Prøv igen'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          // Messages Tab
          Consumer(
            builder: (context, ref, child) {
              final messagesAsync = ref.watch(messagesProvider);
              
              return messagesAsync.when(
                data: (messages) {
                  if (messages.isEmpty) {
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
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return Slidable(
                        key: Key(message.id),
                        endActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                // Archive message
                                _archiveMessage(message.id);
                              },
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              icon: Icons.archive,
                              label: 'Arkivér',
                            ),
                            SlidableAction(
                              onPressed: (context) {
                                // Delete message
                                _deleteMessage(message.id);
                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Slet',
                            ),
                          ],
                        ),
                        child: _MessageTile(
                          message: message,
                          onTap: () async {
                            // Show the message dialog first
                            _handleMessageTap(context, message);
                            
                            // Then mark as read if it wasn't already
                            if (!message.isRead) {
                              await ref.read(markMessageAsReadProvider)(message.id);
                            }
                          },
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Fejl ved indlæsning',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.red.shade600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () {
                          ref.invalidate(messagesProvider);
                        },
                        child: const Text('Prøv igen'),
                      ),
                    ],
                  ),
                ),
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
    if (notification.bookingId != null) {
      // Set the selected booking ID and navigate to bookings screen
      ref.read(selectedBookingIdProvider.notifier).state = notification.bookingId;
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
  
  void _archiveNotification(String notificationId) async {
    try {
      // Archive the notification (mark as archived in database)
      await ref.read(archiveNotificationProvider)(notificationId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notifikation arkiveret'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kunne ikke arkivere notifikation'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
      try {
        await ref.read(deleteNotificationProvider)(notificationId);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notifikation slettet'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kunne ikke slette notifikation'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
  
  void _archiveMessage(String messageId) async {
    try {
      // Archive the message (mark as archived in database)
      await ref.read(archiveMessageProvider)(messageId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Besked arkiveret'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kunne ikke arkivere besked'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _deleteMessage(String messageId) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Slet besked'),
        content: const Text('Er du sikker på, at du vil slette denne besked?'),
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
      try {
        await ref.read(deleteMessageProvider)(messageId);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Besked slettet'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kunne ikke slette besked'),
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
                    notification.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade500,
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
    final isToday = message.createdAt.day == now.day &&
        message.createdAt.month == now.month &&
        message.createdAt.year == now.year;
    
    final timeText = isToday
        ? timeFormat.format(message.createdAt)
        : dateFormat.format(message.createdAt);

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
                    message.content,
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
                        dateFormat.format(message.createdAt),
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
                message.content,
                style: theme.textTheme.bodyLarge,
              ),
            ),
            if (message.bookingId != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Set the selected booking ID and navigate to bookings screen
                    ref.read(selectedBookingIdProvider.notifier).state = message.bookingId;
                    context.go('/bookings');
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