# Configuração do main.dart para Integração de IA

Este documento fornece as instruções completas para adicionar a injeção de dependências necessária para o assistente de IA no arquivo `main.dart`.

## 1. Adicionar Imports

Adicione os seguintes imports no início do arquivo `main.dart`:

```dart
// Depois dos imports existentes, adicione:

// Dio para requisições HTTP
import 'package:dio/dio.dart';

// Flutter Secure Storage
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// AI - Domain
import 'domain/usecases/ai/send_message_usecase.dart';
import 'domain/usecases/ai/generate_insights_usecase.dart';
import 'domain/usecases/ai/manage_api_key_usecase.dart';
import 'domain/usecases/ai/analyze_spending_usecase.dart';
import 'domain/usecases/ai/get_goal_recommendations_usecase.dart';

// AI - Data
import 'data/datasources/ai_remote_datasource.dart';
import 'data/datasources/ai_firestore_datasource.dart';
import 'data/repositories/ai_repository_impl.dart';

// AI - Core Services
import 'core/services/secure_storage_service.dart';

// AI - Presentation
import 'presentation/providers/ai_assistant_provider.dart';
```

## 2. Criar Instâncias dos Serviços

Adicione no método `main()`, após a inicialização do Firebase e antes de `runApp()`:

```dart
void main() async {
  // ... código existente de inicialização ...

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Firebase instances (código existente)
  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  // ====== NOVOS SERVIÇOS PARA IA ======

  // 1. Dio para requisições HTTP às APIs de IA
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ),
  );

  // 2. Flutter Secure Storage para armazenamento de API keys
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // 3. Secure Storage Service (wrapper)
  final secureStorageService = SecureStorageService(secureStorage);

  // 4. AI Firestore Data Source
  final aiFirestoreDataSource = AIFirestoreDataSource(firestore);

  // ====== REPOSITÓRIOS EXISTENTES (necessários para IA) ======
  // Certifique-se de que estes já existem no seu código:

  // Auth Data Source & Repository
  final authDataSource = AuthRemoteDataSource(firebaseAuth, firestore);
  final authRepository = AuthRepositoryImpl(authDataSource);

  // Transaction Data Source & Repository
  final transactionDataSource = TransactionRemoteDataSource(firestore);
  final transactionRepository = TransactionRepositoryImpl(transactionDataSource);

  // Goal Data Source & Repository
  final goalDataSource = GoalRemoteDataSource(firestore);
  final goalRepository = GoalRepositoryImpl(goalDataSource);

  // Task Data Source & Repository
  final taskDataSource = TaskRemoteDataSource(firestore);
  final taskRepository = TaskRepositoryImpl(taskDataSource);

  // ====== AI REPOSITORY ======

  // 5. AI Repository (integra todos os serviços)
  final aiRepository = AIRepositoryImpl(
    secureStorage: secureStorageService,
    firestoreDataSource: aiFirestoreDataSource,
    transactionRepository: transactionRepository,
    goalRepository: goalRepository,
    dio: dio,
  );

  // ====== AI USE CASES ======

  // 6. AI Use Cases
  final sendMessageUseCase = SendMessageUseCase(aiRepository);
  final generateInsightsUseCase = GenerateInsightsUseCase(aiRepository);
  final manageApiKeyUseCase = ManageApiKeyUseCase(aiRepository);
  final analyzeSpendingUseCase = AnalyzeSpendingUseCase(aiRepository);
  final getGoalRecommendationsUseCase = GetGoalRecommendationsUseCase(aiRepository);

  // ... resto do código existente (Auth, Transaction, Goal, Task use cases) ...

  // Continua com runApp()...
}
```

## 3. Adicionar Provider no MultiProvider

Localize o `MultiProvider` no método `runApp()` e adicione o `AIAssistantProvider`:

