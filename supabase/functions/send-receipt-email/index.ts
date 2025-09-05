import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.7'
import { jsPDF } from 'https://esm.sh/jspdf@2.5.1'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface ReceiptRequest {
  booking_id: string
  recipient_email: string
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { booking_id, recipient_email }: ReceiptRequest = await req.json()

    if (!booking_id || !recipient_email) {
      return new Response(
        JSON.stringify({ error: 'Missing required parameters' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseKey)

    // Get booking details with chef information
    const { data: booking, error: bookingError } = await supabase
      .from('bookings')
      .select(`
        *,
        chefs!inner(
          id,
          profiles!inner(
            first_name,
            last_name
          )
        ),
        profiles!inner(
          first_name,
          last_name,
          email
        )
      `)
      .eq('id', booking_id)
      .single()

    if (bookingError || !booking) {
      return new Response(
        JSON.stringify({ error: 'Booking not found' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Check if user owns this booking
    const authHeader = req.headers.get('Authorization')
    if (authHeader) {
      const token = authHeader.replace('Bearer ', '')
      const { data: { user }, error: userError } = await supabase.auth.getUser(token)
      
      if (!userError && user && booking.user_id !== user.id) {
        return new Response(
          JSON.stringify({ error: 'Unauthorized' }),
          { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
    }

    // Check rate limiting (max 3 receipts per booking)
    const receiptCount = booking.receipt_sent_count || 0
    if (receiptCount >= 3) {
      return new Response(
        JSON.stringify({ error: 'Maximum receipt sends reached for this booking' }),
        { status: 429, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Generate PDF receipt
    const pdf = generateReceiptPDF(booking)
    const pdfBytes = pdf.output('arraybuffer')
    const pdfBase64 = btoa(String.fromCharCode(...new Uint8Array(pdfBytes)))

    // Format dates
    const bookingDate = new Date(booking.date)
    const createdDate = new Date(booking.created_at)
    const paymentDate = booking.payment_captured_at ? new Date(booking.payment_captured_at) : new Date()
    
    const formatDate = (date: Date) => {
      const day = date.getDate()
      const months = ['januar', 'februar', 'marts', 'april', 'maj', 'juni', 
                     'juli', 'august', 'september', 'oktober', 'november', 'december']
      const month = months[date.getMonth()]
      const year = date.getFullYear()
      return `${day}. ${month} ${year}`
    }

    const formatTime = (time: string) => {
      const [hours, minutes] = time.split(':')
      return `${hours}:${minutes}`
    }

    // Send email via Postmark
    const postmarkToken = Deno.env.get('POSTMARK_SERVER_TOKEN')
    if (!postmarkToken) {
      throw new Error('Postmark configuration missing')
    }

    const emailData = {
      From: 'DinnerHelp <noreply@dinnerhelp.dk>',
      To: recipient_email,
      Subject: `Kvittering - Booking #${booking.id.substring(0, 8).toUpperCase()}`,
      HtmlBody: `
        <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
          <div style="text-align: center; margin-bottom: 30px;">
            <h1 style="color: #2563eb; margin-bottom: 10px;">DinnerHelp</h1>
            <h2 style="color: #475569; font-size: 24px; margin: 0;">Kvittering</h2>
          </div>
          
          <div style="background: #f8fafc; border-radius: 8px; padding: 20px; margin-bottom: 20px;">
            <p style="margin: 0 0 10px 0; color: #475569;">
              <strong>Booking ID:</strong> #${booking.id.substring(0, 8).toUpperCase()}
            </p>
            <p style="margin: 0 0 10px 0; color: #475569;">
              <strong>Booket den:</strong> ${formatDate(createdDate)}
            </p>
            <p style="margin: 0; color: #475569;">
              <strong>Service dato:</strong> ${formatDate(bookingDate)}
            </p>
          </div>

          <div style="background: #fff; border: 1px solid #e2e8f0; border-radius: 8px; padding: 20px; margin-bottom: 20px;">
            <h3 style="color: #1e293b; margin-top: 0;">Kok Information</h3>
            <p style="color: #475569;">
              ${booking.chefs.profiles.first_name} ${booking.chefs.profiles.last_name}
            </p>
          </div>

          <div style="background: #fff; border: 1px solid #e2e8f0; border-radius: 8px; padding: 20px; margin-bottom: 20px;">
            <h3 style="color: #1e293b; margin-top: 0;">Booking Detaljer</h3>
            <table style="width: 100%; color: #475569;">
              <tr>
                <td style="padding: 5px 0;">Service dato:</td>
                <td style="text-align: right;">${formatDate(bookingDate)}</td>
              </tr>
              <tr>
                <td style="padding: 5px 0;">Tid:</td>
                <td style="text-align: right;">${formatTime(booking.start_time)}</td>
              </tr>
              <tr>
                <td style="padding: 5px 0;">Personer:</td>
                <td style="text-align: right;">${booking.number_of_guests}</td>
              </tr>
              <tr>
                <td style="padding: 5px 0;">Adresse:</td>
                <td style="text-align: right;">${booking.address || 'Ikke angivet'}</td>
              </tr>
            </table>
          </div>

          <div style="background: #f0fdf4; border: 1px solid #86efac; border-radius: 8px; padding: 20px; margin-bottom: 20px;">
            <h3 style="color: #166534; margin-top: 0;">Betaling</h3>
            <table style="width: 100%; color: #166534;">
              <tr>
                <td style="padding: 5px 0;">Service:</td>
                <td style="text-align: right;">${((booking.total_amount - booking.platform_fee) * 0.8).toFixed(0)} kr</td>
              </tr>
              <tr>
                <td style="padding: 5px 0;">Servicegebyr:</td>
                <td style="text-align: right;">${booking.platform_fee} kr</td>
              </tr>
              <tr>
                <td style="padding: 5px 0;">Moms (25%):</td>
                <td style="text-align: right;">${(booking.total_amount * 0.2).toFixed(0)} kr</td>
              </tr>
              <tr style="border-top: 2px solid #86efac; margin-top: 10px;">
                <td style="padding: 10px 0 5px 0; font-weight: bold;">TOTAL:</td>
                <td style="text-align: right; font-weight: bold; font-size: 18px;">${booking.total_amount} kr</td>
              </tr>
            </table>
            <p style="margin: 10px 0 0 0; color: #166534; font-size: 14px;">
              Betalt den: ${formatDate(paymentDate)}
            </p>
          </div>

          <div style="text-align: center; color: #64748b; font-size: 14px; margin-top: 30px;">
            <p>Support: hello@dinnerhelp.dk</p>
            <p>CVR: 45721647</p>
          </div>
          
          <div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #e2e8f0; text-align: center; color: #94a3b8; font-size: 12px;">
            <p>Denne kvittering er sendt til ${recipient_email}</p>
            <p>Se vedhæftet PDF for en udskriftsvenlig version</p>
          </div>
        </div>
      `,
      TextBody: `
DinnerHelp - Kvittering

Booking ID: #${booking.id.substring(0, 8).toUpperCase()}
Booket den: ${formatDate(createdDate)}

Kok: ${booking.chefs.profiles.first_name} ${booking.chefs.profiles.last_name}
Service dato: ${formatDate(bookingDate)}
Tid: ${formatTime(booking.start_time)}
Personer: ${booking.number_of_guests}

Total betalt: ${booking.total_amount} kr
Betalt den: ${formatDate(paymentDate)}

Support: hello@dinnerhelp.dk
CVR: 45721647
      `,
      Attachments: [
        {
          Name: `kvittering_${booking.id.substring(0, 8).toUpperCase()}.pdf`,
          Content: pdfBase64,
          ContentType: 'application/pdf'
        }
      ]
    }

    const postmarkResponse = await fetch('https://api.postmarkapp.com/email', {
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-Postmark-Server-Token': postmarkToken,
      },
      body: JSON.stringify(emailData)
    })

    if (!postmarkResponse.ok) {
      const error = await postmarkResponse.text()
      throw new Error(`Failed to send email: ${error}`)
    }

    // Update receipt send count
    await supabase
      .from('bookings')
      .update({
        receipt_sent_count: receiptCount + 1,
        last_receipt_sent_at: new Date().toISOString()
      })
      .eq('id', booking_id)

    return new Response(
      JSON.stringify({ 
        success: true, 
        message: 'Receipt sent successfully',
        receipt_count: receiptCount + 1 
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Error sending receipt:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})

function generateReceiptPDF(booking: any): any {
  // Create new PDF document
  const pdf = new jsPDF({
    orientation: 'portrait',
    unit: 'mm',
    format: 'a4'
  })

  // Helper function to format dates
  const formatDate = (dateStr: string) => {
    const date = new Date(dateStr)
    const day = date.getDate()
    const months = ['januar', 'februar', 'marts', 'april', 'maj', 'juni', 
                   'juli', 'august', 'september', 'oktober', 'november', 'december']
    const month = months[date.getMonth()]
    const year = date.getFullYear()
    return `${day}. ${month} ${year}`
  }

  const formatTime = (time: string) => {
    const [hours, minutes] = time.split(':')
    return `${hours}:${minutes}`
  }

  // Set fonts and colors
  pdf.setFontSize(24)
  pdf.setTextColor(37, 99, 235) // Blue color
  pdf.text('DinnerHelp', 105, 25, { align: 'center' })
  
  pdf.setFontSize(18)
  pdf.setTextColor(71, 85, 105) // Gray color
  pdf.text('KVITTERING', 105, 35, { align: 'center' })

  // Booking ID and dates
  pdf.setFontSize(10)
  pdf.setTextColor(0, 0, 0)
  pdf.text(`Booking ID: #${booking.id.substring(0, 8).toUpperCase()}`, 20, 55)
  pdf.text(`Booket den: ${formatDate(booking.created_at)}`, 20, 62)

  // Chef information section
  pdf.setFillColor(248, 250, 252)
  pdf.rect(20, 70, 170, 20, 'F')
  pdf.setFontSize(12)
  pdf.setFont(undefined, 'bold')
  pdf.text('KOK INFORMATION', 25, 78)
  pdf.setFont(undefined, 'normal')
  pdf.setFontSize(10)
  pdf.text(`Navn: ${booking.chefs.profiles.first_name} ${booking.chefs.profiles.last_name}`, 25, 85)
  if (isVatRegistered && booking.chefs.vat_number) {
    pdf.text(`CVR: ${booking.chefs.vat_number}`, 25, 90)
  }

  // Booking details section
  pdf.setFillColor(248, 250, 252)
  pdf.rect(20, 95, 170, 40, 'F')
  pdf.setFontSize(12)
  pdf.setFont(undefined, 'bold')
  pdf.text('BOOKING DETALJER', 25, 103)
  pdf.setFont(undefined, 'normal')
  pdf.setFontSize(10)
  
  const bookingDate = new Date(booking.date)
  pdf.text(`Service dato: ${formatDate(booking.date)}`, 25, 110)
  pdf.text(`Tid: ${formatTime(booking.start_time)}`, 25, 117)
  pdf.text(`Personer: ${booking.number_of_guests}`, 25, 124)
  pdf.text(`Adresse: ${booking.address || 'Ikke angivet'}`, 25, 131)

  // Payment details section
  pdf.setFillColor(240, 253, 244) // Light green
  pdf.rect(20, 140, 170, 50, 'F')
  pdf.setFontSize(12)
  pdf.setFont(undefined, 'bold')
  pdf.text('BETALING', 25, 148)
  pdf.setFont(undefined, 'normal')
  pdf.setFontSize(10)

  // Fees are already calculated above
  // const baseAmount, userServiceFee, paymentProcessingFee, vatAmount
  
  pdf.text(`Service:`, 25, 156)
  pdf.text(`${baseAmount.toFixed(0)} kr`, 180, 156, { align: 'right' })
  
  pdf.text(`Servicegebyr:`, 25, 163)
  pdf.text(`${booking.platform_fee} kr`, 180, 163, { align: 'right' })
  
  pdf.text(`Moms (25%):`, 25, 170)
  pdf.text(`${vatAmount.toFixed(0)} kr`, 180, 170, { align: 'right' })

  // Draw line before total
  pdf.setDrawColor(134, 239, 172)
  pdf.setLineWidth(0.5)
  pdf.line(25, 175, 185, 175)

  pdf.setFontSize(12)
  pdf.setFont(undefined, 'bold')
  const totalLineY = vatAmount > 0 ? 190 : 183
  pdf.text(`TOTAL:`, 25, totalLineY)
  pdf.text(`${(booking.total_amount / 100).toFixed(0)} kr`, 180, totalLineY, { align: 'right' })

  // Payment date
  pdf.setFont(undefined, 'normal')
  pdf.setFontSize(9)
  const paymentDate = booking.payment_captured_at || booking.updated_at
  pdf.text(`Betalt den: ${formatDate(paymentDate)}`, 25, 189)
  
  // Transaction ID
  if (booking.stripe_payment_intent_id) {
    pdf.text(`Transaktion: ****${booking.stripe_payment_intent_id.slice(-8)}`, 100, 189)
  }

  // Footer
  pdf.setFontSize(9)
  pdf.setTextColor(100, 116, 139)
  pdf.text('Support: hello@dinnerhelp.dk', 105, 270, { align: 'center' })
  pdf.text('CVR: 45721647', 105, 276, { align: 'center' })

  return pdf
}