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

    // Get user's Stripe customer ID
    const { data: profile, error: profileError } = await supabase
      .from('profiles')
      .select('stripe_customer_id')
      .eq('id', user.id)
      .single()

    if (profileError) {
      console.error('Error fetching profile:', profileError)
      return new Response(
        JSON.stringify({ error: 'Failed to fetch user profile' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    if (!profile?.stripe_customer_id) {
      // No customer ID, return empty list
      return new Response(
        JSON.stringify({ payment_methods: [] }),
        { 
          status: 200, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Get payment methods from Stripe
    const paymentMethods = await stripe.paymentMethods.list({
      customer: profile.stripe_customer_id,
      type: 'card',
    })

    // Get saved payment methods from database
    const { data: savedMethods, error: savedMethodsError } = await supabase
      .from('payment_methods')
      .select('*')
      .eq('user_id', user.id)
      .order('is_default', { ascending: false })
      .order('created_at', { ascending: false })

    if (savedMethodsError) {
      console.error('Error fetching saved payment methods:', savedMethodsError)
    }

    // Sync Stripe payment methods with database
    const syncedMethods = []
    
    for (const method of paymentMethods.data) {
      // Check if method exists in database
      const existingMethod = savedMethods?.find(
        (m) => m.stripe_payment_method_id === method.id
      )

      if (!existingMethod) {
        // Save new payment method to database
        const { data: newMethod, error: insertError } = await supabase
          .from('payment_methods')
          .insert({
            user_id: user.id,
            stripe_payment_method_id: method.id,
            type: 'card',
            last4: method.card?.last4 || '',
            brand: method.card?.brand || 'unknown',
            exp_month: method.card?.exp_month || 0,
            exp_year: method.card?.exp_year || 0,
            holder_name: method.billing_details?.name || null,
            is_default: false,
            stripe_fingerprint: method.card?.fingerprint || null,
            metadata: {
              funding: method.card?.funding,
              country: method.card?.country,
              wallet: method.card?.wallet,
            },
          })
          .select()
          .single()

        if (!insertError && newMethod) {
          syncedMethods.push(newMethod)
        } else {
          console.error('Error inserting payment method:', insertError)
          // Still include Stripe data even if DB insert fails
          syncedMethods.push({
            id: method.id,
            user_id: user.id,
            stripe_payment_method_id: method.id,
            type: 'card',
            last4: method.card?.last4 || '',
            brand: method.card?.brand || 'unknown',
            exp_month: method.card?.exp_month || 0,
            exp_year: method.card?.exp_year || 0,
            holder_name: method.billing_details?.name || null,
            is_default: false,
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString(),
            nickname: null,
            metadata: {
              funding: method.card?.funding,
              country: method.card?.country,
              wallet: method.card?.wallet,
            },
          })
        }
      } else {
        // Update existing method with latest Stripe data
        const { data: updatedMethod, error: updateError } = await supabase
          .from('payment_methods')
          .update({
            last4: method.card?.last4 || existingMethod.last4,
            brand: method.card?.brand || existingMethod.brand,
            exp_month: method.card?.exp_month || existingMethod.exp_month,
            exp_year: method.card?.exp_year || existingMethod.exp_year,
            holder_name: method.billing_details?.name || existingMethod.holder_name,
            metadata: {
              ...existingMethod.metadata,
              funding: method.card?.funding,
              country: method.card?.country,
              wallet: method.card?.wallet,
            },
          })
          .eq('id', existingMethod.id)
          .select()
          .single()

        if (!updateError && updatedMethod) {
          syncedMethods.push(updatedMethod)
        } else {
          syncedMethods.push(existingMethod)
        }
      }
    }

    // Remove payment methods from database that no longer exist in Stripe
    const stripeMethodIds = paymentMethods.data.map(m => m.id)
    const methodsToDelete = savedMethods?.filter(
      m => !stripeMethodIds.includes(m.stripe_payment_method_id)
    ) || []

    for (const methodToDelete of methodsToDelete) {
      await supabase
        .from('payment_methods')
        .delete()
        .eq('id', methodToDelete.id)
    }

    // Sort methods: default first, then by creation date
    syncedMethods.sort((a, b) => {
      if (a.is_default && !b.is_default) return -1
      if (!a.is_default && b.is_default) return 1
      return new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
    })

    return new Response(
      JSON.stringify({ payment_methods: syncedMethods }),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  } catch (error) {
    console.error('Error listing payment methods:', error)
    return new Response(
      JSON.stringify({ 
        error: error instanceof Error ? error.message : 'Failed to list payment methods' 
      }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})