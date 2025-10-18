import 'package:equatable/equatable.dart';

/// User entity representing a user in the domain layer
///
/// This is a pure business object with no dependencies on external packages
/// or implementation details
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final bool isEmailVerified;
  final bool isActive;

  /// Additional profile information
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? bio;

  /// Preferences
  final String? preferredCurrency;
  final String? preferredLanguage;
  final bool notificationsEnabled;
  final bool biometricEnabled;

  /// Statistics
  final int totalGoals;
  final int completedGoals;
  final double totalSaved;

  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    this.lastLogin,
    this.isEmailVerified = false,
    this.isActive = true,
    this.phoneNumber,
    this.dateOfBirth,
    this.bio,
    this.preferredCurrency = 'USD',
    this.preferredLanguage = 'en',
    this.notificationsEnabled = true,
    this.biometricEnabled = false,
    this.totalGoals = 0,
    this.completedGoals = 0,
    this.totalSaved = 0.0,
  });

  /// Get user's first name from display name
  String get firstName {
    if (displayName == null || displayName!.isEmpty) {
      return 'User';
    }
    return displayName!.split(' ').first;
  }

  /// Get user's initials
  String get initials {
    if (displayName == null || displayName!.isEmpty) {
      return email.substring(0, 2).toUpperCase();
    }

    final names = displayName!.split(' ');
    if (names.length >= 2) {
      return '${names.first[0]}${names.last[0]}'.toUpperCase();
    }
    return displayName!.substring(0, min(2, displayName!.length)).toUpperCase();
  }

  /// Check if profile is complete
  bool get isProfileComplete {
    return displayName != null &&
           displayName!.isNotEmpty &&
           phoneNumber != null &&
           phoneNumber!.isNotEmpty &&
           dateOfBirth != null;
  }

  /// Get completion percentage
  double get completionPercentage {
    return totalGoals > 0 ? (completedGoals / totalGoals) * 100 : 0.0;
  }

  /// Get account age in days
  int get accountAgeDays {
    return DateTime.now().difference(createdAt).inDays;
  }

  /// Check if user is new (account less than 7 days old)
  bool get isNewUser {
    return accountAgeDays < 7;
  }

  /// Create a copy with updated fields
  UserEntity copyWith({
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
    return UserEntity(
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

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        photoUrl,
        createdAt,
        lastLogin,
        isEmailVerified,
        isActive,
        phoneNumber,
        dateOfBirth,
        bio,
        preferredCurrency,
        preferredLanguage,
        notificationsEnabled,
        biometricEnabled,
        totalGoals,
        completedGoals,
        totalSaved,
      ];

  @override
  String toString() {
    return 'UserEntity(id: $id, email: $email, displayName: $displayName, isActive: $isActive)';
  }

  /// Helper function for min
  int min(int a, int b) => a < b ? a : b;
}