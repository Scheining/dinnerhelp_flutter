# DinnerHelp Booking & Payment System Technical Documentation
## For React/TypeScript Web Platform Integration

This document provides comprehensive technical documentation of the booking and payment systems in the DinnerHelp Flutter app, designed to help the web platform team implement consistent functionality using React, Vite, and TypeScript.

---

## 1. System Architecture Overview

### 1.1 Core Components

```
┌─────────────────────────────────────────────────────────────┐
│                     BOOKING FLOW                             │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  User         Flutter App         Supabase        Stripe    │
│    │               │                  │              │       │
│    ├──[1.Search]──►│                  │              │       │
│    │               ├──[2.Check]──────►│              │       │
│    │               │  Availability    │              │       │
│    │               │                  │              │       │
│    ├──[3.Book]────►│                  │              │       │
│    │               ├──[4.Create]─────►│              │       │
│    │               │  Booking         │              │       │
│    │               │                  ├──[5.Intent]─►│       │
│    │               │                  │              │       │
│    ├──[6.Pay]─────►│                  │              │       │
│    │               ├──[7.Process]────────────────────►│      │
│    │               │                  │              │       │
│    │               │◄─[8.Confirm]────┤◄─────────────┤       │
│    │               │                  │              │       │
│    │◄──[9.Done]────┤                  │              │       │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Database Schema

#### Bookings Table
```sql
CREATE TABLE bookings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id),
  chef_id UUID REFERENCES chefs(id),
  date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  status TEXT NOT NULL, -- pending, confirmed, in_progress, completed, cancelled, disputed, refunded
  number_of_guests INTEGER NOT NULL,
  total_amount INTEGER NOT NULL, -- in øre (DKK cents)
  payment_status TEXT, -- pending, authorized, succeeded, failed, refunded, disputed
  tip_amount NUMERIC DEFAULT 0,
  platform_fee NUMERIC DEFAULT 0,
  stripe_payment_intent_id TEXT,
  address TEXT,
  notes TEXT,
  cancellation_reason TEXT,
  cancelled_at TIMESTAMPTZ,
  chef_review TEXT,
  user_review TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 1.3 Booking Status Flow

```
PENDING ──────► CONFIRMED ──────► IN_PROGRESS ──────► COMPLETED
   │                │                   │                 │
   │                │                   │                 │
   └──► CANCELLED   └──► CANCELLED     └──► DISPUTED     │
                                                          │
                                             REFUNDED ◄───┘
```

### 1.4 Payment Status Flow

```
PENDING ──────► AUTHORIZED ──────► SUCCEEDED
   │                │                  │
   │                │                  │
   └──► FAILED      └──► REFUNDED     └──► DISPUTED
```

---

## 2. Booking System Implementation

### 2.1 Creating a Booking

**Flutter Implementation:**
```dart
// BookingRepository.createBooking()
final response = await _supabaseClient
  .from('bookings')
  .insert({
    'chef_id': chefId,
    'user_id': userId,
    'date': dateTime.toIso8601String().split('T')[0],
    'start_time': '${dateTime.hour}:${dateTime.minute}',
    'end_time': '${(dateTime.hour + duration)}:${dateTime.minute}',
    'number_of_guests': guestCount,
    'total_amount': (totalAmount * 100).round(), // Convert to øre
    'status': 'pending',
    'payment_status': 'pending',
    'notes': notes,
    'address': address,
  })
  .select()
  .single();
```

**TypeScript/React Equivalent:**
```typescript
interface BookingRequest {
  chefId: string;
  userId: string;
  date: string; // YYYY-MM-DD
  startTime: string; // HH:MM
  endTime: string; // HH:MM
  numberOfGuests: number;
  totalAmount: number; // in øre
  address: string;
  notes?: string;
}

async function createBooking(booking: BookingRequest): Promise<Booking> {
  const { data, error } = await supabase
    .from('bookings')
    .insert({
      chef_id: booking.chefId,
      user_id: booking.userId,
      date: booking.date,
      start_time: booking.startTime,
      end_time: booking.endTime,
      number_of_guests: booking.numberOfGuests,
      total_amount: booking.totalAmount,
      status: 'pending',
      payment_status: 'pending',
      notes: booking.notes,
      address: booking.address,
    })
    .select()
    .single();
    
  if (error) throw error;
  return data;
}
```

