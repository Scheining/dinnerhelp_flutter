import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homechef/core/error/failures.dart';
import '../entities/booking_modification.dart';
import '../repositories/chef_schedule_repository.dart';
import 'package:homechef/features/payment/domain/services/payment_service.dart';
import 'package:homechef/features/notifications/domain/services/notification_service.dart';
import 'booking_modification_service.dart';

class BookingModificationServiceImpl implements BookingModificationService {
  final SupabaseClient _supabaseClient;
  final ChefScheduleRepository _scheduleRepository;
  final PaymentService _paymentService;
  final NotificationService _notificationService;

  // Business rules configuration
  static const int _standardDeadlineHours = 24;
  static const int _lateModificationFeePercentage = 15;
  static const int _maxGuestIncrease = 4;
  static const int _maxGuestDecrease = 2;

  BookingModificationServiceImpl({
    required SupabaseClient supabaseClient,
    required ChefScheduleRepository scheduleRepository,
    required PaymentService paymentService,
    required NotificationService notificationService,
  })  : _supabaseClient = supabaseClient,
        _scheduleRepository = scheduleRepository,
        _paymentService = paymentService,
        _notificationService = notificationService;

  @override
  Future<Either<Failure, ModificationValidationResult>> validateModificationRequest({
    required String bookingId,
    required List<BookingChange> changes,
    required DateTime requestTime,
  }) async {
    try {
      // Get booking details
      final bookingResult = await _getBookingDetails(bookingId);
      if (bookingResult.isLeft()) {
        return bookingResult.fold((l) => Left(l), (r) => throw Exception());
      }
      
      final booking = bookingResult.getOrElse(() => throw Exception());
      final violations = <String>[];
      final warnings = <String>[];

      // Calculate deadline info
      final deadlineInfo = _calculateDeadlineInfo(booking.dateTime, requestTime);

      // Validate each change
      for (final change in changes) {
        final changeValidation = await _validateIndividualChange(change, booking);
        violations.addAll(changeValidation.violations);
        warnings.addAll(changeValidation.warnings);
      }

      // Check booking status
      if (!_isBookingModifiable(booking.status)) {
        violations.add('Booking cannot be modified in current status: ${booking.status}');
      }

      // Check timing constraints
      if (!deadlineInfo.isWithinDeadline && !_isEmergencyModification(changes)) {
        violations.add('Modification request is past the 24-hour deadline');
      }

      // Check chef availability for date/time changes
      final hasDateTimeChange = changes.any((c) => c.type == ChangeType.dateTime);
      if (hasDateTimeChange && deadlineInfo.isWithinDeadline) {
        final availability = await _validateChefAvailability(bookingId, changes);
        if (!availability.isAvailable) {
          violations.add('Chef is not available for the requested time slot');
        }
      }

      final isValid = violations.isEmpty;

      return Right(ModificationValidationResult(
        isValid: isValid,
        violations: violations,
        deadlineInfo: deadlineInfo,
        warnings: warnings,
      ));

    } catch (e) {
      return const Left(ValidationFailure('Failed to validate modification request'));
    }
  }

  @override
  Future<Either<Failure, BookingModificationRequest>> processDateTimeChange({
    required String bookingId,
    required DateTime newDateTime,
    required String? newTimeSlot,
    required String requestedBy,
    String? reason,
  }) async {
    try {
      final bookingResult = await _getBookingDetails(bookingId);
      if (bookingResult.isLeft()) {
        return bookingResult.fold((l) => Left(l), (r) => throw Exception());
      }
      
      final booking = bookingResult.getOrElse(() => throw Exception());

      // Create the change
      final change = BookingChange(
        type: ChangeType.dateTime,
        fieldName: 'dateTime',
        oldValue: booking.dateTime,
        newValue: newDateTime,
        description: 'Change booking date and time from ${_formatDateTime(booking.dateTime)} to ${_formatDateTime(newDateTime)}',
        priceImpact: await _calculateDateTimeChangePriceImpact(booking, newDateTime),
      );

      // Validate the change
      final validationResult = await validateModificationRequest(
        bookingId: bookingId,
        changes: [change],
        requestTime: DateTime.now(),
      );

      if (validationResult.isLeft()) {
        return validationResult.fold((l) => Left(l), (r) => throw Exception());
      }

      final validation = validationResult.getOrElse(() => throw Exception());
      if (!validation.isValid) {
        return Left(ModificationNotAllowedFailure(validation.violations.join(', ')));
      }

      // Create modification request
      final request = BookingModificationRequest(
        bookingId: bookingId,
        requestedBy: requestedBy,
        requestedAt: DateTime.now(),
        changes: [change],
        reason: reason,
        isEmergencyRequest: !validation.deadlineInfo.isWithinDeadline,
      );

      // Save to database
      await _saveModificationRequest(request);

      // Send notifications
      await _notifyModificationRequest(request, booking);

      return Right(request);

    } catch (e) {
      return Left(BookingModificationFailure('Failed to process date/time change: $e'));
    }
  }

