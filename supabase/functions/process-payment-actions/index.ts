import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.7'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseKey)

    // Get pending payment actions from database function
    const { data: pendingActions, error: fetchError } = await supabase
      .rpc('process_pending_payment_actions')

    if (fetchError) {
      console.error('Error fetching pending actions:', fetchError)
      return new Response(
        JSON.stringify({ error: 'Failed to fetch pending payment actions' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const results = {
      processed: 0,
      authorized: 0,
      captured: 0,
      refunded: 0,
      errors: [],
    }

    // Process each pending action
    for (const action of pendingActions || []) {
      try {
        switch (action.action) {
          case 'authorize':
            // Call authorize-booking-payment function
            const authResponse = await fetch(
              `${supabaseUrl}/functions/v1/authorize-booking-payment`,
              {
                method: 'POST',
                headers: {
                  'Authorization': `Bearer ${supabaseKey}`,
                  'Content-Type': 'application/json',
                },
                body: JSON.stringify({ booking_id: action.booking_id }),
              }
            )
            
            if (authResponse.ok) {
              results.authorized++
              
              // Update log status
              await supabase
                .from('booking_payment_logs')
                .update({ status: 'completed' })
                .eq('booking_id', action.booking_id)
                .eq('action', 'payment_authorization_requested')
                .eq('status', 'pending')
            } else {
              const error = await authResponse.json()
              results.errors.push({
                booking_id: action.booking_id,
                action: 'authorize',
                error: error.error || 'Authorization failed',
              })
            }
            break

          case 'capture':
            // Call capture-payment function
            const captureResponse = await fetch(
              `${supabaseUrl}/functions/v1/capture-payment`,
              {
                method: 'POST',
                headers: {
                  'Authorization': `Bearer ${supabaseKey}`,
                  'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                  booking_id: action.booking_id,
                  actual_amount: action.total_amount + (action.tip_amount || 0),
                }),
              }
            )
            
            if (captureResponse.ok) {
              results.captured++
              
              // Update log status
              await supabase
                .from('booking_payment_logs')
                .update({ status: 'completed' })
                .eq('booking_id', action.booking_id)
                .eq('action', 'payment_capture_requested')
                .eq('status', 'pending')
            } else {
              const error = await captureResponse.json()
              results.errors.push({
                booking_id: action.booking_id,
                action: 'capture',
                error: error.error || 'Capture failed',
              })
            }
            break

          case 'refund':
            // Call refund-payment function
            const refundResponse = await fetch(
              `${supabaseUrl}/functions/v1/refund-payment`,
              {
                method: 'POST',
                headers: {
                  'Authorization': `Bearer ${supabaseKey}`,
                  'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                  booking_id: action.booking_id,
                  amount: action.amount,
                  reason: 'requested_by_customer',
                  description: action.reason || action.cancellation_reason,
                }),
              }
            )
            
            if (refundResponse.ok) {
              results.refunded++
              
              // Update log status
              await supabase
                .from('booking_payment_logs')
                .update({ status: 'completed' })
                .eq('booking_id', action.booking_id)
                .eq('action', 'refund_evaluation')
                .eq('status', 'pending')
            } else {
              const error = await refundResponse.json()
              results.errors.push({
                booking_id: action.booking_id,
                action: 'refund',
                error: error.error || 'Refund failed',
              })
            }
            break
        }
        
        results.processed++
      } catch (error) {
        console.error(`Error processing action for booking ${action.booking_id}:`, error)
        results.errors.push({
          booking_id: action.booking_id,
          action: action.action,
          error: error.message,
        })
      }
    }

    // Process auto-capture for completed bookings older than 24 hours
    const { data: bookingsToAutoCapture, error: autoCaptureError } = await supabase
      .from('bookings')
      .select('id, total_amount, tip_amount')
      .eq('status', 'completed')
      .eq('payment_status', 'authorized')
      .lt('payment_captured_at', new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString())
      .limit(10)

    if (!autoCaptureError && bookingsToAutoCapture) {
      for (const booking of bookingsToAutoCapture) {
        try {
          const captureResponse = await fetch(
            `${supabaseUrl}/functions/v1/capture-payment`,
            {
              method: 'POST',
              headers: {
                'Authorization': `Bearer ${supabaseKey}`,
                'Content-Type': 'application/json',
              },
              body: JSON.stringify({
                booking_id: booking.id,
                actual_amount: booking.total_amount + (booking.tip_amount || 0),
              }),
            }
          )
          
          if (captureResponse.ok) {
            results.captured++
            
            // Log auto-capture
            await supabase
              .from('booking_payment_logs')
              .insert({
                booking_id: booking.id,
                action: 'auto_capture_completed',
                status: 'completed',
                amount: booking.total_amount + (booking.tip_amount || 0),
                metadata: { trigger: '24_hour_auto_capture' },
              })
          }
        } catch (error) {
          console.error(`Error auto-capturing payment for booking ${booking.id}:`, error)
          results.errors.push({
            booking_id: booking.id,
            action: 'auto_capture',
            error: error.message,
          })
        }
      }
    }

    return new Response(
      JSON.stringify({
        success: true,
        results,
        timestamp: new Date().toISOString(),
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Error processing payment actions:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})