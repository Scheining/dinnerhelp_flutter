import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dartz/dartz.dart';
import 'package:homechef/core/error/failures.dart';
import '../../domain/entities/recurrence_pattern.dart';
import '../../domain/services/recurring_booking_service.dart';
import '../../data/repositories/recurring_booking_repository_impl.dart';

part 'recurring_booking_providers.g.dart';

// Repository provider
@riverpod
RecurringBookingRepositoryImpl recurringBookingRepository(RecurringBookingRepositoryRef ref) {
  // In a real implementation, inject SupabaseClient here
  return RecurringBookingRepositoryImpl();
}

// Service provider
@riverpod
RecurringBookingService recurringBookingService(RecurringBookingServiceRef ref) {
  return RecurringBookingService(ref.read(recurringBookingRepositoryProvider));
}

// State providers for recurring booking management

@riverpod
class RecurringPatternValidator extends _$RecurringPatternValidator {
  @override
  FutureOr<bool> build() {
    return false;
  }

  Future<void> validatePattern({
    required String chefId,
    required RecurrencePattern pattern,
    required String startTime,
    required String endTime,
  }) async {
    state = const AsyncValue.loading();
    
    final service = ref.read(recurringBookingServiceProvider);
    final result = await service.validateRecurringBookingPattern(
      chefId: chefId,
      pattern: pattern,
      startTime: startTime,
      endTime: endTime,
    );

    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (isValid) => AsyncValue.data(isValid),
    );
  }

  void clearValidation() {
    state = const AsyncValue.data(false);
  }
}

@riverpod
class RecurringBookingCreator extends _$RecurringBookingCreator {
  @override
  FutureOr<List<String>> build() {
    return [];
  }

  Future<void> createRecurringBooking({
    required String userId,
    required String chefId,
    required RecurrencePattern pattern,
    required String startTime,
    required String endTime,
    required int numberOfGuests,
    String? specialRequests,
    String? menuId,
  }) async {
    state = const AsyncValue.loading();
    
    final service = ref.read(recurringBookingServiceProvider);
    final result = await service.createRecurringBooking(
      userId: userId,
      chefId: chefId,
      pattern: pattern,
      startTime: startTime,
      endTime: endTime,
      numberOfGuests: numberOfGuests,
      specialRequests: specialRequests,
      menuId: menuId,
    );

    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (bookingIds) => AsyncValue.data(bookingIds),
    );
  }

  void clearBookings() {
    state = const AsyncValue.data([]);
  }
}

@riverpod
class RecurringBookingManager extends _$RecurringBookingManager {
  @override
  FutureOr<bool> build() {
    return false;
  }

  Future<void> cancelRecurringSeries(String seriesId) async {
    state = const AsyncValue.loading();
    
    final service = ref.read(recurringBookingServiceProvider);
    final result = await service.cancelRecurringSeries(seriesId);

    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (success) => AsyncValue.data(success),
    );
  }

  Future<void> modifyRecurringSeries({
    required String seriesId,
    required RecurrencePattern newPattern,
  }) async {
    state = const AsyncValue.loading();
    
    final service = ref.read(recurringBookingServiceProvider);
    final result = await service.modifyRecurringSeries(
      seriesId: seriesId,
      newPattern: newPattern,
    );

    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (success) => AsyncValue.data(success),
    );
  }

  void clearState() {
    state = const AsyncValue.data(false);
  }
}

// Utility provider for recurring booking calculations
@riverpod
class RecurringBookingCalculator extends _$RecurringBookingCalculator {
  @override
  RecurringBookingCalculation build() {
    return const RecurringBookingCalculation();
  }

  void calculateTotals({
    required RecurrencePattern pattern,
    required double pricePerBooking,
  }) {
    final occurrences = pattern.generateOccurrences();
    final totalPrice = pricePerBooking * occurrences.length;
    final savings = _calculateSavings(occurrences.length, pricePerBooking);
    
    state = RecurringBookingCalculation(
      numberOfOccurrences: occurrences.length,
      pricePerBooking: pricePerBooking,
      totalPrice: totalPrice,
      potentialSavings: savings,
      occurrences: occurrences,
    );
  }

  void clearCalculation() {
    state = const RecurringBookingCalculation();
  }

  double _calculateSavings(int numberOfBookings, double pricePerBooking) {
    // Example discount structure:
    // 5+ bookings: 5% discount
    // 10+ bookings: 10% discount
    // 20+ bookings: 15% discount
    
    double discountPercentage = 0;
    if (numberOfBookings >= 20) {
      discountPercentage = 0.15;
    } else if (numberOfBookings >= 10) {
      discountPercentage = 0.10;
    } else if (numberOfBookings >= 5) {
      discountPercentage = 0.05;
    }
    
    final regularPrice = numberOfBookings * pricePerBooking;
    return regularPrice * discountPercentage;
  }
}

// State class for recurring booking calculations
class RecurringBookingCalculation {
  final int numberOfOccurrences;
  final double pricePerBooking;
  final double totalPrice;
  final double potentialSavings;
  final List<DateTime> occurrences;

  const RecurringBookingCalculation({
    this.numberOfOccurrences = 0,
    this.pricePerBooking = 0,
    this.totalPrice = 0,
    this.potentialSavings = 0,
    this.occurrences = const [],
  });

  double get finalPrice => totalPrice - potentialSavings;
  bool get hasSavings => potentialSavings > 0;
  double get savingsPercentage => totalPrice > 0 ? (potentialSavings / totalPrice) * 100 : 0;

  RecurringBookingCalculation copyWith({
    int? numberOfOccurrences,
    double? pricePerBooking,
    double? totalPrice,
    double? potentialSavings,
    List<DateTime>? occurrences,
  }) {
    return RecurringBookingCalculation(
      numberOfOccurrences: numberOfOccurrences ?? this.numberOfOccurrences,
      pricePerBooking: pricePerBooking ?? this.pricePerBooking,
      totalPrice: totalPrice ?? this.totalPrice,
      potentialSavings: potentialSavings ?? this.potentialSavings,
      occurrences: occurrences ?? this.occurrences,
    );
  }
}