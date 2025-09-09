# DinnerHelp Message System Technical Documentation
## For Web Platform Integration

This document provides a comprehensive technical overview of the message system architecture in the DinnerHelp Flutter native app, including database structure, message flows, edge function integrations, and notification pipelines.

---

## 1. System Architecture Overview

### 1.1 Message Types

The system supports two distinct conversation types:

1. **Inquiries** - Pre-booking conversations between users and chefs
   - Initial contact before booking
   - General questions about services
   - Price negotiations

2. **Booking Chats** - Post-booking conversations
   - Booking-specific discussions
   - Real-time updates during service
   - Post-service communication

### 1.2 Database Schema

```
┌─────────────────────────────────────────────────────┐
│                   CONVERSATIONS                      │
├─────────────────────────────────────────────────────┤
│                                                      │
│  ┌──────────────┐         ┌──────────────┐         │
│  │   inquiries  │         │   bookings   │         │
│  └──────┬───────┘         └──────┬───────┘         │
│         │                         │                  │
│         ▼                         ▼                  │
│  ┌──────────────┐         ┌──────────────┐         │
│  │inquiry_messages         │chat_messages │         │
│  └──────────────┘         └──────────────┘         │
│                                                      │
│  ┌────────────────────────────────────────┐        │
│  │     conversation_visibility            │        │
│  │  (per-user hide/archive settings)      │        │
│  └────────────────────────────────────────┘        │
└─────────────────────────────────────────────────────┘
```

#### Key Tables:

**inquiries**
- `id` (uuid, PK)
- `user_id` (uuid, FK → profiles.id)
- `chef_id` (uuid, FK → chefs.id)
- `last_message` (text)
- `last_message_at` (timestamp)
- `is_archived` (boolean)
- `is_deleted` (boolean)

**inquiry_messages**
- `id` (uuid, PK)
- `inquiry_id` (uuid, FK → inquiries.id)
- `sender_id` (uuid, FK → profiles.id)
- `content` (text)
- `is_read` (boolean)
- `is_flagged` (boolean)
- `flagged_reason` (text)
- `created_at` (timestamp)

**chat_messages** (for bookings)
- `id` (uuid, PK)
- `booking_id` (uuid, FK → bookings.id)
- `sender_id` (uuid, FK → profiles.id)
- `receiver_id` (uuid, FK → profiles.id)
- `content` (text)
- `is_read` (boolean)
- `is_archived` (boolean)
- `created_at` (timestamp)

**conversation_visibility**
- `id` (uuid, PK)
- `user_id` (uuid, FK → profiles.id)
- `conversation_id` (uuid)
- `conversation_type` (enum: 'inquiry' | 'booking')
- `last_hidden_message_at` (timestamp)

---

## 2. Message Flow & Processing

### 2.1 Sending a Message - Step by Step

```
USER ACTION                    FLUTTER APP                    SUPABASE                    EDGE FUNCTIONS
     │                              │                             │                             │
     ├──[1. Type Message]──────────►│                             │                             │
     │                              │                             │                             │
     │                              ├──[2. Validate Content]     │                             │
     │                              │   ContactInfoDetector       │                             │
     │                              │   - Check emails            │                             │
     │                              │   - Check phone numbers     │                             │
     │                              │   - Check social media      │                             │
     │                              │                             │                             │
     │                              ├──[3. Show Warning/Error]   │                             │
     │◄─────────────────────────────┤   (if needed)              │                             │
     │                              │                             │                             │
     ├──[4. Confirm Send]──────────►│                             │                             │
     │                              │                             │                             │
     │                              ├──[5. Insert Message]───────►│                             │
     │                              │                             ├──[6. Trigger]──────────────►│
     │                              │                             │   Database Trigger           │
     │                              │                             │   - Update last_message      │
     │                              │                             │   - Update timestamps        │
     │                              │                             │                             │
     │                              │◄────[7. Real-time Update]──┤                             │
     │                              │                             │                             │
     │                              ├──[8. Check Recipient]      │                             │
     │                              │                             │                             │
     │                              ├──[9. Send Notification]────►│──[10. Trigger Function]────►│
     │                              │                             │                             │
     │                              │                             │                        [OneSignal API]
     │                              │                             │                             │
     │◄─────[11. Message Delivered]─┤                             │                             │
```

