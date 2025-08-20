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
    const { booking_id } = await req.json()

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

    // Get booking details with chef info
    const { data: booking, error: bookingError } = await supabase
      .from('bookings')
      .select(`
        *,
        chefs (
          id,
          stripe_connect_account_id,
          price_per_hour,
          bank_holiday_extra_charge,
          new_years_eve_extra_charge,
          profiles (
            first_name,
            last_name,
            email
          )
        ),
        profiles!user_id (
          first_name,
          last_name,
          email
        )
      `)
      .eq('id', booking_id)
      .single()

    if (bookingError || !booking) {
      return new Response(
        JSON.stringify({ error: 'Booking not found' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Check if chef has Stripe account
    if (!booking.chefs.stripe_connect_account_id) {
      // Update booking payment status
      await supabase
        .from('bookings')
        .update({
          payment_status: 'pending_setup',
          updated_at: new Date().toISOString(),
        })
        .eq('id', booking_id)

      // Log the issue
      await supabase
        .from('booking_payment_logs')
        .insert({
          booking_id,
          action: 'payment_authorization_failed',
          status: 'failed',
          error_message: 'Chef Stripe Connect account not configured',
        })

      return new Response(
        JSON.stringify({ 
          error: 'Chef has not set up payment account',
          requires_chef_onboarding: true 
        }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Check if payment intent already exists
    const { data: existingPaymentIntent } = await supabase
      .from('payment_intents')
      .select()
      .eq('booking_id', booking_id)
      .maybeSingle()

    let paymentIntent

    if (existingPaymentIntent) {
      // If payment intent exists, just authorize it
      if (existingPaymentIntent.status === 'requires_payment_method' || 
          existingPaymentIntent.status === 'requires_confirmation') {
        
        // Confirm the existing payment intent
        paymentIntent = await stripe.paymentIntents.confirm(
          existingPaymentIntent.stripe_payment_intent_id,
          {
            payment_method: 'pm_card_visa', // This should come from frontend
            return_url: `${Deno.env.get('FRONTEND_URL')}/booking/${booking_id}/payment`,
          }
        )
      } else {
        paymentIntent = await stripe.paymentIntents.retrieve(
          existingPaymentIntent.stripe_payment_intent_id
        )
      }
    } else {
      // Calculate amounts
      const baseAmount = booking.total_amount
      const serviceFeeAmount = Math.round(baseAmount * 0.15) // 15% service fee
      const vatAmount = Math.round(baseAmount * 0.25) // 25% VAT
      const totalAmount = baseAmount + vatAmount

      // Check for holiday surcharges
      const bookingDate = new Date(booking.date)
      let adjustedAmount = baseAmount
      
      if (isHoliday(bookingDate) && booking.chefs.bank_holiday_extra_charge) {
        adjustedAmount += Math.round(baseAmount * booking.chefs.bank_holiday_extra_charge / 100)
      }
      
      if (isNewYearEve(bookingDate) && booking.chefs.new_years_eve_extra_charge) {
        adjustedAmount += Math.round(baseAmount * booking.chefs.new_years_eve_extra_charge / 100)
      }

      // Create new payment intent with manual capture
      paymentIntent = await stripe.paymentIntents.create({
        amount: totalAmount,
        currency: 'dkk',
        capture_method: 'manual', // Reserve funds only
        payment_method_types: ['card'],
        application_fee_amount: serviceFeeAmount,
        transfer_data: {
          destination: booking.chefs.stripe_connect_account_id,
        },
        metadata: {
          booking_id,
          chef_id: booking.chef_id,
          user_id: booking.user_id,
          booking_date: booking.date,
          service_type: 'dining_experience',
        },
        description: `DinnerHelp - ${booking.chefs.profiles.first_name} ${booking.chefs.profiles.last_name} - ${bookingDate.toLocaleDateString()}`,
        statement_descriptor_suffix: 'DINNERHELP',
        receipt_email: booking.profiles.email,
      })

      // Store payment intent in database
      await supabase
        .from('payment_intents')
        .insert({
          id: paymentIntent.id,
          booking_id,
          chef_stripe_account_id: booking.chefs.stripe_connect_account_id,
          stripe_payment_intent_id: paymentIntent.id,
          amount: totalAmount,
          service_fee_amount: serviceFeeAmount,
          vat_amount: vatAmount,
          currency: 'DKK',
          status: paymentIntent.status,
          capture_method: 'manual',
          client_secret: paymentIntent.client_secret,
          created_at: new Date().toISOString(),
        })

      // Confirm the payment intent to authorize it
      paymentIntent = await stripe.paymentIntents.confirm(
        paymentIntent.id,
        {
          payment_method: 'pm_card_visa', // This should come from frontend
          return_url: `${Deno.env.get('FRONTEND_URL')}/booking/${booking_id}/payment`,
        }
      )
    }

    // Update payment intent status in database
    await supabase
      .from('payment_intents')
      .update({
        status: paymentIntent.status,
        authorized_at: paymentIntent.status === 'requires_capture' ? new Date().toISOString() : null,
        updated_at: new Date().toISOString(),
      })
      .eq('booking_id', booking_id)

    // Update booking payment status
    const newPaymentStatus = paymentIntent.status === 'requires_capture' ? 'authorized' : 
                            paymentIntent.status === 'processing' ? 'processing' : 
                            'authorization_pending'

    await supabase
      .from('bookings')
      .update({
        payment_status: newPaymentStatus,
        payment_reserved_at: paymentIntent.status === 'requires_capture' ? new Date().toISOString() : null,
        stripe_payment_intent_id: paymentIntent.id,
        updated_at: new Date().toISOString(),
      })
      .eq('id', booking_id)

    // Log the action
    await supabase
      .from('booking_payment_logs')
      .insert({
        booking_id,
        action: 'payment_authorization_completed',
        status: 'success',
        amount: paymentIntent.amount,
        metadata: {
          payment_intent_id: paymentIntent.id,
          payment_status: paymentIntent.status,
        },
      })

    // Send notification to user
    if (paymentIntent.status === 'requires_capture') {
      await supabase
        .from('notifications')
        .insert({
          user_id: booking.user_id,
          type: 'payment_authorized',
          title: 'Payment Reserved',
          message: `Payment of ${(paymentIntent.amount / 100).toFixed(2)} kr has been reserved for your booking with ${booking.chefs.profiles.first_name}.`,
          data: { booking_id },
          created_at: new Date().toISOString(),
        })
    }

    return new Response(
      JSON.stringify({
        success: true,
        payment_intent_id: paymentIntent.id,
        status: paymentIntent.status,
        client_secret: paymentIntent.client_secret,
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Error authorizing payment:', error)
    
    // Log error
    const { booking_id } = await req.json().catch(() => ({ booking_id: null }))
    if (booking_id) {
      const supabaseUrl = Deno.env.get('SUPABASE_URL')!
      const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
      const supabase = createClient(supabaseUrl, supabaseKey)
      
      await supabase
        .from('booking_payment_logs')
        .insert({
          booking_id,
          action: 'payment_authorization_error',
          status: 'error',
          error_message: error.message,
        })
    }
    
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})

// Helper function to check if date is a Danish holiday
function isHoliday(date: Date): boolean {
  const year = date.getFullYear()
  const month = date.getMonth() + 1
  const day = date.getDate()
  
  // Danish public holidays (simplified)
  const holidays = [
    `${year}-01-01`, // New Year's Day
    `${year}-12-24`, // Christmas Eve
    `${year}-12-25`, // Christmas Day
    `${year}-12-26`, // Boxing Day
    `${year}-12-31`, // New Year's Eve
  ]
  
  const dateStr = `${year}-${month.toString().padStart(2, '0')}-${day.toString().padStart(2, '0')}`
  return holidays.includes(dateStr)
}

// Helper function to check if date is New Year's Eve
function isNewYearEve(date: Date): boolean {
  return date.getMonth() === 11 && date.getDate() === 31
}