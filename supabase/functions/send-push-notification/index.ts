import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.7'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface PushNotificationRequest {
  notification_id?: string
  user_id?: string
  user_ids?: string[]
  title: string
  content: string
  data?: Record<string, any>
  deep_link?: string
  schedule_at?: string
}

interface OneSignalResponse {
  id: string
  recipients: number
  external_id?: string
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const requestData: PushNotificationRequest = await req.json()
    
    // Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseKey)

    // Get OneSignal configuration
    const oneSignalAppId = Deno.env.get('ONESIGNAL_APP_ID')
    const oneSignalApiKey = Deno.env.get('ONESIGNAL_API_KEY')
    
    if (!oneSignalAppId || !oneSignalApiKey) {
      throw new Error('OneSignal configuration not found')
    }

    // Get notification details if notification_id provided
    let notification = null
    if (requestData.notification_id) {
      const { data, error } = await supabase
        .from('notifications')
        .select('*')
        .eq('id', requestData.notification_id)
        .single()

      if (error) {
        throw new Error(`Failed to get notification: ${error.message}`)
      }

      notification = data
    }

    // Determine target users
    const targetUserIds: string[] = []
    
    if (requestData.user_ids) {
      targetUserIds.push(...requestData.user_ids)
    } else if (requestData.user_id) {
      targetUserIds.push(requestData.user_id)
    } else if (notification?.user_id) {
      targetUserIds.push(notification.user_id)
    }

    if (targetUserIds.length === 0) {
      throw new Error('No target users specified')
    }

    // Check if users have push notifications enabled
    const { data: preferences, error: prefsError } = await supabase
      .from('notification_preferences')
      .select('user_id, push_enabled')
      .in('user_id', targetUserIds)
      .eq('push_enabled', true)

    if (prefsError) {
      console.warn('Failed to check user preferences:', prefsError)
      // Continue anyway - better to send and have user control than not send at all
    }

    const enabledUserIds = preferences?.map(p => p.user_id) || targetUserIds

    if (enabledUserIds.length === 0) {
      console.log('No users have push notifications enabled')
      
      // Update notification status if applicable
      if (requestData.notification_id) {
        await supabase
          .from('notifications')
          .update({
            status: 'cancelled',
            failure_reason: 'Push notifications disabled for all target users',
            updated_at: new Date().toISOString(),
          })
          .eq('id', requestData.notification_id)
      }

      return new Response(
        JSON.stringify({
          success: true,
          message: 'No users have push notifications enabled',
          recipients: 0,
        }),
        { 
          status: 200, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Prepare OneSignal payload
    const oneSignalPayload = {
      app_id: oneSignalAppId,
      headings: {
        en: requestData.title,
        da: requestData.title,
      },
      contents: {
        en: requestData.content,
        da: requestData.content,
      },
      data: {
        ...requestData.data,
        ...(notification?.data || {}),
        notification_id: requestData.notification_id,
      },
      filters: enabledUserIds.map(userId => ({
        field: 'external_user_id',
        relation: '=',
        value: userId,
      })),
      url: requestData.deep_link || buildDeepLink(notification),
      ios_badgeType: 'Increase',
      ios_badgeCount: 1,
      android_accent_color: 'FF2E7D32',
      small_icon: 'ic_stat_dinnerhelp',
      large_icon: 'ic_notification_large',
      ...(requestData.schedule_at && { 
        send_after: requestData.schedule_at 
      }),
    }

    // Send push notification via OneSignal
    const oneSignalResponse = await fetch('https://onesignal.com/api/v1/notifications', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${oneSignalApiKey}`,
      },
      body: JSON.stringify(oneSignalPayload),
    })

    if (!oneSignalResponse.ok) {
      const errorData = await oneSignalResponse.json()
      throw new Error(`OneSignal API error: ${errorData.errors?.[0] || oneSignalResponse.statusText}`)
    }

    const oneSignalResult: OneSignalResponse = await oneSignalResponse.json()

    // Update notification status in database
    if (requestData.notification_id) {
      const { error: updateError } = await supabase
        .from('notifications')
        .update({
          status: 'sent',
          sent_at: new Date().toISOString(),
          external_id: oneSignalResult.id,
          updated_at: new Date().toISOString(),
        })
        .eq('id', requestData.notification_id)

      if (updateError) {
        console.error('Failed to update notification status:', updateError)
        // Don't throw here as notification was sent successfully
      }
    }

    return new Response(
      JSON.stringify({
        success: true,
        notification_id: oneSignalResult.id,
        recipients: oneSignalResult.recipients,
        target_users: enabledUserIds.length,
      }),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Error sending push notification:', error)

    // Update notification status to failed if notification_id provided
    if (req.body) {
      try {
        const body = await req.text()
        const requestData = JSON.parse(body)
        
        if (requestData.notification_id) {
          const supabaseUrl = Deno.env.get('SUPABASE_URL')!
          const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
          const supabase = createClient(supabaseUrl, supabaseKey)

          await supabase
            .from('notifications')
            .update({
              status: 'failed',
              failed_at: new Date().toISOString(),
              failure_reason: error.message,
              updated_at: new Date().toISOString(),
            })
            .eq('id', requestData.notification_id)
        }
      } catch (updateError) {
        console.error('Failed to update notification failure status:', updateError)
      }
    }

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

// Build deep link URL based on notification type and data
function buildDeepLink(notification: any): string | undefined {
  if (!notification) return undefined

  const baseUrl = 'dinnerhelp://'
  
  // Extract booking ID from notification data
  const bookingId = notification.booking_id || notification.data?.booking_id

  switch (notification.type) {
    case 'chef_message':
      return bookingId ? `${baseUrl}chat/${bookingId}` : `${baseUrl}messages`
    
    case 'booking_confirmation':
    case 'booking_reminder_24h':
    case 'booking_reminder_1h':
    case 'booking_completion':
    case 'booking_modified':
    case 'booking_cancelled':
      return bookingId ? `${baseUrl}booking/${bookingId}` : `${baseUrl}bookings`
    
    case 'payment_success':
    case 'payment_failed':
      return bookingId ? `${baseUrl}booking/${bookingId}/payment` : `${baseUrl}bookings`
    
    default:
      return `${baseUrl}home`
  }
}