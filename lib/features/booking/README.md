# DinnerHelp Booking UI Components

This document describes the complete Flutter booking UI components for DinnerHelp, built following Clean Architecture principles and using Riverpod for state management.

## Components Overview

### 1. BookingDateTimeSelector Widget
**Location:** `lib/features/booking/presentation/widgets/booking_date_time_selector.dart`

A comprehensive date and time selection widget that:
- Shows calendar date picker with chef availability
- Displays time slot selector with visual availability indicators
- Shows buffer times and unavailable slots
- Supports minimum 2-hour booking duration
- Respects chef's min_notice_hours
- Integrates with BookingAvailabilityService

**Usage:**
```dart
BookingDateTimeSelector(
  chefId: "chef_123",
  minDuration: Duration(hours: 2),
  numberOfGuests: 4,
  onDateSelected: (date) => print("Date selected: $date"),
  onTimeSlotSelected: (timeSlot) => print("Time slot: $timeSlot"),
)
```

### 2. DishSelectionScreen
**Location:** `lib/features/booking/presentation/screens/dish_selection_screen.dart`

A screen for selecting dishes from chef's menu that:
- Displays dishes from chef's menu (from dishes table)
- Allows multiple dish selection with quantity controls
- Provides custom dish request option with text input
- Shows preparation time estimates
- Calculates total cooking time
- Shows dietary information (vegan, vegetarian, gluten-free)

**Usage:**
```dart
DishSelectionScreen(
  chefId: "chef_123",
  chefName: "Lars Nielsen",
  availableDishes: dishes,
  onSelectionComplete: (selectedDishes, customRequest) {
    // Handle dish selection
  },
)
```

### 3. RecurringBookingSelector Widget
**Location:** `lib/features/booking/presentation/widgets/recurring_booking_selector.dart`

A widget for setting up recurring bookings that:
- Pattern selector: Weekly, Every 14 days, Every 3 weeks, Monthly
- End date picker (max 6 months)
- Preview of generated occurrences
- Conflict warnings for unavailable dates
- Option to skip conflicting dates

**Usage:**
```dart
RecurringBookingSelector(
  initialDate: DateTime.now(),
  onPatternSelected: (pattern) => print("Pattern: $pattern"),
)
```

### 4. BookingSummaryScreen
**Location:** `lib/features/booking/presentation/screens/booking_summary_screen.dart`

A comprehensive summary screen that shows:
- Selected date, time, and duration
- Display selected dishes or custom requests
- Pricing breakdown (chef rate × hours, fees, tax)
- Recurring booking summary if applicable
- Terms and conditions
- Confirmation button

**Usage:**
```dart
BookingSummaryScreen(
  chef: chef,
  selectedDate: DateTime.now(),
  selectedTimeSlot: timeSlot,
  numberOfGuests: 4,
  selectedDishes: dishes,
  customDishRequest: customRequest,
  recurringPattern: pattern,
  onConfirmBooking: () => print("Booking confirmed"),
)
```

### 5. ChefSearchResultsScreen
**Location:** `lib/features/booking/presentation/screens/chef_search_results_screen.dart`

A screen for the Search tab that includes:
- Date/time filter inputs
- Duration and guest count selectors
- List of available chefs for selected slot
- Chef cards showing rate, rating, cuisine
- Sorting options (rating, price, distance)
- Price range filters
- Integration with existing ChefCard widget

**Usage:**
```dart
ChefSearchResultsScreen(
  allChefs: chefs,
  onChefSelected: (chef) => navigateToBooking(chef),
)
```

### 6. BookingManagementScreen
**Location:** `lib/features/booking/presentation/screens/booking_management_screen.dart`

A comprehensive booking management screen with:
- Tabbed interface (All, Upcoming, Completed, Cancelled)
- User's upcoming bookings display
- Recurring booking series management
- Modification request UI (up to 24h before)
- Cancellation option with policy display
- Status indicators and action buttons

