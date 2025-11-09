import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/ai_message_entity.dart';

/// Model for AI message with Firestore serialization
class AIMessageModel extends AIMessageEntity {
  const AIMessageModel({
    required super.id,
    required super.role,
    required super.content,
    required super.timestamp,
    super.metadata,
  });

  /// Create from entity
  factory AIMessageModel.fromEntity(AIMessageEntity entity) {
    return AIMessageModel(
      id: entity.id,
      role: entity.role,
      content: entity.content,
      timestamp: entity.timestamp,
      metadata: entity.metadata,
    );
  }

  /// Create from Firestore document
  factory AIMessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AIMessageModel.fromMap(data, doc.id);
  }

  /// Create from map
  factory AIMessageModel.fromMap(Map<String, dynamic> map, [String? id]) {
    return AIMessageModel(
      id: id ?? map['id'] as String,
      role: _parseMessageRole(map['role'] as String),
      content: map['content'] as String,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Create from JSON
  factory AIMessageModel.fromJson(Map<String, dynamic> json) {
    return AIMessageModel(
      id: json['id'] as String,
      role: _parseMessageRole(json['role'] as String),
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'role': role.name,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.name,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Parse message role from string
  static MessageRole _parseMessageRole(String value) {
    return MessageRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MessageRole.user,
    );
  }
}
