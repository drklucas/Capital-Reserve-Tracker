import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Login use case - handles user authentication
///
/// Implements the business logic for user login
class LoginUseCase {
  final AuthRepository _authRepository;

  LoginUseCase(this._authRepository);

  /// Execute the login use case
  Future<Either<Failure, UserEntity>> execute(LoginParams params) async {
    // Validate input
    if (params.email.isEmpty) {
      return const Left(ValidationFailure(message: 'Email is required'));
    }

    if (params.password.isEmpty) {
      return const Left(ValidationFailure(message: 'Password is required'));
    }

    // Attempt to sign in
    return await _authRepository.signInWithEmailAndPassword(
      email: params.email.trim().toLowerCase(),
      password: params.password,
    );
  }

  /// Execute login with Google
  Future<Either<Failure, UserEntity>> executeWithGoogle() async {
    return await _authRepository.signInWithGoogle();
  }

  /// Execute login with Apple
  Future<Either<Failure, UserEntity>> executeWithApple() async {
    return await _authRepository.signInWithApple();
  }

  /// Execute login with Facebook
  Future<Either<Failure, UserEntity>> executeWithFacebook() async {
    return await _authRepository.signInWithFacebook();
  }
}

/// Parameters for login use case
class LoginParams extends Equatable {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginParams({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object?> get props => [email, password, rememberMe];
}