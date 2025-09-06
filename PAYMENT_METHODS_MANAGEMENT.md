# Payment Methods Management System

## Overview
This document describes the complete Payment Methods Management system implemented for DinnerHelp, enabling users to securely save, manage, and use payment cards for bookings.

## System Architecture

### Key Features
- **Secure Card Storage**: PCI-compliant card tokenization using Stripe SetupIntent
- **Multiple Payment Methods**: Users can save multiple cards
- **Default Card Selection**: Set a preferred payment method
- **Card Management**: Add, remove, and update payment methods
- **Real-time Sync**: Automatic synchronization with Stripe
- **Card Nicknames**: Custom labels for easy identification

## Database Structure

### Tables

#### payment_methods
```sql
CREATE TABLE payment_methods (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id),
  stripe_payment_method_id TEXT NOT NULL UNIQUE,
  type TEXT NOT NULL,
  last4 TEXT NOT NULL,
  brand TEXT NOT NULL,
  exp_month INTEGER NOT NULL,
  exp_year INTEGER NOT NULL,
  holder_name TEXT,
  is_default BOOLEAN NOT NULL DEFAULT false,
  nickname TEXT,                           -- Custom card label
  stripe_fingerprint TEXT,                 -- For duplicate detection
  metadata JSONB DEFAULT '{}'::jsonb,      -- Additional card info
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT unique_user_card_fingerprint UNIQUE (user_id, stripe_fingerprint)
);
```

#### profiles (updated)
```sql
ALTER TABLE profiles 
ADD COLUMN stripe_customer_id TEXT UNIQUE;  -- Links user to Stripe Customer
```

### Row Level Security (RLS)
```sql
-- Users can only view their own payment methods
CREATE POLICY "Users can view their own payment methods" 
ON payment_methods FOR SELECT 
USING (auth.uid() = user_id);

-- Users can only insert their own payment methods
CREATE POLICY "Users can insert their own payment methods" 
ON payment_methods FOR INSERT 
WITH CHECK (auth.uid() = user_id);

-- Users can only update their own payment methods
CREATE POLICY "Users can update their own payment methods" 
ON payment_methods FOR UPDATE 
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Users can only delete their own payment methods
CREATE POLICY "Users can delete their own payment methods" 
ON payment_methods FOR DELETE 
USING (auth.uid() = user_id);
```

## Edge Functions

### 1. create-setup-intent
Creates a Stripe SetupIntent for saving a card without immediate payment.

**Endpoint**: `/create-setup-intent`
**Method**: POST
**Auth Required**: Yes

**Response**:
```json
{
  "client_secret": "seti_1abc..._secret_xyz",
  "customer_id": "cus_123456",
  "setup_intent_id": "seti_1abc..."
}
```

**Flow**:
1. Checks/creates Stripe Customer for user
2. Saves customer_id to profiles table
3. Creates SetupIntent for card saving
4. Returns client_secret for payment sheet

### 2. save-payment-method
Saves a payment method after successful SetupIntent confirmation.

**Endpoint**: `/save-payment-method`
**Method**: POST
**Auth Required**: Yes

**Body**:
```json
{
  "setup_intent_id": "seti_1abc...",
  "nickname": "Personal Card" // Optional
}
```

**Response**:
```json
{
  "success": true,
  "payment_method": {
    "id": "uuid",
    "stripe_payment_method_id": "pm_123",
    "last4": "4242",
    "brand": "visa",
    // ... other fields
  }
}
```

### 3. list-payment-methods
Retrieves all saved payment methods for the authenticated user.

**Endpoint**: `/list-payment-methods`
**Method**: GET
**Auth Required**: Yes

**Response**:
```json
{
  "payment_methods": [
    {
      "id": "uuid",
      "stripe_payment_method_id": "pm_123",
      "last4": "4242",
      "brand": "visa",
      "exp_month": 12,
      "exp_year": 2025,
      "is_default": true,
      "nickname": "Personal Card",
      // ... other fields
    }
  ]
}
```

**Features**:
- Syncs with Stripe to ensure data consistency
- Removes cards deleted from Stripe
- Updates card details from Stripe

### 4. delete-payment-method
Removes a saved payment method.

**Endpoint**: `/delete-payment-method`
**Method**: POST
**Auth Required**: Yes

**Body**:
```json
{
  "payment_method_id": "uuid"
}
```

**Features**:
- Detaches from Stripe
- Removes from database
- Automatically sets another card as default if needed

### 5. set-default-payment-method
Sets a payment method as the default for future transactions.

