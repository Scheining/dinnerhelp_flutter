import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server error occurred']) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Network error occurred']) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache error occurred']) : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'Validation error occurred']) : super(message);
}

// Booking-specific failures
class BookingConflictFailure extends Failure {
  const BookingConflictFailure([String message = 'Booking conflict detected']) : super(message);
}

class ChefUnavailableFailure extends Failure {
  const ChefUnavailableFailure([String message = 'Chef is not available at the requested time']) : super(message);
}

class InvalidTimeSlotFailure extends Failure {
  const InvalidTimeSlotFailure([String message = 'Invalid time slot selected']) : super(message);
}

class InsufficientNoticeFailure extends Failure {
  const InsufficientNoticeFailure([String message = 'Insufficient notice for booking']) : super(message);
}

class MaxBookingsExceededFailure extends Failure {
  const MaxBookingsExceededFailure([String message = 'Maximum bookings per day exceeded']) : super(message);
}

class InvalidRecurrencePatternFailure extends Failure {
  const InvalidRecurrencePatternFailure([String message = 'Invalid recurrence pattern']) : super(message);
}

class BookingTooFarInAdvanceFailure extends Failure {
  const BookingTooFarInAdvanceFailure([String message = 'Booking is too far in advance (maximum 6 months)']) : super(message);
}

class ChefNotFoundFailure extends Failure {
  const ChefNotFoundFailure([String message = 'Chef not found']) : super(message);
}

class BookingNotFoundFailure extends Failure {
  const BookingNotFoundFailure([String message = 'Booking not found']) : super(message);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([String message = 'Unauthorized access']) : super(message);
}

// Payment-specific failures
class PaymentFailure extends Failure {
  const PaymentFailure([String message = 'Payment error occurred']) : super(message);
}

class PaymentIntentCreationFailure extends Failure {
  const PaymentIntentCreationFailure([String message = 'Failed to create payment intent']) : super(message);
}

class PaymentAuthorizationFailure extends Failure {
  const PaymentAuthorizationFailure([String message = 'Payment authorization failed']) : super(message);
}

class PaymentCaptureFailure extends Failure {
  const PaymentCaptureFailure([String message = 'Payment capture failed']) : super(message);
}

class RefundFailure extends Failure {
  const RefundFailure([String message = 'Refund processing failed']) : super(message);
}

class InvalidPaymentMethodFailure extends Failure {
  const InvalidPaymentMethodFailure([String message = 'Invalid payment method']) : super(message);
}

class InsufficientFundsFailure extends Failure {
  const InsufficientFundsFailure([String message = 'Insufficient funds']) : super(message);
}

class PaymentDeclinedFailure extends Failure {
  const PaymentDeclinedFailure([String message = 'Payment was declined']) : super(message);
}

class StripeConnectAccountFailure extends Failure {
  const StripeConnectAccountFailure([String message = 'Stripe Connect account error']) : super(message);
}

class ServiceFeeCalculationFailure extends Failure {
  const ServiceFeeCalculationFailure([String message = 'Service fee calculation failed']) : super(message);
}

class PaymentWebhookFailure extends Failure {
  const PaymentWebhookFailure([String message = 'Payment webhook processing failed']) : super(message);
}

class PaymentNotFoundFailure extends Failure {
  const PaymentNotFoundFailure([String message = 'Payment not found']) : super(message);
}

class DisputeHandlingFailure extends Failure {
  const DisputeHandlingFailure([String message = 'Dispute handling failed']) : super(message);
}

// Edge case specific failures
class NoAlternativeChefFailure extends Failure {
  const NoAlternativeChefFailure([String message = 'No alternative chefs available']) : super(message);
}

class RecurringBookingConflictFailure extends Failure {
  const RecurringBookingConflictFailure([String message = 'Recurring booking conflicts detected']) : super(message);
}

class BookingModificationFailure extends Failure {
  const BookingModificationFailure([String message = 'Booking modification failed']) : super(message);
}

class ModificationTooLateFailure extends Failure {
  const ModificationTooLateFailure([String message = 'Modification request is too late (less than 24 hours)']) : super(message);
}

class ModificationNotAllowedFailure extends Failure {
  const ModificationNotAllowedFailure([String message = 'This type of modification is not allowed']) : super(message);
}

class DisputeCreationFailure extends Failure {
  const DisputeCreationFailure([String message = 'Failed to create dispute']) : super(message);
}

class DisputeInvestigationFailure extends Failure {
  const DisputeInvestigationFailure([String message = 'Dispute investigation failed']) : super(message);
}

class CompensationCalculationFailure extends Failure {
  const CompensationCalculationFailure([String message = 'Failed to calculate compensation']) : super(message);
}

class HolidaySurchargeCalculationFailure extends Failure {
  const HolidaySurchargeCalculationFailure([String message = 'Holiday surcharge calculation failed']) : super(message);
}

class InvalidHolidayDateFailure extends Failure {
  const InvalidHolidayDateFailure([String message = 'Invalid holiday date provided']) : super(message);
}

class SurchargeSettingsFailure extends Failure {
  const SurchargeSettingsFailure([String message = 'Invalid surcharge settings']) : super(message);
}

class EmergencyCancellationFailure extends Failure {
  const EmergencyCancellationFailure([String message = 'Emergency cancellation failed']) : super(message);
}

class ReschedulingOptionsFailure extends Failure {
  const ReschedulingOptionsFailure([String message = 'Failed to find rescheduling options']) : super(message);
}

class SeriesUpdateFailure extends Failure {
  const SeriesUpdateFailure([String message = 'Failed to update booking series']) : super(message);
}

class NotificationSendFailure extends Failure {
  const NotificationSendFailure([String message = 'Failed to send notifications']) : super(message);
}