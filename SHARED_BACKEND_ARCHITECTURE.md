# Shared Backend Architecture for DinnerHelp

**Last Updated:** January 2025  
**Purpose:** Connect Flutter app and web dashboard to share the same Supabase backend

## Architecture Overview

```
┌─────────────────────┐     ┌─────────────────────┐
│   Flutter App       │     │   Web Dashboard     │
│   (Users & Chefs)   │     │   (Chef Portal)     │
└──────────┬──────────┘     └──────────┬──────────┘
           │                            │
           │      Shared Types          │
           │   ┌──────────────┐        │
           └──►│ TypeScript   │◄───────┘
               │ Definitions  │
               └──────┬───────┘
                      │
           ┌──────────▼──────────┐
           │   Supabase Backend  │
           │  - Database (RLS)   │
           │  - Edge Functions   │
           │  - Auth            │
           │  - Storage         │
           └─────────────────────┘
```

## Implementation Strategy

### Option 1: Monorepo Structure (Recommended)

Create a monorepo that houses both projects and shared code:

```
dinnerhelp/
├── apps/
│   ├── flutter/          # Flutter mobile app
│   │   ├── lib/
│   │   ├── pubspec.yaml
│   │   └── ...
│   └── web-dashboard/    # React/Next.js dashboard
│       ├── src/
│       ├── package.json
│       └── ...
├── packages/
│   ├── shared-types/     # Shared TypeScript types
│   │   ├── src/
│   │   │   ├── database.types.ts
│   │   │   ├── api.types.ts
│   │   │   └── index.ts
│   │   └── package.json
│   └── supabase/         # Shared Supabase config
│       ├── functions/
│       ├── migrations/
│       └── config.toml
├── package.json          # Root package.json
├── turbo.json           # Turborepo config (optional)
└── README.md
```

### Option 2: Shared Types Package

Create a separate npm package for shared types:

```bash
# Create shared types package
mkdir dinnerhelp-shared-types
cd dinnerhelp-shared-types
npm init -y

# Install TypeScript
npm install --save-dev typescript @types/node

# Create tsconfig.json
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "declaration": true,
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
EOF
```

## Step 1: Generate Supabase Types

### Install Supabase CLI
```bash
npm install -g supabase
```

### Generate TypeScript Types
```bash
# Login to Supabase
supabase login

# Link to your project
supabase link --project-ref your-project-ref

# Generate types
supabase gen types typescript --linked > database.types.ts
```

### Generated Types Example
```typescript
// database.types.ts
export interface Database {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string
          first_name: string | null
          last_name: string | null
          email: string | null
          is_chef: boolean | null
          is_admin: boolean | null
          avatar_url: string | null
          created_at: string | null
          updated_at: string | null
        }
        Insert: {
          id: string
          first_name?: string | null
          last_name?: string | null
          // ...
        }
        Update: {
          id?: string
          first_name?: string | null
          // ...
        }
      }
      chefs: {
        Row: {
          id: string
          years_experience: number
          certified_chef: boolean | null
          price_per_hour: number
          bio: string | null
          is_vat_registered: boolean
          vat_number: string | null
          vat_rate: number
          commission_rate: number
          // ...
        }
        // ...
      }
      bookings: {
        Row: {
          id: string
          user_id: string | null
          chef_id: string | null
          date: string
          start_time: string
          end_time: string
          status: string
          total_amount: number
          payment_status: string | null
          // ...
        }
        // ...
      }
    }
  }
}
```

## Step 2: Create Shared Business Types