**Endpoint**: `/set-default-payment-method`
**Method**: POST
**Auth Required**: Yes

**Body**:
```json
{
  "payment_method_id": "uuid"
}
```

## Flutter Implementation

### File Structure
```
lib/features/payment/
├── domain/
│   ├── entities/
│   │   └── payment_method.dart
│   ├── repositories/
│   │   └── payment_repository.dart
│   └── usecases/
│       ├── create_setup_intent.dart
│       ├── save_payment_method.dart
│       ├── get_saved_payment_methods.dart
│       ├── delete_payment_method.dart
│       └── set_default_payment_method.dart
├── data/
│   ├── models/
│   │   └── payment_method_model.dart
│   └── repositories/
│       └── payment_repository_impl.dart
└── presentation/
    ├── screens/
    │   └── payment_methods_screen.dart
    ├── widgets/
    │   ├── payment_method_card.dart
    │   └── add_payment_method_button.dart
    └── providers/
        └── payment_providers.dart
```

### Key Components

#### PaymentMethodsScreen
Main screen for managing payment methods.

**Features**:
- List all saved cards
- Add new cards via Stripe PaymentSheet
- Delete cards with swipe gesture
- Set default payment method
- Empty state for new users
- Pull-to-refresh

**Usage**:
```dart
// Navigate to payment methods
context.go('/profile/payment-methods');
```

#### PaymentMethodCard Widget
Visual representation of a saved card.

**Features**:
- Card brand icon and colors
- Last 4 digits display
- Expiry date with warnings
- Default indicator
- Delete and set-default actions

**Props**:
```dart
PaymentMethodCard(
  paymentMethod: method,
  onDelete: () => deleteCard(method.id),
  onSetDefault: () => setDefault(method.id),
  isDeleting: false,
  isSelected: false,
)
```

#### AddPaymentMethodButton Widget
Button component for adding new payment methods.

**Features**:
- Creates SetupIntent
- Shows Stripe PaymentSheet
- Optional nickname dialog
- Loading states
- Error handling

**Usage**:
```dart
AddPaymentMethodButton(
  onMethodAdded: () => refreshPaymentMethods(),
  isLarge: false, // or true for larger variant
)
```

### Providers (Riverpod)

```dart
// Get all saved payment methods
final paymentMethods = ref.watch(savedPaymentMethodsProvider);

// Create setup intent
final setupIntent = await ref.read(createSetupIntentProvider.future);

// Save payment method
await ref.read(savePaymentMethodProvider(
  setupIntentId: 'seti_123',
  nickname: 'Work Card',
).future);

// Delete payment method
await ref.read(deletePaymentMethodProvider(methodId).future);

// Set default payment method
await ref.read(setDefaultPaymentMethodProvider(methodId).future);
```

### StripeService Methods

```dart
// Create SetupIntent for saving a card
final setupData = await StripeService.instance.createSetupIntent();

// Initialize payment sheet for card saving
await StripeService.instance.initSetupPaymentSheet(
  clientSecret: setupData['client_secret'],
  merchantDisplayName: 'DinnerHelp',
  customerEmail: user.email,
);

// Present payment sheet to user
await Stripe.instance.presentPaymentSheet();

// Save payment method after successful setup
await StripeService.instance.savePaymentMethod(
  setupIntentId: setupData['setup_intent_id'],
  nickname: 'Personal Card',
);

// Get saved payment methods
final methods = await StripeService.instance.getSavedPaymentMethods();

// Delete a payment method
await StripeService.instance.deletePaymentMethod(
  paymentMethodId: 'uuid',
);

// Set default payment method
await StripeService.instance.setDefaultPaymentMethod(
  paymentMethodId: 'uuid',
);
```

## Navigation

### Routes
```dart
// Main payment methods screen
'/profile/payment-methods'

// Legacy route (redirects to payment-methods)
'/profile/payment-history' → '/profile/payment-methods'
```

### Profile Menu Integration
The Profile screen menu item has been updated:
- **Icon**: `Icons.credit_card_outlined`
- **Title**: "Betalingsmetoder" (Payment Methods)
- **Subtitle**: "Administrer dine betalingsmuligheder"
- **Route**: `/profile/payment-methods`

## Security Considerations

### PCI Compliance
- **No Card Numbers**: Only Stripe tokens are stored
- **SetupIntent Flow**: Uses Stripe's secure tokenization
- **Client Secret**: Never exposed in logs or storage
- **HTTPS Only**: All API calls use secure connections

