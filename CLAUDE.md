# DinnerHelp Development Guidelines for Claude

This document contains comprehensive development guidelines for the DinnerHelp Flutter application. Follow these rules and patterns when working on this codebase.

## Project Overview

DinnerHelp is a platform connecting users with professional chefs for in-home dining experiences. The application uses Flutter with Clean Architecture, Riverpod for state management, and Supabase as the backend.

## Flutter & Dart Development Guidelines

### Core Principles

#### Clean Architecture
- Strictly adhere to Clean Architecture layers: Presentation, Domain, and Data
- Follow the dependency rule: dependencies always point inward
- Domain layer contains entities, repositories (interfaces), and use cases
- Data layer implements repositories and contains data sources and models
- Presentation layer contains UI components, providers, and view models
- Use proper abstractions with interfaces/abstract classes for each component

#### Feature-First Organization
- Organize code by features instead of technical layers
- Each feature is a self-contained module with its own implementation of all layers
- Common directory structure:
```
lib/
├── core/                          # Shared/common code
│   ├── error/                     # Error handling, failures
│   ├── network/                   # Network utilities, interceptors
│   ├── utils/                     # Utility functions and extensions
│   └── widgets/                   # Reusable widgets
├── features/                      # All app features
│   ├── feature_name/              # Single feature
│   │   ├── data/                  # Data layer
│   │   │   ├── datasources/       # Remote and local data sources
│   │   │   ├── models/            # DTOs and data models
│   │   │   └── repositories/      # Repository implementations
│   │   ├── domain/                # Domain layer
│   │   │   ├── entities/          # Business objects
│   │   │   ├── repositories/      # Repository interfaces
│   │   │   └── usecases/          # Business logic use cases
│   │   └── presentation/          # Presentation layer
│   │       ├── providers/         # Riverpod providers
│   │       ├── pages/             # Screen widgets
│   │       └── widgets/           # Feature-specific widgets
└── main.dart                      # Entry point
```

### Dart/Flutter Guidelines

#### Basic Principles
- Use English for all code and documentation
- Always declare types explicitly (avoid dynamic)
- Use const constructors for immutable widgets
- Leverage Freezed for immutable state classes and unions
- Use descriptive variable names with auxiliary verbs (isLoading, hasError, canDelete)
- Keep functions small and focused (< 20 lines)
- Prefer composition over inheritance

#### Nomenclature
- Use PascalCase for classes
- Use camelCase for variables, functions, and methods
- Use underscores_case for file and directory names
- Use UPPERCASE for environment variables
- Start functions with verbs
- Use complete words instead of abbreviations (except standard ones like API, URL)

#### Functions
- Write short functions with a single purpose
- Use early returns to avoid nesting
- Use higher-order functions (map, filter, reduce)
- Use default parameter values
- Reduce parameters using object pattern (RO-RO)
- Maintain single level of abstraction

### Riverpod Implementation

#### Provider Guidelines
- Use @riverpod annotation for code generation
- Prefer AsyncNotifierProvider and NotifierProvider over StateProvider
- Avoid StateProvider, StateNotifierProvider, and ChangeNotifierProvider
- Create granular, focused providers for specific features
- Use ref.invalidate() for manual provider updates
- Implement proper cancellation of async operations

#### State Management Pattern
```dart
// Freezed state class
@freezed
class UserState with _$UserState {
  const factory UserState.initial() = _Initial;
  const factory UserState.loading() = _Loading;
  const factory UserState.loaded(User user) = _Loaded;
  const factory UserState.error(Failure failure) = _Error;
}

// Riverpod AsyncNotifier
@riverpod
class UserNotifier extends _$UserNotifier {
  @override
  FutureOr<UserState> build() {
    return const UserState.initial();
  }

  Future<void> getUser(String userId) async {
    state = const AsyncValue.loading();
    
    final result = await ref.read(getUserUseCaseProvider)(userId);
    
    state = result.fold(
      (failure) => AsyncValue.data(UserState.error(failure)),
      (user) => AsyncValue.data(UserState.loaded(user)),
    );
  }
}
```

### Error Handling

#### Functional Error Handling with Dartz
- Use Either<Failure, Success> for error handling
- Create custom Failure classes for domain-specific errors
- Implement proper error mapping between layers
- Use AsyncValue for Riverpod error states

```dart
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
  
  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server error occurred']) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Network error occurred']) : super(message);
}
```

#### UI Error Display
- Use SelectableText.rich for error messages (not SnackBars)
- Display errors with red color for visibility
- Handle empty states within displaying screens
- Implement proper loading indicators

### Dependency Injection

