-- Add missing foreign key constraint for bookings.chef_id → chefs.id
-- Migration: 20240806120005_add_bookings_chef_fk_constraint.sql

-- Before adding the constraint, let's ensure data integrity
-- Check for any orphaned bookings that reference non-existent chefs
DO $$
DECLARE
    orphaned_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO orphaned_count
    FROM public.bookings b
    WHERE b.chef_id IS NOT NULL 
    AND NOT EXISTS (
        SELECT 1 FROM public.chefs c 
        WHERE c.id = b.chef_id
    );
    
    IF orphaned_count > 0 THEN
        RAISE WARNING 'Found % bookings with chef_id that do not reference existing chefs. These will need to be cleaned up before adding the constraint.', orphaned_count;
        
        -- Log the problematic bookings for reference
        RAISE NOTICE 'Problematic booking IDs: %', (
            SELECT string_agg(b.id::text, ', ')
            FROM public.bookings b
            WHERE b.chef_id IS NOT NULL 
            AND NOT EXISTS (
                SELECT 1 FROM public.chefs c 
                WHERE c.id = b.chef_id
            )
        );
        
        -- Optionally, you could clean up the data here:
        -- UPDATE public.bookings SET chef_id = NULL 
        -- WHERE chef_id IS NOT NULL 
        -- AND NOT EXISTS (SELECT 1 FROM public.chefs c WHERE c.id = bookings.chef_id);
        
        RAISE EXCEPTION 'Cannot add foreign key constraint due to orphaned data. Please clean up the data first.';
    END IF;
END $$;

-- Add the foreign key constraint
ALTER TABLE public.bookings
ADD CONSTRAINT bookings_chef_id_fkey 
FOREIGN KEY (chef_id) REFERENCES public.chefs(id) ON DELETE SET NULL;

-- Create index for the foreign key (if not already exists)
CREATE INDEX IF NOT EXISTS idx_bookings_chef_id ON public.bookings(chef_id);

-- Create a function to validate booking-chef relationship
CREATE OR REPLACE FUNCTION validate_booking_chef_relationship()
RETURNS TRIGGER AS $$
BEGIN
    -- Ensure chef is active and approved when assigning to a booking
    IF NEW.chef_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM public.chefs c
            INNER JOIN public.profiles p ON p.id = c.id
            WHERE c.id = NEW.chef_id 
            AND c.is_active = true 
            AND c.approved = true
            AND p.is_chef = true
        ) THEN
            RAISE EXCEPTION 'Cannot assign booking to inactive, unapproved, or non-chef user';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to validate chef assignment
CREATE TRIGGER validate_booking_chef_assignment_trigger
    BEFORE INSERT OR UPDATE ON public.bookings
    FOR EACH ROW
    WHEN (NEW.chef_id IS NOT NULL)
    EXECUTE FUNCTION validate_booking_chef_relationship();

-- Create function to get booking statistics for a chef
CREATE OR REPLACE FUNCTION get_chef_booking_stats(chef_uuid UUID)
RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    SELECT json_build_object(
        'total_bookings', COUNT(*),
        'pending_bookings', COUNT(*) FILTER (WHERE status = 'pending'),
        'accepted_bookings', COUNT(*) FILTER (WHERE status = 'accepted'),
        'confirmed_bookings', COUNT(*) FILTER (WHERE status = 'confirmed'),
        'completed_bookings', COUNT(*) FILTER (WHERE status = 'completed'),
        'cancelled_bookings', COUNT(*) FILTER (WHERE status = 'cancelled'),
        'total_revenue', COALESCE(SUM(total_amount) FILTER (WHERE status = 'completed'), 0),
        'avg_booking_amount', COALESCE(AVG(total_amount) FILTER (WHERE status IN ('completed', 'confirmed')), 0),
        'recurring_bookings', COUNT(*) FILTER (WHERE is_recurring = true),
        'this_month_bookings', COUNT(*) FILTER (WHERE date >= date_trunc('month', CURRENT_DATE)),
        'next_month_bookings', COUNT(*) FILTER (WHERE date >= date_trunc('month', CURRENT_DATE + interval '1 month') AND date < date_trunc('month', CURRENT_DATE + interval '2 months'))
    )
    INTO result
    FROM public.bookings
    WHERE chef_id = chef_uuid;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to get user booking statistics
