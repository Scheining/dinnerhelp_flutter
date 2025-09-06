import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import Stripe from 'https://esm.sh/stripe@14.21.0'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.7'

const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY')!)
const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Get the authorization header
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'Missing authorization header' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Parse request body
    const { setup_intent_id, nickname } = await req.json()
    
    if (!setup_intent_id) {
      return new Response(
        JSON.stringify({ error: 'Missing setup_intent_id' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Create Supabase client with user's JWT
    const supabase = createClient(supabaseUrl, supabaseServiceKey, {
      global: {
        headers: { Authorization: authHeader },
      },
    })

    // Get the authenticated user
    const { data: { user }, error: userError } = await supabase.auth.getUser()
    if (userError || !user) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Retrieve the SetupIntent from Stripe
    const setupIntent = await stripe.setupIntents.retrieve(setup_intent_id)
    
    if (setupIntent.status !== 'succeeded') {
      return new Response(
        JSON.stringify({ error: 'SetupIntent not succeeded' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    if (!setupIntent.payment_method) {
      return new Response(
        JSON.stringify({ error: 'No payment method attached to SetupIntent' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Verify the SetupIntent belongs to the user
    if (setupIntent.metadata?.user_id !== user.id) {
      return new Response(
        JSON.stringify({ error: 'SetupIntent does not belong to user' }),
        { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Retrieve the payment method details
    const paymentMethod = await stripe.paymentMethods.retrieve(setupIntent.payment_method as string)

    // Check if payment method already exists in database
    const { data: existingMethod } = await supabase
      .from('payment_methods')
      .select('id')
      .eq('user_id', user.id)
      .eq('stripe_payment_method_id', paymentMethod.id)
      .single()

    if (existingMethod) {
      return new Response(
        JSON.stringify({ 
          success: true,
          message: 'Payment method already saved',
          payment_method_id: existingMethod.id
        }),
        { 
          status: 200, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Check if this should be the default payment method
    const { data: existingMethods } = await supabase
      .from('payment_methods')
      .select('id')
      .eq('user_id', user.id)
      .limit(1)

    const isDefault = !existingMethods || existingMethods.length === 0

    // Save payment method to database
    const { data: savedMethod, error: saveError } = await supabase
      .from('payment_methods')
      .insert({
        user_id: user.id,
        stripe_payment_method_id: paymentMethod.id,
        type: 'card',
        last4: paymentMethod.card?.last4 || '',
        brand: paymentMethod.card?.brand || 'unknown',
        exp_month: paymentMethod.card?.exp_month || 0,
        exp_year: paymentMethod.card?.exp_year || 0,
        holder_name: paymentMethod.billing_details?.name || null,
        is_default: isDefault,
        nickname: nickname || null,
        stripe_fingerprint: paymentMethod.card?.fingerprint || null,
        metadata: {
          funding: paymentMethod.card?.funding,
          country: paymentMethod.card?.country,
          wallet: paymentMethod.card?.wallet,
          setup_intent_id: setup_intent_id,
        },
      })
      .select()
      .single()

    if (saveError) {
      console.error('Error saving payment method:', saveError)
      
      // Try to detach the payment method from Stripe to maintain consistency
      try {
        await stripe.paymentMethods.detach(paymentMethod.id)
      } catch (detachError) {
        console.error('Failed to detach payment method after save failure:', detachError)
      }
      
      return new Response(
        JSON.stringify({ error: 'Failed to save payment method' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // If this is the default payment method, update the Stripe customer
    if (isDefault && setupIntent.customer) {
      try {
        await stripe.customers.update(setupIntent.customer as string, {
          invoice_settings: {
            default_payment_method: paymentMethod.id,
          },
        })
      } catch (updateError) {
        console.error('Error updating default payment method in Stripe:', updateError)
        // Non-critical error, continue
      }
    }

    return new Response(
      JSON.stringify({ 
        success: true,
        message: 'Payment method saved successfully',
        payment_method: savedMethod
      }),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  } catch (error) {
    console.error('Error saving payment method:', error)
    return new Response(
      JSON.stringify({ 
        error: error instanceof Error ? error.message : 'Failed to save payment method' 
      }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})