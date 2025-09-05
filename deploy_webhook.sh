#!/bin/bash

# Navigate to project directory
cd "/Users/scheining/Desktop/DinnerHelp/DinnerHelp Flutter"

echo "=== Deploying Stripe Webhook to Supabase ==="
echo ""
echo "Step 1: Login to Supabase (if not already logged in)"
echo "This will open a browser window for authentication"
supabase login

echo ""
echo "Step 2: Link to your project"
supabase link --project-ref iiqrtzioysbuyrrxxqdu

echo ""
echo "Step 3: Deploy the webhook function with JWT disabled"
echo "This uses config.toml to set verify_jwt=false"
supabase functions deploy stripe-webhook-db

echo ""
echo "=== Deployment Complete! ==="
echo ""
echo "Your webhook URL is:"
echo "https://iiqrtzioysbuyrrxxqdu.supabase.co/functions/v1/stripe-webhook-db"
echo ""
echo "Next steps:"
echo "1. Update this URL in Stripe Dashboard → Webhooks"
echo "2. Test with 'Send test webhook' in Stripe"
echo ""