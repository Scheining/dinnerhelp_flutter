-- Create notification types enum
CREATE TYPE notification_type AS ENUM (
    'booking_confirmation',
    'booking_reminder_24h',
    'booking_reminder_1h',
    'booking_completion',
    'booking_modified',
    'booking_cancelled',
    'recurring_booking_created',
    'chef_message',
    'payment_success',
    'payment_failed'
);

-- Create notification status enum
CREATE TYPE notification_status AS ENUM (
    'pending',
    'processing',
    'sent',
    'delivered',
    'failed',
    'cancelled'
);

-- Create notification channels enum
CREATE TYPE notification_channel AS ENUM (
    'email',
    'push',
    'in_app',
    'sms'
);

-- Create notification preferences table
CREATE TABLE notification_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    email_enabled BOOLEAN DEFAULT true,
    push_enabled BOOLEAN DEFAULT true,
    in_app_enabled BOOLEAN DEFAULT true,
    sms_enabled BOOLEAN DEFAULT false,
    booking_confirmations BOOLEAN DEFAULT true,
    booking_reminders BOOLEAN DEFAULT true,
    booking_updates BOOLEAN DEFAULT true,
    marketing_emails BOOLEAN DEFAULT false,
    language_preference VARCHAR(10) DEFAULT 'da',
    timezone VARCHAR(50) DEFAULT 'Europe/Copenhagen',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(user_id)
);

-- Create notifications table
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    booking_id UUID,
    chef_id UUID,
    type notification_type NOT NULL,
    channel notification_channel NOT NULL,
    status notification_status DEFAULT 'pending',
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    data JSONB DEFAULT '{}',
    template_id VARCHAR(100),
    scheduled_at TIMESTAMPTZ,
    sent_at TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ,
    failed_at TIMESTAMPTZ,
    failure_reason TEXT,
    retry_count INTEGER DEFAULT 0,
    max_retries INTEGER DEFAULT 3,
    external_id VARCHAR(255), -- For tracking with external services
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create notification queue table for scheduled notifications
CREATE TABLE notification_queue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    notification_id UUID REFERENCES notifications(id) ON DELETE CASCADE,
    scheduled_for TIMESTAMPTZ NOT NULL,
    is_processed BOOLEAN DEFAULT false,
    processed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create device tokens table for push notifications
CREATE TABLE device_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    token VARCHAR(500) NOT NULL,
    platform VARCHAR(20) NOT NULL, -- 'ios', 'android', 'web'
    app_version VARCHAR(50),
    device_id VARCHAR(255),
    is_active BOOLEAN DEFAULT true,
    last_used_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(token, user_id)
);

-- Create email templates table
CREATE TABLE email_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    template_key VARCHAR(100) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    subject_da TEXT NOT NULL,
    subject_en TEXT NOT NULL,
    html_content_da TEXT NOT NULL,
    html_content_en TEXT NOT NULL,
    text_content_da TEXT,
    text_content_en TEXT,
    variables JSONB DEFAULT '[]', -- Array of required variables
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create recurring booking notifications table
CREATE TABLE recurring_booking_notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_series_id UUID NOT NULL,
    booking_id UUID,
    occurrence_date DATE NOT NULL,
    notification_type notification_type NOT NULL,
    is_sent BOOLEAN DEFAULT false,
    sent_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_booking_id ON notifications(booking_id);
CREATE INDEX idx_notifications_type ON notifications(type);
CREATE INDEX idx_notifications_status ON notifications(status);
CREATE INDEX idx_notifications_scheduled_at ON notifications(scheduled_at);
CREATE INDEX idx_notifications_created_at ON notifications(created_at);

CREATE INDEX idx_notification_queue_scheduled_for ON notification_queue(scheduled_for);
CREATE INDEX idx_notification_queue_is_processed ON notification_queue(is_processed);

CREATE INDEX idx_device_tokens_user_id ON device_tokens(user_id);
CREATE INDEX idx_device_tokens_is_active ON device_tokens(is_active);

CREATE INDEX idx_notification_preferences_user_id ON notification_preferences(user_id);

CREATE INDEX idx_recurring_booking_notifications_series_id ON recurring_booking_notifications(booking_series_id);
CREATE INDEX idx_recurring_booking_notifications_occurrence_date ON recurring_booking_notifications(occurrence_date);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at triggers
CREATE TRIGGER update_notification_preferences_updated_at BEFORE UPDATE ON notification_preferences FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_notifications_updated_at BEFORE UPDATE ON notifications FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_email_templates_updated_at BEFORE UPDATE ON email_templates FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- RLS Policies