### 2.2 Chef Availability Checking

**Flutter Implementation:**
```dart
// ChefAvailabilityService
Future<bool> isChefAvailable(String chefId, DateTime dateTime) async {
  // Check working hours
  final workingHours = await getWorkingHours(chefId, dateTime);
  if (!isWithinWorkingHours(dateTime, workingHours)) return false;
  
  // Check existing bookings
  final existingBookings = await getBookingsForDate(chefId, dateTime);
  if (hasConflict(dateTime, existingBookings)) return false;
  
  // Check time off
  final timeOff = await getTimeOff(chefId, dateTime);
  if (isOnTimeOff(dateTime, timeOff)) return false;
  
  return true;
}
```

**Database Tables for Availability:**
```sql
-- Chef working hours
CREATE TABLE chef_working_hours (
  id UUID PRIMARY KEY,
  chef_id UUID REFERENCES chefs(id),
  day_of_week INTEGER, -- 0-6 (Sunday-Saturday)
  start_time TIME,
  end_time TIME,
  is_active BOOLEAN DEFAULT true
);

-- Chef time off
CREATE TABLE chef_time_off (
  id UUID PRIMARY KEY,
  chef_id UUID REFERENCES chefs(id),
  start_date DATE,
  end_date DATE,
  reason TEXT
);

-- Chef schedule settings
CREATE TABLE chef_schedule_settings (
  chef_id UUID PRIMARY KEY REFERENCES chefs(id),
  min_advance_hours INTEGER DEFAULT 24,
  max_advance_days INTEGER DEFAULT 30,
  min_booking_hours INTEGER DEFAULT 2,
  max_booking_hours INTEGER DEFAULT 8
);
```

### 2.3 Price Calculation

**Flutter Implementation:**
```dart
class BookingPriceCalculator {
  double calculateTotal({
    required double hourlyRate,
    required int hours,
    required int guestCount,
  }) {
    final basePrice = hourlyRate * hours;
    final serviceFee = basePrice * 0.10; // 10% platform fee
    final subtotal = basePrice + serviceFee;
    final vat = subtotal * 0.25; // 25% Danish VAT
    
    return basePrice + serviceFee + vat;
  }
  
  // Holiday surcharges
  double applyHolidaySurcharge(double amount, DateTime date) {
    if (isNewYearsEve(date)) {
      return amount * 1.5; // 50% surcharge
    } else if (isBankHoliday(date)) {
      return amount * 1.25; // 25% surcharge
    }
    return amount;
  }
}
```

**TypeScript Equivalent:**
```typescript
interface PriceCalculation {
  basePrice: number;
  serviceFee: number;
  vat: number;
  total: number;
}

function calculateBookingPrice(
  hourlyRate: number,
  hours: number,
  guestCount: number,
  date: Date
): PriceCalculation {
  let basePrice = hourlyRate * hours;
  
  // Apply holiday surcharges
  if (isNewYearsEve(date)) {
    basePrice *= 1.5;
  } else if (isBankHoliday(date)) {
    basePrice *= 1.25;
  }
  
  const serviceFee = basePrice * 0.10;
  const subtotal = basePrice + serviceFee;
  const vat = subtotal * 0.25;
  
  return {
    basePrice,
    serviceFee,
    vat,
    total: basePrice + serviceFee + vat
  };
}
```

---

## 3. Payment System Integration

### 3.1 Stripe Architecture

