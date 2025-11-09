import 'package:flutter/foundation.dart';
import '../../domain/entities/ai_message_entity.dart';
import '../../domain/entities/ai_conversation_entity.dart';
import '../../domain/entities/ai_insight_entity.dart';
import '../../domain/usecases/ai/send_message_usecase.dart';
import '../../domain/usecases/ai/generate_insights_usecase.dart';
import '../../domain/usecases/ai/manage_api_key_usecase.dart';
import '../../domain/usecases/ai/analyze_spending_usecase.dart';
import '../../domain/usecases/ai/get_goal_recommendations_usecase.dart';
import '../../domain/repositories/ai_repository.dart';

/// Status enum for AI assistant operations
enum AIAssistantStatus {
  initial,
  loading,
  loaded,
  sending,
  generating,
  error,
}

/// Provider for AI Assistant state management
class AIAssistantProvider extends ChangeNotifier {
  final SendMessageUseCase _sendMessageUseCase;
  final GenerateInsightsUseCase _generateInsightsUseCase;
  final ManageApiKeyUseCase _manageApiKeyUseCase;
  final AnalyzeSpendingUseCase _analyzeSpendingUseCase;
  final GetGoalRecommendationsUseCase _getGoalRecommendationsUseCase;
  final AIRepository _aiRepository;

  // State
  AIAssistantStatus _status = AIAssistantStatus.initial;
  String? _errorMessage;
  AIProvider _selectedProvider = AIProvider.gemini;
  List<AIMessageEntity> _messages = [];
  List<AIInsightEntity> _insights = [];
  List<AIConversationEntity> _conversations = [];
  AIConversationEntity? _currentConversation;

  // API key configuration status
  Map<AIProvider, bool> _apiKeyConfigured = {
    AIProvider.gemini: false,
    AIProvider.claude: false,
  };

  AIAssistantProvider({
    required SendMessageUseCase sendMessageUseCase,
    required GenerateInsightsUseCase generateInsightsUseCase,
    required ManageApiKeyUseCase manageApiKeyUseCase,
    required AnalyzeSpendingUseCase analyzeSpendingUseCase,
    required GetGoalRecommendationsUseCase getGoalRecommendationsUseCase,
    required AIRepository aiRepository,
  })  : _sendMessageUseCase = sendMessageUseCase,
        _generateInsightsUseCase = generateInsightsUseCase,
        _manageApiKeyUseCase = manageApiKeyUseCase,
        _analyzeSpendingUseCase = analyzeSpendingUseCase,
        _getGoalRecommendationsUseCase = getGoalRecommendationsUseCase,
        _aiRepository = aiRepository;

  // Getters
  AIAssistantStatus get status => _status;
  String? get errorMessage => _errorMessage;
  AIProvider get selectedProvider => _selectedProvider;
  List<AIMessageEntity> get messages => List.unmodifiable(_messages);
  List<AIInsightEntity> get insights => List.unmodifiable(_insights);
  List<AIConversationEntity> get conversations => List.unmodifiable(_conversations);
  AIConversationEntity? get currentConversation => _currentConversation;
  bool get isLoading => _status == AIAssistantStatus.loading || _status == AIAssistantStatus.sending || _status == AIAssistantStatus.generating;
  bool get hasError => _status == AIAssistantStatus.error;

  /// Check if provider is configured
  bool isProviderConfigured(AIProvider provider) {
    return _apiKeyConfigured[provider] ?? false;
  }

  /// Get active insights (not dismissed)
  List<AIInsightEntity> get activeInsights {
    return _insights.where((i) => i.isActive).toList();
  }

  /// Get new insights (not read)
  List<AIInsightEntity> get newInsights {
    return _insights.where((i) => i.isNew).toList();
  }

  /// Get insights by type
  List<AIInsightEntity> getInsightsByType(InsightType type) {
    return _insights.where((i) => i.type == type && i.isActive).toList();
  }

  /// Get insights by priority
  List<AIInsightEntity> getInsightsByPriority(InsightPriority priority) {
    return _insights.where((i) => i.priority == priority && i.isActive).toList();
  }

