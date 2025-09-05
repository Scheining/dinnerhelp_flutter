# DinnerHelp Complete Notification System Documentation
## January 2025

## System Overview

DinnerHelp uses **OneSignal** for push notifications, integrated with Supabase Edge Functions and database triggers for automated notification delivery.

## Architecture

```
┌─────────────┐     ┌─────────────────┐     ┌──────────────┐
│   Flutter   │────▶│  Supabase Edge  │────▶│  OneSignal   │
│     App     │     │    Functions    │     │     API      │
└─────────────┘     └─────────────────┘     └──────────────┘
       │                    ▲                        │
       │                    │                        │
       └──────────▶  ┌─────────────┐               ▼
                     │   Database   │         ┌──────────────┐
                     │   Triggers   │         │ User Device  │
                     └─────────────┘         └──────────────┘
```

## Components

### 1. OneSignal Integration (Flutter App)

#### Configuration
- **Service**: `lib/services/onesignal_service.dart`
- **Provider**: `lib/providers/notification_provider.dart`
- **App ID**: Stored in environment variables

#### Key Features
- User identification via External ID (Supabase user ID)
- Permission management
- Notification click handling
- Deep linking support

### 2. Edge Functions

#### send-push-notification
**Location**: `/supabase/functions/send-push-notification/`
**Purpose**: Main function for sending push notifications via OneSignal

**Parameters**:
```typescript
{
  user_id?: string,      // Target user ID
  user_ids?: string[],   // Multiple users
  title: string,         // Notification title
  content: string,       // Notification body
  data?: object,         // Metadata
  deep_link?: string     // App navigation path
}
```

#### refund-payment
**Location**: `/supabase/functions/refund-payment/`
**Sends Notifications For**:
- Successful refunds
- Cancellations (with/without refund)
- Chef notifications when user cancels

#### send-booking-notifications
**Location**: `/supabase/functions/send-booking-notifications/`
**Handles**:
- Booking confirmations
- Status updates
- Chef notifications for new bookings

### 3. Database Triggers

#### Automatic Notifications
Database triggers automatically send notifications for:
- New bookings
- Booking status changes
- Payment confirmations

## Notification Flow Matrix

| Event | Trigger | Recipients | Title | Content | Deep Link |
|-------|---------|------------|-------|---------|-----------|
| **Payment Success** | Stripe webhook | User | "Booking Confirmed!" | "Your booking for [date] has been confirmed" | `/bookings/[id]` |
| **Booking Accepted** | Chef action | User | "Booking Accepted!" | "Your chef has accepted your booking" | `/bookings/[id]` |
| **User Cancellation (>48h)** | refund-payment | User + Chef | "Booking Cancelled" | "Refund of X kr processing" | `/bookings/[id]` |
| **User Cancellation (<48h)** | refund-payment | User + Chef | "Booking Cancelled" | "No refund (within 48 hours)" | `/bookings/[id]` |
| **Chef Cancellation** | refund-payment | User | "Chef Cancelled" | "Full refund processing" | `/bookings/[id]` |
| **Refund Complete** | Stripe webhook | User | "Refund Successful" | "X kr refunded to your card" | `/bookings/[id]` |
| **24h Reminder** | Scheduled job | User + Chef | "Booking Tomorrow" | "Reminder: Your booking at [time]" | `/bookings/[id]` |

## Implementation Details

### Payment & Refund Notifications

#### When Payment Succeeds
1. Stripe webhook received → `stripe-webhook-db`
2. Database trigger creates booking
3. `handle-stripe-webhook` calls `send-booking-notifications`
4. User receives "Booking Confirmed!" notification
5. Chef receives "New Booking!" notification

#### When Booking is Cancelled
1. App calls `refund-payment` function
2. Function checks 48-hour policy
3. Processes refund if eligible
4. Sends notifications:
   - User: Refund status + amount
   - Chef: Cancellation notice (if user cancelled)

### Code Examples

#### Triggering Cancellation with Refund (Flutter)
```dart
final response = await supabase.functions.invoke(
  'refund-payment',
  body: {
    'booking_id': bookingId,
    'cancelled_by': 'user', // or 'chef', 'admin'
    'reason': 'Change of plans',
  },
);

// Response indicates if refund was processed
if (response.data['refunded']) {
  // User will receive notification about refund
  showSnackBar('Cancellation confirmed. Refund processing.');
}
```