#### GetIt Setup
```dart
final getIt = GetIt.instance;

void initDependencies() {
  // Core
  getIt.registerLazySingleton<SupabaseClient>(
    () => Supabase.instance.client,
  );
  
  // Data sources
  getIt.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(supabaseClient: getIt()),
  );
  
  // Repositories
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      supabaseClient: getIt(),
      localDataSource: getIt(),
    ),
  );
  
  // Use cases
  getIt.registerLazySingleton(() => GetUser(getIt()));
}
```

### UI Implementation

#### Widget Structure
- Use ConsumerWidget for state-dependent widgets
- Use HookConsumerWidget when combining Riverpod and Flutter Hooks
- Create small, private widget classes (not methods)
- Use const constructors where possible

```dart
class UserPage extends HookConsumerWidget {
  final String userId;

  const UserPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userNotifierProvider);

    useEffect(() {
      ref.read(userNotifierProvider.notifier).getUser(userId);
      return null;
    }, [userId]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(userNotifierProvider),
          ),
        ],
      ),
      body: userState.when(
        data: (state) => state.when(
          initial: () => const SizedBox(),
          loading: () => const Center(child: CircularProgressIndicator()),
          loaded: (user) => UserDetailsWidget(user: user),
          error: (failure) => Center(
            child: SelectableText.rich(
              TextSpan(
                text: failure.message,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorWidget(error: error),
      ),
    );
  }
}
```

#### Navigation
- Use AutoRoute or GoRouter for type-safe navigation
- Implement deep linking support
- Pass data using route parameters or extras

#### Performance Optimization
- Use const widgets to minimize rebuilds
- Implement ListView.builder for large lists
- Use AssetImage for static images
- Use cached_network_image for remote images
- Profile with Flutter DevTools
- Minimize widget tree depth

### Testing Strategy
- Unit test domain logic and use cases
- Test repositories with mocked data sources
- Test providers with ProviderContainer
- Widget test UI components
- Integration test complete features
- Follow Given-When-Then pattern

### Code Quality
- Use flutter_lints for consistent code style
- Run build_runner after modifying annotated classes:
  ```bash
  flutter pub run build_runner build --delete-conflicting-outputs
  ```
- Keep lines under 80 characters
- Use trailing commas for better formatting
- Document complex logic
- Apply SOLID principles

### Additional Conventions
- Use log (not print) for debugging
- Use Theme.of(context).textTheme with Material 3 naming
- Set appropriate TextField properties (textCapitalization, keyboardType)
- Always include errorBuilder for Image.network
- Implement RefreshIndicator for pull-to-refresh
- Use @JsonSerializable with FieldRename.snake for models
- Handle Supabase real-time updates with proper cleanup

### Key Packages
- riverpod & flutter_riverpod
- freezed & freezed_annotation
- dartz (for functional programming)
- get_it (dependency injection)
- auto_route or go_router
- supabase_flutter
- flutter_hooks
- cached_network_image

## Supabase Integration Guidelines

### Database Structure

#### Core Tables (Public Schema)

##### Table: profiles
| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | uuid | NO | - | Primary key, references auth.users |
| first_name | text | YES | - | User's first name |
| last_name | text | YES | - | User's last name |
| email | text | YES | - | User's email address |
| is_chef | boolean | YES | false | Whether user is a chef |
| is_admin | boolean | YES | false | Whether user has admin privileges |
| avatar_url | text | YES | - | Profile image URL |
| created_at | timestamptz | YES | timezone('utc', now()) | Creation timestamp |
| updated_at | timestamptz | YES | timezone('utc', now()) | Last update timestamp |

**RLS Policies:**
- SELECT: Users can view all profiles (public read)
- UPDATE: Users can only update their own profile
- INSERT: Users can insert their own profile