### Authentication & Authorization
- All Edge Functions require valid JWT
- RLS policies ensure data isolation
- User can only access their own payment methods
- Stripe customer ID linked to user profile

### Data Protection
- Card fingerprints prevent duplicate cards
- Automatic cleanup of orphaned records
- Sync with Stripe ensures data consistency
- No sensitive data in client-side storage

## User Experience Features

### Card Management
- **Multiple Cards**: Save unlimited payment methods
- **Card Nicknames**: Custom labels for identification
- **Default Selection**: One-tap default card setting
- **Visual Indicators**: Card brand icons and colors
- **Expiry Warnings**: Highlights cards expiring soon

### UI/UX Elements
- **Empty State**: Clear CTA for first-time users
- **Loading States**: Smooth transitions during operations
- **Error Handling**: User-friendly error messages
- **Pull-to-Refresh**: Update card list manually
- **Swipe Actions**: Intuitive delete gesture
- **Success Feedback**: Confirmation messages

## Testing Stripe Integration

### Test Card Numbers
```
Success: 4242 4242 4242 4242
Decline: 4000 0000 0000 0002
Requires Auth: 4000 0025 0000 3155
```

### Test Environment
- Use Stripe test mode keys
- Test publishable key in StripeService
- Test secret key in Edge Functions
- Enable test mode in payment sheet

## Common Use Cases

### Adding a Card
1. User taps "Add Card" button
2. System creates SetupIntent
3. Stripe PaymentSheet presented
4. User enters card details
5. Card saved and synced to database

### Making a Payment with Saved Card
```dart
// During booking checkout
final defaultMethod = paymentMethods.firstWhere((m) => m.isDefault);
await StripeService.instance.processPaymentWithSavedCard(
  paymentMethodId: defaultMethod.stripePaymentMethodId,
  clientSecret: paymentIntentClientSecret,
);
```

### Updating Card Details
Cards automatically update from Stripe during list operation. Changes include:
- Expiry dates (for renewed cards)
- Card brand updates
- Cardholder name changes

## Troubleshooting

### Common Issues

1. **"Failed to create setup intent"**
   - Check Stripe API keys
   - Verify user authentication
   - Check network connectivity

2. **"Payment method not found"**
   - Card may be deleted from Stripe
   - Sync payment methods to refresh

3. **"Duplicate card"**
   - Card fingerprint already exists
   - User trying to add same card twice

4. **RLS Policy Violations**
   - Ensure user is authenticated
   - Check user_id matches auth.uid()

### Debug Tips
```dart
// Enable Stripe logging
Stripe.publishableKey = 'pk_test_...';
Stripe.merchantIdentifier = 'merchant.com.dinnerhelp';
Stripe.urlScheme = 'flutterstripe';

// Check Edge Function logs
supabase functions logs create-setup-intent --tail

// Verify database state
SELECT * FROM payment_methods WHERE user_id = 'user-uuid';
SELECT stripe_customer_id FROM profiles WHERE id = 'user-uuid';
```

## Migration Guide

### For Existing Users
1. Stripe customer will be created on first card add
2. Existing bookings continue to work
3. Old payment history remains accessible
4. No action required from users

### For Developers
1. Run database migration for new columns
2. Deploy all Edge Functions
3. Update Flutter app with new screens
4. Test with Stripe test cards
5. Verify RLS policies are active

## Future Enhancements

### Planned Features
- [ ] Support for bank accounts
- [ ] Apple Pay / Google Pay integration
- [ ] Card update reminders
- [ ] Bulk card operations
- [ ] Card spending limits
- [ ] Transaction history per card
- [ ] Card sharing for family accounts

### API Improvements
- [ ] Batch operations for multiple cards
- [ ] Webhook for card expiry notifications
- [ ] Advanced fraud detection
- [ ] Regional payment method support

## Related Documentation
- [Stripe SetupIntent Documentation](https://stripe.com/docs/payments/save-and-reuse)
- [Payment System Documentation](./PAYMENT_SYSTEM_DOCUMENTATION.md)
- [Supabase RLS Guide](https://supabase.com/docs/guides/auth/row-level-security)
- [Flutter Stripe Package](https://pub.dev/packages/flutter_stripe)

## Support & Maintenance

### Monitoring
- Check Stripe Dashboard for payment method metrics
- Monitor Edge Function logs for errors
- Review failed SetupIntents regularly
- Track card expiry dates for notifications

### Updates
- Keep Stripe SDK updated
- Review and update test cards
- Monitor PCI compliance requirements
- Update UI based on user feedback

---

*Last Updated: January 2025*
*Version: 1.0.0*