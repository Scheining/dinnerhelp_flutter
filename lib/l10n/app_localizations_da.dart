// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Danish (`da`).
class AppLocalizationsDa extends AppLocalizations {
  AppLocalizationsDa([String locale = 'da']) : super(locale);

  @override
  String get appTitle => 'DinnerHelp';

  @override
  String get home => 'Hjem';

  @override
  String get search => 'Søg';

  @override
  String get bookings => 'Bookinger';

  @override
  String get messages => 'Beskeder';

  @override
  String get profile => 'Profil';

  @override
  String get availableChefsNearYou => 'Kokke i nærheden';

  @override
  String get popularChefsInRegion => 'Populære kokke i dit område';

  @override
  String get seeAll => 'Se alle';

  @override
  String get featuredChefs => 'Udvalgte DinnerHelpers';

  @override
  String get bookChef => 'Book DinnerHelper';

  @override
  String dkkPerHour(int rate) {
    return '$rate kr./time';
  }

  @override
  String kmAway(double distance) {
    final intl.NumberFormat distanceNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String distanceString = distanceNumberFormat.format(distance);

    return '$distanceString km væk';
  }

  @override
  String reviews(int count) {
    return '$count anmeldelser';
  }

  @override
  String guests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personer',
      one: '1 person',
    );
    return '$_temp0';
  }

  @override
  String get noMessagesYet => 'Ingen beskeder endnu';

  @override
  String get startConversationWithChef => 'Start en samtale med en kok';

  @override
  String get upcoming => 'Kommende';

  @override
  String get past => 'Tidligere';

  @override
  String get cancelled => 'Annulleret';

  @override
  String get noUpcomingBookings => 'Ingen kommende bookinger';

  @override
  String get noPastBookings => 'Ingen tidligere bookinger';

  @override
  String get noCancelledBookings => 'Ingen annullerede bookinger';

  @override
  String get busy => 'Optaget';

  @override
  String get verified => 'Verificeret';

  @override
  String get bookingDetails => 'Booking detaljer';

  @override
  String get date => 'Dato';

  @override
  String get time => 'Tid';

  @override
  String get address => 'Adresse';

  @override
  String get specialRequests => 'Særlige ønsker';

  @override
  String get priceBreakdown => 'Prisoversigt';

  @override
  String get basePrice => 'Grundpris';

  @override
  String get serviceFee => 'Servicegebyr';

  @override
  String get tax => 'Moms';

  @override
  String get total => 'Total';

  @override
  String get close => 'Luk';

  @override
  String get currentLocation => 'Nuværende placering';

  @override
  String get locationPermissionRequired => 'Placeringstilladelse påkrævet';

  @override
  String get locationServicesDisabled => 'Placeringstjenester er deaktiveret';

  @override
  String get january => 'Jan';

  @override
  String get february => 'Feb';

  @override
  String get march => 'Mar';

  @override
  String get april => 'Apr';

  @override
  String get may => 'Maj';

  @override
  String get june => 'Jun';

  @override
  String get july => 'Jul';

  @override
  String get august => 'Aug';

  @override
  String get september => 'Sep';

  @override
  String get october => 'Okt';

  @override
  String get november => 'Nov';

  @override
  String get december => 'Dec';

  @override
  String get monday => 'Man';

  @override
  String get tuesday => 'Tir';

  @override
  String get wednesday => 'Ons';

  @override
  String get thursday => 'Tor';

  @override
  String get friday => 'Fre';

  @override
  String get saturday => 'Lør';

  @override
  String get sunday => 'Søn';

  @override
  String get yesterday => 'I går';

  @override
  String get now => 'nu';

  @override
  String minutesAgo(int count) {
    return '${count}m';
  }

  @override
  String hoursAgo(int count) {
    return '${count}t';
  }

  @override
  String daysAgo(int count) {
    return '${count}d';
  }

  @override
  String get notificationPreferences => 'Notifikationsindstillinger';

  @override
  String get notifications => 'Notifikationer';

  @override
  String get myBookings => 'Mine bookinger';

  @override
  String get upcomingTab => 'Kommende';

  @override
  String get pastTab => 'Tidligere';

  @override
  String get cancelledTab => 'Annulleret';

  @override
  String get viewDetails => 'Se detaljer';

  @override
  String get cancelBooking => 'Annuller';

  @override
  String get cancelBookingTitle => 'Annuller booking';

  @override
  String get cancelBookingConfirmation =>
      'Er du sikker på, at du vil annullere denne booking?';

  @override
  String get keepBooking => 'Behold booking';

  @override
  String get yesCancel => 'Ja, annuller';

  @override
  String get bookingCancelledSuccess =>
      'Booking annulleret og refundering er påbegyndt';

  @override
  String get errorCancellingBooking => 'Fejl ved annullering';

  @override
  String get tryAgain => 'Prøv igen';

  @override
  String get errorLoadingBookings => 'Fejl ved indlæsning af bookinger';

  @override
  String get refundNotice =>
      'Bemærk: Du vil modtage fuld refundering, da der er mere end 48 timer til bookingen.';

  @override
  String get findYourNextChef => 'Find din næste madoplevelse';

  @override
  String get startExploring => 'Udforsk kokke';

  @override
  String get bookingStatus => 'Status';

  @override
  String get pending => 'Afventer';

  @override
  String get confirmed => 'Bekræftet';

  @override
  String get completed => 'Gennemført';

  @override
  String get inProgress => 'I gang';

  @override
  String get disputed => 'Disputeret';

  @override
  String get refunded => 'Refunderet';

  @override
  String guestCount(int count) {
    return '$count personer';
  }

  @override
  String get paymentMethods => 'Betalingsmetoder';

  @override
  String get savedCards => 'Gemte kort';

  @override
  String get noPaymentMethods => 'Ingen betalingsmetoder';

  @override
  String get addCard => 'Tilføj kort';

  @override
  String get adding => 'Tilføjer...';

  @override
  String get removeCard => 'Fjern kort';

  @override
  String get cardRemoved => 'Kort fjernet';

  @override
  String get cardRemovedSuccessfully => 'Kort fjernet succesfuldt';

  @override
  String get defaultCard => 'Standard';

  @override
  String get expires => 'Udløber';

  @override
  String get setAsDefault => 'Sæt som standard';

  @override
  String get defaultPaymentMethodUpdated =>
      'Standard betalingsmetode opdateret';

  @override
  String areYouSureRemoveCard(String last4) {
    return 'Er du sikker på, at du vil fjerne kortet der slutter på $last4?';
  }

  @override
  String failedToRemoveCard(String message) {
    return 'Kunne ikke fjerne kort: $message';
  }

  @override
  String failedToSetDefault(String message) {
    return 'Kunne ikke sætte som standard: $message';
  }

  @override
  String get cardAddedSuccessfully => 'Kort tilføjet succesfuldt';

  @override
  String get paymentSetupFailed => 'Betalingsopsætning mislykkedes';

  @override
  String get cardNickname => 'Kort kaldenavn (valgfrit)';

  @override
  String get giveCardNickname =>
      'Giv dette kort et kaldenavn for nemt at identificere det';

  @override
  String get skip => 'Spring over';

  @override
  String get save => 'Gem';

  @override
  String get cancel => 'Annuller';

  @override
  String get remove => 'Fjern';

  @override
  String get yourPaymentInfoSecure =>
      'Dine betalingsoplysninger er krypteret og sikre';

  @override
  String get addCardToMakeBookingFaster =>
      'Tilføj et kort for at gøre booking hurtigere og nemmere';

  @override
  String cardsSaved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kort gemt',
      one: '1 kort gemt',
      zero: 'Ingen kort gemt',
    );
    return '$_temp0';
  }

  @override
  String errorLoadingPaymentMethods(String error) {
    return 'Fejl ved indlæsning af betalingsmetoder: $error';
  }

  @override
  String get retry => 'Prøv igen';

  @override
  String get personalCard => 'Personligt kort';

  @override
  String get workCard => 'Arbejdskort';

  @override
  String get expiringCard => 'Udløber snart';

  @override
  String get selectLocation => 'Vælg placering';

  @override
  String get useCurrentLocation => 'Brug nuværende placering';

  @override
  String get enterManually => 'Indtast manuelt';

  @override
  String get typeLocationOrAddress => 'Indtast by eller adresse';

  @override
  String get gettingLocation => 'Henter placering...';

  @override
  String get locationUnavailable => 'Placering utilgængelig';

  @override
  String get locationPermissionNeeded => 'Placeringstilladelse påkrævet';

  @override
  String get locationDisabled => 'Placering deaktiveret';

  @override
  String get locationTimeout => 'Placering timeout';

  @override
  String get locationError => 'Placeringsfejl';

  @override
  String get manualLocationComingSoon => 'Manuel placering kommer snart';

  @override
  String get getPreciseLocation => 'Få din præcise placering';
}