#### Manual Notification Send (Edge Function)
```typescript
await supabase.functions.invoke('send-push-notification', {
  body: {
    user_id: userId,
    title: 'Special Offer',
    content: 'Get 20% off your next booking!',
    data: {
      type: 'promotion',
      discount: 20
    },
    deep_link: '/promotions'
  }
})
```

## User Preferences

### Database Storage
Users can control notifications via `profiles.notification_settings`:
```json
{
  "push_enabled": true,
  "booking_updates": true,
  "payment_updates": true,
  "reminders": true,
  "marketing": false
}
```

### Flutter Implementation
```dart
// Check if user has notifications enabled
final settings = user.notificationSettings;
if (settings['push_enabled'] && settings['booking_updates']) {
  // Send notification
}
```

## Testing Notifications

### 1. Test Direct Push
```bash
curl -X POST https://iiqrtzioysbuyrrxxqdu.supabase.co/functions/v1/send-push-notification \
  -H "Authorization: Bearer [ANON_KEY]" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "test-user-uuid",
    "title": "Test Notification",
    "content": "This is a test message"
  }'
```

### 2. Test Refund with Notification
```bash
curl -X POST https://iiqrtzioysbuyrrxxqdu.supabase.co/functions/v1/refund-payment \
  -H "Authorization: Bearer [ANON_KEY]" \
  -H "Content-Type: application/json" \
  -d '{
    "booking_id": "booking-uuid",
    "cancelled_by": "user",
    "reason": "Testing"
  }'
```

### 3. Verify in OneSignal Dashboard
1. Go to OneSignal Dashboard → Audience
2. Check "All Users" for device count
3. Go to Messages → Delivery
4. View sent notifications and delivery status

## Environment Variables

### Required for Notifications
```env
# OneSignal (Flutter App)
ONESIGNAL_APP_ID=your-onesignal-app-id

# OneSignal (Edge Functions)
ONESIGNAL_API_KEY=your-rest-api-key
```

## Troubleshooting

### Notifications Not Received

1. **Check OneSignal Dashboard**
   - Verify user is subscribed
   - Check delivery status

2. **Verify User Settings**
   ```sql
   SELECT notification_settings 
   FROM profiles 
   WHERE id = 'user-id';
   ```

3. **Check Edge Function Logs**
   ```bash
   supabase functions logs send-push-notification
   ```

4. **iOS Specific**
   - Ensure push certificates are configured
   - Test on real device (not simulator)

5. **Android Specific**
   - Check Firebase configuration
   - Verify app is not force-stopped

### Common Issues

| Issue | Solution |
|-------|----------|
| User not receiving notifications | Check `notification_settings.push_enabled` |
| Notification sent but not delivered | Verify OneSignal subscription status |
| Deep links not working | Check Flutter route configuration |
| Duplicate notifications | Ensure single trigger point |

## Security Notes

1. **User Privacy**: Only send notifications to intended recipients
2. **Data Minimization**: Don't include sensitive data in notification body
3. **Authentication**: Edge Functions verify user permissions
4. **Rate Limiting**: Implement to prevent notification spam

## Monitoring

### Key Metrics
- Delivery rate (OneSignal Dashboard)
- Click-through rate
- Opt-out rate
- Failed notification logs

### Database Queries
```sql
-- Check recent push notification logs
SELECT * FROM push_notifications_log 
ORDER BY sent_at DESC 
LIMIT 20;

-- Check failed notifications
SELECT * FROM push_notifications_log 
WHERE delivered = false 
OR error IS NOT NULL;

-- User notification preferences
SELECT COUNT(*) as enabled_users
FROM profiles
WHERE notification_settings->>'push_enabled' = 'true';
```

## Summary

The notification system is fully integrated with:
- ✅ OneSignal for push delivery
- ✅ Automated triggers for all booking events
- ✅ Refund notifications with policy enforcement
- ✅ User preference management
- ✅ Deep linking for navigation
- ✅ Comprehensive error handling

**No additional setup required** - the system is production-ready!

---
Last Updated: January 2025
Version: 2.0