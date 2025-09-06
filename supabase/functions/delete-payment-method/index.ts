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

    // Get the payment method from database to verify ownership
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

    // Check if this is the default payment method
    if (paymentMethod.is_default) {
      // Check if there are other payment methods
      const { data: otherMethods, error: countError } = await supabase
        .from('payment_methods')
        .select('id')
        .eq('user_id', user.id)
        .neq('id', paymentMethod.id)
        .limit(1)

      if (!countError && otherMethods && otherMethods.length > 0) {
        // Set another payment method as default
        await supabase
          .from('payment_methods')
          .update({ is_default: true })
          .eq('id', otherMethods[0].id)
      }
    }

    // Detach payment method from Stripe
    try {
      await stripe.paymentMethods.detach(paymentMethod.stripe_payment_method_id)
      console.log('Payment method detached from Stripe:', paymentMethod.stripe_payment_method_id)
    } catch (stripeError) {
      console.error('Error detaching payment method from Stripe:', stripeError)
      // Continue with database deletion even if Stripe fails
      // The payment method might already be deleted from Stripe
    }

    // Delete from database
    const { error: deleteError } = await supabase
      .from('payment_methods')
      .delete()
      .eq('stripe_payment_method_id', payment_method_id)
      .eq('user_id', user.id)

    if (deleteError) {
      console.error('Error deleting payment method from database:', deleteError)
      return new Response(
        JSON.stringify({ error: 'Failed to delete payment method' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    return new Response(
      JSON.stringify({ 
        success: true,
        message: 'Payment method deleted successfully' 
      }),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  } catch (error) {
    console.error('Error deleting payment method:', error)
    return new Response(
      JSON.stringify({ 
        error: error instanceof Error ? error.message : 'Failed to delete payment method' 
      }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})