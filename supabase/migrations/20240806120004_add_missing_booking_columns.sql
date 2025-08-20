-- Add missing columns to bookings table
-- Migration: 20240806120004_add_missing_booking_columns.sql

-- Add new columns to bookings table
ALTER TABLE public.bookings 
ADD COLUMN IF NOT EXISTS recurring_series_id UUID,
ADD COLUMN IF NOT EXISTS occurrence_number INTEGER,
ADD COLUMN IF NOT EXISTS is_recurring BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN IF NOT EXISTS selected_menu_id UUID;

-- Add constraints for the new columns
ALTER TABLE public.bookings 
ADD CONSTRAINT bookings_occurrence_number_positive 
CHECK (occurrence_number IS NULL OR occurrence_number > 0);

-- Add foreign key constraints
ALTER TABLE public.bookings
ADD CONSTRAINT bookings_recurring_series_id_fkey 
FOREIGN KEY (recurring_series_id) REFERENCES public.booking_series(id) ON DELETE SET NULL;

ALTER TABLE public.bookings
ADD CONSTRAINT bookings_selected_menu_id_fkey 
FOREIGN KEY (selected_menu_id) REFERENCES public.menus(id) ON DELETE SET NULL;

-- Create indexes for the new columns
CREATE INDEX idx_bookings_recurring_series_id ON public.bookings(recurring_series_id);
CREATE INDEX idx_bookings_is_recurring ON public.bookings(is_recurring) WHERE is_recurring = true;
CREATE INDEX idx_bookings_occurrence_number ON public.bookings(occurrence_number);
CREATE INDEX idx_bookings_selected_menu_id ON public.bookings(selected_menu_id);

-- Create composite index for recurring bookings
CREATE INDEX idx_bookings_series_occurrence 
    ON public.bookings(recurring_series_id, occurrence_number)
    WHERE recurring_series_id IS NOT NULL;

-- Create constraint to ensure recurring bookings have proper data
ALTER TABLE public.bookings 
ADD CONSTRAINT bookings_recurring_data_consistency 
CHECK (
    (is_recurring = false AND recurring_series_id IS NULL AND occurrence_number IS NULL) OR
    (is_recurring = true AND recurring_series_id IS NOT NULL AND occurrence_number IS NOT NULL)
);

-- Add check constraint to ensure selected_menu_id belongs to the assigned chef
-- This will be enforced via application logic and triggers rather than FK constraint
-- to allow for cross-chef menu selection in special cases

-- Create function to validate menu ownership for bookings
CREATE OR REPLACE FUNCTION validate_booking_menu_ownership()
RETURNS TRIGGER AS $$
BEGIN
    -- If selected_menu_id is set, validate it belongs to the chef or is a shared menu
    IF NEW.selected_menu_id IS NOT NULL AND NEW.chef_id IS NOT NULL THEN
        -- Check if menu belongs to the chef or is marked as shared/public
        IF NOT EXISTS (
            SELECT 1 FROM public.menus 
            WHERE id = NEW.selected_menu_id 
            AND (chef_id = NEW.chef_id OR chef_id IS NULL) -- NULL chef_id indicates shared menu
            AND is_active = true
        ) THEN
            RAISE EXCEPTION 'Selected menu must belong to the assigned chef or be a shared menu';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to validate menu ownership
CREATE TRIGGER validate_booking_menu_ownership_trigger
    BEFORE INSERT OR UPDATE ON public.bookings
    FOR EACH ROW
    EXECUTE FUNCTION validate_booking_menu_ownership();

-- Create function to update booking series statistics
CREATE OR REPLACE FUNCTION update_booking_series_stats()
RETURNS TRIGGER AS $$
DECLARE
    series_id UUID;
BEGIN
    -- Determine which series to update
    IF TG_OP = 'DELETE' THEN
        series_id := OLD.recurring_series_id;
    ELSE
        series_id := NEW.recurring_series_id;
    END IF;
    
    -- Skip if no series involved
    IF series_id IS NULL THEN
        RETURN COALESCE(NEW, OLD);
    END IF;
    
    -- Update series statistics
    UPDATE public.booking_series
    SET 
        total_occurrences = (
            SELECT COUNT(*) 
            FROM public.bookings 
            WHERE recurring_series_id = series_id
        ),
        completed_occurrences = (
            SELECT COUNT(*) 
            FROM public.bookings 
            WHERE recurring_series_id = series_id 
            AND status = 'completed'
        ),
        cancelled_occurrences = (
            SELECT COUNT(*) 
            FROM public.bookings 
            WHERE recurring_series_id = series_id 
            AND status = 'cancelled'
        ),
        updated_at = timezone('utc', now())
    WHERE id = series_id;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ language 'plpgsql';

-- Create triggers to maintain booking series statistics
CREATE TRIGGER update_booking_series_stats_insert
    AFTER INSERT ON public.bookings
    FOR EACH ROW
    WHEN (NEW.recurring_series_id IS NOT NULL)
    EXECUTE FUNCTION update_booking_series_stats();

CREATE TRIGGER update_booking_series_stats_update
    AFTER UPDATE ON public.bookings
    FOR EACH ROW
    WHEN (NEW.recurring_series_id IS NOT NULL OR OLD.recurring_series_id IS NOT NULL)
    EXECUTE FUNCTION update_booking_series_stats();

CREATE TRIGGER update_booking_series_stats_delete
    AFTER DELETE ON public.bookings
    FOR EACH ROW
    WHEN (OLD.recurring_series_id IS NOT NULL)
    EXECUTE FUNCTION update_booking_series_stats();

-- Create view for recurring booking series with statistics
CREATE OR REPLACE VIEW booking_series_with_stats AS
SELECT 
    bs.*,
    (
        SELECT COUNT(*) 
        FROM public.bookings b 
        WHERE b.recurring_series_id = bs.id
    ) as actual_total_occurrences,
    (
        SELECT COUNT(*) 
        FROM public.bookings b 
        WHERE b.recurring_series_id = bs.id 
        AND b.status = 'completed'
    ) as actual_completed_occurrences,
    (
        SELECT COUNT(*) 
        FROM public.bookings b 
        WHERE b.recurring_series_id = bs.id 
        AND b.status = 'cancelled'
    ) as actual_cancelled_occurrences,
    (
        SELECT json_agg(
            json_build_object(
                'id', b.id,
                'date', b.date,
                'status', b.status,
                'occurrence_number', b.occurrence_number
            ) ORDER BY b.occurrence_number
        )
        FROM public.bookings b 
        WHERE b.recurring_series_id = bs.id
    ) as occurrences
FROM public.booking_series bs;

-- Grant access to the view
GRANT SELECT ON booking_series_with_stats TO authenticated;

COMMENT ON COLUMN public.bookings.recurring_series_id IS 'Foreign key to booking_series table for recurring bookings';
COMMENT ON COLUMN public.bookings.occurrence_number IS 'Sequential number of this booking within its recurring series (1-based)';
COMMENT ON COLUMN public.bookings.is_recurring IS 'Flag indicating if this booking is part of a recurring series';
COMMENT ON COLUMN public.bookings.selected_menu_id IS 'Primary menu selected for this booking (optional, can also use individual dishes)';

COMMENT ON VIEW booking_series_with_stats IS 'View combining booking series with real-time statistics and occurrence details';