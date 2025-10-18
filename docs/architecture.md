# Architecture Documentation

## Overview

This Flutter application follows **Clean Architecture** principles with **MVVM (Model-View-ViewModel)** pattern for the presentation layer. This architecture ensures separation of concerns, testability, and maintainability.

## Architecture Layers

```
┌─────────────────────────────────────────────────────────┐
│                   Presentation Layer                     │
│                  (UI + State Management)                 │
├─────────────────────────────────────────────────────────┤
│                     Domain Layer                         │
│              (Business Logic + Use Cases)                │
├─────────────────────────────────────────────────────────┤
│                      Data Layer                          │
│            (Repository Implementation + API)             │
└─────────────────────────────────────────────────────────┘
```

### 1. Presentation Layer

**Purpose:** Handle UI rendering and user interactions

**Components:**
- **Screens/Pages:** Flutter widgets that represent full screens
- **Widgets:** Reusable UI components
- **Providers:** State management using Provider package
- **ViewModels:** Business logic for views (part of Provider pattern)

**Directory Structure:**
```
lib/presentation/
├── providers/       # State management
├── screens/        # Full screen widgets
│   ├── auth/
│   ├── home/
│   └── settings/
└── widgets/        # Reusable UI components
```

**Characteristics:**
- Depends on Domain layer
- Contains no business logic
- Handles only UI state and presentation logic
- Uses Provider for state management

### 2. Domain Layer

**Purpose:** Contains business logic and rules

**Components:**
- **Entities:** Core business objects
- **Use Cases:** Application-specific business rules
- **Repository Interfaces:** Contracts for data operations

**Directory Structure:**
```
lib/domain/
├── entities/       # Business objects
├── repositories/   # Abstract repository interfaces
└── usecases/      # Business logic implementation
```

**Characteristics:**
- Most stable layer
- No dependencies on other layers
- Contains pure Dart code (no Flutter dependencies)
- Defines contracts (abstract classes)

### 3. Data Layer

**Purpose:** Handle data operations and external services

**Components:**
- **Models:** Data transfer objects with serialization
- **Data Sources:** Remote (Firebase) and local data sources
- **Repository Implementations:** Concrete implementations of domain repositories

**Directory Structure:**
```
lib/data/
├── datasources/    # Firebase, API, local storage
├── models/        # Data models with JSON serialization
└── repositories/  # Repository implementations
```

**Characteristics:**
- Implements domain repository interfaces
- Handles data transformation (Model ↔ Entity)
- Manages external service communication
- Contains error handling and data validation

### 4. Core Layer

**Purpose:** Shared utilities and constants

**Components:**
- **Constants:** App-wide constant values
- **Errors:** Error and exception definitions
- **Utils:** Helper functions and utilities
- **Config:** Environment and app configuration

**Directory Structure:**
```
lib/core/
├── config/        # Environment configuration
├── constants/     # App constants
├── errors/        # Error handling
└── utils/         # Utility functions
```

## Data Flow

```
User Interaction → UI → Provider → Use Case → Repository → Data Source
                    ↑                                           ↓
                    └─────────────────────────────────────────┘
```

1. User interacts with UI
2. UI notifies Provider
3. Provider executes Use Case
4. Use Case calls Repository
5. Repository fetches data from Data Source
6. Data flows back through the layers
7. Provider updates UI

## State Management: Provider

We use **Provider** for state management because:

1. **Simplicity:** Easy to understand and implement
2. **Performance:** Efficient rebuild management
3. **Flutter Integration:** Built with Flutter in mind
4. **Testability:** Easy to mock and test
5. **Scalability:** Works well for apps of all sizes

### Provider Pattern Implementation

```dart
// ViewModel/Provider
class AuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;

  AuthState _state = AuthState.initial();
  AuthState get state => _state;

  Future<void> login(String email, String password) async {
    _state = AuthState.loading();
    notifyListeners();

    final result = await _loginUseCase.execute(email, password);

    result.fold(
      (failure) => _state = AuthState.error(failure.message),
      (user) => _state = AuthState.authenticated(user),
    );
    notifyListeners();
  }
}

// Usage in Widget
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    if (authProvider.state.isLoading) {
      return CircularProgressIndicator();
    }
    // ... rest of UI
  },
)
```

## Dependency Injection

We use **Provider** for dependency injection at the app level:

```dart
MultiProvider(
  providers: [
    Provider(create: (_) => FirebaseAuth.instance),
    Provider(create: (_) => FirebaseFirestore.instance),

    // Data Sources
    Provider(create: (context) => AuthRemoteDataSource(
      context.read<FirebaseAuth>(),
    )),

    // Repositories
    Provider(create: (context) => AuthRepositoryImpl(
      context.read<AuthRemoteDataSource>(),
    )),

    // Use Cases
    Provider(create: (context) => LoginUseCase(
      context.read<AuthRepository>(),
    )),

    // ViewModels/Providers
    ChangeNotifierProvider(create: (context) => AuthProvider(
      context.read<LoginUseCase>(),
    )),
  ],
  child: MyApp(),
)
```

## Error Handling

### Failure Types

