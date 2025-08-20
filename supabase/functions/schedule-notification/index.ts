import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.7'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface ScheduleRequest {
  booking_id: string
  notification_type: 'booking_confirmation' | 'booking_reminder_24h' | 'booking_reminder_1h' | 'booking_completion' | 'booking_modified' | 'booking_cancelled'
  recipient_type: 'user' | 'chef' | 'both'
  schedule_at?: string
  custom_data?: Record<string, any>
}

interface BookingData {
  id: string
  user_id: string
  chef_id: string
  date: string
  start_time: string
  end_time: string
  number_of_guests: number
  address: string
  total_amount?: number
  notes?: string
  profiles?: {
    first_name: string
    last_name: string
    email: string
  }
  chefs?: {
    profiles?: {
      first_name: string
      last_name: string
      email: string
    }
  }
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const requestData: ScheduleRequest = await req.json()
    
    if (!requestData.booking_id || !requestData.notification_type || !requestData.recipient_type) {
      throw new Error('booking_id, notification_type, and recipient_type are required')
    }

    // Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseKey)

    // Get booking details with user and chef information
    const { data: booking, error: bookingError } = await supabase
      .from('bookings')
      .select(`
        *,
        profiles!user_id (
          first_name,
          last_name,
          email
        ),
        chefs (
          profiles (
            first_name,
            last_name,
            email
          )
        )
      `)
      .eq('id', requestData.booking_id)
      .single()

    if (bookingError || !booking) {
      throw new Error(`Booking not found: ${bookingError?.message || 'Unknown error'}`)
    }

    const bookingData = booking as BookingData
    
    // Calculate schedule times based on notification type
    const bookingDateTime = new Date(`${bookingData.date}T${bookingData.start_time}`)
    let scheduledAt: Date | null = null

    switch (requestData.notification_type) {
      case 'booking_confirmation':
        // Send immediately
        scheduledAt = null
        break
      
      case 'booking_reminder_24h':
        scheduledAt = new Date(bookingDateTime.getTime() - 24 * 60 * 60 * 1000)
        break
      
      case 'booking_reminder_1h':
        scheduledAt = new Date(bookingDateTime.getTime() - 60 * 60 * 1000)
        break
      
      case 'booking_completion':
        // Schedule 2 hours after booking end time (assuming 3-hour duration if not specified)
        const endTime = bookingData.end_time || 
                       new Date(bookingDateTime.getTime() + 3 * 60 * 60 * 1000).toTimeString().slice(0, 5)
        const endDateTime = new Date(`${bookingData.date}T${endTime}`)
        scheduledAt = new Date(endDateTime.getTime() + 2 * 60 * 60 * 1000)
        break
      
      case 'booking_modified':
      case 'booking_cancelled':
        // Send immediately
        scheduledAt = null
        break
      
      default:
        throw new Error(`Unknown notification type: ${requestData.notification_type}`)
    }

    // Only schedule if time is in the future
    if (scheduledAt && scheduledAt <= new Date()) {
      scheduledAt = null // Send immediately if scheduled time has passed
    }

    // Prepare notification data
    const notificationData = {
      booking_id: requestData.booking_id,
      user_name: `${bookingData.profiles?.first_name || ''} ${bookingData.profiles?.last_name || ''}`.trim(),
      user_email: bookingData.profiles?.email,
      chef_name: `${bookingData.chefs?.profiles?.first_name || ''} ${bookingData.chefs?.profiles?.last_name || ''}`.trim(),
      chef_email: bookingData.chefs?.profiles?.email,
      booking_date: formatDate(bookingDateTime, 'da'),
      booking_date_en: formatDate(bookingDateTime, 'en'),
      booking_time: bookingData.start_time,
      booking_datetime: bookingDateTime.toISOString(),
      guest_count: bookingData.number_of_guests.toString(),
      address: bookingData.address,
      total_amount: bookingData.total_amount?.toString(),
      notes: bookingData.notes,
      ...requestData.custom_data,
    }

    const createdNotifications: any[] = []

    // Create notifications based on recipient type
    const recipientTypes = requestData.recipient_type === 'both' 
      ? ['user', 'chef'] 
      : [requestData.recipient_type]