  @override
  Future<Either<Failure, BookingModificationRequest>> processDishesChange({
    required String bookingId,
    required List<String> newDishIds,
    required String requestedBy,
    String? reason,
  }) async {
    try {
      final bookingResult = await _getBookingDetails(bookingId);
      if (bookingResult.isLeft()) {
        return bookingResult.fold((l) => Left(l), (r) => throw Exception());
      }
      
      final booking = bookingResult.getOrElse(() => throw Exception());

      // Get current dishes
      final currentDishes = await _getCurrentBookingDishes(bookingId);

      // Create the change
      final change = BookingChange(
        type: ChangeType.dishes,
        fieldName: 'selectedDishes',
        oldValue: currentDishes,
        newValue: newDishIds,
        description: 'Change selected dishes for the booking',
        priceImpact: await _calculateDishesChangePriceImpact(currentDishes, newDishIds),
      );

      // Validate the change
      final validationResult = await validateModificationRequest(
        bookingId: bookingId,
        changes: [change],
        requestTime: DateTime.now(),
      );

      if (validationResult.isLeft()) {
        return validationResult.fold((l) => Left(l), (r) => throw Exception());
      }

      final validation = validationResult.getOrElse(() => throw Exception());
      if (!validation.isValid) {
        return Left(ModificationNotAllowedFailure(validation.violations.join(', ')));
      }

      // Create modification request
      final request = BookingModificationRequest(
        bookingId: bookingId,
        requestedBy: requestedBy,
        requestedAt: DateTime.now(),
        changes: [change],
        reason: reason,
      );

      // Save to database
      await _saveModificationRequest(request);

      // Send notifications
      await _notifyModificationRequest(request, booking);

      return Right(request);

    } catch (e) {
      return Left(BookingModificationFailure('Failed to process dishes change: $e'));
    }
  }

  @override
  Future<Either<Failure, BookingModificationRequest>> processGuestCountChange({
    required String bookingId,
    required int newGuestCount,
    required String requestedBy,
    String? reason,
  }) async {
    try {
      final bookingResult = await _getBookingDetails(bookingId);
      if (bookingResult.isLeft()) {
        return bookingResult.fold((l) => Left(l), (r) => throw Exception());
      }
      
      final booking = bookingResult.getOrElse(() => throw Exception());

      // Validate guest count change
      final currentGuests = booking.guestCount;
      final difference = newGuestCount - currentGuests;

      if (difference > _maxGuestIncrease) {
        return Left(ModificationNotAllowedFailure(
          'Cannot increase guest count by more than $_maxGuestIncrease guests',
        ));
      }

      if (difference < -_maxGuestDecrease) {
        return Left(ModificationNotAllowedFailure(
          'Cannot decrease guest count by more than $_maxGuestDecrease guests',
        ));
      }

      // Create the change
      final change = BookingChange(
        type: ChangeType.guestCount,
        fieldName: 'guestCount',
        oldValue: currentGuests,
        newValue: newGuestCount,
        description: 'Change guest count from $currentGuests to $newGuestCount',
        priceImpact: await _calculateGuestCountChangePriceImpact(booking, newGuestCount),
      );

      // Validate the change
      final validationResult = await validateModificationRequest(
        bookingId: bookingId,
        changes: [change],
        requestTime: DateTime.now(),
      );

      if (validationResult.isLeft()) {
        return validationResult.fold((l) => Left(l), (r) => throw Exception());
      }

      final validation = validationResult.getOrElse(() => throw Exception());
      if (!validation.isValid) {
        return Left(ModificationNotAllowedFailure(validation.violations.join(', ')));
      }

      // Create modification request
      final request = BookingModificationRequest(
        bookingId: bookingId,
        requestedBy: requestedBy,
        requestedAt: DateTime.now(),
        changes: [change],
        reason: reason,
      );

      // Save to database
      await _saveModificationRequest(request);

      // Send notifications
      await _notifyModificationRequest(request, booking);

      return Right(request);

    } catch (e) {
      return Left(BookingModificationFailure('Failed to process guest count change: $e'));
    }
  }

