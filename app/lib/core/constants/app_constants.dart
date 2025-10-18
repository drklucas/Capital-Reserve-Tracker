/// Application-wide constants
class AppConstants {
  // Prevent instantiation
  AppConstants._();

  /// App Information
  static const String appName = 'Capital Reserve Tracker';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Track your capital reserves for your sabbatical year goal';

  /// Routing
  static const String initialRoute = '/';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String forgotPasswordRoute = '/forgot-password';
  static const String homeRoute = '/home';
  static const String profileRoute = '/profile';
  static const String settingsRoute = '/settings';
  static const String goalsRoute = '/goals';
  static const String transactionsRoute = '/transactions';

  /// Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  /// Layout Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 12.0;
  static const double defaultElevation = 4.0;

  /// Form Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int maxEmailLength = 255;

  /// Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  /// Cache
  static const Duration cacheExpiration = Duration(hours: 24);
  static const String cachePrefix = 'crt_cache_';

  /// Local Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String themeKey = 'theme_preference';
  static const String languageKey = 'language_preference';
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String biometricEnabledKey = 'biometric_enabled';

  /// Date Formats
  static const String shortDateFormat = 'MMM dd, yyyy';
  static const String longDateFormat = 'MMMM dd, yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'MMM dd, yyyy HH:mm';

  /// Currency
  static const String defaultCurrency = 'USD';
  static const String currencySymbol = '\$';
  static const int currencyDecimals = 2;

  /// Goal Settings
  static const double minGoalAmount = 100.0;
  static const double maxGoalAmount = 10000000.0;
  static const int minGoalDurationDays = 30;
  static const int maxGoalDurationYears = 10;

  /// Transaction Limits
  static const double minTransactionAmount = 0.01;
  static const double maxTransactionAmount = 1000000.0;
  static const int maxTransactionNoteLength = 500;

  /// UI Messages
  static const String welcomeMessage = 'Welcome to Capital Reserve Tracker';
  static const String loginSuccessMessage = 'Successfully logged in';
  static const String logoutMessage = 'You have been logged out';
  static const String registrationSuccessMessage =
      'Account created successfully';
  static const String passwordResetMessage =
      'Password reset email sent. Check your inbox.';

  /// Error Messages
  static const String genericErrorMessage =
      'Something went wrong. Please try again.';
  static const String networkErrorMessage =
      'No internet connection. Please check your network.';
  static const String authErrorMessage = 'Authentication failed';
  static const String validationErrorMessage = 'Please check your input';
  static const String serverErrorMessage =
      'Server error. Please try again later.';
  static const String timeoutErrorMessage = 'Request timed out';

  /// Success Messages
  static const String saveSuccessMessage = 'Saved successfully';
  static const String updateSuccessMessage = 'Updated successfully';
  static const String deleteSuccessMessage = 'Deleted successfully';

  /// Confirmation Messages
  static const String logoutConfirmation = 'Are you sure you want to logout?';
  static const String deleteConfirmation =
      'Are you sure you want to delete this item?';
  static const String unsavedChangesConfirmation =
      'You have unsaved changes. Do you want to discard them?';

  /// Regex Patterns
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$',
  );

  static final RegExp nameRegex = RegExp(r"^[a-zA-ZÀ-ÿ]+([',. -][a-zA-ZÀ-ÿ]+)*$");

  static final RegExp phoneRegex = RegExp(r'^\+?[\d\s()-]+$');

  /// API Endpoints (for future use)
  static const String apiVersion = 'v1';
  static const String authEndpoint = '/auth';
  static const String usersEndpoint = '/users';
  static const String goalsEndpoint = '/goals';
  static const String transactionsEndpoint = '/transactions';

  /// Feature Flags
  static const bool enableBiometricAuth = true;
  static const bool enablePushNotifications = true;
  static const bool enableDarkMode = true;
  static const bool enableMultipleGoals = true;
  static const bool enableDataExport = true;

  /// Development
  static const bool showDebugBanner = false;
  static const bool enableLogging = true;
  static const bool enablePerformanceOverlay = false;
}