```
┌────────────────────────────────────────────────────────────┐
│                   STRIPE PAYMENT FLOW                       │
├────────────────────────────────────────────────────────────┤
│                                                             │
│  1. CREATE INTENT                                          │
│     App ──► Edge Function ──► Stripe API                   │
│                │                                            │
│                └─► Create customer                         │
│                └─► Create payment intent                   │
│                └─► Return client secret                    │
│                                                             │
│  2. COLLECT PAYMENT                                        │
│     App ──► Stripe SDK ──► Stripe                         │
│                │                                            │
│                └─► Show payment sheet                      │
│                └─► Process card                            │
│                └─► Authorize payment                       │
│                                                             │
│  3. CAPTURE PAYMENT (on booking completion)                │
│     Database Trigger ──► Edge Function ──► Stripe          │
│                             │                              │
│                             └─► Capture authorized amount  │
│                             └─► Transfer to chef account   │
│                                                             │
└────────────────────────────────────────────────────────────┘
```

### 3.2 Payment Intent Creation

**Edge Function: create-payment-intent**
```javascript
export async function handler(req: Request) {
  const {
    amount,
    service_fee_amount,
    vat_amount,
    chef_stripe_account_id,
    booking_id,
    booking_data
  } = await req.json();
  
  // Get or create Stripe customer
  const customer = await getOrCreateStripeCustomer(userId);
  
  // Create payment intent with Stripe Connect
  const paymentIntent = await stripe.paymentIntents.create({
    amount: amount, // in øre
    currency: 'dkk',
    customer: customer.id,
    setup_future_usage: 'off_session',
    application_fee_amount: service_fee_amount,
    transfer_data: {
      destination: chef_stripe_account_id,
    },
    metadata: {
      booking_id: booking_id || 'pending',
      vat_amount: vat_amount.toString(),
    },
    capture_method: 'manual', // Authorize now, capture later
  });
  
  // Create ephemeral key for customer
  const ephemeralKey = await stripe.ephemeralKeys.create(
    { customer: customer.id },
    { apiVersion: '2023-10-16' }
  );
  
  // If booking_data provided, create booking
  if (booking_data && !booking_id) {
    const booking = await createBookingWithPaymentIntent(
      booking_data,
      paymentIntent.id
    );
    
    // Update payment intent with booking ID
    await stripe.paymentIntents.update(paymentIntent.id, {
      metadata: { ...paymentIntent.metadata, booking_id: booking.id }
    });
  }
  
  return new Response(JSON.stringify({
    client_secret: paymentIntent.client_secret,
    customer_id: customer.id,
    ephemeral_key: ephemeralKey.secret,
    payment_intent_id: paymentIntent.id,
  }), { status: 200 });
}
```

### 3.3 Flutter Payment Implementation

```dart
// StripeService
Future<Map<String, dynamic>> createPaymentIntent({
  required int amount,
  required int serviceFeeAmount,
  required int vatAmount,
  required String chefId,
  Map<String, dynamic>? bookingData,
}) async {
  // Get chef's Stripe account
  final chefResponse = await _supabaseClient
    .from('chefs')
    .select('stripe_account_id')
    .eq('id', chefId)
    .single();
    
  // Call Edge Function
  final response = await _supabaseClient.functions.invoke(
    'create-payment-intent',
    body: {
      'amount': amount,
      'service_fee_amount': serviceFeeAmount,
      'vat_amount': vatAmount,
      'chef_stripe_account_id': chefResponse['stripe_account_id'],
      'booking_data': bookingData,
    },
  );
  
  return response.data;
}

// Initialize payment sheet
await Stripe.instance.initPaymentSheet(
  paymentSheetParameters: SetupPaymentSheetParameters(
    paymentIntentClientSecret: clientSecret,
    merchantDisplayName: 'DinnerHelp',
    customerId: customerId,
    customerEphemeralKeySecret: ephemeralKey,
    style: ThemeMode.system,
    primaryButtonLabel: 'Betal', // Danish
  ),
);

// Present payment sheet
await Stripe.instance.presentPaymentSheet();
```

### 3.4 React/TypeScript Implementation

