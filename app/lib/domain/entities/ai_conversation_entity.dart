import 'package:equatable/equatable.dart';
import 'ai_message_entity.dart';

/// Entity representing an AI conversation session
class AIConversationEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final List<AIMessageEntity> messages;
  final AIProvider provider;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  const AIConversationEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.messages,
    required this.provider,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  /// Get the last message in the conversation
  AIMessageEntity? get lastMessage {
    return messages.isNotEmpty ? messages.last : null;
  }

  /// Get total message count
  int get messageCount => messages.length;

  /// Check if conversation is empty
  bool get isEmpty => messages.isEmpty;

  /// Get all user messages
  List<AIMessageEntity> get userMessages {
    return messages.where((m) => m.isUser).toList();
  }

  /// Get all assistant messages
  List<AIMessageEntity> get assistantMessages {
    return messages.where((m) => m.isAssistant).toList();
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        messages,
        provider,
        createdAt,
        updatedAt,
        metadata,
      ];

  /// Create a copy with modified fields
  AIConversationEntity copyWith({
    String? id,
    String? userId,
    String? title,
    List<AIMessageEntity>? messages,
    AIProvider? provider,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return AIConversationEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      provider: provider ?? this.provider,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}
