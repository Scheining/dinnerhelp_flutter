-- Migration: Implement Authorization & Hold Pattern for Bookings
-- This migration adds reservation functionality without breaking existing bookings

-- 1. Add reservation fields to payment_intents table
ALTER TABLE public.payment_intents 
ADD COLUMN IF NOT EXISTS reservation_expires_at timestamptz,
ADD COLUMN IF NOT EXISTS booking_data jsonb,
ADD COLUMN IF NOT EXISTS reservation_status text DEFAULT 'active' 
  CHECK (reservation_status IN ('active', 'expired', 'converted', 'cancelled'));

-- Index for finding active reservations
CREATE INDEX IF NOT EXISTS idx_payment_intents_reservation_status 
ON public.payment_intents(reservation_status, reservation_expires_at)
WHERE reservation_status = 'active';

-- 2. Add new status for bookings that are pending payment authorization
ALTER TABLE public.bookings 
DROP CONSTRAINT IF EXISTS bookings_status_check;

ALTER TABLE public.bookings 
ADD CONSTRAINT bookings_status_check 
CHECK (status IN ('pending', 'accepted', 'confirmed', 'in_progress', 'completed', 'cancelled', 'disputed', 'refunded', 'payment_reserving'));

-- 3. Create a view for active reservations (for availability checking)
CREATE OR REPLACE VIEW public.active_booking_reservations AS
SELECT 
  pi.chef_stripe_account_id as chef_id,
  (pi.booking_data->>'date')::date as date,
  (pi.booking_data->>'start_time')::time as start_time,
  (pi.booking_data->>'end_time')::time as end_time,
  pi.reservation_expires_at,
  pi.id as payment_intent_id
FROM public.payment_intents pi
WHERE pi.reservation_status = 'active'
  AND pi.reservation_expires_at > NOW()
  AND pi.booking_data IS NOT NULL;

-- Grant permissions
GRANT SELECT ON public.active_booking_reservations TO authenticated;
GRANT SELECT ON public.active_booking_reservations TO service_role;

-- 4. Function to check if a time slot is available (considers both bookings and reservations)
CREATE OR REPLACE FUNCTION public.is_chef_time_slot_available(
  p_chef_id uuid,
  p_date date,
  p_start_time time,
  p_end_time time,
  p_buffer_minutes integer DEFAULT 60
)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_conflict_count integer;
BEGIN
  -- Check for conflicts with existing bookings
  SELECT COUNT(*)
  INTO v_conflict_count
  FROM public.bookings b
  WHERE b.chef_id = p_chef_id
    AND b.date = p_date
    AND b.status IN ('pending', 'accepted', 'confirmed', 'in_progress')
    AND (
      -- Check for time overlap including buffer
      (b.start_time - (p_buffer_minutes || ' minutes')::interval <= p_end_time)
      AND (b.end_time + (p_buffer_minutes || ' minutes')::interval >= p_start_time)
    );

  IF v_conflict_count > 0 THEN
    RETURN false;
  END IF;

  -- Check for conflicts with active reservations
  SELECT COUNT(*)
  INTO v_conflict_count
  FROM public.active_booking_reservations r
  WHERE r.chef_id = p_chef_id
    AND r.date = p_date
    AND (
      -- Check for time overlap including buffer
      (r.start_time - (p_buffer_minutes || ' minutes')::interval <= p_end_time)
      AND (r.end_time + (p_buffer_minutes || ' minutes')::interval >= p_start_time)
    );

  RETURN v_conflict_count = 0;
END;
$$;

