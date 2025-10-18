/// Custom exceptions for the application
///
/// These exceptions are thrown by data sources and caught by repositories
/// to be converted into Failures

/// Base exception class
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() => '$runtimeType(message: $message, code: $code)';
}

/// Server-related exceptions
class ServerException extends AppException {
  const ServerException({
    required String message,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Authentication exceptions
class AuthException extends AppException {
  const AuthException({
    required String message,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Network exceptions
class NetworkException extends AppException {
  const NetworkException({
    String message = 'Network error occurred',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Cache exceptions
class CacheException extends AppException {
  const CacheException({
    String message = 'Cache error occurred',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Validation exceptions
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException({
    required String message,
    this.fieldErrors,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Permission exceptions
class PermissionException extends AppException {
  const PermissionException({
    String message = 'Permission denied',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Timeout exceptions
class TimeoutException extends AppException {
  const TimeoutException({
    String message = 'Operation timed out',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Database exceptions
class DatabaseException extends AppException {
  const DatabaseException({
    required String message,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Storage exceptions
class StorageException extends AppException {
  const StorageException({
    required String message,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Not found exceptions
class NotFoundException extends AppException {
  const NotFoundException({
    String message = 'Resource not found',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Already exists exceptions
class AlreadyExistsException extends AppException {
  const AlreadyExistsException({
    String message = 'Resource already exists',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Invalid input exceptions
class InvalidInputException extends AppException {
  const InvalidInputException({
    required String message,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Unauthorized exceptions
class UnauthorizedException extends AppException {
  const UnauthorizedException({
    String message = 'Unauthorized access',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Rate limit exceptions
class RateLimitException extends AppException {
  final DateTime? retryAfter;

  const RateLimitException({
    String message = 'Rate limit exceeded',
    this.retryAfter,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Configuration exceptions
class ConfigurationException extends AppException {
  const ConfigurationException({
    required String message,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Feature not available exceptions
class FeatureNotAvailableException extends AppException {
  const FeatureNotAvailableException({
    String message = 'Feature not available',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Parse exceptions
class ParseException extends AppException {
  const ParseException({
    required String message,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Format exceptions
class FormatException extends AppException {
  const FormatException({
    required String message,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}