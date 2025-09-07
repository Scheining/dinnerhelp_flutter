# DinnerHelp Booking & Payment Flow Documentation

## Overview
This document describes the complete booking and payment flow for the DinnerHelp platform, including webhook processing, status management, and the chef approval process.

## System Architecture

### Key Components
1. **Flutter App** - Mobile application for users and chefs
2. **Supabase Backend** - Database and Edge Functions
3. **Stripe** - Payment processing
4. **Webhook System** - Automated payment event handling

## Booking Flow

### 1. User Creates Booking
```
User selects chef → Chooses date/time → Enters details → Proceeds to payment
```

### 2. Payment Intent Creation
- Edge Function: `create-payment-intent`
- Creates a payment reservation with 15-minute expiry
- Stores booking data in `payment_intents` table
- Returns payment sheet configuration to app

### 3. Payment Processing
```
User enters card → Stripe processes payment → Payment succeeds
```

### 4. Webhook Processing
- **Endpoint**: `https://[project].supabase.co/functions/v1/stripe-webhook`
- **Important**: JWT verification must be **OFF** for this endpoint
- Webhook verifies signature using `STRIPE_WEBHOOK_SECRET`
- On payment success:
  1. Updates payment intent status
  2. Calls `convert_reservation_to_booking` function
  3. Creates booking with `pending` status

### 5. Chef Approval Required
```
Booking created (pending) → Chef reviews → Chef accepts/rejects
```

## Booking Status Flow

### Status Definitions
| Status | Description | Payment Status |
|--------|-------------|----------------|
| `pending` | Payment received, awaiting chef approval | `succeeded` |
| `accepted` | Chef has accepted the booking (deprecated) | `succeeded` |
| `confirmed` | Chef confirmed, booking is final | `succeeded` |
| `in_progress` | Service is being delivered | `succeeded` |
| `completed` | Service delivered successfully | `succeeded` |
| `cancelled` | Booking cancelled (by user or chef) | `refunded` or `succeeded` |
| `disputed` | Issue raised by user or chef | `succeeded` |
| `refunded` | Payment has been refunded | `refunded` |

### Correct Status Transitions
```
pending → confirmed (chef accepts)
pending → cancelled (chef rejects) → refunded
confirmed → in_progress → completed
confirmed → cancelled (if >48hrs before) → refunded
```

## Webhook Configuration

### Critical Settings

#### 1. Stripe Dashboard Configuration
- **Webhook Endpoint URL**: `https://[project].supabase.co/functions/v1/stripe-webhook`
- **Events to Listen**:
  - `payment_intent.succeeded`
  - `payment_intent.payment_failed`
  - `payment_intent.canceled`
  - `charge.refunded`

#### 2. Supabase Edge Function Settings
- **Function Name**: `stripe-webhook`
- **JWT Verification**: **MUST BE TURNED OFF**
  - Stripe doesn't send JWT tokens
  - Only sends `stripe-signature` header
  - JWT verification will cause 401 errors

#### 3. Environment Variables Required
```env
STRIPE_SECRET_KEY=sk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...
SUPABASE_URL=https://[project].supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJ...
```

### Common Webhook Issues & Solutions

| Issue | Symptom | Solution |
|-------|---------|----------|
| 401 Unauthorized | Webhook fails immediately | Turn OFF JWT verification in Edge Function settings |
| Signature verification failed | 400 error with signature message | Update `STRIPE_WEBHOOK_SECRET` in Supabase secrets |
| No booking created | Payment succeeds but no booking | Check webhook endpoint URL is correct (not `-db` version) |
| Wrong booking status | Booking auto-confirmed | Fixed in migration `fix_booking_status_flow` |

## Database Schema

### Key Tables

#### payment_intents
```sql
- stripe_payment_intent_id (text) - Stripe's payment ID
- booking_data (jsonb) - Temporary booking details
- reservation_status (text) - active/expired/converted
- reservation_expires_at (timestamp) - 15-minute expiry
- status (text) - Payment status from Stripe
```

#### bookings
```sql
- id (uuid) - Booking ID
- user_id (uuid) - Customer ID
- chef_id (uuid) - Chef ID
- status (text) - Booking status (see table above)
- payment_status (text) - Payment status
- stripe_payment_intent_id (text) - Links to payment
```

## Testing Webhooks Locally

### Using Stripe CLI
```bash
# Install Stripe CLI
brew install stripe/stripe-cli/stripe

# Login to Stripe
stripe login

# Forward webhooks to local endpoint
stripe listen --forward-to https://[project].supabase.co/functions/v1/stripe-webhook

# The CLI will show:
# Your webhook signing secret is whsec_... (use this for local testing)
```

### Test Payment Flow
1. Make a test booking in the app
2. Use test card: `4242 4242 4242 4242`
3. Check Stripe Dashboard for webhook delivery
4. Verify booking created with `pending` status

## Important Notes

### Security Considerations
1. **Never expose** `STRIPE_SECRET_KEY` or `SUPABASE_SERVICE_ROLE_KEY`
2. **Always verify** webhook signatures in production
3. **Use test mode** for development and testing

### Payment Handling
- Payments are captured immediately (not just authorized)
- Refunds must be processed through Stripe
- Platform fees are calculated during payment intent creation

### Chef Approval Process
- Chefs should be notified of new bookings (push/email)
- Implement time limit for chef response (e.g., 24 hours)
- Auto-cancel if chef doesn't respond (with full refund)

## Troubleshooting

### Booking Not Created After Payment
1. Check Stripe Dashboard → Webhooks → Recent deliveries
2. Verify webhook endpoint URL (should NOT end with `-db`)
3. Ensure JWT verification is OFF in Edge Function settings
4. Check Edge Function logs in Supabase Dashboard

### Payment Succeeded but Wrong Status
- Run migration `fix_booking_status_flow`
- Verify `convert_reservation_to_booking` function uses `pending` status

### Webhook Signature Verification Fails
1. Get webhook secret from Stripe Dashboard
2. Update in Supabase → Edge Functions → Secrets
3. Redeploy the Edge Function

## Migration History
- `20250104_payment_reservation_system.sql` - Initial reservation system
- `fix_booking_status_flow` - Fixed status to require chef approval

## Related Documentation
- [Webhook System Documentation](./WEBHOOK_SYSTEM.md)
- [Supabase Edge Functions Guide](https://supabase.com/docs/guides/functions)
- [Stripe Webhooks Guide](https://stripe.com/docs/webhooks)

---

*Last Updated: 2025-09-07*
*Version: 1.0*