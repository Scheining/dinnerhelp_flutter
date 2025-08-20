import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const ONESIGNAL_APP_ID = Deno.env.get('ONESIGNAL_APP_ID')!
const ONESIGNAL_REST_API_KEY = Deno.env.get('ONESIGNAL_REST_API_KEY')!
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface NotificationPayload {
  type: 'booking_confirmed' | 'reminder_24h' | 'rating_request' | 'new_message'
  bookingId?: string
  userId?: string
  chefId?: string
  messageId?: string
}

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { type, bookingId, userId, chefId, messageId } = await req.json() as NotificationPayload
    
    // Initialize Supabase client
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

    let notificationSent = false

    switch (type) {
      case 'booking_confirmed':
        notificationSent = await handleBookingConfirmed(supabase, bookingId!)
        break
      
      case 'reminder_24h':
        notificationSent = await handle24HourReminder(supabase, bookingId!)
        break
      
      case 'rating_request':
        notificationSent = await handleRatingRequest(supabase, bookingId!)
        break
      
      case 'new_message':
        notificationSent = await handleNewMessage(supabase, messageId!, userId!)
        break
      
      default:
        throw new Error(`Unknown notification type: ${type}`)
    }

    return new Response(
      JSON.stringify({ success: notificationSent }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200 
      },
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400
      },
    )
  }
})

async function handleBookingConfirmed(supabase: any, bookingId: string) {
  // Get booking details
  const { data: booking, error } = await supabase
    .from('bookings')
    .select(`
      *,
      user:profiles!bookings_user_id_fkey(
        id,
        first_name,
        last_name,
        email
      ),
      chef:chefs!bookings_chef_id_fkey(
        id,
        profiles!inner(
          first_name,
          last_name
        )
      )
    `)
    .eq('id', bookingId)
    .single()

  if (error || !booking) {
    console.error('Error fetching booking:', error)
    return false
  }

  const chefName = `${booking.chef.profiles.first_name} ${booking.chef.profiles.last_name}`
  const bookingDate = new Date(booking.date).toLocaleDateString('da-DK')
  const bookingTime = booking.start_time

  // Send notification to user
  const notificationPayload = {
    app_id: ONESIGNAL_APP_ID,
    include_external_user_ids: [booking.user_id],
    headings: {
      en: '🎉 Booking Confirmed!',
      da: '🎉 Booking Bekræftet!'
    },
    contents: {
      en: `${chefName} has confirmed your booking for ${bookingDate} at ${bookingTime}`,
      da: `${chefName} har bekræftet din booking for ${bookingDate} kl. ${bookingTime}`
    },
    data: {
      type: 'booking_confirmed',
      booking_id: bookingId,
      screen: 'booking_details'
    }
  }

  // Also schedule 24-hour reminder
  const bookingDateTime = new Date(`${booking.date}T${booking.start_time}`)
  const reminderTime = new Date(bookingDateTime.getTime() - 24 * 60 * 60 * 1000)
  
  if (reminderTime > new Date()) {
    await schedule24HourReminder(booking, chefName, reminderTime)
  }

  return await sendOneSignalNotification(notificationPayload)
}

async function handle24HourReminder(supabase: any, bookingId: string) {
  const { data: booking, error } = await supabase
    .from('bookings')
    .select(`
      *,
      chef:chefs!bookings_chef_id_fkey(
        profiles!inner(
          first_name,
          last_name
        )
      )
    `)
    .eq('id', bookingId)
    .eq('status', 'confirmed')
    .single()

  if (error || !booking) {
    return false
  }

  const chefName = `${booking.chef.profiles.first_name} ${booking.chef.profiles.last_name}`
  const bookingTime = booking.start_time

  const notificationPayload = {
    app_id: ONESIGNAL_APP_ID,
    include_external_user_ids: [booking.user_id],
    headings: {
      en: '⏰ Reminder: Booking Tomorrow',
      da: '⏰ Påmindelse: Booking i morgen'
    },
    contents: {
      en: `Your booking with ${chefName} is tomorrow at ${bookingTime}`,
      da: `Din booking med ${chefName} er i morgen kl. ${bookingTime}`
    },
    data: {
      type: 'booking_reminder',
      booking_id: bookingId,
      screen: 'booking_details'
    }
  }

  return await sendOneSignalNotification(notificationPayload)
}

