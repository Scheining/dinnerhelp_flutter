import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homechef/core/error/failures.dart';
import '../entities/chef_alternative.dart';
import '../entities/booking_request.dart';
import '../repositories/chef_schedule_repository.dart';
import '../repositories/booking_availability_repository.dart';
import 'package:homechef/data/repositories/chef_repository.dart';
import 'package:homechef/features/search/domain/services/chef_search_service.dart';
import 'package:homechef/features/search/domain/entities/search_filters.dart';
import 'package:homechef/features/notifications/domain/services/notification_service.dart';
import 'package:homechef/features/payment/domain/services/payment_service.dart';
import 'package:homechef/features/payment/domain/entities/refund.dart';
import 'package:homechef/models/booking.dart';
import 'package:homechef/models/chef.dart';
import 'chef_unavailability_handler.dart';

class ChefUnavailabilityHandlerImpl implements ChefUnavailabilityHandler {
  final SupabaseClient _supabaseClient;
  final ChefScheduleRepository _scheduleRepository;
  final BookingAvailabilityRepository _availabilityRepository;
  final ChefRepository _chefRepository;
  final ChefSearchService _searchService;
  final NotificationService _notificationService;
  final PaymentService _paymentService;

  ChefUnavailabilityHandlerImpl({
    required SupabaseClient supabaseClient,
    required ChefScheduleRepository scheduleRepository,
    required BookingAvailabilityRepository availabilityRepository,
    required ChefRepository chefRepository,
    required ChefSearchService searchService,
    required NotificationService notificationService,
    required PaymentService paymentService,
  })  : _supabaseClient = supabaseClient,
        _scheduleRepository = scheduleRepository,
        _availabilityRepository = availabilityRepository,
        _chefRepository = chefRepository,
        _searchService = searchService,
        _notificationService = notificationService,
        _paymentService = paymentService;

  @override
  Future<Either<Failure, UnavailabilityResolution>> handleChefUnavailability({
    required String bookingId,
    required UnavailabilityReason reason,
  }) async {
    try {
      // Get booking details
      final bookingResult = await _getBookingDetails(bookingId);
      if (bookingResult.isLeft()) return bookingResult.fold((l) => Left(l), (r) => throw Exception());
      
      final booking = bookingResult.getOrElse(() => throw Exception());

      // Check if emergency (less than 24 hours)
      final isEmergency = booking.dateTime.difference(DateTime.now()).inHours < 24;

      if (isEmergency) {
        return await _handleEmergencyUnavailability(booking, reason);
      }

      // Try to find alternatives in order of preference
      // 1. Try rescheduling with same chef
      final reschedulingResult = await suggestRescheduling(
        bookingId: bookingId,
        preferredDates: _generatePreferredDates(booking.dateTime),
      );

      if (reschedulingResult.isRight()) {
        final options = reschedulingResult.getOrElse(() => []);
        if (options.isNotEmpty) {
          final bestOption = options.first;
          return Right(UnavailabilityResolution(
            bookingId: bookingId,
            type: ResolutionType.reschedule,
            newDateTime: bestOption.dateTime,
            newTimeSlot: bestOption.timeSlot,
            description: 'Rescheduled due to chef unavailability: ${reason.description}',
            requiresUserApproval: true,
            resolvedAt: DateTime.now(),
          ));
        }
      }

      // 2. Try finding alternative chefs
      final alternativeResult = await findAlternativeChefs(
        originalBooking: _bookingToRequest(booking),
        maxDistanceKm: 20.0,
      );

      if (alternativeResult.isRight()) {
        final alternatives = alternativeResult.getOrElse(() => []);
        final bestAlternative = alternatives.where((a) => a.isGoodMatch).firstOrNull;

        if (bestAlternative != null) {
          return Right(UnavailabilityResolution(
            bookingId: bookingId,
            type: ResolutionType.alternativeChef,
            alternativeChefId: bestAlternative.chefId,
            description: 'Alternative chef found: ${bestAlternative.chefName}',
            requiresUserApproval: true,
            resolvedAt: DateTime.now(),
          ));
        }
      }

      // 3. Offer refund with service credit
      final refundAmount = await _calculateRefundAmount(bookingId);
      final compensationAmount = (refundAmount * 0.1).round(); // 10% service credit

      return Right(UnavailabilityResolution(
        bookingId: bookingId,
        type: ResolutionType.partialRefundWithCredit,
        refundAmount: refundAmount,
        compensationAmount: compensationAmount,
        description: 'Full refund plus ${compensationAmount ~/ 100} DKK service credit for inconvenience',
        requiresUserApproval: false,
        resolvedAt: DateTime.now(),
      ));

    } catch (e) {
      return const Left(ChefUnavailableFailure('Failed to handle chef unavailability'));
    }
  }

