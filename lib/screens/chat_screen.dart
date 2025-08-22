import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homechef/models/conversation_simple.dart';
import 'package:homechef/providers/messaging_provider.dart';
import 'package:homechef/providers/auth_provider.dart';
import 'package:homechef/core/utils/contact_info_detector.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chefId;
  final String chefName;
  final String chefImage;
  final ConversationType? conversationType;
  final String? conversationId;  // inquiryId or bookingId

  const ChatScreen({
    super.key,
    required this.chefId,
    required this.chefName,
    required this.chefImage,
    this.conversationType,
    this.conversationId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _conversationId;
  bool _isLoading = true;
  bool _isSending = false;
  ConversationType _conversationType = ConversationType.inquiry; // Default to inquiry

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    // Set conversation type if provided
    if (widget.conversationType != null) {
      _conversationType = widget.conversationType!;
    }
    
    // If we already have a conversationId, use it
    if (widget.conversationId != null) {
      setState(() {
        _conversationId = widget.conversationId;
        _isLoading = false;
      });
      
      // Scroll to bottom after messages load
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } else {
      // Otherwise, create a new inquiry (default behavior for new chats)
      final conversationsNotifier = ref.read(unifiedConversationsNotifierProvider.notifier);
      final conversationId = await conversationsNotifier.getOrCreateInquiry(widget.chefId);
      
      if (conversationId != null && mounted) {
        setState(() {
          _conversationId = conversationId;
          _conversationType = ConversationType.inquiry;
          _isLoading = false;
        });
        
        // Scroll to bottom after messages load
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _conversationId == null || _isSending) return;

    final messageText = _messageController.text.trim();
    
    // Validate message for contact information
    final validation = ContactInfoDetector.validate(messageText);
    
    if (!validation.isValid) {
      // Show error dialog for prohibited content
      _showContactInfoError(validation.issues);
      return;
    }
    
    if (validation.hasWarning) {
      // Show warning dialog for suspicious content
      final shouldSend = await _showContactInfoWarning(validation.issues);
      if (!shouldSend) return;
    }

    setState(() {
      _isSending = true;
    });

    bool success = false;
    
    if (_conversationType == ConversationType.booking) {
      // For booking messages, we need the receiver ID (the other person in the conversation)
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser != null) {
        // Determine receiver ID based on current user
        // In a booking conversation, if current user is the chef, receiver is the customer, and vice versa
        // For now, we'll use a simplified approach - this would need proper implementation
        final bookingMessagesNotifier = ref.read(bookingMessagesNotifierProvider(_conversationId!).notifier);
        // TODO: Get proper receiver ID from booking data
        success = await bookingMessagesNotifier.sendMessage(messageText, widget.chefId);
      }
    } else {
      final messagesNotifier = ref.read(inquiryMessagesNotifierProvider(_conversationId!).notifier);
      success = await messagesNotifier.sendMessage(messageText);
    }

    if (success) {
      _messageController.clear();
      _scrollToBottom();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kunne ikke sende besked. Prøv igen.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() {
      _isSending = false;
    });
  }

  void _showContactInfoError(List<String> issues) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400),
            const SizedBox(width: 8),
            Text(
              'Besked blokeret',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Din besked indeholder information der ikke er tilladt:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            ...issues.map((issue) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', 
                    style: TextStyle(
                      color: Colors.red.shade400,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      issue,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark 
                    ? Colors.blue.shade900.withOpacity(0.3)
                    : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark 
                      ? Colors.blue.shade700 
                      : Colors.blue.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline, 
                    color: isDark ? Colors.blue.shade300 : Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Al kommunikation skal foregå gennem DinnerHelp for din sikkerhed.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.blue.shade200 : Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Forstået',
              style: TextStyle(
                color: isDark ? Colors.white70 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showContactInfoWarning(List<String> issues) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade600),
            const SizedBox(width: 8),
            Text(
              'Advarsel',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Din besked ser ud til at indeholde kontaktoplysninger.',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark 
                    ? Colors.orange.shade900.withOpacity(0.3)
                    : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark 
                      ? Colors.orange.shade700 
                      : Colors.orange.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Husk at:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.orange.shade200 : Colors.orange.shade900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('• Deling af telefonnumre er ikke tilladt',
                    style: TextStyle(
                      color: isDark ? Colors.orange.shade200 : Colors.orange.shade900,
                    ),
                  ),
                  Text('• Deling af email adresser er ikke tilladt',
                    style: TextStyle(
                      color: isDark ? Colors.orange.shade200 : Colors.orange.shade900,
                    ),
                  ),
                  Text('• Deling af sociale medier er ikke tilladt',
                    style: TextStyle(
                      color: isDark ? Colors.orange.shade200 : Colors.orange.shade900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Er du sikker på at du vil sende denne besked?',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Annuller',
              style: TextStyle(
                color: isDark ? Colors.white70 : null,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Send alligevel'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentUser = ref.watch(currentUserProvider).value;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          title: Text(widget.chefName),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_conversationId == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          title: Text(widget.chefName),
        ),
        body: const Center(
          child: Text('Kunne ikke starte samtale'),
        ),
      );
    }

    // Handle both inquiry and booking messages
    final dynamic messagesAsync = _conversationType == ConversationType.booking
        ? ref.watch(bookingMessagesNotifierProvider(_conversationId!))
        : ref.watch(inquiryMessagesNotifierProvider(_conversationId!));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: widget.chefImage.isNotEmpty 
                  ? NetworkImage(widget.chefImage)
                  : null,
              child: widget.chefImage.isEmpty 
                  ? const Icon(Icons.person, size: 18)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chefName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Kok',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Info banner about contact info policy
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.blue.shade50.withOpacity(isDark ? 0.1 : 1),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Deling af kontaktoplysninger er ikke tilladt',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _conversationType == ConversationType.booking
                ? _buildBookingMessagesView(messagesAsync as AsyncValue<List<Map<String, dynamic>>>, currentUser, isDark)
                : _buildInquiryMessagesView(messagesAsync as AsyncValue<List<InquiryMessage>>, currentUser, isDark),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF252325) : theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark 
                            ? Colors.grey.shade800.withOpacity(0.5)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Skriv en besked...',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          hintStyle: TextStyle(
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: _isSending 
                          ? Colors.grey 
                          : theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _isSending ? null : _sendMessage,
                      icon: _isSending
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.onPrimary,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.send,
                              color: theme.colorScheme.onPrimary,
                              size: 20,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingMessagesView(AsyncValue<List<Map<String, dynamic>>> messagesAsync, User? currentUser, bool isDark) {
    return messagesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Fejl: ${error.toString()}'),
      ),
      data: (messages) {
        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: widget.chefImage.isNotEmpty
                      ? NetworkImage(widget.chefImage)
                      : null,
                  child: widget.chefImage.isEmpty
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.chefName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start en samtale',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        // Scroll to bottom after messages load
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isFromUser = message['sender_id'] == currentUser?.id;
            final createdAt = DateTime.parse(message['created_at']);
            final showDate = index == 0 || 
                !_isSameDay(DateTime.parse(messages[index - 1]['created_at']), createdAt);

            return Column(
              children: [
                if (showDate)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      _formatDate(createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                  ),
                _buildBookingMessageBubble(message, isFromUser, isDark),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildInquiryMessagesView(AsyncValue<List<InquiryMessage>> messagesAsync, User? currentUser, bool isDark) {
    return messagesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Fejl: ${error.toString()}'),
      ),
      data: (messages) {
        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: widget.chefImage.isNotEmpty
                      ? NetworkImage(widget.chefImage)
                      : null,
                  child: widget.chefImage.isEmpty
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.chefName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start en samtale',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        // Mark unread messages as read
        final unreadMessages = messages
            .where((m) => !m.isRead && m.senderId != currentUser?.id)
            .map((m) => m.id)
            .toList();
        
        if (unreadMessages.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(inquiryMessagesNotifierProvider(_conversationId!).notifier)
                .markMessagesAsRead(unreadMessages);
          });
        }

        // Scroll to bottom after messages load
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isFromUser = message.senderId == currentUser?.id;
            final showDate = index == 0 || 
                !_isSameDay(messages[index - 1].createdAt, message.createdAt);

            return Column(
              children: [
                if (showDate)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      _formatDate(message.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                  ),
                _buildMessageBubble(message, isFromUser, isDark),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildBookingMessageBubble(Map<String, dynamic> message, bool isFromUser, bool isDark) {
    final content = message['content'] ?? '';
    final createdAt = DateTime.parse(message['created_at']);
    final isRead = message['is_read'] ?? false;
    
    // Get current user's profile image
    final currentUser = ref.read(currentUserProvider).value;
    final userProfileImage = currentUser?.userMetadata?['profile-image-url'] as String?;
    
    return Align(
      alignment: isFromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Chef's profile image on the left for their messages
          if (!isFromUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: widget.chefImage.isNotEmpty
                  ? NetworkImage(widget.chefImage)
                  : null,
              child: widget.chefImage.isEmpty
                  ? Text(
                      widget.chefName.isNotEmpty ? widget.chefName[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          
          // Message bubble
          Flexible(
            child: Container(
              margin: EdgeInsets.only(
                left: isFromUser ? 64 : 0,
                right: isFromUser ? 0 : 64,
                bottom: 8,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isFromUser
                    ? Theme.of(context).colorScheme.primary
                    : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isFromUser ? 16 : 4),
                  bottomRight: Radius.circular(isFromUser ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content,
                    style: TextStyle(
                      color: isFromUser
                          ? Colors.white
                          : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('HH:mm').format(createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: isFromUser
                          ? Colors.white.withOpacity(0.7)
                          : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Read receipt - small user profile image when message is read
          if (isFromUser && isRead) ...[
            const SizedBox(width: 4),
            CircleAvatar(
              radius: 8,
              backgroundImage: widget.chefImage.isNotEmpty
                  ? NetworkImage(widget.chefImage)
                  : null,
              child: widget.chefImage.isEmpty
                  ? Text(
                      widget.chefName.isNotEmpty ? widget.chefName[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 6, color: Colors.white),
                    )
                  : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageBubble(InquiryMessage message, bool isFromUser, bool isDark) {
    // Get current user's profile image
    final currentUser = ref.read(currentUserProvider).value;
    final userProfileImage = currentUser?.userMetadata?['profile-image-url'] as String?;
    
    return Align(
      alignment: isFromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Chef's profile image on the left for their messages
          if (!isFromUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: widget.chefImage.isNotEmpty
                  ? NetworkImage(widget.chefImage)
                  : null,
              child: widget.chefImage.isEmpty
                  ? Text(
                      widget.chefName.isNotEmpty ? widget.chefName[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          
          // Message bubble
          Flexible(
            child: Container(
              margin: EdgeInsets.only(
                left: isFromUser ? 64 : 0,
                right: isFromUser ? 0 : 64,
                bottom: 8,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isFromUser
                    ? Theme.of(context).colorScheme.primary
                    : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isFromUser ? 16 : 4),
                  bottomRight: Radius.circular(isFromUser ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isFromUser
                          ? Colors.white
                          : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('HH:mm').format(message.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: isFromUser
                          ? Colors.white.withOpacity(0.7)
                          : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Read receipt - small chef profile image when message is read
          if (isFromUser && message.isRead) ...[
            const SizedBox(width: 4),
            CircleAvatar(
              radius: 8,
              backgroundImage: widget.chefImage.isNotEmpty
                  ? NetworkImage(widget.chefImage)
                  : null,
              child: widget.chefImage.isEmpty
                  ? Text(
                      widget.chefName.isNotEmpty ? widget.chefName[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 6, color: Colors.white),
                    )
                  : null,
            ),
          ],
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (_isSameDay(date, now)) {
      return 'I dag';
    } else if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return 'I går';
    } else {
      return DateFormat('d. MMMM yyyy', 'da_DK').format(date);
    }
  }
}