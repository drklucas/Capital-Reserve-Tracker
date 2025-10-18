import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Core
import 'core/config/env_config.dart';
import 'core/constants/app_constants.dart';
import 'firebase_options.dart';

// Domain
import 'domain/usecases/login_usecase.dart';
import 'domain/usecases/register_usecase.dart';
import 'domain/usecases/logout_usecase.dart';
import 'domain/usecases/transaction/create_transaction_usecase.dart';
import 'domain/usecases/transaction/update_transaction_usecase.dart';
import 'domain/usecases/transaction/delete_transaction_usecase.dart';
import 'domain/usecases/transaction/get_transactions_usecase.dart';
import 'domain/usecases/transaction/watch_transactions_usecase.dart';
import 'domain/usecases/goal/create_goal_usecase.dart';
import 'domain/usecases/goal/update_goal_usecase.dart';
import 'domain/usecases/goal/delete_goal_usecase.dart';
import 'domain/usecases/goal/get_goals_usecase.dart';
import 'domain/usecases/goal/get_goal_by_id_usecase.dart';
import 'domain/usecases/goal/watch_goals_usecase.dart';
import 'domain/usecases/goal/update_goal_status_usecase.dart';

// Data
import 'data/datasources/auth_remote_datasource.dart';
import 'data/datasources/transaction_remote_datasource.dart';
import 'data/datasources/goal_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/transaction_repository_impl.dart';
import 'data/repositories/goal_repository_impl.dart';

// Presentation
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/transaction_provider.dart';
import 'presentation/providers/goal_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'presentation/screens/auth/forgot_password_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/transactions/transactions_screen.dart';
import 'presentation/screens/goals/goals_screen.dart';