  @override
  DateTime calculate24HourDeadline(DateTime bookingDateTime) {
    return bookingDateTime.subtract(const Duration(hours: _standardDeadlineHours));
  }

  @override
  Future<Either<Failure, LateModificationResult>> handleLateModificationRequest({
    required String bookingId,
    required List<BookingChange> changes,
    required String requestedBy,
    String? emergencyReason,
  }) async {
    try {
      final bookingResult = await _getBookingDetails(bookingId);
      if (bookingResult.isLeft()) {
        return bookingResult.fold((l) => Left(l), (r) => throw Exception());
      }
      
      final booking = bookingResult.getOrElse(() => throw Exception());
      final hoursUntilBooking = booking.dateTime.difference(DateTime.now()).inHours;

      // Determine if late modification is allowed
      bool allowed = false;
      String reason = '';
      int additionalFee = 0;
      List<String> conditions = [];
      bool requiresChefApproval = true;
      bool requiresAdminApproval = false;

      if (hoursUntilBooking < 2) {
        // Less than 2 hours - very restricted
        allowed = _isEmergencyModification(changes) && emergencyReason != null;
        reason = allowed 
            ? 'Emergency modification allowed due to: $emergencyReason'
            : 'Modifications not allowed less than 2 hours before booking';
        additionalFee = allowed ? (booking.totalPrice * 0.25).round() : 0;
        requiresAdminApproval = allowed;
      } else if (hoursUntilBooking < 6) {
        // 2-6 hours - limited modifications
        allowed = changes.length <= 2 && !changes.any((c) => c.type == ChangeType.dateTime);
        reason = allowed 
            ? 'Limited modifications allowed with fee and chef approval'
            : 'Date/time changes not allowed within 6 hours of booking';
        additionalFee = allowed ? (booking.totalPrice * _lateModificationFeePercentage / 100).round() : 0;
      } else if (hoursUntilBooking < 24) {
        // 6-24 hours - most modifications allowed with fee
        allowed = true;
        reason = 'Late modification allowed with additional fee';
        additionalFee = (booking.totalPrice * (_lateModificationFeePercentage / 2) / 100).round();
      }

      if (allowed) {
        conditions = [
          if (additionalFee > 0) 'Additional fee of ${additionalFee / 100} DKK applies',
          if (requiresChefApproval) 'Chef must approve the modification',
          if (requiresAdminApproval) 'Admin approval required for emergency modifications',
          'Modification may be rejected if chef cannot accommodate',
        ];
      }

      return Right(LateModificationResult(
        allowed: allowed,
        reason: reason,
        additionalFee: additionalFee,
        conditions: conditions,
        requiresChefApproval: requiresChefApproval,
        requiresAdminApproval: requiresAdminApproval,
      ));

    } catch (e) {
      return const Left(ModificationTooLateFailure('Failed to evaluate late modification request'));
    }
  }

