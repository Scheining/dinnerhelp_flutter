# Payment Flow Implementation Plan: Authorization & Hold Pattern

## Overview
Implementing industry-standard payment flow where:
1. Payment is authorized first (funds held)
2. Booking is created only after successful authorization
3. Payment is captured at service completion or beforehand

## Current Issues Being Solved
- ❌ Double booking when multiple users try same slot
- ❌ Phantom bookings without payment
- ❌ Chef sees unconfirmed bookings
- ❌ Poor user experience with payment failures

## Implementation Phases

### Phase 1: Database Changes ✅ (Created)
**File:** `supabase/migrations/20250104_payment_reservation_system.sql`
- Adds reservation fields to payment_intents
- Creates active_booking_reservations view
- Adds helper functions for availability checking
- No breaking changes - all additions

### Phase 2: Update Edge Functions

#### 2.1 Modify create-payment-intent
```typescript
// Store booking details in payment_intent for later conversion
const { data: paymentIntentRecord } = await supabase
  .from('payment_intents')
  .insert({
    booking_id: null, // No booking yet!
    chef_stripe_account_id,
    stripe_payment_intent_id: paymentIntent.id,
    amount,
    service_fee_amount: applicationFeeAmount,
    vat_amount: vat_amount || 0,
    currency: 'DKK',
    status: paymentIntent.status,
    capture_method: 'manual', // Important!
    client_secret: paymentIntent.client_secret,
    // NEW FIELDS:
    reservation_expires_at: new Date(Date.now() + 15 * 60 * 1000), // 15 minutes
    reservation_status: 'active',
    booking_data: {
      user_id,
      chef_id,
      date,
      start_time,
      end_time,
      number_of_guests,
      total_amount,
      address,
      notes,
      platform_fee: serviceFeeAmount
    }
  })
```

#### 2.2 Create stripe-webhook handler
```typescript
// New Edge Function: handle-stripe-webhook
export async function handleStripeWebhook(req: Request) {
  const event = stripe.webhooks.constructEvent(...)
  
  switch(event.type) {
    case 'payment_intent.succeeded':
    case 'payment_intent.amount_capturable_updated':
      // Payment authorized - create booking
      const bookingId = await convertReservationToBooking(
        event.data.object.id
      )
      // Send confirmation notifications
      await sendBookingConfirmation(bookingId)
      break
      
    case 'payment_intent.canceled':
    case 'payment_intent.payment_failed':
      // Mark reservation as cancelled
      await cancelReservation(event.data.object.id)
      break
  }
}
```

### Phase 3: Update Availability Service

#### 3.1 Modify ChefAvailabilityService
```dart
// lib/services/chef_availability_service.dart
Future<AvailabilityCheckResult> _checkExistingBookings(...) async {
  // Check regular bookings
  final existingBookings = await _supabaseClient
    .from('bookings')
    .select()
    .eq('chef_id', chefId)
    .eq('date', date)
    .inFilter('status', ['pending', 'confirmed', 'in_progress']);
    
  // NEW: Also check active reservations
  final activeReservations = await _supabaseClient
    .from('active_booking_reservations')
    .select()
    .eq('chef_id', chefId)
    .eq('date', date);
    
  // Check both for conflicts...
}
```

### Phase 4: Update Flutter Payment Flow

#### 4.1 Modify payment_screen.dart
```dart
Future<void> _processPaymentWithStripe() async {
  // REMOVE: Creating booking before payment
  // DELETE these lines:
  // final bookingResponse = await _supabaseClient.from('bookings').insert({...})
  
  // Just check availability and create payment intent
  final availabilityCheck = await _availabilityService.checkAvailability(...)
  if (!availabilityCheck.isAvailable) {
    throw Exception(availabilityCheck.message)
  }
  
  // Create payment intent (which creates reservation)
  final clientSecret = await _stripeService.createPaymentIntent(
    // Pass all booking data to Edge Function
    bookingData: {
      'user_id': user.id,
      'chef_id': widget.chef.id,
      'date': bookingDate,
      'start_time': startTime,
      'end_time': endTime,
      'number_of_guests': guestCount,
      'total_amount': totalAmount,
      'address': address,
      'notes': specialRequests,
    }
  )
  
  // Present payment sheet
  await _stripeService.presentPaymentSheet()
  
  // No need to create booking here - webhook handles it!
  // Just navigate to success screen
}
```

