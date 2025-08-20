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
    const { booking_id, amount, reason, description } = await req.json()

    if (!booking_id || !reason) {
      return new Response(
        JSON.stringify({ error: 'Booking ID and reason are required' }),
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
      .in('status', ['succeeded', 'requires_capture'])
      .single()

    if (fetchError || !paymentIntent) {
      return new Response(
        JSON.stringify({ error: 'Payment intent not found or not refundable' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Determine refund amount
    const refundAmount = amount || paymentIntent.amount
    
    if (refundAmount > paymentIntent.amount) {
      return new Response(
        JSON.stringify({ error: 'Refund amount cannot exceed payment amount' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Check booking date for cancellation policy
    const bookingDate = new Date(paymentIntent.bookings.date)
    const bookingTime = paymentIntent.bookings.start_time
    const bookingDateTime = new Date(`${paymentIntent.bookings.date}T${bookingTime}`)
    const now = new Date()
    const hoursUntilBooking = (bookingDateTime.getTime() - now.getTime()) / (1000 * 60 * 60)
    
    let netRefundAmount = 0
    let refundFeeAmount = 0
    let policyDescription = ''
    
    // Apply DinnerHelp cancellation policy
    if (reason === 'requested_by_customer') {
      if (hoursUntilBooking >= 48) {
        // Full refund for cancellations 48+ hours before
        netRefundAmount = refundAmount
        refundFeeAmount = 0
        policyDescription = 'Full refund - Cancelled 48+ hours before booking'
      } else if (hoursUntilBooking >= 24) {
        // 50% refund for cancellations 24-48 hours before
        netRefundAmount = Math.round(refundAmount * 0.5)
        refundFeeAmount = refundAmount - netRefundAmount
        policyDescription = '50% refund - Cancelled 24-48 hours before booking'
      } else {
        // No refund for cancellations less than 24 hours before
        netRefundAmount = 0
        refundFeeAmount = refundAmount
        policyDescription = 'No refund - Cancelled less than 24 hours before booking'
        
        // Don't process Stripe refund if amount is 0
        if (netRefundAmount === 0) {
          // Just update the booking status and log
          await supabase
            .from('bookings')
            .update({
              status: 'cancelled',
              payment_status: 'non_refundable',
              cancellation_reason: description || 'Customer requested cancellation',
              cancelled_at: new Date().toISOString(),
              updated_at: new Date().toISOString(),
            })
            .eq('id', booking_id)
          
          // Log the non-refundable cancellation
          await supabase
            .from('booking_payment_logs')
            .insert({
              booking_id,
              action: 'cancellation_non_refundable',
              status: 'completed',
              amount: 0,
              metadata: {
                hours_until_booking: hoursUntilBooking,
                policy_description: policyDescription,
                original_amount: refundAmount,
              },
            })
          
          return new Response(
            JSON.stringify({
              success: true,
              refund_amount: 0,
              policy: policyDescription,
              message: 'Booking cancelled. No refund due to cancellation policy.',
            }),
            { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
          )
        }
      }
    } else {
      // Full refund for other reasons (chef cancellation, platform issues, etc.)
      netRefundAmount = refundAmount
      refundFeeAmount = 0
      policyDescription = description || `Full refund - ${reason}`
    }

    // Create refund with Stripe
    const refund = await stripe.refunds.create(
      {
        payment_intent: paymentIntent.stripe_payment_intent_id,
        amount: netRefundAmount,
        reason: reason === 'fraudulent' ? 'fraudulent' : 'requested_by_customer',
        metadata: {
          booking_id,
          reason,
          description: description || '',
        },
      },
      {
        stripeAccount: paymentIntent.chef_stripe_account_id,
      }
    )

    // Create refund record in database
    const { data: refundRecord, error: refundError } = await supabase
      .from('refunds')
      .insert({
        id: refund.id,
        payment_intent_id: paymentIntent.id,
        booking_id,
        amount: netRefundAmount,
        fee_amount: refundFeeAmount,
        currency: refund.currency.toUpperCase(),
        status: refund.status,
        reason,
        description,
        created_at: new Date().toISOString(),
      })
      .select()
      .single()

    if (refundError) {
      console.error('Error creating refund record:', refundError)
      return new Response(
        JSON.stringify({ error: 'Failed to create refund record' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Update booking status
    await supabase
      .from('bookings')
      .update({
        status: refund.amount === paymentIntent.amount ? 'cancelled' : 'partially_refunded',
        payment_status: refund.amount === paymentIntent.amount ? 'refunded' : 'partially_refunded',
        updated_at: new Date().toISOString(),
      })
      .eq('id', booking_id)

    // If chef payout exists, create a deduction
    const { data: payout } = await supabase
      .from('chef_payouts')
      .select()
      .eq('booking_id', booking_id)
      .single()

    if (payout) {
      const chefDeduction = refundAmount - paymentIntent.service_fee_amount - refundFeeAmount
      
      await supabase
        .from('chef_payout_deductions')
        .insert({
          payout_id: payout.id,
          amount: chefDeduction,
          reason: 'refund',
          refund_id: refund.id,
          created_at: new Date().toISOString(),
        })
    }

    // Send notification to user about refund processing
    await supabase
      .from('notifications')
      .insert({
        user_id: paymentIntent.bookings.user_id,
        type: 'refund_processing',
        title: 'Refund Processing',
        message: `Your refund of ${(netRefundAmount / 100).toFixed(2)} kr is being processed.`,
        data: { booking_id, refund_id: refund.id },
        created_at: new Date().toISOString(),
      })

    return new Response(
      JSON.stringify(refundRecord),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Error processing refund:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})