```typescript
// Install: npm install @stripe/stripe-js @stripe/react-stripe-js

import { loadStripe } from '@stripe/stripe-js';
import {
  Elements,
  PaymentElement,
  useStripe,
  useElements
} from '@stripe/react-stripe-js';

const stripePromise = loadStripe('pk_test_YOUR_KEY');

interface PaymentIntentResponse {
  clientSecret: string;
  customerId: string;
  ephemeralKey: string;
  paymentIntentId: string;
}

// Payment service
class PaymentService {
  async createPaymentIntent(
    booking: BookingData
  ): Promise<PaymentIntentResponse> {
    const { data, error } = await supabase.functions.invoke(
      'create-payment-intent',
      {
        body: {
          amount: booking.totalAmount,
          service_fee_amount: booking.serviceFee,
          vat_amount: booking.vat,
          chef_stripe_account_id: booking.chefStripeAccountId,
          booking_data: booking,
        },
      }
    );
    
    if (error) throw error;
    return data;
  }
}

// Payment component
function PaymentForm({ clientSecret }: { clientSecret: string }) {
  const stripe = useStripe();
  const elements = useElements();
  const [processing, setProcessing] = useState(false);
  
  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    
    if (!stripe || !elements) return;
    
    setProcessing(true);
    
    const result = await stripe.confirmPayment({
      elements,
      confirmParams: {
        return_url: `${window.location.origin}/booking-confirmation`,
      },
    });
    
    if (result.error) {
      console.error(result.error);
    }
    
    setProcessing(false);
  };
  
  return (
    <form onSubmit={handleSubmit}>
      <PaymentElement />
      <button disabled={!stripe || processing}>
        {processing ? 'Processing...' : 'Pay'}
      </button>
    </form>
  );
}

// Main booking checkout
function BookingCheckout({ booking }: { booking: BookingData }) {
  const [clientSecret, setClientSecret] = useState<string>();
  
  useEffect(() => {
    const paymentService = new PaymentService();
    paymentService
      .createPaymentIntent(booking)
      .then(response => setClientSecret(response.clientSecret));
  }, [booking]);
  
  if (!clientSecret) return <div>Loading...</div>;
  
  return (
    <Elements stripe={stripePromise} options={{ clientSecret }}>
      <PaymentForm clientSecret={clientSecret} />
    </Elements>
  );
}
```

---

## 4. Booking Status Management

### 4.1 Status Transition Triggers

| From Status | To Status | Trigger | Payment Action |
|------------|-----------|---------|----------------|
| pending | confirmed | Chef accepts | Authorize payment |
| confirmed | in_progress | Chef arrives | None |
| in_progress | completed | Service ends | Capture payment |
| any | cancelled | User/Chef cancels | Refund evaluation |
| completed | disputed | User disputes | Hold funds |

### 4.2 Database Triggers

```sql
-- Trigger for payment authorization on booking confirmation
CREATE OR REPLACE FUNCTION handle_booking_confirmation()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'confirmed' AND OLD.status = 'pending' THEN
    -- Call Edge Function to authorize payment
    PERFORM net.http_post(
      url := SUPABASE_URL || '/functions/v1/authorize-payment',
      headers := jsonb_build_object(
        'Authorization', 'Bearer ' || SUPABASE_SERVICE_KEY
      ),
      body := jsonb_build_object(
        'booking_id', NEW.id,
        'payment_intent_id', NEW.stripe_payment_intent_id
      )
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for payment capture on booking completion
CREATE OR REPLACE FUNCTION handle_booking_completion()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
    -- Call Edge Function to capture payment
    PERFORM net.http_post(
      url := SUPABASE_URL || '/functions/v1/capture-payment',
      headers := jsonb_build_object(
        'Authorization', 'Bearer ' || SUPABASE_SERVICE_KEY
      ),
      body := jsonb_build_object(
        'booking_id', NEW.id,
        'tip_amount', NEW.tip_amount
      )
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### 4.3 Real-time Status Updates

**Flutter Implementation:**
```dart
// Subscribe to booking status changes
final subscription = supabase
  .from('bookings')
  .stream(primaryKey: ['id'])
  .eq('id', bookingId)
  .listen((data) {
    final booking = Booking.fromJson(data.first);
    // Update UI based on new status
    handleStatusChange(booking.status);
  });
