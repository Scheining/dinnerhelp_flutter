import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_da.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('da')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'DinnerHelp'**
  String get appTitle;

  /// Home navigation item
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Search navigation item
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Bookings navigation item
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get bookings;

  /// Messages navigation item
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// Profile navigation item
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Section title for nearby available chefs
  ///
  /// In en, this message translates to:
  /// **'Available Chefs Near You'**
  String get availableChefsNearYou;

  /// Section title for popular regional chefs
  ///
  /// In en, this message translates to:
  /// **'Popular Chefs in Your Region'**
  String get popularChefsInRegion;

  /// Link to see all items
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// Section title for featured chefs
  ///
  /// In en, this message translates to:
  /// **'Featured Chefs'**
  String get featuredChefs;

  /// Button to book a chef
  ///
  /// In en, this message translates to:
  /// **'Book Chef'**
  String get bookChef;

  /// Hourly rate format
  ///
  /// In en, this message translates to:
  /// **'{rate} DKK/hr'**
  String dkkPerHour(int rate);

  /// Distance format
  ///
  /// In en, this message translates to:
  /// **'{distance} km away'**
  String kmAway(double distance);

  /// Review count format
  ///
  /// In en, this message translates to:
  /// **'{count} reviews'**
  String reviews(int count);

  /// Guest count with plural support
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 guest} other{{count} guests}}'**
  String guests(int count);

  /// Empty state for messages
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// Prompt to start messaging
  ///
  /// In en, this message translates to:
  /// **'Start a conversation with a chef'**
  String get startConversationWithChef;

  /// Tab for upcoming bookings
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// Tab for past bookings
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get past;

  /// Tab for cancelled bookings
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// Empty state for upcoming bookings
  ///
  /// In en, this message translates to:
  /// **'No upcoming bookings'**
  String get noUpcomingBookings;

  /// Empty state for past bookings
  ///
  /// In en, this message translates to:
  /// **'No past bookings'**
  String get noPastBookings;

  /// Empty state for cancelled bookings
  ///
  /// In en, this message translates to:
  /// **'No cancelled bookings'**
  String get noCancelledBookings;

  /// Chef availability status
  ///
  /// In en, this message translates to:
  /// **'Busy'**
  String get busy;

  /// Chef verification status
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// Booking details dialog title
  ///
  /// In en, this message translates to:
  /// **'Booking Details'**
  String get bookingDetails;

  /// Date label
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Time label
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// Address label
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// Special requests label
  ///
  /// In en, this message translates to:
  /// **'Special Requests'**
  String get specialRequests;

  /// Price breakdown section title
  ///
  /// In en, this message translates to:
  /// **'Price Breakdown'**
  String get priceBreakdown;

  /// Base price label
  ///
  /// In en, this message translates to:
  /// **'Base Price'**
  String get basePrice;

  /// Service fee label
  ///
  /// In en, this message translates to:
  /// **'Service Fee'**
  String get serviceFee;

  /// Tax label
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// Total price label
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// Close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Current location option
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get currentLocation;

  /// Location permission message
  ///
  /// In en, this message translates to:
  /// **'Location permission required'**
  String get locationPermissionRequired;

  /// Location services disabled message
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled'**
  String get locationServicesDisabled;

  /// January abbreviation
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get january;

  /// February abbreviation
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get february;

  /// March abbreviation
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get march;

  /// April abbreviation
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get april;

  /// May abbreviation
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// June abbreviation
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get june;

  /// July abbreviation
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get july;

  /// August abbreviation
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get august;

  /// September abbreviation
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get september;

  /// October abbreviation
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get october;

  /// November abbreviation
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get november;

  /// December abbreviation
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get december;

  /// Monday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get monday;

  /// Tuesday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesday;

  /// Wednesday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesday;

  /// Thursday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursday;

  /// Friday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get friday;

  /// Saturday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get saturday;

  /// Sunday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sunday;

  /// Yesterday time label
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Now time label
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get now;

  /// Minutes ago format
  ///
  /// In en, this message translates to:
  /// **'{count}m'**
  String minutesAgo(int count);

  /// Hours ago format
  ///
  /// In en, this message translates to:
  /// **'{count}h'**
  String hoursAgo(int count);

  /// Days ago format
  ///
  /// In en, this message translates to:
  /// **'{count}d'**
  String daysAgo(int count);

  /// Notification preferences page title
  ///
  /// In en, this message translates to:
  /// **'Notification Preferences'**
  String get notificationPreferences;

  /// Notifications page title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// My bookings page title
  ///
  /// In en, this message translates to:
  /// **'My Bookings'**
  String get myBookings;

  /// Upcoming bookings tab
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcomingTab;

  /// Past bookings tab
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get pastTab;

  /// Cancelled bookings tab
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelledTab;

  /// View booking details button
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// Cancel booking button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelBooking;

  /// Cancel booking dialog title
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking'**
  String get cancelBookingTitle;

  /// Cancel booking confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this booking?'**
  String get cancelBookingConfirmation;

  /// Keep booking button
  ///
  /// In en, this message translates to:
  /// **'Keep Booking'**
  String get keepBooking;

  /// Confirm cancellation button
  ///
  /// In en, this message translates to:
  /// **'Yes, Cancel'**
  String get yesCancel;

  /// Booking cancellation success message
  ///
  /// In en, this message translates to:
  /// **'Booking cancelled and refund initiated'**
  String get bookingCancelledSuccess;

  /// Error cancelling booking message
  ///
  /// In en, this message translates to:
  /// **'Error cancelling'**
  String get errorCancellingBooking;

  /// Try again button
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Error loading bookings message
  ///
  /// In en, this message translates to:
  /// **'Error loading bookings'**
  String get errorLoadingBookings;

  /// Refund notice message
  ///
  /// In en, this message translates to:
  /// **'Note: You will receive a full refund as there are more than 48 hours until the booking.'**
  String get refundNotice;

  /// Find next chef prompt
  ///
  /// In en, this message translates to:
  /// **'Find your next dining experience'**
  String get findYourNextChef;

  /// Start exploring button
  ///
  /// In en, this message translates to:
  /// **'Explore Chefs'**
  String get startExploring;

  /// Booking status label
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get bookingStatus;

  /// Pending booking status
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// Confirmed booking status
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// Completed booking status
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// In progress booking status
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// Disputed booking status
  ///
  /// In en, this message translates to:
  /// **'Disputed'**
  String get disputed;

  /// Refunded booking status
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get refunded;

  /// Guest count format
  ///
  /// In en, this message translates to:
  /// **'{count} guests'**
  String guestCount(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['da', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'da':
      return AppLocalizationsDa();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