CREATE OR REPLACE FUNCTION get_user_booking_stats(user_uuid UUID)
RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    SELECT json_build_object(
        'total_bookings', COUNT(*),
        'pending_bookings', COUNT(*) FILTER (WHERE status = 'pending'),
        'confirmed_bookings', COUNT(*) FILTER (WHERE status = 'confirmed'),
        'completed_bookings', COUNT(*) FILTER (WHERE status = 'completed'),
        'cancelled_bookings', COUNT(*) FILTER (WHERE status = 'cancelled'),
        'total_spent', COALESCE(SUM(total_amount + COALESCE(tip_amount, 0)) FILTER (WHERE status = 'completed'), 0),
        'avg_booking_amount', COALESCE(AVG(total_amount) FILTER (WHERE status IN ('completed', 'confirmed')), 0),
        'recurring_bookings', COUNT(*) FILTER (WHERE is_recurring = true),
        'favorite_chefs', (
            SELECT json_agg(
                json_build_object(
                    'chef_id', chef_id,
                    'booking_count', booking_count
                )
            )
            FROM (
                SELECT chef_id, COUNT(*) as booking_count
                FROM public.bookings
                WHERE user_id = user_uuid AND status = 'completed'
                GROUP BY chef_id
                ORDER BY booking_count DESC
                LIMIT 5
            ) chef_stats
        )
    )
    INTO result
    FROM public.bookings
    WHERE user_id = user_uuid;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permissions on the functions
GRANT EXECUTE ON FUNCTION get_chef_booking_stats(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_booking_stats(UUID) TO authenticated;

-- Create a view for booking details with chef and user information
CREATE OR REPLACE VIEW booking_details AS
SELECT 
    b.*,
    -- Chef information
    c.title as chef_title,
    c.price_per_hour as chef_hourly_rate,
    cp.first_name as chef_first_name,
    cp.last_name as chef_last_name,
    cp.avatar_url as chef_avatar_url,
    c.profile_image_url as chef_profile_image_url,
    
    -- User information
    up.first_name as user_first_name,
    up.last_name as user_last_name,
    up.email as user_email,
    up.avatar_url as user_avatar_url,
    
    -- Menu information (if selected)
    m.title as menu_title,
    m.description as menu_description,
    m.cuisine as menu_cuisine,
    m.image_url as menu_image_url,
    
    -- Series information (if recurring)
    bs.title as series_title,
    bs.pattern as series_pattern,
    
    -- Calculated fields
    (b.total_amount + COALESCE(b.tip_amount, 0)) as total_with_tip,
    CASE 
        WHEN b.date < CURRENT_DATE THEN 'past'
        WHEN b.date = CURRENT_DATE THEN 'today'
        ELSE 'future'
    END as booking_time_category
    
FROM public.bookings b
LEFT JOIN public.chefs c ON c.id = b.chef_id
LEFT JOIN public.profiles cp ON cp.id = c.id
LEFT JOIN public.profiles up ON up.id = b.user_id
LEFT JOIN public.menus m ON m.id = b.selected_menu_id
LEFT JOIN public.booking_series bs ON bs.id = b.recurring_series_id;

-- Grant access to the view with RLS
ALTER VIEW booking_details OWNER TO postgres;
GRANT SELECT ON booking_details TO authenticated;

-- Enable RLS on the view (inherits from bookings table policies)
-- Users can see booking details for their own bookings
-- Chefs can see booking details for bookings assigned to them
-- This is enforced through the underlying bookings table RLS policies

COMMENT ON CONSTRAINT bookings_chef_id_fkey ON public.bookings IS 'Ensures bookings can only be assigned to existing chefs';
COMMENT ON FUNCTION get_chef_booking_stats(UUID) IS 'Returns comprehensive booking statistics for a chef';
COMMENT ON FUNCTION get_user_booking_stats(UUID) IS 'Returns comprehensive booking statistics for a user including favorite chefs';
COMMENT ON VIEW booking_details IS 'Comprehensive view of booking information including chef, user, menu, and series details';