```

**React/TypeScript Implementation:**
```typescript
// Subscribe to booking updates
useEffect(() => {
  const subscription = supabase
    .channel(`booking:${bookingId}`)
    .on(
      'postgres_changes',
      {
        event: 'UPDATE',
        schema: 'public',
        table: 'bookings',
        filter: `id=eq.${bookingId}`,
      },
      (payload) => {
        const updatedBooking = payload.new as Booking;
        setBooking(updatedBooking);
        handleStatusChange(updatedBooking.status);
      }
    )
    .subscribe();
    
  return () => {
    subscription.unsubscribe();
  };
}, [bookingId]);
```

---

## 5. Cancellation & Refund Logic

### 5.1 Cancellation Policy

```typescript
interface CancellationPolicy {
  hoursBeforeBooking: number;
  refundPercentage: number;
}

const CANCELLATION_POLICIES: CancellationPolicy[] = [
  { hoursBeforeBooking: 48, refundPercentage: 100 }, // Full refund
  { hoursBeforeBooking: 24, refundPercentage: 50 },  // 50% refund
  { hoursBeforeBooking: 12, refundPercentage: 25 },  // 25% refund
  { hoursBeforeBooking: 0, refundPercentage: 0 },    // No refund
];

function calculateRefundAmount(
  booking: Booking,
  cancellationTime: Date
): number {
  const hoursUntilBooking = differenceInHours(
    booking.dateTime,
    cancellationTime
  );
  
  const policy = CANCELLATION_POLICIES.find(
    p => hoursUntilBooking >= p.hoursBeforeBooking
  );
  
  if (!policy) return 0;
  
  const refundableAmount = booking.totalAmount - booking.platformFee;
  return Math.round(refundableAmount * (policy.refundPercentage / 100));
}
```

### 5.2 Refund Edge Function

```javascript
// Edge Function: refund-payment
export async function handler(req: Request) {
  const { booking_id, amount, reason } = await req.json();
  
  // Get booking and payment details
  const { data: booking } = await supabase
    .from('bookings')
    .select('*, payment_intents(*)')
    .eq('id', booking_id)
    .single();
    
  // Calculate refund amount if not specified
  const refundAmount = amount || calculateRefundAmount(booking);
  
  // Create Stripe refund
  const refund = await stripe.refunds.create({
    payment_intent: booking.stripe_payment_intent_id,
    amount: refundAmount,
    reason: reason || 'requested_by_customer',
    refund_application_fee: true, // Also refund platform fee
    reverse_transfer: true, // Reverse transfer from chef
  });
  
  // Update booking status
  await supabase
    .from('bookings')
    .update({
      status: 'refunded',
      payment_status: 'refunded',
      refund_id: refund.id,
      refund_amount: refundAmount,
      refunded_at: new Date().toISOString(),
    })
    .eq('id', booking_id);
    
  return new Response(JSON.stringify({ refund }), { status: 200 });
}
```

---

## 6. Stripe Connect for Chef Payouts

### 6.1 Chef Onboarding Flow

```
1. Chef signs up
2. Create Stripe Connect account
3. Chef completes onboarding
4. Account verified
5. Ready to receive payments
```

**Edge Function: stripe-connect-account**
```javascript
export async function handler(req: Request) {
  const { chef_id } = await req.json();
  
  // Create Express account for chef
  const account = await stripe.accounts.create({
    type: 'express',
    country: 'DK',
    capabilities: {
      card_payments: { requested: true },
      transfers: { requested: true },
    },
    business_type: 'individual',
    business_profile: {
      mcc: '5812', // Eating places and restaurants
      product_description: 'Personal chef services',
    },
  });
  
  // Save account ID to database
  await supabase
    .from('chefs')
    .update({ stripe_account_id: account.id })
    .eq('id', chef_id);
    
  // Create onboarding link
  const accountLink = await stripe.accountLinks.create({
    account: account.id,
    refresh_url: `${FRONTEND_URL}/chef/stripe-refresh`,
    return_url: `${FRONTEND_URL}/chef/stripe-success`,
    type: 'account_onboarding',
  });
  
  return new Response(JSON.stringify({
    account_id: account.id,
    onboarding_url: accountLink.url,
  }), { status: 200 });
}
```

### 6.2 Payment Distribution

```
Total Payment: 1000 DKK
├── Base Amount: 800 DKK → Chef (80%)
├── Platform Fee: 100 DKK → Platform (10%)
└── VAT: 100 DKK → Tax Authority (10%)