**Usage:**
```dart
BookingManagementScreen(
  bookings: userBookings,
  onModifyBooking: (id) => print("Modify booking $id"),
  onCancelBooking: (id) => print("Cancel booking $id"),
  onContactChef: (id) => print("Contact chef for $id"),
)
```

## Entity Models

### Dish Entity
**Location:** `lib/features/booking/domain/entities/dish.dart`

Represents a dish from chef's menu with properties like:
- Basic info (name, description, image)
- Preparation time
- Dietary information (vegan, vegetarian, gluten-free)
- Allergens
- Chef association

### SelectedDish Entity
**Location:** `lib/features/booking/domain/entities/selected_dish.dart`

Represents a dish selected for booking with:
- Reference to Dish entity
- Quantity
- Special instructions
- Total preparation time calculation

### CustomDishRequest Entity
**Location:** `lib/features/booking/domain/entities/custom_dish_request.dart`

Represents a custom dish request with:
- Name and description
- Estimated preparation time
- Dietary requirements
- Additional notes

## State Management

### BookingAvailabilityProviders
**Location:** `lib/features/booking/presentation/providers/booking_availability_providers.dart`

Provides state management for:
- Available time slots
- Booking conflict checking
- Chef weekly schedule
- Next available slot finding
- Booking validation
- Booking selection state

### RecurringBookingProviders
**Location:** `lib/features/booking/presentation/providers/recurring_booking_providers.dart`

Provides state management for:
- Recurring pattern validation
- Recurring booking creation
- Series management (cancel, modify)
- Pricing calculations with discounts

## Theme Integration

All components follow the existing DinnerHelp theme:
- **Primary Color:** `#79CBC2` (Soft Teal)
- **Typography:** Google Fonts Inter
- **Spacing:** Material Design 3 spacing constants
- **Component Style:** Rounded corners, card-based design
- **Navigation:** Maintains current navigation bar design

## Danish Localization

Components include Danish text for:
- Button labels and actions
- Form labels and placeholders
- Status messages and feedback
- Date and time formatting
- Error messages and validation

## Key Features

### Responsive Design
- Adapts to different screen sizes
- Touch-friendly controls
- Proper spacing and typography scaling

### Accessibility
- Semantic markup with proper labels
- Color contrast compliance
- Screen reader support
- Keyboard navigation support

### Error Handling
- Proper loading states with CircularProgressIndicator
- Error states with user-friendly messages
- Validation feedback with red text and icons
- Network error handling

### Performance
- Efficient state management with Riverpod
- Lazy loading of time slots
- Optimized list rendering
- Image caching for chef and dish images

## Integration Points

### With Existing Codebase
- Uses existing `Chef` model from `models/chef.dart`
- Integrates with `ChefCard` widget
- Follows existing navigation patterns
- Uses established theme and spacing constants

### With BookingAvailabilityService
- Real-time availability checking
- Conflict detection
- Schedule validation
- Buffer time calculations

### With Supabase Backend
- Dish data from `dishes` table
- Chef availability from `chef_working_hours`
- Booking creation and management
- Real-time updates for availability

## Usage Flow

1. **Search:** User searches for chefs using `ChefSearchResultsScreen`
2. **Selection:** User selects chef and sees `BookingDateTimeSelector`
3. **Dishes:** User selects dishes in `DishSelectionScreen`
4. **Recurring:** Optional recurring pattern in `RecurringBookingSelector`
5. **Summary:** Review and confirm in `BookingSummaryScreen`
6. **Management:** View bookings in `BookingManagementScreen`

## Development Notes

### Running Code Generation
After modifying provider files, run:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Testing
Each component includes proper state management for testing:
- Unit tests for business logic
- Widget tests for UI components
- Integration tests for complete flows

### Customization
Components are designed to be:
- Highly configurable through constructor parameters
- Themeable through Material Design 3
- Localizable through l10n integration
- Extensible for additional features

This implementation provides a complete, production-ready booking system that maintains consistency with the existing DinnerHelp design language while providing comprehensive functionality for chef booking workflows.