import 'package:dio/dio.dart';
import '../../domain/entities/ai_message_entity.dart';
import '../../core/errors/exceptions.dart';
import '../models/ai_message_model.dart';

/// Remote data source for AI API interactions
abstract class AIRemoteDataSource {
  /// Send message to AI and get response
  Future<AIMessageModel> sendMessage({
    required String message,
    required List<AIMessageEntity> conversationHistory,
    Map<String, dynamic>? context,
  });

  /// Test API connection
  Future<bool> testConnection();

  /// List available models
  Future<List<String>> listAvailableModels();
}

/// Implementation for Google Gemini API
class GeminiRemoteDataSource implements AIRemoteDataSource {
  final Dio _dio;
  final String _apiKey;
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  GeminiRemoteDataSource({
    required Dio dio,
    required String apiKey,
  })  : _dio = dio,
        _apiKey = apiKey;

  @override
  Future<AIMessageModel> sendMessage({
    required String message,
    required List<AIMessageEntity> conversationHistory,
    Map<String, dynamic>? context,
  }) async {
    try {
      // Build conversation context
      final contents = _buildGeminiMessages(message, conversationHistory, context);

      // Log request for debugging
      print('DEBUG: Sending request to Gemini with ${contents.length} messages');

      // Make API request
      final response = await _dio.post(
        '$_baseUrl/models/gemini-2.0-flash-exp:generateContent?key=$_apiKey',
        data: {
          'contents': contents,
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 4096, // Increased for longer responses
          },
          'safetySettings': [
            {
              'category': 'HARM_CATEGORY_HARASSMENT',
              'threshold': 'BLOCK_NONE',
            },
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH',
              'threshold': 'BLOCK_NONE',
            },
            {
              'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              'threshold': 'BLOCK_NONE',
            },
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_NONE',
            },
          ],
        },
      );

      // Extract response with null safety and debugging
      final responseData = response.data as Map<String, dynamic>?;
      if (responseData == null) {
        throw ServerException(
          message: 'Empty response from Gemini API',
          code: 'EMPTY_RESPONSE',
        );
      }

      // Check for API errors first
      if (responseData.containsKey('error')) {
        final error = responseData['error'] as Map<String, dynamic>;
        throw ServerException(
          message: 'Gemini API Error: ${error['message'] ?? 'Unknown error'}',
          code: 'API_ERROR',
          details: error,
        );
      }

      final candidates = responseData['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        // Log the full response for debugging
        print('DEBUG: Full Gemini response: ${responseData.toString()}');
        throw ServerException(
          message: 'No candidates in Gemini response. Response keys: ${responseData.keys.join(", ")}',
          code: 'EMPTY_CANDIDATES',
          details: {'response': responseData},
        );
      }

      final firstCandidate = candidates.first as Map<String, dynamic>?;
      if (firstCandidate == null) {
        throw ServerException(
          message: 'Invalid candidate format in Gemini response',
          code: 'INVALID_CANDIDATE',
        );
      }

      // Check for blocked content
      if (firstCandidate.containsKey('finishReason')) {
        final finishReason = firstCandidate['finishReason'] as String?;
        if (finishReason == 'SAFETY' || finishReason == 'RECITATION') {
          throw ServerException(
            message: 'Content was blocked by Gemini: $finishReason',
            code: 'CONTENT_BLOCKED',
          );
        }
      }

      final content = firstCandidate['content'] as Map<String, dynamic>?;
      if (content == null) {
        print('DEBUG: Candidate structure: ${firstCandidate.toString()}');
        throw ServerException(
          message: 'No content in Gemini response. Candidate keys: ${firstCandidate.keys.join(", ")}',
          code: 'EMPTY_CONTENT',
          details: {'candidate': firstCandidate},
        );
      }

      final parts = content['parts'] as List<dynamic>?;
      if (parts == null || parts.isEmpty) {
        print('DEBUG: Content structure: ${content.toString()}');
        throw ServerException(
          message: 'No parts in Gemini response. Content keys: ${content.keys.join(", ")}',
          code: 'EMPTY_PARTS',
          details: {'content': content},
        );
      }

      final firstPart = parts.first as Map<String, dynamic>?;
      if (firstPart == null || !firstPart.containsKey('text')) {
        print('DEBUG: Parts structure: ${parts.toString()}');
        throw ServerException(
          message: 'No text in Gemini response. Part keys: ${firstPart?.keys.join(", ") ?? "null"}',
          code: 'NO_TEXT',
          details: {'parts': parts},
        );
      }

      final text = firstPart['text'] as String;

      // Create response message
      return AIMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: MessageRole.assistant,
        content: text,
        timestamp: DateTime.now(),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException(
        message: 'Error communicating with Gemini: $e',
        code: 'GEMINI_ERROR',
      );
    }
  }

  @override
  Future<bool> testConnection() async {
    try {
      await sendMessage(
        message: 'Hello',
        conversationHistory: [],
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<String>> listAvailableModels() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/models?key=$_apiKey',
      );

      final data = response.data as Map<String, dynamic>;
      final models = data['models'] as List;

      return models
          .map((model) {
            final name = model['name'] as String;
            // Extract just the model name from "models/gemini-1.5-flash"
            return name.replaceFirst('models/', '');
          })
          .where((name) => name.contains('gemini'))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Build Gemini-formatted messages
  List<Map<String, dynamic>> _buildGeminiMessages(
    String message,
    List<AIMessageEntity> conversationHistory,
    Map<String, dynamic>? context,
  ) {
    final messages = <Map<String, dynamic>>[];

    // Add context as system message if provided
    if (context != null) {
      final contextString = _formatContext(context);
      messages.add({
        'role': 'user',
        'parts': [
          {'text': 'Contexto:\n$contextString'}
        ],
      });
      messages.add({
        'role': 'model',
        'parts': [
          {'text': 'Entendido. Como posso ajudar?'}
        ],
      });
    }

    // Add conversation history
    for (final msg in conversationHistory) {
      if (msg.role == MessageRole.system) continue;

      messages.add({
        'role': msg.role == MessageRole.user ? 'user' : 'model',
        'parts': [
          {'text': msg.content}
        ],
      });
    }

    // Add current message
    messages.add({
      'role': 'user',
      'parts': [
        {'text': message}
      ],
    });

    return messages;
  }

  /// Format context data into readable string from structured JSON
  String _formatContext(Map<String, dynamic> context) {
    final buffer = StringBuffer();

    // Summary section
    if (context.containsKey('summary')) {
      final summary = context['summary'] as Map<String, dynamic>;
      buffer.writeln('## Resumo Financeiro:');
      buffer.writeln('- Receita Total: R\$ ${summary['totalIncome']}');
      buffer.writeln('- Despesas Totais: R\$ ${summary['totalExpenses']}');
      buffer.writeln('- Saldo Atual: R\$ ${summary['balance']}');
      buffer.writeln('- Total de Transações: ${summary['transactionCount']}');

      if (summary.containsKey('averages')) {
        final averages = summary['averages'] as Map<String, dynamic>;
        buffer.writeln('\nMédias:');
        buffer.writeln('- Gasto Diário: R\$ ${averages['dailyExpense'].toStringAsFixed(2)}');
        buffer.writeln('- Gasto Semanal: R\$ ${averages['weeklyExpense'].toStringAsFixed(2)}');
        buffer.writeln('- Gasto Mensal: R\$ ${averages['monthlyExpense'].toStringAsFixed(2)}');
      }
    }

    // Category breakdown
    if (context.containsKey('topExpenseCategories')) {
      buffer.writeln('\n## Maiores Categorias de Gastos:');
      final categories = context['topExpenseCategories'] as List<dynamic>;
      for (final category in categories) {
        if (category is Map<String, dynamic>) {
          buffer.writeln('- ${category['name']}: R\$ ${category['amount'].toStringAsFixed(2)} (${category['percentage'].toStringAsFixed(1)}%)');
        }
      }
    }

    // Goals
    if (context.containsKey('goals')) {
      buffer.writeln('\n## Metas Financeiras:');
      final goals = context['goals'] as List<dynamic>;
      for (final goal in goals) {
        if (goal is Map<String, dynamic>) {
          buffer.writeln('- ${goal['title']}: ${goal['progress'].toStringAsFixed(1)}% completo');
          buffer.writeln('  Meta: R\$ ${goal['targetAmount']} | Atual: R\$ ${goal['currentAmount']}');
          buffer.writeln('  Faltam: R\$ ${goal['remainingAmount']} em ${goal['daysRemaining']} dias');
          buffer.writeln('  Economia diária necessária: R\$ ${goal['requiredDailySavings'].toStringAsFixed(2)}');
        }
      }
    }

    // Recent transactions summary
    if (context.containsKey('transactions')) {
      final transactions = context['transactions'] as List<dynamic>;
      if (transactions.isNotEmpty) {
        buffer.writeln('\n## Últimas ${transactions.length > 10 ? 10 : transactions.length} Transações:');
        for (final transaction in transactions.take(10)) {
          if (transaction is Map<String, dynamic>) {
            final type = transaction['isIncome'] == true ? '📈' : '📉';
            buffer.writeln('$type ${transaction['type']}: R\$ ${transaction['amount']} - ${transaction['category']}');
          }
        }
      }
    }

    return buffer.toString();
  }

  /// Handle Dio errors
  Exception _handleDioError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final message = error.response!.data?.toString() ?? 'Unknown error';

      if (statusCode == 401 || statusCode == 403) {
        return AuthException(
          message: 'Invalid API key',
          code: 'INVALID_API_KEY',
        );
      } else if (statusCode == 429) {
        return RateLimitException(
          message: 'Rate limit exceeded',
          code: 'RATE_LIMIT',
        );
      }

      return ServerException(
        message: 'API error: $message',
        code: 'API_ERROR_$statusCode',
      );
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return TimeoutException(
        message: 'Request timeout',
        code: 'TIMEOUT',
      );
    }

    if (error.type == DioExceptionType.connectionError) {
      return NetworkException(
        message: 'Network error',
        code: 'NETWORK_ERROR',
      );
    }

    return ServerException(
      message: error.message ?? 'Unknown error',
      code: 'UNKNOWN_ERROR',
    );
  }
}

