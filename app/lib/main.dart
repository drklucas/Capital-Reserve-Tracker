import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
import 'domain/usecases/task/create_task_usecase.dart';
import 'domain/usecases/task/update_task_usecase.dart';
import 'domain/usecases/task/delete_task_usecase.dart';
import 'domain/usecases/task/toggle_task_usecase.dart';
import 'domain/usecases/task/get_tasks_by_goal_usecase.dart';
import 'domain/usecases/task/watch_tasks_by_goal_usecase.dart';

// Data
import 'data/datasources/auth_remote_datasource.dart';
import 'data/datasources/transaction_remote_datasource.dart';
import 'data/datasources/goal_remote_datasource.dart';
import 'data/datasources/task_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/transaction_repository_impl.dart';
import 'data/repositories/goal_repository_impl.dart';
import 'data/repositories/task_repository_impl.dart';

// Presentation
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/transaction_provider.dart';
import 'presentation/providers/goal_provider.dart';
import 'presentation/providers/task_provider.dart';
import 'presentation/providers/dashboard_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'presentation/screens/auth/forgot_password_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/transactions/transactions_screen.dart';
import 'presentation/screens/transactions/add_transaction_screen.dart';
import 'presentation/screens/goals/goals_screen.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';
import 'presentation/screens/transactions/import_transactions_screen.dart';

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

  // Initialize locale data for Brazilian Portuguese
  await initializeDateFormatting('pt_BR', null);
  Intl.defaultLocale = 'pt_BR';

  // Initialize Firebase instances
  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  // Initialize data sources
  final authDataSource = AuthRemoteDataSourceImpl(
    firebaseAuth: firebaseAuth,
    firestore: firestore,
  );
  final transactionDataSource = TransactionRemoteDataSource(firestore: firestore);
  final goalDataSource = GoalRemoteDataSource(firestore: firestore);
  final taskDataSource = TaskRemoteDataSource(firestore: firestore);

  // Initialize repositories
  final authRepository = AuthRepositoryImpl(remoteDataSource: authDataSource);
  final transactionRepository = TransactionRepositoryImpl(remoteDataSource: transactionDataSource);
  final goalRepository = GoalRepositoryImpl(remoteDataSource: goalDataSource);
  final taskRepository = TaskRepositoryImpl(remoteDataSource: taskDataSource);

  // Initialize use cases - Auth
  final loginUseCase = LoginUseCase(authRepository);
  final registerUseCase = RegisterUseCase(authRepository);
  final logoutUseCase = LogoutUseCase(authRepository);

  // Initialize use cases - Transaction
  final createTransactionUseCase = CreateTransactionUseCase(transactionRepository);
  final updateTransactionUseCase = UpdateTransactionUseCase(transactionRepository);
  final deleteTransactionUseCase = DeleteTransactionUseCase(transactionRepository);
  final getTransactionsUseCase = GetTransactionsUseCase(transactionRepository);
  final watchTransactionsUseCase = WatchTransactionsUseCase(transactionRepository);

  // Initialize use cases - Goal
  final createGoalUseCase = CreateGoalUseCase(goalRepository);
  final updateGoalUseCase = UpdateGoalUseCase(goalRepository);
  final deleteGoalUseCase = DeleteGoalUseCase(goalRepository);
  final getGoalsUseCase = GetGoalsUseCase(goalRepository);
  final getGoalByIdUseCase = GetGoalByIdUseCase(goalRepository);
  final watchGoalsUseCase = WatchGoalsUseCase(goalRepository);
  final updateGoalStatusUseCase = UpdateGoalStatusUseCase(goalRepository);

  // Initialize use cases - Task
  final createTaskUseCase = CreateTaskUseCase(taskRepository);
  final updateTaskUseCase = UpdateTaskUseCase(taskRepository);
  final deleteTaskUseCase = DeleteTaskUseCase(taskRepository);
  final toggleTaskUseCase = ToggleTaskUseCase(taskRepository);
  final getTasksByGoalUseCase = GetTasksByGoalUseCase(taskRepository);
  final watchTasksByGoalUseCase = WatchTasksByGoalUseCase(taskRepository);

  // Run the app with providers
  runApp(
    MultiProvider(
      providers: [
        // Firebase instances
        Provider<FirebaseAuth>.value(value: firebaseAuth),
        Provider<FirebaseFirestore>.value(value: firestore),

        // Data sources
        Provider<AuthRemoteDataSource>.value(value: authDataSource),
        Provider<TransactionRemoteDataSource>.value(value: transactionDataSource),
        Provider<GoalRemoteDataSource>.value(value: goalDataSource),
        Provider<TaskRemoteDataSource>.value(value: taskDataSource),

        // Repositories
        Provider<AuthRepositoryImpl>.value(value: authRepository),
        Provider<TransactionRepositoryImpl>.value(value: transactionRepository),
        Provider<GoalRepositoryImpl>.value(value: goalRepository),
        Provider<TaskRepositoryImpl>.value(value: taskRepository),

        // Use cases - Auth
        Provider<LoginUseCase>.value(value: loginUseCase),
        Provider<RegisterUseCase>.value(value: registerUseCase),
        Provider<LogoutUseCase>.value(value: logoutUseCase),

        // Use cases - Transaction
        Provider<CreateTransactionUseCase>.value(value: createTransactionUseCase),
        Provider<UpdateTransactionUseCase>.value(value: updateTransactionUseCase),
        Provider<DeleteTransactionUseCase>.value(value: deleteTransactionUseCase),
        Provider<GetTransactionsUseCase>.value(value: getTransactionsUseCase),
        Provider<WatchTransactionsUseCase>.value(value: watchTransactionsUseCase),

        // Use cases - Goal
        Provider<CreateGoalUseCase>.value(value: createGoalUseCase),
        Provider<UpdateGoalUseCase>.value(value: updateGoalUseCase),
        Provider<DeleteGoalUseCase>.value(value: deleteGoalUseCase),
        Provider<GetGoalsUseCase>.value(value: getGoalsUseCase),
        Provider<GetGoalByIdUseCase>.value(value: getGoalByIdUseCase),
        Provider<WatchGoalsUseCase>.value(value: watchGoalsUseCase),
        Provider<UpdateGoalStatusUseCase>.value(value: updateGoalStatusUseCase),

        // Use cases - Task
        Provider<CreateTaskUseCase>.value(value: createTaskUseCase),
        Provider<UpdateTaskUseCase>.value(value: updateTaskUseCase),
        Provider<DeleteTaskUseCase>.value(value: deleteTaskUseCase),
        Provider<ToggleTaskUseCase>.value(value: toggleTaskUseCase),
        Provider<GetTasksByGoalUseCase>.value(value: getTasksByGoalUseCase),
        Provider<WatchTasksByGoalUseCase>.value(value: watchTasksByGoalUseCase),

        // Providers (State Management)
        ChangeNotifierProvider<AppAuthProvider>(
          create: (_) => AppAuthProvider(
            loginUseCase: loginUseCase,
            registerUseCase: registerUseCase,
            logoutUseCase: logoutUseCase,
            authRepository: authRepository,
          ),
        ),

        ChangeNotifierProvider<TransactionProvider>(
          create: (_) => TransactionProvider(
            createTransactionUseCase: createTransactionUseCase,
            updateTransactionUseCase: updateTransactionUseCase,
            deleteTransactionUseCase: deleteTransactionUseCase,
            getTransactionsUseCase: getTransactionsUseCase,
            watchTransactionsUseCase: watchTransactionsUseCase,
          ),
        ),

        ChangeNotifierProvider<GoalProvider>(
          create: (_) => GoalProvider(
            createGoalUseCase: createGoalUseCase,
            updateGoalUseCase: updateGoalUseCase,
            deleteGoalUseCase: deleteGoalUseCase,
            getGoalsUseCase: getGoalsUseCase,
            getGoalByIdUseCase: getGoalByIdUseCase,
            watchGoalsUseCase: watchGoalsUseCase,
            updateGoalStatusUseCase: updateGoalStatusUseCase,
            goalRemoteDataSource: goalDataSource,
            taskRemoteDataSource: taskDataSource,
          ),
        ),

        ChangeNotifierProvider<TaskProvider>(
          create: (_) => TaskProvider(
            createTaskUseCase: createTaskUseCase,
            updateTaskUseCase: updateTaskUseCase,
            deleteTaskUseCase: deleteTaskUseCase,
            toggleTaskUseCase: toggleTaskUseCase,
            getTasksByGoalUseCase: getTasksByGoalUseCase,
            watchTasksByGoalUseCase: watchTasksByGoalUseCase,
            taskRepository: taskRepository,
          ),
        ),

        ChangeNotifierProvider<DashboardProvider>(
          create: (_) => DashboardProvider(),
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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      locale: const Locale('pt', 'BR'),
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
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        AppConstants.loginRoute: (context) => const LoginScreen(),
        AppConstants.registerRoute: (context) => const RegisterScreen(),
        AppConstants.forgotPasswordRoute: (context) =>
            const ForgotPasswordScreen(),
        AppConstants.homeRoute: (context) => const HomeScreen(),
        '/transactions': (context) => const TransactionsScreen(),
        '/add-transaction': (context) => const AddTransactionScreen(),
        '/goals': (context) => const GoalsScreen(),
        AppConstants.dashboardRoute: (context) => const DashboardScreen(),
        AppConstants.importTransactionsRoute: (context) =>
            const ImportTransactionsScreen(),
      },
    );
  }
}

/// Auth wrapper to handle authentication state
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppAuthProvider>(
      builder: (context, authProvider, _) {
        // Show loading while checking auth state
        if (authProvider.status == AuthStatus.initial ||
            authProvider.status == AuthStatus.authenticating) {
          return Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1a1a2e),
                    Color(0xFF16213e),
                    Color(0xFF0f3460),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          );
        }

        // Navigate based on auth status
        if (authProvider.status == AuthStatus.authenticated &&
            authProvider.user != null) {
          // Use post frame callback to navigate after build is complete
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (ModalRoute.of(context)?.settings.name != AppConstants.homeRoute) {
              Navigator.of(context).pushReplacementNamed(AppConstants.homeRoute);
            }
          });
          // Show loading while navigating
          return Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1a1a2e),
                    Color(0xFF16213e),
                    Color(0xFF0f3460),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          );
        }

        // Default to login screen
        return const LoginScreen();
      },
    );
  }
}
