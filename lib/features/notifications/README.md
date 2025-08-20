# DinnerHelp Notification System

A comprehensive notification system for the DinnerHelp Flutter application supporting email, push, and in-app notifications with multi-language support and timezone awareness.

## Features

- **Multi-channel Notifications**: Email (Postmark), Push (OneSignal), In-app, SMS (future)
- **Bilingual Support**: Danish and English templates and content
- **Timezone Awareness**: Proper scheduling for Danish users (Europe/Copenhagen)
- **Notification Types**:
  - Booking confirmations
  - 24-hour and 1-hour reminders
  - Booking modifications and cancellations
  - Completion review requests
  - In-app messaging notifications
  - Recurring booking notifications
- **User Preferences**: Granular control over notification channels and types
- **Retry Logic**: Automatic retry with exponential backoff for failed notifications
- **Analytics**: Delivery tracking and failure monitoring

## Architecture

The notification system follows Clean Architecture principles:

```
lib/features/notifications/
├── domain/                    # Business logic layer
│   ├── entities/             # Core business objects
│   ├── repositories/         # Repository interfaces
│   ├── services/            # Service interfaces
│   └── usecases/            # Application-specific business rules
├── data/                     # Data layer
│   ├── models/              # Data models and DTOs
│   ├── repositories/        # Repository implementations
│   └── services/            # External service integrations
└── presentation/             # UI layer
    ├── pages/               # UI screens
    ├── providers/           # State management (Riverpod)
    └── widgets/             # Reusable UI components
```

## Database Schema

### Core Tables

#### `notifications`
Stores all notification records with status tracking.

#### `notification_preferences`
User-specific notification settings and preferences.

#### `notification_queue`
Scheduled notifications with timing information.

#### `device_tokens`
Device registration tokens for push notifications.

#### `email_templates`
Bilingual email templates with variable substitution.

#### `recurring_booking_notifications`
Manages notifications for recurring booking series.

## Setup Instructions

### 1. Database Migration

Run the migration to create notification tables:

```sql
-- Apply the migration file
supabase/migrations/20240806130001_create_notifications_system.sql
```

### 2. Environment Variables

Set up the following environment variables:

```env
# Postmark (Email)
POSTMARK_SERVER_TOKEN=your_postmark_token
FROM_EMAIL=noreply@dinnerhelp.dk
FROM_NAME=DinnerHelp

# OneSignal (Push Notifications)
ONESIGNAL_APP_ID=your_onesignal_app_id
ONESIGNAL_API_KEY=your_onesignal_api_key

# Supabase
SUPABASE_URL=your_supabase_url
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
```

### 3. Deploy Edge Functions

Deploy the notification Edge Functions:

```bash
# Deploy all notification functions
supabase functions deploy send-email-notification
supabase functions deploy send-push-notification
supabase functions deploy schedule-notification
supabase functions deploy process-notification-queue
```

### 4. Flutter Dependencies

The required packages are already added to `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.1.0
  timezone: ^0.9.2
  onesignal_flutter: ^5.0.0
```

### 5. OneSignal Setup

#### iOS Configuration

Add to `ios/Runner/Info.plist`:

```xml
<key>OneSignal_APP_ID</key>
<string>your_onesignal_app_id</string>
```

#### Android Configuration

Add to `android/app/build.gradle`:

```gradle
buildscript {
    dependencies {
        classpath 'gradle.plugin.com.onesignal:onesignal-gradle-plugin:0.14.0'
    }
}

apply plugin: 'com.onesignal.androidsdk.onesignal-gradle-plugin'

android {
    defaultConfig {
        manifestPlaceholders = [
            onesignalAppId: "your_onesignal_app_id",
            onesignalGoogleProjectNumber: "REMOTE"
        ]
    }
}
```

## Usage Examples

### Basic Notification Sending

```dart
// Send booking confirmation
final result = await ref.read(sendBookingConfirmationProvider)(
  bookingId, 
  RecipientType.both, // Send to both user and chef
);

// Schedule reminders
await ref.read(schedule24HourReminderProvider)(bookingId);
await ref.read(schedule1HourReminderProvider)(bookingId);
```

### User Preferences Management

```dart
// Load user preferences
await ref.read(notificationPreferencesNotifierProvider.notifier)
    .loadPreferences(userId);

// Toggle email notifications
await ref.read(notificationPreferencesNotifierProvider.notifier)
    .toggleEmailNotifications(userId);

// Update language preference
await ref.read(notificationPreferencesNotifierProvider.notifier)
    .updateLanguagePreference(userId, 'en');
```

