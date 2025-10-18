import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
///
/// Uses Equatable for value comparison
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  final dynamic details;

  const Failure({
    required this.message,
    this.code,
    this.details,
  });

  @override
  List<Object?> get props => [message, code, details];

  @override
  String toString() => '$runtimeType(message: $message, code: $code)';
}

/// Server-related failures
class ServerFailure extends Failure {
  const ServerFailure({
    required String message,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);

  factory ServerFailure.fromCode(String code) {
    switch (code) {
      case '500':
        return const ServerFailure(
          message: 'Internal server error. Please try again later.',
          code: '500',
        );
      case '503':
        return const ServerFailure(
          message: 'Service temporarily unavailable.',
          code: '503',
        );
      default:
        return ServerFailure(
          message: 'Server error occurred.',
          code: code,
        );
    }
  }
}

/// Authentication-related failures
class AuthFailure extends Failure {
  const AuthFailure({
    required String message,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);

  factory AuthFailure.fromFirebaseCode(String code) {
    switch (code) {
      case 'user-not-found':
        return const AuthFailure(
          message: 'No user found with this email address.',
          code: 'user-not-found',
        );
      case 'wrong-password':
        return const AuthFailure(
          message: 'Incorrect password. Please try again.',
          code: 'wrong-password',
        );
      case 'email-already-in-use':
        return const AuthFailure(
          message: 'An account already exists with this email.',
          code: 'email-already-in-use',
        );
      case 'invalid-email':
        return const AuthFailure(
          message: 'Please enter a valid email address.',
          code: 'invalid-email',
        );
      case 'weak-password':
        return const AuthFailure(
          message: 'Password should be at least 6 characters.',
          code: 'weak-password',
        );
      case 'user-disabled':
        return const AuthFailure(
          message: 'This account has been disabled.',
          code: 'user-disabled',
        );
      case 'too-many-requests':
        return const AuthFailure(
          message: 'Too many attempts. Please try again later.',
          code: 'too-many-requests',
        );
      case 'operation-not-allowed':
        return const AuthFailure(
          message: 'This operation is not allowed.',
          code: 'operation-not-allowed',
        );
      case 'invalid-credential':
        return const AuthFailure(
          message: 'Invalid credentials. Please check and try again.',
          code: 'invalid-credential',
        );
      default:
        return AuthFailure(
          message: 'Authentication failed. Please try again.',
          code: code,
        );
    }
  }
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    String message = 'No internet connection. Please check your network.',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Cache-related failures
class CacheFailure extends Failure {
  const CacheFailure({
    String message = 'Local data error occurred.',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Validation failures
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    required String message,
    this.fieldErrors,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);

  @override
  List<Object?> get props => [message, code, details, fieldErrors];
}

/// Permission-related failures
class PermissionFailure extends Failure {
  const PermissionFailure({
    String message = 'You do not have permission to perform this action.',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Timeout failures
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    String message = 'Request timed out. Please try again.',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Database failures
class DatabaseFailure extends Failure {
  const DatabaseFailure({
    required String message,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);

  factory DatabaseFailure.fromFirestoreCode(String code) {
    switch (code) {
      case 'permission-denied':
        return const DatabaseFailure(
          message: 'Permission denied. Please check your access rights.',
          code: 'permission-denied',
        );
      case 'not-found':
        return const DatabaseFailure(
          message: 'Requested data not found.',
          code: 'not-found',
        );
      case 'already-exists':
        return const DatabaseFailure(
          message: 'Data already exists.',
          code: 'already-exists',
        );
      case 'resource-exhausted':
        return const DatabaseFailure(
          message: 'Quota exceeded. Please try again later.',
          code: 'resource-exhausted',
        );
      case 'failed-precondition':
        return const DatabaseFailure(
          message: 'Operation rejected. Please check the requirements.',
          code: 'failed-precondition',
        );
      case 'aborted':
        return const DatabaseFailure(
          message: 'Operation aborted due to a conflict.',
          code: 'aborted',
        );
      case 'out-of-range':
        return const DatabaseFailure(
          message: 'Operation out of valid range.',
          code: 'out-of-range',
        );
      case 'unimplemented':
        return const DatabaseFailure(
          message: 'Operation not implemented.',
          code: 'unimplemented',
        );
      case 'internal':
        return const DatabaseFailure(
          message: 'Internal error occurred.',
          code: 'internal',
        );
      case 'unavailable':
        return const DatabaseFailure(
          message: 'Service currently unavailable.',
          code: 'unavailable',
        );
      case 'data-loss':
        return const DatabaseFailure(
          message: 'Unrecoverable data loss or corruption.',
          code: 'data-loss',
        );
      default:
        return DatabaseFailure(
          message: 'Database operation failed.',
          code: code,
        );
    }
  }
}

/// Storage failures
class StorageFailure extends Failure {
  const StorageFailure({
    required String message,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);

  factory StorageFailure.fromFirebaseCode(String code) {
    switch (code) {
      case 'storage/unknown':
        return const StorageFailure(
          message: 'Unknown storage error occurred.',
          code: 'storage/unknown',
        );
      case 'storage/object-not-found':
        return const StorageFailure(
          message: 'File not found.',
          code: 'storage/object-not-found',
        );
      case 'storage/bucket-not-found':
        return const StorageFailure(
          message: 'Storage bucket not configured.',
          code: 'storage/bucket-not-found',
        );
      case 'storage/project-not-found':
        return const StorageFailure(
          message: 'Storage project not configured.',
          code: 'storage/project-not-found',
        );
      case 'storage/quota-exceeded':
        return const StorageFailure(
          message: 'Storage quota exceeded.',
          code: 'storage/quota-exceeded',
        );
      case 'storage/unauthenticated':
        return const StorageFailure(
          message: 'User not authenticated.',
          code: 'storage/unauthenticated',
        );
      case 'storage/unauthorized':
        return const StorageFailure(
          message: 'User not authorized for this operation.',
          code: 'storage/unauthorized',
        );
      case 'storage/retry-limit-exceeded':
        return const StorageFailure(
          message: 'Maximum retry time exceeded.',
          code: 'storage/retry-limit-exceeded',
        );
      case 'storage/invalid-checksum':
        return const StorageFailure(
          message: 'File checksum does not match.',
          code: 'storage/invalid-checksum',
        );
      case 'storage/canceled':
        return const StorageFailure(
          message: 'Operation was canceled.',
          code: 'storage/canceled',
        );
      default:
        return StorageFailure(
          message: 'Storage operation failed.',
          code: code,
        );
    }
  }
}

/// Unknown/Unexpected failures
class UnknownFailure extends Failure {
  const UnknownFailure({
    String message = 'An unexpected error occurred.',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// Feature not implemented failure
class NotImplementedFailure extends Failure {
  const NotImplementedFailure({
    String message = 'This feature is not yet implemented.',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}