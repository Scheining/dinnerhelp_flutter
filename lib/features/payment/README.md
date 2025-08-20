# DinnerHelp Stripe Connect Payment Integration

Complete payment system integration for the DinnerHelp booking platform using Stripe Connect, following Clean Architecture principles.

## Overview

This payment system handles the complete booking payment flow:
1. **Reserve funds** when chef confirms booking (authorization)
2. **Capture payment** after dining experience completion (or auto-capture after 24h)
3. **Service fee deduction** - DinnerHelp takes 15% from chef earnings
4. **Refund handling** with Danish cancellation policies
5. **Dispute management** for payment issues

## Architecture

### Domain Layer
- **Entities**: PaymentIntent, PaymentMethod, Refund, Dispute, PaymentCalculation
- **Services**: PaymentService (business logic)
- **Repositories**: PaymentRepository (interface)
- **Use Cases**: Specific business operations

### Data Layer
- **Repository Implementation**: PaymentRepositoryImpl
- **Models**: Data transfer objects with JSON serialization
- **Edge Functions**: Stripe API integration via Supabase

### Presentation Layer
- **Providers**: Riverpod state management
- **UI Components**: Payment forms, processing screens, history
- **Screens**: Complete payment flow integration

## Key Features

### Payment Flow
1. **Calculation**: Automatic fee calculation with VAT (25%) and service fee (15%)
2. **Authorization**: Reserve funds without immediate charge
3. **Capture**: Charge after service completion with actual amount adjustment
4. **Refunds**: Support full/partial refunds with cancellation policies

### Danish Compliance
- **VAT Handling**: 25% VAT automatically calculated
- **Holiday Surcharges**: Bank holidays and New Year's Eve extra charges
- **Cancellation Policy**: Free cancellation 24h+ before booking

### Service Fee Structure
- **Platform Fee**: 15% of base amount (deducted from chef payout)
- **User Pays**: Base amount + VAT only
- **Chef Receives**: Base amount - 15% service fee

## Setup Instructions

### 1. Dependencies
Add to `pubspec.yaml`:
```yaml
dependencies:
  stripe_flutter: ^10.2.0
  flutter_stripe: ^10.2.0
  url_launcher: ^6.2.2
  # ... existing dependencies
```

### 2. Environment Variables
Set in Supabase Edge Functions:
```env
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
SUPABASE_URL=https://...
SUPABASE_SERVICE_ROLE_KEY=eyJ...
```

### 3. Database Migration
Run the migration:
```bash
supabase db push
```

### 4. Dependency Injection
In your `main.dart`:
```dart
import 'lib/features/payment/di/payment_dependencies.dart';

void main() async {
  // ... Supabase initialization
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  
  // Setup payment dependencies
  setupPaymentDependencies();
  
  runApp(MyApp());
}
```

### 5. Edge Functions Deployment
Deploy Supabase functions:
```bash
supabase functions deploy create-payment-intent
supabase functions deploy authorize-payment
supabase functions deploy capture-payment
supabase functions deploy refund-payment
supabase functions deploy validate-stripe-account
```

## Usage Examples

### Basic Payment Integration
```dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'features/payment/presentation/screens/payment_integration_example.dart';

class BookingConfirmationScreen extends ConsumerWidget {
  final String bookingId;
  final int baseAmount; // in øre
  final String chefStripeAccountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: PaymentIntegrationExample(
        bookingId: bookingId,
        baseAmount: baseAmount,
        chefStripeAccountId: chefStripeAccountId,
        eventDate: DateTime.now().add(Duration(days: 7)),
      ),
    );
  }
}
```

### Payment Calculation
```dart
// Calculate payment amounts
final calculation = ref.watch(calculatePaymentProvider(
  baseAmount: 180000, // 1800.00 DKK in øre
  eventDate: DateTime.now().add(Duration(days: 7)),
));

print('Customer pays: ${calculation.formattedTotalAmount}');
print('Chef receives: ${calculation.formattedChefPayout}');
print('Platform revenue: ${calculation.formattedServiceFee}');
```

