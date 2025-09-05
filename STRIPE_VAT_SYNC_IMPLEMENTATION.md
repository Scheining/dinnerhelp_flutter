# Stripe VAT Sync Implementation Guide

**Last Updated:** January 2025  
**Purpose:** Sync VAT information from Stripe Connect accounts to chef records

## Overview

This guide provides the SQL migrations, Edge Functions, and implementation steps needed to sync VAT registration data from Stripe Connect accounts to the DinnerHelp chef records.

## Step 1: SQL Migration for VAT Sync

Run this migration to update existing chef records with VAT information:

```sql
-- Migration: Sync VAT information from Stripe Connect
-- File: supabase/migrations/20250105_sync_stripe_vat_info.sql

-- First, ensure the columns exist (if not already added)
ALTER TABLE chefs 
ADD COLUMN IF NOT EXISTS is_vat_registered BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS vat_number TEXT,
ADD COLUMN IF NOT EXISTS vat_rate DECIMAL(5,4) DEFAULT 0.25,
ADD COLUMN IF NOT EXISTS business_type TEXT DEFAULT 'individual',
ADD COLUMN IF NOT EXISTS commission_rate DECIMAL(5,4) DEFAULT 0.15;

-- Create a function to sync VAT info from Stripe
CREATE OR REPLACE FUNCTION sync_chef_vat_from_stripe(
  p_chef_id UUID,
  p_is_vat_registered BOOLEAN,
  p_vat_number TEXT DEFAULT NULL,
  p_business_type TEXT DEFAULT 'individual'
)
RETURNS VOID AS $$
BEGIN
  UPDATE chefs
  SET 
    is_vat_registered = p_is_vat_registered,
    vat_number = p_vat_number,
    business_type = p_business_type,
    vat_rate = CASE 
      WHEN p_is_vat_registered THEN 0.25 
      ELSE 0 
    END,
    updated_at = NOW()
  WHERE id = p_chef_id;
END;
$$ LANGUAGE plpgsql;

-- Create an audit table to track VAT updates
CREATE TABLE IF NOT EXISTS chef_vat_sync_log (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  chef_id UUID REFERENCES chefs(id),
  previous_vat_status BOOLEAN,
  new_vat_status BOOLEAN,
  previous_vat_number TEXT,
  new_vat_number TEXT,
  sync_source TEXT DEFAULT 'stripe',
  synced_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create trigger to log VAT changes
CREATE OR REPLACE FUNCTION log_vat_changes()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.is_vat_registered IS DISTINCT FROM NEW.is_vat_registered 
     OR OLD.vat_number IS DISTINCT FROM NEW.vat_number THEN
    INSERT INTO chef_vat_sync_log (
      chef_id,
      previous_vat_status,
      new_vat_status,
      previous_vat_number,
      new_vat_number
    ) VALUES (
      NEW.id,
      OLD.is_vat_registered,
      NEW.is_vat_registered,
      OLD.vat_number,
      NEW.vat_number
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER chef_vat_changes
AFTER UPDATE ON chefs
FOR EACH ROW
EXECUTE FUNCTION log_vat_changes();
```

## Step 2: Edge Function to Sync VAT from Stripe

Create a new Edge Function to fetch and sync VAT data:

```typescript
// supabase/functions/sync-stripe-vat/index.ts
import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import Stripe from 'https://esm.sh/stripe@14.21.0'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.7'

const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY')!)
const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { chef_id, stripe_account_id } = await req.json()
    
    if (!chef_id || !stripe_account_id) {
      return new Response(
        JSON.stringify({ error: 'Missing required parameters' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Initialize Supabase client
    const supabase = createClient(supabaseUrl, supabaseKey)

    // Fetch Stripe account details
    const account = await stripe.accounts.retrieve(stripe_account_id)
    
    // Extract VAT information
    let isVatRegistered = false
    let vatNumber = null
    let businessType = 'individual'
    
    // Check business type
    if (account.business_type === 'company') {
      businessType = 'company'
      
      // Check for VAT registration in company data
      if (account.company?.vat_id) {
        isVatRegistered = true
        vatNumber = account.company.vat_id
      }
      
      // For Danish companies, check tax_id as well
      if (!vatNumber && account.company?.tax_id) {
        // Danish CVR numbers that are VAT registered typically have format "DK" + 8 digits
        if (account.company.tax_id.startsWith('DK')) {
          isVatRegistered = true
          vatNumber = account.company.tax_id
        }
      }
    } else if (account.business_type === 'individual') {
      // For individuals, check if they have a VAT ID
      if (account.individual?.id_number) {
        // Check if the ID number is a VAT number (Danish format)
        const idNumber = account.individual.id_number
        if (idNumber.startsWith('DK') && idNumber.length === 10) {
          isVatRegistered = true
          vatNumber = idNumber
        }
      }
    }
    
    // Additional check: Look at metadata if VAT info was stored there
    if (account.metadata?.vat_number) {
      isVatRegistered = true
      vatNumber = account.metadata.vat_number as string
    }
    
    // Check capabilities for tax reporting (indicates business registration)
    if (account.capabilities?.tax_reporting_us_1099_k === 'active' ||
        account.capabilities?.tax_reporting_us_1099_misc === 'active') {
      // This indicates tax reporting capability, but for EU we need specific VAT check
      // This is more relevant for US accounts
    }

    // Update chef record in database
    const { data, error } = await supabase
      .from('chefs')
      .update({
        is_vat_registered: isVatRegistered,
        vat_number: vatNumber,
        business_type: businessType,
        vat_rate: isVatRegistered ? 0.25 : 0,
        updated_at: new Date().toISOString(),
      })
      .eq('id', chef_id)
      .select()
      .single()

    if (error) {
      throw error
    }

    // Log the sync
    await supabase
      .from('chef_vat_sync_log')
      .insert({
        chef_id: chef_id,
        new_vat_status: isVatRegistered,
        new_vat_number: vatNumber,
        sync_source: 'stripe_manual',
      })

    return new Response(
      JSON.stringify({
        success: true,
        data: {
          chef_id,
          is_vat_registered: isVatRegistered,
          vat_number: vatNumber,
          business_type: businessType,
          stripe_account: {
            id: account.id,
            business_type: account.business_type,
            country: account.country,
          }
        }
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Error syncing VAT from Stripe:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
```