async function handleRatingRequest(supabase: any, bookingId: string) {
  const { data: booking, error } = await supabase
    .from('bookings')
    .select(`
      *,
      chef:chefs!bookings_chef_id_fkey(
        profiles!inner(
          first_name,
          last_name
        )
      )
    `)
    .eq('id', bookingId)
    .eq('status', 'completed')
    .single()

  if (error || !booking) {
    return false
  }

  const chefName = `${booking.chef.profiles.first_name} ${booking.chef.profiles.last_name}`

  const notificationPayload = {
    app_id: ONESIGNAL_APP_ID,
    include_external_user_ids: [booking.user_id],
    headings: {
      en: '⭐ How was your experience?',
      da: '⭐ Hvordan var din oplevelse?'
    },
    contents: {
      en: `Please rate your experience with ${chefName}`,
      da: `Bedøm din oplevelse med ${chefName} og hjælp andre brugere`
    },
    data: {
      type: 'rating_request',
      booking_id: bookingId,
      screen: 'rate_booking'
    },
    buttons: [
      { id: 'rate_now', text: 'Rate Now' },
      { id: 'later', text: 'Later' }
    ]
  }

  return await sendOneSignalNotification(notificationPayload)
}

async function handleNewMessage(supabase: any, messageId: string, recipientId: string) {
  const { data: message, error } = await supabase
    .from('chat_messages')
    .select(`
      *,
      sender:profiles!chat_messages_sender_id_fkey(
        first_name,
        last_name,
        avatar_url
      )
    `)
    .eq('id', messageId)
    .single()

  if (error || !message) {
    return false
  }

  const senderName = `${message.sender.first_name} ${message.sender.last_name}`
  const messagePreview = message.message.length > 100 
    ? message.message.substring(0, 100) + '...' 
    : message.message

  const notificationPayload = {
    app_id: ONESIGNAL_APP_ID,
    include_external_user_ids: [recipientId],
    headings: {
      en: `💬 New message from ${senderName}`,
      da: `💬 Ny besked fra ${senderName}`
    },
    contents: {
      en: messagePreview,
      da: messagePreview
    },
    data: {
      type: 'new_message',
      message_id: messageId,
      booking_id: message.booking_id,
      screen: 'messages'
    },
    ios_attachments: message.sender.avatar_url ? { id1: message.sender.avatar_url } : undefined,
    big_picture: message.sender.avatar_url || undefined
  }

  return await sendOneSignalNotification(notificationPayload)
}

async function schedule24HourReminder(booking: any, chefName: string, sendTime: Date) {
  const notificationPayload = {
    app_id: ONESIGNAL_APP_ID,
    include_external_user_ids: [booking.user_id],
    headings: {
      en: '⏰ Reminder: Booking Tomorrow',
      da: '⏰ Påmindelse: Booking i morgen'
    },
    contents: {
      en: `Your booking with ${chefName} is tomorrow at ${booking.start_time}`,
      da: `Din booking med ${chefName} er i morgen kl. ${booking.start_time}`
    },
    data: {
      type: 'booking_reminder',
      booking_id: booking.id,
      screen: 'booking_details'
    },
    send_after: sendTime.toISOString()
  }

  return await sendOneSignalNotification(notificationPayload)
}

async function sendOneSignalNotification(payload: any) {
  try {
    const response = await fetch('https://onesignal.com/api/v1/notifications', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${ONESIGNAL_REST_API_KEY}`
      },
      body: JSON.stringify(payload)
    })

    const result = await response.json()
    
    if (response.ok) {
      console.log('Notification sent successfully:', result)
      return true
    } else {
      console.error('Failed to send notification:', result)
      return false
    }
  } catch (error) {
    console.error('Error sending notification:', error)
    return false
  }
}