  /// Initialize provider - check API key configuration and load insights
  Future<void> initialize({String? userId}) async {
    _status = AIAssistantStatus.loading;
    notifyListeners();

    try {
      // Check Gemini API key
      final geminiResult = await _manageApiKeyUseCase.isConfigured(
        provider: AIProvider.gemini,
      );
      geminiResult.fold(
        (failure) => _apiKeyConfigured[AIProvider.gemini] = false,
        (isConfigured) => _apiKeyConfigured[AIProvider.gemini] = isConfigured,
      );

      // Check Claude API key
      final claudeResult = await _manageApiKeyUseCase.isConfigured(
        provider: AIProvider.claude,
      );
      claudeResult.fold(
        (failure) => _apiKeyConfigured[AIProvider.claude] = false,
        (isConfigured) => _apiKeyConfigured[AIProvider.claude] = isConfigured,
      );

      // Set default provider to configured one
      if (_apiKeyConfigured[AIProvider.claude] == true) {
        _selectedProvider = AIProvider.claude;
      } else if (_apiKeyConfigured[AIProvider.gemini] == true) {
        _selectedProvider = AIProvider.gemini;
      }

      // Load existing insights if userId provided
      if (userId != null) {
        await loadInsights(userId);
      }

      _status = AIAssistantStatus.loaded;
      _errorMessage = null;
    } catch (e) {
      _status = AIAssistantStatus.error;
      _errorMessage = 'Erro ao inicializar: $e';
    }

    notifyListeners();
  }

  /// Set API key for a provider
  Future<void> setApiKey(AIProvider provider, String apiKey) async {
    _status = AIAssistantStatus.loading;
    notifyListeners();

    final result = await _manageApiKeyUseCase.setApiKey(
      provider: provider,
      apiKey: apiKey,
    );

    result.fold(
      (failure) {
        _status = AIAssistantStatus.error;
        _errorMessage = failure.message;
      },
      (_) {
        _apiKeyConfigured[provider] = true;
        _selectedProvider = provider;
        _status = AIAssistantStatus.loaded;
        _errorMessage = null;
      },
    );

    notifyListeners();
  }

