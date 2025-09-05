# DinnerHelp Payment & Refund System Documentation

## Overview
This document describes the complete payment, refund, and notification system for DinnerHelp, implemented on January 2025.

## Payment Flow

### 1. Immediate Payment Capture
When a user books a chef, payment is captured immediately (not just authorized). This ensures:
- No issues with 7-day authorization expiry for future bookings
- Platform has funds to handle refunds/disputes
- Industry-standard approach (like Airbnb)

### 2. Payment Distribution
- **User pays**: Full amount including 25% VAT
- **Platform keeps**: 15% service fee (calculated before VAT)
- **Chef receives**: Base amount minus platform fee (after service completion)

## Cancellation & Refund Policy

### Cancellation Rules
- **Free cancellation**: Up to 48 hours before service start time
- **No refund**: Less than 48 hours before service
- **Chef cancellation**: Always results in full refund regardless of timing

### Refund Process
1. User or chef initiates cancellation
2. System checks if within 48-hour window
3. If eligible, automatic refund is processed
4. User receives push notification and email confirmation
5. Funds returned to original payment method (3-5 business days)

## Technical Implementation

### Database Schema

#### Bookings Table Additions
```sql
-- Refund tracking fields
refund_status TEXT CHECK (refund_status IN ('none', 'pending', 'processed', 'failed'))
refunded_amount INTEGER DEFAULT 0
cancelled_by TEXT CHECK (cancelled_by IN ('user', 'chef', 'admin', 'system'))
cancellation_reason TEXT

-- Automatic cancellation deadline calculation
cancellation_deadline TIMESTAMPTZ GENERATED ALWAYS AS 
  (date + start_time - INTERVAL '48 hours') STORED
```

#### Push Notification Support
```sql
-- User push tokens table
CREATE TABLE user_push_tokens (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  fcm_token TEXT NOT NULL,
  device_type TEXT CHECK (device_type IN ('ios', 'android')),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, fcm_token)
);
```

### Edge Functions

#### create-payment-intent
- **Change**: Removed `capture_method: 'manual'`
- **Result**: Payments captured immediately
- **Location**: `/supabase/functions/create-payment-intent/`

#### refund-payment (NEW)
- **Purpose**: Process refunds for cancelled bookings
- **Validates**: 48-hour cancellation window
- **Location**: `/supabase/functions/refund-payment/`

#### send-push-notification (NEW)
- **Purpose**: Send push notifications via Firebase
- **Location**: `/supabase/functions/send-push-notification/`

### Webhook Handling

The existing `stripe-webhook-db` function handles:
- `payment_intent.succeeded` - Creates booking from reservation
- `charge.refunded` (NEW) - Updates booking refund status

## Push Notification Triggers

### For Users (Customers)
1. **Booking Accepted** - Chef confirms the booking
2. **Booking Cancelled by Chef** - Full refund initiated
3. **Refund Successful** - Confirmation of processed refund
4. **24-Hour Reminder** - Day before service
5. **Service Complete** - Request for review

### For Chefs
1. **New Booking Request** - Immediate notification
2. **User Cancellation** - Booking cancelled by customer
3. **Payment Received** - After service completion
4. **24-Hour Reminder** - Day before service

## API Changes

### StripeService
No changes needed - existing `processRefund` method will be used

### Flutter App Updates
1. **BookingScreen**: Show cancellation deadline
2. **BookingsScreen**: 
   - Show "Cancel" button only if within 48-hour window
   - Display cancellation policy clearly
3. **PaymentScreen**: Update messaging about immediate charge

## Testing Checklist

### Payment Flow
- [ ] Book with immediate payment capture
- [ ] Verify payment shows as 'succeeded' in Stripe
- [ ] Confirm booking created in database

### Refund Flow  
- [ ] Cancel booking >48 hours before (should refund)
- [ ] Cancel booking <48 hours before (no refund)
- [ ] Chef cancellation (always refunds)
- [ ] Verify refund appears in Stripe
- [ ] Check refund status in database

### Notifications
- [ ] Booking acceptance notification
- [ ] Cancellation notification
- [ ] Refund success notification
- [ ] 24-hour reminder

## Environment Variables Required

### Existing (No Changes)
- STRIPE_SECRET_KEY
- STRIPE_WEBHOOK_SECRET
- SUPABASE_URL
- SUPABASE_SERVICE_ROLE_KEY

### New (For Push Notifications)
- FIREBASE_SERVER_KEY
- FIREBASE_PROJECT_ID

## Migration Safety

### What Changes
1. Payment capture timing (manual → automatic)
2. New database columns for refunds
3. New Edge Functions for refunds and notifications

### What Stays The Same
1. Payment amount calculations
2. Stripe Connect setup
3. Existing booking flow
4. Chef payout process (still after service)
5. All existing Edge Functions remain unchanged

## Rollback Plan

If issues arise:
1. Revert create-payment-intent to use `capture_method: 'manual'`
2. Disable refund-payment function
3. Hide cancellation buttons in app
4. All existing bookings remain unaffected

## Success Metrics

- Successful immediate payment capture rate: >99%
- Refund processing time: <5 minutes
- Push notification delivery rate: >95%
- Customer satisfaction with cancellation policy

## Support Documentation

### Common Issues

**Q: Why was I charged immediately?**
A: Payment is processed at booking to secure your reservation. Funds are held safely until service completion.

**Q: How do I cancel my booking?**
A: Go to My Bookings, select the booking, and tap Cancel. Refunds are automatic if >48 hours before service.

**Q: When will I receive my refund?**
A: Refunds are processed immediately but may take 3-5 business days to appear on your card.

**Q: What if the chef cancels?**
A: You'll receive a full refund regardless of timing, plus assistance finding an alternative chef.

---

Last Updated: January 2025
Version: 1.0