```typescript
// shared-types/src/models.ts
import { Database } from './database.types'

// Type aliases for easier use
export type Profile = Database['public']['Tables']['profiles']['Row']
export type Chef = Database['public']['Tables']['chefs']['Row']
export type Booking = Database['public']['Tables']['bookings']['Row']

// Extended types with relations
export interface ChefWithProfile extends Chef {
  profile: Profile
}

export interface BookingWithDetails extends Booking {
  chef: ChefWithProfile
  user: Profile
}

// Enums shared between apps
export enum BookingStatus {
  PENDING = 'pending',
  ACCEPTED = 'accepted',
  CONFIRMED = 'confirmed',
  IN_PROGRESS = 'in_progress',
  COMPLETED = 'completed',
  CANCELLED = 'cancelled',
  DISPUTED = 'disputed',
  REFUNDED = 'refunded'
}

export enum PaymentStatus {
  PENDING = 'pending',
  SUCCEEDED = 'succeeded',
  FAILED = 'failed',
  REFUNDED = 'refunded',
  DISPUTED = 'disputed'
}

// API request/response types
export interface CreateBookingRequest {
  chef_id: string
  date: string
  start_time: string
  end_time: string
  number_of_guests: number
  menu_description?: string
  special_requests?: string
  address: string
}

export interface PaymentIntentRequest {
  booking_id?: string
  amount: number
  service_fee_amount: number
  payment_processing_fee: number
  vat_amount: number
  chef_stripe_account_id: string
  booking_data?: CreateBookingRequest
}

// Shared validation rules
export const ValidationRules = {
  MIN_BOOKING_HOURS: 2,
  MAX_BOOKING_HOURS: 8,
  MIN_GUESTS: 1,
  MAX_GUESTS: 20,
  MIN_ADVANCE_BOOKING_DAYS: 2,
  MAX_ADVANCE_BOOKING_DAYS: 90,
  VAT_RATE: 0.25,
  SERVICE_FEE_RATE: 0.05,
  CHEF_COMMISSION_RATE: 0.15,
  VAT_THRESHOLD_DKK: 50000,
}

// Fee calculation utilities
export class FeeCalculator {
  static calculateFees(
    baseAmount: number,
    isVatRegistered: boolean
  ) {
    const serviceFee = Math.round(baseAmount * ValidationRules.SERVICE_FEE_RATE)
    const chefCommission = Math.round(baseAmount * ValidationRules.CHEF_COMMISSION_RATE)
    const vatRate = isVatRegistered ? ValidationRules.VAT_RATE : 0
    const vatAmount = Math.round(baseAmount * vatRate)
    const processingFee = Math.round((baseAmount + serviceFee) * 0.029 + 250)
    
    return {
      baseAmount,
      serviceFee,
      chefCommission,
      vatAmount,
      processingFee,
      totalAmount: baseAmount + serviceFee + vatAmount + processingFee,
      chefPayout: baseAmount - chefCommission,
      platformRevenue: serviceFee + chefCommission,
    }
  }
}
```

## Step 3: Use in Flutter App

### Create Dart Models from TypeScript

```dart
// lib/models/shared/booking_status.dart
enum BookingStatus {
  pending('pending'),
  accepted('accepted'),
  confirmed('confirmed'),
  inProgress('in_progress'),
  completed('completed'),
  cancelled('cancelled'),
  disputed('disputed'),
  refunded('refunded');

  final String value;
  const BookingStatus(this.value);
  
  static BookingStatus fromString(String value) {
    return BookingStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => BookingStatus.pending,
    );
  }
}

// lib/models/shared/validation_rules.dart
class ValidationRules {
  static const int minBookingHours = 2;
  static const int maxBookingHours = 8;
  static const int minGuests = 1;
  static const int maxGuests = 20;
  static const int minAdvanceBookingDays = 2;
  static const int maxAdvanceBookingDays = 90;
  static const double vatRate = 0.25;
  static const double serviceFeeRate = 0.05;
  static const double chefCommissionRate = 0.15;
  static const int vatThresholdDkk = 50000;
}

// lib/utils/fee_calculator.dart
class FeeCalculator {
  static Map<String, int> calculateFees({
    required int baseAmount,
    required bool isVatRegistered,
  }) {
    final serviceFee = (baseAmount * ValidationRules.serviceFeeRate).round();
    final chefCommission = (baseAmount * ValidationRules.chefCommissionRate).round();
    final vatRate = isVatRegistered ? ValidationRules.vatRate : 0.0;
    final vatAmount = (baseAmount * vatRate).round();
    final processingFee = ((baseAmount + serviceFee) * 0.029 + 250).round();
    
    return {
      'baseAmount': baseAmount,
      'serviceFee': serviceFee,
      'chefCommission': chefCommission,
      'vatAmount': vatAmount,
      'processingFee': processingFee,
      'totalAmount': baseAmount + serviceFee + vatAmount + processingFee,
      'chefPayout': baseAmount - chefCommission,
      'platformRevenue': serviceFee + chefCommission,
    };
  }
}
```