/// Implementation for Anthropic Claude API
class ClaudeRemoteDataSource implements AIRemoteDataSource {
  final Dio _dio;
  final String _apiKey;
  static const String _baseUrl = 'https://api.anthropic.com/v1';
  static const String _model = 'claude-sonnet-4-5-20250929';

  ClaudeRemoteDataSource({
    required Dio dio,
    required String apiKey,
  })  : _dio = dio,
        _apiKey = apiKey;

  @override
  Future<AIMessageModel> sendMessage({
    required String message,
    required List<AIMessageEntity> conversationHistory,
    Map<String, dynamic>? context,
  }) async {
    try {
      // Build conversation messages
      final messages = _buildClaudeMessages(message, conversationHistory);

      // Build system prompt with context
      final systemPrompt = _buildSystemPrompt(context);

      // Make API request
      final response = await _dio.post(
        '$_baseUrl/messages',
        options: Options(
          headers: {
            'x-api-key': _apiKey,
            'anthropic-version': '2023-06-01',
            'content-type': 'application/json',
          },
        ),
        data: {
          'model': _model,
          'max_tokens': 2048,
          'system': systemPrompt,
          'messages': messages,
        },
      );

      // Extract response with null safety
      final responseData = response.data as Map<String, dynamic>?;
      if (responseData == null) {
        throw ServerException(
          message: 'Empty response from Claude API',
          code: 'EMPTY_RESPONSE',
        );
      }

      final content = responseData['content'] as List<dynamic>?;
      if (content == null || content.isEmpty) {
        throw ServerException(
          message: 'No content in Claude response',
          code: 'EMPTY_CONTENT',
        );
      }

      final firstContent = content.first as Map<String, dynamic>?;
      if (firstContent == null || !firstContent.containsKey('text')) {
        throw ServerException(
          message: 'No text in Claude response',
          code: 'NO_TEXT',
        );
      }

      final text = firstContent['text'] as String;

      // Create response message
      return AIMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: MessageRole.assistant,
        content: text,
        timestamp: DateTime.now(),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException(
        message: 'Error communicating with Claude: $e',
        code: 'CLAUDE_ERROR',
      );
    }
  }

