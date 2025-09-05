# DinnerHelp VAT and Fee Structure Documentation

**Last Updated:** January 2025  
**Version:** 1.0

## Overview

This document describes the complete VAT handling and fee structure implementation for the DinnerHelp platform. The system correctly handles Danish VAT (MOMS) requirements and implements a transparent fee structure that separates platform fees from chef commissions.

## Fee Structure

### User Perspective (What Users Pay)

Users see and pay the following fees on their receipts:

1. **Chef Service Amount** - The base cost for the chef's service
2. **Service Fee (5%)** - Platform fee paid to DinnerHelp
3. **Payment Processing Fee (~2.9% + 2.50 DKK)** - Stripe transaction costs
4. **VAT/MOMS (25%)** - ONLY if chef is VAT-registered (annual revenue >50,000 DKK)

### Chef Perspective (What Chefs Receive)

- **Gross Earnings:** Their advertised hourly rate × hours
- **Platform Commission:** -15% (paid to DinnerHelp)
- **Net Earnings:** 85% of their gross rate

**Important:** The 15% commission is NEVER shown to users - it's an internal fee between chef and platform.

### Platform Revenue Model

DinnerHelp earns revenue from two sources:
- **15% commission** from chef's earnings (chef-side)
- **5% service fee** from user's payment (user-side)
- **Total platform revenue:** ~20% of booking value

## VAT (MOMS) Implementation

### Danish VAT Requirements

- **Registration Threshold:** 50,000 DKK annual revenue
- **VAT Rate:** 25% (standard Danish rate)
- **Who Must Register:** Any business exceeding the threshold
- **CVR Number:** Required for VAT-registered businesses

### System Implementation

The system intelligently handles VAT based on chef registration status:

```
IF chef.is_vat_registered = TRUE:
  - Apply 25% VAT on service amount
  - Show VAT on receipts
  - Display CVR number
  
IF chef.is_vat_registered = FALSE:
  - No VAT charged
  - No VAT line on receipts
  - No CVR number displayed
```

## Money Flow Examples

### Example 1: VAT-Registered Chef (1000 DKK Service)

**User Pays:**
```
Service (3 timer):        1000.00 kr
Servicegebyr (5%):          50.00 kr
Betalingsgebyr:             30.48 kr
Moms (25%):                250.00 kr
────────────────────────────────────
TOTAL:                    1330.48 kr
```

**Distribution:**
- Chef receives: 850.00 kr (1000 - 15% commission)
- DinnerHelp receives: 200.00 kr (150 commission + 50 service fee)
- Tax authority: 250.00 kr (VAT)
- Stripe: ~30.48 kr (processing)

### Example 2: Non-VAT Registered Chef (1000 DKK Service)

**User Pays:**
```
Service (3 timer):        1000.00 kr
Servicegebyr (5%):          50.00 kr
Betalingsgebyr:             30.48 kr
────────────────────────────────────
TOTAL:                    1080.48 kr
```

**Distribution:**
- Chef receives: 850.00 kr (same as above)
- DinnerHelp receives: 200.00 kr (same as above)
- Stripe: ~30.48 kr (processing)
- No VAT collected

## Database Schema

### Chef Table Additions

```sql
-- VAT and business information
is_vat_registered BOOLEAN DEFAULT FALSE  -- Whether chef charges VAT
vat_number TEXT                          -- CVR number with MOMS status
vat_rate DECIMAL(5,4) DEFAULT 0.25      -- VAT rate (0.25 for Denmark)
business_type TEXT DEFAULT 'individual'  -- 'individual' or 'company'
commission_rate DECIMAL(5,4) DEFAULT 0.15 -- Platform commission (15%)
```

### Booking Table Additions

```sql
-- Detailed fee tracking
user_service_fee INTEGER DEFAULT 0       -- 5% service fee paid by user
payment_processing_fee INTEGER DEFAULT 0 -- Stripe processing fee
chef_commission_amount INTEGER DEFAULT 0 -- 15% commission from chef
```

## Technical Implementation

### Payment Flow

1. **Flutter App (payment_screen.dart):**
   - Calculates fees based on chef's VAT status
   - Shows transparent breakdown to user
   - Only displays user-facing fees

2. **Stripe Service (stripe_service.dart):**
   - Passes all fee parameters to Edge Function
   - Includes payment processing fee

3. **Edge Function (create-payment-intent):**
   - Fetches chef's VAT registration status
   - Calculates correct fee distribution
   - Creates Stripe payment intent with proper `application_fee_amount`
   - Stores detailed metadata for tracking

4. **Receipt Generation (send-receipt-email):**
   - Shows only user-visible fees
   - Includes VAT only if applicable
   - Displays CVR number for VAT-registered chefs

### Code Locations

- **Models:** `lib/models/chef.dart`
- **Payment UI:** `lib/screens/payment_screen.dart`
- **Stripe Integration:** `lib/services/stripe_service.dart`
- **Payment Processing:** `supabase/functions/create-payment-intent/index.ts`
- **Receipt Generation:** `supabase/functions/send-receipt-email/index.ts`
- **Database Migration:** Applied via Supabase migrations

## Stripe Connect Configuration

### Fee Structure with Stripe

