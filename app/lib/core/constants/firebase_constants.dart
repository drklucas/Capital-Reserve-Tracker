/// Firebase-specific constants and collection names
///
/// SECURITY NOTE: These are collection names, not credentials
/// Actual Firebase configuration should come from environment variables
class FirebaseConstants {
  // Prevent instantiation
  FirebaseConstants._();

  /// Firestore Collections
  static const String usersCollection = 'users';
  static const String goalsCollection = 'goals';
  static const String transactionsCollection = 'transactions';
  static const String categoriesCollection = 'categories';
  static const String notificationsCollection = 'notifications';
  static const String settingsCollection = 'settings';
  static const String analyticsCollection = 'analytics';

  /// Firestore Subcollections
  static const String userGoalsSubcollection = 'user_goals';
  static const String goalTransactionsSubcollection = 'goal_transactions';
  static const String userNotificationsSubcollection = 'user_notifications';

  /// Firestore Document Fields
  // User fields
  static const String userIdField = 'userId';
  static const String emailField = 'email';
  static const String displayNameField = 'displayName';
  static const String photoUrlField = 'photoUrl';
  static const String createdAtField = 'createdAt';
  static const String updatedAtField = 'updatedAt';
  static const String lastLoginField = 'lastLogin';
  static const String isActiveField = 'isActive';
  static const String isVerifiedField = 'isVerified';
  static const String fcmTokenField = 'fcmToken';

  // Goal fields
  static const String goalIdField = 'goalId';
  static const String goalNameField = 'name';
  static const String goalDescriptionField = 'description';
  static const String targetAmountField = 'targetAmount';
  static const String currentAmountField = 'currentAmount';
  static const String targetDateField = 'targetDate';
  static const String categoryField = 'category';
  static const String priorityField = 'priority';
  static const String statusField = 'status';
  static const String progressField = 'progress';

  // Transaction fields
  static const String transactionIdField = 'transactionId';
  static const String amountField = 'amount';
  static const String typeField = 'type';
  static const String noteField = 'note';
  static const String dateField = 'date';
  static const String attachmentUrlField = 'attachmentUrl';

  /// Storage Buckets
  static const String profileImagesBucket = 'profile_images';
  static const String goalImagesBucket = 'goal_images';
  static const String transactionAttachmentsBucket = 'transaction_attachments';
  static const String documentsBucket = 'documents';

  /// Storage Paths
  static String profileImagePath(String userId) => '$profileImagesBucket/$userId.jpg';

  static String goalImagePath(String goalId) => '$goalImagesBucket/$goalId.jpg';

  static String transactionAttachmentPath(String transactionId, String fileName) =>
      '$transactionAttachmentsBucket/$transactionId/$fileName';

  /// Cloud Functions
  static const String onUserCreatedFunction = 'onUserCreated';
  static const String onGoalCompletedFunction = 'onGoalCompleted';
  static const String sendNotificationFunction = 'sendNotification';
  static const String generateReportFunction = 'generateReport';
  static const String cleanupDataFunction = 'cleanupData';
  static const String calculateStatisticsFunction = 'calculateStatistics';

  /// FCM Topics
  static const String allUsersTopic = 'all_users';
  static const String premiumUsersTopic = 'premium_users';
  static const String goalUpdatesTopic = 'goal_updates';
  static const String promotionsTopic = 'promotions';
  static const String maintenanceTopic = 'maintenance';

  /// Analytics Events
  static const String loginEvent = 'login';
  static const String signupEvent = 'sign_up';
  static const String goalCreatedEvent = 'goal_created';
  static const String goalCompletedEvent = 'goal_completed';
  static const String transactionAddedEvent = 'transaction_added';
  static const String profileUpdatedEvent = 'profile_updated';
  static const String settingsChangedEvent = 'settings_changed';
  static const String shareEvent = 'share';
  static const String errorEvent = 'app_error';

  /// Analytics User Properties
  static const String userTypeProperty = 'user_type';
  static const String goalsCountProperty = 'goals_count';
  static const String accountAgeProperty = 'account_age_days';
  static const String preferredCurrencyProperty = 'preferred_currency';
  static const String notificationEnabledProperty = 'notifications_enabled';

  /// Firestore Limits
  static const int maxBatchSize = 500;
  static const int maxDocumentSize = 1048576; // 1MB in bytes
  static const int maxFieldNameLength = 1500;
  static const int maxQueryFilters = 10;
  static const int maxCompoundIndexes = 200;

  /// Rate Limiting
  static const int maxReadsPerSecond = 50000;
  static const int maxWritesPerSecond = 10000;
  static const int maxConcurrentConnections = 1000000;

  /// Timeouts
  static const Duration connectionTimeout = Duration(seconds: 60);
  static const Duration queryTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(minutes: 5);

  /// Retry Configuration
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  static const double retryBackoffMultiplier = 2.0;

  /// Error Codes
  static const String permissionDeniedCode = 'permission-denied';
  static const String unauthenticatedCode = 'unauthenticated';
  static const String notFoundCode = 'not-found';
  static const String alreadyExistsCode = 'already-exists';
  static const String resourceExhaustedCode = 'resource-exhausted';
  static const String invalidArgumentCode = 'invalid-argument';
  static const String deadlineExceededCode = 'deadline-exceeded';
  static const String unavailableCode = 'unavailable';

  /// Default Values
  static const String defaultProfileImage = 'assets/images/default_profile.png';
  static const String defaultGoalImage = 'assets/images/default_goal.png';
  static const String defaultCategory = 'General';
  static const int defaultPriority = 1;
  static const String defaultStatus = 'active';
  static const String defaultCurrency = 'USD';
}