## Step 3: Batch Sync Script for All Chefs

Run this SQL to sync all existing chefs:

```sql
-- Create a temporary function to sync all chefs
CREATE OR REPLACE FUNCTION sync_all_chef_vat_data()
RETURNS TABLE(
  chef_id UUID,
  stripe_account_id TEXT,
  sync_status TEXT
) AS $$
DECLARE
  chef_record RECORD;
  sync_result TEXT;
BEGIN
  FOR chef_record IN 
    SELECT id, stripe_account_id 
    FROM chefs 
    WHERE stripe_account_id IS NOT NULL 
      AND stripe_account_id != ''
  LOOP
    BEGIN
      -- Call the Edge Function for each chef
      -- Note: You'll need to run this via a script that can call Edge Functions
      -- This is a placeholder showing the structure
      
      RETURN QUERY
      SELECT 
        chef_record.id,
        chef_record.stripe_account_id,
        'pending_sync'::TEXT;
        
    EXCEPTION WHEN OTHERS THEN
      RETURN QUERY
      SELECT 
        chef_record.id,
        chef_record.stripe_account_id,
        'error: ' || SQLERRM;
    END;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Get list of chefs that need syncing
SELECT 
  c.id,
  c.stripe_account_id,
  p.first_name,
  p.last_name,
  c.is_vat_registered,
  c.vat_number
FROM chefs c
JOIN profiles p ON c.id = p.id
WHERE c.stripe_account_id IS NOT NULL
  AND c.stripe_account_id != ''
ORDER BY c.created_at DESC;
```

## Step 4: Webhook Handler Update

Update your stripe-webhook handler to automatically sync VAT on account updates:

```typescript
// In your handle-stripe-webhook function, add this case:

case 'account.updated': {
  const account = event.data.object as Stripe.Account;
  
  // Find chef by stripe_account_id
  const { data: chef } = await supabase
    .from('chefs')
    .select('id')
    .eq('stripe_account_id', account.id)
    .single();
    
  if (chef) {
    // Sync VAT information
    let isVatRegistered = false;
    let vatNumber = null;
    
    if (account.company?.vat_id) {
      isVatRegistered = true;
      vatNumber = account.company.vat_id;
    } else if (account.metadata?.vat_number) {
      isVatRegistered = true;
      vatNumber = account.metadata.vat_number as string;
    }
    
    await supabase
      .from('chefs')
      .update({
        is_vat_registered: isVatRegistered,
        vat_number: vatNumber,
        vat_rate: isVatRegistered ? 0.25 : 0,
      })
      .eq('id', chef.id);
  }
  break;
}
```

## Step 5: Manual SQL Commands for Immediate Use

### Check Current VAT Status
```sql
-- View all chefs and their VAT status
SELECT 
  c.id,
  p.first_name || ' ' || p.last_name as chef_name,
  c.is_vat_registered,
  c.vat_number,
  c.stripe_account_id,
  c.business_type
FROM chefs c
JOIN profiles p ON c.id = p.id
ORDER BY c.created_at DESC;
```

### Update Specific Chef's VAT Status
```sql
-- Update a specific chef with known VAT information
UPDATE chefs
SET 
  is_vat_registered = true,
  vat_number = 'DK12345678', -- Replace with actual CVR number
  vat_rate = 0.25,
  business_type = 'company',
  updated_at = NOW()
WHERE id = 'chef-uuid-here';
```

