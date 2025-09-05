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
      cancelled_by, // 'user', 'chef', 'admin'
      reason 
    } = await req.json()

    if (!booking_id || !cancelled_by) {
      return new Response(
        JSON.stringify({ error: 'booking_id and cancelled_by are required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseKey)

    // Get booking details with payment intent
    const { data: booking, error: bookingError } = await supabase
      .from('bookings')
      .select('*')
      .eq('id', booking_id)
      .single()

    if (bookingError || !booking) {
      return new Response(
        JSON.stringify({ error: 'Booking not found' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Check if booking is already cancelled or refunded
    if (booking.status === 'cancelled' || booking.refund_status === 'processed') {
      return new Response(
        JSON.stringify({ error: 'Booking is already cancelled or refunded' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Get payment intent
    const { data: paymentIntent, error: piError } = await supabase
      .from('payment_intents')
      .select('*')
      .eq('booking_id', booking_id)
      .single()

    if (piError || !paymentIntent || !paymentIntent.stripe_payment_intent_id) {
      return new Response(
        JSON.stringify({ error: 'No payment found for this booking' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Check cancellation window (48 hours before service)
    const bookingDateTime = new Date(`${booking.date}T${booking.start_time}`)
    const now = new Date()
    const hoursUntilService = (bookingDateTime.getTime() - now.getTime()) / (1000 * 60 * 60)
    
    // Determine if refund should be processed
    let shouldRefund = false
    let refundAmount = 0

    if (cancelled_by === 'chef' || cancelled_by === 'admin') {
      // Chef or admin cancellations always get full refund
      shouldRefund = true
      refundAmount = booking.total_amount
    } else if (cancelled_by === 'user') {
      // User cancellations only refunded if >48 hours before service
      if (hoursUntilService > 48) {
        shouldRefund = true
        refundAmount = booking.total_amount
      } else {
        // No refund if within 48 hours
        console.log(`Cancellation within 48 hours. No refund. Hours until service: ${hoursUntilService}`)
      }
    }

    let refundId = null

    // Process refund if eligible
    if (shouldRefund && refundAmount > 0) {
      try {
        // Create refund in Stripe
        const refund = await stripe.refunds.create({
          payment_intent: paymentIntent.stripe_payment_intent_id,
          amount: refundAmount, // Refund full amount
          reason: 'requested_by_customer',
          metadata: {
            booking_id: booking_id,
            cancelled_by: cancelled_by,
            cancellation_reason: reason || 'No reason provided'
          }
        })

        refundId = refund.id
        console.log(`Refund created: ${refundId} for amount: ${refundAmount}`)

        // Update booking with refund info
        await supabase
          .from('bookings')
          .update({
            status: 'cancelled',
            payment_status: 'refunded',
            refund_status: 'processed',
            refunded_amount: refundAmount,
            cancelled_by: cancelled_by,
            cancellation_reason: reason,
            cancelled_at: new Date().toISOString(),
            updated_at: new Date().toISOString()
          })
          .eq('id', booking_id)

        // Update payment intent status
        await supabase
          .from('payment_intents')
          .update({
            status: 'refunded',
            updated_at: new Date().toISOString()
          })
          .eq('booking_id', booking_id)

      } catch (refundError: any) {
        console.error('Stripe refund error:', refundError)
        
        // Update booking with failed refund status
        await supabase
          .from('bookings')
          .update({
            refund_status: 'failed',
            updated_at: new Date().toISOString()
          })
          .eq('id', booking_id)

        return new Response(
          JSON.stringify({ 
            error: 'Failed to process refund',
            details: refundError.message 
          }),
          { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
    } else {
      // Cancellation without refund
      await supabase
        .from('bookings')
        .update({
          status: 'cancelled',
          refund_status: 'none',
          refunded_amount: 0,
          cancelled_by: cancelled_by,
          cancellation_reason: reason,
          cancelled_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        })
        .eq('id', booking_id)
    }

    // Log the cancellation/refund in booking_payment_logs
    await supabase
      .from('booking_payment_logs')
      .insert({
        booking_id: booking_id,
        log_type: shouldRefund ? 'refund_processed' : 'cancellation_no_refund',
        amount: refundAmount,
        description: `Booking cancelled by ${cancelled_by}. ${shouldRefund ? `Refund of ${refundAmount} DKK processed.` : 'No refund (within 48 hours).'}`,
        metadata: {
          cancelled_by: cancelled_by,
          reason: reason,
          hours_until_service: hoursUntilService,
          refund_id: refundId
        }
      })

    // Send push notification about cancellation/refund
    try {
      // Determine notification content based on cancellation type
      let notificationTitle = ''
      let notificationContent = ''
      
      if (cancelled_by === 'chef') {
        notificationTitle = 'Booking Cancelled by Chef'
        notificationContent = shouldRefund 
          ? `Your booking has been cancelled by the chef. A refund of ${refundAmount} kr is being processed.`
          : 'Your booking has been cancelled by the chef.'
      } else if (cancelled_by === 'user') {
        notificationTitle = shouldRefund ? 'Booking Cancelled - Refund Processing' : 'Booking Cancelled'
        notificationContent = shouldRefund 
          ? `Your cancellation has been confirmed. A refund of ${refundAmount} kr is being processed.`
          : 'Your booking has been cancelled. No refund due to cancellation within 48 hours of service.'
      } else if (cancelled_by === 'admin') {
        notificationTitle = 'Booking Cancelled'
        notificationContent = shouldRefund 
          ? `Your booking has been cancelled. A refund of ${refundAmount} kr is being processed.`
          : 'Your booking has been cancelled.'
      }
      
      // Send notification to user
      if (notificationTitle && notificationContent) {
        await supabase.functions.invoke('send-push-notification', {
          body: {
            user_id: booking.user_id,
            title: notificationTitle,
            content: notificationContent,
            data: {
              type: 'booking_cancelled',
              booking_id: booking_id,
              cancelled_by: cancelled_by,
              refunded: shouldRefund,
              refund_amount: refundAmount,
            },
            deep_link: `/bookings/${booking_id}`
          }
        })
      }
      
      // If cancelled by user, also notify the chef
      if (cancelled_by === 'user') {
        await supabase.functions.invoke('send-push-notification', {
          body: {
            user_id: booking.chef_id,
            title: 'Booking Cancelled',
            content: `Your booking for ${booking.date} at ${booking.start_time} has been cancelled by the customer.`,
            data: {
              type: 'booking_cancelled',
              booking_id: booking_id,
              cancelled_by: 'user',
            },
            deep_link: `/chef/bookings/${booking_id}`
          }
        })
      }
    } catch (notificationError) {
      // Log error but don't fail the refund process
      console.error('Failed to send push notification:', notificationError)
    }

    return new Response(
      JSON.stringify({ 
        success: true,
        booking_id: booking_id,
        refunded: shouldRefund,
        refund_amount: refundAmount,
        message: shouldRefund 
          ? `Refund of ${refundAmount} DKK has been processed` 
          : 'Booking cancelled. No refund due to cancellation policy.'
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error: any) {
    console.error('Error processing refund:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})