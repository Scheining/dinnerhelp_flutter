-- Create booking_menu_items table for menu-based bookings
-- Migration: 20240806120002_create_booking_menu_items_table.sql

-- Create booking_menu_items table
CREATE TABLE public.booking_menu_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Foreign key relationships
    booking_id UUID NOT NULL,
    menu_id UUID NOT NULL,
    
    -- Item details
    quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
    unit_price INTEGER NOT NULL CHECK (unit_price >= 0), -- Price in DKK (øre)
    total_price INTEGER GENERATED ALWAYS AS (quantity * unit_price) STORED,
    
    -- Additional information
    notes TEXT,
    special_requests TEXT,
    
    -- Menu customizations (stored as JSONB for flexibility)
    customizations JSONB DEFAULT '{}',
    
    -- Status and metadata
    is_confirmed BOOLEAN NOT NULL DEFAULT false,
    confirmed_at TIMESTAMPTZ,
    confirmed_by UUID, -- References profiles.id (chef who confirmed)
    
    -- Audit fields
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    
    -- Ensure unique menu per booking (prevent duplicates)
    UNIQUE(booking_id, menu_id)
);

-- Add foreign key constraints
ALTER TABLE public.booking_menu_items
    ADD CONSTRAINT booking_menu_items_booking_id_fkey 
    FOREIGN KEY (booking_id) REFERENCES public.bookings(id) ON DELETE CASCADE;

ALTER TABLE public.booking_menu_items
    ADD CONSTRAINT booking_menu_items_menu_id_fkey 
    FOREIGN KEY (menu_id) REFERENCES public.menus(id) ON DELETE CASCADE;

ALTER TABLE public.booking_menu_items
    ADD CONSTRAINT booking_menu_items_confirmed_by_fkey 
    FOREIGN KEY (confirmed_by) REFERENCES public.profiles(id) ON DELETE SET NULL;

-- Create indexes for performance
CREATE INDEX idx_booking_menu_items_booking_id ON public.booking_menu_items(booking_id);
CREATE INDEX idx_booking_menu_items_menu_id ON public.booking_menu_items(menu_id);
CREATE INDEX idx_booking_menu_items_confirmed ON public.booking_menu_items(is_confirmed);
CREATE INDEX idx_booking_menu_items_created_at ON public.booking_menu_items(created_at);

-- Create composite index for booking queries
CREATE INDEX idx_booking_menu_items_booking_confirmed 
    ON public.booking_menu_items(booking_id, is_confirmed);

-- Create trigger for updated_at
CREATE TRIGGER update_booking_menu_items_updated_at 
    BEFORE UPDATE ON public.booking_menu_items 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Create trigger to set confirmed_at when is_confirmed changes to true
CREATE OR REPLACE FUNCTION set_confirmed_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    -- Set confirmed_at when is_confirmed becomes true
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
    END IF;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER set_booking_menu_items_confirmed_timestamp 
    BEFORE UPDATE ON public.booking_menu_items 
    FOR EACH ROW 
    EXECUTE FUNCTION set_confirmed_timestamp();

-- Enable Row Level Security
ALTER TABLE public.booking_menu_items ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Users can view menu items for their bookings
CREATE POLICY "Users can view menu items for own bookings" ON public.booking_menu_items
    FOR SELECT USING (
        booking_id IN (
            SELECT id FROM public.bookings 
            WHERE user_id = auth.uid()
        )
    );

-- Chefs can view menu items for bookings assigned to them
CREATE POLICY "Chefs can view menu items for assigned bookings" ON public.booking_menu_items
    FOR SELECT USING (
        booking_id IN (
            SELECT b.id FROM public.bookings b
            INNER JOIN public.profiles p ON p.id = auth.uid()
            WHERE b.chef_id = auth.uid() AND p.is_chef = true
        )
    );

-- Users can add menu items to their bookings
CREATE POLICY "Users can add menu items to own bookings" ON public.booking_menu_items
    FOR INSERT WITH CHECK (
        booking_id IN (
            SELECT id FROM public.bookings 
            WHERE user_id = auth.uid()
        )
    );

-- Users can update menu items for their bookings (before confirmation)
CREATE POLICY "Users can update menu items for own bookings" ON public.booking_menu_items
    FOR UPDATE USING (
        booking_id IN (
            SELECT id FROM public.bookings 
            WHERE user_id = auth.uid()
        ) AND is_confirmed = false
    );

-- Chefs can update menu items for their bookings (confirmation and notes)
CREATE POLICY "Chefs can update menu items for assigned bookings" ON public.booking_menu_items
    FOR UPDATE USING (
        booking_id IN (
            SELECT b.id FROM public.bookings b
            INNER JOIN public.profiles p ON p.id = auth.uid()
            WHERE b.chef_id = auth.uid() AND p.is_chef = true
        )
    );

-- Users can delete menu items from their bookings (before confirmation)
CREATE POLICY "Users can delete menu items from own bookings" ON public.booking_menu_items
    FOR DELETE USING (
        booking_id IN (
            SELECT id FROM public.bookings 
            WHERE user_id = auth.uid()
        ) AND is_confirmed = false
    );

-- Admins can manage all booking menu items
CREATE POLICY "Admins can manage all booking menu items" ON public.booking_menu_items
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE id = auth.uid() AND is_admin = true
        )
    );

-- Create function to calculate total menu items amount for a booking
CREATE OR REPLACE FUNCTION get_booking_menu_items_total(booking_uuid UUID)
RETURNS INTEGER AS $$
BEGIN
    RETURN (
        SELECT COALESCE(SUM(total_price), 0)
        FROM public.booking_menu_items
        WHERE booking_id = booking_uuid AND is_confirmed = true
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission on the function
GRANT EXECUTE ON FUNCTION get_booking_menu_items_total(UUID) TO authenticated;

COMMENT ON TABLE public.booking_menu_items IS 'Junction table linking bookings to selected menus with pricing and customization details';
COMMENT ON COLUMN public.booking_menu_items.unit_price IS 'Price per menu in DKK (øre) - can differ from menu base price due to customizations';
COMMENT ON COLUMN public.booking_menu_items.total_price IS 'Computed total price (quantity × unit_price)';
COMMENT ON COLUMN public.booking_menu_items.customizations IS 'JSON object storing menu customizations and modifications';
COMMENT ON COLUMN public.booking_menu_items.is_confirmed IS 'Whether the chef has confirmed this menu item for the booking';
COMMENT ON FUNCTION get_booking_menu_items_total(UUID) IS 'Returns total amount of confirmed menu items for a booking';