### Payment Status Checking
```dart
final paymentStatus = ref.watch(paymentStatusProvider(bookingId));

paymentStatus.when(
  data: (paymentIntent) {
    if (paymentIntent?.status.isAuthorized == true) {
      // Payment authorized - booking confirmed
    } else if (paymentIntent?.status.isSuccessful == true) {
      // Payment captured - service completed
    }
  },
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => ErrorWidget(error),
);
```

### Refund Processing
```dart
// Request refund
final refundResult = await ref.read(refundPaymentUseCaseProvider).call(
  bookingId: bookingId,
  amount: null, // null = full refund
  reason: RefundReason.requestedByCustomer,
  description: 'Customer requested cancellation',
);

refundResult.fold(
  (failure) => print('Refund failed: ${failure.message}'),
  (refund) => print('Refund processed: ${refund.id}'),
);
```

## Payment Flow States

### PaymentIntent Status
- `requiresPaymentMethod` - Need payment method
- `requiresConfirmation` - Need user confirmation
- `requiresAction` - Additional authentication needed
- `processing` - Payment processing
- `requiresCapture` - Authorized, awaiting capture
- `succeeded` - Payment completed
- `canceled` - Payment cancelled

### Booking Payment Flow
1. **User books chef** → `payment_status: pending`
2. **Chef accepts** → Create payment intent
3. **User authorizes** → `payment_status: authorized`
4. **Service completed** → Capture payment → `payment_status: succeeded`
5. **Auto-capture** → After 24h if not manually captured

## Database Schema

### Key Tables
- `payment_intents` - Stripe payment intent records
- `payment_methods` - Saved user payment methods
- `refunds` - Refund processing records
- `disputes` - Payment dispute handling
- `chef_payouts` - Chef earnings and payouts

### Relationships
```
bookings 1:1 payment_intents
payment_intents 1:* refunds
payment_intents 1:* disputes
bookings 1:1 chef_payouts
chef_payouts 1:* chef_payout_deductions
```

## Security Considerations

### Row Level Security (RLS)
- All payment tables have RLS enabled
- Users can only access their own payment data
- Chefs can access data for their bookings only

### API Security
- Edge Functions use service role key
- Stripe webhooks verified with webhook secret
- No sensitive data stored client-side

### PCI Compliance
- Payment methods handled by Stripe
- No card data stored in application
- Tokenization for recurring payments

## Error Handling

### Common Failures
- `PaymentIntentCreationFailure` - Payment intent creation failed
- `PaymentAuthorizationFailure` - Authorization declined
- `PaymentCaptureFailure` - Capture failed
- `RefundFailure` - Refund processing failed
- `StripeConnectAccountFailure` - Chef account issues

### Error Display
```dart
paymentState.when(
  error: (error, stack) => SelectableText.rich(
    TextSpan(
      text: 'Payment error: $error',
      style: TextStyle(color: Colors.red),
    ),
  ),
  // ... other states
);
```

## Testing

### Unit Tests
```bash
flutter test test/features/payment/
```

### Integration Tests
Test complete payment flows with mock Stripe responses.

## Monitoring & Analytics

### Key Metrics
- Payment success rate
- Authorization vs capture rates
- Refund rates and reasons
- Service fee collection
- Chef payout processing

### Logging
All payment operations logged via Edge Functions for debugging and compliance.

## Support

### Common Issues
1. **Chef account not ready**: Ensure Stripe Connect onboarding complete
2. **Payment declined**: Check card/account issues
3. **Capture failures**: Verify booking completion status
4. **Refund delays**: Normal processing time 2-10 business days

### Debugging
Check Supabase Edge Function logs for detailed error information:
```bash
supabase functions logs --func-name create-payment-intent
```

## Compliance

### Danish Regulations
- VAT automatically calculated and included
- Holiday surcharge policies implemented
- Cancellation rights respected (24h free cancellation)

### GDPR
- Payment data minimization
- User consent for payment method storage
- Right to deletion of payment history

This payment system provides a complete, compliant, and user-friendly payment experience for the DinnerHelp platform while ensuring proper revenue collection and chef compensation.