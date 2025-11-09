import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/ai_message_entity.dart';
import '../../domain/entities/ai_conversation_entity.dart';
import '../../domain/entities/ai_insight_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/ai_repository.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/repositories/goal_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../../core/services/secure_storage_service.dart';
import '../datasources/ai_remote_datasource.dart';
import '../datasources/ai_firestore_datasource.dart';
import '../models/ai_insight_model.dart';
import 'package:dio/dio.dart';

/// Implementation of AI repository
class AIRepositoryImpl implements AIRepository {
  final SecureStorageService _secureStorage;
  final AIFirestoreDataSource _firestoreDataSource;
  final TransactionRepository _transactionRepository;
  final GoalRepository _goalRepository;
  final Dio _dio;
  final Uuid _uuid = const Uuid();

  AIRepositoryImpl({
    required SecureStorageService secureStorage,
    required AIFirestoreDataSource firestoreDataSource,
    required TransactionRepository transactionRepository,
    required GoalRepository goalRepository,
    required Dio dio,
  })  : _secureStorage = secureStorage,
        _firestoreDataSource = firestoreDataSource,
        _transactionRepository = transactionRepository,
        _goalRepository = goalRepository,
        _dio = dio;

  @override
  Future<Either<Failure, AIMessageEntity>> sendMessage({
    required String userId,
    required String message,
    required AIProvider provider,
    required List<AIMessageEntity> conversationHistory,
    Map<String, dynamic>? context,
  }) async {
    try {
      // Get API key
      final apiKey = await _secureStorage.getApiKey(provider);
      if (apiKey == null || apiKey.isEmpty) {
        return Left(
          AuthFailure(
            message: 'API key not configured for ${provider.displayName}',
            code: 'NO_API_KEY',
          ),
        );
      }

      // Get remote data source for provider
      final dataSource = _getDataSource(provider, apiKey);

      // Add financial context if not provided
      final enrichedContext = context ?? await _buildFinancialContext(userId);

      // Send message
      final response = await dataSource.sendMessage(
        message: message,
        conversationHistory: conversationHistory,
        context: enrichedContext,
      );

      return Right(response);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code, details: e.details));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code, details: e.details));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code, details: e.details));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(message: e.message, code: e.code, details: e.details));
    } catch (e) {
      return Left(
        UnknownFailure(message: 'Unexpected error: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<AIInsightEntity>>> generateInsights({
    required String userId,
    required AIProvider provider,
    Map<String, dynamic>? filters,
  }) async {
    try {
      // Get API key
      final apiKey = await _secureStorage.getApiKey(provider);
      if (apiKey == null || apiKey.isEmpty) {
        return Left(
          AuthFailure(
            message: 'API key not configured for ${provider.displayName}',
            code: 'NO_API_KEY',
          ),
        );
      }

      // Get financial data
      final context = await _buildFinancialContext(userId);

      // Build insights prompt
      final prompt = _buildInsightsPrompt(context);

      // Get data source and send request
      final dataSource = _getDataSource(provider, apiKey);
      final response = await dataSource.sendMessage(
        message: prompt,
        conversationHistory: [],
        context: context,
      );

      // Parse response into insights
      final insights = _parseInsights(userId, response.content);

      // Save insights to Firestore
      for (final insight in insights) {
        final model = AIInsightModel.fromEntity(insight);
        await _firestoreDataSource.saveInsight(
          userId: userId,
          insight: model,
        );
      }

      return Right(insights);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code, details: e.details));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code, details: e.details));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code, details: e.details));
    } on TypeError catch (e, stackTrace) {
      return Left(
        UnknownFailure(message: 'Type error: $e\n$stackTrace'),
      );
    } catch (e, stackTrace) {
      return Left(
        UnknownFailure(message: 'Error generating insights: $e\n$stackTrace'),
      );
    }
  }

  @override
  Future<Either<Failure, String>> analyzeSpending({
    required String userId,
    required AIProvider provider,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Get API key
      final apiKey = await _secureStorage.getApiKey(provider);
      if (apiKey == null || apiKey.isEmpty) {
        return Left(
          AuthFailure(
            message: 'API key not configured for ${provider.displayName}',
            code: 'NO_API_KEY',
          ),
        );
      }

      // Get transactions in date range
      final transactionsResult = await _transactionRepository.getTransactions(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      if (transactionsResult.isLeft()) {
        return Left(
          ServerFailure(message: 'Failed to get transactions'),
        );
      }

      final transactions = transactionsResult.getOrElse(() => []);

      // Build analysis context
      final context = {
        'transactions': transactions
            .map((t) => {
                  'amount': t.amount,
                  'type': t.type.displayName,
                  'category': t.category.displayName,
                  'description': t.description,
                  'date': t.date.toIso8601String(),
                  'isIncome': t.isIncome,
                  'isExpense': t.isExpense,
                })
            .toList(),
        'transactionCount': transactions.length,
        'totalTransactions': transactions.length,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
      };

      // Build prompt
      final prompt = '''
Analise os dados financeiros fornecidos e crie uma análise detalhada e personalizada.

Total de transações disponíveis: ${transactions.length}

Instruções:
1. Analise os padrões de gastos por categoria (use os dados das transações)
2. Identifique as maiores despesas e suas categorias
3. Calcule totais por categoria
4. Identifique tendências e padrões de consumo
5. Forneça recomendações específicas para economia baseadas nos dados reais
6. Alerte sobre gastos incomuns ou excessivos

IMPORTANTE:
- Use APENAS os dados das transações fornecidas no contexto
- Forneça números e valores específicos em Reais (R\$)
- Seja detalhado e objetivo
- Organize a resposta de forma clara com títulos e subtítulos
${transactions.isEmpty ? '\nATENÇÃO: Não há transações registradas no período selecionado. Informe ao usuário que precisa registrar transações primeiro.' : ''}
''';

      // Send request
      final dataSource = _getDataSource(provider, apiKey);
      final response = await dataSource.sendMessage(
        message: prompt,
        conversationHistory: [],
        context: context,
      );

      return Right(response.content);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code, details: e.details));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code, details: e.details));
    } catch (e) {
      return Left(
        UnknownFailure(message: 'Error analyzing spending: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, String>> getGoalRecommendations({
    required String userId,
    required String goalId,
    required AIProvider provider,
  }) async {
    try {
      // Get API key
      final apiKey = await _secureStorage.getApiKey(provider);
      if (apiKey == null || apiKey.isEmpty) {
        return Left(
          AuthFailure(
            message: 'API key not configured for ${provider.displayName}',
            code: 'NO_API_KEY',
          ),
        );
      }

      // Get goal
      final goalResult = await _goalRepository.getGoalById(goalId, userId);
      if (goalResult.isLeft()) {
        return Left(
          ServerFailure(message: 'Failed to get goal'),
        );
      }

      final goal = goalResult.getOrElse(() => throw Exception('Goal not found'));

      // Build context
      final context = {
        'goal': {
          'title': goal.title,
          'targetAmount': goal.targetAmount,
          'currentAmount': goal.currentAmount,
          'progress': goal.progressPercentage,
          'remainingAmount': goal.remainingAmount,
          'daysRemaining': goal.daysRemaining,
          'requiredDailySavings': goal.requiredDailySavings,
          'isOnTrack': goal.isOnTrack,
        },
      };

      // Build prompt
      final prompt = '''
Com base na meta financeira abaixo, forneça recomendações personalizadas para ajudar o usuário a alcançá-la:

Meta: ${goal.title}
Valor Alvo: R\$ ${goal.targetAmount}
Valor Atual: R\$ ${goal.currentAmount}
Progresso: ${goal.progressPercentage.toStringAsFixed(1)}%
Faltam: R\$ ${goal.remainingAmount}
Dias Restantes: ${goal.daysRemaining ?? 'N/A'}

Forneça:
1. Avaliação da viabilidade da meta
2. Estratégias específicas para economizar
3. Plano de ação com prazos
4. Dicas para manter a motivação
5. Alertas sobre possíveis desafios
''';

      // Send request
      final dataSource = _getDataSource(provider, apiKey);
      final response = await dataSource.sendMessage(
        message: prompt,
        conversationHistory: [],
        context: context,
      );

      return Right(response.content);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code, details: e.details));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code, details: e.details));
    } catch (e) {
      return Left(
        UnknownFailure(message: 'Error getting recommendations: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, String>> askQuestion({
    required String userId,
    required String question,
    required AIProvider provider,
    Map<String, dynamic>? context,
  }) async {
    try {
      // Get API key
      final apiKey = await _secureStorage.getApiKey(provider);
      if (apiKey == null || apiKey.isEmpty) {
        return Left(
          AuthFailure(
            message: 'API key not configured for ${provider.displayName}',
            code: 'NO_API_KEY',
          ),
        );
      }

      // Build context
      final enrichedContext = context ?? await _buildFinancialContext(userId);

      // Send request
      final dataSource = _getDataSource(provider, apiKey);
      final response = await dataSource.sendMessage(
        message: question,
        conversationHistory: [],
        context: enrichedContext,
      );

      return Right(response.content);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code, details: e.details));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code, details: e.details));
    } catch (e) {
      return Left(
        UnknownFailure(message: 'Error asking question: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, AIConversationEntity>> createConversation({
    required String userId,
    required AIProvider provider,
    String? title,
  }) async {
    try {
      final conversationId = _uuid.v4();
      final now = DateTime.now();

      final metadata = {
        'userId': userId,
        'title': title ?? 'Nova Conversa',
        'provider': provider.name,
        'createdAt': now,
        'updatedAt': now,
      };

      await _firestoreDataSource.createConversation(
        userId: userId,
        conversationId: conversationId,
        metadata: metadata,
      );

      final conversation = AIConversationEntity(
        id: conversationId,
        userId: userId,
        title: title ?? 'Nova Conversa',
        messages: [],
        provider: provider,
        createdAt: now,
        updatedAt: now,
      );

      return Right(conversation);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code, details: e.details));
    } catch (e) {
      return Left(
        UnknownFailure(message: 'Error creating conversation: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<AIConversationEntity>>> getConversations({
    required String userId,
    int? limit,
  }) async {
    try {
      final conversationsData = await _firestoreDataSource.getConversations(
        userId: userId,
        limit: limit,
      );

      final conversations = <AIConversationEntity>[];

      for (final data in conversationsData) {
        final messages = await _firestoreDataSource.getMessages(
          userId: userId,
          conversationId: data['id'] as String,
        );

        conversations.add(
          AIConversationEntity(
            id: data['id'] as String,
            userId: data['userId'] as String,
            title: data['title'] as String,
            messages: messages,
            provider: AIProvider.values.firstWhere(
              (e) => e.name == data['provider'],
            ),
            createdAt: (data['createdAt'] as dynamic).toDate(),
            updatedAt: (data['updatedAt'] as dynamic).toDate(),
            metadata: data['metadata'] as Map<String, dynamic>?,
          ),
        );
      }

      return Right(conversations);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code, details: e.details));
    } catch (e) {
      return Left(
        UnknownFailure(message: 'Error getting conversations: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, AIConversationEntity>> getConversationById({
    required String conversationId,
  }) async {
    // Implementation needed - requires userId extraction from conversation
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, AIConversationEntity>> updateConversation({
    required AIConversationEntity conversation,
  }) async {
    try {
      await _firestoreDataSource.updateConversation(
        userId: conversation.userId,
        conversationId: conversation.id,
        updates: {
          'title': conversation.title,
          'updatedAt': DateTime.now(),
        },
      );

      return Right(conversation);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code, details: e.details));
    } catch (e) {
      return Left(
        UnknownFailure(message: 'Error updating conversation: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteConversation({
    required String conversationId,
  }) async {
    // Implementation needed - requires userId
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<AIInsightEntity>>> getInsights({
    required String userId,
    int? limit,
    bool? includeRead,
    bool? includeDismissed,
  }) async {
    try {
      final insights = await _firestoreDataSource.getInsights(
        userId: userId,
        limit: limit,
        includeRead: includeRead,
        includeDismissed: includeDismissed,
      );

      return Right(insights);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code, details: e.details));
    } catch (e) {
      return Left(
        UnknownFailure(message: 'Error getting insights: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> markInsightAsRead({
    required String insightId,
  }) async {
    // Implementation needed - requires userId
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> dismissInsight({
    required String insightId,
  }) async {
    // Implementation needed - requires userId
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> isApiKeyConfigured({
    required AIProvider provider,
  }) async {
    try {
      final hasKey = await _secureStorage.hasApiKey(provider);
      return Right(hasKey);
    } catch (e) {
      return Left(
        UnknownFailure(message: 'Error checking API key: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> setApiKey({
    required AIProvider provider,
    required String apiKey,
  }) async {
    try {
      await _secureStorage.setApiKey(provider, apiKey);
      return const Right(null);
    } catch (e) {
      return Left(
        UnknownFailure(message: 'Error setting API key: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> removeApiKey({
    required AIProvider provider,
  }) async {
    try {
      await _secureStorage.removeApiKey(provider);
      return const Right(null);
    } catch (e) {
      return Left(
        UnknownFailure(message: 'Error removing API key: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> testConnection({
    required AIProvider provider,
  }) async {
    try {
      final apiKey = await _secureStorage.getApiKey(provider);
      if (apiKey == null || apiKey.isEmpty) {
        return const Right(false);
      }

      final dataSource = _getDataSource(provider, apiKey);
      final isConnected = await dataSource.testConnection();

      return Right(isConnected);
    } catch (e) {
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, List<String>>> listAvailableModels({
    required AIProvider provider,
  }) async {
    try {
      final apiKey = await _secureStorage.getApiKey(provider);
      if (apiKey == null || apiKey.isEmpty) {
        return Left(
          AuthFailure(
            message: 'API key not configured for ${provider.displayName}',
            code: 'NO_API_KEY',
          ),
        );
      }

      final dataSource = _getDataSource(provider, apiKey);
      final models = await dataSource.listAvailableModels();

      return Right(models);
    } catch (e) {
      return Left(
        UnknownFailure(message: 'Error listing models: $e'),
      );
    }
  }

  // Private helper methods

  /// Get appropriate data source for provider
  AIRemoteDataSource _getDataSource(AIProvider provider, String apiKey) {
    switch (provider) {
      case AIProvider.gemini:
        return GeminiRemoteDataSource(dio: _dio, apiKey: apiKey);
      case AIProvider.claude:
        return ClaudeRemoteDataSource(dio: _dio, apiKey: apiKey);
    }
  }

  /// Build financial context from user data with structured format
  Future<Map<String, dynamic>> _buildFinancialContext(String userId) async {
    final context = <String, dynamic>{};
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    // Get balance
    final balance = await _transactionRepository.getBalance(userId: userId);
    final totalIncome = await _transactionRepository.getTotalIncome(userId: userId);
    final totalExpenses = await _transactionRepository.getTotalExpenses(userId: userId);

    // Summary section
    final summary = <String, dynamic>{
      'totalIncome': totalIncome.getOrElse(() => 0.0),
      'totalExpenses': totalExpenses.getOrElse(() => 0.0),
      'balance': balance.getOrElse(() => 0.0),
      'period': {
        'start': thirtyDaysAgo.toIso8601String(),
        'end': now.toIso8601String(),
      },
    };

    // Get all transactions
    final transactionsResult = await _transactionRepository.getTransactions(userId: userId);
    final transactions = transactionsResult.getOrElse(() => []);

    summary['transactionCount'] = transactions.length;

    // Calculate averages if we have transactions
    if (transactions.isNotEmpty) {
      final totalExpense = totalExpenses.getOrElse(() => 0.0);
      summary['averages'] = {
        'dailyExpense': totalExpense / 30,
        'weeklyExpense': totalExpense / 4.3,
        'monthlyExpense': totalExpense,
      };
    }

    context['summary'] = summary;

    // Full transactions list with all details (limited to prevent context overflow)
    if (transactions.isNotEmpty) {
      // Limit to 30 most recent transactions to prevent API context overflow
      final limitedTransactions = transactions.take(30).toList();

      context['transactions'] = limitedTransactions
          .map((t) => {
                'id': t.id,
                'amount': t.amount,
                'type': t.type.displayName,
                'category': t.category.displayName,
                'description': t.description,
                'date': t.date.toIso8601String(),
                'isIncome': t.isIncome,
                'isExpense': t.isExpense,
              })
          .toList();

      // Category breakdown for expenses
      final Map<String, double> categoryTotals = {};
      for (final transaction in transactions) {
        if (transaction.isExpense) {
          final categoryName = transaction.category.displayName;
          categoryTotals[categoryName] =
              (categoryTotals[categoryName] ?? 0.0) + transaction.amount;
        }
      }

      context['categoryBreakdown'] = categoryTotals;

      // Top expense categories
      final sortedCategories = categoryTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      if (sortedCategories.isNotEmpty) {
        context['topExpenseCategories'] = sortedCategories
            .take(5)
            .map((e) => {
                  'name': e.key,
                  'amount': e.value,
                  'percentage': (e.value / totalExpenses.getOrElse(() => 1.0)) * 100,
                })
            .toList();
      }
    }

    // Get goals with complete information
    final goalsResult = await _goalRepository.getGoals(userId);
    if (goalsResult.isRight()) {
      final goals = goalsResult.getOrElse(() => []);
      if (goals.isNotEmpty) {
        context['goals'] = goals
            .map((g) => {
                  'id': g.id,
                  'title': g.title,
                  'description': g.description,
                  'targetAmount': g.targetAmount,
                  'currentAmount': g.currentAmount,
                  'progress': g.progressPercentage,
                  'remainingAmount': g.remainingAmount,
                  'targetDate': g.targetDate.toIso8601String(),
                  'daysRemaining': g.daysRemaining,
                  'requiredDailySavings': g.requiredDailySavings,
                  'isOnTrack': g.isOnTrack,
                  'status': g.status.name,
                  'colorIndex': g.colorIndex,
                })
            .toList();
      }
    }

    return context;
  }

  /// Build prompt for insights generation with JSON schema
  String _buildInsightsPrompt(Map<String, dynamic> context) {
    final summary = context['summary'] as Map<String, dynamic>? ?? {};
    final transactionCount = summary['transactionCount'] as int? ?? 0;
    final hasTransactions = transactionCount > 0;
    final goals = context['goals'] as List<dynamic>? ?? [];
    final hasGoals = goals.isNotEmpty;

    // Build a concise summary instead of full JSON to reduce token usage
    final summaryText = _buildContextSummary(context);

    return '''
Você é um assistente financeiro expert. Analise os dados e retorne insights em formato JSON.

## DADOS FINANCEIROS:
$summaryText

## INSTRUÇÕES:
1. Analise padrões de gastos por categoria e identifique categorias com gastos acima da média
2. Compare progresso de metas vs prazo restante e calcule se está no caminho certo
3. Identifique oportunidades concretas de economia baseadas nos dados reais
4. Calcule economia necessária para atingir metas no prazo
5. Identifique gastos recorrentes que podem ser reduzidos

## FORMATO DE RESPOSTA (JSON OBRIGATÓRIO):
Retorne APENAS um objeto JSON válido seguindo EXATAMENTE este formato:

{
  "insights": [
    {
      "type": "spending",
      "priority": "high",
      "title": "Gastos com Alimentação 40% acima da média",
      "description": "Você gastou R\$ 1.200 em Alimentação este mês, 40% acima da sua média histórica de R\$ 857. Os principais gastos foram: restaurantes (R\$ 750) e delivery (R\$ 450).",
      "actionableAdvice": "Reduza pedidos de delivery para no máximo 2x por semana. Preparar refeições em casa pode economizar até R\$ 300/mês (R\$ 10/dia).",
      "data": {
        "category": "Alimentação",
        "currentAmount": 1200.00,
        "averageAmount": 857.00,
        "differencePercentage": 40.0,
        "potentialSavings": 300.00
      }
    }
  ]
}

## TIPOS DE INSIGHTS (use exatamente estes valores no campo "type"):
- "spending": Análise de gastos por categoria
- "saving": Oportunidades de economia
- "goal": Progresso e viabilidade de metas
- "recommendation": Recomendações financeiras gerais
- "warning": Alertas sobre problemas (gastos excessivos, meta fora do prazo)
- "achievement": Reconhecimento de progresso positivo

## PRIORIDADES (use exatamente estes valores no campo "priority"):
- "critical": Problemas urgentes (meta muito fora do prazo, gastos 50%+ acima)
- "high": Requer atenção (gastos 30%+ acima, meta levemente atrasada)
- "medium": Importante mas não urgente
- "low": Informativo

## REGRAS OBRIGATÓRIAS:
1. Retorne APENAS JSON válido, sem texto adicional antes ou depois
2. Gere entre 3 e 6 insights baseados nos dados disponíveis
3. Use valores reais dos dados fornecidos - NÃO invente números
4. Seja específico: cite categorias, valores e percentuais reais
5. Forneça conselhos acionáveis e mensuráveis (ex: "economize R\$ X por dia")
6. Use português do Brasil
7. Valores monetários em formato numérico (1234.56, não "R\$ 1.234,56")
8. Se não houver transações, crie apenas 1 insight do tipo "recommendation" orientando o usuário a registrar transações

${!hasTransactions ? '\n⚠️ ATENÇÃO: Não há transações registradas. Crie apenas 1 insight recomendando registrar transações.' : ''}
${hasGoals ? '\n✓ ${goals.length} meta(s) ativa(s) para analisar' : ''}
''';
  }

  /// Build concise context summary to reduce token usage
  String _buildContextSummary(Map<String, dynamic> context) {
    final buffer = StringBuffer();
    final summary = context['summary'] as Map<String, dynamic>? ?? {};
    final goals = context['goals'] as List<dynamic>? ?? [];
    final topCategories = context['topExpenseCategories'] as List<dynamic>? ?? [];
    final transactions = context['transactions'] as List<dynamic>? ?? [];

    // Financial summary
    buffer.writeln('Resumo Financeiro:');
    buffer.writeln('- Receita Total: R\$ ${summary['totalIncome'] ?? 0}');
    buffer.writeln('- Despesas Totais: R\$ ${summary['totalExpenses'] ?? 0}');
    buffer.writeln('- Saldo: R\$ ${summary['balance'] ?? 0}');
    buffer.writeln('- Total de Transações: ${summary['transactionCount'] ?? 0}');

    if (summary.containsKey('averages')) {
      final averages = summary['averages'] as Map<String, dynamic>;
      buffer.writeln('- Gasto Médio Diário: R\$ ${(averages['dailyExpense'] as num).toStringAsFixed(2)}');
    }

    // Top expense categories
    if (topCategories.isNotEmpty) {
      buffer.writeln('\nPrincipais Categorias de Gastos:');
      for (final cat in topCategories.take(5)) {
        if (cat is Map<String, dynamic>) {
          buffer.writeln('- ${cat['name']}: R\$ ${(cat['amount'] as num).toStringAsFixed(2)} (${(cat['percentage'] as num).toStringAsFixed(1)}%)');
        }
      }
    }

    // Goals
    if (goals.isNotEmpty) {
      buffer.writeln('\nMetas Financeiras:');
      for (final goal in goals) {
        if (goal is Map<String, dynamic>) {
          buffer.writeln('- ${goal['title']}: R\$ ${goal['currentAmount']} de R\$ ${goal['targetAmount']} (${(goal['progress'] as num).toStringAsFixed(1)}%)');
          buffer.writeln('  Faltam R\$ ${goal['remainingAmount']} em ${goal['daysRemaining']} dias - Economizar R\$ ${(goal['requiredDailySavings'] as num).toStringAsFixed(2)}/dia');
        }
      }
    }

    // Recent transactions sample (only 10)
    if (transactions.isNotEmpty) {
      buffer.writeln('\nÚltimas ${transactions.length > 10 ? 10 : transactions.length} Transações:');
      for (final tx in transactions.take(10)) {
        if (tx is Map<String, dynamic>) {
          final emoji = tx['isIncome'] == true ? '📈' : '📉';
          buffer.writeln('$emoji ${tx['category']}: R\$ ${tx['amount']} - ${tx['description']}');
        }
      }
    }

    return buffer.toString();
  }

  /// Parse AI response into structured insights from JSON
  List<AIInsightEntity> _parseInsights(String userId, String response) {
    try {
      // Try to extract JSON from response (AI might add text before/after)
      String jsonString = response.trim();

      // Remove markdown code blocks if present
      if (jsonString.startsWith('```json')) {
        jsonString = jsonString.substring(7);
      } else if (jsonString.startsWith('```')) {
        jsonString = jsonString.substring(3);
      }
      if (jsonString.endsWith('```')) {
        jsonString = jsonString.substring(0, jsonString.length - 3);
      }
      jsonString = jsonString.trim();

      // Try to find JSON object in the response
      final jsonMatch = RegExp(r'\{[\s\S]*"insights"[\s\S]*\}').firstMatch(jsonString);
      if (jsonMatch != null) {
        jsonString = jsonMatch.group(0)!;
      }

      // Parse JSON
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      if (!data.containsKey('insights') || data['insights'] is! List) {
        throw Exception('Invalid insights format - missing or invalid "insights" array');
      }

      final insightsList = data['insights'] as List<dynamic>;
      final insights = <AIInsightEntity>[];

      for (final item in insightsList) {
        if (item is! Map<String, dynamic>) continue;

        try {
          insights.add(
            AIInsightEntity(
              id: _uuid.v4(),
              userId: userId,
              type: _parseInsightType(item['type'] as String? ?? 'recommendation'),
              priority: _parseInsightPriority(item['priority'] as String? ?? 'medium'),
              title: item['title'] as String? ?? 'Insight Financeiro',
              description: item['description'] as String? ?? '',
              actionableAdvice: item['actionableAdvice'] as String?,
              data: item['data'] as Map<String, dynamic>?,
              generatedAt: DateTime.now(),
            ),
          );
        } catch (e) {
          // Skip invalid insights but continue processing
          continue;
        }
      }

      // If no valid insights were parsed, create a fallback
      if (insights.isEmpty) {
        return [_createFallbackInsight(userId, response)];
      }

      return insights;
    } catch (e) {
      // If JSON parsing fails completely, create a fallback insight
      return [_createFallbackInsight(userId, response)];
    }
  }

  /// Create fallback insight when JSON parsing fails
  AIInsightEntity _createFallbackInsight(String userId, String response) {
    return AIInsightEntity(
      id: _uuid.v4(),
      userId: userId,
      type: InsightType.recommendation,
      priority: InsightPriority.medium,
      title: 'Análise Financeira',
      description: response.length > 300
          ? '${response.substring(0, 300)}...'
          : response,
      actionableAdvice: response.length > 300
          ? response.substring(300, response.length > 600 ? 600 : response.length)
          : null,
      generatedAt: DateTime.now(),
    );
  }

  /// Parse insight type from string
  InsightType _parseInsightType(String value) {
    switch (value.toLowerCase()) {
      case 'spending':
        return InsightType.spending;
      case 'saving':
        return InsightType.saving;
      case 'goal':
        return InsightType.goal;
      case 'recommendation':
        return InsightType.recommendation;
      case 'warning':
        return InsightType.warning;
      case 'achievement':
        return InsightType.achievement;
      default:
        return InsightType.recommendation;
    }
  }

  /// Parse insight priority from string
  InsightPriority _parseInsightPriority(String value) {
    switch (value.toLowerCase()) {
      case 'critical':
        return InsightPriority.critical;
      case 'high':
        return InsightPriority.high;
      case 'medium':
        return InsightPriority.medium;
      case 'low':
        return InsightPriority.low;
      default:
        return InsightPriority.medium;
    }
  }
}
