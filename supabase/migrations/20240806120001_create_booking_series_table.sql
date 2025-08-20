-- Create booking_series table for recurring bookings
-- Migration: 20240806120001_create_booking_series_table.sql

-- Create ENUM for recurrence patterns
CREATE TYPE recurrence_pattern AS ENUM ('weekly', 'bi_weekly', 'every_3_weeks', 'monthly');

-- Create booking_series table
CREATE TABLE public.booking_series (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Basic information
    title TEXT NOT NULL,
    description TEXT,
    
    -- Recurrence configuration
    pattern recurrence_pattern NOT NULL,
    interval_value INTEGER NOT NULL DEFAULT 1 CHECK (interval_value > 0),
    
    -- Date range constraints (max 6 months advance)
    start_date DATE NOT NULL,
    end_date DATE,
    max_occurrences INTEGER CHECK (max_occurrences > 0),
    
    -- Booking template information
    chef_id UUID NOT NULL,
    user_id UUID NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    number_of_guests INTEGER NOT NULL CHECK (number_of_guests > 0),
    selected_menu_id UUID,
    
    -- Pricing (can be overridden per occurrence)
    base_amount INTEGER NOT NULL CHECK (base_amount >= 0),
    
    -- Series status and metadata
    is_active BOOLEAN NOT NULL DEFAULT true,
    total_occurrences INTEGER DEFAULT 0,
    completed_occurrences INTEGER DEFAULT 0,
    cancelled_occurrences INTEGER DEFAULT 0,
    
    -- Audit fields
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    
    -- Constraints
    CONSTRAINT valid_date_range CHECK (end_date IS NULL OR end_date >= start_date),
    CONSTRAINT valid_time_range CHECK (end_time > start_time),
    CONSTRAINT max_6_months_advance CHECK (
        start_date <= CURRENT_DATE + INTERVAL '6 months'
    ),
    CONSTRAINT valid_occurrence_counts CHECK (
        completed_occurrences >= 0 AND 
        cancelled_occurrences >= 0 AND
        (completed_occurrences + cancelled_occurrences) <= total_occurrences
    )
);

-- Add foreign key constraints
ALTER TABLE public.booking_series
    ADD CONSTRAINT booking_series_chef_id_fkey 
    FOREIGN KEY (chef_id) REFERENCES public.chefs(id) ON DELETE CASCADE;

ALTER TABLE public.booking_series
    ADD CONSTRAINT booking_series_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

ALTER TABLE public.booking_series
    ADD CONSTRAINT booking_series_selected_menu_id_fkey 
    FOREIGN KEY (selected_menu_id) REFERENCES public.menus(id) ON DELETE SET NULL;

-- Create indexes for performance
CREATE INDEX idx_booking_series_chef_id ON public.booking_series(chef_id);
CREATE INDEX idx_booking_series_user_id ON public.booking_series(user_id);
CREATE INDEX idx_booking_series_start_date ON public.booking_series(start_date);
CREATE INDEX idx_booking_series_pattern ON public.booking_series(pattern);
CREATE INDEX idx_booking_series_active ON public.booking_series(is_active) WHERE is_active = true;

-- Create composite index for user's active series
CREATE INDEX idx_booking_series_user_active 
    ON public.booking_series(user_id, is_active) 
    WHERE is_active = true;

-- Create trigger for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc', now());
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_booking_series_updated_at 
    BEFORE UPDATE ON public.booking_series 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security
ALTER TABLE public.booking_series ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Users can view their own booking series
CREATE POLICY "Users can view own booking series" ON public.booking_series
    FOR SELECT USING (
        auth.uid()::text = user_id::text
    );

-- Chefs can view booking series assigned to them
CREATE POLICY "Chefs can view assigned booking series" ON public.booking_series
    FOR SELECT USING (
        auth.uid()::text IN (
            SELECT p.id::text 
            FROM public.profiles p 
            WHERE p.id = chef_id AND p.is_chef = true
        )
    );

-- Users can create booking series
CREATE POLICY "Users can create booking series" ON public.booking_series
    FOR INSERT WITH CHECK (
        auth.uid()::text = user_id::text
    );

-- Users can update their own booking series (if not completed)
CREATE POLICY "Users can update own booking series" ON public.booking_series
    FOR UPDATE USING (
        auth.uid()::text = user_id::text AND
        is_active = true
    );

-- Chefs can update series assigned to them (limited fields)
CREATE POLICY "Chefs can update assigned booking series" ON public.booking_series
    FOR UPDATE USING (
        auth.uid()::text IN (
            SELECT p.id::text 
            FROM public.profiles p 
            WHERE p.id = chef_id AND p.is_chef = true
        )
    );

-- Only users can delete their own booking series
CREATE POLICY "Users can delete own booking series" ON public.booking_series
    FOR DELETE USING (
        auth.uid()::text = user_id::text
    );

-- Admins can view all booking series
CREATE POLICY "Admins can view all booking series" ON public.booking_series
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE id = auth.uid() AND is_admin = true
        )
    );

COMMENT ON TABLE public.booking_series IS 'Table for managing recurring booking patterns with support for weekly, bi-weekly, every 3 weeks, and monthly recurrence';
COMMENT ON COLUMN public.booking_series.pattern IS 'Recurrence pattern: weekly, bi_weekly, every_3_weeks, monthly';
COMMENT ON COLUMN public.booking_series.interval_value IS 'Interval multiplier for the pattern (e.g., every 2 weeks)';
COMMENT ON COLUMN public.booking_series.max_occurrences IS 'Maximum number of bookings to generate (optional limit)';
COMMENT ON COLUMN public.booking_series.base_amount IS 'Base amount in DKK that can be overridden per occurrence';