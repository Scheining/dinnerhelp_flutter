// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'DinnerHelp';

  @override
  String get home => 'Home';

  @override
  String get search => 'Search';

  @override
  String get bookings => 'Bookings';

  @override
  String get messages => 'Messages';

  @override
  String get profile => 'Profile';

  @override
  String get availableChefsNearYou => 'Available Chefs Near You';

  @override
  String get popularChefsInRegion => 'Popular Chefs in Your Region';

  @override
  String get seeAll => 'See all';

  @override
  String get featuredChefs => 'Featured Chefs';

  @override
  String get bookChef => 'Book Chef';

  @override
  String dkkPerHour(int rate) {
    return '$rate DKK/hr';
  }

  @override
  String kmAway(double distance) {
    final intl.NumberFormat distanceNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String distanceString = distanceNumberFormat.format(distance);

    return '$distanceString km away';
  }

  @override
  String reviews(int count) {
    return '$count reviews';
  }

  @override
  String guests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count guests',
      one: '1 guest',
    );
    return '$_temp0';
  }

  @override
  String get noMessagesYet => 'No messages yet';

  @override
  String get startConversationWithChef => 'Start a conversation with a chef';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get past => 'Past';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get noUpcomingBookings => 'No upcoming bookings';

  @override
  String get noPastBookings => 'No past bookings';

  @override
  String get noCancelledBookings => 'No cancelled bookings';

  @override
  String get busy => 'Busy';

  @override
  String get verified => 'Verified';

  @override
  String get bookingDetails => 'Booking Details';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get address => 'Address';

  @override
  String get specialRequests => 'Special Requests';

  @override
  String get priceBreakdown => 'Price Breakdown';

  @override
  String get basePrice => 'Base Price';

  @override
  String get serviceFee => 'Service Fee';

  @override
  String get tax => 'Tax';

  @override
  String get total => 'Total';

  @override
  String get close => 'Close';

  @override
  String get currentLocation => 'Current Location';

  @override
  String get locationPermissionRequired => 'Location permission required';

  @override
  String get locationServicesDisabled => 'Location services are disabled';

  @override
  String get january => 'Jan';

  @override
  String get february => 'Feb';

  @override
  String get march => 'Mar';

  @override
  String get april => 'Apr';

  @override
  String get may => 'May';

  @override
  String get june => 'Jun';

  @override
  String get july => 'Jul';

  @override
  String get august => 'Aug';

  @override
  String get september => 'Sep';

  @override
  String get october => 'Oct';

  @override
  String get november => 'Nov';

  @override
  String get december => 'Dec';

  @override
  String get monday => 'Mon';

  @override
  String get tuesday => 'Tue';

  @override
  String get wednesday => 'Wed';

  @override
  String get thursday => 'Thu';

  @override
  String get friday => 'Fri';

  @override
  String get saturday => 'Sat';

  @override
  String get sunday => 'Sun';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get now => 'now';

  @override
  String minutesAgo(int count) {
    return '${count}m';
  }

  @override
  String hoursAgo(int count) {
    return '${count}h';
  }

  @override
  String daysAgo(int count) {
    return '${count}d';
  }

  @override
  String get notificationPreferences => 'Notification Preferences';

  @override
  String get notifications => 'Notifications';

  @override
  String get myBookings => 'My Bookings';

  @override
  String get upcomingTab => 'Upcoming';

  @override
  String get pastTab => 'Past';

  @override
  String get cancelledTab => 'Cancelled';

  @override
  String get viewDetails => 'View Details';

  @override
  String get cancelBooking => 'Cancel';

  @override
  String get cancelBookingTitle => 'Cancel Booking';

  @override
  String get cancelBookingConfirmation =>
      'Are you sure you want to cancel this booking?';

  @override
  String get keepBooking => 'Keep Booking';

  @override
  String get yesCancel => 'Yes, Cancel';

  @override
  String get bookingCancelledSuccess =>
      'Booking cancelled and refund initiated';

  @override
  String get errorCancellingBooking => 'Error cancelling';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get errorLoadingBookings => 'Error loading bookings';

  @override
  String get refundNotice =>
      'Note: You will receive a full refund as there are more than 48 hours until the booking.';

  @override
  String get findYourNextChef => 'Find your next dining experience';

  @override
  String get startExploring => 'Explore Chefs';

  @override
  String get bookingStatus => 'Status';

  @override
  String get pending => 'Pending';

  @override
  String get confirmed => 'Confirmed';

  @override
  String get completed => 'Completed';

  @override
  String get inProgress => 'In Progress';

  @override
  String get disputed => 'Disputed';

  @override
  String get refunded => 'Refunded';

  @override
  String guestCount(int count) {
    return '$count guests';
  }

  @override
  String get paymentMethods => 'Payment Methods';

  @override
  String get savedCards => 'Saved Cards';

  @override
  String get noPaymentMethods => 'No Payment Methods';

  @override
  String get addCard => 'Add Card';

  @override
  String get adding => 'Adding...';

  @override
  String get removeCard => 'Remove Card';

  @override
  String get cardRemoved => 'Card removed';

  @override
  String get cardRemovedSuccessfully => 'Card removed successfully';

  @override
  String get defaultCard => 'Default';

  @override
  String get expires => 'Expires';

  @override
  String get setAsDefault => 'Set as default';

  @override
  String get defaultPaymentMethodUpdated => 'Default payment method updated';

  @override
  String areYouSureRemoveCard(String last4) {
    return 'Are you sure you want to remove the card ending in $last4?';
  }

  @override
  String failedToRemoveCard(String message) {
    return 'Failed to remove card: $message';
  }

  @override
  String failedToSetDefault(String message) {
    return 'Failed to set default: $message';
  }

  @override
  String get cardAddedSuccessfully => 'Card added successfully';

  @override
  String get paymentSetupFailed => 'Payment setup failed';

  @override
  String get cardNickname => 'Card Nickname (Optional)';

  @override
  String get giveCardNickname =>
      'Give this card a nickname to easily identify it';

  @override
  String get skip => 'Skip';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get remove => 'Remove';

  @override
  String get yourPaymentInfoSecure =>
      'Your payment information is encrypted and secure';

  @override
  String get addCardToMakeBookingFaster =>
      'Add a card to make booking faster and easier';

  @override
  String cardsSaved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards saved',
      one: '1 card saved',
      zero: 'No cards saved',
    );
    return '$_temp0';
  }

  @override
  String errorLoadingPaymentMethods(String error) {
    return 'Error loading payment methods: $error';
  }

  @override
  String get retry => 'Retry';

  @override
  String get personalCard => 'Personal Card';

  @override
  String get workCard => 'Work Card';

  @override
  String get expiringCard => 'Expiring Soon';

  @override
  String get selectLocation => 'Select Location';

  @override
  String get useCurrentLocation => 'Use Current Location';

  @override
  String get enterManually => 'Enter Manually';

  @override
  String get typeLocationOrAddress => 'Type city or address';

  @override
  String get gettingLocation => 'Getting location...';

  @override
  String get locationUnavailable => 'Location unavailable';

  @override
  String get locationPermissionNeeded => 'Location permission needed';

  @override
  String get locationDisabled => 'Location disabled';

  @override
  String get locationTimeout => 'Location timeout';

  @override
  String get locationError => 'Location error';

  @override
  String get manualLocationComingSoon => 'Manual location picker coming soon';

  @override
  String get getPreciseLocation => 'Get your precise location';
}
