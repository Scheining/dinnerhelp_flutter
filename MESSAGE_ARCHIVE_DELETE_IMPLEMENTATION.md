# Message Archive & Delete Implementation

**Last Updated:** January 5, 2025  
**Purpose:** Implement functional swipe actions for archiving and deleting messages in the DinnerHelp app

## Overview

The swipe actions (Archive and Delete) in the Messages tab were showing but not functional. This implementation adds full database support and real functionality to these actions.

## Problem

- Swipe actions displayed "Arkivér" (Archive) and "Slet" (Delete) buttons
- Pressing the buttons only showed mock SnackBars without actually archiving/deleting
- No database fields or functions to support these operations

## Solution Implemented

### 1. Database Schema Changes

Added archive/delete support to messaging tables:

```sql
-- inquiries table
is_archived BOOLEAN DEFAULT false
is_deleted BOOLEAN DEFAULT false
archived_at TIMESTAMPTZ
deleted_at TIMESTAMPTZ
archived_by UUID
deleted_by UUID

-- inquiry_messages table  
is_archived BOOLEAN DEFAULT false
is_deleted BOOLEAN DEFAULT false

-- chat_messages table
is_archived BOOLEAN DEFAULT false
is_deleted BOOLEAN DEFAULT false
archived_at TIMESTAMPTZ
deleted_at TIMESTAMPTZ
```

### 2. Database Functions

Created PostgreSQL functions for secure operations:

- `archive_inquiry_conversation(inquiry_id, user_id)` - Archives an inquiry
- `unarchive_inquiry_conversation(inquiry_id, user_id)` - Restores archived inquiry
- `delete_inquiry_conversation(inquiry_id, user_id)` - Soft deletes an inquiry
- `archive_booking_chat(booking_id, user_id)` - Archives booking messages
- `delete_booking_chat(booking_id, user_id)` - Soft deletes booking messages

All functions include:
- Permission checking (user must be part of conversation)
- Soft delete (data not permanently removed)
- Prevention of deleting active bookings

### 3. Flutter Implementation

#### Updated Models
- Added `isArchived` field to `UnifiedConversation` class
- Pass archive status from database to UI

#### Messaging Provider Updates
Added methods to `UnifiedConversationsNotifier`:
- `archiveConversation(conversationId, type)`
- `unarchiveConversation(conversationId, type)`
- `deleteConversation(conversationId, type)`
- Updated `_loadAllConversations()` to filter out deleted items

#### UI Updates
Modified `notifications_screen.dart`:
- Connected swipe actions to real provider methods
- Added undo functionality for archive action
- Show confirmation dialog for delete
- Display success/error feedback

## Deployment Instructions

### Step 1: Deploy Database Changes

Run the SQL script in Supabase SQL Editor:

```bash
# The script is located at:
deploy_archive_delete.sql
```

This script:
1. Adds the necessary columns to tables
2. Creates the database functions
3. Sets up proper permissions
4. Creates performance indexes

### Step 2: Test the Implementation

1. Open the app and navigate to Messages tab
2. Swipe left on any message
3. Tap "Arkivér" to archive (with undo option)
4. Tap "Slet" to delete (with confirmation)
5. Verify messages disappear from list
6. Check database to confirm soft delete

### Step 3: Verify Database

Check if implementation is working:

```sql
-- Check archived conversations
SELECT id, is_archived, archived_at, is_deleted 
FROM inquiries 
WHERE is_archived = true;

-- Check deleted conversations
SELECT id, is_deleted, deleted_at 
FROM inquiries 
WHERE is_deleted = true;

-- Verify functions exist
SELECT proname FROM pg_proc 
WHERE proname LIKE '%inquiry_conversation%' 
   OR proname LIKE '%booking_chat%';
```

## Features

### Archive
- Hides conversation from main list
- Can be undone via SnackBar action
- Conversation can be restored later
- Preserves all data

### Delete  
- Soft delete (data retained in database)
- Requires confirmation dialog
- Cannot be undone by user
- Prevents deletion of active bookings

### Security
- Users can only archive/delete their own conversations
- Permission checks in database functions
- Soft delete preserves audit trail
- RLS policies ensure data isolation

## User Experience

1. **Swipe Actions**: Natural swipe gesture reveals action buttons
2. **Visual Feedback**: Blue for archive, red for delete
3. **Confirmation**: Delete requires explicit confirmation
4. **Undo Option**: Archive can be immediately undone
5. **Error Handling**: Clear error messages if action fails

## Future Enhancements

1. **Archive View**: Add toggle to show archived conversations
2. **Bulk Actions**: Select multiple messages to archive/delete
3. **Auto-Archive**: Archive old conversations automatically
4. **Hard Delete**: Admin function to permanently remove data
5. **Archive Badge**: Show count of archived messages

## Troubleshooting

### If swipe actions don't work:

1. Check database functions exist:
```sql
SELECT * FROM pg_proc WHERE proname LIKE '%archive%';
```

2. Verify columns were added:
```sql
\d inquiries
\d chat_messages
```

3. Check Flutter console for errors
4. Ensure user is authenticated
5. Verify RLS policies aren't blocking

### Common Issues:

- **"Unauthorized" error**: User not part of conversation
- **"Cannot delete active booking"**: Booking still in progress
- **No visual change**: Check if provider is refreshing
- **Database not updated**: Ensure functions have proper permissions

## Technical Details

### Soft Delete Pattern
- Data marked as deleted but not removed
- Allows recovery if needed
- Maintains referential integrity
- Preserves audit trail

### Permission Model
- User-level isolation
- Both parties can independently archive/delete
- Chef and customer have equal rights
- Admin override possible

### Performance Considerations
- Indexes on is_deleted for fast filtering
- Composite index for archived+deleted
- Async operations prevent UI blocking
- Batch refresh after actions

This implementation provides a complete, production-ready solution for message archiving and deletion with proper security, user feedback, and data preservation.