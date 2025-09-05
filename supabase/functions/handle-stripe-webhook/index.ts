import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import Stripe from 'https://esm.sh/stripe@14.21.0'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.7'

const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY')!)
const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, stripe-signature',
}

Deno.serve(async (req: Request) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  const signature = req.headers.get('stripe-signature')
  const webhookSecret = Deno.env.get('STRIPE_WEBHOOK_SECRET')!

  try {
    const body = await req.text()
    
    // Verify the webhook signature
    let event: Stripe.Event
    try {
      event = stripe.webhooks.constructEvent(body, signature!, webhookSecret)
    } catch (err) {
      console.error('Webhook signature verification failed:', err)
      return new Response(
        JSON.stringify({ error: 'Invalid signature' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Initialize Supabase client
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Handle different event types
    switch (event.type) {
      case 'payment_intent.succeeded':
      case 'payment_intent.amount_capturable_updated': {
        // Payment has been authorized/captured - create the booking
        const paymentIntent = event.data.object as Stripe.PaymentIntent
        
        console.log(`Processing payment intent ${paymentIntent.id} with status ${paymentIntent.status}`)
        
        // Convert reservation to booking using our database function
        const { data: bookingResult, error: bookingError } = await supabase
          .rpc('convert_reservation_to_booking', {
            p_payment_intent_id: paymentIntent.id,
            p_stripe_payment_status: paymentIntent.status
          })
        
        if (bookingError) {
          console.error('Error creating booking from payment intent:', bookingError)
          // Don't return error to Stripe - log it and handle separately
          await supabase
            .from('system_logs')
            .insert({
              action: 'webhook_booking_creation_failed',
              details: {
                payment_intent_id: paymentIntent.id,
                error: bookingError.message,
                event_id: event.id
              }
            })
        } else {
          console.log(`Successfully created booking ${bookingResult} from payment intent ${paymentIntent.id}`)
          
          // Trigger booking confirmation notifications
          // You can call your existing notification Edge Functions here
          if (bookingResult) {
            await fetch(`${supabaseUrl}/functions/v1/send-booking-notifications`, {
              method: 'POST',
              headers: {
                'Authorization': `Bearer ${supabaseServiceKey}`,
                'Content-Type': 'application/json'
              },
              body: JSON.stringify({
                booking_id: bookingResult,
                notification_type: 'booking_confirmation'
              })
            })
          }
        }
        break
      }

      case 'payment_intent.canceled':
      case 'payment_intent.payment_failed': {
        // Payment was cancelled or failed - mark reservation as cancelled
        const paymentIntent = event.data.object as Stripe.PaymentIntent
        
        console.log(`Payment intent ${paymentIntent.id} was cancelled/failed`)
        
        // Update the reservation status
        const { error: updateError } = await supabase
          .from('payment_intents')
          .update({
            reservation_status: 'cancelled',
            updated_at: new Date().toISOString()
          })
          .eq('stripe_payment_intent_id', paymentIntent.id)
          .eq('reservation_status', 'active')
        
        if (updateError) {
          console.error('Error cancelling reservation:', updateError)
        } else {
          console.log(`Cancelled reservation for payment intent ${paymentIntent.id}`)
        }
        break
      }

      case 'charge.succeeded': {
        // Handle successful charge (for captured payments)
        const charge = event.data.object as Stripe.Charge
        console.log(`Charge succeeded for payment intent ${charge.payment_intent}`)
        
        // Update booking payment status if needed
        if (charge.payment_intent) {
          await supabase
            .from('bookings')
            .update({
              payment_status: 'succeeded',
              payment_captured_at: new Date().toISOString(),
              updated_at: new Date().toISOString()
            })
            .eq('stripe_payment_intent_id', charge.payment_intent)
        }
        break
      }

      case 'charge.refunded': {
        // Handle refunds
        const charge = event.data.object as Stripe.Charge
        console.log(`Charge refunded for payment intent ${charge.payment_intent}`)
        
        if (charge.payment_intent) {
          // Update booking status to refunded
          await supabase
            .from('bookings')
            .update({
              status: 'refunded',
              payment_status: 'refunded',
              updated_at: new Date().toISOString()
            })
            .eq('stripe_payment_intent_id', charge.payment_intent)
          
          // Cancel any active reservation
          await supabase
            .from('payment_intents')
            .update({
              reservation_status: 'cancelled',
              updated_at: new Date().toISOString()
            })
            .eq('stripe_payment_intent_id', charge.payment_intent)
        }
        break
      }

      default:
        console.log(`Unhandled event type: ${event.type}`)
    }

    // Return success response to Stripe
    return new Response(
      JSON.stringify({ received: true, event_type: event.type }),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Webhook processing error:', error)
    
    // Log the error but return success to Stripe to prevent retries
    const supabase = createClient(supabaseUrl, supabaseServiceKey)
    await supabase
      .from('system_logs')
      .insert({
        action: 'webhook_processing_error',
        details: {
          error: error.message,
          stack: error.stack
        }
      })
    
    return new Response(
      JSON.stringify({ received: true, error: 'Internal error logged' }),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})