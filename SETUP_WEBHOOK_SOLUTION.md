# Complete Webhook Setup Solution

## The Problem
- Supabase Edge Functions require JWT authentication by default
- Stripe webhooks cannot send custom Authorization headers
- API deployments don't respect config.toml's `verify_jwt = false`

## The Solution: CLI Deployment

### Step 1: Install Supabase CLI (if not installed)
```bash
brew install supabase/tap/supabase
```

### Step 2: Login and Link Project
```bash
# Login to Supabase
supabase login

# Link to your project
supabase link --project-ref iiqrtzioysbuyrrxxqdu
```

### Step 3: Deploy the Database Webhook Function
```bash
# Navigate to project directory
cd /Users/scheining/Desktop/DinnerHelp/DinnerHelp\ Flutter

# Deploy the database webhook function (respects config.toml)
supabase functions deploy stripe-webhook-db
```

This deployment will respect the `config.toml` setting and deploy WITHOUT JWT verification.

### Step 4: Update Stripe Webhook URL
1. Go to Stripe Dashboard → Developers → Webhooks
2. Update your webhook endpoint URL to:
   ```
   https://iiqrtzioysbuyrrxxqdu.supabase.co/functions/v1/stripe-webhook-db
   ```
3. Keep the same events selected:
   - payment_intent.succeeded ✓
   - payment_intent.payment_failed ✓
   - payment_intent.canceled ✓
   - charge.refunded ✓

### Step 5: Test the Webhook
1. In Stripe Dashboard, click "Send test webhook"
2. Select "payment_intent.succeeded"
3. You should get a 200 OK response

## How It Works

1. **Stripe sends webhook** → Edge Function (no JWT needed)
2. **Edge Function** → Inserts event into `stripe_webhook_events` table
3. **Database trigger** → Automatically processes the event:
   - Converts reservations to bookings
   - Updates payment statuses
   - Handles refunds
4. **Response to Stripe** → Immediate 200 OK

## Benefits of This Approach

✅ **No JWT issues** - Function deployed with `verify_jwt = false`
✅ **Database handles logic** - More reliable than Edge Functions
✅ **Automatic retries** - Database trigger ensures processing
✅ **Event deduplication** - Prevents duplicate processing
✅ **Error logging** - Errors stored in database for debugging

## Monitoring

Check webhook events in the database:
```sql
-- View recent webhook events
SELECT * FROM stripe_webhook_events 
ORDER BY created_at DESC 
LIMIT 10;

-- Check for errors
SELECT * FROM stripe_webhook_events 
WHERE processed = false OR error IS NOT NULL;
```

## Alternative: Direct Database Webhook

If CLI deployment still doesn't work, you can use PostgREST directly:
```
https://iiqrtzioysbuyrrxxqdu.supabase.co/rest/v1/rpc/handle_stripe_webhook_http
```
With headers:
- `apikey`: [your anon key]
- `Content-Type`: application/json

But the CLI deployment method above should work!