### 2.2 Contact Information Protection

The app implements strict contact information filtering through `ContactInfoDetector`:

```dart
// Detection Patterns:
- Email: /\b[A-Za-z0-9._%+-]+[@＠][A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b/
- Phone: Danish (+45), US, and international formats
- Social Media: @handles, profile URLs, platform names + usernames

// Validation Levels:
1. BLOCKED - Direct contact info detected → Message cannot be sent
2. WARNING - Suspicious keywords → User prompted to confirm
3. ALLOWED - Clean message → Sent normally
```

### 2.3 Real-time Subscriptions

```dart
// Inquiry Messages Subscription
supabase
  .from('inquiry_messages')
  .stream(primaryKey: ['id'])
  .eq('inquiry_id', inquiryId)
  .order('created_at')
  .listen((data) => updateUI());

// Booking Messages Subscription
supabase
  .from('chat_messages')
  .stream(primaryKey: ['id'])
  .eq('booking_id', bookingId)
  .order('created_at')
  .listen((data) => updateUI());
```

---

## 3. Edge Functions Integration

### 3.1 Message-Related Edge Functions

| Function | Trigger | Purpose |
|----------|---------|---------|
| `trigger_booking_notification` | RPC call from app | Sends booking-related notifications |
| `send_message_notification` | Database trigger on new message | Sends push notification for new messages |
| `flag_inappropriate_content` | RPC call on flagged message | Processes content moderation |
| `archive_conversation` | RPC call from app | Handles conversation archiving |

### 3.2 Notification Pipeline

```
NEW MESSAGE INSERTED
        │
        ▼
[Database Trigger]
        │
        ├──► Check if recipient online
        │
        ├──► Check conversation muted status
        │
        └──► Invoke Edge Function
                    │
                    ├──► Get recipient push tokens
                    │
                    ├──► Format notification
                    │
                    └──► Send via OneSignal API
```

### 3.3 Edge Function Example - Message Notification

```javascript
// Edge Function: send-message-notification
export async function handler(req: Request) {
  const { message, recipientId, senderId, conversationType } = await req.json();
  
  // 1. Check if recipient has notifications enabled
  const { data: settings } = await supabase
    .from('notification_settings')
    .select('push_enabled, message_notifications')
    .eq('user_id', recipientId)
    .single();
    
  if (!settings?.push_enabled || !settings?.message_notifications) {
    return new Response(JSON.stringify({ skipped: true }), { status: 200 });
  }
  
  // 2. Get sender information
  const { data: sender } = await supabase
    .from('profiles')
    .select('first_name, last_name, avatar_url')
    .eq('id', senderId)
    .single();
  
  // 3. Send via OneSignal
  const notification = {
    app_id: ONESIGNAL_APP_ID,
    include_external_user_ids: [recipientId],
    headings: { 
      en: `New message from ${sender.first_name}`,
      da: `Ny besked fra ${sender.first_name}`
    },
    contents: { 
      en: message.substring(0, 100),
      da: message.substring(0, 100)
    },
    data: {
      type: 'new_message',
      conversation_type: conversationType,
      sender_id: senderId
    }
  };
  
  await fetch('https://onesignal.com/api/v1/notifications', {
    method: 'POST',
    headers: {
      'Authorization': `Basic ${ONESIGNAL_API_KEY}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(notification)
  });
  
  return new Response(JSON.stringify({ success: true }), { status: 200 });
}
```

---

## 4. State Management (Riverpod)

### 4.1 Provider Architecture

```dart
// Main Providers:

1. inquiryMessagesNotifierProvider
   - Family provider keyed by inquiryId
   - Manages inquiry message list
   - Handles real-time updates
   