```dart
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

class AuthFailure extends Failure {
  const AuthFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}
```

### Either Pattern (using dartz)

```dart
Future<Either<Failure, User>> login(String email, String password) async {
  try {
    final user = await remoteDataSource.login(email, password);
    return Right(user);
  } on ServerException catch (e) {
    return Left(ServerFailure(e.message));
  } on NetworkException {
    return Left(NetworkFailure('No internet connection'));
  }
}
```

## Testing Strategy

### 1. Unit Tests
- Test individual classes and functions
- Mock dependencies
- Test business logic in isolation

```dart
test('should return user when login is successful', () async {
  // Arrange
  when(mockRepository.login(any, any))
    .thenAnswer((_) async => Right(tUser));

  // Act
  final result = await useCase.execute(email, password);

  // Assert
  expect(result, Right(tUser));
});
```

### 2. Widget Tests
- Test individual widgets
- Test widget interactions
- Test UI state changes

```dart
testWidgets('should show loading indicator when state is loading',
  (tester) async {
    // Arrange
    when(mockProvider.state).thenReturn(AuthState.loading());

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(),
      ),
    );

    // Assert
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  },
);
```

### 3. Integration Tests
- Test complete user flows
- Test Firebase integration
- Test navigation and state persistence

## Folder Structure

```
lib/
├── core/
│   ├── config/
│   │   └── env_config.dart
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── firebase_constants.dart
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   └── utils/
│       ├── date_utils.dart
│       └── validators.dart
├── data/
│   ├── datasources/
│   │   ├── auth_remote_datasource.dart
│   │   └── firestore_datasource.dart
│   ├── models/
│   │   ├── user_model.dart
│   │   └── goal_model.dart
│   └── repositories/
│       ├── auth_repository_impl.dart
│       └── goal_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── user_entity.dart
│   │   └── goal_entity.dart
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   └── goal_repository.dart
│   └── usecases/
│       ├── auth/
│       │   ├── login_usecase.dart
│       │   ├── logout_usecase.dart
│       │   └── register_usecase.dart
│       └── goals/
│           ├── create_goal_usecase.dart
│           └── get_goals_usecase.dart
├── presentation/
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   └── goal_provider.dart
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── home/
│   │   │   └── home_screen.dart
│   │   └── goals/
│   │       └── goals_screen.dart
│   └── widgets/
│       ├── custom_button.dart
│       └── custom_textfield.dart
└── main.dart
```

## Best Practices

### 1. Separation of Concerns
- Each layer has a single responsibility
- No cross-layer dependencies
- Clear boundaries between layers

### 2. Dependency Rule
- Dependencies point inward
- Inner layers know nothing about outer layers
- Use dependency injection

### 3. Testability
- Write testable code
- Use dependency injection
- Mock external dependencies

### 4. Error Handling
- Use Either pattern for error handling
- Define specific failure types
- Provide meaningful error messages

### 5. Code Organization
- Follow consistent naming conventions
- Group related files together
- Keep files small and focused

## Design Patterns Used

### 1. Repository Pattern
- Abstracts data source operations
- Provides clean API for data access
- Enables easy testing and mocking

### 2. Use Case Pattern
- Encapsulates business logic
- Single responsibility principle
- Reusable across different presentations

### 3. Factory Pattern
- Used in model classes for JSON parsing
- Creates objects from different data sources

### 4. Observer Pattern
- Implemented through Provider/ChangeNotifier
- Enables reactive UI updates

### 5. Singleton Pattern
- Used for service instances
- Firebase service instances

## Performance Considerations

### 1. State Management
- Use `Consumer` widgets efficiently
- Implement `Selector` for granular rebuilds
- Avoid unnecessary state updates

### 2. Memory Management
- Dispose of controllers and streams
- Use `const` constructors where possible
- Implement lazy loading for large lists

### 3. Network Optimization
- Implement caching strategies
- Use pagination for large data sets
- Optimize Firebase queries

## Security Considerations

### 1. Authentication
- Implement proper authentication flows
- Store tokens securely
- Handle session management

### 2. Data Validation
- Validate all user inputs
- Sanitize data before storage
- Implement proper error handling

### 3. Secure Communication
- Use HTTPS for all API calls
- Implement certificate pinning
- Encrypt sensitive local data

## Future Enhancements

### Planned Improvements
1. **Offline Support**
   - Implement local caching
   - Sync mechanism for offline changes
   - Conflict resolution

2. **Advanced State Management**
   - Consider Riverpod for more features
   - Implement state persistence
   - Add undo/redo functionality

3. **Modularization**
   - Create feature modules
   - Implement micro-frontends approach
   - Enable dynamic feature delivery

4. **Analytics Integration**
   - Add Firebase Analytics
   - Implement custom events
   - Create dashboards for insights

## Conclusion

This architecture provides:
- **Maintainability:** Clear structure and separation
- **Testability:** Easy to test each component
- **Scalability:** Can grow with the application
- **Flexibility:** Easy to change implementations
- **Team Collaboration:** Clear boundaries for parallel development

Following these architectural principles ensures a robust, maintainable, and scalable Flutter application.