  /// Remove API key for a provider
  Future<void> removeApiKey(AIProvider provider) async {
    final result = await _manageApiKeyUseCase.removeApiKey(provider: provider);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
      },
      (_) {
        _apiKeyConfigured[provider] = false;
        if (_selectedProvider == provider) {
          // Switch to other provider if available
          if (provider == AIProvider.gemini && _apiKeyConfigured[AIProvider.claude] == true) {
            _selectedProvider = AIProvider.claude;
          } else if (provider == AIProvider.claude && _apiKeyConfigured[AIProvider.gemini] == true) {
            _selectedProvider = AIProvider.gemini;
          }
        }
      },
    );

    notifyListeners();
  }

  /// Test connection to provider
  Future<bool> testConnection(AIProvider provider) async {
    final result = await _manageApiKeyUseCase.testConnection(provider: provider);
    return result.getOrElse(() => false);
  }

  /// List available models for a provider
  Future<List<String>> listAvailableModels(AIProvider provider) async {
    final result = await _aiRepository.listAvailableModels(provider: provider);
    return result.fold(
      (failure) => [],
      (models) => models,
    );
  }

  /// Change selected provider
  void setProvider(AIProvider provider) {
    if (_apiKeyConfigured[provider] == true) {
      _selectedProvider = provider;
      notifyListeners();
    }
  }

  /// Send message to AI
  Future<void> sendMessage(String userId, String message, {Map<String, dynamic>? context}) async {
    if (message.trim().isEmpty) return;

    // Add user message to list
    final userMessage = AIMessageEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.user,
      content: message,
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    _status = AIAssistantStatus.sending;
    notifyListeners();

    final result = await _sendMessageUseCase(
      userId: userId,
      message: message,
      provider: _selectedProvider,
      conversationHistory: _messages,
      context: context,
    );

    result.fold(
      (failure) {
        _status = AIAssistantStatus.error;
        _errorMessage = failure.message;

        // Add error message
        _messages.add(
          AIMessageEntity(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            role: MessageRole.system,
            content: 'Erro: ${failure.message}',
            timestamp: DateTime.now(),
          ),
        );
      },
      (response) {
        _messages.add(response);
        _status = AIAssistantStatus.loaded;
        _errorMessage = null;
      },
    );

    notifyListeners();
  }

  /// Generate insights
  Future<void> generateInsights(String userId) async {
    _status = AIAssistantStatus.generating;
    notifyListeners();

    final result = await _generateInsightsUseCase(
      userId: userId,
      provider: _selectedProvider,
    );

    result.fold(
      (failure) {
        _status = AIAssistantStatus.error;
        _errorMessage = failure.message;
      },
      (newInsights) {
        _insights = newInsights;
        _status = AIAssistantStatus.loaded;
        _errorMessage = null;
      },
    );

    notifyListeners();
  }

  /// Analyze spending
  Future<void> analyzeSpending(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _status = AIAssistantStatus.loading;
    notifyListeners();

    final result = await _analyzeSpendingUseCase(
      userId: userId,
      provider: _selectedProvider,
      startDate: startDate,
      endDate: endDate,
    );

    result.fold(
      (failure) {
        _status = AIAssistantStatus.error;
        _errorMessage = failure.message;
      },
      (analysis) {
        // Add analysis as assistant message
        _messages.add(
          AIMessageEntity(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            role: MessageRole.assistant,
            content: analysis,
            timestamp: DateTime.now(),
            metadata: {'type': 'spending_analysis'},
          ),
        );
        _status = AIAssistantStatus.loaded;
        _errorMessage = null;
      },
    );

    notifyListeners();
  }

  /// Get goal recommendations
  Future<void> getGoalRecommendations(String userId, String goalId) async {
    _status = AIAssistantStatus.loading;
    notifyListeners();

    final result = await _getGoalRecommendationsUseCase(
      userId: userId,
      goalId: goalId,
      provider: _selectedProvider,
    );

    result.fold(
      (failure) {
        _status = AIAssistantStatus.error;
        _errorMessage = failure.message;
      },
      (recommendations) {
        // Add recommendations as assistant message
        _messages.add(
          AIMessageEntity(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            role: MessageRole.assistant,
            content: recommendations,
            timestamp: DateTime.now(),
            metadata: {'type': 'goal_recommendations', 'goalId': goalId},
          ),
        );
        _status = AIAssistantStatus.loaded;
        _errorMessage = null;
      },
    );

    notifyListeners();
  }

  /// Load conversations
  Future<void> loadConversations(String userId) async {
    final result = await _aiRepository.getConversations(userId: userId, limit: 20);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
      },
      (conversations) {
        _conversations = conversations;
        _errorMessage = null;
      },
    );

    notifyListeners();
  }

  /// Create new conversation
  Future<void> createConversation(String userId, {String? title}) async {
    final result = await _aiRepository.createConversation(
      userId: userId,
      provider: _selectedProvider,
      title: title,
    );

    result.fold(
      (failure) {
        _errorMessage = failure.message;
      },
      (conversation) {
        _currentConversation = conversation;
        _messages = [];
        _conversations.insert(0, conversation);
        _errorMessage = null;
      },
    );

    notifyListeners();
  }

  /// Load insights
  Future<void> loadInsights(String userId) async {
    final result = await _aiRepository.getInsights(
      userId: userId,
      limit: 50,
      includeRead: true,
      includeDismissed: false,
    );

    result.fold(
      (failure) {
        _errorMessage = failure.message;
      },
      (insights) {
        _insights = insights;
        _errorMessage = null;
      },
    );

    notifyListeners();
  }

  /// Add a message to the conversation
  void addMessage(AIMessageEntity message) {
    _messages.add(message);
    notifyListeners();
  }

  /// Clear messages
  void clearMessages() {
    _messages = [];
    _currentConversation = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset state
  void reset() {
    _status = AIAssistantStatus.initial;
    _errorMessage = null;
    _messages = [];
    _insights = [];
    _conversations = [];
    _currentConversation = null;
    notifyListeners();
  }
}