  @override
  Future<bool> testConnection() async {
    try {
      await sendMessage(
        message: 'Hello',
        conversationHistory: [],
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<String>> listAvailableModels() async {
    // Claude doesn't have a public models list endpoint
    // Return the known available models (updated for 2025)
    return [
      'claude-sonnet-4-5-20250929',  // Latest Sonnet 4.5 (Recommended)
      'claude-3-7-sonnet',           // With extended thinking
      'claude-haiku-4-5',            // Fastest and most intelligent Haiku
    ];
  }

  /// Build Claude-formatted messages
  List<Map<String, dynamic>> _buildClaudeMessages(
    String message,
    List<AIMessageEntity> conversationHistory,
  ) {
    final messages = <Map<String, dynamic>>[];

    // Add conversation history (skip system messages)
    for (final msg in conversationHistory) {
      if (msg.role == MessageRole.system) continue;

      messages.add({
        'role': msg.role == MessageRole.user ? 'user' : 'assistant',
        'content': msg.content,
      });
    }

    // Add current message
    messages.add({
      'role': 'user',
      'content': message,
    });

    return messages;
  }

  /// Build system prompt with context
  String _buildSystemPrompt(Map<String, dynamic>? context) {
    final buffer = StringBuffer();

    buffer.writeln('Você é um assistente financeiro especializado em ajudar usuários a gerenciar suas reservas de capital, despesas e metas financeiras.');
    buffer.writeln('Você deve fornecer insights acionáveis, recomendações personalizadas e análises detalhadas.');
    buffer.writeln('Sempre responda em português do Brasil.');
    buffer.writeln('Seja direto, claro e empático.');

    if (context != null) {
      buffer.writeln('\n## Contexto Financeiro do Usuário:');
      buffer.writeln(_formatContext(context));
    }

    return buffer.toString();
  }

  /// Format context data into readable string from structured JSON (Claude version)
  String _formatContext(Map<String, dynamic> context) {
    final buffer = StringBuffer();

    // Summary section
    if (context.containsKey('summary')) {
      final summary = context['summary'] as Map<String, dynamic>;
      buffer.writeln('### Resumo Financeiro:');
      buffer.writeln('- Receita Total: R\$ ${summary['totalIncome']}');
      buffer.writeln('- Despesas Totais: R\$ ${summary['totalExpenses']}');
      buffer.writeln('- Saldo Atual: R\$ ${summary['balance']}');
      buffer.writeln('- Total de Transações: ${summary['transactionCount']}');

      if (summary.containsKey('averages')) {
        final averages = summary['averages'] as Map<String, dynamic>;
        buffer.writeln('\n#### Médias:');
        buffer.writeln('- Gasto Diário: R\$ ${averages['dailyExpense'].toStringAsFixed(2)}');
        buffer.writeln('- Gasto Semanal: R\$ ${averages['weeklyExpense'].toStringAsFixed(2)}');
        buffer.writeln('- Gasto Mensal: R\$ ${averages['monthlyExpense'].toStringAsFixed(2)}');
      }
    }

    // Category breakdown
    if (context.containsKey('topExpenseCategories')) {
      buffer.writeln('\n### Maiores Categorias de Gastos:');
      final categories = context['topExpenseCategories'] as List<dynamic>;
      for (final category in categories) {
        if (category is Map<String, dynamic>) {
          buffer.writeln('- ${category['name']}: R\$ ${category['amount'].toStringAsFixed(2)} (${category['percentage'].toStringAsFixed(1)}%)');
        }
      }
    }

    // Goals
    if (context.containsKey('goals')) {
      buffer.writeln('\n### Metas Financeiras:');
      final goals = context['goals'] as List<dynamic>;
      for (final goal in goals) {
        if (goal is Map<String, dynamic>) {
          buffer.writeln('- **${goal['title']}**: ${goal['progress'].toStringAsFixed(1)}% completo');
          buffer.writeln('  - Meta: R\$ ${goal['targetAmount']} | Atual: R\$ ${goal['currentAmount']}');
          buffer.writeln('  - Faltam: R\$ ${goal['remainingAmount']} em ${goal['daysRemaining']} dias');
          buffer.writeln('  - Economia diária necessária: R\$ ${goal['requiredDailySavings'].toStringAsFixed(2)}');
        }
      }
    }

    // Recent transactions summary
    if (context.containsKey('transactions')) {
      final transactions = context['transactions'] as List<dynamic>;
      if (transactions.isNotEmpty) {
        buffer.writeln('\n### Últimas ${transactions.length > 10 ? 10 : transactions.length} Transações:');
        for (final transaction in transactions.take(10)) {
          if (transaction is Map<String, dynamic>) {
            final type = transaction['isIncome'] == true ? '📈 Receita' : '📉 Despesa';
            buffer.writeln('- $type: R\$ ${transaction['amount']} - ${transaction['category']}');
          }
        }
      }
    }

    return buffer.toString();
  }

  /// Handle Dio errors
  Exception _handleDioError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final message = error.response!.data?.toString() ?? 'Unknown error';

      if (statusCode == 401 || statusCode == 403) {
        return AuthException(
          message: 'Invalid API key',
          code: 'INVALID_API_KEY',
        );
      } else if (statusCode == 429) {
        return RateLimitException(
          message: 'Rate limit exceeded',
          code: 'RATE_LIMIT',
        );
      }

      return ServerException(
        message: 'API error: $message',
        code: 'API_ERROR_$statusCode',
      );
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return TimeoutException(
        message: 'Request timeout',
        code: 'TIMEOUT',
      );
    }

    if (error.type == DioExceptionType.connectionError) {
      return NetworkException(
        message: 'Network error',
        code: 'NETWORK_ERROR',
      );
    }

    return ServerException(
      message: error.message ?? 'Unknown error',
      code: 'UNKNOWN_ERROR',
    );
  }
}