### Bulk Update for Known VAT-Registered Chefs
```sql
-- If you have a list of chef IDs that are VAT registered
UPDATE chefs
SET 
  is_vat_registered = true,
  vat_rate = 0.25,
  updated_at = NOW()
WHERE id IN (
  'chef-id-1',
  'chef-id-2',
  'chef-id-3'
);
```

### Set Default for Non-VAT Registered
```sql
-- Set all chefs without VAT info as non-registered (safe default)
UPDATE chefs
SET 
  is_vat_registered = false,
  vat_rate = 0,
  business_type = 'individual'
WHERE vat_number IS NULL 
  OR vat_number = '';
```

## Step 6: Script to Call Edge Function for All Chefs

Create a Node.js script to sync all chefs:

```javascript
// sync-all-chef-vat.js
const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

const supabase = createClient(supabaseUrl, supabaseKey);

async function syncAllChefVat() {
  // Get all chefs with Stripe accounts
  const { data: chefs, error } = await supabase
    .from('chefs')
    .select('id, stripe_account_id')
    .not('stripe_account_id', 'is', null)
    .not('stripe_account_id', 'eq', '');
    
  if (error) {
    console.error('Error fetching chefs:', error);
    return;
  }
  
  console.log(`Found ${chefs.length} chefs to sync`);
  
  for (const chef of chefs) {
    try {
      const { data, error } = await supabase.functions.invoke('sync-stripe-vat', {
        body: {
          chef_id: chef.id,
          stripe_account_id: chef.stripe_account_id
        }
      });
      
      if (error) {
        console.error(`Error syncing chef ${chef.id}:`, error);
      } else {
        console.log(`Synced chef ${chef.id}:`, data);
      }
      
      // Add delay to avoid rate limiting
      await new Promise(resolve => setTimeout(resolve, 500));
      
    } catch (err) {
      console.error(`Failed to sync chef ${chef.id}:`, err);
    }
  }
  
  console.log('Sync complete');
}

syncAllChefVat();
```

## Step 7: Verification Queries

After running the sync, verify the results:

```sql
-- Count VAT-registered vs non-registered chefs
SELECT 
  is_vat_registered,
  COUNT(*) as count
FROM chefs
GROUP BY is_vat_registered;

-- View recent VAT sync log
SELECT 
  l.*,
  p.first_name || ' ' || p.last_name as chef_name
FROM chef_vat_sync_log l
JOIN chefs c ON l.chef_id = c.id
JOIN profiles p ON c.id = p.id
ORDER BY l.synced_at DESC
LIMIT 20;

-- Find chefs that might need manual review
SELECT 
  c.id,
  p.first_name || ' ' || p.last_name as chef_name,
  c.stripe_account_id,
  c.is_vat_registered,
  c.vat_number
FROM chefs c
JOIN profiles p ON c.id = p.id
WHERE c.stripe_account_id IS NOT NULL
  AND c.is_vat_registered = false
  AND c.hourly_rate > 500 -- High earners might need VAT
ORDER BY c.hourly_rate DESC;
```

## Important Notes

1. **Stripe Connect Limitations**: 
   - Express accounts don't always expose VAT information directly
   - VAT data might be in company.vat_id, company.tax_id, or metadata
   - Some information is only available after onboarding completion

2. **Danish VAT (MOMS) Format**:
   - CVR numbers are 8 digits
   - VAT numbers are typically "DK" + 8 digit CVR
   - Not all CVR numbers are VAT registered

3. **Manual Verification Needed**:
   - After sync, review chefs with high earnings but no VAT
   - Contact chefs directly if VAT status unclear
   - Consider adding VAT fields to chef onboarding form

4. **Testing**:
   - Test with one chef first before bulk sync
   - Keep the sync log for audit purposes
   - Have rollback plan ready

## Recommended Execution Order

1. Run the SQL migration to add columns and functions
2. Deploy the sync-stripe-vat Edge Function
3. Test with a single chef manually
4. Run verification queries to check current state
5. Execute batch sync for all chefs
6. Review results and handle exceptions manually
7. Update webhook handler for future automatic syncing

## Support Queries

If you need to check specific scenarios:

```sql
-- Find chefs who might exceed VAT threshold
SELECT 
  c.id,
  p.first_name || ' ' || p.last_name as chef_name,
  c.hourly_rate,
  COUNT(b.id) as total_bookings,
  SUM(b.total_amount) as total_revenue,
  c.is_vat_registered
FROM chefs c
JOIN profiles p ON c.id = p.id
LEFT JOIN bookings b ON c.id = b.chef_id
WHERE b.status = 'completed'
  AND b.created_at >= NOW() - INTERVAL '1 year'
GROUP BY c.id, p.first_name, p.last_name
HAVING SUM(b.total_amount) > 5000000 -- 50,000 DKK in øre
ORDER BY total_revenue DESC;
```

This comprehensive guide should help you sync VAT information from Stripe to your chef records effectively.