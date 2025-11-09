import 'package:equatable/equatable.dart';

/// Enum representing AI provider options
enum AIProvider {
  gemini,
  claude;

  String get displayName {
    switch (this) {
      case AIProvider.gemini:
        return 'Google Gemini';
      case AIProvider.claude:
        return 'Anthropic Claude';
    }
  }

  String get icon {
    switch (this) {
      case AIProvider.gemini:
        return '✨'; // Gemini icon
      case AIProvider.claude:
        return '🤖'; // Claude icon
    }
  }
}

/// Enum representing message roles in conversation
enum MessageRole {
  user,
  assistant,
  system;

  String get displayName {
    switch (this) {
      case MessageRole.user:
        return 'Você';
      case MessageRole.assistant:
        return 'Assistente';
      case MessageRole.system:
        return 'Sistema';
    }
  }
}

/// Entity representing a single message in AI conversation
class AIMessageEntity extends Equatable {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const AIMessageEntity({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.metadata,
  });

  /// Check if message is from user
  bool get isUser => role == MessageRole.user;

  /// Check if message is from assistant
  bool get isAssistant => role == MessageRole.assistant;

  /// Check if message is a system message
  bool get isSystem => role == MessageRole.system;

  /// Get formatted timestamp
  String get formattedTime {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  List<Object?> get props => [id, role, content, timestamp, metadata];

  /// Create a copy with modified fields
  AIMessageEntity copyWith({
    String? id,
    MessageRole? role,
    String? content,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return AIMessageEntity(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }
}