  @override
  Future<Either<Failure, List<ChefAlternative>>> findAlternativeChefs({
    required BookingRequest originalBooking,
    required double maxDistanceKm,
    int maxAlternatives = 5,
  }) async {
    try {
      // Get original chef details for comparison
      final originalChef = await _chefRepository.getChefById(originalBooking.chefId);
      if (originalChef == null) {
        return const Left(ServerFailure('Original chef not found'));
      }

      // Calculate duration from start and end time
      final startHour = int.parse(originalBooking.startTime.split(':')[0]);
      final startMinute = int.parse(originalBooking.startTime.split(':')[1]);
      final endHour = int.parse(originalBooking.endTime.split(':')[0]);
      final endMinute = int.parse(originalBooking.endTime.split(':')[1]);
      final durationMinutes = (endHour * 60 + endMinute) - (startHour * 60 + startMinute);
      final duration = Duration(minutes: durationMinutes);

      // Search for available chefs in the area
      final searchFilters = SearchFilters(
        cuisineTypes: originalChef.cuisineTypes,
        maxDistanceKm: maxDistanceKm,
        minRating: 4.0,
        availableOnly: true,
      );
      
      final searchResult = await _searchService.searchAvailableChefs(
        date: originalBooking.date,
        startTime: originalBooking.startTime,
        duration: duration,
        numberOfGuests: originalBooking.numberOfGuests,
        filters: searchFilters,
      );

      if (searchResult.isLeft()) {
        return searchResult.fold((l) => Left(l), (r) => throw Exception());
      }

      final availableChefs = searchResult.getOrElse(() => []);

      // Convert to alternatives and calculate match scores
      final alternatives = <ChefAlternative>[];

      for (final result in availableChefs.take(maxAlternatives)) {
        if (result.chef.id == originalBooking.chefId) continue; // Skip original chef

        // Get available slots for this chef
        final availabilityResult = await _availabilityRepository.getAvailableTimeSlots(
          chefId: result.chef.id,
          date: originalBooking.date,
          duration: duration,
          numberOfGuests: originalBooking.numberOfGuests,
        );

        final availableSlots = availabilityResult.fold(
          (failure) => <String>[],
          (slots) => slots.map((slot) => '${slot.startTime}-${slot.endTime}').toList(),
        );

        // Calculate match score
        final matchScore = _calculateMatchScore(
          originalChef: originalChef,
          alternativeChef: result.chef,
          originalBooking: originalBooking,
          distanceKm: result.distance ?? 0.0,
          availableSlots: availableSlots,
        );

        alternatives.add(ChefAlternative(
          chefId: result.chef.id,
          chefName: result.chef.name,
          profileImageUrl: result.chef.profileImage,
          rating: result.chef.rating,
          reviewCount: result.chef.reviewCount,
          hourlyRate: result.chef.hourlyRate,
          distanceKm: result.distance ?? 0.0,
          cuisines: result.chef.cuisineTypes,
          availableSlots: availableSlots,
          matchScore: matchScore,
        ));
      }

      // Sort by match score
      alternatives.sort((a, b) => b.matchScore.overallScore.compareTo(a.matchScore.overallScore));

      return Right(alternatives);

    } catch (e) {
      return const Left(NoAlternativeChefFailure('Failed to find alternative chefs'));
    }
  }