2. bookingMessagesNotifierProvider
   - Family provider keyed by bookingId
   - Manages booking chat messages
   - Handles real-time updates
   
3. unifiedConversationsNotifierProvider
   - Combines all conversation types
   - Provides unified conversation list
   - Manages visibility/archive states
```

### 4.2 Provider Flow

```
                 ┌─────────────────────┐
                 │ UnifiedConversations │
                 │     Notifier         │
                 └──────────┬──────────┘
                           │
            ┌──────────────┴──────────────┐
            │                             │
     ┌──────▼──────┐              ┌──────▼──────┐
     │  Inquiries  │              │   Bookings  │
     │  Notifier   │              │   Notifier  │
     └──────┬──────┘              └──────┬──────┘
            │                             │
     ┌──────▼──────┐              ┌──────▼──────┐
     │  Supabase   │              │  Supabase   │
     │  Real-time  │              │  Real-time  │
     └─────────────┘              └─────────────┘
```

---

## 5. Notification System Integration

### 5.1 OneSignal Integration

```dart
// NotificationTriggersService handles:
- Booking confirmations
- New message alerts
- 24-hour reminders
- Rating requests
- Status updates
```

### 5.2 Notification Types & Triggers

| Event | Trigger Point | Edge Function | OneSignal Call |
|-------|--------------|---------------|----------------|
| New Message | `chat_messages` INSERT | `send_message_notification` | Immediate |
| Booking Confirmed | `bookings.status` = 'confirmed' | `trigger_booking_notification` | Immediate |
| 24hr Reminder | Scheduled | `send_booking_reminder` | Scheduled |
| Rating Request | `bookings.status` = 'completed' | `trigger_rating_request` | Delayed 15min |
| Chef Arrival | Manual trigger | None | Direct API |

### 5.3 Notification Data Flow

```
DATABASE EVENT
      │
      ├──► Postgres Trigger
      │         │
      │         └──► Edge Function
      │                   │
      ├──► Flutter Stream │
      │         │         └──► OneSignal API
      │         │                   │
      │         └──► UI Update      └──► Push Notification
      │
      └──► Audit Log
```

---

## 6. Web Platform Integration Points

### 6.1 Key Integration Areas

1. **Real-time Subscriptions**
   - Use same Supabase real-time channels
   - Subscribe to same tables/filters
   - Maintain message ordering consistency

2. **Message Validation**
   - Implement same ContactInfoDetector logic
   - Use identical regex patterns
   - Maintain consistent blocking rules

3. **State Management**
   - Mirror conversation states (active/archived/hidden)
   - Sync read receipts across platforms
   - Maintain unified conversation list structure

4. **Edge Functions**
   - Call same RPC functions
   - Use identical parameter structures
   - Handle same response formats

### 6.2 Web Implementation Checklist

- [ ] Implement ContactInfoDetector validation
- [ ] Set up Supabase real-time subscriptions
- [ ] Create conversation state management
- [ ] Integrate OneSignal Web SDK
- [ ] Implement message sending with validation
- [ ] Handle conversation visibility states
- [ ] Sync read receipts
- [ ] Implement notification permissions
- [ ] Handle edge function calls
- [ ] Implement message pagination
- [ ] Add file attachment support
- [ ] Handle offline message queue

### 6.3 API Endpoints (via Supabase)

```javascript
// Get conversations
const conversations = await supabase
  .from('inquiries')
  .select(`
    *,
    inquiry_messages(count)
  `)
  .eq('user_id', userId)
  .order('last_message_at', { ascending: false });

// Send message
const { data, error } = await supabase
  .from('inquiry_messages')
  .insert({
    inquiry_id: inquiryId,
    sender_id: userId,
    content: messageContent
  });

// Mark as read
await supabase
  .from('inquiry_messages')
  .update({ is_read: true })
  .eq('inquiry_id', inquiryId)
  .eq('is_read', false)
  .neq('sender_id', userId);

