class LocationException implements Exception {
  final String message;
  final LocationErrorType type;

  const LocationException(this.message, [this.type = LocationErrorType.general]);

  @override
  String toString() => 'LocationException: $message';
}

enum LocationErrorType {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  timeout,
  networkError,
  general,
}

class DinnerHelpLocationPermissionDeniedException extends LocationException {
  const DinnerHelpLocationPermissionDeniedException([String? message])
      : super(
          message ?? 'Location permission denied by user',
          LocationErrorType.permissionDenied,
        );
}

class DinnerHelpLocationPermissionDeniedForeverException extends LocationException {
  const DinnerHelpLocationPermissionDeniedForeverException([String? message])
      : super(
          message ?? 'Location permission permanently denied',
          LocationErrorType.permissionDeniedForever,
        );
}

class DinnerHelpLocationServiceDisabledException extends LocationException {
  const DinnerHelpLocationServiceDisabledException([String? message])
      : super(
          message ?? 'Location services are disabled',
          LocationErrorType.serviceDisabled,
        );
}

class DinnerHelpLocationTimeoutException extends LocationException {
  const DinnerHelpLocationTimeoutException([String? message])
      : super(
          message ?? 'Location request timed out',
          LocationErrorType.timeout,
        );
}