  @override
  Future<Either<Failure, Unit>> respondToModificationRequest({
    required String requestId,
    required bool approved,
    required String respondedBy,
    String? rejectionReason,
  }) async {
    try {
      // Update request status
      await _supabaseClient
          .from('booking_modification_requests')
          .update({
            'status': approved ? 'approved' : 'rejected',
            'responded_by': respondedBy,
            'responded_at': DateTime.now().toIso8601String(),
            'rejection_reason': rejectionReason,
          })
          .eq('id', requestId);

      if (approved) {
        // Process the approved modification
        final processResult = await processApprovedModification(requestId: requestId);
        if (processResult.isLeft()) {
          return processResult.fold((l) => Left(l), (r) => throw Exception());
        }
      }

      // Send notification to user
      await _notifyModificationResponse(requestId, approved, rejectionReason);

      return const Right(unit);

    } catch (e) {
      return Left(BookingModificationFailure('Failed to respond to modification request: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BookingModificationRequest>>> getPendingModifications({
    required String userId,
    bool isChef = false,
  }) async {
    try {
      final query = _supabaseClient
          .from('booking_modification_requests')
          .select('''
            *,
            bookings!inner(*)
          ''')
          .eq('status', 'pending');

      if (isChef) {
        query.eq('bookings.chef_id', userId);
      } else {
        query.eq('requested_by', userId);
      }

      final response = await query.order('requested_at', ascending: false);

      final requests = <BookingModificationRequest>[];
      for (final data in response) {
        final request = await _convertDataToModificationRequest(data);
        if (request != null) requests.add(request);
      }

      return Right(requests);

    } catch (e) {
      return const Left(ServerFailure('Failed to get pending modifications'));
    }
  }

  @override
  Future<Either<Failure, PriceImpact>> calculatePriceImpact({
    required String bookingId,
    required List<BookingChange> changes,
  }) async {
    try {
      int totalAdditionalCost = 0;
      int totalRefundAmount = 0;
      final breakdown = <PriceBreakdown>[];
      final explanations = <String>[];

      for (final change in changes) {
        switch (change.type) {
          case ChangeType.guestCount:
            final impact = await _calculateGuestCountChangePriceImpact(
              await _getBookingDetails(bookingId).then((r) => r.getOrElse(() => throw Exception())),
              change.newValue as int,
            );
            if (impact != null) {
              totalAdditionalCost += impact.additionalCost ?? 0;
              totalRefundAmount += impact.refundAmount ?? 0;
              breakdown.addAll(impact.breakdown);
              explanations.add(impact.explanation);
            }
            break;

          case ChangeType.dishes:
            final impact = await _calculateDishesChangePriceImpact(
              change.oldValue as List<String>,
              change.newValue as List<String>,
            );
            if (impact != null) {
              totalAdditionalCost += impact.additionalCost ?? 0;
              totalRefundAmount += impact.refundAmount ?? 0;
              breakdown.addAll(impact.breakdown);
              explanations.add(impact.explanation);
            }
            break;

          case ChangeType.dateTime:
            final booking = await _getBookingDetails(bookingId).then((r) => r.getOrElse(() => throw Exception()));
            final impact = await _calculateDateTimeChangePriceImpact(
              booking,
              change.newValue as DateTime,
            );
            if (impact != null) {
              totalAdditionalCost += impact.additionalCost ?? 0;
              totalRefundAmount += impact.refundAmount ?? 0;
              breakdown.addAll(impact.breakdown);
              explanations.add(impact.explanation);
            }
            break;

          default:
            break;
        }
      }

      final explanation = explanations.join('. ');

      return Right(PriceImpact(
        additionalCost: totalAdditionalCost > 0 ? totalAdditionalCost : null,
        refundAmount: totalRefundAmount > 0 ? totalRefundAmount : null,
        explanation: explanation.isEmpty ? 'No price changes' : explanation,
        breakdown: breakdown,
      ));

    } catch (e) {
      return Left(ServiceFeeCalculationFailure('Failed to calculate price impact: $e'));
    }
  }

  @override
  Future<Either<Failure, ModificationProcessResult>> processApprovedModification({
    required String requestId,
  }) async {
    try {
      // Get modification request
      final request = await _getModificationRequestById(requestId);
      if (request == null) {
        return const Left(BookingNotFoundFailure('Modification request not found'));
      }

      final processedChanges = <String>[];
      String? paymentIntentId;
      String? refundId;

      // Calculate price impact
      final priceImpactResult = await calculatePriceImpact(
        bookingId: request.bookingId,
        changes: request.changes,
      );

      PriceImpact? priceImpact;
      if (priceImpactResult.isRight()) {
        priceImpact = priceImpactResult.getOrElse(() => throw Exception());
      }

      // Process payment if needed
      if (priceImpact?.hasNetIncrease ?? false) {
        final paymentResult = await _processAdditionalPayment(
          request.bookingId,
          priceImpact!.additionalCost!,
        );
        
        if (paymentResult.isLeft()) {
          return paymentResult.fold((l) => Left(l), (r) => throw Exception());
        }
        
        paymentIntentId = paymentResult.getOrElse(() => throw Exception());
      }

      // Process refund if needed
      if (priceImpact?.hasNetDecrease ?? false) {
        final refundResult = await _processRefund(
          request.bookingId,
          priceImpact!.refundAmount!,
        );
        
        if (refundResult.isLeft()) {
          return refundResult.fold((l) => Left(l), (r) => throw Exception());
        }
        
        refundId = refundResult.getOrElse(() => throw Exception());
      }

      // Apply changes to booking
      for (final change in request.changes) {
        await _applyChangeToBooking(request.bookingId, change);
        processedChanges.add(change.description);
      }

      // Update request status
      await _supabaseClient
          .from('booking_modification_requests')
          .update({
            'status': 'processed',
            'processed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', requestId);

      // Send confirmation notification
      await _notifyModificationProcessed(request);

      return Right(ModificationProcessResult(
        requestId: requestId,
        bookingId: request.bookingId,
        success: true,
        processedChanges: processedChanges,
        priceImpact: priceImpact,
        paymentIntentId: paymentIntentId,
        refundId: refundId,
        processedAt: DateTime.now(),
      ));

    } catch (e) {
      return Left(BookingModificationFailure('Failed to process approved modification: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> cancelModificationRequest({
    required String requestId,
    required String cancelledBy,
    String? reason,
  }) async {
    try {
      await _supabaseClient
          .from('booking_modification_requests')
          .update({
            'status': 'cancelled',
            'responded_by': cancelledBy,
            'responded_at': DateTime.now().toIso8601String(),
            'rejection_reason': reason ?? 'Cancelled by user',
          })
          .eq('id', requestId);

      return const Right(unit);

    } catch (e) {
      return Left(BookingModificationFailure('Failed to cancel modification request: $e'));
    }
  }

  // Private helper methods

  Future<Either<Failure, dynamic>> _getBookingDetails(String bookingId) async {
    try {
      final response = await _supabaseClient
          .from('bookings')
          .select('*')
          .eq('id', bookingId)
          .single();

      return Right(response);
    } catch (e) {
      return const Left(BookingNotFoundFailure('Booking not found'));
    }
  }

  ModificationDeadlineInfo _calculateDeadlineInfo(DateTime bookingDateTime, DateTime requestTime) {
    final deadline = calculate24HourDeadline(bookingDateTime);
    final timeUntilDeadline = deadline.difference(requestTime);
    final isWithinDeadline = requestTime.isBefore(deadline);

    return ModificationDeadlineInfo(
      bookingDateTime: bookingDateTime,
      modificationDeadline: deadline,
      requestTime: requestTime,
      timeUntilDeadline: timeUntilDeadline,
      isWithinDeadline: isWithinDeadline,
    );
  }

  Future<ChangeValidationResult> _validateIndividualChange(BookingChange change, dynamic booking) async {
    final violations = <String>[];
    final warnings = <String>[];

    switch (change.type) {
      case ChangeType.dateTime:
        final newDateTime = change.newValue as DateTime;
        if (newDateTime.isBefore(DateTime.now().add(const Duration(hours: 2)))) {
          violations.add('New booking time must be at least 2 hours in the future');
        }
        break;

      case ChangeType.guestCount:
        final newCount = change.newValue as int;
        if (newCount <= 0) {
          violations.add('Guest count must be at least 1');
        }
        if (newCount > 20) {
          violations.add('Guest count cannot exceed 20');
        }
        break;

      default:
        break;
    }

    return ChangeValidationResult(violations, warnings);
  }

  bool _isBookingModifiable(String status) {
    const modifiableStatuses = ['pending', 'confirmed'];
    return modifiableStatuses.contains(status);
  }

  bool _isEmergencyModification(List<BookingChange> changes) {
    // Define what constitutes an emergency modification
    return changes.any((change) =>
        change.description.toLowerCase().contains('emergency') ||
        change.description.toLowerCase().contains('illness') ||
        change.description.toLowerCase().contains('family'));
  }

  Future<ChefAvailabilityResult> _validateChefAvailability(String bookingId, List<BookingChange> changes) async {
    // This would check chef availability for date/time changes
    // Simplified for now
    return const ChefAvailabilityResult(isAvailable: true);
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<PriceImpact?> _calculateDateTimeChangePriceImpact(dynamic booking, DateTime newDateTime) async {
    // Simplified implementation
    // In real implementation, this would check for holiday surcharges, different time periods, etc.
    return null;
  }

  Future<PriceImpact?> _calculateDishesChangePriceImpact(List<String> oldDishes, List<String> newDishes) async {
    // This would calculate price differences based on dish selections
    return null;
  }

  Future<PriceImpact?> _calculateGuestCountChangePriceImpact(dynamic booking, int newGuestCount) async {
    final currentCount = booking['number_of_guests'] as int;
    final difference = newGuestCount - currentCount;
    
    if (difference == 0) return null;

    // Simplified calculation - would be more complex in real implementation
    const pricePerGuest = 15000; // 150 DKK per guest in øre
    
    if (difference > 0) {
      final additionalCost = difference * pricePerGuest;
      return PriceImpact(
        additionalCost: additionalCost,
        explanation: 'Additional cost for $difference more guests',
        breakdown: [
          PriceBreakdown(
            item: 'Additional guests',
            amount: additionalCost,
            description: '$difference guests × ${pricePerGuest / 100} DKK',
          ),
        ],
      );
    } else {
      final refundAmount = difference.abs() * pricePerGuest;
      return PriceImpact(
        refundAmount: refundAmount,
        explanation: 'Refund for ${difference.abs()} fewer guests',
        breakdown: [
          PriceBreakdown(
            item: 'Guest count reduction',
            amount: -refundAmount,
            description: '${difference.abs()} fewer guests × ${pricePerGuest / 100} DKK',
          ),
        ],
      );
    }
  }

  Future<List<String>> _getCurrentBookingDishes(String bookingId) async {
    final response = await _supabaseClient
        .from('booking_dish_items')
        .select('dish_id')
        .eq('booking_id', bookingId);

    return response.map<String>((item) => item['dish_id'] as String).toList();
  }

  Future<void> _saveModificationRequest(BookingModificationRequest request) async {
    await _supabaseClient.from('booking_modification_requests').insert({
      'booking_id': request.bookingId,
      'requested_by': request.requestedBy,
      'requested_at': request.requestedAt.toIso8601String(),
      'changes': request.changes.map((c) => {
        'type': c.type.name,
        'field_name': c.fieldName,
        'old_value': c.oldValue,
        'new_value': c.newValue,
        'description': c.description,
      }).toList(),
      'reason': request.reason,
      'is_emergency_request': request.isEmergencyRequest,
      'status': request.status.name,
    });
  }

  Future<void> _notifyModificationRequest(BookingModificationRequest request, dynamic booking) async {
    await _notificationService.sendBookingModification(
      request.bookingId,
      {
        'message': 'A customer has requested to modify their booking',
        'type': 'modification_request',
        'chef_id': booking['chef_id'],
        'request_id': 'generated_id', // Would be actual ID from database
      },
    );
  }

  Future<void> _notifyModificationResponse(String requestId, bool approved, String? rejectionReason) async {
    // Implementation for notifying user of response
  }

  Future<void> _notifyModificationProcessed(BookingModificationRequest request) async {
    // Implementation for notifying that modification was processed
  }

  Future<BookingModificationRequest?> _getModificationRequestById(String requestId) async {
    // Implementation to retrieve modification request from database
    return null;
  }

  Future<BookingModificationRequest?> _convertDataToModificationRequest(Map<String, dynamic> data) async {
    // Implementation to convert database data to ModificationRequest object
    return null;
  }

  Future<Either<Failure, String>> _processAdditionalPayment(String bookingId, int amount) async {
    // Implementation for processing additional payment
    return const Left(PaymentFailure('Not implemented'));
  }

  Future<Either<Failure, String>> _processRefund(String bookingId, int amount) async {
    // Implementation for processing refund
    return const Left(RefundFailure('Not implemented'));
  }

  Future<void> _applyChangeToBooking(String bookingId, BookingChange change) async {
    final updateData = <String, dynamic>{};
    
    switch (change.type) {
      case ChangeType.dateTime:
        final newDateTime = change.newValue as DateTime;
        updateData['date'] = newDateTime.toIso8601String().split('T')[0];
        updateData['start_time'] = '${newDateTime.hour.toString().padLeft(2, '0')}:${newDateTime.minute.toString().padLeft(2, '0')}';
        break;
      case ChangeType.guestCount:
        updateData['number_of_guests'] = change.newValue;
        break;
      case ChangeType.specialRequests:
        updateData['special_requests'] = change.newValue;
        break;
      default:
        break;
    }

    if (updateData.isNotEmpty) {
      updateData['updated_at'] = DateTime.now().toIso8601String();
      await _supabaseClient
          .from('bookings')
          .update(updateData)
          .eq('id', bookingId);
    }
  }
}

class ChangeValidationResult {
  final List<String> violations;
  final List<String> warnings;

  ChangeValidationResult(this.violations, this.warnings);
}

class ChefAvailabilityResult {
  final bool isAvailable;
  final String? reason;

  const ChefAvailabilityResult({required this.isAvailable, this.reason});
}