  @override
  Future<Either<Failure, List<ReschedulingOption>>> suggestRescheduling({
    required String bookingId,
    required List<DateTime> preferredDates,
  }) async {
    try {
      // Get booking details directly from database
      final response = await _supabaseClient
          .from('bookings')
          .select('*')
          .eq('id', bookingId)
          .single();
          
      final chefId = response['chef_id'] as String;
      final startTime = response['start_time'] as String;
      final endTime = response['end_time'] as String;
      final numberOfGuests = response['number_of_guests'] as int;
      
      final options = <ReschedulingOption>[];

      for (final preferredDate in preferredDates) {
        // Calculate duration from booking times
        final startHour = int.parse(startTime.split(':')[0]);
        final startMinute = int.parse(startTime.split(':')[1]);
        final endHour = int.parse(endTime.split(':')[0]);
        final endMinute = int.parse(endTime.split(':')[1]);
        final durationMinutes = (endHour * 60 + endMinute) - (startHour * 60 + startMinute);
        final duration = Duration(minutes: durationMinutes);
        
        final availabilityResult = await _availabilityRepository.getAvailableTimeSlots(
          chefId: chefId,
          date: preferredDate,
          duration: duration,
          numberOfGuests: numberOfGuests,
        );

        if (availabilityResult.isRight()) {
          final slots = availabilityResult.getOrElse(() => []);
          
          for (final slot in slots) {
            // Calculate probability score based on how close to original time
            final originalHour = int.parse(startTime.split(':')[0]);
            final slotHour = slot.startTime.hour;
            final timeDiff = (originalHour - slotHour).abs();
            final probabilityScore = (24 - timeDiff) / 24.0;

            options.add(ReschedulingOption(
              dateTime: DateTime(
                preferredDate.year,
                preferredDate.month,
                preferredDate.day,
                slot.startTime.hour,
                slot.startTime.minute,
              ),
              timeSlot: '${slot.startTime.hour.toString().padLeft(2, '0')}:${slot.startTime.minute.toString().padLeft(2, '0')}-${slot.endTime.hour.toString().padLeft(2, '0')}:${slot.endTime.minute.toString().padLeft(2, '0')}',
              isAvailable: true,
              probabilityScore: probabilityScore,
              notes: _getReschedulingNotes(preferredDate, DateTime.parse(response['date'] + ' ' + startTime)),
            ));
          }
        }
      }

      // Sort by probability score
      options.sort((a, b) => b.probabilityScore.compareTo(a.probabilityScore));

      return Right(options.take(10).toList());

    } catch (e) {
      return const Left(ReschedulingOptionsFailure('Failed to suggest rescheduling options'));
    }
  }

  @override
  Future<Either<Failure, Unit>> notifyAffectedParties({
    required String bookingId,
    required UnavailabilityResolution solution,
  }) async {
    try {
      final bookingResult = await _getBookingDetails(bookingId);
      if (bookingResult.isLeft()) return bookingResult.fold((l) => Left(l), (r) => throw Exception());
      
      final booking = bookingResult.getOrElse(() => throw Exception());

      // Notify user about booking modification
      await _notificationService.sendBookingModification(
        bookingId,
        {
          'message': _generateUserNotificationMessage(solution),
          'resolution_type': solution.type.name,
        },
      );

      // Notify chef if applicable
      if (solution.alternativeChefId != null) {
        // Use booking modification notification for alternative chef
        await _notificationService.sendBookingModification(
          bookingId,
          {
            'message': 'You have been selected as an alternative chef for a booking',
            'alternative_chef_id': solution.alternativeChefId,
          },
        );
      }

      // Notify original chef
      await _notificationService.sendBookingModification(
        bookingId,
        {
          'message': 'Your unavailability has been resolved: ${solution.description}',
          'resolution_type': solution.type.name,
        },
      );

      return const Right(unit);

    } catch (e) {
      return const Left(NotificationSendFailure('Failed to notify affected parties'));
    }
  }

