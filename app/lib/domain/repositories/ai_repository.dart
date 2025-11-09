import 'package:dartz/dartz.dart';
import '../entities/ai_message_entity.dart';
import '../entities/ai_conversation_entity.dart';
import '../entities/ai_insight_entity.dart';
import '../../core/errors/failures.dart';

/// Abstract repository for AI operations
abstract class AIRepository {
  /// Send a message to the AI and get a response
  Future<Either<Failure, AIMessageEntity>> sendMessage({
    required String userId,
    required String message,
    required AIProvider provider,
    required List<AIMessageEntity> conversationHistory,
    Map<String, dynamic>? context,
  });

  /// Generate insights based on user's financial data
  Future<Either<Failure, List<AIInsightEntity>>> generateInsights({
    required String userId,
    required AIProvider provider,
    Map<String, dynamic>? filters,
  });

  /// Analyze spending patterns
  Future<Either<Failure, String>> analyzeSpending({
    required String userId,
    required AIProvider provider,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get recommendations for achieving a goal
  Future<Either<Failure, String>> getGoalRecommendations({
    required String userId,
    required String goalId,
    required AIProvider provider,
  });

  /// Ask a specific question about finances
  Future<Either<Failure, String>> askQuestion({
    required String userId,
    required String question,
    required AIProvider provider,
    Map<String, dynamic>? context,
  });

  /// Create a new conversation
  Future<Either<Failure, AIConversationEntity>> createConversation({
    required String userId,
    required AIProvider provider,
    String? title,
  });

  /// Get conversations for a user
  Future<Either<Failure, List<AIConversationEntity>>> getConversations({
    required String userId,
    int? limit,
  });

  /// Get a specific conversation by ID
  Future<Either<Failure, AIConversationEntity>> getConversationById({
    required String conversationId,
  });

  /// Update conversation
  Future<Either<Failure, AIConversationEntity>> updateConversation({
    required AIConversationEntity conversation,
  });

  /// Delete conversation
  Future<Either<Failure, void>> deleteConversation({
    required String conversationId,
  });

  /// Get insights for a user
  Future<Either<Failure, List<AIInsightEntity>>> getInsights({
    required String userId,
    int? limit,
    bool? includeRead,
    bool? includeDismissed,
  });

  /// Mark insight as read
  Future<Either<Failure, void>> markInsightAsRead({
    required String insightId,
  });

  /// Dismiss insight
  Future<Either<Failure, void>> dismissInsight({
    required String insightId,
  });

  /// Check if API key is configured for a provider
  Future<Either<Failure, bool>> isApiKeyConfigured({
    required AIProvider provider,
  });

  /// Set API key for a provider
  Future<Either<Failure, void>> setApiKey({
    required AIProvider provider,
    required String apiKey,
  });

  /// Remove API key for a provider
  Future<Either<Failure, void>> removeApiKey({
    required AIProvider provider,
  });

  /// Test API connection
  Future<Either<Failure, bool>> testConnection({
    required AIProvider provider,
  });

  /// List available AI models for a provider
  Future<Either<Failure, List<String>>> listAvailableModels({
    required AIProvider provider,
  });
}
