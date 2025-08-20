-- Create booking_dish_items table for individual dish bookings
-- Migration: 20240806120003_create_booking_dish_items_table.sql

-- Create booking_dish_items table
CREATE TABLE public.booking_dish_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Foreign key relationships
    booking_id UUID NOT NULL,
    dish_id UUID NOT NULL,
    
    -- Item details
    quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
    unit_price INTEGER NOT NULL CHECK (unit_price >= 0), -- Price in DKK (øre)
    total_price INTEGER GENERATED ALWAYS AS (quantity * unit_price) STORED,
    
    -- Dish customizations and requests
    special_requests TEXT,
    dietary_modifications TEXT,
    spice_level TEXT CHECK (spice_level IN ('mild', 'medium', 'hot', 'extra_hot')),
    
    -- Preparation preferences (stored as JSONB for flexibility)
    preparation_notes JSONB DEFAULT '{}',
    ingredient_substitutions JSONB DEFAULT '{}', -- Track ingredient swaps
    
    -- Course information (if part of a structured meal)
    course_type TEXT CHECK (course_type IN ('appetizer', 'starter', 'main', 'side', 'dessert', 'beverage')),
    course_order INTEGER,
    
    -- Status and metadata
    is_confirmed BOOLEAN NOT NULL DEFAULT false,
    is_prepared BOOLEAN NOT NULL DEFAULT false,
    confirmed_at TIMESTAMPTZ,
    prepared_at TIMESTAMPTZ,
    confirmed_by UUID, -- References profiles.id (chef who confirmed)
    
    -- Special handling flags
    requires_special_preparation BOOLEAN NOT NULL DEFAULT false,
    estimated_prep_time_minutes INTEGER DEFAULT 0 CHECK (estimated_prep_time_minutes >= 0),
    
    -- Audit fields
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    
    -- Ensure unique dish per booking (prevent duplicates unless different customizations)
    UNIQUE(booking_id, dish_id, special_requests, dietary_modifications)
);

-- Add foreign key constraints
ALTER TABLE public.booking_dish_items
    ADD CONSTRAINT booking_dish_items_booking_id_fkey 
    FOREIGN KEY (booking_id) REFERENCES public.bookings(id) ON DELETE CASCADE;

ALTER TABLE public.booking_dish_items
    ADD CONSTRAINT booking_dish_items_dish_id_fkey 
    FOREIGN KEY (dish_id) REFERENCES public.dishes(id) ON DELETE CASCADE;

ALTER TABLE public.booking_dish_items
    ADD CONSTRAINT booking_dish_items_confirmed_by_fkey 
    FOREIGN KEY (confirmed_by) REFERENCES public.profiles(id) ON DELETE SET NULL;

-- Create indexes for performance
CREATE INDEX idx_booking_dish_items_booking_id ON public.booking_dish_items(booking_id);
CREATE INDEX idx_booking_dish_items_dish_id ON public.booking_dish_items(dish_id);
CREATE INDEX idx_booking_dish_items_confirmed ON public.booking_dish_items(is_confirmed);
CREATE INDEX idx_booking_dish_items_prepared ON public.booking_dish_items(is_prepared);
CREATE INDEX idx_booking_dish_items_course_type ON public.booking_dish_items(course_type);
CREATE INDEX idx_booking_dish_items_created_at ON public.booking_dish_items(created_at);

-- Create composite indexes for common queries
CREATE INDEX idx_booking_dish_items_booking_course 
    ON public.booking_dish_items(booking_id, course_type, course_order);

CREATE INDEX idx_booking_dish_items_booking_status 
    ON public.booking_dish_items(booking_id, is_confirmed, is_prepared);

CREATE INDEX idx_booking_dish_items_special_prep 
    ON public.booking_dish_items(requires_special_preparation) 
    WHERE requires_special_preparation = true;

-- Create trigger for updated_at
CREATE TRIGGER update_booking_dish_items_updated_at 
    BEFORE UPDATE ON public.booking_dish_items 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Create trigger to set confirmation and preparation timestamps
CREATE OR REPLACE FUNCTION set_dish_item_timestamps()
RETURNS TRIGGER AS $$
BEGIN
    -- Set confirmed_at when is_confirmed changes to true
    IF OLD.is_confirmed = false AND NEW.is_confirmed = true THEN
        NEW.confirmed_at = timezone('utc', now());
        
        -- Set confirmed_by to current user if not already set
        IF NEW.confirmed_by IS NULL THEN
            NEW.confirmed_by = auth.uid();
        END IF;
    END IF;
    
    -- Clear confirmed_at when is_confirmed becomes false
    IF OLD.is_confirmed = true AND NEW.is_confirmed = false THEN
        NEW.confirmed_at = NULL;
        NEW.confirmed_by = NULL;
        -- Also reset prepared status if unconfirming
        NEW.is_prepared = false;
        NEW.prepared_at = NULL;
    END IF;
    
    -- Set prepared_at when is_prepared changes to true
    IF OLD.is_prepared = false AND NEW.is_prepared = true THEN
        NEW.prepared_at = timezone('utc', now());
        -- Must be confirmed before it can be prepared
        IF NEW.is_confirmed = false THEN
            RAISE EXCEPTION 'Dish item must be confirmed before marking as prepared';
        END IF;
    END IF;
    
    -- Clear prepared_at when is_prepared becomes false
    IF OLD.is_prepared = true AND NEW.is_prepared = false THEN
        NEW.prepared_at = NULL;
    END IF;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER set_booking_dish_items_timestamps 
    BEFORE UPDATE ON public.booking_dish_items 
    FOR EACH ROW 
    EXECUTE FUNCTION set_dish_item_timestamps();

