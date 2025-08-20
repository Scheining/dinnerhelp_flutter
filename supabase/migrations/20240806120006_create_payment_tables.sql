-- Create payment_intents table
CREATE TABLE payment_intents (
    id UUID PRIMARY KEY,
    booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    chef_stripe_account_id TEXT NOT NULL,
    stripe_payment_intent_id TEXT NOT NULL UNIQUE,
    amount INTEGER NOT NULL CHECK (amount > 0),
    service_fee_amount INTEGER NOT NULL DEFAULT 0,
    vat_amount INTEGER NOT NULL DEFAULT 0,
    currency TEXT NOT NULL DEFAULT 'DKK',
    status TEXT NOT NULL CHECK (status IN (
        'requires_payment_method',
        'requires_confirmation', 
        'requires_action',
        'processing',
        'requires_capture',
        'succeeded',
        'canceled'
    )),
    capture_method TEXT NOT NULL CHECK (capture_method IN ('automatic', 'manual')),
    payment_method_id TEXT,
    client_secret TEXT,
    last_payment_error TEXT,
    authorized_at TIMESTAMPTZ,
    captured_at TIMESTAMPTZ,
    cancelled_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ DEFAULT timezone('utc', now())
);

-- Create indexes for payment_intents
CREATE INDEX idx_payment_intents_booking_id ON payment_intents(booking_id);
CREATE INDEX idx_payment_intents_status ON payment_intents(status);
CREATE INDEX idx_payment_intents_stripe_id ON payment_intents(stripe_payment_intent_id);

-- Create payment_methods table
CREATE TABLE payment_methods (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    stripe_payment_method_id TEXT NOT NULL UNIQUE,
    type TEXT NOT NULL CHECK (type IN ('card', 'mobilepay', 'bank_transfer', 'apple_pay', 'google_pay')),
    last4 TEXT NOT NULL,
    brand TEXT NOT NULL,
    exp_month INTEGER NOT NULL CHECK (exp_month >= 1 AND exp_month <= 12),
    exp_year INTEGER NOT NULL CHECK (exp_year >= 2024),
    holder_name TEXT,
    is_default BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- Create indexes for payment_methods
CREATE INDEX idx_payment_methods_user_id ON payment_methods(user_id);
CREATE INDEX idx_payment_methods_stripe_id ON payment_methods(stripe_payment_method_id);

-- Create refunds table
CREATE TABLE refunds (
    id TEXT PRIMARY KEY,
    payment_intent_id UUID NOT NULL REFERENCES payment_intents(id) ON DELETE CASCADE,
    booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    amount INTEGER NOT NULL CHECK (amount > 0),
    fee_amount INTEGER NOT NULL DEFAULT 0,
    currency TEXT NOT NULL DEFAULT 'DKK',
    status TEXT NOT NULL CHECK (status IN ('pending', 'succeeded', 'failed', 'canceled', 'requires_action')),
    reason TEXT NOT NULL CHECK (reason IN (
        'duplicate',
        'fraudulent',
        'requested_by_customer',
        'chef_cancellation',
        'system_error',
        'no_show',
        'unsatisfactory'
    )),
    description TEXT,
    failure_reason TEXT,
    processed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- Create indexes for refunds
CREATE INDEX idx_refunds_payment_intent_id ON refunds(payment_intent_id);
CREATE INDEX idx_refunds_booking_id ON refunds(booking_id);
CREATE INDEX idx_refunds_status ON refunds(status);

-- Create disputes table
CREATE TABLE disputes (
    id TEXT PRIMARY KEY,
    payment_intent_id UUID NOT NULL REFERENCES payment_intents(id) ON DELETE CASCADE,
    booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    amount INTEGER NOT NULL CHECK (amount > 0),
    currency TEXT NOT NULL DEFAULT 'DKK',
    status TEXT NOT NULL CHECK (status IN (
        'needs_response',
        'under_review',
        'charge_refunded',
        'lost',
        'won',
        'accepted'
    )),
    reason TEXT NOT NULL CHECK (reason IN (
        'duplicate',
        'fraudulent',
        'subscription_canceled',
        'product_unacceptable',
        'product_not_received',
        'unrecognized',
        'credit_not_processed',
        'general',
        'incorrect_account_details',
        'insufficient_funds',
        'bank_cannot_process',
        'debit_not_authorized',
        'customer_initiated'
    )),
    description TEXT,
    evidence_details TEXT,
    respond_by_date TIMESTAMPTZ,
    resolved_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ DEFAULT timezone('utc', now())
);

-- Create indexes for disputes
CREATE INDEX idx_disputes_payment_intent_id ON disputes(payment_intent_id);
CREATE INDEX idx_disputes_booking_id ON disputes(booking_id);
CREATE INDEX idx_disputes_status ON disputes(status);

-- Create chef_payouts table
CREATE TABLE chef_payouts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    chef_id UUID NOT NULL REFERENCES chefs(id) ON DELETE CASCADE,
    booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    payment_intent_id UUID NOT NULL REFERENCES payment_intents(id) ON DELETE CASCADE,
    amount INTEGER NOT NULL CHECK (amount > 0),
    status TEXT NOT NULL CHECK (status IN ('pending', 'processing', 'paid', 'failed')),
    payout_date TIMESTAMPTZ,
    stripe_payout_id TEXT,
    failure_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ DEFAULT timezone('utc', now())
);

-- Create indexes for chef_payouts
CREATE INDEX idx_chef_payouts_chef_id ON chef_payouts(chef_id);
CREATE INDEX idx_chef_payouts_booking_id ON chef_payouts(booking_id);
CREATE INDEX idx_chef_payouts_status ON chef_payouts(status);

-- Create chef_payout_deductions table
CREATE TABLE chef_payout_deductions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    payout_id UUID NOT NULL REFERENCES chef_payouts(id) ON DELETE CASCADE,
    amount INTEGER NOT NULL CHECK (amount > 0),
    reason TEXT NOT NULL CHECK (reason IN ('refund', 'dispute', 'chargeback', 'fee')),
    refund_id TEXT REFERENCES refunds(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- Create indexes for chef_payout_deductions
CREATE INDEX idx_chef_payout_deductions_payout_id ON chef_payout_deductions(payout_id);

-- Add payment-related columns to bookings table if they don't exist
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='bookings' AND column_name='payment_status') THEN
        ALTER TABLE bookings ADD COLUMN payment_status TEXT CHECK (payment_status IN (
            'pending',
            'authorized', 
            'succeeded',
            'failed',
            'refunded',
            'partially_refunded',
            'disputed'
        )) DEFAULT 'pending';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='bookings' AND column_name='stripe_payment_intent_id') THEN
        ALTER TABLE bookings ADD COLUMN stripe_payment_intent_id TEXT;
    END IF;