### Phase 5: Add Cleanup Mechanism

#### 5.1 Edge Function for cleanup (if pg_cron not available)
```typescript
// Edge Function: cleanup-reservations
Deno.serve(async () => {
  // Run every 5 minutes via Supabase cron
  await supabase.rpc('cleanup_expired_reservations')
  return new Response('OK')
})
```

### Phase 6: Testing Strategy

#### 6.1 Test Cases
1. **Happy Path**
   - User books → Payment authorized → Booking created → Chef notified
   
2. **Payment Failure**
   - User books → Payment fails → No booking created → Slot available

3. **Timeout**
   - User starts payment → Abandons → Reservation expires after 15min → Slot available

4. **Double Booking Prevention**
   - User A starts payment → User B tries same slot → User B blocked
   - User A completes → Slot taken
   - User A abandons → After 15min User B can book

5. **Rollback Test**
   - If issues arise, call `rollback_reservation_system()`
   - All reservations cancelled, system reverts to old behavior

### Phase 7: Rollback Plan

If any issues occur:

1. **Quick Disable** (No code changes)
```sql
-- Disable reservation checking
UPDATE payment_intents SET reservation_status = 'cancelled' WHERE reservation_status = 'active';
```

2. **Revert Flutter Code** (if needed)
```bash
git revert [commit-hash]
```

3. **Keep Database Changes** 
- New columns don't affect old code
- Can re-enable later

## Migration Checklist

### Before Deployment
- [ ] Backup database
- [ ] Test in staging environment
- [ ] Review all Edge Functions
- [ ] Verify Stripe webhook endpoint configured
- [ ] Test payment flow end-to-end

### Deployment Steps
1. [ ] Apply database migration
2. [ ] Deploy Edge Functions (including webhook handler)
3. [ ] Deploy Flutter app update
4. [ ] Configure Stripe webhook in dashboard
5. [ ] Monitor for 24 hours

### Post-Deployment
- [ ] Monitor error logs
- [ ] Check reservation cleanup is working
- [ ] Verify bookings are being created via webhook
- [ ] Test rollback procedure once

## Benefits After Implementation

✅ **No Double Bookings** - Reservations block slots immediately
✅ **Clean Data** - Only paid bookings in database
✅ **Better UX** - Clear payment status to users
✅ **Industry Standard** - Same as Airbnb, Uber, Hotels
✅ **Automatic Cleanup** - Expired reservations removed
✅ **Easy Rollback** - Can disable without data loss

## Timeline Estimate

- Phase 1-2: 2 hours (Database + Edge Functions)
- Phase 3-4: 3 hours (Flutter Updates)
- Phase 5: 1 hour (Cleanup mechanism)
- Phase 6: 2 hours (Testing)
- **Total: ~8 hours** for complete implementation

## Key Files to Modify

1. `/supabase/migrations/20250104_payment_reservation_system.sql` ✅
2. `/supabase/functions/create-payment-intent/index.ts`
3. `/supabase/functions/handle-stripe-webhook/index.ts` (NEW)
4. `/lib/services/chef_availability_service.dart`
5. `/lib/screens/payment_screen.dart`
6. `/lib/services/stripe_service.dart`

## Success Metrics

- Zero double bookings
- Payment failures don't create bookings
- Abandoned payments free up slots within 15 minutes
- Chef only sees confirmed, paid bookings
- No increase in payment failures