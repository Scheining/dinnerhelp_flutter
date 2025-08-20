-- Create function to send notification when booking status changes
CREATE OR REPLACE FUNCTION notify_booking_status_change()
RETURNS TRIGGER AS $$
DECLARE
  notification_type TEXT;
BEGIN
  -- Only proceed if status has changed
  IF OLD.status IS DISTINCT FROM NEW.status THEN
    -- Determine notification type based on status change
    CASE NEW.status
      WHEN 'confirmed' THEN
        notification_type := 'booking_confirmed';
      WHEN 'completed' THEN
        notification_type := 'booking_completed';
      WHEN 'cancelled' THEN
        notification_type := 'booking_cancelled';
      ELSE
        RETURN NEW;
    END CASE;

    -- Call edge function to send notification
    PERFORM
      net.http_post(
        url := current_setting('app.supabase_url') || '/functions/v1/send-booking-notifications',
        headers := jsonb_build_object(
          'Content-Type', 'application/json',
          'Authorization', 'Bearer ' || current_setting('app.supabase_service_role_key')
        ),
        body := jsonb_build_object(
          'type', notification_type,
          'bookingId', NEW.id,
          'userId', NEW.user_id,
          'chefId', NEW.chef_id
        )
      );

    -- Schedule rating request 15 minutes after completion
    IF NEW.status = 'completed' THEN
      -- Insert a job to send rating request after 15 minutes
      INSERT INTO notification_queue (
        booking_id,
        notification_type,
        scheduled_for,
        created_at
      ) VALUES (
        NEW.id,
        'rating_request',
        NOW() + INTERVAL '15 minutes',
        NOW()
      );
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for booking status changes
DROP TRIGGER IF EXISTS booking_status_change_trigger ON bookings;
CREATE TRIGGER booking_status_change_trigger
  AFTER UPDATE OF status ON bookings
  FOR EACH ROW
  EXECUTE FUNCTION notify_booking_status_change();

-- Create function to send notification when new message is created
CREATE OR REPLACE FUNCTION notify_new_message()
RETURNS TRIGGER AS $$
DECLARE
  recipient_id UUID;
BEGIN
  -- Determine recipient based on sender
  SELECT 
    CASE 
      WHEN NEW.sender_id = b.user_id THEN b.chef_id
      ELSE b.user_id
    END INTO recipient_id
  FROM bookings b
  WHERE b.id = NEW.booking_id;

  -- Call edge function to send notification
  PERFORM
    net.http_post(
      url := current_setting('app.supabase_url') || '/functions/v1/send-booking-notifications',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer ' || current_setting('app.supabase_service_role_key')
      ),
      body := jsonb_build_object(
        'type', 'new_message',
        'messageId', NEW.id,
        'userId', recipient_id
      )
    );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for new messages
DROP TRIGGER IF EXISTS new_message_trigger ON chat_messages;
CREATE TRIGGER new_message_trigger
  AFTER INSERT ON chat_messages
  FOR EACH ROW
  EXECUTE FUNCTION notify_new_message();

-- Create notification queue table for scheduled notifications
CREATE TABLE IF NOT EXISTS notification_queue (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  booking_id UUID REFERENCES bookings(id) ON DELETE CASCADE,
  notification_type TEXT NOT NULL,
  scheduled_for TIMESTAMPTZ NOT NULL,
  sent_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  error_message TEXT
);

-- Create index for efficient querying
CREATE INDEX idx_notification_queue_scheduled ON notification_queue(scheduled_for) WHERE sent_at IS NULL;

-- Create function to process scheduled notifications
CREATE OR REPLACE FUNCTION process_scheduled_notifications()
RETURNS void AS $$
DECLARE
  notification RECORD;
BEGIN
  -- Process all due notifications
  FOR notification IN 
    SELECT * FROM notification_queue 
    WHERE scheduled_for <= NOW() 
    AND sent_at IS NULL
    ORDER BY scheduled_for
  LOOP
    BEGIN
      -- Call edge function to send notification
      PERFORM
        net.http_post(
          url := current_setting('app.supabase_url') || '/functions/v1/send-booking-notifications',
          headers := jsonb_build_object(
            'Content-Type', 'application/json',
            'Authorization', 'Bearer ' || current_setting('app.supabase_service_role_key')
          ),
          body := jsonb_build_object(
            'type', notification.notification_type,
            'bookingId', notification.booking_id
          )
        );
      
      -- Mark as sent
      UPDATE notification_queue 
      SET sent_at = NOW() 
      WHERE id = notification.id;
      
    EXCEPTION WHEN OTHERS THEN
      -- Log error
      UPDATE notification_queue 
      SET error_message = SQLERRM 
      WHERE id = notification.id;
    END;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Create a cron job to process notifications every minute (requires pg_cron extension)
-- This should be set up in Supabase dashboard under Database > Extensions
-- Enable pg_cron and then run:
-- SELECT cron.schedule('process-notifications', '* * * * *', 'SELECT process_scheduled_notifications();');

-- Function to schedule 24-hour reminder when booking is confirmed
CREATE OR REPLACE FUNCTION schedule_booking_reminder()
RETURNS TRIGGER AS $$
BEGIN
  -- Only for confirmed bookings
  IF NEW.status = 'confirmed' AND OLD.status != 'confirmed' THEN
    -- Calculate reminder time (24 hours before booking)
    INSERT INTO notification_queue (
      booking_id,
      notification_type,
      scheduled_for,
      created_at
    ) VALUES (
      NEW.id,
      'reminder_24h',
      (NEW.date + NEW.start_time) - INTERVAL '24 hours',
      NOW()
    );
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for scheduling reminders
DROP TRIGGER IF EXISTS schedule_booking_reminder_trigger ON bookings;
CREATE TRIGGER schedule_booking_reminder_trigger
  AFTER UPDATE OF status ON bookings
  FOR EACH ROW
  EXECUTE FUNCTION schedule_booking_reminder();