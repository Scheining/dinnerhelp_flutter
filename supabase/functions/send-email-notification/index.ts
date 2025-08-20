import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.7'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface EmailRequest {
  notification_id: string
  user_email?: string
  template_key?: string
  template_variables?: Record<string, any>
  subject?: string
  html_content?: string
  text_content?: string
  language?: string
}

interface PostmarkResponse {
  To: string
  SubmittedAt: string
  MessageID: string
  ErrorCode: number
  Message: string
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const requestData: EmailRequest = await req.json()
    
    // Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseKey)

    // Get Postmark configuration
    const postmarkToken = Deno.env.get('POSTMARK_SERVER_TOKEN')
    if (!postmarkToken) {
      throw new Error('Postmark server token not configured')
    }

    const fromEmail = Deno.env.get('FROM_EMAIL') || 'noreply@dinnerhelp.dk'
    const fromName = Deno.env.get('FROM_NAME') || 'DinnerHelp'

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

    // Determine recipient email
    const recipientEmail = requestData.user_email || 
                          notification?.data?.user_email ||
                          notification?.data?.recipient_email

    if (!recipientEmail) {
      throw new Error('Recipient email not specified')
    }

    // Prepare email content
    let subject = requestData.subject
    let htmlContent = requestData.html_content
    let textContent = requestData.text_content
    const language = requestData.language || notification?.data?.language || 'da'

    // If template is specified, render it
    if (requestData.template_key) {
      const { data: template, error: templateError } = await supabase
        .from('email_templates')
        .select('*')
        .eq('template_key', requestData.template_key)
        .eq('is_active', true)
        .single()

      if (templateError) {
        throw new Error(`Failed to get email template: ${templateError.message}`)
      }

      // Use template content based on language
      subject = language === 'da' ? template.subject_da : template.subject_en
      htmlContent = language === 'da' ? template.html_content_da : template.html_content_en
      textContent = language === 'da' ? template.text_content_da : template.text_content_en

      // Render template variables
      const variables = {
        ...notification?.data,
        ...requestData.template_variables
      }

      if (variables) {
        subject = renderTemplate(subject, variables)
        htmlContent = renderTemplate(htmlContent, variables)
        if (textContent) {
          textContent = renderTemplate(textContent, variables)
        }
      }
    }

    if (!subject || !htmlContent) {
      throw new Error('Email subject and content must be provided')
    }

    // Send email via Postmark
    const postmarkResponse = await fetch('https://api.postmarkapp.com/email', {
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-Postmark-Server-Token': postmarkToken,
      },
      body: JSON.stringify({
        From: `${fromName} <${fromEmail}>`,
        To: recipientEmail,
        Subject: subject,
        HtmlBody: htmlContent,
        ...(textContent && { TextBody: textContent }),
        MessageStream: 'outbound',
        Metadata: {
          notification_id: requestData.notification_id,
          template_key: requestData.template_key,
          language: language,
        },
      }),
    })

    if (!postmarkResponse.ok) {
      const errorData = await postmarkResponse.json()
      throw new Error(`Postmark API error: ${errorData.Message || postmarkResponse.statusText}`)
    }

    const postmarkResult: PostmarkResponse = await postmarkResponse.json()

    // Update notification status in database
    if (requestData.notification_id) {
      const { error: updateError } = await supabase
        .from('notifications')
        .update({
          status: 'sent',
          sent_at: new Date().toISOString(),
          external_id: postmarkResult.MessageID,
          updated_at: new Date().toISOString(),
        })
        .eq('id', requestData.notification_id)

      if (updateError) {
        console.error('Failed to update notification status:', updateError)
        // Don't throw here as email was sent successfully
      }
    }

    return new Response(
      JSON.stringify({
        success: true,
        message_id: postmarkResult.MessageID,
        to: postmarkResult.To,
        submitted_at: postmarkResult.SubmittedAt,
      }),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Error sending email:', error)

    // Update notification status to failed if notification_id provided
    if (req.body) {
      try {
        const requestData = await req.json()
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

// Template rendering utility
function renderTemplate(template: string, variables: Record<string, any>): string {
  let rendered = template
  
  Object.entries(variables).forEach(([key, value]) => {
    const placeholder = `{{${key}}}`
    const stringValue = value?.toString() || ''
    rendered = rendered.replaceAll(placeholder, stringValue)
  })
  
  return rendered
}