import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user_entity.dart';

/// Abstract authentication repository
///
/// Defines the contract for authentication operations
/// Implementation details are hidden in the data layer
abstract class AuthRepository {
  /// Get current authenticated user
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Sign in with email and password
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Register with email and password
  Future<Either<Failure, UserEntity>> registerWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  });

  /// Sign out
  Future<Either<Failure, void>> signOut();

  /// Send password reset email
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  });

  /// Update user profile
  Future<Either<Failure, UserEntity>> updateProfile({
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? bio,
  });

  /// Update password
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Delete account
  Future<Either<Failure, void>> deleteAccount({
    required String password,
  });

  /// Verify email
  Future<Either<Failure, void>> sendEmailVerification();

  /// Reload user data
  Future<Either<Failure, UserEntity>> reloadUser();

  /// Check if email is already registered
  Future<Either<Failure, bool>> isEmailRegistered({
    required String email,
  });

  /// Sign in with Google
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  /// Sign in with Apple
  Future<Either<Failure, UserEntity>> signInWithApple();

  /// Sign in with Facebook
  Future<Either<Failure, UserEntity>> signInWithFacebook();

  /// Link account with email/password
  Future<Either<Failure, UserEntity>> linkWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Unlink provider
  Future<Either<Failure, UserEntity>> unlinkProvider({
    required String providerId,
  });

  /// Get authentication state stream
  Stream<UserEntity?> get authStateChanges;

  /// Check if user is signed in
  bool get isSignedIn;

  /// Get current user ID
  String? get currentUserId;

  /// Re-authenticate user (for sensitive operations)
  Future<Either<Failure, void>> reAuthenticate({
    required String password,
  });

  /// Update email
  Future<Either<Failure, void>> updateEmail({
    required String newEmail,
    required String password,
  });
}