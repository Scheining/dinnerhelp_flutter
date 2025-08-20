# Push Notifications Setup Guide

## Overview

The DinnerHelp app now has comprehensive push notification support for key booking events:

1. **Booking Confirmation** - Sent immediately when chef confirms
2. **24-Hour Reminder** - Sent 24 hours before booking
3. **Rating Request** - Sent 10-15 minutes after completion
4. **New Message** - Sent when user receives a message

## Components Created

### 1. Flutter Services
- `lib/services/notification_triggers_service.dart` - Core service for sending notifications
- `lib/providers/booking_notification_provider.dart` - Provider for booking-related notifications

### 2. Supabase Edge Function
- `supabase/functions/send-booking-notifications/index.ts` - Server-side notification handler

### 3. Database Triggers
- `supabase/migrations/20240119_notification_triggers.sql` - Automatic triggers for events

## Setup Instructions

### 1. Get OneSignal REST API Key

1. Go to OneSignal Dashboard
2. Navigate to Settings → Keys & IDs
3. Copy your REST API Key
4. Add to `.env` file:
   ```
   ONESIGNAL_REST_API_KEY=your_rest_api_key_here
   ```

### 2. Deploy Supabase Edge Function

```bash
# Deploy the edge function
supabase functions deploy send-booking-notifications

# Set environment variables
supabase secrets set ONESIGNAL_APP_ID=64976bb8-7d30-470a-9d52-408faf7459cb
supabase secrets set ONESIGNAL_REST_API_KEY=your_rest_api_key_here
```

### 3. Run Database Migration

```bash
# Apply the notification triggers migration
supabase db push
```

Or manually in Supabase SQL Editor:
1. Go to Supabase Dashboard → SQL Editor
2. Copy contents of `20240119_notification_triggers.sql`
3. Run the migration

### 4. Enable pg_cron Extension (for scheduled notifications)

1. Go to Supabase Dashboard → Database → Extensions
2. Enable `pg_cron`
3. Run this SQL to schedule the notification processor:
   ```sql
   SELECT cron.schedule(
     'process-notifications', 
     '* * * * *', 
     'SELECT process_scheduled_notifications();'
   );
   ```

## Implementation in Your App

### Booking Confirmation Example

When a chef confirms a booking, the notification is sent automatically via database trigger. But you can also trigger manually:

```dart
// In your booking confirmation handler
final notificationService = ref.read(bookingNotificationProvider);

await notificationService.handleBookingConfirmation(
  bookingId: booking.id,
  userId: booking.userId,
  chefName: chefName,
  bookingDateTime: bookingDateTime,
);
```

### Message Notification Example

```dart
// When sending a new message
await notificationService.handleNewMessage(
  recipientId: recipientUserId,
  senderName: currentUserName,
  messagePreview: messageText,
  conversationId: bookingId,
  senderImageUrl: currentUserAvatarUrl,
);
```

### Rating Request After Completion

This happens automatically 15 minutes after booking status changes to 'completed'.

## Notification Flow

### Automatic Flow (Database Triggers)

1. **Booking Confirmed**
   - Database trigger detects status change to 'confirmed'
   - Calls Edge Function
   - Sends immediate confirmation notification
   - Schedules 24-hour reminder

2. **Booking Completed**
   - Database trigger detects status change to 'completed'
   - Schedules rating request for 15 minutes later
   - Cron job processes and sends notification

3. **New Message**
   - Database trigger on message insert
   - Determines recipient
   - Sends notification immediately

### Manual Flow (From Flutter)

You can also trigger notifications directly from Flutter:

```dart
// Direct notification sending
await NotificationTriggersService.instance.sendNotification(
  userId: userId,
  title: 'Custom Title',
  message: 'Custom Message',
  additionalData: {'type': 'custom'},
);
```

## Testing Notifications

### 1. Test Booking Confirmation

```dart
// Create a test booking and confirm it
await supabase
  .from('bookings')
  .update({'status': 'confirmed'})
  .eq('id', testBookingId);
```

### 2. Test Rating Request

```dart
// Complete a booking to trigger rating request
await supabase
  .from('bookings')
  .update({'status': 'completed'})
  .eq('id', testBookingId);
```

### 3. Test Message Notification

```dart
// Send a test message
await supabase
  .from('chat_messages')
  .insert({
    'booking_id': bookingId,
    'sender_id': senderId,
    'message': 'Test message',
  });
```

## Customization

### Notification Content

Edit notification text in:
- `notification_triggers_service.dart` for Flutter-side notifications
- `send-booking-notifications/index.ts` for server-side notifications

### Timing

Adjust notification timing:
- 24-hour reminder: Change `Duration(hours: 24)` in service
- Rating request: Change `INTERVAL '15 minutes'` in SQL migration

### Add New Notification Types

1. Add new type to `NotificationPayload` interface in Edge Function
2. Create handler function in Edge Function
3. Add trigger in SQL migration
4. Add method in `notification_triggers_service.dart`

## Monitoring

### Check Scheduled Notifications

```sql
-- View pending notifications
SELECT * FROM notification_queue 
WHERE sent_at IS NULL 
ORDER BY scheduled_for;

-- View sent notifications
SELECT * FROM notification_queue 
WHERE sent_at IS NOT NULL 
ORDER BY sent_at DESC;

-- View failed notifications
SELECT * FROM notification_queue 
WHERE error_message IS NOT NULL;
```

### OneSignal Dashboard

Monitor notification delivery:
1. Go to OneSignal Dashboard → Delivery
2. View sent messages and delivery stats
3. Check for failures or undelivered notifications

## Troubleshooting

### Notifications Not Sending

1. **Check REST API Key**: Ensure it's correctly set in `.env`
2. **Check User External ID**: User must be logged in with external ID set
3. **Check Edge Function Logs**: 
   ```bash
   supabase functions logs send-booking-notifications
   ```
4. **Check Database Triggers**:
   ```sql
   -- List all triggers
   SELECT * FROM pg_trigger WHERE tgname LIKE '%notification%';
   ```

### Scheduled Notifications Not Working

1. **Check pg_cron is enabled**:
   ```sql
   SELECT * FROM cron.job;
   ```
2. **Check notification queue**:
   ```sql
   SELECT * FROM notification_queue WHERE sent_at IS NULL;
   ```
3. **Manually process queue**:
   ```sql
   SELECT process_scheduled_notifications();
   ```

### User Not Receiving Notifications

1. Check user has granted permission
2. Check user's OneSignal subscription status
3. Verify external user ID is set correctly
4. Check notification filters/segments in OneSignal

## Production Considerations

1. **Remove Debug Logging**: Set OneSignal log level to `.none` in production
2. **Rate Limiting**: Implement rate limiting for notification sending
3. **Localization**: Add Danish translations for all notifications
4. **Analytics**: Track notification engagement in OneSignal dashboard
5. **Cleanup**: Periodically clean old records from notification_queue table

## Next Steps

1. Add more notification types (promotions, chef updates, etc.)
2. Implement notification preferences per user
3. Add in-app notification center
4. Set up notification analytics tracking
5. Create admin dashboard for notification management

The notification system is now fully integrated and ready for testing! 🚀