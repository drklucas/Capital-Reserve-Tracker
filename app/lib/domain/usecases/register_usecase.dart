import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/validators.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Register use case - handles user registration
///
/// Implements the business logic for creating new user accounts
class RegisterUseCase {
  final AuthRepository _authRepository;

  RegisterUseCase(this._authRepository);

  /// Execute the registration use case
  Future<Either<Failure, UserEntity>> execute(RegisterParams params) async {
    // Validate input
    final emailError = Validators.validateEmail(params.email);
    if (emailError != null) {
      return Left(ValidationFailure(
        message: emailError,
        fieldErrors: {'email': emailError},
      ));
    }

    final passwordError = Validators.validatePassword(params.password);
    if (passwordError != null) {
      return Left(ValidationFailure(
        message: passwordError,
        fieldErrors: {'password': passwordError},
      ));
    }

    if (params.password != params.confirmPassword) {
      return const Left(ValidationFailure(
        message: 'Passwords do not match',
        fieldErrors: {'confirmPassword': 'Passwords do not match'},
      ));
    }

    if (params.displayName != null) {
      final nameError = Validators.validateName(params.displayName);
      if (nameError != null) {
        return Left(ValidationFailure(
          message: nameError,
          fieldErrors: {'displayName': nameError},
        ));
      }
    }

    // Check if terms are accepted
    if (!params.acceptedTerms) {
      return const Left(ValidationFailure(
        message: 'You must accept the terms and conditions',
        fieldErrors: {'acceptedTerms': 'Terms must be accepted'},
      ));
    }

    // Check if email is already registered
    final emailCheckResult = await _authRepository.isEmailRegistered(
      email: params.email.trim().toLowerCase(),
    );

    return emailCheckResult.fold(
      (failure) => Left(failure),
      (isRegistered) async {
        if (isRegistered) {
          return const Left(AuthFailure(
            message: 'An account already exists with this email',
            code: 'email-already-in-use',
          ));
        }

        // Register the user
        final result = await _authRepository.registerWithEmailAndPassword(
          email: params.email.trim().toLowerCase(),
          password: params.password,
          displayName: params.displayName?.trim(),
        );

        // Send email verification if registration successful
        await result.fold(
          (failure) async => null,
          (user) async {
            if (!user.isEmailVerified && params.sendVerificationEmail) {
              await _authRepository.sendEmailVerification();
            }
          },
        );

        return result;
      },
    );
  }
}

/// Parameters for registration use case
class RegisterParams extends Equatable {
  final String email;
  final String password;
  final String confirmPassword;
  final String? displayName;
  final bool acceptedTerms;
  final bool sendVerificationEmail;
  final bool subscribeToNewsletter;

  const RegisterParams({
    required this.email,
    required this.password,
    required this.confirmPassword,
    this.displayName,
    this.acceptedTerms = false,
    this.sendVerificationEmail = true,
    this.subscribeToNewsletter = false,
  });

  @override
  List<Object?> get props => [
        email,
        password,
        confirmPassword,
        displayName,
        acceptedTerms,
        sendVerificationEmail,
        subscribeToNewsletter,
      ];
}