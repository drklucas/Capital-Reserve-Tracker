import 'package:equatable/equatable.dart';

/// Enum representing different types of insights
enum InsightType {
  spending,
  saving,
  goal,
  recommendation,
  warning,
  achievement;

  String get displayName {
    switch (this) {
      case InsightType.spending:
        return 'Análise de Gastos';
      case InsightType.saving:
        return 'Economia';
      case InsightType.goal:
        return 'Meta';
      case InsightType.recommendation:
        return 'Recomendação';
      case InsightType.warning:
        return 'Aviso';
      case InsightType.achievement:
        return 'Conquista';
    }
  }

  String get icon {
    switch (this) {
      case InsightType.spending:
        return '💰';
      case InsightType.saving:
        return '💵';
      case InsightType.goal:
        return '🎯';
      case InsightType.recommendation:
        return '💡';
      case InsightType.warning:
        return '⚠️';
      case InsightType.achievement:
        return '🏆';
    }
  }
}

/// Enum representing insight priority levels
enum InsightPriority {
  low,
  medium,
  high,
  critical;

  String get displayName {
    switch (this) {
      case InsightPriority.low:
        return 'Baixa';
      case InsightPriority.medium:
        return 'Média';
      case InsightPriority.high:
        return 'Alta';
      case InsightPriority.critical:
        return 'Crítica';
    }
  }
}

/// Entity representing an AI-generated insight about user's finances
class AIInsightEntity extends Equatable {
  final String id;
  final String userId;
  final InsightType type;
  final InsightPriority priority;
  final String title;
  final String description;
  final String? actionableAdvice;
  final Map<String, dynamic>? data;
  final DateTime generatedAt;
  final bool isRead;
  final bool isDismissed;

  const AIInsightEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.priority,
    required this.title,
    required this.description,
    this.actionableAdvice,
    this.data,
    required this.generatedAt,
    this.isRead = false,
    this.isDismissed = false,
  });

  /// Check if insight is active (not dismissed)
  bool get isActive => !isDismissed;

  /// Check if insight is new (not read)
  bool get isNew => !isRead;

  /// Get formatted date
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(generatedAt);

    if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else {
      return '${generatedAt.day}/${generatedAt.month}/${generatedAt.year}';
    }
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        priority,
        title,
        description,
        actionableAdvice,
        data,
        generatedAt,
        isRead,
        isDismissed,
      ];

  /// Create a copy with modified fields
  AIInsightEntity copyWith({
    String? id,
    String? userId,
    InsightType? type,
    InsightPriority? priority,
    String? title,
    String? description,
    String? actionableAdvice,
    Map<String, dynamic>? data,
    DateTime? generatedAt,
    bool? isRead,
    bool? isDismissed,
  }) {
    return AIInsightEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      title: title ?? this.title,
      description: description ?? this.description,
      actionableAdvice: actionableAdvice ?? this.actionableAdvice,
      data: data ?? this.data,
      generatedAt: generatedAt ?? this.generatedAt,
      isRead: isRead ?? this.isRead,
      isDismissed: isDismissed ?? this.isDismissed,
    );
  }
}