-- notification_preferences policies
ALTER TABLE notification_preferences ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own notification preferences" ON notification_preferences
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own notification preferences" ON notification_preferences
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own notification preferences" ON notification_preferences
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- notifications policies
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own notifications" ON notifications
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Service role can manage all notifications" ON notifications
    FOR ALL USING (auth.role() = 'service_role');

-- notification_queue policies
ALTER TABLE notification_queue ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Service role can manage notification queue" ON notification_queue
    FOR ALL USING (auth.role() = 'service_role');

-- device_tokens policies  
ALTER TABLE device_tokens ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own device tokens" ON device_tokens
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can manage their own device tokens" ON device_tokens
    FOR ALL USING (auth.uid() = user_id);

-- email_templates policies
ALTER TABLE email_templates ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Service role can manage email templates" ON email_templates
    FOR ALL USING (auth.role() = 'service_role');

CREATE POLICY "Public read access to active email templates" ON email_templates
    FOR SELECT USING (is_active = true);

-- recurring_booking_notifications policies
ALTER TABLE recurring_booking_notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Service role can manage recurring booking notifications" ON recurring_booking_notifications
    FOR ALL USING (auth.role() = 'service_role');

-- Insert default email templates
INSERT INTO email_templates (template_key, name, description, subject_da, subject_en, html_content_da, html_content_en, text_content_da, text_content_en, variables) VALUES
('booking_confirmation_user', 'Booking Confirmation - User', 'Confirmation email sent to user when booking is confirmed', 
    'Din booking er bekræftet! 🎉', 
    'Your booking is confirmed! 🎉',
    '<!DOCTYPE html><html><head><meta charset="utf-8"><title>Booking Bekræftelse</title></head><body><h1>Hej {{user_name}},</h1><p>Din booking er bekræftet!</p><p><strong>Detaljer:</strong></p><ul><li>Kok: {{chef_name}}</li><li>Dato: {{booking_date}}</li><li>Tid: {{booking_time}}</li><li>Gæster: {{guest_count}}</li><li>Adresse: {{address}}</li></ul><p>Vi glæder os til at give dig en fantastisk madoplevelse!</p><p>Med venlig hilsen,<br>DinnerHelp-teamet</p></body></html>',
    '<!DOCTYPE html><html><head><meta charset="utf-8"><title>Booking Confirmation</title></head><body><h1>Hi {{user_name}},</h1><p>Your booking is confirmed!</p><p><strong>Details:</strong></p><ul><li>Chef: {{chef_name}}</li><li>Date: {{booking_date}}</li><li>Time: {{booking_time}}</li><li>Guests: {{guest_count}}</li><li>Address: {{address}}</li></ul><p>We look forward to providing you with an amazing dining experience!</p><p>Best regards,<br>The DinnerHelp Team</p></body></html>',
    'Hej {{user_name}}, Din booking er bekræftet! Detaljer: Kok: {{chef_name}}, Dato: {{booking_date}}, Tid: {{booking_time}}, Gæster: {{guest_count}}, Adresse: {{address}}. Vi glæder os til at give dig en fantastisk madoplevelse! Med venlig hilsen, DinnerHelp-teamet',
    'Hi {{user_name}}, Your booking is confirmed! Details: Chef: {{chef_name}}, Date: {{booking_date}}, Time: {{booking_time}}, Guests: {{guest_count}}, Address: {{address}}. We look forward to providing you with an amazing dining experience! Best regards, The DinnerHelp Team',
    '["user_name", "chef_name", "booking_date", "booking_time", "guest_count", "address", "booking_id"]'::jsonb),

