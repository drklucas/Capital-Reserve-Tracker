import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final userModel = await _remoteDataSource.getCurrentUser();
      return Right(userModel?.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await _remoteDataSource.signInWithEmailAndPassword(
        email,
        password,
      );
      return Right(userModel.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure.fromFirebaseCode(e.code ?? 'unknown'));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> registerWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final userModel = await _remoteDataSource.registerWithEmailAndPassword(
        email,
        password,
        displayName,
      );
      return Right(userModel.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure.fromFirebaseCode(e.code ?? 'unknown'));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await _remoteDataSource.sendPasswordResetEmail(email);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure.fromFirebaseCode(e.code ?? 'unknown'));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? bio,
  }) async {
    try {
      final profileData = <String, dynamic>{};

      if (displayName != null) profileData['displayName'] = displayName;
      if (photoUrl != null) profileData['photoUrl'] = photoUrl;
      if (phoneNumber != null) profileData['phoneNumber'] = phoneNumber;
      if (dateOfBirth != null) profileData['dateOfBirth'] = dateOfBirth.toIso8601String();
      if (bio != null) profileData['bio'] = bio;

      final userModel = await _remoteDataSource.updateProfile(profileData);
      return Right(userModel.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification() async {
    try {
      await _remoteDataSource.sendEmailVerification();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isEmailRegistered({
    required String email,
  }) async {
    try {
      final isRegistered = await _remoteDataSource.isEmailRegistered(email);
      return Right(isRegistered);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _remoteDataSource.authStateChanges.map((firebaseUser) {
      if (firebaseUser == null) return null;
      return UserModel.fromFirebaseUser(firebaseUser).toEntity();
    });
  }

  @override
  bool get isSignedIn => _remoteDataSource.isSignedIn;

  @override
  String? get currentUserId => _remoteDataSource.currentUserId;

  // Simplified implementations for MVP
  @override
  Future<Either<Failure, UserEntity>> reloadUser() async {
    return getCurrentUser().then((result) {
      return result.fold(
        (failure) => Left(failure),
        (user) {
          if (user == null) {
            return const Left(AuthFailure(message: 'No user signed in'));
          }
          return Right(user);
        },
      );
    });
  }

  @override
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return const Left(NotImplementedFailure());
  }

  @override
  Future<Either<Failure, void>> deleteAccount({
    required String password,
  }) async {
    return const Left(NotImplementedFailure());
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    return const Left(NotImplementedFailure());
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithApple() async {
    return const Left(NotImplementedFailure());
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithFacebook() async {
    return const Left(NotImplementedFailure());
  }

  @override
  Future<Either<Failure, UserEntity>> linkWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return const Left(NotImplementedFailure());
  }

  @override
  Future<Either<Failure, UserEntity>> unlinkProvider({
    required String providerId,
  }) async {
    return const Left(NotImplementedFailure());
  }

  @override
  Future<Either<Failure, void>> reAuthenticate({
    required String password,
  }) async {
    return const Left(NotImplementedFailure());
  }

  @override
  Future<Either<Failure, void>> updateEmail({
    required String newEmail,
    required String password,
  }) async {
    return const Left(NotImplementedFailure());
  }
}