### Create Script to Sync Types

```bash
#!/bin/bash
# sync-types.sh

# Generate Supabase types
supabase gen types typescript --linked > packages/shared-types/src/database.types.ts

# Generate Dart models from TypeScript (using a tool like quicktype)
npx quicktype \
  -s typescript \
  -t dart \
  --src packages/shared-types/src/models.ts \
  --out apps/flutter/lib/models/generated/

# Format Dart code
cd apps/flutter && dart format lib/models/generated/
```

## Step 4: Use in Web Dashboard

```typescript
// web-dashboard/src/lib/supabase.ts
import { createClient } from '@supabase/supabase-js'
import { Database } from '@dinnerhelp/shared-types'

export const supabase = createClient<Database>(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)

// web-dashboard/src/hooks/useBookings.ts
import { useState, useEffect } from 'react'
import { supabase } from '@/lib/supabase'
import { BookingWithDetails, BookingStatus } from '@dinnerhelp/shared-types'

export function useChefBookings(chefId: string) {
  const [bookings, setBookings] = useState<BookingWithDetails[]>([])
  const [loading, setLoading] = useState(true)
  
  useEffect(() => {
    async function fetchBookings() {
      const { data, error } = await supabase
        .from('bookings')
        .select(`
          *,
          chef:chefs!inner(
            *,
            profile:profiles!inner(*)
          ),
          user:profiles!inner(*)
        `)
        .eq('chef_id', chefId)
        .order('date', { ascending: false })
      
      if (data) {
        setBookings(data as BookingWithDetails[])
      }
      setLoading(false)
    }
    
    fetchBookings()
    
    // Subscribe to real-time updates
    const subscription = supabase
      .channel('chef-bookings')
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'bookings',
          filter: `chef_id=eq.${chefId}`
        },
        (payload) => {
          // Handle real-time updates
          fetchBookings()
        }
      )
      .subscribe()
    
    return () => {
      subscription.unsubscribe()
    }
  }, [chefId])
  
  return { bookings, loading }
}

// web-dashboard/src/components/BookingCard.tsx
import { BookingWithDetails, FeeCalculator } from '@dinnerhelp/shared-types'

interface BookingCardProps {
  booking: BookingWithDetails
}

export function BookingCard({ booking }: BookingCardProps) {
  const fees = FeeCalculator.calculateFees(
    booking.total_amount,
    booking.chef.is_vat_registered
  )
  
  return (
    <div className="booking-card">
      <h3>Booking #{booking.id.substring(0, 8)}</h3>
      <p>Customer: {booking.user.first_name} {booking.user.last_name}</p>
      <p>Date: {new Date(booking.date).toLocaleDateString('da-DK')}</p>
      <p>Your earnings: {fees.chefPayout} kr</p>
      <p>Status: {booking.status}</p>
    </div>
  )
}
```

## Step 5: Automated Type Generation Workflow

### GitHub Actions Workflow

```yaml
# .github/workflows/sync-types.yml
name: Sync Types

on:
  push:
    paths:
      - 'supabase/migrations/**'
      - 'packages/shared-types/**'
  workflow_dispatch:

jobs:
  sync-types:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          
      - name: Install Supabase CLI
        run: |
          curl -fsSL https://github.com/supabase/cli/releases/latest/download/supabase_linux_amd64.tar.gz | tar xz
          sudo mv supabase /usr/local/bin/
          
      - name: Generate Types
        env:
          SUPABASE_ACCESS_TOKEN: ${{ secrets.SUPABASE_ACCESS_TOKEN }}
          SUPABASE_PROJECT_REF: ${{ secrets.SUPABASE_PROJECT_REF }}
        run: |
          supabase gen types typescript --project-ref $SUPABASE_PROJECT_REF > packages/shared-types/src/database.types.ts
          
      - name: Build Shared Types
        run: |
          cd packages/shared-types
          npm install
          npm run build
          
      - name: Create Pull Request
        uses: peter-evans/create-pull-request@v5
        with:
          title: 'chore: update generated types'
          commit-message: 'chore: update generated types from Supabase'
          branch: update-types
          delete-branch: true
```