('booking_confirmation_chef', 'Booking Confirmation - Chef', 'Confirmation email sent to chef when booking is confirmed',
    'Ny booking bekræftet! 👨‍🍳',
    'New booking confirmed! 👨‍🍳', 
    '<!DOCTYPE html><html><head><meta charset="utf-8"><title>Ny Booking</title></head><body><h1>Hej {{chef_name}},</h1><p>Du har fået en ny booking!</p><p><strong>Detaljer:</strong></p><ul><li>Kunde: {{user_name}}</li><li>Dato: {{booking_date}}</li><li>Tid: {{booking_time}}</li><li>Gæster: {{guest_count}}</li><li>Adresse: {{address}}</li></ul><p>Log ind på din konto for at se alle detaljer.</p><p>Held og lykke med din madlavning!</p><p>Med venlig hilsen,<br>DinnerHelp-teamet</p></body></html>',
    '<!DOCTYPE html><html><head><meta charset="utf-8"><title>New Booking</title></head><body><h1>Hi {{chef_name}},</h1><p>You have received a new booking!</p><p><strong>Details:</strong></p><ul><li>Customer: {{user_name}}</li><li>Date: {{booking_date}}</li><li>Time: {{booking_time}}</li><li>Guests: {{guest_count}}</li><li>Address: {{address}}</li></ul><p>Log in to your account to see all details.</p><p>Good luck with your cooking!</p><p>Best regards,<br>The DinnerHelp Team</p></body></html>',
    'Hej {{chef_name}}, Du har fået en ny booking! Detaljer: Kunde: {{user_name}}, Dato: {{booking_date}}, Tid: {{booking_time}}, Gæster: {{guest_count}}, Adresse: {{address}}. Log ind på din konto for at se alle detaljer. Held og lykke med din madlavning! Med venlig hilsen, DinnerHelp-teamet',
    'Hi {{chef_name}}, You have received a new booking! Details: Customer: {{user_name}}, Date: {{booking_date}}, Time: {{booking_time}}, Guests: {{guest_count}}, Address: {{address}}. Log in to your account to see all details. Good luck with your cooking! Best regards, The DinnerHelp Team',
    '["chef_name", "user_name", "booking_date", "booking_time", "guest_count", "address", "booking_id"]'::jsonb),

('booking_reminder_24h', 'Booking Reminder - 24 Hours', 'Reminder sent 24 hours before booking',
    'Påmindelse: Din madoplevelse i morgen! 🍽️',
    'Reminder: Your dining experience tomorrow! 🍽️',
    '<!DOCTYPE html><html><head><meta charset="utf-8"><title>Booking Påmindelse</title></head><body><h1>Hej {{user_name}},</h1><p>Dette er en påmindelse om din madoplevelse i morgen!</p><p><strong>Detaljer:</strong></p><ul><li>Kok: {{chef_name}}</li><li>Dato: {{booking_date}}</li><li>Tid: {{booking_time}}</li><li>Gæster: {{guest_count}}</li><li>Adresse: {{address}}</li></ul><p>Sørg for at være klar og have køkkenet tilgængeligt for kokken.</p><p>Vi glæder os til din madoplevelse!</p><p>Med venlig hilsen,<br>DinnerHelp-teamet</p></body></html>',
    '<!DOCTYPE html><html><head><meta charset="utf-8"><title>Booking Reminder</title></head><body><h1>Hi {{user_name}},</h1><p>This is a reminder about your dining experience tomorrow!</p><p><strong>Details:</strong></p><ul><li>Chef: {{chef_name}}</li><li>Date: {{booking_date}}</li><li>Time: {{booking_time}}</li><li>Guests: {{guest_count}}</li><li>Address: {{address}}</li></ul><p>Make sure you are ready and have the kitchen available for the chef.</p><p>We look forward to your dining experience!</p><p>Best regards,<br>The DinnerHelp Team</p></body></html>',
    'Hej {{user_name}}, Dette er en påmindelse om din madoplevelse i morgen! Detaljer: Kok: {{chef_name}}, Dato: {{booking_date}}, Tid: {{booking_time}}, Gæster: {{guest_count}}, Adresse: {{address}}. Sørg for at være klar og have køkkenet tilgængeligt for kokken. Vi glæder os til din madoplevelse! Med venlig hilsen, DinnerHelp-teamet',
    'Hi {{user_name}}, This is a reminder about your dining experience tomorrow! Details: Chef: {{chef_name}}, Date: {{booking_date}}, Time: {{booking_time}}, Guests: {{guest_count}}, Address: {{address}}. Make sure you are ready and have the kitchen available for the chef. We look forward to your dining experience! Best regards, The DinnerHelp Team',
    '["user_name", "chef_name", "booking_date", "booking_time", "guest_count", "address", "booking_id"]'::jsonb);

-- Function to create default notification preferences for new users
CREATE OR REPLACE FUNCTION create_default_notification_preferences()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO notification_preferences (user_id)
    VALUES (NEW.id)
    ON CONFLICT (user_id) DO NOTHING;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to create default preferences when user is created
CREATE TRIGGER create_user_notification_preferences
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION create_default_notification_preferences();