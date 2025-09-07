import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import Stripe from 'https://esm.sh/stripe@14.21.0'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.7'

const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY')!)

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, stripe-signature',
}

// Public webhook endpoint - no JWT required
Deno.serve(async (req: Request) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Get the signature from headers
    const signature = req.headers.get('stripe-signature')
    
    if (!signature) {
      console.log('No stripe signature found in headers')
      return new Response(
        JSON.stringify({ error: 'No stripe signature found' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Get webhook secret - try production first, then development
    let endpointSecret = Deno.env.get('STRIPE_WEBHOOK_SECRET')
    const isDevelopment = Deno.env.get('ENVIRONMENT') === 'development' || 
                         Deno.env.get('IS_LOCAL_SUPABASE') === 'true'
    
    // For local development, use separate environment variable
    if (!endpointSecret && isDevelopment) {
      endpointSecret = Deno.env.get('STRIPE_WEBHOOK_SECRET_LOCAL')
      if (endpointSecret) {
        console.log('Using local development webhook secret')
      }
    }
    
    // Debug logging
    console.log('=== Webhook Debug Info ===')
    console.log('Environment:', isDevelopment ? 'development' : 'production')
    console.log('Webhook secret configured:', !!endpointSecret)
    if (endpointSecret) {
      console.log('Secret starts with:', endpointSecret.substring(0, 10) + '...')
      console.log('Secret length:', endpointSecret.length)
    }
    console.log('Received signature:', signature?.substring(0, 20) + '...')
    
    if (!endpointSecret) {
      console.error('STRIPE_WEBHOOK_SECRET not configured')
      console.error('For local development, set STRIPE_WEBHOOK_SECRET_LOCAL from stripe listen output')
      return new Response(
        JSON.stringify({ 
          error: 'Webhook configuration error',
          message: 'Webhook secret not configured. Please set appropriate environment variables.'
        }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Get the raw body
    const body = await req.text()
    
    // Verify webhook signature
    let event: Stripe.Event
    
    try {
      event = stripe.webhooks.constructEvent(body, signature, endpointSecret)
      console.log('✅ Webhook signature verified successfully')
    } catch (err) {
      console.error('❌ Webhook signature verification failed:', err.message)
      console.error('This could mean:')
      console.error('1. The webhook secret is incorrect')
      console.error('2. The signature has been tampered with')
      console.error('3. The raw body has been modified before verification')
      
      return new Response(
        JSON.stringify({ 
          error: `Webhook Error: ${err.message}`,
          hint: 'Check webhook secret configuration in environment variables'
        }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    console.log('Webhook event received:', event.type)

    // Initialize Supabase client with service role key
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Handle the event
    switch (event.type) {
      case 'payment_intent.succeeded': {
        const paymentIntent = event.data.object as Stripe.PaymentIntent
        console.log('Payment succeeded:', paymentIntent.id)
        
        // First, update the payment intent status in our database
        const { error: updateError } = await supabase
          .from('payment_intents')
          .update({ 
            status: paymentIntent.status,
            updated_at: new Date().toISOString()
          })
          .eq('stripe_payment_intent_id', paymentIntent.id)
        
        if (updateError) {
          console.error('Error updating payment intent:', updateError)
        }
        
        // Convert reservation to booking
        const { data: bookingResult, error: bookingError } = await supabase
          .rpc('convert_reservation_to_booking', {
            p_payment_intent_id: paymentIntent.id,
            p_stripe_payment_status: paymentIntent.status
          })
        
        if (bookingError) {
          console.error('Error creating booking from reservation:', bookingError)
          // Log but don't fail the webhook
        } else {
          console.log('Booking created successfully:', bookingResult)
        }
        break
      }

      case 'payment_intent.payment_failed': {
        const failedPayment = event.data.object as Stripe.PaymentIntent
        console.log('Payment failed:', failedPayment.id)
        
        // Update payment intent status
        await supabase
          .from('payment_intents')
          .update({ 
            status: 'failed',
            reservation_status: 'expired',
            updated_at: new Date().toISOString()
          })
          .eq('stripe_payment_intent_id', failedPayment.id)
        break
      }

      case 'payment_intent.canceled': {
        const canceledPayment = event.data.object as Stripe.PaymentIntent
        console.log('Payment canceled:', canceledPayment.id)
        
        // Update payment intent status
        await supabase
          .from('payment_intents')
          .update({ 
            status: 'canceled',
            reservation_status: 'expired',
            updated_at: new Date().toISOString()
          })
          .eq('stripe_payment_intent_id', canceledPayment.id)
        break
      }

      case 'charge.refunded': {
        const charge = event.data.object as Stripe.Charge
        console.log('Refund processed for payment:', charge.payment_intent)
        
        // Update booking status if payment_intent exists
        if (charge.payment_intent) {
          await supabase
            .from('bookings')
            .update({ 
              payment_status: 'refunded',
              status: 'refunded',
              updated_at: new Date().toISOString()
            })
            .eq('stripe_payment_intent_id', charge.payment_intent)
        }
        break
      }

      default:
        console.log(`Unhandled event type: ${event.type}`)
    }

    // Return success to Stripe
    return new Response(
      JSON.stringify({ received: true }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Webhook processing error:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})