import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homechef/models/booking.dart';

class BookingRepository {
  final SupabaseClient _supabaseClient;

  BookingRepository({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  // Create a new booking
  Future<Booking> createBooking({
    required String chefId,
    required String userId,
    required DateTime dateTime,
    required int guestCount,
    required String address,
    required double totalAmount,
    String? notes,
    String? selectedMenuId,
  }) async {
    try {
      final response = await _supabaseClient
          .from('bookings')
          .insert({
            'chef_id': chefId,
            'user_id': userId,
            'date': dateTime.toIso8601String().split('T')[0],
            'start_time': '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}',
            'end_time': '${(dateTime.hour + 3).toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}', // Default 3 hour duration
            'number_of_guests': guestCount,
            'total_amount': (totalAmount * 100).round(), // Convert to øre
            'status': 'pending',
            'payment_status': 'pending',
            'notes': notes,
            'selected_menu_id': selectedMenuId,
          })
          .select()
          .single();

      return _mapToBooking(response);
    } catch (e) {
      print('Error creating booking: $e');
      rethrow;
    }
  }

  // Get bookings for a user
  Future<List<Booking>> getUserBookings(String userId) async {
    try {
      final response = await _supabaseClient
          .from('bookings')
          .select('''
            *,
            chefs!inner (
              profiles (
                first_name,
                last_name
              )
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response.map<Booking>((booking) => _mapToBooking(booking)).toList();
    } catch (e) {
      print('Error fetching user bookings: $e');
      rethrow;
    }
  }

  // Get bookings for a chef
  Future<List<Booking>> getChefBookings(String chefId) async {
    try {
      final response = await _supabaseClient
          .from('bookings')
          .select('''
            *,
            profiles!inner (
              first_name,
              last_name
            )
          ''')
          .eq('chef_id', chefId)
          .order('created_at', ascending: false);

      return response.map<Booking>((booking) => _mapToBooking(booking)).toList();
    } catch (e) {
      print('Error fetching chef bookings: $e');
      rethrow;
    }
  }

  // Get a specific booking by ID
  Future<Booking?> getBookingById(String bookingId) async {
    try {
      final response = await _supabaseClient
          .from('bookings')
          .select('''
            *,
            chefs (
              profiles (
                first_name,
                last_name
              )
            ),
            profiles (
              first_name,
              last_name
            )
          ''')
          .eq('id', bookingId)
          .maybeSingle();

      return response != null ? _mapToBooking(response) : null;
    } catch (e) {
      print('Error fetching booking by ID: $e');
      rethrow;
    }
  }

  // Update booking status - handles payment flow based on status
  Future<Booking> updateBookingStatus(String bookingId, BookingStatus status, {double? tipAmount}) async {
    try {
      final statusString = _bookingStatusToString(status);
      final updateData = {
        'status': statusString,
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      // Handle specific status transitions
      switch (status) {
        case BookingStatus.accepted:
          // Accepting booking triggers payment authorization via database trigger
          print('Accepting booking - payment authorization will be initiated');
          break;
        case BookingStatus.completed:
          // Completing booking triggers payment capture via database trigger
          if (tipAmount != null && tipAmount > 0) {
            updateData['tip_amount'] = (tipAmount * 100).round(); // Convert to øre
          }
          print('Completing booking - payment will be captured');
          break;
        case BookingStatus.cancelled:
          // Cancelling booking triggers refund evaluation via database trigger
          updateData['cancelled_at'] = DateTime.now().toIso8601String();
          print('Cancelling booking - refund will be evaluated based on policy');
          break;
        default:
          break;
      }
      
      final response = await _supabaseClient
          .from('bookings')
          .update(updateData)
          .eq('id', bookingId)
          .select()
          .single();

      final updatedBooking = _mapToBooking(response);
      
      // Log payment status for specific transitions
      final paymentStatus = updatedBooking.paymentStatus;
      if (status == BookingStatus.accepted && paymentStatus == PaymentStatus.pendingSetup) {
        print('Warning: Chef needs to complete Stripe account setup');
      } else if (status == BookingStatus.accepted && paymentStatus == PaymentStatus.authorizationPending) {
        print('Payment authorization initiated');
      } else if (status == BookingStatus.completed && paymentStatus == PaymentStatus.capturePending) {
        print('Payment capture initiated');
      }
      
      return updatedBooking;
    } catch (e) {
      print('Error updating booking status: $e');
      rethrow;
    }
  }

  // Update payment status
  Future<Booking> updatePaymentStatus(String bookingId, PaymentStatus paymentStatus, {String? paymentIntentId}) async {
    try {
      final statusString = _paymentStatusToString(paymentStatus);
      final updateData = {
        'payment_status': statusString,
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (paymentIntentId != null) {
        updateData['stripe_payment_intent_id'] = paymentIntentId;
      }

      final response = await _supabaseClient
          .from('bookings')
          .update(updateData)
          .eq('id', bookingId)
          .select()
          .single();

      return _mapToBooking(response);
    } catch (e) {
      print('Error updating payment status: $e');
      rethrow;
    }
  }

  // Cancel a booking with automatic refund processing
  Future<Booking> cancelBooking(String bookingId, {String? cancellationReason}) async {
    try {
      // First, get the booking details to check payment status
      final bookingResponse = await _supabaseClient
          .from('bookings')
          .select()
          .eq('id', bookingId)
          .single();
      
      final booking = _mapToBooking(bookingResponse);
      
      final updateData = {
        'status': 'cancelled',
        'cancellation_reason': cancellationReason,
        'cancelled_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Update the booking - this will trigger the cancellation trigger
      // which handles refund logic based on timing
      final response = await _supabaseClient
          .from('bookings')
          .update(updateData)
          .eq('id', bookingId)
          .select()
          .single();

      final cancelledBooking = _mapToBooking(response);
      
      // If payment was authorized or captured, the database trigger will handle refund
      // Check if refund is being processed
      if (booking.paymentStatus == PaymentStatus.authorized || 
          booking.paymentStatus == PaymentStatus.succeeded) {
        // Calculate hours until booking
        final bookingDateTime = DateTime(
          booking.date.year,
          booking.date.month,
          booking.date.day,
          booking.startTime.hour,
          booking.startTime.minute,
        );
        final hoursUntilBooking = bookingDateTime.difference(DateTime.now()).inHours;
        
        // Notify user about refund policy
        String refundMessage;
        if (hoursUntilBooking >= 48) {
          refundMessage = 'Full refund will be processed within 3-5 business days.';
        } else if (hoursUntilBooking >= 24) {
          refundMessage = '50% refund will be processed within 3-5 business days.';
        } else {
          refundMessage = 'No refund due to cancellation within 24 hours of booking.';
        }
        
        print('Cancellation processed. $refundMessage');
      }
      
      return cancelledBooking;
    } catch (e) {
      print('Error cancelling booking: $e');
      rethrow;
    }
  }

  // Create a payment intent for a booking
  Future<Map<String, dynamic>> createPaymentIntent({
    required String bookingId,
    required double amount,
    required String chefStripeAccountId,
    double? serviceFeeAmount,
    double? vatAmount,
  }) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'create-payment-intent',
        body: {
          'booking_id': bookingId,
          'amount': (amount * 100).round(), // Convert to øre
          'chef_stripe_account_id': chefStripeAccountId,
          'service_fee_amount': serviceFeeAmount != null ? (serviceFeeAmount * 100).round() : null,
          'vat_amount': vatAmount != null ? (vatAmount * 100).round() : null,
        },
      );

      if (response.data == null) {
        throw Exception('Failed to create payment intent: No data returned');
      }

      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('Error creating payment intent: $e');
      rethrow;
    }
  }

  // Schedule notifications for a booking
  Future<void> scheduleBookingNotifications({
    required String bookingId,
    required String notificationType,
    required String recipientType,
    DateTime? scheduleAt,
    Map<String, dynamic>? customData,
  }) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'schedule-notification',
        body: {
          'booking_id': bookingId,
          'notification_type': notificationType,
          'recipient_type': recipientType,
          'schedule_at': scheduleAt?.toIso8601String(),
          'custom_data': customData,
        },
      );

      if (response.data == null) {
        throw Exception('Failed to schedule notification: No data returned');
      }
    } catch (e) {
      print('Error scheduling booking notifications: $e');
      rethrow;
    }
  }

  // Get booking statistics for a user
  Future<Map<String, dynamic>> getUserBookingStats(String userId) async {
    try {
      final response = await _supabaseClient
          .rpc('get_user_booking_stats', params: {'user_uuid': userId});

      return response as Map<String, dynamic>;
    } catch (e) {
      print('Error fetching user booking stats: $e');
      rethrow;
    }
  }

  // Get booking statistics for a chef
  Future<Map<String, dynamic>> getChefBookingStats(String chefId) async {
    try {
      final response = await _supabaseClient
          .rpc('get_chef_booking_stats', params: {'chef_uuid': chefId});

      return response as Map<String, dynamic>;
    } catch (e) {
      print('Error fetching chef booking stats: $e');
      rethrow;
    }
  }

  // Helper method to map database response to Booking model
  Booking _mapToBooking(Map<String, dynamic> data) {
    // Extract chef name
    String chefName = 'Unknown Chef';
    if (data['chefs'] != null && data['chefs']['profiles'] != null) {
      final profiles = data['chefs']['profiles'];
      final firstName = profiles['first_name'] ?? '';
      final lastName = profiles['last_name'] ?? '';
      chefName = '$firstName $lastName'.trim();
      if (chefName.isEmpty) chefName = 'Chef ${data['chef_id']?.toString().substring(0, 8) ?? ''}';
    }

    // Parse date and time
    final date = DateTime.parse(data['date']);
    final startTime = data['start_time'] as String;
    final timeParts = startTime.split(':');
    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );

    // Convert amount from øre to DKK
    final totalAmount = (data['total_amount'] as num).toDouble() / 100.0;
    
    // Calculate service fee (15% of total) and tax (25% of service fee)
    final serviceFee = totalAmount * 0.15;
    final tax = serviceFee * 0.25;
    final basePrice = totalAmount - serviceFee - tax;

    return Booking(
      id: data['id'],
      chefId: data['chef_id'],
      chefName: chefName,
      userId: data['user_id'],
      dateTime: dateTime,
      guestCount: data['number_of_guests'],
      address: data['address'] ?? 'Address not provided',
      basePrice: basePrice,
      serviceFee: serviceFee,
      tax: tax,
      totalPrice: totalAmount,
      status: _stringToBookingStatus(data['status']),
      paymentStatus: _stringToPaymentStatus(data['payment_status']),
      stripePaymentIntentId: data['stripe_payment_intent_id'],
      notes: data['notes'],
      createdAt: DateTime.parse(data['created_at']),
    );
  }

  // Helper methods to convert between enums and strings
  String _bookingStatusToString(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'pending';
      case BookingStatus.confirmed:
        return 'confirmed';
      case BookingStatus.inProgress:
        return 'in_progress';
      case BookingStatus.completed:
        return 'completed';
      case BookingStatus.cancelled:
        return 'cancelled';
      case BookingStatus.disputed:
        return 'disputed';
      case BookingStatus.refunded:
        return 'refunded';
    }
  }

  BookingStatus _stringToBookingStatus(String status) {
    switch (status) {
      case 'pending':
        return BookingStatus.pending;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'in_progress':
        return BookingStatus.inProgress;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'disputed':
        return BookingStatus.disputed;
      case 'refunded':
        return BookingStatus.refunded;
      default:
        return BookingStatus.pending;
    }
  }

  String _paymentStatusToString(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'pending';
      case PaymentStatus.authorized:
        return 'authorized';
      case PaymentStatus.succeeded:
        return 'succeeded';
      case PaymentStatus.failed:
        return 'failed';
      case PaymentStatus.refunded:
        return 'refunded';
      case PaymentStatus.partiallyRefunded:
        return 'partially_refunded';
      case PaymentStatus.disputed:
        return 'disputed';
    }
  }

  PaymentStatus _stringToPaymentStatus(String status) {
    switch (status) {
      case 'pending':
        return PaymentStatus.pending;
      case 'authorized':
        return PaymentStatus.authorized;
      case 'succeeded':
        return PaymentStatus.succeeded;
      case 'failed':
        return PaymentStatus.failed;
      case 'refunded':
        return PaymentStatus.refunded;
      case 'partially_refunded':
        return PaymentStatus.partiallyRefunded;
      case 'disputed':
        return PaymentStatus.disputed;
      default:
        return PaymentStatus.pending;
    }
  }
}