import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homechef/models/booking.dart';
import 'package:homechef/data/repositories/booking_repository.dart';

// Re-use the supabase client provider
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Booking repository provider
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return BookingRepository(supabaseClient: supabaseClient);
});

// Current user ID provider (should be set from auth state)
final currentUserIdProvider = StateProvider<String?>((ref) => null);

// Current chef ID provider (for chef users)
final currentChefIdProvider = StateProvider<String?>((ref) => null);

// Provider to hold the selected booking ID for navigation
final selectedBookingIdProvider = StateProvider<String?>((ref) => null);

// User bookings provider
final userBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final repository = ref.watch(bookingRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  
  if (userId == null) {
    throw Exception('User not authenticated');
  }
  
  return repository.getUserBookings(userId);
});

// Chef bookings provider
final chefBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final repository = ref.watch(bookingRepositoryProvider);
  final chefId = ref.watch(currentChefIdProvider);
  
  if (chefId == null) {
    throw Exception('Chef ID not provided');
  }
  
  return repository.getChefBookings(chefId);
});

// Single booking provider
final bookingByIdProvider = FutureProvider.family<Booking?, String>((ref, bookingId) async {
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getBookingById(bookingId);
});

// User booking statistics provider
final userBookingStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(bookingRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  
  if (userId == null) {
    throw Exception('User not authenticated');
  }
  
  return repository.getUserBookingStats(userId);
});

// Chef booking statistics provider
final chefBookingStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(bookingRepositoryProvider);
  final chefId = ref.watch(currentChefIdProvider);
  
  if (chefId == null) {
    throw Exception('Chef ID not provided');
  }
  
  return repository.getChefBookingStats(chefId);
});