```dart
runApp(
  MultiProvider(
    providers: [
      // ====== PROVIDERS EXISTENTES ======

      // Auth Provider
      ChangeNotifierProvider(
        create: (_) => AppAuthProvider(
          loginUseCase: loginUseCase,
          registerUseCase: registerUseCase,
          logoutUseCase: logoutUseCase,
          authRepository: authRepository,
        ),
      ),

      // Transaction Provider
      ChangeNotifierProvider(
        create: (_) => TransactionProvider(
          createTransactionUseCase: createTransactionUseCase,
          updateTransactionUseCase: updateTransactionUseCase,
          deleteTransactionUseCase: deleteTransactionUseCase,
          getTransactionsUseCase: getTransactionsUseCase,
          watchTransactionsUseCase: watchTransactionsUseCase,
          transactionRepository: transactionRepository,
        ),
      ),

      // Goal Provider
      ChangeNotifierProvider(
        create: (_) => GoalProvider(
          createGoalUseCase: createGoalUseCase,
          updateGoalUseCase: updateGoalUseCase,
          deleteGoalUseCase: deleteGoalUseCase,
          getGoalsUseCase: getGoalsUseCase,
          getGoalByIdUseCase: getGoalByIdUseCase,
          watchGoalsUseCase: watchGoalsUseCase,
          updateGoalStatusUseCase: updateGoalStatusUseCase,
        ),
      ),

      // Task Provider
      ChangeNotifierProvider(
        create: (_) => TaskProvider(
          createTaskUseCase: createTaskUseCase,
          updateTaskUseCase: updateTaskUseCase,
          deleteTaskUseCase: deleteTaskUseCase,
          toggleTaskUseCase: toggleTaskUseCase,
          getTasksByGoalUseCase: getTasksByGoalUseCase,
          watchTasksByGoalUseCase: watchTasksByGoalUseCase,
        ),
      ),

      // Dashboard Provider
      ChangeNotifierProvider(
        create: (_) => DashboardProvider(
          transactionRepository: transactionRepository,
          goalRepository: goalRepository,
        ),
      ),

      // Goals Screen Provider
      ChangeNotifierProvider(
        create: (_) => GoalsScreenProvider(
          goalRepository: goalRepository,
        ),
      ),

      // Home Screen Provider
      ChangeNotifierProvider(
        create: (_) => HomeScreenProvider(
          watchGoalsUseCase: watchGoalsUseCase,
        ),
      ),

      // Widget Data Provider
      ChangeNotifierProvider(
        create: (_) => WidgetDataProvider(
          transactionRepository: transactionRepository,
          goalRepository: goalRepository,
        ),
      ),

      // ====== NOVO: AI ASSISTANT PROVIDER ======

      ChangeNotifierProvider(
        create: (_) => AIAssistantProvider(
          sendMessageUseCase: sendMessageUseCase,
          generateInsightsUseCase: generateInsightsUseCase,
          manageApiKeyUseCase: manageApiKeyUseCase,
          analyzeSpendingUseCase: analyzeSpendingUseCase,
          getGoalRecommendationsUseCase: getGoalRecommendationsUseCase,
          aiRepository: aiRepository,
        ),
      ),
    ],
    child: const MyApp(),
  ),
);
```

## 4. Código Completo da Função main()

Aqui está um exemplo completo de como a função `main()` deve ficar:

```dart
void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Load environment configuration
  await EnvConfig.initialize();

  // Validate environment configuration
  if (!EnvConfig.validateConfig()) {
    debugPrint('ERROR: Invalid environment configuration');
    return;
  }

  // Log configuration (debug only)
  EnvConfig.logConfiguration();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize date formatting for Portuguese
  await initializeDateFormatting('pt_BR', null);
  Intl.defaultLocale = 'pt_BR';

  // ====== FIREBASE INSTANCES ======
  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  // ====== HTTP & STORAGE ======
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ),
  );

  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  final secureStorageService = SecureStorageService(secureStorage);

  // ====== DATA SOURCES ======
  final authDataSource = AuthRemoteDataSource(firebaseAuth, firestore);
  final transactionDataSource = TransactionRemoteDataSource(firestore);
  final goalDataSource = GoalRemoteDataSource(firestore);
  final taskDataSource = TaskRemoteDataSource(firestore);
  final aiFirestoreDataSource = AIFirestoreDataSource(firestore);

  // ====== REPOSITORIES ======
  final authRepository = AuthRepositoryImpl(authDataSource);
  final transactionRepository = TransactionRepositoryImpl(transactionDataSource);
  final goalRepository = GoalRepositoryImpl(goalDataSource);
  final taskRepository = TaskRepositoryImpl(taskDataSource);
  final aiRepository = AIRepositoryImpl(
    secureStorage: secureStorageService,
    firestoreDataSource: aiFirestoreDataSource,
    transactionRepository: transactionRepository,
    goalRepository: goalRepository,
    dio: dio,
  );

  // ====== AUTH USE CASES ======
  final loginUseCase = LoginUseCase(authRepository);
  final registerUseCase = RegisterUseCase(authRepository);
  final logoutUseCase = LogoutUseCase(authRepository);

  // ====== TRANSACTION USE CASES ======
  final createTransactionUseCase = CreateTransactionUseCase(transactionRepository);
  final updateTransactionUseCase = UpdateTransactionUseCase(transactionRepository);
  final deleteTransactionUseCase = DeleteTransactionUseCase(transactionRepository);
  final getTransactionsUseCase = GetTransactionsUseCase(transactionRepository);
  final watchTransactionsUseCase = WatchTransactionsUseCase(transactionRepository);

  // ====== GOAL USE CASES ======
  final createGoalUseCase = CreateGoalUseCase(goalRepository);
  final updateGoalUseCase = UpdateGoalUseCase(goalRepository);
  final deleteGoalUseCase = DeleteGoalUseCase(goalRepository);
  final getGoalsUseCase = GetGoalsUseCase(goalRepository);
  final getGoalByIdUseCase = GetGoalByIdUseCase(goalRepository);
  final watchGoalsUseCase = WatchGoalsUseCase(goalRepository);
  final updateGoalStatusUseCase = UpdateGoalStatusUseCase(goalRepository);

  // ====== TASK USE CASES ======
  final createTaskUseCase = CreateTaskUseCase(taskRepository);
  final updateTaskUseCase = UpdateTaskUseCase(taskRepository);
  final deleteTaskUseCase = DeleteTaskUseCase(taskRepository);
  final toggleTaskUseCase = ToggleTaskUseCase(taskRepository);
  final getTasksByGoalUseCase = GetTasksByGoalUseCase(taskRepository);
  final watchTasksByGoalUseCase = WatchTasksByGoalUseCase(taskRepository);

  // ====== AI USE CASES ======
  final sendMessageUseCase = SendMessageUseCase(aiRepository);
  final generateInsightsUseCase = GenerateInsightsUseCase(aiRepository);
  final manageApiKeyUseCase = ManageApiKeyUseCase(aiRepository);
  final analyzeSpendingUseCase = AnalyzeSpendingUseCase(aiRepository);
  final getGoalRecommendationsUseCase = GetGoalRecommendationsUseCase(aiRepository);

  // ====== RUN APP ======
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppAuthProvider(
            loginUseCase: loginUseCase,
            registerUseCase: registerUseCase,
            logoutUseCase: logoutUseCase,
            authRepository: authRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => TransactionProvider(
            createTransactionUseCase: createTransactionUseCase,
            updateTransactionUseCase: updateTransactionUseCase,
            deleteTransactionUseCase: deleteTransactionUseCase,
            getTransactionsUseCase: getTransactionsUseCase,
            watchTransactionsUseCase: watchTransactionsUseCase,
            transactionRepository: transactionRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => GoalProvider(
            createGoalUseCase: createGoalUseCase,
            updateGoalUseCase: updateGoalUseCase,
            deleteGoalUseCase: deleteGoalUseCase,
            getGoalsUseCase: getGoalsUseCase,
            getGoalByIdUseCase: getGoalByIdUseCase,
            watchGoalsUseCase: watchGoalsUseCase,
            updateGoalStatusUseCase: updateGoalStatusUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskProvider(
            createTaskUseCase: createTaskUseCase,
            updateTaskUseCase: updateTaskUseCase,
            deleteTaskUseCase: deleteTaskUseCase,
            toggleTaskUseCase: toggleTaskUseCase,
            getTasksByGoalUseCase: getTasksByGoalUseCase,
            watchTasksByGoalUseCase: watchTasksByGoalUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(
            transactionRepository: transactionRepository,
            goalRepository: goalRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => GoalsScreenProvider(
            goalRepository: goalRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeScreenProvider(
            watchGoalsUseCase: watchGoalsUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => WidgetDataProvider(
            transactionRepository: transactionRepository,
            goalRepository: goalRepository,
          ),
        ),
        // AI Assistant Provider
        ChangeNotifierProvider(
          create: (_) => AIAssistantProvider(
            sendMessageUseCase: sendMessageUseCase,
            generateInsightsUseCase: generateInsightsUseCase,
            manageApiKeyUseCase: manageApiKeyUseCase,
            analyzeSpendingUseCase: analyzeSpendingUseCase,
            getGoalRecommendationsUseCase: getGoalRecommendationsUseCase,
            aiRepository: aiRepository,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
```

## 5. Verificação

Após fazer as alterações:

### 5.1 Instalar dependências:
```bash
cd app
flutter pub get
```

### 5.2 Verificar compilação:
```bash
flutter analyze
```

### 5.3 Executar o app:
```bash
flutter run
```

## 6. Troubleshooting

### Erro: "The getter 'user' isn't defined for the type 'AuthProvider'"
- Certifique-se de usar `AppAuthProvider` e não `AuthProvider`
- Use `FirebaseAuth.instance.currentUser?.uid` nas telas de IA

### Erro: Import não encontrado
- Verifique se todos os arquivos foram criados corretamente
- Execute `flutter pub get`
- Reinicie o IDE

### Erro: Provider não encontrado
- Certifique-se de que o `AIAssistantProvider` está no `MultiProvider`
- Verifique se está usando `context.read<AIAssistantProvider>()`

### Erro de compilação no Dio
- Versão mínima do Dart: 3.9.2
- Atualize se necessário: `flutter upgrade`

## 7. Próximos Passos

Após configurar o main.dart:

1. Execute o app: `flutter run`
2. Navegue para Configurações de IA
3. Configure uma API key (Gemini ou Claude)
4. Teste o chat e a geração de insights
5. Integre no home screen seguindo [AI_HOME_INTEGRATION.md](AI_HOME_INTEGRATION.md)

---

**Nota Importante**: Certifique-se de que todas as dependências estão no `pubspec.yaml` antes de executar. Veja [AI_INTEGRATION.md](AI_INTEGRATION.md) para a lista completa.
