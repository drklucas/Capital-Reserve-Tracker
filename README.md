# Capital Reserve Tracker

## SECURITY WARNING

**THIS IS A PUBLIC REPOSITORY**

Never commit sensitive information, credentials, or private data to this repository. All Firebase credentials and API keys must be stored in local `.env` files that are never committed to version control.

## Overview

Capital Reserve Tracker is a Flutter mobile application designed to help users track their capital reserves and savings progress towards a sabbatical year goal. Built with Clean Architecture principles and powered by Firebase, this app provides a secure and scalable solution for personal financial goal tracking.

### Key Features

- ✅ Secure user authentication with email/password
- ✅ Financial transaction tracking (income and expenses)
- ✅ 15 transaction categories (6 income + 9 expense)
- ✅ Real-time data synchronization with Firestore
- ✅ Transaction filtering (by type, date, goal)
- ✅ Automatic balance calculations
- ⏳ Set and track sabbatical year financial goals (Coming Soon)
- ⏳ Visualize progress with charts and analytics (Coming Soon)
- ⏳ Calculate time to goal achievement (Coming Soon)
- ✅ Multi-platform support (iOS, Android, Web, Windows, Linux, macOS)

## Architecture

This application follows **Clean Architecture** principles with clear separation of concerns:

- **Presentation Layer**: Flutter UI with Provider state management
- **Domain Layer**: Business logic and use cases
- **Data Layer**: Firebase integration and repository implementations

For detailed architecture information, see [Architecture Documentation](docs/architecture.md).

## Tech Stack

- **Frontend**: Flutter 3.x with Dart
- **State Management**: Provider
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Architecture**: Clean Architecture + MVVM
- **Testing**: Unit, Widget, and Integration tests

## Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Firebase CLI
- Android Studio or VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/drklucas/Capital-Reserve-Tracker.git
   cd Capital-Reserve-Tracker
   ```

2. **Set up Firebase**
   - Create a Firebase project at https://console.firebase.google.com
   - Run FlutterFire CLI to configure:
     ```bash
     cd app
     flutterfire configure --project=your-project-id
     ```
   - This will generate `firebase_options.dart` (not committed to git)
   - Alternatively, copy `lib/firebase_options.dart.example` to `lib/firebase_options.dart` and add your credentials

3. **Configure environment variables**
   ```bash
   cd app
   cp .env.example .env
   # Edit .env with your Firebase credentials
   ```

4. **Install dependencies**
   ```bash
   cd app
   flutter pub get
   ```

5. **Run the application**
   ```bash
   flutter run
   ```

For detailed setup instructions, see [Complete Setup Guide](docs/setup.md).

## Project Structure

```
Capital-Reserve-Tracker/
├── app/                    # Flutter application
│   ├── lib/
│   │   ├── core/          # Core utilities and configuration
│   │   ├── data/          # Data layer (repositories, models)
│   │   ├── domain/        # Domain layer (entities, use cases)
│   │   └── presentation/  # UI layer (screens, widgets, providers)
│   ├── test/              # Test files
│   └── .env.example       # Environment variables template
├── docs/                   # Documentation
│   ├── setup.md           # Setup instructions
│   ├── security.md        # Security guidelines
│   ├── architecture.md    # Architecture documentation
│   └── sprints/           # Sprint documentation
└── README.md              # This file
```

## Development Workflow

### Before You Start

1. **Never commit sensitive files**:
   - `.env`
   - `google-services.json`
   - `GoogleService-Info.plist`
   - Any file with API keys or credentials

2. **Always check git status** before committing:
   ```bash
   git status
   git diff --staged
   ```

3. **Run security check**:
   ```bash
   # Check for accidentally staged secrets
   git secrets --scan
   ```

### Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `flutter format` before committing
- Run `flutter analyze` to check for issues

### Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/unit/auth_test.dart
```

## Security

This is a **PUBLIC REPOSITORY**. Security is our top priority:

- All credentials stored in `.env` (never committed)
- Firebase security rules enforced
- Input validation on all forms
- Secure data transmission
- Regular security audits

Read the [Security Guidelines](docs/security.md) for more information.

## Sprint Progress

- **Sprint 1** ✅: Initial setup, authentication, Clean Architecture (Completed)
  - Firebase integration
  - User authentication (login, register, password recovery)
  - Security setup for public repository
  - Complete documentation

- **Sprint 2** ✅: Core features implementation (Completed ~95%)
  - ✅ Financial transaction management (CRUD complete)
  - ✅ 15 transaction categories
  - ✅ Real-time Firestore synchronization
  - ✅ Transaction filtering and calculations
  - ✅ Goal management system (CRUD complete)
  - ✅ Task management with drag-and-drop reordering
  - ✅ Modern dark theme HomeScreen with animations
  - ✅ Real-time stats overview with period filters (Today/Week/Month)
  - ✅ Active goals display with progress tracking
  - ⏳ Advanced charts and analytics (Pending - Sprint 3)

- **Sprint 3** 📋: Analytics and advanced features (Planned)
- **Sprint 4** 📋: Polish, optimization, deployment (Planned)

See [Sprint Documentation](docs/sprints/) for detailed progress.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. **Ensure no secrets are committed**
5. Push to the branch (`git push origin feature/AmazingFeature`)
6. Open a Pull Request

### Commit Message Format

```
type(scope): description

[optional body]

[optional footer]
```

Types: feat, fix, docs, style, refactor, test, chore

## Troubleshooting

### Common Issues

1. **Firebase initialization error**
   - Ensure `.env` file exists with valid credentials
   - Check Firebase project configuration
   - Run `flutterfire configure`

2. **Build failures**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

3. **Authentication not working**
   - Enable Email/Password auth in Firebase Console
   - Check Firestore security rules
   - Verify network connectivity

For more issues, see [Setup Guide](docs/setup.md#troubleshooting).

## Roadmap

### Completed ✅
- [x] User authentication (email/password)
- [x] Clean Architecture setup
- [x] Transaction tracking (income/expense)
- [x] 15 transaction categories
- [x] Real-time data sync
- [x] Transaction filtering
- [x] Goal creation and management
- [x] Task management with reordering
- [x] Modern dark theme UI
- [x] HomeScreen dashboard with stats
- [x] Period-based analytics (Day/Week/Month)

### In Progress 🚧
- [ ] Advanced charts and visualizations (Sprint 3)
- [ ] Export functionality (Sprint 3)

### Planned 📋
- [ ] Progress visualization with charts (Sprint 2-3)
- [ ] Countdown timer (Sprint 2)
- [ ] Push notifications (Sprint 2-3)
- [ ] Export data functionality (Sprint 3)
- [ ] Offline support (Sprint 3)
- [ ] Multi-currency support (Sprint 3)
- [ ] Budget planning features (Sprint 3)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Clean Architecture principles by Robert C. Martin
- Flutter community for packages and support

## Support

For support, please:
1. Check the [documentation](docs/)
2. Search existing [issues](https://github.com/drklucas/Capital-Reserve-Tracker/issues)
3. Create a new issue with detailed information

## Contact

- Project Maintainer: Lucas Neves
- Email: lucasnevesp3@gmail.com
- GitHub: [@drklucas](https://github.com/drklucas)

---

**Remember**: This is a PUBLIC repository. Never commit sensitive information!