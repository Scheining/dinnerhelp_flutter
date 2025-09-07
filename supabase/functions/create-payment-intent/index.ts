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
      booking_id, // Optional - for backward compatibility
      amount, 
      service_fee_amount, 
      payment_processing_fee,
      vat_amount, 
      chef_stripe_account_id,
      // New fields for reservation system
      booking_data // Contains all booking details for creating reservation
    } = await req.json()

    // Log received parameters for debugging
    console.log('Received parameters:', {
      has_booking_id: !!booking_id,
      has_amount: !!amount,
      amount_value: amount,
      has_chef_stripe_account_id: !!chef_stripe_account_id,
      chef_stripe_account_id_value: chef_stripe_account_id,
      has_booking_data: !!booking_data
    })

    // Support both old (with booking_id) and new (with booking_data) approaches
    if (!amount || !chef_stripe_account_id) {
      console.error('Missing required parameters:', {
        amount: amount || 'missing',
        chef_stripe_account_id: chef_stripe_account_id || 'missing'
      })
      return new Response(
        JSON.stringify({ 
          error: 'Missing required parameters',
          details: {
            amount_provided: !!amount,
            chef_stripe_account_id_provided: !!chef_stripe_account_id
          }
        }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseKey)
    
    // Get auth header to identify user
    const authHeader = req.headers.get('Authorization')
    let currentUserId: string | null = null
    
    if (authHeader) {
      const token = authHeader.replace('Bearer ', '')
      const { data: { user }, error } = await supabase.auth.getUser(token)
      if (!error && user) {
        currentUserId = user.id
      }
    }

    // Handle both old and new approaches
    let booking = null
    let useReservationSystem = false
    
    if (booking_id) {
      // Old approach: booking already exists
      const { data: bookingData, error: bookingError } = await supabase
        .from('bookings')
        .select('*, chefs(*, profiles(*))')
        .eq('id', booking_id)
        .single()

      if (bookingError || !bookingData) {
        return new Response(
          JSON.stringify({ error: 'Booking not found' }),
          { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
      booking = bookingData
    } else if (booking_data) {
      // New approach: create reservation without booking
      useReservationSystem = true
      
      // Get chef details for the description
      const { data: chefData, error: chefError } = await supabase
        .from('chefs')
        .select('*, profiles(*)')
        .eq('id', booking_data.chef_id)
        .single()
      
      if (chefError || !chefData) {
        return new Response(
          JSON.stringify({ error: 'Chef not found' }),
          { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
      
      // Create a booking-like object for compatibility
      booking = {
        chef_id: booking_data.chef_id,
        user_id: booking_data.user_id,
        chefs: {
          profiles: chefData.profiles
        }
      }
    } else {
      return new Response(
        JSON.stringify({ error: 'Either booking_id or booking_data is required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
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

    // Check if payment intent already exists
    if (booking_id) {
      // Old approach: check by booking_id
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
    }

    // Fetch chef with VAT info
    const { data: chefInfo, error: chefInfoError } = await supabase
      .from('chefs')
      .select('is_vat_registered, vat_rate, commission_rate')
      .eq('id', booking_data?.chef_id || booking?.chef_id)
      .single()
    
    if (chefInfoError) {
      console.error('Failed to fetch chef VAT info:', chefInfoError)
    }
    
    // Calculate fees based on new structure
    // User pays: base_amount + service_fee (5%) + payment_processing + VAT (if registered)
    // Chef pays: commission (15%) from their base amount
    // Platform receives: commission (15%) from chef + service_fee (5%) from user
    
    const isVatRegistered = chefInfo?.is_vat_registered || false
    const vatRate = isVatRegistered ? (chefInfo?.vat_rate || 0.25) : 0
    const commissionRate = chefInfo?.commission_rate || 0.15
    
    // Calculate base amount (without VAT and fees)
    const baseAmount = Math.round(amount / (1 + vatRate + 0.05)) // Approximate base
    
    // Chef-side commission (15% from chef's earnings)
    const chefCommission = Math.round(baseAmount * commissionRate)
    
    // User-side service fee (5% shown to user)
    const userServiceFee = service_fee_amount || Math.round(baseAmount * 0.05)
    
    // Total platform revenue (commission + service fee)
    const applicationFeeAmount = chefCommission + userServiceFee
    
    // What chef actually receives (base minus their commission)
    const chefPayout = baseAmount - chefCommission
    
    // Get or create Stripe customer for the user
    let stripeCustomerId: string | null = null
    let ephemeralKey: any = null
    
    if (currentUserId || booking_data?.user_id || booking?.user_id) {
      const userId = currentUserId || booking_data?.user_id || booking?.user_id
      
      // Check if user already has a Stripe customer ID
      const { data: profile } = await supabase
        .from('profiles')
        .select('stripe_customer_id, email')
        .eq('id', userId)
        .single()
      
      if (profile?.stripe_customer_id) {
        stripeCustomerId = profile.stripe_customer_id
      } else if (profile?.email) {
        // Create new Stripe customer
        const customer = await stripe.customers.create({
          email: profile.email,
          metadata: {
            user_id: userId,
            platform: 'dinnerhelp'
          }
        })
        
        stripeCustomerId = customer.id
        
        // Store customer ID in profile
        await supabase
          .from('profiles')
          .update({ stripe_customer_id: stripeCustomerId })
          .eq('id', userId)
      }
      
      // Generate ephemeral key for the customer
      if (stripeCustomerId) {
        ephemeralKey = await stripe.ephemeralKeys.create(
          { customer: stripeCustomerId },
          { apiVersion: '2023-10-16' }
        )
      }
    }

    // Create Stripe payment intent with Connect
    const paymentIntent = await stripe.paymentIntents.create(
      {
        amount, // Total amount user pays (includes VAT)
        currency: 'dkk',
        customer: stripeCustomerId || undefined, // Attach customer if available
        // Payment captured immediately (no manual capture)
        automatic_payment_methods: {
          enabled: true,
        },
        setup_future_usage: 'off_session', // Allow saving card for future use
        application_fee_amount: applicationFeeAmount, // Platform's fee
        transfer_data: {
          destination: chef_stripe_account_id,
        },
        metadata: {
          booking_id,
          chef_id: booking.chef_id,
          user_id: booking.user_id,
          service_type: 'dining_experience',
          base_amount: baseAmount,
          chef_commission: chefCommission,
          user_service_fee: userServiceFee,
          payment_processing_fee: payment_processing_fee || 0,
          vat_amount: vat_amount || 0,
          vat_rate: vatRate,
          is_vat_registered: isVatRegistered,
          chef_payout: chefPayout,
          platform_revenue: applicationFeeAmount,
        },
        description: `DinnerHelp booking - ${booking.chefs.profiles.first_name} ${booking.chefs.profiles.last_name}`,
        statement_descriptor_suffix: 'DINNERHELP',
      }
    )

    // Store payment intent in database
    const paymentIntentData: any = {
      // Don't specify id - let it auto-generate as UUID
      chef_stripe_account_id,
      stripe_payment_intent_id: paymentIntent.id,
      amount,
      service_fee_amount: userServiceFee,
      chef_commission_amount: chefCommission,
      payment_processing_fee: payment_processing_fee || 0,
      vat_amount: vat_amount || 0,
      currency: paymentIntent.currency.toUpperCase(),
      status: paymentIntent.status,
      capture_method: paymentIntent.capture_method,
      client_secret: paymentIntent.client_secret,
      created_at: new Date().toISOString(),
    }
    
    // Add fields based on approach
    if (useReservationSystem) {
      // New approach: store booking data and set reservation
      paymentIntentData.booking_data = booking_data
      paymentIntentData.reservation_expires_at = new Date(Date.now() + 15 * 60 * 1000).toISOString() // 15 minutes
      paymentIntentData.reservation_status = 'active'
    } else {
      // Old approach: link to existing booking
      paymentIntentData.booking_id = booking_id
    }
    
    const { data: storedPaymentIntent, error: storeError } = await supabase
      .from('payment_intents')
      .insert(paymentIntentData)
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

    // Update booking with payment intent (only for old approach)
    if (booking_id) {
      await supabase
        .from('bookings')
        .update({
          payment_status: 'pending',
          stripe_payment_intent_id: paymentIntent.id,
          updated_at: new Date().toISOString(),
        })
        .eq('id', booking_id)
    }

    // Return payment intent with customer data
    const response = {
      ...storedPaymentIntent,
      customer_id: stripeCustomerId,
      ephemeral_key: ephemeralKey?.secret || null,
      ephemeral_key_expires: ephemeralKey?.expires || null
    }
    
    return new Response(
      JSON.stringify(response),
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