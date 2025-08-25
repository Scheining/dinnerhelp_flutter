import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import Stripe from 'https://esm.sh/stripe@14.21.0'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.7'

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
    const { 
      booking_id, 
      amount, 
      service_fee_amount, 
      vat_amount, 
      chef_stripe_account_id 
    } = await req.json()

    if (!booking_id || !amount || !chef_stripe_account_id) {
      return new Response(
        JSON.stringify({ error: 'Missing required parameters' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseKey)

    // Get booking details
    const { data: booking, error: bookingError } = await supabase
      .from('bookings')
      .select('*, chefs(*, profiles(*))')
      .eq('id', booking_id)
      .single()

    if (bookingError || !booking) {
      return new Response(
        JSON.stringify({ error: 'Booking not found' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Validate chef's Stripe account
    try {
      const account = await stripe.accounts.retrieve(chef_stripe_account_id)
      
      if (!account.charges_enabled || !account.details_submitted) {
        return new Response(
          JSON.stringify({ error: 'Chef Stripe account is not ready to receive payments' }),
          { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
    } catch (error) {
      return new Response(
        JSON.stringify({ error: 'Invalid chef Stripe account' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Check if payment intent already exists for this booking
    const { data: existingPaymentIntent } = await supabase
      .from('payment_intents')
      .select()
      .eq('booking_id', booking_id)
      .maybeSingle()

    if (existingPaymentIntent) {
      return new Response(
        JSON.stringify(existingPaymentIntent),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Calculate fees
    // User pays: chef_rate + VAT (25%)
    // Chef receives: chef_rate - platform_fee (15%)
    // Platform receives: 15% of chef_rate (before VAT)
    
    // amount is what user pays (including VAT)
    const baseAmount = Math.round(amount / 1.25) // Remove 25% VAT to get base chef rate
    const platformFee = Math.round(baseAmount * 0.15) // 15% platform fee from base amount
    const chefPayout = baseAmount - platformFee // What chef actually receives
    
    // For Stripe: application_fee is what platform keeps
    const applicationFeeAmount = service_fee_amount || platformFee

    // Create Stripe payment intent with Connect
    const paymentIntent = await stripe.paymentIntents.create(
      {
        amount, // Total amount user pays (includes VAT)
        currency: 'dkk',
        capture_method: 'manual', // Reserve funds, capture later
        application_fee_amount: applicationFeeAmount, // Platform's fee
        transfer_data: {
          destination: chef_stripe_account_id,
        },
        metadata: {
          booking_id,
          chef_id: booking.chef_id,
          user_id: booking.user_id,
          service_type: 'dining_experience',
        },
        description: `DinnerHelp booking - ${booking.chefs.profiles.first_name} ${booking.chefs.profiles.last_name}`,
        statement_descriptor_suffix: 'DINNERHELP',
      }
    )

    // Store payment intent in database
    const { data: storedPaymentIntent, error: storeError } = await supabase
      .from('payment_intents')
      .insert({
        id: paymentIntent.id,
        booking_id,
        chef_stripe_account_id,
        stripe_payment_intent_id: paymentIntent.id,
        amount,
        service_fee_amount: applicationFeeAmount,
        vat_amount: vat_amount || 0,
        currency: paymentIntent.currency.toUpperCase(),
        status: paymentIntent.status,
        capture_method: paymentIntent.capture_method,
        client_secret: paymentIntent.client_secret,
        created_at: new Date().toISOString(),
      })
      .select()
      .single()

    if (storeError) {
      console.error('Error storing payment intent:', storeError)
      // Clean up Stripe payment intent if database insert fails
      await stripe.paymentIntents.cancel(paymentIntent.id)
      
      return new Response(
        JSON.stringify({ error: 'Failed to create payment intent' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Update booking with payment intent
    await supabase
      .from('bookings')
      .update({
        payment_status: 'pending',
        stripe_payment_intent_id: paymentIntent.id,
        updated_at: new Date().toISOString(),
      })
      .eq('id', booking_id)

    return new Response(
      JSON.stringify(storedPaymentIntent),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Error creating payment intent:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})