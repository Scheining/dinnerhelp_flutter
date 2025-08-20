import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import Stripe from 'https://esm.sh/stripe@14.21.0'

const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY')!)

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { stripe_account_id } = await req.json()

    if (!stripe_account_id) {
      return new Response(
        JSON.stringify({ error: 'Stripe account ID is required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Retrieve the Connect account from Stripe
    const account = await stripe.accounts.retrieve(stripe_account_id)

    // Check if account is valid and can receive payments
    const isValid = account.charges_enabled && 
                   account.payouts_enabled && 
                   account.details_submitted &&
                   account.requirements?.currently_due?.length === 0

    const result = {
      valid: isValid,
      charges_enabled: account.charges_enabled,
      payouts_enabled: account.payouts_enabled,
      details_submitted: account.details_submitted,
      requirements_due: account.requirements?.currently_due || [],
      requirements_eventually_due: account.requirements?.eventually_due || [],
      country: account.country,
      default_currency: account.default_currency,
      verification_status: account.individual?.verification?.status || account.company?.verification?.status,
    }

    return new Response(
      JSON.stringify(result),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Error validating Stripe account:', error)
    
    // Handle specific Stripe errors
    if (error.type === 'StripePermissionError') {
      return new Response(
        JSON.stringify({ 
          error: 'Invalid Stripe account ID or insufficient permissions',
          valid: false 
        }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    return new Response(
      JSON.stringify({ 
        error: error.message,
        valid: false 
      }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})