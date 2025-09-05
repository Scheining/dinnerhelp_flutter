import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.7'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'content-type, stripe-signature',
}

// This function simply forwards Stripe events to the database
// No JWT required, no signature verification needed here
// The database handles all processing
Deno.serve(async (req: Request) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Get the raw body
    const body = await req.json()
    
    // Initialize Supabase client with anon key (public)
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY')!
    const supabase = createClient(supabaseUrl, supabaseAnonKey)
    
    // Simply insert the webhook event into the database
    // The database trigger will handle all processing
    const { data, error } = await supabase
      .from('stripe_webhook_events')
      .insert({
        event_id: body.id,
        type: body.type,
        data: body,
      })
      .select()
      .single()
    
    if (error) {
      // Check if it's a duplicate (already processed)
      if (error.code === '23505') { // unique_violation
        return new Response(
          JSON.stringify({ received: true, message: 'Event already processed' }),
          { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
      
      console.error('Database error:', error)
      return new Response(
        JSON.stringify({ error: error.message }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }
    
    // Return success to Stripe immediately
    // Processing happens async in the database
    return new Response(
      JSON.stringify({ received: true, event_id: body.id }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
    
  } catch (error) {
    console.error('Webhook error:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})