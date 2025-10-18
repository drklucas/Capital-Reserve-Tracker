import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firebase_constants.dart';
import '../../core/errors/exceptions.dart';
import '../models/user_model.dart';

/// Abstract interface for authentication remote data source
abstract class AuthRemoteDataSource {
  Future<UserModel?> getCurrentUser();
  Future<UserModel> signInWithEmailAndPassword(String email, String password);
  Future<UserModel> registerWithEmailAndPassword(String email, String password, String? displayName);
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<UserModel> updateProfile(Map<String, dynamic> profileData);
  Future<void> sendEmailVerification();
  Future<bool> isEmailRegistered(String email);
  Stream<User?> get authStateChanges;
  bool get isSignedIn;
  String? get currentUserId;
}

/// Implementation of authentication remote data source using Firebase
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore;

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return null;

      // Get additional user data from Firestore
      final userDoc = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(firebaseUser.uid)
          .get();

      if (userDoc.exists) {
        return UserModel.fromJson(userDoc.data()!);
      } else {
        // Create user document if it doesn't exist
        final userModel = UserModel.fromFirebaseUser(firebaseUser);
        await _createUserDocument(userModel);
        return userModel;
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Authentication error', code: e.code);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthException(message: 'Sign in failed');
      }

      // Update last login time in Firestore
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(credential.user!.uid)
          .update({
        FirebaseConstants.lastLoginField: FieldValue.serverTimestamp(),
      });

      // Get complete user data
      final userDoc = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(credential.user!.uid)
          .get();

      if (userDoc.exists) {
        return UserModel.fromJson(userDoc.data()!);
      } else {
        // Create user document if it doesn't exist (for legacy users)
        final userModel = UserModel.fromFirebaseUser(credential.user!);
        await _createUserDocument(userModel);
        return userModel;
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Sign in failed', code: e.code);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> registerWithEmailAndPassword(
    String email,
    String password,
    String? displayName,
  ) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthException(message: 'Registration failed');
      }

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await credential.user!.updateDisplayName(displayName);
        await credential.user!.reload();
      }

      // Create user model
      final userModel = UserModel.fromFirebaseUser(
        _firebaseAuth.currentUser ?? credential.user!,
      ).copyWith(displayName: displayName);

      // Create user document in Firestore
      await _createUserDocument(userModel);

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Registration failed', code: e.code);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Sign out failed', code: e.code);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Password reset failed', code: e.code);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw const AuthException(message: 'No user signed in');
      }

      // Update Firebase Auth profile if display name or photo URL changed
      if (profileData.containsKey('displayName')) {
        await currentUser.updateDisplayName(profileData['displayName']);
      }
      if (profileData.containsKey('photoUrl')) {
        await currentUser.updatePhotoURL(profileData['photoUrl']);
      }

      // Update Firestore document
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(currentUser.uid)
          .update({
        ...profileData,
        FirebaseConstants.updatedAtField: FieldValue.serverTimestamp(),
      });

      // Reload user
      await currentUser.reload();

      // Get updated user data
      final userDoc = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(currentUser.uid)
          .get();

      return UserModel.fromJson(userDoc.data()!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Profile update failed', code: e.code);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw const AuthException(message: 'No user signed in');
      }

      if (!currentUser.emailVerified) {
        await currentUser.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Email verification failed', code: e.code);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<bool> isEmailRegistered(String email) async {
    try {
      // Query Firestore for email
      final querySnapshot = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .where(FirebaseConstants.emailField, isEqualTo: email)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      // If error, try Firebase Auth method (less reliable)
      try {
        final methods = await _firebaseAuth.fetchSignInMethodsForEmail(email);
        // Safe cast to List to handle Pigeon type issues
        return (methods as List).isNotEmpty;
      } catch (_) {
        throw ServerException(message: e.toString());
      }
    }
  }

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  bool get isSignedIn => _firebaseAuth.currentUser != null;

  @override
  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  /// Create user document in Firestore
  Future<void> _createUserDocument(UserModel user) async {
    try {
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.id)
          .set(user.toJson());
    } catch (e) {
      throw DatabaseException(message: 'Failed to create user document: $e');
    }
  }
}