// Archive conversation
await supabase.rpc('archive_inquiry_conversation', {
  p_inquiry_id: inquiryId,
  p_user_id: userId
});
```

---

## 7. Security Considerations

### 7.1 Row Level Security (RLS)

All message tables have RLS enabled with policies:
- Users can only read messages they're part of
- Users can only send messages as themselves
- Archive/delete operations are user-specific

### 7.2 Content Moderation

1. **Client-side validation** (ContactInfoDetector)
2. **Server-side validation** (Edge Functions)
3. **Manual flagging** system
4. **Automated content scanning** (planned)

### 7.3 Data Privacy

- Messages are never truly deleted (soft delete only)
- Hidden conversations can reappear on new activity
- All message content is encrypted at rest
- PII detection and blocking

---

## 8. Testing Considerations

### 8.1 Test Scenarios

1. **Message Flow**
   - Send inquiry message
   - Send booking message
   - Validate contact info blocking
   - Test real-time updates

2. **Notifications**
   - New message notification
   - Booking status notifications
   - Scheduled reminders
   - Cross-platform delivery

3. **State Management**
   - Archive/unarchive conversations
   - Hide/unhide conversations
   - Read receipt sync
   - Conversation list ordering

### 8.2 Test Data Setup

```sql
-- Create test inquiry
INSERT INTO inquiries (user_id, chef_id, last_message, last_message_at)
VALUES ('user-uuid', 'chef-uuid', 'Test message', NOW());

-- Create test messages
INSERT INTO inquiry_messages (inquiry_id, sender_id, content)
VALUES ('inquiry-uuid', 'user-uuid', 'Hello, are you available?');

-- Test notification trigger
SELECT trigger_booking_notification('booking-uuid', 'booking_confirmed', '{}');
```

---

## 9. Performance Optimization

### 9.1 Current Optimizations

- Message pagination (50 messages per load)
- Debounced real-time updates
- Cached conversation lists
- Lazy loading of user profiles

### 9.2 Recommended Web Optimizations

- Implement virtual scrolling for long conversations
- Use WebSocket connection pooling
- Cache message content locally (IndexedDB)
- Implement optimistic UI updates
- Batch read receipt updates

---

## 10. Monitoring & Analytics

### 10.1 Key Metrics

- Message delivery rate
- Notification delivery rate
- Real-time connection stability
- Average response time
- Message flagging rate

### 10.2 Error Tracking

- Failed message sends
- Notification delivery failures
- WebSocket disconnections
- Edge function timeouts
- Validation bypass attempts

---

## Appendix A: Database Functions

```sql
-- Archive inquiry conversation
CREATE OR REPLACE FUNCTION archive_inquiry_conversation(
  p_inquiry_id UUID,
  p_user_id UUID
) RETURNS VOID AS $$
BEGIN
  UPDATE inquiries 
  SET is_archived = true, 
      archived_at = NOW()
  WHERE id = p_inquiry_id
    AND (user_id = p_user_id OR chef_id = p_user_id);
END;
$$ LANGUAGE plpgsql;

-- Hide conversation for user
CREATE OR REPLACE FUNCTION hide_conversation_for_user(
  p_conversation_id UUID,
  p_conversation_type TEXT,
  p_user_id UUID
) RETURNS VOID AS $$
BEGIN
  INSERT INTO conversation_visibility 
    (user_id, conversation_id, conversation_type, last_hidden_message_at)
  VALUES 
    (p_user_id, p_conversation_id, p_conversation_type, NOW())
  ON CONFLICT (user_id, conversation_id, conversation_type)
  DO UPDATE SET last_hidden_message_at = NOW();
END;
$$ LANGUAGE plpgsql;
```

---

## Appendix B: Environment Variables

Required for message system:
```
SUPABASE_URL=https://[project].supabase.co
SUPABASE_ANON_KEY=[anon-key]
SUPABASE_SERVICE_ROLE_KEY=[service-key] # Edge Functions only
ONESIGNAL_APP_ID=[app-id]
ONESIGNAL_REST_API_KEY=[api-key]
```

---

*Last Updated: Current as of codebase analysis*
*Version: 1.0*
*Target Audience: Web Platform Development Team*