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
    const { payment_method_id } = await req.json()
    
    if (!payment_method_id) {
      return new Response(
        JSON.stringify({ error: 'Missing payment_method_id' }),
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

    // Verify the payment method belongs to the user
    const { data: paymentMethod, error: fetchError } = await supabase
      .from('payment_methods')
      .select('*')
      .eq('stripe_payment_method_id', payment_method_id)
      .eq('user_id', user.id)
      .single()

    if (fetchError || !paymentMethod) {
      console.error('Payment method not found or not owned by user:', fetchError)
      return new Response(
        JSON.stringify({ error: 'Payment method not found' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Get user's Stripe customer ID
    const { data: profile, error: profileError } = await supabase
      .from('profiles')
      .select('stripe_customer_id')
      .eq('id', user.id)
      .single()

    if (profileError || !profile?.stripe_customer_id) {
      console.error('Error fetching profile or no Stripe customer:', profileError)
      return new Response(
        JSON.stringify({ error: 'Stripe customer not found' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Update Stripe customer's default payment method
    try {
      await stripe.customers.update(profile.stripe_customer_id, {
        invoice_settings: {
          default_payment_method: paymentMethod.stripe_payment_method_id,
        },
      })
      console.log('Updated default payment method in Stripe')
    } catch (stripeError) {
      console.error('Error updating default payment method in Stripe:', stripeError)
      // Continue with database update even if Stripe fails
    }

    // Begin transaction to update default payment method
    // First, unset all other payment methods as default
    const { error: unsetError } = await supabase
      .from('payment_methods')
      .update({ is_default: false })
      .eq('user_id', user.id)
      .neq('id', paymentMethod.id)

    if (unsetError) {
      console.error('Error unsetting default payment methods:', unsetError)
      return new Response(
        JSON.stringify({ error: 'Failed to update default payment method' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Then set the selected payment method as default
    const { data: updatedMethod, error: updateError } = await supabase
      .from('payment_methods')
      .update({ is_default: true })
      .eq('id', paymentMethod.id)
      .eq('user_id', user.id)
      .select()
      .single()

    if (updateError) {
      console.error('Error setting default payment method:', updateError)
      return new Response(
        JSON.stringify({ error: 'Failed to set default payment method' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    return new Response(
      JSON.stringify({ 
        success: true,
        message: 'Default payment method updated successfully',
        payment_method: updatedMethod
      }),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  } catch (error) {
    console.error('Error setting default payment method:', error)
    return new Response(
      JSON.stringify({ 
        error: error instanceof Error ? error.message : 'Failed to set default payment method' 
      }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})