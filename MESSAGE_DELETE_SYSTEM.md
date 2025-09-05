# DinnerHelp Message Delete System Documentation

**Last Updated:** January 5, 2025  
**Status:** ✅ Fully Implemented and Working

## Overview

The DinnerHelp app implements a Facebook/Airbnb-style message deletion system where messages are hidden from the user's view but preserved in the database and can reappear when new activity occurs.

## How It Works

### User Perspective
1. **Delete Action**: User swipes left on any message → Taps "Slet" (Delete) button
2. **Message Disappears**: Message immediately vanishes from their Messages list
3. **Access Deleted**: User can view deleted messages via archive icon in app bar
4. **Auto-Restore**: If other party sends a new message, conversation reappears with full history

### Technical Implementation
- Messages are **never actually deleted** from the database
- Instead, they're marked as "hidden" for that specific user
- Each user has their own visibility settings independent of other users
- System automatically unhides conversations when new messages arrive

## Database Structure

### Table: `conversation_visibility`
Tracks which conversations are hidden for each user:

```sql
CREATE TABLE conversation_visibility (
  user_id UUID NOT NULL,
  conversation_id UUID NOT NULL,
  conversation_type TEXT NOT NULL, -- 'inquiry' or 'booking'
  hidden_at TIMESTAMPTZ,
  last_hidden_message_at TIMESTAMPTZ,
  PRIMARY KEY (user_id, conversation_id, conversation_type)
);
```

### Key Database Functions

#### `hide_conversation_for_user(conversation_id, conversation_type, user_id)`
- Hides a conversation for a specific user
- Records when it was hidden and the timestamp of the last message
- **NO RESTRICTIONS** - works for all conversations including active bookings

#### `auto_unhide_conversation(conversation_id, conversation_type, sender_id)`
- Automatically called when new messages arrive
- Unhides conversation for recipients (not the sender)
- Ensures conversations reappear with new activity

## Flutter Implementation

### UI Components

#### Swipe to Delete
**Location:** `lib/screens/notifications_screen.dart`
- Single swipe action: "Slet" (Delete)
- Red background, delete icon
- Calls `deleteConversation()` method

#### Deleted Messages View
**Location:** `lib/screens/archived_messages_screen.dart`
- Accessed via archive icon in Messages tab app bar
- Shows all deleted/hidden conversations
- Swipe to restore ("Gendan") functionality
- Empty state: "Ingen slettede beskeder"

### Provider Methods

**Location:** `lib/providers/messaging_provider.dart`

#### Core Methods:
1. **`deleteConversation()`** - Hides conversation for current user
2. **`getHiddenConversations()`** - Retrieves all hidden messages
3. **`unhideConversation()`** - Manually restores a conversation
4. **`_loadAllConversations()`** - Filters out hidden conversations from main list

### Filtering Logic
```dart
// Check if conversation is hidden
final hideKey = 'inquiry_${inquiry['id']}';
if (hiddenConversations.containsKey(hideKey)) {
  continue; // Skip this conversation
}
```

## User Experience Flow

### Deleting Messages
1. User sees unwanted conversation in Messages tab
2. Swipes left → "Slet" button appears
3. Taps "Slet" → Confirmation dialog
4. Confirms → Message disappears
5. Success message: "Besked fjernet"

### Viewing Deleted Messages
1. Tap archive icon (📁) in Messages tab app bar
2. See "Slettede beskeder" screen
3. View all deleted conversations
4. Can tap to read or swipe to restore

### Auto-Restore Behavior
1. User A deletes conversation with User B
2. User B sends new message
3. Conversation automatically reappears for User A
4. Full message history is visible

## Important Notes

### What "Delete" Actually Does
- **User thinks:** Message is deleted
- **Actually happens:** Message is hidden from their view only
- **Other party:** Unaffected, still sees conversation
- **Database:** All data preserved

### No Restrictions
- Can delete messages for **any** booking status
- Works for active, upcoming, completed bookings
- Works for inquiries and booking chats

### Privacy & Security
- Each user controls their own view
- Cannot affect other users' visibility
- Soft delete preserves audit trail
- Data never permanently removed

## Comparison with Old System

### Old Archive System (REMOVED)
- Had restrictions on active bookings
- Used `is_archived` field in database
- Function: `archive_booking_chat()` - NOT USED

### New Delete System (CURRENT)
- No restrictions on any bookings
- Uses `conversation_visibility` table
- Function: `hide_conversation_for_user()` - IN USE

## Testing the System

### Test Delete Function
1. Open Messages tab
2. Swipe left on any message
3. Tap "Slet" (Delete)
4. Verify message disappears

### Test Archive View
1. Delete a message (as above)
2. Tap archive icon in app bar
3. Verify deleted message appears in list
4. Swipe right → Tap "Gendan" to restore

### Test Auto-Restore
1. Delete a conversation
2. Have other party send new message
3. Verify conversation reappears in main list

## Troubleshooting

### Message Not Disappearing After Delete
- Check if `hiddenConversations` map is populated
- Verify filtering logic in `_loadAllConversations()`
- Ensure `ref.invalidate()` is called after delete

### Archive Icon Not Showing
- Only appears in Messages tab (index 1)
- Check `_tabController.index == 1` condition
- Verify TabController listener for state updates

### Can't Restore Messages
- Check `unhideConversation()` method
- Verify deletion from `conversation_visibility` table
- Ensure provider refresh after restore

## Code Locations Quick Reference

| Feature | File | Key Lines |
|---------|------|-----------|
| Swipe to Delete | `notifications_screen.dart` | 435-469 |
| Archive Icon | `notifications_screen.dart` | 149-168 |
| Deleted Messages Screen | `archived_messages_screen.dart` | Full file |
| Delete Function | `messaging_provider.dart` | 692-721 |
| Hidden Conversations Query | `messaging_provider.dart` | 724-859 |
| Filtering Logic | `messaging_provider.dart` | 344-348, 444-448 |
| Database Functions | PostgreSQL | `hide_conversation_for_user`, `auto_unhide_conversation` |

## Key Danish Translations

- **Delete** = Slet
- **Deleted messages** = Slettede beskeder  
- **No deleted messages** = Ingen slettede beskeder
- **Remove message** = Fjern besked
- **Message removed** = Besked fjernet
- **Restore** = Gendan
- **Message restored** = Besked gendannet

This implementation provides a user-friendly, Facebook-style deletion system that preserves data integrity while giving users control over their message visibility.