With Stripe fees:
├── Payment Processing: ~2.9% + 1.80 DKK
└── Transfer Fee: 0.25% (for payouts)
```

---

## 7. Security & Compliance

### 7.1 PCI Compliance

- **Never store card details** - Use Stripe tokens
- **Use Stripe Elements/SDK** - Ensure PCI DSS compliance
- **HTTPS only** - All payment pages must use SSL
- **Tokenization** - Convert sensitive data to tokens

### 7.2 RLS Policies

```sql
-- Bookings RLS
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;

-- Users can view their own bookings
CREATE POLICY "Users can view own bookings"
  ON bookings FOR SELECT
  USING (auth.uid() = user_id);

-- Chefs can view their assigned bookings
CREATE POLICY "Chefs can view assigned bookings"
  ON bookings FOR SELECT
  USING (
    auth.uid() IN (
      SELECT id FROM chefs WHERE id = bookings.chef_id
    )
  );

-- Only users can create bookings
CREATE POLICY "Users can create bookings"
  ON bookings FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Status updates restricted
CREATE POLICY "Restricted status updates"
  ON bookings FOR UPDATE
  USING (
    auth.uid() = user_id OR
    auth.uid() IN (
      SELECT id FROM chefs WHERE id = bookings.chef_id
    )
  );
```

### 7.3 Data Protection

```typescript
// Never log sensitive data
function sanitizeBookingData(booking: any): any {
  const sanitized = { ...booking };
  delete sanitized.stripe_payment_intent_id;
  delete sanitized.customer_email;
  delete sanitized.phone_number;
  return sanitized;
}

// Encrypt sensitive fields
const encryptedFields = [
  'card_last4',
  'bank_account',
  'personal_id',
];
```

---

## 8. Web Platform Integration Guide

### 8.1 Required Environment Variables

```env
# Supabase
VITE_SUPABASE_URL=https://[project].supabase.co
VITE_SUPABASE_ANON_KEY=[anon-key]

# Stripe
VITE_STRIPE_PUBLISHABLE_KEY=pk_test_[key]
VITE_STRIPE_WEBHOOK_SECRET=[secret] # Server only
```

### 8.2 TypeScript Interfaces

```typescript
// types/booking.ts
export enum BookingStatus {
  PENDING = 'pending',
  CONFIRMED = 'confirmed',
  IN_PROGRESS = 'in_progress',
  COMPLETED = 'completed',
  CANCELLED = 'cancelled',
  DISPUTED = 'disputed',
  REFUNDED = 'refunded',
}

export enum PaymentStatus {
  PENDING = 'pending',
  AUTHORIZED = 'authorized',
  SUCCEEDED = 'succeeded',
  FAILED = 'failed',
  REFUNDED = 'refunded',
  DISPUTED = 'disputed',
}

export interface Booking {
  id: string;
  userId: string;
  chefId: string;
  date: string;
  startTime: string;
  endTime: string;
  status: BookingStatus;
  numberOfGuests: number;
  totalAmount: number; // in øre
  paymentStatus: PaymentStatus;
  tipAmount?: number;
  platformFee: number;
  stripePaymentIntentId?: string;
  address: string;
  notes?: string;
  cancellationReason?: string;
  cancelledAt?: string;
  createdAt: string;
  updatedAt: string;
}