  @override
  Future<Either<Failure, EmergencyCancellationResult>> processEmergencyCancellation({
    required String bookingId,
    required UnavailabilityReason reason,
  }) async {
    try {
      final bookingResult = await _getBookingDetails(bookingId);
      if (bookingResult.isLeft()) return bookingResult.fold((l) => Left(l), (r) => throw Exception());
      
      final booking = bookingResult.getOrElse(() => throw Exception());

      // Calculate full refund
      final refundAmount = await _calculateRefundAmount(bookingId);
      
      // Calculate compensation based on urgency and reason
      final compensationAmount = _calculateEmergencyCompensation(booking, reason);

      // Process refund
      final refundResult = await _paymentService.refundPayment(
        bookingId: bookingId,
        amount: refundAmount,
        reason: RefundReason.chefCancellation,
        description: 'Emergency chef unavailability: ${reason.description}',
      );

      if (refundResult.isLeft()) {
        return refundResult.fold((l) => Left(l), (r) => throw Exception());
      }

      // Update booking status
      await _supabaseClient
          .from('bookings')
          .update({
            'status': 'cancelled',
            'cancellation_reason': reason.description,
            'refund_amount': refundAmount,
            'compensation_amount': compensationAmount,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', bookingId);

      // Create service credit for compensation
      if (compensationAmount > 0) {
        await _supabaseClient
            .from('user_credits')
            .insert({
              'user_id': booking.userId,
              'amount': compensationAmount,
              'reason': 'Emergency cancellation compensation',
              'expires_at': DateTime.now().add(const Duration(days: 365)).toIso8601String(),
            });
      }

      final actionsNotified = ['user', 'chef', 'admin'];

      // Send notifications
      await notifyAffectedParties(
        bookingId: bookingId,
        solution: UnavailabilityResolution(
          bookingId: bookingId,
          type: ResolutionType.emergency,
          refundAmount: refundAmount,
          compensationAmount: compensationAmount,
          description: 'Emergency cancellation: ${reason.description}',
          resolvedAt: DateTime.now(),
        ),
      );

      return Right(EmergencyCancellationResult(
        bookingId: bookingId,
        cancelled: true,
        refundAmount: refundAmount,
        compensationAmount: compensationAmount,
        reason: reason.description,
        actionsNotified: actionsNotified,
        processedAt: DateTime.now(),
      ));

    } catch (e) {
      return const Left(EmergencyCancellationFailure('Failed to process emergency cancellation'));
    }
  }

  // Private helper methods

  Future<Either<Failure, Booking>> _getBookingDetails(String bookingId) async {
    try {
      final response = await _supabaseClient
          .from('bookings')
          .select('*')
          .eq('id', bookingId)
          .single();

      // Convert to Booking object (simplified)
      final booking = Booking(
        id: response['id'],
        chefId: response['chef_id'],
        chefName: response['chef_name'] ?? '',
        userId: response['user_id'],
        dateTime: DateTime.parse(response['date'] + ' ' + response['start_time']),
        guestCount: response['number_of_guests'],
        address: response['address'] ?? '',
        basePrice: (response['total_amount'] as num).toDouble(),
        serviceFee: 0.0,
        tax: 0.0,
        totalPrice: (response['total_amount'] as num).toDouble(),
        status: _parseBookingStatus(response['status']),
        paymentStatus: _parsePaymentStatus(response['payment_status']),
        stripePaymentIntentId: response['stripe_payment_intent_id'],
        createdAt: DateTime.parse(response['created_at']),
      );

      return Right(booking);
    } catch (e) {
      return const Left(BookingNotFoundFailure('Booking not found'));
    }
  }

  BookingStatus _parseBookingStatus(String status) {
    switch (status) {
      case 'pending': return BookingStatus.pending;
      case 'confirmed': return BookingStatus.confirmed;
      case 'in_progress': return BookingStatus.inProgress;
      case 'completed': return BookingStatus.completed;
      case 'cancelled': return BookingStatus.cancelled;
      case 'disputed': return BookingStatus.disputed;
      case 'refunded': return BookingStatus.refunded;
      default: return BookingStatus.pending;
    }
  }

  PaymentStatus _parsePaymentStatus(String status) {
    switch (status) {
      case 'pending': return PaymentStatus.pending;
      case 'authorized': return PaymentStatus.authorized;
      case 'succeeded': return PaymentStatus.succeeded;
      case 'failed': return PaymentStatus.failed;
      case 'refunded': return PaymentStatus.refunded;
      case 'partially_refunded': return PaymentStatus.partiallyRefunded;
      case 'disputed': return PaymentStatus.disputed;
      default: return PaymentStatus.pending;
    }
  }

  Future<Either<Failure, UnavailabilityResolution>> _handleEmergencyUnavailability(
    Booking booking,
    UnavailabilityReason reason,
  ) async {
    final emergencyResult = await processEmergencyCancellation(
      bookingId: booking.id,
      reason: reason,
    );

    return emergencyResult.fold(
      (failure) => Left(failure),
      (result) => Right(UnavailabilityResolution(
        bookingId: booking.id,
        type: ResolutionType.emergency,
        refundAmount: result.refundAmount,
        compensationAmount: result.compensationAmount,
        description: result.reason,
        resolvedAt: result.processedAt,
      )),
    );
  }

  List<DateTime> _generatePreferredDates(DateTime originalDate) {
    final dates = <DateTime>[];
    final now = DateTime.now();
    
    // Add next 14 days as preferred dates
    for (int i = 1; i <= 14; i++) {
      final date = now.add(Duration(days: i));
      if (date.isAfter(originalDate)) {
        dates.add(date);
      }
    }
    
    return dates;
  }

  BookingRequest _bookingToRequest(Booking booking) {
    final time = booking.dateTime;
    return BookingRequest(
      userId: booking.userId,
      chefId: booking.chefId,
      date: DateTime(time.year, time.month, time.day),
      startTime: '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      endTime: '${(time.hour + 3).toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}', // Assume 3-hour booking
      numberOfGuests: booking.guestCount,
    );
  }

  AlternativeMatchScore _calculateMatchScore({
    required Chef originalChef,
    required Chef alternativeChef,
    required BookingRequest originalBooking,
    required double distanceKm,
    required List<String> availableSlots,
  }) {
    // Cuisine match (1.0 if any cuisine matches, 0.5 if similar, 0.0 if none)
    final cuisineMatch = _calculateCuisineMatch(originalChef.cuisineTypes, alternativeChef.cuisineTypes);
    
    // Location match (1.0 if < 5km, decreasing to 0.0 at maxDistance)
    final locationMatch = distanceKm <= 5.0 ? 1.0 : (1.0 - (distanceKm - 5.0) / 15.0).clamp(0.0, 1.0);
    
    // Price match (1.0 if same price, decreasing with difference)
    final priceDiff = (alternativeChef.hourlyRate - originalChef.hourlyRate).abs();
    final priceMatch = (1.0 - (priceDiff / originalChef.hourlyRate)).clamp(0.0, 1.0);
    
    // Rating match (normalized to 0.0-1.0)
    final ratingMatch = (alternativeChef.rating / 5.0).clamp(0.0, 1.0);
    
    // Availability match (1.0 if has slots, 0.0 if none)
    final availabilityMatch = availableSlots.isNotEmpty ? 1.0 : 0.0;

    return AlternativeMatchScore.calculate(
      cuisineMatch: cuisineMatch,
      locationMatch: locationMatch,
      priceMatch: priceMatch,
      ratingMatch: ratingMatch,
      availabilityMatch: availabilityMatch,
    );
  }

  double _calculateCuisineMatch(List<String> original, List<String> alternative) {
    final intersection = original.toSet().intersection(alternative.toSet());
    if (intersection.isNotEmpty) return 1.0;
    
    // Check for similar cuisines (simplified)
    final similarCuisines = {
      'Italian': ['Mediterranean', 'French'],
      'French': ['Italian', 'European'],
      'Asian': ['Chinese', 'Thai', 'Japanese'],
      'Indian': ['Asian', 'Fusion'],
    };
    
    for (final orig in original) {
      final similar = similarCuisines[orig] ?? [];
      if (alternative.any((alt) => similar.contains(alt))) {
        return 0.7;
      }
    }
    
    return 0.0;
  }

  String? _getReschedulingNotes(DateTime newDate, DateTime originalDate) {
    final dayDiff = newDate.difference(originalDate).inDays;
    if (dayDiff == 0) return 'Same day rescheduling';
    if (dayDiff == 1) return 'Next day option';
    if (dayDiff <= 7) return 'Within same week';
    return 'Alternative date option';
  }

  String _generateUserNotificationMessage(UnavailabilityResolution solution) {
    switch (solution.type) {
      case ResolutionType.alternativeChef:
        return 'We found an alternative chef for your booking. Please review and confirm.';
      case ResolutionType.reschedule:
        return 'Your chef is available on alternative dates. Please choose your preferred option.';
      case ResolutionType.fullRefund:
        return 'Unfortunately, your booking has been cancelled. You will receive a full refund.';
      case ResolutionType.partialRefundWithCredit:
        return 'Your booking has been cancelled with full refund plus service credit for the inconvenience.';
      case ResolutionType.emergency:
        return 'Emergency cancellation processed. Refund and compensation are being processed.';
    }
  }

  Future<int> _calculateRefundAmount(String bookingId) async {
    final response = await _supabaseClient
        .from('bookings')
        .select('total_amount')
        .eq('id', bookingId)
        .single();
    
    return (response['total_amount'] as num).toInt();
  }

  int _calculateEmergencyCompensation(Booking booking, UnavailabilityReason reason) {
    final baseAmount = booking.totalPrice.toInt();
    
    // Base compensation of 10% for inconvenience
    double compensationRate = 0.10;
    
    // Increase compensation based on urgency and reason
    final hoursUntilBooking = booking.dateTime.difference(DateTime.now()).inHours;
    
    if (hoursUntilBooking < 2) compensationRate = 0.25; // 25% if less than 2 hours
    else if (hoursUntilBooking < 6) compensationRate = 0.20; // 20% if less than 6 hours
    else if (hoursUntilBooking < 12) compensationRate = 0.15; // 15% if less than 12 hours
    
    // Additional compensation for emergency reasons
    if (reason.isEmergency) {
      compensationRate += 0.05; // Additional 5% for emergency
    }
    
    return (baseAmount * compensationRate).round();
  }
}