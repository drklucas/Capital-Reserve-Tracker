import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration manager
///
/// SECURITY WARNING: This class reads from .env file which should NEVER be committed
/// Always ensure .env is in .gitignore
class EnvConfig {
  // Prevent instantiation
  EnvConfig._();

  /// Initialize environment configuration
  /// Must be called before accessing any environment variables
  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
  }

  /// Firebase configuration
  static String get firebaseProjectId =>
      dotenv.env['FIREBASE_PROJECT_ID'] ?? '';

  static String get firebaseApiKey =>
      dotenv.env['FIREBASE_API_KEY'] ?? '';

  static String get firebaseAppId => dotenv.env['FIREBASE_APP_ID'] ?? '';

  static String get firebaseMessagingSenderId =>
      dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';

  static String get firebaseStorageBucket =>
      dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';

  /// Platform configuration
  static String get iosBundleId => dotenv.env['IOS_BUNDLE_ID'] ?? '';

  static String get androidPackageName =>
      dotenv.env['ANDROID_PACKAGE_NAME'] ?? '';

  /// Environment settings
  static String get environment =>
      dotenv.env['ENVIRONMENT'] ?? 'development';

  static bool get isDebugMode =>
      dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';

  static bool get isProduction => environment == 'production';

  static bool get isDevelopment => environment == 'development';

  static bool get isStaging => environment == 'staging';

  /// Feature flags
  static bool get enableAnalytics =>
      dotenv.env['ENABLE_ANALYTICS']?.toLowerCase() == 'true';

  static bool get enableCrashlytics =>
      dotenv.env['ENABLE_CRASHLYTICS']?.toLowerCase() == 'true';

  /// API Configuration (for future use)
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';

  static int get apiTimeout =>
      int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30000') ?? 30000;

  /// Security settings
  static bool get enableSslPinning =>
      dotenv.env['ENABLE_SSL_PINNING']?.toLowerCase() == 'true';

  static bool get enableRootDetection =>
      dotenv.env['ENABLE_ROOT_DETECTION']?.toLowerCase() == 'true';

  /// Validate required environment variables
  static bool validateConfig() {
    final requiredVars = [
      'FIREBASE_PROJECT_ID',
      'FIREBASE_API_KEY',
      'FIREBASE_APP_ID',
      'FIREBASE_MESSAGING_SENDER_ID',
      'ENVIRONMENT',
    ];

    for (final varName in requiredVars) {
      if (dotenv.env[varName] == null || dotenv.env[varName]!.isEmpty) {
        print('WARNING: Missing required environment variable: $varName');
        return false;
      }
    }

    // Security check: Warn if using default/example values
    if (firebaseApiKey.contains('your_api_key_here') ||
        firebaseApiKey.contains('example')) {
      print('SECURITY WARNING: Using example/default API key!');
      print('Please update your .env file with real Firebase credentials');
      return false;
    }

    return true;
  }

  /// Log configuration (only in debug mode)
  static void logConfiguration() {
    if (!isDebugMode) return;

    print('=== Environment Configuration ===');
    print('Environment: $environment');
    print('Debug Mode: $isDebugMode');
    print('Firebase Project: $firebaseProjectId');
    print('Analytics Enabled: $enableAnalytics');
    print('Crashlytics Enabled: $enableCrashlytics');
    print('================================');
  }
}