-- 5. Function to convert a reservation to a booking
CREATE OR REPLACE FUNCTION public.convert_reservation_to_booking(
  p_payment_intent_id text,
  p_stripe_payment_status text DEFAULT 'succeeded'
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_booking_data jsonb;
  v_booking_id uuid;
  v_chef_stripe_account_id text;
BEGIN
  -- Get the reservation data
  SELECT booking_data, chef_stripe_account_id
  INTO v_booking_data, v_chef_stripe_account_id
  FROM public.payment_intents
  WHERE stripe_payment_intent_id = p_payment_intent_id
    AND reservation_status = 'active';

  IF v_booking_data IS NULL THEN
    RAISE EXCEPTION 'No active reservation found for payment intent %', p_payment_intent_id;
  END IF;

  -- Create the booking
  INSERT INTO public.bookings (
    id,
    user_id,
    chef_id,
    date,
    start_time,
    end_time,
    status,
    number_of_guests,
    total_amount,
    payment_status,
    address,
    notes,
    stripe_payment_intent_id,
    platform_fee,
    created_at,
    updated_at
  ) VALUES (
    COALESCE((v_booking_data->>'id')::uuid, gen_random_uuid()),
    (v_booking_data->>'user_id')::uuid,
    (v_booking_data->>'chef_id')::uuid,
    (v_booking_data->>'date')::date,
    (v_booking_data->>'start_time')::time,
    (v_booking_data->>'end_time')::time,
    CASE 
      WHEN p_stripe_payment_status = 'requires_capture' THEN 'confirmed'
      WHEN p_stripe_payment_status = 'succeeded' THEN 'confirmed'
      ELSE 'pending'
    END,
    (v_booking_data->>'number_of_guests')::integer,
    (v_booking_data->>'total_amount')::integer,
    p_stripe_payment_status,
    v_booking_data->>'address',
    v_booking_data->>'notes',
    p_payment_intent_id,
    (v_booking_data->>'platform_fee')::numeric,
    NOW(),
    NOW()
  )
  RETURNING id INTO v_booking_id;

  -- Mark the reservation as converted
  UPDATE public.payment_intents
  SET 
    reservation_status = 'converted',
    updated_at = NOW()
  WHERE stripe_payment_intent_id = p_payment_intent_id;

  RETURN v_booking_id;
END;
$$;

-- 6. Function to clean up expired reservations
CREATE OR REPLACE FUNCTION public.cleanup_expired_reservations()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE public.payment_intents
  SET 
    reservation_status = 'expired',
    updated_at = NOW()
  WHERE reservation_status = 'active'
    AND reservation_expires_at < NOW();
END;
$$;

-- 7. Create a scheduled job to clean up expired reservations (runs every 5 minutes)
-- Note: This requires pg_cron extension
-- If pg_cron is not available, you'll need to call this from an Edge Function
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_cron') THEN
    PERFORM cron.schedule(
      'cleanup-expired-reservations',
      '*/5 * * * *',
      'SELECT public.cleanup_expired_reservations();'
    );
  END IF;
END $$;

-- 8. Update RLS policies for the new view
CREATE POLICY "Users can view reservations affecting their bookings"
ON public.payment_intents
FOR SELECT
USING (
  auth.uid() IN (
    SELECT (booking_data->>'user_id')::uuid
    UNION
    SELECT (booking_data->>'chef_id')::uuid
  )
);

-- 9. Add helper function for migration rollback (if needed)
CREATE OR REPLACE FUNCTION public.rollback_reservation_system()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- This function can be used to quickly disable the reservation system
  -- without losing data if issues arise
  
  -- Mark all active reservations as cancelled
  UPDATE public.payment_intents
  SET reservation_status = 'cancelled'
  WHERE reservation_status = 'active';
  
  -- Log the rollback
  INSERT INTO public.system_logs (action, details, created_at)
  VALUES ('reservation_rollback', jsonb_build_object('timestamp', NOW()), NOW());
END;
$$;

-- Create system_logs table if it doesn't exist (for tracking rollbacks)
CREATE TABLE IF NOT EXISTS public.system_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  action text NOT NULL,
  details jsonb,
  created_at timestamptz DEFAULT NOW()
);

COMMENT ON FUNCTION public.is_chef_time_slot_available IS 
'Checks if a chef is available for a given time slot, considering both confirmed bookings and active payment reservations';

COMMENT ON FUNCTION public.convert_reservation_to_booking IS 
'Converts a payment reservation to an actual booking after successful payment authorization';

COMMENT ON FUNCTION public.cleanup_expired_reservations IS 
'Marks expired payment reservations as expired to free up time slots';

COMMENT ON VIEW public.active_booking_reservations IS 
'View of all active payment reservations that should block booking slots';