/// Main entry point of the application
///
/// SECURITY WARNING: Ensure .env file exists with Firebase configuration
/// Never commit .env file to version control
void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations (optional)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Load environment configuration
  // SECURITY: This reads from .env file which should never be committed
  await EnvConfig.initialize();

  // Validate environment configuration
  if (!EnvConfig.validateConfig()) {
    print('ERROR: Invalid environment configuration');
    print('Please ensure .env file exists with valid Firebase configuration');
    print('Copy .env.example to .env and update with your Firebase credentials');
    // In production, you might want to show an error screen instead
    return;
  }

  // Log configuration (only in debug mode)
  EnvConfig.logConfiguration();

  // Initialize Firebase with platform-specific options
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('ERROR: Failed to initialize Firebase: $e');
    print('Please check your Firebase configuration');
    return;
  }

  // Run the app with providers
  runApp(
    MultiProvider(
      providers: [
        // Firebase instances
        Provider<FirebaseAuth>.value(value: FirebaseAuth.instance),
        Provider<FirebaseFirestore>.value(value: FirebaseFirestore.instance),

        // Data sources
        Provider<AuthRemoteDataSource>(
          create: (context) => AuthRemoteDataSourceImpl(
            firebaseAuth: context.read<FirebaseAuth>(),
            firestore: context.read<FirebaseFirestore>(),
          ),
        ),

        // Repositories
        Provider<AuthRepositoryImpl>(
          create: (context) => AuthRepositoryImpl(
            remoteDataSource: context.read<AuthRemoteDataSource>(),
          ),
        ),

        // Use cases
        Provider<LoginUseCase>(
          create: (context) => LoginUseCase(
            context.read<AuthRepositoryImpl>(),
          ),
        ),
        Provider<RegisterUseCase>(
          create: (context) => RegisterUseCase(
            context.read<AuthRepositoryImpl>(),
          ),
        ),
        Provider<LogoutUseCase>(
          create: (context) => LogoutUseCase(
            context.read<AuthRepositoryImpl>(),
          ),
        ),

        // Transaction data sources
        Provider<TransactionRemoteDataSource>(
          create: (context) => TransactionRemoteDataSource(
            firestore: context.read<FirebaseFirestore>(),
          ),
        ),

        // Transaction repositories
        Provider<TransactionRepositoryImpl>(
          create: (context) => TransactionRepositoryImpl(
            remoteDataSource: context.read<TransactionRemoteDataSource>(),
          ),
        ),

        // Transaction use cases
        Provider<CreateTransactionUseCase>(
          create: (context) => CreateTransactionUseCase(
            context.read<TransactionRepositoryImpl>(),
          ),
        ),
        Provider<UpdateTransactionUseCase>(
          create: (context) => UpdateTransactionUseCase(
            context.read<TransactionRepositoryImpl>(),
          ),
        ),
        Provider<DeleteTransactionUseCase>(
          create: (context) => DeleteTransactionUseCase(
            context.read<TransactionRepositoryImpl>(),
          ),
        ),
        Provider<GetTransactionsUseCase>(
          create: (context) => GetTransactionsUseCase(
            context.read<TransactionRepositoryImpl>(),
          ),
        ),
        Provider<WatchTransactionsUseCase>(
          create: (context) => WatchTransactionsUseCase(
            context.read<TransactionRepositoryImpl>(),
          ),
        ),

        // Goal data sources
        Provider<GoalRemoteDataSource>(
          create: (context) => GoalRemoteDataSource(
            firestore: context.read<FirebaseFirestore>(),
          ),
        ),

        // Goal repositories
        Provider<GoalRepositoryImpl>(
          create: (context) => GoalRepositoryImpl(
            remoteDataSource: context.read<GoalRemoteDataSource>(),
          ),
        ),

        // Goal use cases
        Provider<CreateGoalUseCase>(
          create: (context) => CreateGoalUseCase(
            context.read<GoalRepositoryImpl>(),
          ),
        ),
        Provider<UpdateGoalUseCase>(
          create: (context) => UpdateGoalUseCase(
            context.read<GoalRepositoryImpl>(),
          ),
        ),
        Provider<DeleteGoalUseCase>(
          create: (context) => DeleteGoalUseCase(
            context.read<GoalRepositoryImpl>(),
          ),
        ),
        Provider<GetGoalsUseCase>(
          create: (context) => GetGoalsUseCase(
            context.read<GoalRepositoryImpl>(),
          ),
        ),
        Provider<GetGoalByIdUseCase>(
          create: (context) => GetGoalByIdUseCase(
            context.read<GoalRepositoryImpl>(),
          ),
        ),
        Provider<WatchGoalsUseCase>(
          create: (context) => WatchGoalsUseCase(
            context.read<GoalRepositoryImpl>(),
          ),
        ),
        Provider<UpdateGoalStatusUseCase>(
          create: (context) => UpdateGoalStatusUseCase(
            context.read<GoalRepositoryImpl>(),
          ),
        ),

        // Providers (State Management)
        ChangeNotifierProvider<AppAuthProvider>(
          create: (context) => AppAuthProvider(
            loginUseCase: context.read<LoginUseCase>(),
            registerUseCase: context.read<RegisterUseCase>(),
            logoutUseCase: context.read<LogoutUseCase>(),
            authRepository: context.read<AuthRepositoryImpl>(),
          ),
        ),

        ChangeNotifierProvider<TransactionProvider>(
          create: (context) => TransactionProvider(
            createTransactionUseCase: context.read<CreateTransactionUseCase>(),
            updateTransactionUseCase: context.read<UpdateTransactionUseCase>(),
            deleteTransactionUseCase: context.read<DeleteTransactionUseCase>(),
            getTransactionsUseCase: context.read<GetTransactionsUseCase>(),
            watchTransactionsUseCase: context.read<WatchTransactionsUseCase>(),
          ),
        ),

        ChangeNotifierProvider<GoalProvider>(
          create: (context) => GoalProvider(
            createGoalUseCase: context.read<CreateGoalUseCase>(),
            updateGoalUseCase: context.read<UpdateGoalUseCase>(),
            deleteGoalUseCase: context.read<DeleteGoalUseCase>(),
            getGoalsUseCase: context.read<GetGoalsUseCase>(),
            getGoalByIdUseCase: context.read<GetGoalByIdUseCase>(),
            watchGoalsUseCase: context.read<WatchGoalsUseCase>(),
            updateGoalStatusUseCase: context.read<UpdateGoalStatusUseCase>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

/// Root application widget
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: AppConstants.showDebugBanner,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF2196F3),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
          ),
        ),
      ),
      home: const AuthWrapper(),
      routes: {
        AppConstants.loginRoute: (context) => const LoginScreen(),
        AppConstants.registerRoute: (context) => const RegisterScreen(),
        AppConstants.forgotPasswordRoute: (context) =>
            const ForgotPasswordScreen(),
        AppConstants.homeRoute: (context) => const HomeScreen(),
        '/transactions': (context) => const TransactionsScreen(),
        '/goals': (context) => const GoalsScreen(),
      },
    );
  }
}

/// Auth wrapper to handle authentication state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppAuthProvider>(
      builder: (context, authProvider, _) {
        // Show loading while checking auth state
        if (authProvider.status == AuthStatus.initial ||
            authProvider.status == AuthStatus.authenticating) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Navigate based on auth status
        if (authProvider.status == AuthStatus.authenticated) {
          return const HomeScreen();
        }

        // Default to login screen
        return const LoginScreen();
      },
    );
  }
}
