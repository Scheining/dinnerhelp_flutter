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
    const { booking_id, actual_amount } = await req.json()

    if (!booking_id) {
      return new Response(
        JSON.stringify({ error: 'Booking ID is required' }),
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
      .eq('booking_id', booking_id)
      .eq('status', 'requires_capture')
      .single()

    if (fetchError || !paymentIntent) {
      return new Response(
        JSON.stringify({ error: 'Payment intent not found or not authorized' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Calculate final amount
    let captureAmount = paymentIntent.amount
    if (actual_amount && actual_amount !== paymentIntent.amount) {
      // Recalculate fees for actual amount
      const baseAmount = Math.round(actual_amount / 1.25) // Remove VAT
      const serviceFeeAmount = Math.round(baseAmount * 0.15) // 15% service fee
      const vatAmount = actual_amount - baseAmount // VAT difference
      captureAmount = actual_amount
      
      // Update payment intent with actual amounts
      await supabase
        .from('payment_intents')
        .update({
          amount: captureAmount,
          service_fee_amount: serviceFeeAmount,
          vat_amount: vatAmount,
          updated_at: new Date().toISOString(),
        })
        .eq('id', paymentIntent.id)
    }

    // Capture the payment intent with Stripe
    const capturedPaymentIntent = await stripe.paymentIntents.capture(
      paymentIntent.stripe_payment_intent_id,
      {
        amount_to_capture: captureAmount,
      },
      {
        stripeAccount: paymentIntent.chef_stripe_account_id,
      }
    )

    // Update payment intent status in database
    const { data: updatedPaymentIntent, error: updateError } = await supabase
      .from('payment_intents')
      .update({
        status: capturedPaymentIntent.status,
        captured_at: new Date().toISOString(),
        amount: captureAmount,
        updated_at: new Date().toISOString(),
      })
      .eq('id', paymentIntent.id)
      .select()
      .single()

    if (updateError) {
      console.error('Error updating payment intent:', updateError)
      return new Response(
        JSON.stringify({ error: 'Failed to update payment intent' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Update booking status
    await supabase
      .from('bookings')
      .update({
        status: 'completed',
        payment_status: 'succeeded',
        total_amount: captureAmount,
        updated_at: new Date().toISOString(),
      })
      .eq('id', booking_id)

    // Calculate chef payout (amount minus service fee)
    const chefPayout = captureAmount - paymentIntent.service_fee_amount

    // Create payout record for chef
    await supabase
      .from('chef_payouts')
      .insert({
        chef_id: paymentIntent.bookings.chef_id,
        booking_id: booking_id,
        payment_intent_id: paymentIntent.id,
        amount: chefPayout,
        status: 'pending',
        created_at: new Date().toISOString(),
      })

    return new Response(
      JSON.stringify(updatedPaymentIntent),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Error capturing payment:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})