import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.7'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface QueuedNotification {
  id: string
  notification_id: string
  scheduled_for: string
  is_processed: boolean
  notifications: {
    id: string
    user_id: string
    booking_id?: string
    chef_id?: string
    type: string
    channel: string
    status: string
    title: string
    content: string
    data: Record<string, any>
    template_id?: string
    retry_count: number
    max_retries: number
  }
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

    const now = new Date().toISOString()
    
    // Get queued notifications that are ready to be sent
    const { data: queuedNotifications, error: queueError } = await supabase
      .from('notification_queue')
      .select(`
        *,
        notifications (
          id,
          user_id,
          booking_id,
          chef_id,
          type,
          channel,
          status,
          title,
          content,
          data,
          template_id,
          retry_count,
          max_retries
        )
      `)
      .eq('is_processed', false)
      .lte('scheduled_for', now)
      .limit(50) // Process in batches to avoid timeouts

    if (queueError) {
      throw new Error(`Failed to get queued notifications: ${queueError.message}`)
    }

    if (!queuedNotifications || queuedNotifications.length === 0) {
      return new Response(
        JSON.stringify({
          success: true,
          message: 'No notifications to process',
          processed: 0,
        }),
        { 
          status: 200, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    const processResults = {
      processed: 0,
      succeeded: 0,
      failed: 0,
      errors: [] as string[],
    }

    // Process each queued notification
    for (const queueItem of queuedNotifications as QueuedNotification[]) {
      try {
        const notification = queueItem.notifications
        
        // Skip if notification is not in pending status
        if (notification.status !== 'pending') {
          await markQueueItemProcessed(supabase, queueItem.id)
          processResults.processed++
          continue
        }

        // Check if we've exceeded retry count
        if (notification.retry_count >= notification.max_retries) {
          await supabase
            .from('notifications')
            .update({
              status: 'cancelled',
              failure_reason: 'Maximum retries exceeded',
              updated_at: now,
            })
            .eq('id', notification.id)
            
          await markQueueItemProcessed(supabase, queueItem.id)
          processResults.processed++
          processResults.failed++
          continue
        }

        // Update notification status to processing
        await supabase
          .from('notifications')
          .update({
            status: 'processing',
            updated_at: now,
          })
          .eq('id', notification.id)

        let success = false

        // Process based on channel
        switch (notification.channel) {
          case 'email':
            success = await processEmailNotification(supabase, notification)
            break
            
          case 'push':
            success = await processPushNotification(supabase, notification)
            break
            
          case 'in_app':
            // For in-app notifications, just mark as sent
            success = true
            break
            
          case 'sms':
            // SMS not implemented yet
            success = false
            processResults.errors.push(`SMS not implemented for notification ${notification.id}`)
            break
            
          default:
            success = false
            processResults.errors.push(`Unknown channel ${notification.channel} for notification ${notification.id}`)
        }

        if (success) {
          await supabase
            .from('notifications')
            .update({
              status: 'sent',
              sent_at: now,
              updated_at: now,
            })
            .eq('id', notification.id)
            
          processResults.succeeded++
        } else {
          await supabase
            .from('notifications')
            .update({
              status: 'failed',
              failed_at: now,
              retry_count: notification.retry_count + 1,
              updated_at: now,
            })
            .eq('id', notification.id)
            
          processResults.failed++
        }

        // Mark queue item as processed
        await markQueueItemProcessed(supabase, queueItem.id)
        processResults.processed++

        // Small delay to respect rate limits
        await new Promise(resolve => setTimeout(resolve, 100))

      } catch (error) {
        console.error(`Error processing notification ${queueItem.notification_id}:`, error)
        processResults.errors.push(`Error processing ${queueItem.notification_id}: ${error.message}`)
        
        // Mark queue item as processed even if failed to avoid infinite loops
        await markQueueItemProcessed(supabase, queueItem.id)
        processResults.processed++
        processResults.failed++
      }
    }

    // Also process any failed notifications that are ready for retry
    await processFailedNotifications(supabase, processResults)

    return new Response(
      JSON.stringify({
        success: true,
        processed: processResults.processed,
        succeeded: processResults.succeeded,
        failed: processResults.failed,
        errors: processResults.errors.slice(0, 10), // Limit error messages
      }),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Error processing notification queue:', error)

    return new Response(
      JSON.stringify({ 
        error: error.message || 'Unknown error occurred',
        success: false 
      }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})

async function processEmailNotification(supabase: any, notification: any): Promise<boolean> {
  try {
    const { error } = await supabase.functions.invoke('send-email-notification', {
      body: {
        notification_id: notification.id,
      },
    })
    
    return !error
  } catch (error) {
    console.error('Failed to send email notification:', error)
    return false
  }
}

async function processPushNotification(supabase: any, notification: any): Promise<boolean> {
  try {
    const { error } = await supabase.functions.invoke('send-push-notification', {
      body: {
        notification_id: notification.id,
      },
    })
    
    return !error
  } catch (error) {
    console.error('Failed to send push notification:', error)
    return false
  }
}

async function markQueueItemProcessed(supabase: any, queueItemId: string): Promise<void> {
  await supabase
    .from('notification_queue')
    .update({
      is_processed: true,
      processed_at: new Date().toISOString(),
    })
    .eq('id', queueItemId)
}

async function processFailedNotifications(supabase: any, processResults: any): Promise<void> {
  const now = new Date()
  
  // Get failed notifications that are ready for retry
  const { data: failedNotifications, error } = await supabase
    .from('notifications')
    .select('*')
    .eq('status', 'failed')
    .lt('retry_count', 3) // Only retry if under max retries
    .limit(20) // Process in small batches

  if (error || !failedNotifications) {
    return
  }

  for (const notification of failedNotifications) {
    // Calculate next retry time based on retry count
    const failedAt = new Date(notification.failed_at)
    const retryDelays = [5 * 60 * 1000, 30 * 60 * 1000, 2 * 60 * 60 * 1000] // 5min, 30min, 2h
    const retryDelay = retryDelays[notification.retry_count] || retryDelays[retryDelays.length - 1]
    const nextRetryTime = new Date(failedAt.getTime() + retryDelay)

    // Skip if it's not time for retry yet
    if (nextRetryTime > now) {
      continue
    }

    try {
      // Reset status to pending for retry
      await supabase
        .from('notifications')
        .update({
          status: 'pending',
          updated_at: now.toISOString(),
        })
        .eq('id', notification.id)

      // Add back to queue for immediate processing
      await supabase
        .from('notification_queue')
        .insert({
          notification_id: notification.id,
          scheduled_for: now.toISOString(),
          is_processed: false,
        })

    } catch (retryError) {
      console.error(`Failed to reschedule notification ${notification.id}:`, retryError)
    }
  }
}