    for (const recipientType of recipientTypes) {
      const isUser = recipientType === 'user'
      const userId = isUser ? bookingData.user_id : bookingData.chef_id
      const templateSuffix = isUser ? 'user' : 'chef'
      
      // Get user preferences to determine which channels to use
      const { data: preferences } = await supabase
        .from('notification_preferences')
        .select('*')
        .eq('user_id', userId)
        .single()

      const userPrefs = preferences || {
        email_enabled: true,
        push_enabled: true,
        language_preference: 'da',
      }

      // Create email notification
      if (userPrefs.email_enabled && getNotificationSetting(userPrefs, requestData.notification_type)) {
        const emailNotification = {
          user_id: userId,
          booking_id: requestData.booking_id,
          chef_id: isUser ? bookingData.chef_id : null,
          type: requestData.notification_type,
          channel: 'email',
          title: getNotificationTitle(requestData.notification_type, userPrefs.language_preference, isUser),
          content: getNotificationContent(requestData.notification_type, userPrefs.language_preference, isUser, notificationData),
          data: notificationData,
          template_id: `${requestData.notification_type}_${templateSuffix}`,
          scheduled_at: scheduledAt?.toISOString(),
        }

        const { data: emailNotif, error: emailError } = await supabase
          .from('notifications')
          .insert(emailNotification)
          .select()
          .single()

        if (emailError) {
          console.error('Failed to create email notification:', emailError)
        } else {
          createdNotifications.push(emailNotif)

          // Add to queue if scheduled
          if (scheduledAt) {
            await supabase
              .from('notification_queue')
              .insert({
                notification_id: emailNotif.id,
                scheduled_for: scheduledAt.toISOString(),
              })
          }
        }
      }

      // Create push notification
      if (userPrefs.push_enabled && getNotificationSetting(userPrefs, requestData.notification_type)) {
        const pushNotification = {
          user_id: userId,
          booking_id: requestData.booking_id,
          chef_id: isUser ? bookingData.chef_id : null,
          type: requestData.notification_type,
          channel: 'push',
          title: getPushTitle(requestData.notification_type, userPrefs.language_preference, isUser),
          content: getPushContent(requestData.notification_type, userPrefs.language_preference, isUser, notificationData),
          data: notificationData,
          scheduled_at: scheduledAt?.toISOString(),
        }

        const { data: pushNotif, error: pushError } = await supabase
          .from('notifications')
          .insert(pushNotification)
          .select()
          .single()

        if (pushError) {
          console.error('Failed to create push notification:', pushError)
        } else {
          createdNotifications.push(pushNotif)

          // Add to queue if scheduled
          if (scheduledAt) {
            await supabase
              .from('notification_queue')
              .insert({
                notification_id: pushNotif.id,
                scheduled_for: scheduledAt.toISOString(),
              })
          }
        }
      }
    }

    // If no scheduled time, process notifications immediately
    if (!scheduledAt && createdNotifications.length > 0) {
      // Trigger immediate processing
      for (const notification of createdNotifications) {
        try {
          if (notification.channel === 'email') {
            await supabase.functions.invoke('send-email-notification', {
              body: {
                notification_id: notification.id,
              },
            })
          } else if (notification.channel === 'push') {
            await supabase.functions.invoke('send-push-notification', {
              body: {
                notification_id: notification.id,
              },
            })
          }
        } catch (error) {
          console.error(`Failed to send immediate notification ${notification.id}:`, error)
        }
      }
    }

