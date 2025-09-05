# DinnerHelp Payment System Documentation

## Overview
The DinnerHelp payment system has been upgraded to use the **Authorization & Hold pattern**, an industry-standard approach for handling bookings with payment. This prevents double-bookings, eliminates phantom bookings shown to chefs, and ensures payment is secured before confirming a booking.

## System Architecture

### Payment Flow Sequence
1. **User initiates booking** → Selects chef, date, time, and guests
2. **Payment reservation created** → 15-minute slot reserved, prevents double-booking
3. **Stripe payment processing** → User enters card details and confirms
4. **Webhook confirmation** → Stripe notifies our system of payment success
5. **Booking creation** → Reservation converted to actual booking
6. **Cleanup** → Expired reservations automatically removed

### Key Components

#### Database Schema Changes
- **payment_intents table**: Added reservation fields
  - `booking_data`: JSONB storing booking details before creation
  - `reservation_status`: 'active', 'expired', or 'converted'
  - `reservation_expires_at`: Timestamp for automatic expiry
- **active_booking_reservations view**: Shows currently reserved time slots
- **Database functions**:
  - `cleanup_expired_reservations()`: Expires old reservations
  - `convert_reservation_to_booking()`: Converts successful payments to bookings

#### Edge Functions
1. **handle-stripe-webhook**: Processes Stripe payment events
   - URL: `https://iiqrtzioysbuyrrxxqdu.supabase.co/functions/v1/handle-stripe-webhook`
   - Handles: payment_intent.succeeded, payment_intent.failed, payment_intent.canceled, charge.refunded
   
2. **cleanup-expired-reservations**: Removes expired reservations
   - URL: `https://iiqrtzioysbuyrrxxqdu.supabase.co/functions/v1/cleanup-expired-reservations`
   - Should be called periodically (cron job or scheduled trigger)

3. **create-payment-intent** (updated): Supports reservation system
   - Backward compatible with existing booking_id approach
   - New booking_data approach for reservations

#### Flutter App Changes
- **payment_screen.dart**: No longer creates booking before payment
- **stripe_service.dart**: Supports both old and new payment approaches
- **chef_availability_service.dart**: Checks both bookings and active reservations

## Stripe Webhook Configuration

### Setting Up the Webhook Endpoint

1. **Log into Stripe Dashboard**
   - Go to https://dashboard.stripe.com
   - Navigate to Developers → Webhooks

2. **Add Endpoint**
   - Click "Add endpoint"
   - Enter URL: `https://iiqrtzioysbuyrrxxqdu.supabase.co/functions/v1/handle-stripe-webhook`
   - Select events to listen for:
     - `payment_intent.succeeded` ✓ (Required)
     - `payment_intent.payment_failed` ✓ (Required)
     - `payment_intent.canceled` ✓ (Required)
     - `charge.refunded` ✓ (Optional but recommended)

3. **Get Webhook Secret**
   - After creating the endpoint, click on it
   - Copy the "Signing secret" (starts with `whsec_`)
   - This needs to be set as an environment variable in Supabase

4. **Configure Environment Variable in Supabase**
   - Go to Supabase Dashboard → Settings → Edge Functions
   - Add secret: `STRIPE_WEBHOOK_SECRET` = `whsec_...` (your webhook secret)

### Testing the Webhook
Use Stripe CLI for local testing:
```bash
# Install Stripe CLI
brew install stripe/stripe-cli/stripe

# Login to Stripe
stripe login

# Forward webhooks to local endpoint (for testing)
stripe listen --forward-to https://iiqrtzioysbuyrrxxqdu.supabase.co/functions/v1/handle-stripe-webhook

# Trigger test events
stripe trigger payment_intent.succeeded
```

## Reservation System Details

### How Reservations Work
1. When user proceeds to payment, a reservation is created with:
   - 15-minute expiry time
   - Chef ID and time slot
   - All booking details stored in JSONB

2. During reservation period:
   - Time slot appears unavailable to other users
   - Chef doesn't see the booking yet
   - Payment can be completed

3. On successful payment:
   - Webhook triggers booking creation
   - Reservation marked as 'converted'
   - Chef and user receive notifications

4. On payment failure or timeout:
   - Reservation expires automatically
   - Time slot becomes available again
   - No booking is created

### Automatic Cleanup
The `cleanup-expired-reservations` function should be called periodically to expire old reservations. Options:

1. **Supabase Cron Job** (Recommended):
   ```sql
   -- Create a cron job to run every 5 minutes
   SELECT cron.schedule(
     'cleanup-expired-reservations',
     '*/5 * * * *',
     $$
     SELECT net.http_post(
       url := 'https://iiqrtzioysbuyrrxxqdu.supabase.co/functions/v1/cleanup-expired-reservations',
       headers := jsonb_build_object(
         'Authorization', 'Bearer ' || current_setting('app.settings.service_role_key'),
         'Content-Type', 'application/json'
       ),
       body := '{}'::jsonb
     );
     $$
   );
   ```

2. **External Scheduler**: Use services like Zapier, n8n, or GitHub Actions

3. **Manual Trigger**: Can be called on-demand when needed

## Backward Compatibility

The system maintains full backward compatibility:
- Old code using `booking_id` continues to work
- New code uses `booking_data` for reservations
- Both approaches handled in Edge Functions
- No breaking changes to existing bookings

## Monitoring and Maintenance

### Key Metrics to Monitor
1. **Reservation conversion rate**: Successful payments / Total reservations
2. **Expired reservations**: Track how many expire without payment
3. **Average time to payment**: Time between reservation and payment
4. **Webhook failures**: Monitor webhook delivery success

### Database Queries for Monitoring
```sql
-- Active reservations
SELECT * FROM active_booking_reservations;

-- Recent expired reservations
SELECT * FROM payment_intents 
WHERE reservation_status = 'expired' 
AND updated_at > now() - interval '1 hour';

-- Conversion rate (last 24 hours)
SELECT 
  COUNT(*) FILTER (WHERE reservation_status = 'converted') * 100.0 / 
  COUNT(*) as conversion_rate
FROM payment_intents
WHERE created_at > now() - interval '24 hours'
AND booking_data IS NOT NULL;
```

### Troubleshooting Common Issues

1. **Webhook not receiving events**
   - Check webhook URL is correct
   - Verify STRIPE_WEBHOOK_SECRET is set
   - Check Edge Function logs in Supabase

2. **Reservations not expiring**
   - Ensure cleanup function is being called
   - Check database function `cleanup_expired_reservations()`
   - Verify timestamps are in UTC

3. **Double bookings still occurring**
   - Check `chef_availability_service.dart` is deployed
   - Verify `active_booking_reservations` view exists
   - Ensure all payment flows use new system

## Security Considerations

1. **Webhook Verification**: Always verify Stripe signatures
2. **Service Role Key**: Only use in Edge Functions, never client-side
3. **Rate Limiting**: Consider adding rate limits to prevent abuse
4. **Monitoring**: Set up alerts for unusual payment patterns

## Testing Checklist

### Unit Tests
- [ ] Reservation creation with correct expiry
- [ ] Availability check includes reservations
- [ ] Cleanup function expires old reservations
- [ ] Webhook signature verification

### Integration Tests
- [ ] Complete payment flow end-to-end
- [ ] Payment failure handling
- [ ] Reservation expiry after 15 minutes
- [ ] Multiple users trying same time slot

### Manual Testing
- [ ] Book as user, verify chef doesn't see until payment
- [ ] Abandon payment, verify slot becomes available
- [ ] Complete payment, verify booking created
- [ ] Check refund process works correctly

## Rollback Procedure

If issues arise, the system can be rolled back:

1. **Revert Flutter app changes**:
   ```bash
   git revert [commit-hash]
   flutter pub get
   flutter build ios/android
   ```

2. **Keep database changes** (they're backward compatible)

3. **Disable webhook** in Stripe Dashboard (temporary)

4. **Monitor old booking flow** to ensure it works

## Future Enhancements

1. **Dynamic reservation times**: Adjust based on demand
2. **Partial payments**: Allow deposits
3. **Group bookings**: Multiple payments for one event
4. **Recurring bookings**: Subscription model
5. **Smart pricing**: Dynamic pricing based on demand

## Support and Maintenance

For issues or questions:
1. Check Edge Function logs in Supabase Dashboard
2. Review Stripe Dashboard for payment events
3. Monitor database for reservation status
4. Contact development team with specific error messages

## Appendix: Environment Variables

Required environment variables in Supabase Edge Functions:
- `STRIPE_SECRET_KEY`: Your Stripe secret key
- `STRIPE_WEBHOOK_SECRET`: Webhook endpoint signing secret
- `SUPABASE_URL`: Your Supabase project URL
- `SUPABASE_SERVICE_ROLE_KEY`: Service role key for admin operations

---
Last Updated: January 2025
Version: 2.0 (Reservation System Implementation)