export interface Chef {
  id: string;
  firstName: string;
  lastName: string;
  hourlyRate: number;
  profileImageUrl?: string;
  stripeAccountId?: string;
  isActive: boolean;
  bio?: string;
  cuisines: string[];
  languages: string[];
}
```

### 8.3 React Hooks

```typescript
// hooks/useBooking.ts
import { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabase';

export function useBooking(bookingId: string) {
  const [booking, setBooking] = useState<Booking | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);
  
  useEffect(() => {
    // Fetch initial booking
    fetchBooking();
    
    // Subscribe to updates
    const subscription = supabase
      .channel(`booking:${bookingId}`)
      .on('postgres_changes', {
        event: '*',
        schema: 'public',
        table: 'bookings',
        filter: `id=eq.${bookingId}`,
      }, handleBookingChange)
      .subscribe();
      
    return () => {
      subscription.unsubscribe();
    };
  }, [bookingId]);
  
  async function fetchBooking() {
    try {
      const { data, error } = await supabase
        .from('bookings')
        .select('*, chefs(*), profiles(*)')
        .eq('id', bookingId)
        .single();
        
      if (error) throw error;
      setBooking(data);
    } catch (err) {
      setError(err as Error);
    } finally {
      setLoading(false);
    }
  }
  
  function handleBookingChange(payload: any) {
    if (payload.eventType === 'UPDATE') {
      setBooking(payload.new);
    }
  }
  
  return { booking, loading, error, refetch: fetchBooking };
}
```

### 8.4 State Management (Zustand)

```typescript
// store/bookingStore.ts
import { create } from 'zustand';
import { supabase } from '@/lib/supabase';

interface BookingStore {
  currentBooking: Booking | null;
  bookings: Booking[];
  loading: boolean;
  error: Error | null;
  
  createBooking: (data: BookingRequest) => Promise<Booking>;
  updateBookingStatus: (id: string, status: BookingStatus) => Promise<void>;
  cancelBooking: (id: string, reason?: string) => Promise<void>;
  fetchUserBookings: () => Promise<void>;
}

export const useBookingStore = create<BookingStore>((set, get) => ({
  currentBooking: null,
  bookings: [],
  loading: false,
  error: null,
  
  createBooking: async (data) => {
    set({ loading: true, error: null });
    try {
      const { data: booking, error } = await supabase
        .from('bookings')
        .insert(data)
        .select()
        .single();
        
      if (error) throw error;
      
      set(state => ({
        bookings: [...state.bookings, booking],
        currentBooking: booking,
        loading: false,
      }));
      
      return booking;
    } catch (error) {
      set({ error: error as Error, loading: false });
      throw error;
    }
  },
  
  updateBookingStatus: async (id, status) => {
    const { error } = await supabase
      .from('bookings')
      .update({ status, updated_at: new Date().toISOString() })
      .eq('id', id);
      
    if (error) throw error;
    
    set(state => ({
      bookings: state.bookings.map(b =>
        b.id === id ? { ...b, status } : b
      ),
    }));
  },
  
  // ... other methods
}));
```

---

## 9. Testing Considerations

### 9.1 Test Cards (Stripe Test Mode)

```
Success: 4242 4242 4242 4242
Decline: 4000 0000 0000 0002
Requires Auth: 4000 0025 0000 3155
Danish Card: 4571 0000 0000 0001
```

### 9.2 Test Scenarios

1. **Happy Path**
   - Create booking → Payment authorized → Chef confirms → Service completed → Payment captured

2. **Cancellation Flow**
   - Create booking → Payment authorized → User cancels → Refund processed

3. **Dispute Flow**
   - Booking completed → Payment captured → User disputes → Investigation → Resolution

4. **Failed Payment**
   - Create booking → Payment fails → Retry payment → Success

### 9.3 Integration Tests

```typescript
// __tests__/booking.test.ts
import { createBooking, processPayment } from '@/services/booking';