    return new Response(
      JSON.stringify({
        success: true,
        notifications_created: createdNotifications.length,
        scheduled_at: scheduledAt?.toISOString(),
        notification_ids: createdNotifications.map(n => n.id),
      }),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Error scheduling notification:', error)

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

// Helper functions

function formatDate(date: Date, language: string): string {
  if (language === 'da') {
    const months = [
      'januar', 'februar', 'marts', 'april', 'maj', 'juni',
      'juli', 'august', 'september', 'oktober', 'november', 'december'
    ]
    return `${date.getDate()}. ${months[date.getMonth()]} ${date.getFullYear()}`
  } else {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ]
    return `${months[date.getMonth()]} ${date.getDate()}, ${date.getFullYear()}`
  }
}

function getNotificationSetting(preferences: any, notificationType: string): boolean {
  switch (notificationType) {
    case 'booking_confirmation':
      return preferences.booking_confirmations ?? true
    case 'booking_reminder_24h':
    case 'booking_reminder_1h':
      return preferences.booking_reminders ?? true
    case 'booking_completion':
    case 'booking_modified':
    case 'booking_cancelled':
      return preferences.booking_updates ?? true
    default:
      return true
  }
}

function getNotificationTitle(type: string, language: string, isUser: boolean): string {
  const titles = {
    da: {
      booking_confirmation: isUser ? 'Din booking er bekræftet! 🎉' : 'Ny booking bekræftet! 👨‍🍳',
      booking_reminder_24h: 'Påmindelse: Din madoplevelse i morgen! 🍽️',
      booking_reminder_1h: 'Din kok ankommer snart! ⏰',
      booking_completion: 'Hvordan var din madoplevelse? ⭐',
      booking_modified: 'Din booking er blevet opdateret',
      booking_cancelled: 'Din booking er blevet aflyst',
    },
    en: {
      booking_confirmation: isUser ? 'Your booking is confirmed! 🎉' : 'New booking confirmed! 👨‍🍳',
      booking_reminder_24h: 'Reminder: Your dining experience tomorrow! 🍽️',
      booking_reminder_1h: 'Your chef is arriving soon! ⏰',
      booking_completion: 'How was your dining experience? ⭐',
      booking_modified: 'Your booking has been updated',
      booking_cancelled: 'Your booking has been cancelled',
    },
  }

  return titles[language as keyof typeof titles]?.[type as keyof typeof titles.da] || titles.en[type as keyof typeof titles.en]
}

function getNotificationContent(type: string, language: string, isUser: boolean, data: any): string {
  // This would return the full content for email notifications
  // For brevity, returning a simple version here
  const name = isUser ? data.chef_name : data.user_name
  
  if (language === 'da') {
    switch (type) {
      case 'booking_confirmation':
        return isUser 
          ? `Din booking med ${name} er bekræftet for ${data.booking_date} kl. ${data.booking_time}.`
          : `Du har fået en ny booking fra ${name} for ${data.booking_date} kl. ${data.booking_time}.`
      case 'booking_reminder_24h':
        return `Påmindelse: Din madoplevelse med ${name} er i morgen kl. ${data.booking_time}.`
      case 'booking_reminder_1h':
        return `Din madoplevelse med ${name} starter om 1 time.`
      default:
        return `Opdatering vedrørende din booking med ${name}.`
    }
  } else {
    switch (type) {
      case 'booking_confirmation':
        return isUser
          ? `Your booking with ${name} is confirmed for ${data.booking_date_en} at ${data.booking_time}.`
          : `You have received a new booking from ${name} for ${data.booking_date_en} at ${data.booking_time}.`
      case 'booking_reminder_24h':
        return `Reminder: Your dining experience with ${name} is tomorrow at ${data.booking_time}.`
      case 'booking_reminder_1h':
        return `Your dining experience with ${name} starts in 1 hour.`
      default:
        return `Update regarding your booking with ${name}.`
    }
  }
}

function getPushTitle(type: string, language: string, isUser: boolean): string {
  // Shorter titles for push notifications
  const titles = {
    da: {
      booking_confirmation: isUser ? 'Booking bekræftet!' : 'Ny booking!',
      booking_reminder_24h: 'Madoplevelse i morgen',
      booking_reminder_1h: 'Kok ankommer snart',
      booking_completion: 'Bedøm din oplevelse',
      booking_modified: 'Booking opdateret',
      booking_cancelled: 'Booking aflyst',
    },
    en: {
      booking_confirmation: isUser ? 'Booking confirmed!' : 'New booking!',
      booking_reminder_24h: 'Dining experience tomorrow',
      booking_reminder_1h: 'Chef arriving soon',
      booking_completion: 'Rate your experience',
      booking_modified: 'Booking updated',
      booking_cancelled: 'Booking cancelled',
    },
  }

  return titles[language as keyof typeof titles]?.[type as keyof typeof titles.da] || titles.en[type as keyof typeof titles.en]
}

function getPushContent(type: string, language: string, isUser: boolean, data: any): string {
  // Short content for push notifications
  const name = isUser ? data.chef_name : data.user_name
  
  if (language === 'da') {
    switch (type) {
      case 'booking_confirmation':
        return isUser ? `Med ${name} på ${data.booking_date}` : `Fra ${name} på ${data.booking_date}`
      case 'booking_reminder_24h':
        return `Med ${name} kl. ${data.booking_time}`
      case 'booking_reminder_1h':
        return `${name} ankommer snart`
      default:
        return `Vedrørende booking med ${name}`
    }
  } else {
    switch (type) {
      case 'booking_confirmation':
        return isUser ? `With ${name} on ${data.booking_date_en}` : `From ${name} on ${data.booking_date_en}`
      case 'booking_reminder_24h':
        return `With ${name} at ${data.booking_time}`
      case 'booking_reminder_1h':
        return `${name} arriving soon`
      default:
        return `Regarding booking with ${name}`
    }
  }
}