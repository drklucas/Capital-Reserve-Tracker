import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/ai_insight_entity.dart';

/// Model for AI insight with Firestore serialization
class AIInsightModel extends AIInsightEntity {
  const AIInsightModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.priority,
    required super.title,
    required super.description,
    super.actionableAdvice,
    super.data,
    required super.generatedAt,
    super.isRead = false,
    super.isDismissed = false,
  });

  /// Create from entity
  factory AIInsightModel.fromEntity(AIInsightEntity entity) {
    return AIInsightModel(
      id: entity.id,
      userId: entity.userId,
      type: entity.type,
      priority: entity.priority,
      title: entity.title,
      description: entity.description,
      actionableAdvice: entity.actionableAdvice,
      data: entity.data,
      generatedAt: entity.generatedAt,
      isRead: entity.isRead,
      isDismissed: entity.isDismissed,
    );
  }

  /// Create from Firestore document
  factory AIInsightModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AIInsightModel.fromMap(data, doc.id);
  }

  /// Create from map
  factory AIInsightModel.fromMap(Map<String, dynamic> map, [String? id]) {
    return AIInsightModel(
      id: id ?? map['id'] as String,
      userId: map['userId'] as String,
      type: _parseInsightType(map['type'] as String),
      priority: _parseInsightPriority(map['priority'] as String),
      title: map['title'] as String,
      description: map['description'] as String,
      actionableAdvice: map['actionableAdvice'] as String?,
      data: map['data'] as Map<String, dynamic>?,
      generatedAt: (map['generatedAt'] as Timestamp).toDate(),
      isRead: map['isRead'] as bool? ?? false,
      isDismissed: map['isDismissed'] as bool? ?? false,
    );
  }

  /// Create from JSON
  factory AIInsightModel.fromJson(Map<String, dynamic> json) {
    return AIInsightModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: _parseInsightType(json['type'] as String),
      priority: _parseInsightPriority(json['priority'] as String),
      title: json['title'] as String,
      description: json['description'] as String,
      actionableAdvice: json['actionableAdvice'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      isDismissed: json['isDismissed'] as bool? ?? false,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
      'priority': priority.name,
      'title': title,
      'description': description,
      if (actionableAdvice != null) 'actionableAdvice': actionableAdvice,
      if (data != null) 'data': data,
      'generatedAt': Timestamp.fromDate(generatedAt),
      'isRead': isRead,
      'isDismissed': isDismissed,
    };
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
      'priority': priority.name,
      'title': title,
      'description': description,
      if (actionableAdvice != null) 'actionableAdvice': actionableAdvice,
      if (data != null) 'data': data,
      'generatedAt': generatedAt.toIso8601String(),
      'isRead': isRead,
      'isDismissed': isDismissed,
    };
  }

  /// Parse insight type from string
  static InsightType _parseInsightType(String value) {
    return InsightType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => InsightType.recommendation,
    );
  }

  /// Parse insight priority from string
  static InsightPriority _parseInsightPriority(String value) {
    return InsightPriority.values.firstWhere(
      (e) => e.name == value,
      orElse: () => InsightPriority.medium,
    );
  }
}