- **Charge Type:** Destination charges
- **Application Fee:** Total platform revenue (15% + 5% = 20%)
- **Processing Fees:** Paid by platform, shown to user for transparency
- **No Double Charging:** Stripe doesn't charge fees on application_fee_amount

### Payment Intent Metadata

The system stores comprehensive metadata for each payment:
```javascript
{
  base_amount: 100000,        // Chef service in øre
  chef_commission: 15000,      // 15% to platform
  user_service_fee: 5000,       // 5% from user
  payment_processing_fee: 3048, // Stripe fees
  vat_amount: 25000,           // VAT if applicable
  vat_rate: 0.25,              // VAT rate
  is_vat_registered: true,     // Chef VAT status
  chef_payout: 85000,          // What chef receives
  platform_revenue: 20000      // Total platform earnings
}
```

## Receipt Design

### User Receipt Shows:

```
┌─────────────────────────────────────┐
│        [DinnerHelp Logo]            │
│           KVITTERING                 │
├─────────────────────────────────────┤
│ Booking ID: #XXXX-XXXX              │
│ Booket den: 10. januar 2025         │
├─────────────────────────────────────┤
│ KOK INFORMATION                     │
│ Navn: [Chef Name]                   │
│ CVR: [Number - if VAT registered]   │
├─────────────────────────────────────┤
│ BETALING                            │
│ Service (3 timer): 1000 kr          │
│ Servicegebyr (5%): 50 kr            │
│ Betalingsgebyr: 30.48 kr            │
│ [Moms (25%): 250 kr - if applicable]│
│ ─────────────────────               │
│ TOTAL: 1330.48 kr                   │
├─────────────────────────────────────┤
│ Support: hello@dinnerhelp.dk        │
│ CVR: 45721647                       │
└─────────────────────────────────────┘
```

**Note:** Chef's 15% commission is NEVER shown on user receipts.

## Business Rules

### VAT Registration

1. **Threshold Monitoring:** Chefs should register when annual revenue exceeds 50,000 DKK
2. **Default Status:** New chefs default to `is_vat_registered = false`
3. **CVR Requirement:** VAT-registered chefs must provide CVR number with MOMS status
4. **Rate Flexibility:** System supports different VAT rates for future expansion

### Commission Structure

1. **Chef Commission:** 15% of base service amount (configurable per chef)
2. **User Service Fee:** 5% added to user's payment
3. **Processing Fees:** Shown transparently to users
4. **Platform Revenue:** Combination of commission + service fee

## Migration Strategy

### For Existing Data

1. **Existing Chefs:** Default to `is_vat_registered = false`
2. **Notification Required:** Email chefs to update VAT status
3. **Backward Compatible:** Old bookings continue to work
4. **Gradual Rollout:** Can be enabled per chef

### Deployment Steps

1. Database migration applied ✅
2. Chef model updated ✅
3. Payment calculations updated ✅
4. Edge Functions deployed ✅
5. Receipt generation updated ✅

## Compliance Considerations

### Danish Tax Law

- ✅ Correctly applies VAT only when required
- ✅ Supports CVR number storage and display
- ✅ Tracks revenue for threshold monitoring
- ✅ Generates compliant receipts

### GDPR and Privacy

- ✅ Chef commission not exposed to users
- ✅ Personal contact info protected
- ✅ Only necessary financial data stored
- ✅ Audit trail for all transactions

## Future Enhancements

### Planned Features

1. **Automatic Threshold Monitoring**
   - Track chef's annual revenue
   - Alert when approaching 50,000 DKK
   - Automated VAT registration reminders

2. **CVR Validation**
   - Integration with Danish CVR registry
   - Automatic validation of VAT numbers
   - Real-time status updates

3. **Stripe Tax Integration**
   - Use Stripe's automatic tax calculation
   - Support for EU-wide operations
   - Automated tax reporting

4. **Dynamic Commission Rates**
   - Different rates for premium chefs
   - Volume-based discounts
   - Promotional periods

## Support and Maintenance

### Common Issues

**Q: Why isn't VAT showing on receipts?**
A: Check if chef's `is_vat_registered` flag is set to true in the database.

**Q: How to update chef's VAT status?**
A: Update the `chefs` table: `UPDATE chefs SET is_vat_registered = true, vat_number = 'CVR12345678' WHERE id = 'chef_id'`

**Q: What if Stripe fees change?**
A: Update the calculation in `payment_screen.dart` line 92: `paymentProcessingFee`

### Monitoring Queries

```sql
-- Check chef VAT status
SELECT id, is_vat_registered, vat_number, commission_rate 
FROM chefs 
WHERE id = 'chef_id';

-- View booking fees
SELECT id, total_amount, user_service_fee, chef_commission_amount, vat_amount 
FROM bookings 
WHERE id = 'booking_id';

-- Calculate platform revenue
SELECT 
  SUM(user_service_fee + chef_commission_amount) as total_revenue,
  SUM(user_service_fee) as service_fees,
  SUM(chef_commission_amount) as commissions
FROM bookings 
WHERE created_at >= '2025-01-01';
```

## Contact

For technical questions or issues:
- **Support Email:** hello@dinnerhelp.dk
- **Platform CVR:** 45721647

---

**Important:** This system ensures legal compliance with Danish VAT law while maintaining fee transparency and preventing double-charging. The 15% chef commission remains internal and is never exposed to end users.