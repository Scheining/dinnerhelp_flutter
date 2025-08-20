import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dartz/dartz.dart';
import 'package:homechef/core/error/failures.dart';
import '../../domain/entities/time_slot.dart';
import '../../domain/entities/booking_request.dart';
import '../../domain/services/booking_availability_service.dart';
import '../../domain/repositories/booking_availability_repository.dart';
import '../../domain/repositories/chef_schedule_repository.dart';
import '../../data/repositories/booking_availability_repository_impl.dart';
import '../../data/repositories/chef_schedule_repository_impl.dart';
import '../../../booking/domain/services/chef_schedule_service.dart';

part 'booking_availability_providers.g.dart';

// Repository providers
@riverpod
BookingAvailabilityRepository bookingAvailabilityRepository(BookingAvailabilityRepositoryRef ref) {
  // In a real implementation, inject SupabaseClient here
  return BookingAvailabilityRepositoryImpl();
}

@riverpod
ChefScheduleRepository chefScheduleRepository(ChefScheduleRepositoryRef ref) {
  // In a real implementation, inject SupabaseClient here
  return ChefScheduleRepositoryImpl();
}

// Service providers
@riverpod
ChefScheduleService chefScheduleService(ChefScheduleServiceRef ref) {
  return ChefScheduleService(ref.read(chefScheduleRepositoryProvider));
}

@riverpod
BookingAvailabilityService bookingAvailabilityService(BookingAvailabilityServiceRef ref) {
  return BookingAvailabilityService(
    ref.read(bookingAvailabilityRepositoryProvider),
    ref.read(chefScheduleRepositoryProvider),
    ref.read(chefScheduleServiceProvider),
  );
}

// State providers for availability data

@riverpod
class AvailableTimeSlots extends _$AvailableTimeSlots {
  @override
  FutureOr<List<TimeSlot>> build() {
    return [];
  }

  Future<void> getAvailableTimeSlots({
    required String chefId,
    required DateTime date,
    required Duration duration,
    required int numberOfGuests,
  }) async {
    state = const AsyncValue.loading();
    
    final service = ref.read(bookingAvailabilityServiceProvider);
    final result = await service.getAvailableTimeSlots(
      chefId: chefId,
      date: date,
      duration: duration,
      numberOfGuests: numberOfGuests,
    );

    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (timeSlots) => AsyncValue.data(timeSlots),
    );
  }

  void clearTimeSlots() {
    state = const AsyncValue.data([]);
  }
}

@riverpod
class BookingConflictChecker extends _$BookingConflictChecker {
  @override
  FutureOr<bool> build() {
    return false;
  }

  Future<void> checkBookingConflict({
    required String chefId,
    required DateTime date,
    required String startTime,
    required String endTime,
    String? excludeBookingId,
  }) async {
    state = const AsyncValue.loading();
    
    final service = ref.read(bookingAvailabilityServiceProvider);
    final result = await service.checkBookingConflict(
      chefId: chefId,
      date: date,
      startTime: startTime,
      endTime: endTime,
      excludeBookingId: excludeBookingId,
    );

    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (hasConflict) => AsyncValue.data(hasConflict),
    );
  }
}

@riverpod
class ChefWeeklySchedule extends _$ChefWeeklySchedule {
  @override
  FutureOr<List<TimeSlot>> build() {
    return [];
  }

  Future<void> getChefScheduleForWeek({
    required String chefId,
    required DateTime weekStart,
  }) async {
    state = const AsyncValue.loading();
    
    final service = ref.read(bookingAvailabilityServiceProvider);
    final result = await service.getChefScheduleForWeek(
      chefId: chefId,
      weekStart: weekStart,
    );

    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (schedule) => AsyncValue.data(schedule),
    );
  }

  void clearSchedule() {
    state = const AsyncValue.data([]);
  }
}

@riverpod
class NextAvailableSlot extends _$NextAvailableSlot {
  @override
  FutureOr<TimeSlot?> build() {
    return null;
  }

  Future<void> getNextAvailableSlot({
    required String chefId,
    required DateTime afterDate,
    required Duration duration,
  }) async {
    state = const AsyncValue.loading();
    
    final service = ref.read(bookingAvailabilityServiceProvider);
    final result = await service.getNextAvailableSlot(
      chefId: chefId,
      afterDate: afterDate,
      duration: duration,
    );

    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (timeSlot) => AsyncValue.data(timeSlot),
    );
  }

  void clearNextSlot() {
    state = const AsyncValue.data(null);
  }
}

