import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

/// Logout use case - handles user sign out
///
/// Implements the business logic for signing out users
class LogoutUseCase {
  final AuthRepository _authRepository;

  LogoutUseCase(this._authRepository);

  /// Execute the logout use case
  Future<Either<Failure, void>> execute() async {
    // Check if user is signed in
    if (!_authRepository.isSignedIn) {
      return const Left(AuthFailure(
        message: 'No user is currently signed in',
        code: 'not-signed-in',
      ));
    }

    // TODO: Clear local cache/storage if needed
    // This would be done through a cache repository

    // TODO: Cancel any pending uploads/downloads
    // This would be done through respective repositories

    // TODO: Log analytics event
    // This would be done through analytics repository

    // Sign out from Firebase
    return await _authRepository.signOut();
  }

  /// Execute logout from all devices (future feature)
  Future<Either<Failure, void>> executeFromAllDevices() async {
    // This would require backend support to invalidate all tokens
    // For now, just perform regular logout
    return execute();
  }

  /// Check if logout is safe (no pending operations)
  Future<bool> canSafelyLogout() async {
    // TODO: Check for:
    // - Pending uploads
    // - Unsaved changes
    // - Active transactions
    // For now, always return true
    return true;
  }
}