## Step 6: Development Workflow

### Local Development Setup

```bash
# 1. Clone monorepo
git clone https://github.com/yourorg/dinnerhelp.git
cd dinnerhelp

# 2. Install dependencies
npm install # Install root dependencies
cd apps/flutter && flutter pub get
cd ../web-dashboard && npm install

# 3. Set up environment variables
cp .env.example .env.local
# Edit .env.local with your Supabase credentials

# 4. Start Supabase locally (optional)
supabase start

# 5. Generate types
npm run generate:types

# 6. Start development servers
# Terminal 1: Flutter app
cd apps/flutter && flutter run

# Terminal 2: Web dashboard
cd apps/web-dashboard && npm run dev
```

### Package.json Scripts

```json
{
  "scripts": {
    "generate:types": "supabase gen types typescript --linked > packages/shared-types/src/database.types.ts",
    "build:shared": "cd packages/shared-types && npm run build",
    "dev:flutter": "cd apps/flutter && flutter run",
    "dev:web": "cd apps/web-dashboard && npm run dev",
    "test:all": "npm run test:shared && npm run test:flutter && npm run test:web",
    "deploy:functions": "supabase functions deploy",
    "db:migrate": "supabase db push",
    "db:reset": "supabase db reset"
  }
}
```

## Step 7: Best Practices

### 1. Version Control
- Use semantic versioning for shared packages
- Tag releases for both apps simultaneously
- Maintain changelog for breaking changes

### 2. CI/CD Pipeline
```yaml
# Deploy both apps when shared types change
on:
  push:
    tags:
      - 'v*'
      
jobs:
  deploy-flutter:
    # Build and deploy Flutter app
    
  deploy-web:
    # Build and deploy web dashboard
```

### 3. Type Safety Checks
```typescript
// Add type guards for runtime validation
export function isValidBookingStatus(status: string): status is BookingStatus {
  return Object.values(BookingStatus).includes(status as BookingStatus)
}

export function assertBookingWithDetails(
  booking: unknown
): asserts booking is BookingWithDetails {
  if (!booking || typeof booking !== 'object') {
    throw new Error('Invalid booking object')
  }
  // Add more validation as needed
}
```

### 4. Documentation
```typescript
/**
 * Booking represents a dining experience request
 * @property {string} id - Unique booking identifier
 * @property {BookingStatus} status - Current booking status
 * @see {@link BookingStatus} for possible values
 */
export interface Booking {
  // ...
}
```

## Monitoring & Debugging

### 1. Shared Logging Format
```typescript
// shared-types/src/logging.ts
export interface LogEntry {
  timestamp: string
  level: 'debug' | 'info' | 'warn' | 'error'
  source: 'flutter' | 'web' | 'edge-function'
  userId?: string
  chefId?: string
  bookingId?: string
  message: string
  metadata?: Record<string, any>
}
```

### 2. Error Tracking
```typescript
// Use same error codes across platforms
export enum ErrorCode {
  INVALID_BOOKING_DATE = 'INVALID_BOOKING_DATE',
  CHEF_NOT_AVAILABLE = 'CHEF_NOT_AVAILABLE',
  PAYMENT_FAILED = 'PAYMENT_FAILED',
  VAT_INFO_MISSING = 'VAT_INFO_MISSING',
  // ...
}
```

## Summary

This architecture ensures:
1. **Type Safety**: Shared types prevent mismatches between apps
2. **Consistency**: Business logic is implemented identically
3. **Maintainability**: Changes to database schema automatically propagate
4. **Developer Experience**: IntelliSense and type checking across projects
5. **Scalability**: Easy to add more frontends (mobile web, admin panel, etc.)

The key is treating your Supabase schema as the source of truth and generating types from it, ensuring all applications stay in sync with the backend.