// Utility provider for booking validation
@riverpod
class BookingValidator extends _$BookingValidator {
  @override
  FutureOr<bool> build() {
    return false;
  }

  Future<void> validateBookingRequest(BookingRequest bookingRequest) async {
    state = const AsyncValue.loading();

    // Basic validation
    if (bookingRequest.numberOfGuests <= 0) {
      state = AsyncValue.error(
        const ValidationFailure('Number of guests must be greater than 0'),
        StackTrace.current,
      );
      return;
    }

    if (bookingRequest.date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      state = AsyncValue.error(
        const ValidationFailure('Cannot book for past dates'),
        StackTrace.current,
      );
      return;
    }

    // Check for booking conflicts
    final conflictResult = await ref.read(bookingAvailabilityServiceProvider).checkBookingConflict(
      chefId: bookingRequest.chefId,
      date: bookingRequest.date,
      startTime: bookingRequest.startTime,
      endTime: bookingRequest.endTime,
    );

    state = conflictResult.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (hasConflict) {
        if (hasConflict) {
          return AsyncValue.error(
            const BookingConflictFailure('Booking conflicts with existing bookings'),
            StackTrace.current,
          );
        }
        return const AsyncValue.data(true);
      },
    );
  }
}

// Provider for managing selected booking date and time
@riverpod
class BookingSelection extends _$BookingSelection {
  @override
  BookingSelectionState build() {
    return const BookingSelectionState();
  }

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
    // Clear time slots when date changes
    ref.read(availableTimeSlotsProvider.notifier).clearTimeSlots();
  }

  void selectTimeSlot(TimeSlot timeSlot) {
    state = state.copyWith(selectedTimeSlot: timeSlot);
  }

  void setGuestCount(int count) {
    state = state.copyWith(guestCount: count);
    // Refresh availability when guest count changes
    _refreshAvailability();
  }

  void setDuration(Duration duration) {
    state = state.copyWith(duration: duration);
    // Refresh availability when duration changes
    _refreshAvailability();
  }

  void selectChef(String chefId) {
    state = state.copyWith(selectedChefId: chefId);
    // Clear previous selections
    clearSelections();
  }

  void clearSelections() {
    state = state.copyWith(
      selectedDate: null,
      selectedTimeSlot: null,
    );
    ref.read(availableTimeSlotsProvider.notifier).clearTimeSlots();
  }

  void _refreshAvailability() {
    if (state.hasValidSelectionForAvailability) {
      ref.read(availableTimeSlotsProvider.notifier).getAvailableTimeSlots(
        chefId: state.selectedChefId!,
        date: state.selectedDate!,
        duration: state.duration,
        numberOfGuests: state.guestCount,
      );
    }
  }
}

// State class for booking selection
class BookingSelectionState {
  final String? selectedChefId;
  final DateTime? selectedDate;
  final TimeSlot? selectedTimeSlot;
  final int guestCount;
  final Duration duration;

  const BookingSelectionState({
    this.selectedChefId,
    this.selectedDate,
    this.selectedTimeSlot,
    this.guestCount = 2,
    this.duration = const Duration(hours: 3),
  });

  BookingSelectionState copyWith({
    String? selectedChefId,
    DateTime? selectedDate,
    TimeSlot? selectedTimeSlot,
    int? guestCount,
    Duration? duration,
  }) {
    return BookingSelectionState(
      selectedChefId: selectedChefId ?? this.selectedChefId,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTimeSlot: selectedTimeSlot ?? this.selectedTimeSlot,
      guestCount: guestCount ?? this.guestCount,
      duration: duration ?? this.duration,
    );
  }

  bool get hasValidSelectionForAvailability =>
      selectedChefId != null && selectedDate != null;

  bool get hasCompleteSelection =>
      selectedChefId != null && 
      selectedDate != null && 
      selectedTimeSlot != null;

  BookingRequest? toBookingRequest({
    required String userId,
    String? specialRequests,
    String? menuId,
  }) {
    if (!hasCompleteSelection) return null;

    final startParts = selectedTimeSlot!.startTime.toString().split(' ')[1].split(':');
    final endParts = selectedTimeSlot!.endTime.toString().split(' ')[1].split(':');
    
    return BookingRequest(
      userId: userId,
      chefId: selectedChefId!,
      date: selectedDate!,
      startTime: '${startParts[0]}:${startParts[1]}',
      endTime: '${endParts[0]}:${endParts[1]}',
      numberOfGuests: guestCount,
      specialRequests: specialRequests,
      menuId: menuId,
    );
  }
}