describe('Booking Flow', () => {
  it('should create booking and process payment', async () => {
    // Create test booking
    const booking = await createBooking({
      chefId: 'test-chef-id',
      date: '2024-12-25',
      startTime: '18:00',
      endTime: '21:00',
      numberOfGuests: 4,
      address: 'Test Address 123',
    });
    
    expect(booking.status).toBe('pending');
    expect(booking.paymentStatus).toBe('pending');
    
    // Process payment
    const payment = await processPayment(booking.id, {
      paymentMethodId: 'pm_card_visa',
    });
    
    expect(payment.status).toBe('authorized');
    
    // Verify booking updated
    const updatedBooking = await getBooking(booking.id);
    expect(updatedBooking.paymentStatus).toBe('authorized');
  });
});
```

---

## 10. Monitoring & Analytics

### 10.1 Key Metrics

```sql
-- Booking conversion rate
SELECT 
  COUNT(*) FILTER (WHERE status = 'completed') * 100.0 / 
  COUNT(*) as conversion_rate
FROM bookings
WHERE created_at > NOW() - INTERVAL '30 days';

-- Average booking value
SELECT 
  AVG(total_amount / 100.0) as avg_booking_value_dkk,
  AVG(tip_amount / 100.0) as avg_tip_dkk
FROM bookings
WHERE status = 'completed';

-- Payment success rate
SELECT 
  COUNT(*) FILTER (WHERE payment_status = 'succeeded') * 100.0 / 
  COUNT(*) as payment_success_rate
FROM bookings
WHERE created_at > NOW() - INTERVAL '30 days';
```

### 10.2 Error Tracking

```typescript
// Error reporting service
class BookingErrorTracker {
  static logPaymentError(error: StripeError, context: any) {
    console.error('Payment Error:', {
      code: error.code,
      message: error.message,
      bookingId: context.bookingId,
      amount: context.amount,
      timestamp: new Date().toISOString(),
    });
    
    // Send to monitoring service (e.g., Sentry)
    Sentry.captureException(error, {
      tags: {
        component: 'payment',
        booking_id: context.bookingId,
      },
    });
  }
}
```

---

## Appendix A: Edge Functions Summary

| Function | Purpose | Trigger |
|----------|---------|---------|
| create-payment-intent | Creates Stripe payment intent | Manual - booking creation |
| authorize-payment | Authorizes payment | Database - status → confirmed |
| capture-payment | Captures authorized payment | Database - status → completed |
| refund-payment | Processes refund | Manual/Database - cancellation |
| stripe-connect-account | Creates chef Stripe account | Manual - chef onboarding |
| stripe-webhook | Handles Stripe webhooks | Webhook - Stripe events |
| calculate-final-amount | Adjusts for tips/actual time | Manual - booking completion |

---

## Appendix B: Database Functions

```sql
-- Calculate booking total with all fees
CREATE OR REPLACE FUNCTION calculate_booking_total(
  p_hourly_rate INTEGER,
  p_hours INTEGER,
  p_date DATE
) RETURNS TABLE (
  base_amount INTEGER,
  service_fee INTEGER,
  vat_amount INTEGER,
  total_amount INTEGER
) AS $$
DECLARE
  v_base_amount INTEGER;
  v_service_fee INTEGER;
  v_subtotal INTEGER;
  v_vat_amount INTEGER;
BEGIN
  -- Calculate base amount with holiday surcharge
  v_base_amount := p_hourly_rate * p_hours;
  
  -- Apply holiday surcharges
  IF EXTRACT(MONTH FROM p_date) = 12 AND EXTRACT(DAY FROM p_date) = 31 THEN
    v_base_amount := v_base_amount * 1.5; -- 50% New Year's Eve surcharge
  ELSIF is_bank_holiday(p_date) THEN
    v_base_amount := v_base_amount * 1.25; -- 25% bank holiday surcharge
  END IF;
  
  -- Calculate fees
  v_service_fee := v_base_amount * 0.10; -- 10% platform fee
  v_subtotal := v_base_amount + v_service_fee;
  v_vat_amount := v_subtotal * 0.25; -- 25% Danish VAT
  
  RETURN QUERY SELECT 
    v_base_amount,
    v_service_fee,
    v_vat_amount,
    v_base_amount + v_service_fee + v_vat_amount;
END;
$$ LANGUAGE plpgsql;
```

---

*Last Updated: Current as of codebase analysis*
*Version: 1.0*
*Target Audience: React/TypeScript Web Platform Development Team*