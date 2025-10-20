# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Capital Reserve Tracker is a Flutter application for tracking capital reserves. The project uses a standard Flutter structure with multi-platform support (Android, iOS, Web, Windows, Linux, macOS).

## Development Commands

### Working Directory
All Flutter commands must be run from the `app/` directory:
```bash
cd app
```

### Essential Commands
- **Run the app**: `flutter run` (from app/)
- **Run on specific device**: `flutter run -d <device-id>`
- **List devices**: `flutter devices`
- **Hot reload**: Press `r` in terminal while app is running
- **Hot restart**: Press `R` in terminal while app is running
- **Get dependencies**: `flutter pub get` (from app/)
- **Upgrade dependencies**: `flutter pub upgrade` (from app/)

### Testing & Quality
- **Run all tests**: `flutter test` (from app/)
- **Run specific test**: `flutter test test/widget_test.dart` (from app/)
- **Analyze code**: `flutter analyze` (from app/)

### Build Commands
- **Build APK (Android)**: `flutter build apk` (from app/)
- **Build iOS**: `flutter build ios` (from app/)
- **Build Web**: `flutter build web` (from app/)
- **Build Windows**: `flutter build windows` (from app/)

### Clean & Reset
- **Clean build**: `flutter clean` (from app/)
- **Clean and reinstall**: `flutter clean && flutter pub get` (from app/)

## Project Structure

- **app/**: Main Flutter application directory
  - **lib/**: Dart source code
    - **main.dart**: Application entry point
  - **test/**: Test files
  - **android/**, **ios/**, **web/**, **windows/**, **linux/**, **macos/**: Platform-specific code
  - **pubspec.yaml**: Dependencies and project configuration
  - **analysis_options.yaml**: Linter rules (uses flutter_lints package)

## Technical Details

- **SDK Version**: Dart ^3.9.2
- **Flutter Version**: 3.0+
- **Architecture**: Clean Architecture with MVVM pattern
- **State Management**: Provider (ChangeNotifier)
- **Backend**: Firebase (Auth, Firestore, Storage, Crashlytics, Analytics, Messaging)
- **Functional Programming**: dartz (Either pattern for error handling)
- **Local Storage**: flutter_secure_storage
- **Notifications**: flutter_local_notifications
- **Linting**: Uses `package:flutter_lints` with recommended rules

### Key Dependencies
- **firebase_core**: ^3.13.1 - Firebase initialization
- **firebase_auth**: ^5.3.5 - User authentication
- **cloud_firestore**: ^5.7.1 - NoSQL database
- **provider**: ^6.1.2 - State management and dependency injection
- **dartz**: ^0.10.1 - Functional programming (Either, Option)
- **equatable**: ^2.0.7 - Value equality without boilerplate
- **intl**: ^0.19.0 - Internationalization and date formatting