// Filtered bookings by status provider
final bookingsByStatusProvider = Provider.family<AsyncValue<List<Booking>>, BookingStatus?>((ref, status) {
  final bookingsAsync = ref.watch(userBookingsProvider);
  
  return bookingsAsync.when(
    data: (bookings) {
      if (status == null) return AsyncValue.data(bookings);
      final filtered = bookings.where((booking) => booking.status == status).toList();
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Upcoming bookings provider (next 30 days)
final upcomingBookingsProvider = Provider<AsyncValue<List<Booking>>>((ref) {
  final bookingsAsync = ref.watch(userBookingsProvider);
  
  return bookingsAsync.when(
    data: (bookings) {
      final now = DateTime.now();
      final thirtyDaysFromNow = now.add(const Duration(days: 30));
      
      final upcoming = bookings.where((booking) {
        // Only show future bookings that are not cancelled or refunded
        return booking.dateTime.isAfter(now) && 
               booking.dateTime.isBefore(thirtyDaysFromNow) &&
               booking.status != BookingStatus.cancelled &&
               booking.status != BookingStatus.refunded &&
               booking.status != BookingStatus.disputed;
      }).toList();
      
      // Sort by date
      upcoming.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      
      return AsyncValue.data(upcoming);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Past bookings provider
final pastBookingsProvider = Provider<AsyncValue<List<Booking>>>((ref) {
  final bookingsAsync = ref.watch(userBookingsProvider);
  
  return bookingsAsync.when(
    data: (bookings) {
      final now = DateTime.now();
      
      final past = bookings.where((booking) {
        // Show past bookings or completed ones, but exclude cancelled/refunded
        return (booking.dateTime.isBefore(now) || 
                booking.status == BookingStatus.completed) &&
               booking.status != BookingStatus.cancelled &&
               booking.status != BookingStatus.refunded;
      }).toList();
      
      // Sort by date (most recent first)
      past.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      
      return AsyncValue.data(past);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Cancelled bookings provider
final cancelledBookingsProvider = Provider<AsyncValue<List<Booking>>>((ref) {
  return ref.watch(bookingsByStatusProvider(BookingStatus.cancelled));
});

// Booking actions provider (for state management)
final bookingActionsProvider = Provider<BookingActions>((ref) {
  final repository = ref.watch(bookingRepositoryProvider);
  return BookingActions(repository, ref);
});

// Class to handle booking actions
class BookingActions {
  final BookingRepository _repository;
  final ProviderRef _ref;

  BookingActions(this._repository, this._ref);

  // Create a new booking
  Future<Booking> createBooking({
    required String chefId,
    required DateTime dateTime,
    required int guestCount,
    required String address,
    required double totalAmount,
    String? notes,
    String? selectedMenuId,
  }) async {
    final userId = _ref.read(currentUserIdProvider);
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final booking = await _repository.createBooking(
      chefId: chefId,
      userId: userId,
      dateTime: dateTime,
      guestCount: guestCount,
      address: address,
      totalAmount: totalAmount,
      notes: notes,
      selectedMenuId: selectedMenuId,
    );

    // Refresh the bookings list
    _ref.invalidate(userBookingsProvider);
    
    // Schedule confirmation notifications
    try {
      await _repository.scheduleBookingNotifications(
        bookingId: booking.id,
        notificationType: 'booking_confirmation',
        recipientType: 'both',
      );
    } catch (e) {
      print('Warning: Failed to schedule confirmation notifications: $e');
    }

    return booking;
  }

  // Update booking status
  Future<Booking> updateBookingStatus(String bookingId, BookingStatus status) async {
    final updatedBooking = await _repository.updateBookingStatus(bookingId, status);
    
    // Refresh relevant providers
    _ref.invalidate(userBookingsProvider);
    _ref.invalidate(chefBookingsProvider);
    _ref.invalidate(bookingByIdProvider(bookingId));
    
    return updatedBooking;
  }

  // Update payment status
  Future<Booking> updatePaymentStatus(
    String bookingId, 
    PaymentStatus paymentStatus, {
    String? paymentIntentId,
  }) async {
    final updatedBooking = await _repository.updatePaymentStatus(
      bookingId, 
      paymentStatus,
      paymentIntentId: paymentIntentId,
    );
    
    // Refresh relevant providers
    _ref.invalidate(userBookingsProvider);
    _ref.invalidate(chefBookingsProvider);
    _ref.invalidate(bookingByIdProvider(bookingId));
    
    return updatedBooking;
  }

  // Cancel a booking
  Future<Booking> cancelBooking(String bookingId, {String? cancellationReason}) async {
    final cancelledBooking = await _repository.cancelBooking(
      bookingId, 
      cancellationReason: cancellationReason,
    );
    
    // Refresh relevant providers
    _ref.invalidate(userBookingsProvider);
    _ref.invalidate(chefBookingsProvider);
    _ref.invalidate(bookingByIdProvider(bookingId));
    
    // Schedule cancellation notifications
    try {
      await _repository.scheduleBookingNotifications(
        bookingId: bookingId,
        notificationType: 'booking_cancelled',
        recipientType: 'both',
        customData: {'cancellation_reason': cancellationReason},
      );
    } catch (e) {
      print('Warning: Failed to schedule cancellation notifications: $e');
    }
    
    return cancelledBooking;
  }

  // Create payment intent for a booking
  Future<Map<String, dynamic>> createPaymentIntent({
    required String bookingId,
    required double amount,
    required String chefStripeAccountId,
    double? serviceFeeAmount,
    double? vatAmount,
  }) async {
    return await _repository.createPaymentIntent(
      bookingId: bookingId,
      amount: amount,
      chefStripeAccountId: chefStripeAccountId,
      serviceFeeAmount: serviceFeeAmount,
      vatAmount: vatAmount,
    );
  }

  // Confirm a booking (chef action)
  Future<Booking> confirmBooking(String bookingId) async {
    final confirmedBooking = await updateBookingStatus(bookingId, BookingStatus.confirmed);
    
    // Schedule reminder notifications
    try {
      await _repository.scheduleBookingNotifications(
        bookingId: bookingId,
        notificationType: 'booking_reminder_24h',
        recipientType: 'user',
      );
    } catch (e) {
      print('Warning: Failed to schedule reminder notifications: $e');
    }
    
    return confirmedBooking;
  }

  // Complete a booking
  Future<Booking> completeBooking(String bookingId) async {
    final completedBooking = await updateBookingStatus(bookingId, BookingStatus.completed);
    
    // Schedule completion notifications
    try {
      await _repository.scheduleBookingNotifications(
        bookingId: bookingId,
        notificationType: 'booking_completion',
        recipientType: 'both',
      );
    } catch (e) {
      print('Warning: Failed to schedule completion notifications: $e');
    }
    
    return completedBooking;
  }

  // Refresh all booking data
  void refreshAllBookings() {
    _ref.invalidate(userBookingsProvider);
    _ref.invalidate(chefBookingsProvider);
    _ref.invalidate(userBookingStatsProvider);
    _ref.invalidate(chefBookingStatsProvider);
  }
}

// Provider for booking form state management
final bookingFormProvider = StateNotifierProvider<BookingFormNotifier, BookingFormState>((ref) {
  return BookingFormNotifier();
});

// Booking form state
class BookingFormState {
  final String? selectedChefId;
  final DateTime? selectedDateTime;
  final int guestCount;
  final String address;
  final String? notes;
  final String? selectedMenuId;
  final bool isLoading;
  final String? error;

  const BookingFormState({
    this.selectedChefId,
    this.selectedDateTime,
    this.guestCount = 2,
    this.address = '',
    this.notes,
    this.selectedMenuId,
    this.isLoading = false,
    this.error,
  });

  BookingFormState copyWith({
    String? selectedChefId,
    DateTime? selectedDateTime,
    int? guestCount,
    String? address,
    String? notes,
    String? selectedMenuId,
    bool? isLoading,
    String? error,
  }) {
    return BookingFormState(
      selectedChefId: selectedChefId ?? this.selectedChefId,
      selectedDateTime: selectedDateTime ?? this.selectedDateTime,
      guestCount: guestCount ?? this.guestCount,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      selectedMenuId: selectedMenuId ?? this.selectedMenuId,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isValid {
    return selectedChefId != null &&
           selectedDateTime != null &&
           guestCount > 0 &&
           address.isNotEmpty;
  }
}

// Booking form state notifier
class BookingFormNotifier extends StateNotifier<BookingFormState> {
  BookingFormNotifier() : super(const BookingFormState());

  void setChef(String chefId) {
    state = state.copyWith(selectedChefId: chefId);
  }

  void setDateTime(DateTime dateTime) {
    state = state.copyWith(selectedDateTime: dateTime);
  }

  void setGuestCount(int count) {
    state = state.copyWith(guestCount: count);
  }

  void setAddress(String address) {
    state = state.copyWith(address: address);
  }

  void setNotes(String? notes) {
    state = state.copyWith(notes: notes);
  }

  void setMenu(String? menuId) {
    state = state.copyWith(selectedMenuId: menuId);
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void reset() {
    state = const BookingFormState();
  }
}