END $$;

-- Create updated_at trigger function if it doesn't exist
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc', now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add updated_at triggers
CREATE TRIGGER update_payment_intents_updated_at
    BEFORE UPDATE ON payment_intents
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_disputes_updated_at
    BEFORE UPDATE ON disputes
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_chef_payouts_updated_at
    BEFORE UPDATE ON chef_payouts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Enable RLS on all payment tables
ALTER TABLE payment_intents ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_methods ENABLE ROW LEVEL SECURITY;
ALTER TABLE refunds ENABLE ROW LEVEL SECURITY;
ALTER TABLE disputes ENABLE ROW LEVEL SECURITY;
ALTER TABLE chef_payouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE chef_payout_deductions ENABLE ROW LEVEL SECURITY;

-- RLS policies for payment_intents
CREATE POLICY "Users can view their own payment intents" ON payment_intents
    FOR SELECT USING (
        booking_id IN (
            SELECT id FROM bookings WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Chefs can view their booking payment intents" ON payment_intents
    FOR SELECT USING (
        booking_id IN (
            SELECT id FROM bookings WHERE chef_id IN (
                SELECT id FROM chefs WHERE id = (
                    SELECT id FROM profiles WHERE id = auth.uid() AND is_chef = true
                )
            )
        )
    );

-- RLS policies for payment_methods
CREATE POLICY "Users can manage their own payment methods" ON payment_methods
    FOR ALL USING (user_id = auth.uid());

-- RLS policies for refunds
CREATE POLICY "Users can view their booking refunds" ON refunds
    FOR SELECT USING (
        booking_id IN (
            SELECT id FROM bookings WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Chefs can view their booking refunds" ON refunds
    FOR SELECT USING (
        booking_id IN (
            SELECT id FROM bookings WHERE chef_id IN (
                SELECT id FROM chefs WHERE id = (
                    SELECT id FROM profiles WHERE id = auth.uid() AND is_chef = true
                )
            )
        )
    );

-- RLS policies for disputes
CREATE POLICY "Users can view their booking disputes" ON disputes
    FOR SELECT USING (
        booking_id IN (
            SELECT id FROM bookings WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Chefs can view their booking disputes" ON disputes
    FOR SELECT USING (
        booking_id IN (
            SELECT id FROM bookings WHERE chef_id IN (
                SELECT id FROM chefs WHERE id = (
                    SELECT id FROM profiles WHERE id = auth.uid() AND is_chef = true
                )
            )
        )
    );

-- RLS policies for chef_payouts
CREATE POLICY "Chefs can view their own payouts" ON chef_payouts
    FOR SELECT USING (
        chef_id = (
            SELECT id FROM chefs WHERE id = (
                SELECT id FROM profiles WHERE id = auth.uid() AND is_chef = true
            )
        )
    );

-- RLS policies for chef_payout_deductions
CREATE POLICY "Chefs can view their payout deductions" ON chef_payout_deductions
    FOR SELECT USING (
        payout_id IN (
            SELECT id FROM chef_payouts WHERE chef_id = (
                SELECT id FROM chefs WHERE id = (
                    SELECT id FROM profiles WHERE id = auth.uid() AND is_chef = true
                )
            )
        )
    );

-- Grant necessary permissions
GRANT SELECT, INSERT, UPDATE ON payment_intents TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON payment_methods TO authenticated;
GRANT SELECT ON refunds TO authenticated;
GRANT SELECT ON disputes TO authenticated;
GRANT SELECT ON chef_payouts TO authenticated;
GRANT SELECT ON chef_payout_deductions TO authenticated;