-- Enable Row Level Security
ALTER TABLE public.booking_dish_items ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Users can view dish items for their bookings
CREATE POLICY "Users can view dish items for own bookings" ON public.booking_dish_items
    FOR SELECT USING (
        booking_id IN (
            SELECT id FROM public.bookings 
            WHERE user_id = auth.uid()
        )
    );

-- Chefs can view dish items for bookings assigned to them
CREATE POLICY "Chefs can view dish items for assigned bookings" ON public.booking_dish_items
    FOR SELECT USING (
        booking_id IN (
            SELECT b.id FROM public.bookings b
            INNER JOIN public.profiles p ON p.id = auth.uid()
            WHERE b.chef_id = auth.uid() AND p.is_chef = true
        )
    );

-- Users can add dish items to their bookings
CREATE POLICY "Users can add dish items to own bookings" ON public.booking_dish_items
    FOR INSERT WITH CHECK (
        booking_id IN (
            SELECT id FROM public.bookings 
            WHERE user_id = auth.uid()
        )
    );

-- Users can update dish items for their bookings (before confirmation)
CREATE POLICY "Users can update dish items for own bookings" ON public.booking_dish_items
    FOR UPDATE USING (
        booking_id IN (
            SELECT id FROM public.bookings 
            WHERE user_id = auth.uid()
        ) AND is_confirmed = false
    );

-- Chefs can update dish items for their bookings (confirmation, preparation, and notes)
CREATE POLICY "Chefs can update dish items for assigned bookings" ON public.booking_dish_items
    FOR UPDATE USING (
        booking_id IN (
            SELECT b.id FROM public.bookings b
            INNER JOIN public.profiles p ON p.id = auth.uid()
            WHERE b.chef_id = auth.uid() AND p.is_chef = true
        )
    );

-- Users can delete dish items from their bookings (before confirmation)
CREATE POLICY "Users can delete dish items from own bookings" ON public.booking_dish_items
    FOR DELETE USING (
        booking_id IN (
            SELECT id FROM public.bookings 
            WHERE user_id = auth.uid()
        ) AND is_confirmed = false
    );

-- Admins can manage all booking dish items
CREATE POLICY "Admins can manage all booking dish items" ON public.booking_dish_items
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE id = auth.uid() AND is_admin = true
        )
    );

-- Create function to calculate total dish items amount for a booking
CREATE OR REPLACE FUNCTION get_booking_dish_items_total(booking_uuid UUID)
RETURNS INTEGER AS $$
BEGIN
    RETURN (
        SELECT COALESCE(SUM(total_price), 0)
        FROM public.booking_dish_items
        WHERE booking_id = booking_uuid AND is_confirmed = true
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to get preparation progress for a booking
CREATE OR REPLACE FUNCTION get_booking_preparation_progress(booking_uuid UUID)
RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    SELECT json_build_object(
        'total_items', COUNT(*),
        'confirmed_items', COUNT(*) FILTER (WHERE is_confirmed = true),
        'prepared_items', COUNT(*) FILTER (WHERE is_prepared = true),
        'special_prep_items', COUNT(*) FILTER (WHERE requires_special_preparation = true),
        'total_prep_time_minutes', COALESCE(SUM(estimated_prep_time_minutes), 0)
    )
    INTO result
    FROM public.booking_dish_items
    WHERE booking_id = booking_uuid;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permissions on the functions
GRANT EXECUTE ON FUNCTION get_booking_dish_items_total(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_booking_preparation_progress(UUID) TO authenticated;

COMMENT ON TABLE public.booking_dish_items IS 'Junction table linking bookings to individual dishes with detailed customization and preparation tracking';
COMMENT ON COLUMN public.booking_dish_items.unit_price IS 'Price per dish in DKK (øre) - can differ from dish base price due to customizations';
COMMENT ON COLUMN public.booking_dish_items.total_price IS 'Computed total price (quantity × unit_price)';
COMMENT ON COLUMN public.booking_dish_items.preparation_notes IS 'JSON object storing chef preparation instructions and notes';
COMMENT ON COLUMN public.booking_dish_items.ingredient_substitutions IS 'JSON object tracking ingredient substitutions (allergies, preferences)';
COMMENT ON COLUMN public.booking_dish_items.course_type IS 'Type of course this dish represents in the meal structure';
COMMENT ON COLUMN public.booking_dish_items.course_order IS 'Order of this dish within its course type';
COMMENT ON COLUMN public.booking_dish_items.requires_special_preparation IS 'Flag indicating if dish needs special handling or preparation';
COMMENT ON FUNCTION get_booking_dish_items_total(UUID) IS 'Returns total amount of confirmed dish items for a booking';
COMMENT ON FUNCTION get_booking_preparation_progress(UUID) IS 'Returns JSON with preparation progress statistics for a booking';