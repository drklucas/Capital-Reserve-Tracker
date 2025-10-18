import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../core/constants/firebase_constants.dart';
import '../../domain/entities/user_entity.dart';

/// User model for data layer
///
/// Handles conversion between Firebase User and domain UserEntity
class UserModel extends UserEntity {
  const UserModel({
    required String id,
    required String email,
    String? displayName,
    String? photoUrl,
    required DateTime createdAt,
    DateTime? lastLogin,
    bool isEmailVerified = false,
    bool isActive = true,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? bio,
    String? preferredCurrency,
    String? preferredLanguage,
    bool notificationsEnabled = true,
    bool biometricEnabled = false,
    int totalGoals = 0,
    int completedGoals = 0,
    double totalSaved = 0.0,
  }) : super(
          id: id,
          email: email,
          displayName: displayName,
          photoUrl: photoUrl,
          createdAt: createdAt,
          lastLogin: lastLogin,
          isEmailVerified: isEmailVerified,
          isActive: isActive,
          phoneNumber: phoneNumber,
          dateOfBirth: dateOfBirth,
          bio: bio,
          preferredCurrency: preferredCurrency,
          preferredLanguage: preferredLanguage,
          notificationsEnabled: notificationsEnabled,
          biometricEnabled: biometricEnabled,
          totalGoals: totalGoals,
          completedGoals: completedGoals,
          totalSaved: totalSaved,
        );

  /// Create UserModel from Firebase User
  factory UserModel.fromFirebaseUser(firebase_auth.User firebaseUser) {
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      lastLogin: firebaseUser.metadata.lastSignInTime,
      isEmailVerified: firebaseUser.emailVerified,
      phoneNumber: firebaseUser.phoneNumber,
      isActive: true,
    );
  }

  /// Create UserModel from Firestore document
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json[FirebaseConstants.userIdField] as String,
      email: json[FirebaseConstants.emailField] as String,
      displayName: json[FirebaseConstants.displayNameField] as String?,
      photoUrl: json[FirebaseConstants.photoUrlField] as String?,
      createdAt: _parseDateTime(json[FirebaseConstants.createdAtField]),
      lastLogin: _parseDateTime(json[FirebaseConstants.lastLoginField]),
      isEmailVerified: json[FirebaseConstants.isVerifiedField] as bool? ?? false,
      isActive: json[FirebaseConstants.isActiveField] as bool? ?? true,
      phoneNumber: json['phoneNumber'] as String?,
      dateOfBirth: _parseDateTime(json['dateOfBirth']),
      bio: json['bio'] as String?,
      preferredCurrency: json['preferredCurrency'] as String? ?? 'USD',
      preferredLanguage: json['preferredLanguage'] as String? ?? 'en',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      biometricEnabled: json['biometricEnabled'] as bool? ?? false,
      totalGoals: json['totalGoals'] as int? ?? 0,
      completedGoals: json['completedGoals'] as int? ?? 0,
      totalSaved: (json['totalSaved'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Convert UserModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      FirebaseConstants.userIdField: id,
      FirebaseConstants.emailField: email,
      FirebaseConstants.displayNameField: displayName,
      FirebaseConstants.photoUrlField: photoUrl,
      FirebaseConstants.createdAtField: createdAt.toIso8601String(),
      FirebaseConstants.lastLoginField: lastLogin?.toIso8601String(),
      FirebaseConstants.isVerifiedField: isEmailVerified,
      FirebaseConstants.isActiveField: isActive,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'bio': bio,
      'preferredCurrency': preferredCurrency,
      'preferredLanguage': preferredLanguage,
      'notificationsEnabled': notificationsEnabled,
      'biometricEnabled': biometricEnabled,
      'totalGoals': totalGoals,
      'completedGoals': completedGoals,
      'totalSaved': totalSaved,
      FirebaseConstants.updatedAtField: DateTime.now().toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  @override
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? isEmailVerified,
    bool? isActive,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? bio,
    String? preferredCurrency,
    String? preferredLanguage,
    bool? notificationsEnabled,
    bool? biometricEnabled,
    int? totalGoals,
    int? completedGoals,
    double? totalSaved,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isActive: isActive ?? this.isActive,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bio: bio ?? this.bio,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      totalGoals: totalGoals ?? this.totalGoals,
      completedGoals: completedGoals ?? this.completedGoals,
      totalSaved: totalSaved ?? this.totalSaved,
    );
  }

  /// Parse DateTime from various formats
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }

    // Handle Firestore Timestamp
    if (value is Map) {
      final seconds = value['_seconds'] ?? 0;
      final nanoseconds = value['_nanoseconds'] ?? 0;
      return DateTime.fromMillisecondsSinceEpoch(
        seconds * 1000 + nanoseconds ~/ 1000000,
      );
    }

    return DateTime.now();
  }

  /// Convert to UserEntity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      createdAt: createdAt,
      lastLogin: lastLogin,
      isEmailVerified: isEmailVerified,
      isActive: isActive,
      phoneNumber: phoneNumber,
      dateOfBirth: dateOfBirth,
      bio: bio,
      preferredCurrency: preferredCurrency,
      preferredLanguage: preferredLanguage,
      notificationsEnabled: notificationsEnabled,
      biometricEnabled: biometricEnabled,
      totalGoals: totalGoals,
      completedGoals: completedGoals,
      totalSaved: totalSaved,
    );
  }

  /// Create UserModel from UserEntity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      createdAt: entity.createdAt,
      lastLogin: entity.lastLogin,
      isEmailVerified: entity.isEmailVerified,
      isActive: entity.isActive,
      phoneNumber: entity.phoneNumber,
      dateOfBirth: entity.dateOfBirth,
      bio: entity.bio,
      preferredCurrency: entity.preferredCurrency,
      preferredLanguage: entity.preferredLanguage,
      notificationsEnabled: entity.notificationsEnabled,
      biometricEnabled: entity.biometricEnabled,
      totalGoals: entity.totalGoals,
      completedGoals: entity.completedGoals,
      totalSaved: entity.totalSaved,
    );
  }
}