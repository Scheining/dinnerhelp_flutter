# Deploy Stripe Webhook with JWT Disabled

## Quick Setup (One-time)

1. Install Supabase CLI:
```bash
brew install supabase/tap/supabase
```

2. Login to Supabase:
```bash
supabase login
```

3. Link your project:
```bash
supabase link --project-ref iiqrtzioysbuyrrxxqdu
```

## Deploy the Webhook

From the project root directory:

```bash
cd /Users/scheining/Desktop/DinnerHelp/DinnerHelp\ Flutter
supabase functions deploy handle-stripe-webhook
```

This will deploy with the config.toml settings, properly disabling JWT verification.

## Verify Deployment

After deployment, the webhook should work without the 401 error because:
1. The config.toml sets `verify_jwt=false` for this function
2. The CLI respects this configuration
3. Stripe can now call the webhook without needing JWT

## Test the Webhook

In Stripe Dashboard:
1. Go to your webhook endpoint
2. Click "Send test webhook"
3. Select "payment_intent.succeeded"
4. It should return 200 OK