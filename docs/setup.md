# Capital Reserve Tracker - Setup Guide

## Prerequisites

Before you begin, ensure you have the following installed:

- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Android Studio or VS Code with Flutter extensions
- Git
- Firebase CLI (`npm install -g firebase-tools`)
- FlutterFire CLI (`dart pub global activate flutterfire_cli`)

## Project Setup

### 1. Clone the Repository

```bash
git clone https://github.com/drklucas/Capital-Reserve-Tracker.git
cd Capital-Reserve-Tracker
```

### 2. Firebase Configuration

#### Getting Firebase Credentials

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select the project: `mygoals-19463`
3. Navigate to Project Settings (gear icon)
4. In the "General" tab, scroll down to "Your apps"

#### For Android:
1. Click "Add app" and select Android
2. Enter package name: `com.example.capital_reserve_tracker`
3. Download `google-services.json`
4. Place it in `app/android/app/` directory
5. **IMPORTANT**: Never commit this file to version control!

#### For iOS:
1. Click "Add app" and select iOS
2. Enter bundle ID: `com.example.capitalreservetracker`
3. Download `GoogleService-Info.plist`
4. Place it in `app/ios/Runner/` directory
5. **IMPORTANT**: Never commit this file to version control!

#### For Web:
1. Click "Add app" and select Web
2. Register your app with a nickname
3. Copy the Firebase configuration values
4. You'll use these in the `.env` file (see below)

### 3. Environment Configuration

#### Create .env File

1. Navigate to the `app/` directory
2. Copy `.env.example` to `.env`:
   ```bash
   cd app
   cp .env.example .env
   ```

3. Edit `.env` and replace placeholder values with your actual Firebase configuration:

```env
# Get these values from Firebase Console > Project Settings
FIREBASE_PROJECT_ID=mygoals-19463
FIREBASE_API_KEY=your_actual_api_key_here
FIREBASE_APP_ID=your_actual_app_id_here
FIREBASE_MESSAGING_SENDER_ID=your_actual_sender_id_here
FIREBASE_STORAGE_BUCKET=mygoals-19463.appspot.com

# Keep these as is for now
IOS_BUNDLE_ID=com.example.capitalreservetracker
ANDROID_PACKAGE_NAME=com.example.capital_reserve_tracker
ENVIRONMENT=development
DEBUG_MODE=true
```

**SECURITY WARNING**:
- Never commit the `.env` file to version control
- The `.gitignore` is already configured to exclude it
- Keep your credentials secure and never share them publicly

### 4. FlutterFire Configuration

Run the FlutterFire CLI to configure your Firebase project:

```bash
cd app
flutterfire configure --project=mygoals-19463
```

This command will:
- Generate `firebase_options.dart` in your lib folder
- Configure platform-specific Firebase settings
- Set up necessary Firebase configurations

**Note**: The `firebase_options.dart` file can be committed as it doesn't contain sensitive credentials.

### 5. Install Dependencies

Navigate to the app directory and install Flutter dependencies:

```bash
cd app
flutter pub get
```

### 6. Platform-Specific Setup

#### Android Setup
1. Ensure minimum SDK version is 21 or higher in `android/app/build.gradle`
2. Verify `google-services.json` is in `android/app/` directory
3. Check that the Google Services plugin is applied in `android/app/build.gradle`

#### iOS Setup
1. Open `ios/Runner.xcworkspace` in Xcode
2. Ensure minimum iOS deployment target is 12.0 or higher
3. Verify `GoogleService-Info.plist` is added to the Runner target
4. Run `pod install` in the `ios` directory:
   ```bash
   cd ios
   pod install
   ```

### 7. Run the Application

#### Debug Mode
```bash
flutter run
```

#### Release Mode
```bash
flutter run --release
```

#### Specific Platform
```bash
# Android
flutter run -d android

# iOS (macOS only)
flutter run -d ios

# Web
flutter run -d chrome
```

## Troubleshooting

### Common Issues and Solutions

1. **Firebase initialization error**
   - Ensure `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) is in the correct location
   - Verify Firebase project ID matches in all configuration files
   - Run `flutter clean` and rebuild

2. **.env file not found**
   - Ensure `.env` file exists in the `app/` directory
   - Check that `.env` is listed in the assets section of `pubspec.yaml`
   - Run `flutter pub get` after creating the file

3. **Authentication not working**
   - Enable Authentication in Firebase Console
   - Enable Email/Password sign-in method
   - Check Firebase Auth rules

4. **Firestore permission denied**
   - Update Firestore security rules in Firebase Console
   - Ensure user is properly authenticated
   - Check network connectivity

5. **Build failures**
   ```bash
   # Clean and rebuild
   flutter clean
   flutter pub get
   flutter run
   ```

## Development Workflow

1. Always pull latest changes before starting work:
   ```bash
   git pull origin main
   ```

2. Create a feature branch for your work:
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. Before committing, ensure no sensitive files are included:
   ```bash
   git status
   # Check that no .env, google-services.json, or GoogleService-Info.plist files are staged
   ```

4. Run tests before pushing:
   ```bash
   flutter test
   ```

5. Format your code:
   ```bash
   flutter format .
   ```

6. Analyze for issues:
   ```bash
   flutter analyze
   ```

## Security Checklist

Before every commit, verify:

- [ ] No `.env` file is being committed
- [ ] No `google-services.json` is being committed
- [ ] No `GoogleService-Info.plist` is being committed
- [ ] No API keys or credentials are hardcoded in the source code
- [ ] No sensitive user data is logged to console
- [ ] All debug print statements are removed
- [ ] Firebase security rules are properly configured

## Next Steps

After successful setup:

1. Test authentication flow (register, login, logout)
2. Verify Firestore connection
3. Set up Firebase Security Rules
4. Configure Firebase Analytics (optional)
5. Set up CI/CD pipeline
6. Review architecture documentation

## Support

If you encounter issues not covered in this guide:

1. Check the [Flutter documentation](https://flutter.dev/docs)
2. Review [Firebase documentation](https://firebase.google.com/docs)
3. Search for similar issues in the project's issue tracker
4. Create a new issue with detailed error messages and steps to reproduce

## Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Flutter Setup](https://firebase.google.com/docs/flutter/setup)
- [FlutterFire Documentation](https://firebase.flutter.dev/docs/overview)
- [Clean Architecture Guide](./architecture.md)
- [Security Guidelines](./security.md)