##### Table: chefs
| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | uuid | NO | - | Primary key, references profiles.id |
| years_experience | integer | NO | - | Years of cooking experience |
| certified_chef | boolean | YES | false | Professional certification status |
| price_per_hour | integer | NO | - | Hourly rate in DKK |
| bio | text | YES | - | Chef biography |
| profile_image_url | text | YES | - | Chef profile image |
| profile_background_url | text | YES | - | Background image URL |
| is_active | boolean | YES | true | Whether chef is active |
| title | text | YES | - | Professional title |
| languages | text[] | YES | - | Languages spoken |
| cuisines | text[] | YES | - | Cuisine specialties |
| dietary_specialties | text[] | YES | - | Dietary specialties (vegan, gluten-free, etc.) |
| occasion_specialties | text[] | YES | - | Event specialties |
| gallery_images | jsonb | YES | - | Gallery image URLs and metadata |
| bank_holiday_extra_charge | integer | YES | 0 | Extra charge % for bank holidays (0-100) |
| new_years_eve_extra_charge | integer | YES | 0 | Extra charge % for New Year's Eve (0-100) |
| postal_code | text | YES | - | Service area postal code |
| phone | text | YES | - | Contact phone number |
| facebook_profile | text | YES | - | Facebook profile URL |
| linkedin_profile | text | YES | - | LinkedIn profile URL |
| instagram_profile | text | YES | - | Instagram profile URL |
| education_and_qualifications | text | YES | - | Educational background |
| has_clean_criminal_record | boolean | YES | - | Criminal record status |
| has_hygiene_certificate | boolean | YES | - | Food hygiene certification |
| hourly_rate | integer | YES | - | Hourly rate (duplicate of price_per_hour) |
| about | text | YES | - | About section |
| other_info | text | YES | - | Additional information |
| consent_given | boolean | YES | - | GDPR consent status |
| open_question | text | YES | - | Open question response |
| approved | boolean | YES | false | Admin approval status |
| created_at | timestamptz | YES | now() | Creation timestamp |
| updated_at | timestamptz | YES | now() | Last update timestamp |

**RLS Policies:**
- SELECT: Public read for approved chefs
- UPDATE: Chefs can update their own profile
- INSERT: Authenticated users can create chef profile
- DELETE: Only admins can delete

##### Table: bookings
| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | uuid | NO | uuid_generate_v4() | Primary key |
| user_id | uuid | YES | - | References profiles.id |
| chef_id | uuid | YES | - | References chefs.id |
| date | date | NO | - | Booking date |
| start_time | time | NO | - | Start time |
| end_time | time | NO | - | End time |
| status | text | NO | - | Booking status (pending, accepted, confirmed, etc.) |
| number_of_guests | integer | NO | - | Number of guests |
| total_amount | integer | NO | - | Total amount in DKK |
| payment_status | text | YES | 'pending' | Payment status |
| tip_amount | numeric | YES | 0 | Tip amount |
| platform_fee | numeric | YES | 0 | Platform fee |
| stripe_payment_intent_id | text | YES | - | Stripe payment ID |
| chef_review | text | YES | - | Review by chef |
| user_review | text | YES | - | Review by user |
| created_at | timestamptz | NO | timezone('utc', now()) | Creation timestamp |
| updated_at | timestamptz | NO | timezone('utc', now()) | Last update timestamp |

**Constraints:**
- status CHECK: Must be one of ['pending', 'accepted', 'confirmed', 'in_progress', 'completed', 'cancelled', 'disputed', 'refunded']
- payment_status CHECK: Must be one of ['pending', 'succeeded', 'failed', 'refunded', 'disputed']

**RLS Policies:**
- SELECT: Users can view own bookings, Chefs can view assigned bookings
- INSERT: Users can create bookings
- UPDATE: Users and chefs can update their related bookings

#### Additional tables include:
- chat_messages: For booking-related communication
- chef_applications: For chef onboarding
- chef_availability: Chef scheduling
- chef_ratings: Review system
- notifications: System notifications
- chef_schedule_settings: Booking rules
- chef_working_hours: Regular schedule
- chef_service_areas: Service locations
- chef_time_off: Vacation/unavailable dates
- faqs: FAQ content

### Storage Buckets

