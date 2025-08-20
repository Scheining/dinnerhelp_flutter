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
    const { payment_intent_id } = await req.json()

    if (!payment_intent_id) {
      return new Response(
        JSON.stringify({ error: 'Payment intent ID is required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseKey)

    // Get payment intent from database
    const { data: paymentIntent, error: fetchError } = await supabase
      .from('payment_intents')
      .select('*, bookings(*)')
      .eq('id', payment_intent_id)
      .single()

    if (fetchError || !paymentIntent) {
      return new Response(
        JSON.stringify({ error: 'Payment intent not found' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Confirm the payment intent with Stripe
    const confirmedPaymentIntent = await stripe.paymentIntents.confirm(
      paymentIntent.stripe_payment_intent_id,
      {},
      {
        stripeAccount: paymentIntent.chef_stripe_account_id,
      }
    )

    // Update payment intent status in database
    const { data: updatedPaymentIntent, error: updateError } = await supabase
      .from('payment_intents')
      .update({
        status: confirmedPaymentIntent.status,
        authorized_at: confirmedPaymentIntent.status === 'requires_capture' ? new Date().toISOString() : null,
        last_payment_error: confirmedPaymentIntent.last_payment_error?.message || null,
        updated_at: new Date().toISOString(),
      })
      .eq('id', payment_intent_id)
      .select()
      .single()

    if (updateError) {
      console.error('Error updating payment intent:', updateError)
      return new Response(
        JSON.stringify({ error: 'Failed to update payment intent' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Update booking status if payment was authorized
    if (confirmedPaymentIntent.status === 'requires_capture') {
      await supabase
        .from('bookings')
        .update({
          status: 'confirmed',
          payment_status: 'authorized',
          updated_at: new Date().toISOString(),
        })
        .eq('id', paymentIntent.booking_id)
    }

    return new Response(
      JSON.stringify(updatedPaymentIntent),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Error authorizing payment:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})