### Device Token Registration

```dart
// Register device for push notifications
await ref.read(deviceTokenNotifierProvider.notifier)
    .registerToken(
      userId,
      deviceToken,
      Platform.isIOS ? 'ios' : 'android',
      appVersion: packageInfo.version,
      deviceId: deviceId,
    );
```

## Notification Templates

### Email Templates

Templates support variable substitution using `{{variable_name}}` syntax:

```html
<!-- Danish template example -->
<h1>Hej {{user_name}},</h1>
<p>Din booking med {{chef_name}} er bekræftet!</p>
<p>Dato: {{booking_date}} kl. {{booking_time}}</p>
```

### Available Variables

Common template variables:
- `{{user_name}}` - User's display name
- `{{chef_name}}` - Chef's display name
- `{{booking_date}}` - Formatted booking date
- `{{booking_time}}` - Booking time
- `{{guest_count}}` - Number of guests
- `{{address}}` - Booking address
- `{{booking_id}}` - Booking ID for deep linking

## Scheduling & Processing

### Automatic Processing

The notification queue is processed automatically via:

1. **Edge Function Cron**: `process-notification-queue` function
2. **Manual Triggering**: Call the processing function directly
3. **Real-time Processing**: Immediate notifications bypass the queue

### Retry Logic

Failed notifications are automatically retried with exponential backoff:
- First retry: 5 minutes
- Second retry: 30 minutes  
- Third retry: 2 hours
- Maximum 3 retries before marking as cancelled

## Deep Linking

Push notifications include deep links for direct navigation:

- `dinnerhelp://booking/{booking_id}` - Booking details
- `dinnerhelp://chat/{booking_id}` - Chat conversation
- `dinnerhelp://home` - App home screen

## Monitoring & Analytics

### Delivery Statistics

```dart
// Get notification analytics
final analytics = NotificationAnalytics(repository);
final stats = await analytics.getDeliveryStats();

print('Total sent: ${stats['total_sent']}');
print('Delivery rate: ${stats['delivery_rate']}');
```

### Failed Notifications

```dart
// Get failed notifications for debugging
final failures = await analytics.getFailedNotifications(limit: 20);
```

## Testing

### Unit Tests

Run notification service tests:

```bash
flutter test test/features/notifications/
```

### Mock Services

The system includes mock implementations for testing:

```dart
// Use mock services in tests
final mockEmailService = MockEmailService();
final mockPushService = MockPushNotificationService();
```

## Troubleshooting

### Common Issues

#### 1. Notifications Not Sending
- Check environment variables are set correctly
- Verify Edge Functions are deployed
- Check Postmark/OneSignal API credentials

#### 2. Wrong Language/Timezone
- Ensure user preferences are set correctly
- Verify timezone conversion in notification scheduler

#### 3. Push Notifications Not Received
- Check device token registration
- Verify OneSignal app ID configuration
- Ensure user has push notifications enabled in preferences

#### 4. Email Delivery Issues
- Check Postmark domain verification
- Review email template syntax for variable substitution
- Monitor bounce rates via Postmark dashboard

### Debugging

Enable detailed logging:

```dart
// Add to notification service implementation
print('Sending notification: ${notification.id}');
print('Template variables: ${notification.data}');
```

### Database Queries for Debugging

```sql
-- Check notification status
SELECT * FROM notifications WHERE status = 'failed' ORDER BY created_at DESC;

-- Check user preferences
SELECT * FROM notification_preferences WHERE user_id = 'user-id';

-- Check queued notifications
SELECT * FROM notification_queue WHERE is_processed = false;
```

## Contributing

When adding new notification types:

1. Add to `NotificationType` enum
2. Create email templates in both languages
3. Update notification content builders
4. Add appropriate tests
5. Update this documentation

## Security Considerations

- Never expose service role keys in client code
- Use RLS policies to protect notification data
- Validate template variables to prevent injection
- Rate limit notification sending to prevent abuse
- Encrypt sensitive data in notification payloads

## Performance Optimization

- Process notifications in batches (max 10-50 at a time)
- Use database indexes for efficient querying
- Cache user preferences to reduce database calls
- Implement exponential backoff for external API calls
- Monitor memory usage during bulk processing

## Future Enhancements

- [ ] SMS notifications via Twilio
- [ ] WhatsApp Business API integration
- [ ] Advanced scheduling with business hours respect
- [ ] A/B testing for notification content
- [ ] Machine learning for optimal send times
- [ ] Rich push notifications with images
- [ ] Notification categories and importance levels