| Bucket Name | Public | File Size Limit | Allowed MIME Types | Description |
|-------------|--------|-----------------|-------------------|-------------|
| chef-images | true | 50MB | All | Chef profile and gallery images |
| marketing | true | - | All | Marketing materials |
| menu-images | true | 50MB | All | Menu and dish images |
| message-attachments | true | 10MB | image/*, application/pdf, MS Office, text/plain | Chat attachments |
| user-images | true | - | All | User profile images |

### Edge Functions

| Function | Description | Key Features |
|----------|-------------|--------------|
| stripe-connect-account | Creates Stripe Connect Express accounts for chefs | - Creates Express accounts<br>- Returns onboarding URL |
| stripe-disconnect-account | Disconnects Stripe accounts | - Deletes Connect account |
| stripe-onboarding-link | Generates new onboarding links | - For re-onboarding |
| stripe-account-status | Checks Connect account status | - Returns verification status |
| create-payment-intent | Creates payment intents for bookings | - Calculates platform fees<br>- Creates Stripe payment intent |
| handle-stripe-webhook | Processes Stripe webhooks | - Payment success/failure<br>- Refunds and disputes |
| calculate-final-amount | Calculates final booking amount | - Handles tips<br>- Adjusts for actual hours |
| invite-chef | Sends chef invitation emails | - Creates auth user<br>- Sends magic link |
| sync-chef-application | Syncs approved applications to chef profiles | - Creates profile/chef records |
| generate-recipe | Generates recipes using OpenAI | - Danish recipes<br>- Structured JSON output |
| generate-image | Generates images using Recraft AI | - Food photography<br>- Recipe images |
| add-chef-to-brevo | Adds chefs to email marketing list | - Brevo/SendinBlue integration |

### Integration Patterns

#### Repository Implementation Pattern
```dart
class BookingRepositoryImpl implements BookingRepository {
  final SupabaseClient _supabaseClient;
  
  @override
  Future<Either<Failure, Booking>> createBooking(BookingRequest request) async {
    try {
      // Validate booking using Edge Function
      final validationResult = await _supabaseClient.functions.invoke(
        'validate-booking-request',
        body: request.toJson(),
      );
      
      if (validationResult.error != null) {
        return Left(ValidationFailure(validationResult.error!.message));
      }
      
      // Create booking
      final response = await _supabaseClient
          .from('bookings')
          .insert({
            'user_id': request.userId,
            'chef_id': request.chefId,
            'date': request.date.toIso8601String(),
            'start_time': request.startTime,
            'end_time': request.endTime,
            'number_of_guests': request.numberOfGuests,
            'status': 'pending',
          })
          .select()
          .single();
          
      return Right(BookingModel.fromJson(response).toDomain());
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
```

#### Real-time Subscription Pattern
```dart
StreamSubscription<List<Map<String, dynamic>>>? _bookingSubscription;

void subscribeToBookingUpdates(String userId) {
  _bookingSubscription = _supabaseClient
      .from('bookings')
      .stream(primaryKey: ['id'])
      .eq('user_id', userId)
      .listen((data) {
        // Handle real-time updates
      });
}

void dispose() {
  _bookingSubscription?.cancel();
}
```

#### Edge Function Invocation
```dart
// For Stripe operations
final result = await _supabaseClient.functions.invoke(
  'create-payment-intent',
  body: {'booking_id': bookingId},
);

// For AI features
final recipeResult = await _supabaseClient.functions.invoke(
  'generate-recipe',
  body: {
    'dishName': dishName,
    'servings': servings,
  },
);
```

#### File Upload Pattern
```dart
Future<String> uploadChefImage(File image, String chefId) async {
  final fileName = '${chefId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
  final response = await _supabaseClient.storage
      .from('chef-images')
      .upload(fileName, image);
      
  if (response.error != null) {
    throw StorageException(response.error!.message);
  }
  
  return _supabaseClient.storage
      .from('chef-images')
      .getPublicUrl(fileName);
}
```

### Security Considerations

1. **RLS is enabled on all tables** - Never disable without careful consideration
2. **Service role key** should only be used in Edge Functions, never client-side
3. **Stripe webhooks** must be verified using webhook secret
4. **User permissions** are role-based (is_chef, is_admin flags)
5. **File uploads** are restricted by size and MIME type per bucket

### Environment Variables Required

**Supabase:**
- SUPABASE_URL
- SUPABASE_ANON_KEY
- SUPABASE_SERVICE_ROLE_KEY (Edge Functions only)

**Third-party Services:**
- STRIPE_SECRET_KEY
- STRIPE_WEBHOOK_SECRET
- OPENAI_API_KEY
- RECRAFT_API_TOKEN
- VITE_BREVO_API_KEY

**Application:**
- FRONTEND_URL (for redirects)

## Key Business Logic

### Chef Onboarding Flow
1. Application submitted (chef_applications)
2. Admin approval
3. User account created via invite-chef function
4. Profile synced via sync-chef-application
5. Chef completes profile and Stripe onboarding

### Booking Flow
1. Users create bookings → Chefs accept → Payment processed → Completion
2. Both parties can view and communicate about bookings
3. Disputes handled through separate dispute system

### Important Relationships
- profiles.id ← → auth.users.id (1:1)
- chefs.id → profiles.id (1:1)
- bookings.user_id → profiles.id
- bookings.chef_id → chefs.id
- chat_messages → bookings (via booking_id)
- notifications → users, chefs, bookings

## Development Workflow

1. Always follow Clean Architecture principles
2. Use proper error handling with Either types
3. Implement proper state management with Riverpod
4. Test all layers of the application
5. Maintain consistent naming conventions
6. Document complex business logic
7. Use proper Git commit messages
8. Run linting and formatting before commits

## Common Commands

```bash
# Generate code with build_runner
flutter pub run build_runner build --delete-conflicting-outputs

# Run tests
flutter test

# Run linting
flutter analyze

# Format code
flutter format .

# Clean project
flutter clean

# Get dependencies
flutter pub get
```

Remember to always prioritize code quality, maintainability, and user experience when developing features for the DinnerHelp platform.