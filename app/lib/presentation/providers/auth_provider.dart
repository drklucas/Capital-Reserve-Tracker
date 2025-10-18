import 'package:flutter/foundation.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/repositories/auth_repository.dart';

/// Authentication state
enum AuthStatus {
  initial,
  authenticating,
  authenticated,
  unauthenticated,
  error,
}

/// Authentication provider for state management
/// Note: Named AppAuthProvider to avoid conflict with Firebase's AuthProvider
class AppAuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final AuthRepository _authRepository;

  // State
  AuthStatus _status = AuthStatus.initial;
  UserEntity? _user;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  AuthStatus get status => _status;
  UserEntity? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  String get userDisplayName => _user?.displayName ?? _user?.email ?? 'User';
  String get userInitials => _user?.initials ?? 'U';

  AppAuthProvider({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required AuthRepository authRepository,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        _authRepository = authRepository {
    _initializeAuth();
  }

  /// Initialize authentication state
  Future<void> _initializeAuth() async {
    _setLoading(true);

    // Check current user
    final result = await _authRepository.getCurrentUser();

    result.fold(
      (failure) {
        _setStatus(AuthStatus.unauthenticated);
        _setError(failure.message);
      },
      (user) {
        if (user != null) {
          _user = user;
          _setStatus(AuthStatus.authenticated);
        } else {
          _setStatus(AuthStatus.unauthenticated);
        }
      },
    );

    _setLoading(false);

    // Listen to auth state changes
    _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        _user = user;
        _setStatus(AuthStatus.authenticated);
      } else {
        _user = null;
        _setStatus(AuthStatus.unauthenticated);
      }
    });
  }

  /// Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    _setLoading(true);
    _clearError();
    _setStatus(AuthStatus.authenticating);

    final params = LoginParams(
      email: email,
      password: password,
      rememberMe: rememberMe,
    );

    final result = await _loginUseCase.execute(params);

    result.fold(
      (failure) {
        _setStatus(AuthStatus.error);
        _setError(failure.message);
        _setLoading(false);
      },
      (user) {
        _user = user;
        _setStatus(AuthStatus.authenticated);
        _clearError();
        _setLoading(false);
      },
    );
  }

  /// Register with email and password
  Future<void> register({
    required String email,
    required String password,
    required String confirmPassword,
    String? displayName,
    bool acceptedTerms = false,
    bool subscribeToNewsletter = false,
  }) async {
    _setLoading(true);
    _clearError();
    _setStatus(AuthStatus.authenticating);

    final params = RegisterParams(
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      displayName: displayName,
      acceptedTerms: acceptedTerms,
      subscribeToNewsletter: subscribeToNewsletter,
    );

    final result = await _registerUseCase.execute(params);

    result.fold(
      (failure) {
        _setStatus(AuthStatus.error);
        _setError(failure.message);
        _setLoading(false);
      },
      (user) {
        _user = user;
        _setStatus(AuthStatus.authenticated);
        _clearError();
        _setLoading(false);
      },
    );
  }

  /// Sign out
  Future<void> signOut() async {
    _setLoading(true);

    final result = await _logoutUseCase.execute();

    result.fold(
      (failure) {
        _setError(failure.message);
        _setLoading(false);
      },
      (_) {
        _user = null;
        _setStatus(AuthStatus.unauthenticated);
        _clearError();
        _setLoading(false);
      },
    );
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _clearError();

    final result = await _authRepository.sendPasswordResetEmail(email: email);

    return result.fold(
      (failure) {
        _setError(failure.message);
        _setLoading(false);
        return false;
      },
      (_) {
        _clearError();
        _setLoading(false);
        return true;
      },
    );
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? displayName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? bio,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _authRepository.updateProfile(
      displayName: displayName,
      phoneNumber: phoneNumber,
      dateOfBirth: dateOfBirth,
      bio: bio,
    );

    return result.fold(
      (failure) {
        _setError(failure.message);
        _setLoading(false);
        return false;
      },
      (user) {
        _user = user;
        _clearError();
        _setLoading(false);
        notifyListeners();
        return true;
      },
    );
  }

  /// Send email verification
  Future<bool> sendEmailVerification() async {
    _setLoading(true);
    _clearError();

    final result = await _authRepository.sendEmailVerification();

    return result.fold(
      (failure) {
        _setError(failure.message);
        _setLoading(false);
        return false;
      },
      (_) {
        _clearError();
        _setLoading(false);
        return true;
      },
    );
  }

  /// Reload user data
  Future<void> reloadUser() async {
    final result = await _authRepository.reloadUser();

    result.fold(
      (failure) => null,
      (user) {
        _user = user;
        notifyListeners();
      },
    );
  }

  /// Check if email is registered
  Future<bool> isEmailRegistered(String email) async {
    final result = await _authRepository.isEmailRegistered(email: email);

    return result.fold(
      (failure) => false,
      (isRegistered) => isRegistered,
    );
  }

  // Private helper methods
  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  /// Clear all state (useful for testing)
  void clearState() {
    _status = AuthStatus.initial;
    _user = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}